#include <altera_avalon_sgdma.h>
#include <altera_avalon_sgdma_descriptor.h>
#include <altera_avalon_sgdma_regs.h>

#include "sys/alt_stdio.h"
#include "sys/alt_irq.h"
#include <unistd.h>
#include <malloc.h>
#include <string.h>
#include "io.h"
#include "altera_eth_tse_regs.h"
#include "system.h"
#include "display.h"
#include "graphics.h"

#define BUF_SIZE 32768
#define BUF_SIZE_DBGOUT 65532//64//65532 is das max was ein SGDMA kann

#define DBGOUT_SIZE 1024//1 wenn kein DBG -max derzeit 1024

#define DBGOUT

// Allocate descriptors in the descriptor_memory (onchip memory) and rx frames (main memory)
//alt_sgdma_descriptor rx_descriptor[3]  __attribute__ (( section ( ".descriptor_memory" )));
#ifdef DBGOUT
alt_sgdma_descriptor rx_descriptor[DBGOUT_SIZE+1]  __attribute__ (( section ( ".descriptor_memory" )));//NUR FÜR DBGOUT!!! descripter memory standard 4096 bytes
#endif
#ifndef DBGOUT
alt_sgdma_descriptor rx_descriptor[3]  __attribute__ (( section ( ".descriptor_memory" )));
unsigned char rx_audio[2][BUF_SIZE]    __attribute__ (( section ( ".main_memory" )));
#endif

int main(void)
{
	// Create sgdma receive device
	alt_sgdma_dev * sgdma_rx_dev;

	unsigned char act_frame = 0;

	short* song = NULL;
	unsigned char* song_ptr_b = NULL;
	int sample = 0;

	unsigned int avail = 0;
	unsigned int i = 0;
	int status = 1;

	// Open the sgdma receive device
	sgdma_rx_dev = alt_avalon_sgdma_open ("/dev/sgdma_rx");
	if (sgdma_rx_dev == NULL) {
		//alt_printf ("Error: could not open scatter-gather dma receive device\n");
		return -1;
	} else ;//alt_printf ("Opened scatter-gather dma receive device\n");
	// Initialize the MAC address
	IOWR_ALTERA_TSEMAC_MAC_0(TSE_BASE, 0x116E6001);
	IOWR_ALTERA_TSEMAC_MAC_1(TSE_BASE, 0x00000F02);
	// Specify the addresses of the PHY devices to be accessed through MDIO interface
	IOWR_ALTERA_TSEMAC_MDIO_ADDR0(TSE_BASE, 0x10);
	//IOWR_ALTERA_TSEMAC_MDIO_ADDR1(TSE_BASE, 0x11);
	// Software reset the first PHY chip and wait
	IOWR_32DIRECT(TSE_BASE, 0x80*4, IORD_32DIRECT(TSE_BASE, 0x80*4) | 0x8000 );
	while ( IORD_32DIRECT(TSE_BASE, 0x80*4) & 0x8000);
	// Enable read and write transfers, gigabit Ethernet operation, and CRC forwarding
	IOWR_ALTERA_TSEMAC_CMD_CONFIG(TSE_BASE, IORD_ALTERA_TSEMAC_CMD_CONFIG(TSE_BASE) | 0x00000002); //B for PC //2 für real
	display_print("Initializing audio...\n");
	// Reset the audio and video config core
	IOWR_32DIRECT(AUDIO_AND_VIDEO_CONFIG_0_BASE,0,0x01);
	// Wait until auto-initialization is done
	while ((IORD_32DIRECT(AUDIO_AND_VIDEO_CONFIG_0_BASE,4)&(1<<8)) == 0);
	display_print("done!\n");
	// Clear display
	display_clear();
	// Print a message
	display_print(bunny);//bunny || snowman || sonic

	// Allocate memory for the song (SDRAM)
	#ifdef DBGOUT
	song= (short*)malloc(BUF_SIZE_DBGOUT*DBGOUT_SIZE);
	#else
	song = (short*)malloc(BUF_SIZE*DBGOUT_SIZE);
	#endif
	
	if (song == NULL)
	{
		display_print("Could not allocate memory for audio file!\n");
		return -1;
	}
	int versatz=0;

	// Set a pointer (byte-access) to the song
	song_ptr_b = (unsigned char*)song;
	//Speicherbereich löschen um ihn sicher leer zu haben
	#ifdef DBGOUT
	for(i=0; i<BUF_SIZE_DBGOUT*DBGOUT_SIZE; i++){
	#else
	for(i=0; i<BUF_SIZE*DBGOUT_SIZE; i++){
	#endif
		song_ptr_b[i]=0;
	}

	#ifndef DBGOUT
	// Create sgdma receive descriptor
	alt_avalon_sgdma_construct_stream_to_mem_desc( &rx_descriptor[0], &rx_descriptor[1], &song_ptr_b[0], BUF_SIZE, 0 );//(alt_u32 *)rx_audio[0

	display_print ("Ready to receive data!\n");

	// Set up non-blocking transfer of sgdma receive descriptor
	alt_avalon_sgdma_do_async_transfer( sgdma_rx_dev, &rx_descriptor[0] );
	//Auch am Anfang auf Daten warten
	//while (alt_avalon_sgdma_check_descriptor_status(&rx_descriptor[act_frame])!=0);

	act_frame = 0;
	status = 0;

	while(1)
	{
		//Unter entwicklung, sgdma abwechselnd abarbeiten, während der andere grade befüllt wird
		if(status == 0){
			// Create sgdma receive descriptor
			alt_avalon_sgdma_construct_stream_to_mem_desc( &rx_descriptor[1-act_frame], &rx_descriptor[act_frame], &song_ptr_b[(1-act_frame)*BUF_SIZE] , BUF_SIZE, 0 );//(alt_u32 *)rx_audio[1-act_frame]

			// Set up non-blocking transfer of sgdma receive descriptor
			//alt_avalon_sgdma_do_async_transfer( sgdma_rx_dev, &rx_descriptor[1-act_frame] );
			
			act_frame = 1-act_frame;
			
			alt_printf("OK\n");
		}
		status = alt_avalon_sgdma_check_descriptor_status(&rx_descriptor[act_frame]);

		for (i = 0; i < BUF_SIZE; i ++){
			/*if(i%4==0){
				alt_printf(" ");
			}*/
			sprintf(outtext, "%02x",song_ptr_b[i]);
			//display_print(outtext);
			alt_printf(outtext);
		}

	}
	#endif

	#ifdef DBGOUT
	char outtext[80];
	int zeigen=4;
	sprintf(outtext, "%02x\n\n",NULL);
	alt_printf(outtext);
	
	int runs;
	for(runs=0; runs<DBGOUT_SIZE; runs++){
		alt_avalon_sgdma_construct_stream_to_mem_desc( &rx_descriptor[runs], &rx_descriptor[runs+1],&song_ptr_b[runs*BUF_SIZE_DBGOUT] , BUF_SIZE_DBGOUT, 0 );
	}
	alt_avalon_sgdma_do_async_transfer(sgdma_rx_dev, &rx_descriptor[0]);
	display_print("Init abgeschlossen\n");
	while (alt_avalon_sgdma_check_descriptor_status(&rx_descriptor[0])!=0);
	display_print("Daten ok\n");
	
	for (i = 0; i < BUF_SIZE_DBGOUT*DBGOUT_SIZE; i ++){
		/*if(i%4==0){
			alt_printf(" ");
		}*/
		sprintf(outtext, "%02x",song_ptr_b[i]);
		//display_print(outtext);
		alt_printf(outtext);
	}
	alt_printf("\n\nENDE");
	sprintf(outtext, "%c",4);
	alt_printf(outtext);
	#endif
	return 0;
}
