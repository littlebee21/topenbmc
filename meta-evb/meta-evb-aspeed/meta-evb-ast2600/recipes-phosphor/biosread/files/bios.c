#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <string.h>

#define BASE_addr 0x1E780000
#define BASE_addr1 0x1E6E2000
#define SIZE 0xff

void setdir(void)
{
        int fd;
        fd = open("/dev/mem", O_RDWR|O_NDELAY);
        unsigned int* map_base=(unsigned int*)mmap(NULL,SIZE,PROT_READ|PROT_WRITE,MAP_SHARED,fd,BASE_addr);
        //l2
        *(volatile unsigned int*)(map_base+0x74/4)|=(1<<26);
        //x1
        *(volatile unsigned int*)(map_base+0x8c/4)|=(1<<25);
        *(volatile unsigned int*)(map_base+0x8c/4)|=(1<<24);
}
void setspics(void)
{
        int fd;  //gpiox0 spi2cs0 scu434
        fd = open("/dev/mem", O_RDWR|O_NDELAY);
        unsigned int* map_base=(unsigned int*)mmap(NULL,SIZE,PROT_READ|PROT_WRITE,MAP_SHARED,fd,BASE_addr1);
	*(volatile unsigned int*)(map_base+0x434/4)&=~(1<<25);
	*(volatile unsigned int*)(map_base+0x418/4)&=~(1<<26);
}

void setgpio(int l2,int x1)
{
        int fd;
        fd = open("/dev/mem", O_RDWR|O_NDELAY);
unsigned int* map_base=(unsigned int*)mmap(NULL,SIZE,PROT_READ|PROT_WRITE,MAP_SHARED,fd,BASE_addr);
        //l2
        if(l2 == 0)
                *(volatile unsigned int*)(map_base+0x70/4)&=~(1<<26);
        else
                *(volatile unsigned int*)(map_base+0x70/4)|=(1<<26);

        //k4
        if(x1 == 0)
	{
		*(volatile unsigned int*)(map_base+0x88/4)&=~(1<<25);
		*(volatile unsigned int*)(map_base+0x88/4)&=~(1<<24);
	}
        else
	{
                *(volatile unsigned int*)(map_base+0x88/4)|=(1<<25);
                *(volatile unsigned int*)(map_base+0x88/4)|=(1<<24);
	}
}

int readl()
{
        int fd;
        fd = open("/dev/mem", O_RDWR|O_NDELAY);
	unsigned int* map_base=(unsigned int*)mmap(NULL,SIZE,PROT_READ|PROT_WRITE,MAP_SHARED,fd,BASE_addr);
	return 0;
}

int bios_version(int byte,int size,char *str,char*sle)
{
    FILE *spi_fd;
    FILE *fd;
    int i =0;
    char buffer[50];
    char buff[1]={0};
    char buffee[50]={0};
    memset(buffer,'\0',sizeof(buffer));
    spi_fd = fopen(str,"rb");
    if(spi_fd < 0)
    {
	printf("ERROR for open failed\n");
	fclose(spi_fd);
	return -1;
    }
    for(i=0;i<50;i++)
    {
	fseek(spi_fd,byte+i,SEEK_SET);
	fread(buff,1,1,spi_fd);
	if(!strcmp(buff,""))
	{
	    size=i;
	    break;
	}
	buffer[i]=*buff;
    }
    buffer[size]='\n';
    fclose(spi_fd);

    fd = fopen("/usr/bin/bios_version.txt","rw+");
    if(fd < 0)
    {
	printf("ERROR for open failed\n");
	fclose(fd);
	return -1;
    }
    
    if(!strcmp(sle,"srom")) fprintf(fd,"%s",buffer);
    else if(fgets(buffee,50,fd)== NULL) fprintf(fd,"\n");

    if(!strcmp(sle,"hmcode")) fprintf(fd,"%s",buffer);
    else if(fgets(buffee,50,fd)== NULL) fprintf(fd,"\n");

    if(!strcmp(sle,"bios")) fprintf(fd,"%s",buffer);
    else if(fgets(buffee,50,fd)== NULL) fprintf(fd,"\n");

    fclose(fd);
    return 0;
}

int main(int argc, char *argv[])
{
    int ret = 0;
    if(strcmp(argv[1],"0")==0)
    {
	setgpio(0,1);
    }else if(strcmp(argv[1],"1")==0)
    {
	setgpio(1,0);
    }else if(strcmp(argv[1],"2")==0)
    {
	setgpio(1,1);
    }else if(strcmp(argv[1],"3")==0)
    {
	setgpio(0,0);
    }else if(strcmp(argv[1],"4")==0)
    {
	readl();
	setspics();
    }else if(strcmp(argv[1],"5")==0)
    {
	ret = system("/usr/bin/bios_update.sh");

	if(ret <0)
	{
	    printf("Bios Update  failed\n");
	}
    }else if(strcmp(argv[1],"6")==0)
    {
	int byte = 0;
	int size = 0;
	int ret = 0;
	printf("GET BIOS Version\n");
	ret=system("/usr/bin/bios_version.sh 1");
	if(!strcmp(argv[2],"all"))
	{
	    bios_version(37120,size,argv[3],"srom");
	    bios_version(40960,size,argv[3],"hmcode");
	    bios_version(1310491,size,argv[3],"bios");
	    ret=system("/usr/bin/bios_version.sh 0");
	    if(ret < 0)
	    {
		printf("BIOS-VERSION GET failed\n");
	    }
	    return 0;
	}
	byte = atoi(argv[4]);
	bios_version(byte,size,argv[3],argv[2]);
	ret=system("/usr/bin/bios_version.sh 0");
	if(ret < 0)
	{
	    printf("BIOS-VERSION GET failed\n");
	}
    }
        return 0;
}
