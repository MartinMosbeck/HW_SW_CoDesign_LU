#include <altera_avalon_sgdma.h>
#include <altera_avalon_sgdma_descriptor.h>
#include <altera_avalon_sgdma_regs.h>

#include "sys/alt_stdio.h"
#include "sys/alt_irq.h"
#include <unistd.h>
#include <malloc.h>
#include "io.h"
#include "altera_eth_tse_regs.h"
#include "system.h"
#include "display.h"
                 
#define SONG_LEN (32000*50) // song length (samples)
#define BUF_SIZE 64

// Allocate descriptors in the descriptor_memory (onchip memory) and rx frames (main memory)
alt_sgdma_descriptor rx_descriptor[3]  __attribute__ (( section ( ".descriptor_memory" )));
unsigned char rx_frame[2][BUF_SIZE]    __attribute__ (( section ( ".main_memory" )));

int main(void)
{	
	// Create sgdma receive device
	alt_sgdma_dev * sgdma_rx_dev;

	unsigned char act_frame = 0;
	//unsigned int* sample_ptr = NULL;

	short* song = NULL;
	unsigned char* song_ptr_b = NULL;
	volatile unsigned int song_cnt = 0;
	int sample = 0;
	
	unsigned int avail = 0;	
	unsigned int i = 0;

	// Open the sgdma receive device
	sgdma_rx_dev = alt_avalon_sgdma_open ("/dev/sgdma_rx");
	if (sgdma_rx_dev == NULL) {
		alt_printf ("Error: could not open scatter-gather dma receive device\n");
		return -1;
	} else alt_printf ("Opened scatter-gather dma receive device\n");

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
	IOWR_ALTERA_TSEMAC_CMD_CONFIG(TSE_BASE, IORD_ALTERA_TSEMAC_CMD_CONFIG(TSE_BASE) | 0x0000004B);
	
	// Initialize display
	display_init();
	
	// Clear display
	display_clear();
	
	// Print a message
	display_print("Messages...");

	// Allocate memory for the song (SDRAM)
	song = (short*)malloc(SONG_LEN*2);
	if (song == NULL)
	{
		alt_printf("Could not allocate memory for audio file!\n");
		return -1;
	}
	
	// Set a pointer (byte-access) to the song
	song_ptr_b = (unsigned char*)song;
	song_cnt = 0;	
	
	// Create sgdma receive descriptor
	alt_avalon_sgdma_construct_stream_to_mem_desc( &rx_descriptor[0], &rx_descriptor[1], (alt_u32 *)rx_frame[0], 0, 0 );
	
	alt_printf ("Ready to receive data!\n");
	
	// Set up non-blocking transfer of sgdma receive descriptor
	alt_avalon_sgdma_do_sync_transfer( sgdma_rx_dev, &rx_descriptor[0] );
	
	act_frame = 0;
	while(1) 
	{
		// Create sgdma receive descriptor
		alt_avalon_sgdma_construct_stream_to_mem_desc( &rx_descriptor[1-act_frame], &rx_descriptor[2-act_frame], (alt_u32 *)rx_frame[1-act_frame], 0, 0 );
		
		// Set up non-blocking transfer of sgdma receive descriptor
		alt_avalon_sgdma_do_async_transfer( sgdma_rx_dev, &rx_descriptor[1-act_frame] );

		// Check if the frame has the required type
		if ((rx_frame[act_frame][14] == 0x88)&&(rx_frame[act_frame][15] == 0xb5))
		{
			// Copy received frame to song 
			for (i = 16; i < BUF_SIZE; i ++)
			{
				song_ptr_b[song_cnt] = rx_frame[act_frame][i];
				song_cnt ++;
			}

			if (song_cnt >= 4*SONG_LEN)
			{
				break;
			}
		}
		
		act_frame = 1-act_frame;
		
		// Wait until receive descriptor transfer is complete
		while (alt_avalon_sgdma_check_descriptor_status(&rx_descriptor[act_frame]) != 0);
	}
	
	alt_printf ("Initializing audio...\n");
	
	// Reset the audio and video config core
	IOWR_32DIRECT(AUDIO_AND_VIDEO_CONFIG_0_BASE,0,0x01);
	// Wait until auto-initialization is done
	while ((IORD_32DIRECT(AUDIO_AND_VIDEO_CONFIG_0_BASE,4)&(1<<8)) == 0);
	
	alt_printf ("done!\n");
	
	// Reset audio FIFOs
	IOWR_32DIRECT(AUDIO_BASE,0,0x0C);
	IOWR_32DIRECT(AUDIO_BASE,0,0x00);
	
	while(1)
	{
		song_cnt = 0;
		while(1)
		{
			// If space for samples is available in FIFOs
			avail = (unsigned int)((IORD_32DIRECT(AUDIO_BASE,4)&0xFF000000)>>24);
			if (avail > 0)
			{
				// Read sample from SDRAM
				sample = (int)song[song_cnt++];
				// and write it to the FIFO for left channel
				IOWR_32DIRECT(AUDIO_BASE,8,sample);

				// Read sample from SDRAM
				sample = (int)song[song_cnt++];
				// and write it to the FIFO for left channel
				IOWR_32DIRECT(AUDIO_BASE,12,sample);
				
				// If song length is reached
				if (song_cnt >= 2*SONG_LEN)
				{
					break;
				}
			}
		}	
	}
	
	return 0;
}
