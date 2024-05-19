#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <string.h>

int main() 
{
    int ret = 0;
    FILE *value;
    FILE *mointor;
    char valuebuff[2]={0};
    char gpiobuff[2]={0};
    char moinbuff[4]={0};
    int ch;

//更新gpio
//  读取当前gpio得知
    mointor = fopen("/usr/bin/mointor.txt","rw+");
    value = fopen("/sys/class/gpio/gpio860/value","r");
    if(value == NULL) //该文件不存在
    {
	printf("file not exiting\n");
	ret=fseek(mointor,0,SEEK_SET);
	ch=fwrite("200",1,3,mointor); //reboot情况下不存在文件，向其中写入0
	if(ch<0)
	{
	    fclose(mointor);
	    return -1;
	}
    }
//读取文件
    ret=fseek(mointor,2,SEEK_SET);
    ch=fread(gpiobuff,1,1,mointor);
    if(ch == 0)
    {
	return -1;
    }
    gpiobuff[2]='\0';
    ret = strcmp(gpiobuff,"0");//没有gpio860
    if(ret == 0)
    {
	ret = system("echo 860 > /sys/class/gpio/export");
	ret=fseek(mointor,2,SEEK_SET);
	ch=fwrite("1",1,1,mointor); //创建gpio并且置1 不用监测该文件是否存在
	if(ch<0)
	{
	    fclose(mointor);
	    return -1;
	}
    }

//gpio
    fseek(value,0,SEEK_SET);
    fread(valuebuff,1,1,value);
    valuebuff[2]='\0';
    fclose(value);

//将value写到当前状态里面 第一个字节
    ret=fseek(mointor,0,SEEK_SET);
    ch=fwrite(valuebuff,1,1,mointor);
    if(ch == 0)
    {
	return -1;
    }

    ret=fseek(mointor,0,SEEK_SET);
    ret=fread(moinbuff,1,3,mointor);
    moinbuff[4]='\0';
    if(strcmp(moinbuff,"111")==0) //开机当中
    {
	fclose(mointor);
	return -1;
    }
    ret = strcmp(moinbuff,"101");//开机时
    if(ret == 0)
    {
	// 开机脚本
	ret = system("tmp421.sh");
        ret = system("lm75.sh");
        ret=system("busctl set-property xyz.openbmc_project.State.Chassis0  /xyz/openbmc_project/state/chassis0  xyz.openbmc_project.State.Chassis CurrentPowerState s xyz.openbmc_project.State.Chassis.PowerState.On");
        ret = system("systemctl restart obmc-read-eeprom@system-motherboard.service");
	ret=fseek(mointor,0,SEEK_SET);
	ch=fwrite("111",1,3,mointor);//将value保存到上次当中

    }
    ret = strcmp(moinbuff,"011"); //关机时
    if(ret == 0)
    {
	// 关机脚本
	ret = system("tmp421bye.sh");
	ret = system("lm75bye.sh");
        ret=system("busctl set-property xyz.openbmc_project.State.Chassis0  /xyz/openbmc_project/state/chassis0  xyz.openbmc_project.State.Chassis CurrentPowerState s xyz.openbmc_project.State.Chassis.PowerState.Off");
	ret=fseek(mointor,0,SEEK_SET);
	ch=fwrite("000",1,3,mointor);//将value保存到上次当中
	ret = system("echo 860 > /sys/class/gpio/unexport"); //unexport gpio
    }
    
    fclose(mointor);
    return 0;
}
