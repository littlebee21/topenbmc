#include <iostream>
#include <fstream>
#include <string>
#include <cstdlib>
#include <cstdio>
#include <ctime>
#include <unistd.h>

using namespace std;

// get today Date
std::string getDate() {
    time_t now = time(nullptr);
    tm* local_time = localtime(&now);
    std::string year = std::to_string(local_time->tm_year + 1900);
    std::string month = std::to_string(local_time->tm_mon + 1);
    std::string day = std::to_string(local_time->tm_mday);
    return year+ '-' + month + '-' +day;
}

// assert time before 23:59
bool beforeZero() {
    time_t now = time(nullptr);
    tm* local_time = localtime(&now);
    if (local_time->tm_hour < 23 || (local_time->tm_hour == 23 && local_time->tm_min < 59)) {
        std::cout << "below 23:59" << std::endl;
        return true;
    } else {
        std::cout << "beyond 23:59" << std::endl;
        return false;
    }
}


// get old data from power_data.txt
void getPowerData(double* total, int* count, double* tmp, double* peak) {
    // date       total count tmp average
    // 2023-11-01 ****  ***** *** *******
    ifstream fin("/data/power_data");
    string line;
    getline(fin, line);
    fin.close();

    std::string now = getDate();
    char date[20];

    sscanf(line.c_str(), "%s %lf %d %lf %lf", date, total, count, tmp, peak);
    if (now != std::string(date)) {
        total = 0;
        count = 0;
        tmp = 0;
        peak = 0;
    }
}

// get two sensor data
int getCurrentPower() {
    // Set the file path
    string file1 = "/sys/class/hwmon/hwmon4/power1_input";
    string file2 = "/sys/class/hwmon/hwmon5/power1_input";
    // Read the data from the file
    ifstream fin1(file1), fin2(file2);
    int power1_value, power2_value;
    fin1 >> power1_value;
    fin2 >> power2_value;
    fin1.close();
    fin2.close();
    int value = power1_value + power2_value;
    return value;
}


int main() {
    // Set the time interval for data collection
    int interval = 3;

    int count;
    double tmp;
    double total;
    double value;
    double peak;
    double average;
    getPowerData(&total, &count, &tmp, &peak);

    // Start collecting data
    while (beforeZero()) {
        // Wait for the next interval
        sleep(interval);
        value = getCurrentPower();

        // peak
        if (value/1000000.0 > peak)
            peak = value/1000000.0;

        // Calculate the average power
        count++;
        tmp += value;
        average = (double)tmp / count / 1000000.0;

        // Calculate total power consumption
        total = total + (double)value / 1200 / 1000000.0;

        // Print the results
        // date       total count tmp average peak
        // 2023-11-01 ***** ***** *** ******* ****
        ofstream fout("/data/power_data");
        fout << getDate() << " " << total << " " << count << " " << tmp << " " << average << " " << peak << endl;
        fout.close();
        cout << getDate() << " " << total << " " << count << " " << tmp << " " << average << " " << peak << endl;
    }
}
