#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <string.h>

int bios_version(char *str_sn,char *str_ee)
{
    FILE *sn_fd;
    FILE *ee_fd;
    char *sn_buff[120]={0};
    int ret =0;
    sn_fd = fopen(str_sn,"rb+");
    if(sn_fd < 0)
    {
        printf("ERROR for open failed\n");
        return -1;
    }
    for(int i=0;i<120;i++)
    {
	fseek(sn_fd,i,SEEK_SET);
	ret = fread(sn_buff+i,1,1,sn_fd);
	if(ret < 0)
	{
	    printf("ERROR FRO WRITE\n");
	}
    }
    fclose(sn_fd);

    ee_fd = fopen(str_ee,"rb+");
    if(ee_fd < 0)
    {
        printf("ERROR for open failed\n");
        return -1;
    }
    for(int i=0;i<120;i++)
    {
	fseek(ee_fd,i,SEEK_SET);
	ret = fwrite(sn_buff+i,1,1,sn_fd);
	if(ret < 0)
	{
	    printf("ERROR FRO WRITE\n");
	}
    }
    fclose(ee_fd);

    return 0;
}

int main(int argc, char *argv[])
{
    bios_version(argv[1],argv[2]);
}
