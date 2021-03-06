#include <errno.h>
#include <string.h>
#include <arpa/inet.h>
#include <net/ethernet.h>
#include <net/if.h>
#include <netpacket/packet.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>

#define DEFAULT_IF "eth0"
#define BUF_SIZE 64

int main(int argc, char *argv[])
{
	FILE *fp;
	unsigned int cnt = 0;
	unsigned int i, j = 0;

	int sockfd;
	struct ifreq if_idx;
	struct ifreq if_mac;
	//char sendbuf[BUF_SIZE];
	struct sockaddr_ll socket_address;
	char ifName[IFNAMSIZ];
	unsigned int mac[6] = {0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF}; //using as uint8_t

	/* Get interface name */
	if (argc > 1)
	{
		strcpy(ifName, argv[1]);
		if (argc > 2)
		{
			 /* 2 arguments, second argument is mac */
			sscanf(argv[2], "%02x:%02x:%02x:%02x:%02x:%02x", &mac[0], &mac[1], &mac[2], &mac[3], &mac[4], &mac[5]);
		}
	}
	else
	{
		strcpy(ifName, DEFAULT_IF);
	}

	/* Print info */
	printf("Broadcasting from FILE to MAC address ");
	printf("%2x:%2x:%2x:%2x:%2x:%2x\n", mac[0], mac[1], mac[2], mac[3], mac[4], mac[5]);

	/* Open RAW socket to send on */
	if ((sockfd = socket(AF_PACKET, SOCK_DGRAM, htons(0x88b5))) == -1)
	{
		perror("Error opening socket");
		return -1;
	}

	/* Get the index of the interface to send on */
	memset(&if_idx, 0, sizeof(struct ifreq));
	strncpy(if_idx.ifr_name, ifName, IFNAMSIZ-1);
	if (ioctl(sockfd, SIOCGIFINDEX, &if_idx) < 0)
	{
		perror("Error getting interface index");
		return -1;
	}
	/* Get the MAC address of the interface to send on */
	memset(&if_mac, 0, sizeof(struct ifreq));
	strncpy(if_mac.ifr_name, ifName, IFNAMSIZ-1);
	if (ioctl(sockfd, SIOCGIFHWADDR, &if_mac) < 0)
	{
		perror("Error getting interface MAC address");
		return -1;
	}

	socket_address.sll_family=AF_PACKET;
	/* Index of the network device */
	socket_address.sll_ifindex = if_idx.ifr_ifindex;
	/* Address length*/
	socket_address.sll_halen = ETHER_ADDR_LEN;

	socket_address.sll_protocol = htons(0x88b5);
	/* Destination MAC */
	socket_address.sll_addr[0] = mac[0];
	socket_address.sll_addr[1] = mac[1];
	socket_address.sll_addr[2] = mac[2];
	socket_address.sll_addr[3] = mac[3];
	socket_address.sll_addr[4] = mac[4];
	socket_address.sll_addr[5] = mac[5];

	fp = fopen("ethst_input.txt","r");
	if (!fp)
	{
			perror("Could not open audio file!");
	}

	//fseek(fp,44,SEEK_SET);

	fseek(fp,0L,SEEK_END);
	size_t anzBytes=ftell(fp)/2;
	fseek(fp,0L,SEEK_SET);

	uint8_t c[3]="";
	uint8_t * sendbuf=malloc(anzBytes);

	i = 0;
	for(;i<anzBytes;){
		c[0]=fgetc(fp);
		c[1]=fgetc(fp);
		c[2]='\0';
		sendbuf[i++]=strtol(c, NULL, 16);

	}
	fclose(fp);

	cnt = 0;
	while (1)
	{
		/* Send packet */
		if (sendto(sockfd, &sendbuf[cnt], BUF_SIZE-16, 0, (struct sockaddr*)&socket_address, sizeof(struct sockaddr_ll)) < 0)
		{
			perror("Error sending packet");
			return -1;
		}
		else
		{
			cnt += BUF_SIZE-16;
			if(cnt>anzBytes)break;

			printf("Sent %d packets!\r",cnt);

			if (cnt == 2)
			{
				//break;
			}

			usleep(1000);
		}
	}

  free(sendbuf);
  //fclose(fp);

  return 0;
}
