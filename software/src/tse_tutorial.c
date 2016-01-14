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
                 
#define BUF_SIZE 256

// Allocate descriptors in the descriptor_memory (onchip memory) and rx frames (main memory)
alt_sgdma_descriptor rx_descriptor[3]  __attribute__ (( section ( ".descriptor_memory" )));
unsigned char rx_audio[2][BUF_SIZE]    __attribute__ (( section ( ".main_memory" )));

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
	IOWR_ALTERA_TSEMAC_CMD_CONFIG(TSE_BASE, IORD_ALTERA_TSEMAC_CMD_CONFIG(TSE_BASE) | 0x00000002);


	display_print("Initializing audio...\n");
	
	// Reset the audio and video config core
	IOWR_32DIRECT(AUDIO_AND_VIDEO_CONFIG_0_BASE,0,0x01);
	// Wait until auto-initialization is done
	while ((IORD_32DIRECT(AUDIO_AND_VIDEO_CONFIG_0_BASE,4)&(1<<8)) == 0);
	
	display_print("done!\n");
	
	// Reset audio FIFOs
	IOWR_32DIRECT(AUDIO_BASE,0,0x0C);
	IOWR_32DIRECT(AUDIO_BASE,0,0x00);
	
	// Clear display
	display_clear();
	
	// Print a message
	display_print(
	"                      ::::::    .-~~\\        ::::::\n"
    "                      |::::|   /     \\ _     |::::|\n"
    "              _ _     l~~~~!   ~x   .-~_)_   l~~~~!\n"
    "           .-~   ~-.   \\  /      ~x\\\".-~   ~-. \\  /\n"
    "    _     /         \\   ||    _  ( /         \\ ||\n"
    "    ||   T  o  o     Y  ||    ||  T o  o      Y||\n"
    "  ==:l   l   <       !  (3  ==:l  l  <        !(3\n"
    "     \\\\   \\  .__/   /  /||     \\\\  \\  ._/    / ||\n"
    "      \\\\ ,r\\\"-,___.-'r.//||      \\\\,r\\\"-,___.-'r/||\n"
    "       }^ \\.( )   _.'//.||      }^\\. ( )  _.-//||\n"
    "      /    }~Xi--~  //  ||     /   }~Xi--~  // ||\\\\\n"
    "     Y    Y I\\ \\    \\\"   ||    Y   Y I\\ \\    \\\"  || Y\n"
    "     |    | |o\\ \\       ||    |   | |o\\ \\      || |\n"
    "     |    l_l  Y T      ||    |   l_l  Y T     || |\n"
    "     l      'o l_j      |!    l     \\\"o l_j     || !\n"
    "      \\                 ||     \\               ||/\n"
    "    .--^.     o       .^||.  .--^.     o       ||--. -   \n"
    "         \\\\           ~  `'        \\\"           ~`'"
			 );

	// Allocate memory for the song (SDRAM)
	song = (short*)malloc(BUF_SIZE);
	if (song == NULL)
	{
		display_print("Could not allocate memory for audio file!\n");
		return -1;
	}
	
	// Set a pointer (byte-access) to the song
	song_ptr_b = (unsigned char*)song;
	
	// Create sgdma receive descriptor
	alt_avalon_sgdma_construct_stream_to_mem_desc( &rx_descriptor[0], &rx_descriptor[1], (alt_u32 *)rx_audio[0], BUF_SIZE, 0 );
	
	//display_print ("Ready to receive data!\n");
	
	// Set up non-blocking transfer of sgdma receive descriptor
	alt_avalon_sgdma_do_async_transfer( sgdma_rx_dev, &rx_descriptor[0] );

	act_frame = 0;
	//#define DEBUGOUT
	//#define DEBUGSTATUS
	#ifdef DEBUGOUT
		char outtext[80];
		int zeigen=4;
	#endif
	#ifdef DEBUGDESCRIPTOR
		char text[80];
		int *show=NULL;
		int zeigend=4;
	#endif
	#ifdef DEBUGSTATUS
		int laststatus=status;
		char outputBuffer[1000];
	#endif

	while(1) 
	{
		// Create sgdma receive descriptor
		alt_avalon_sgdma_construct_stream_to_mem_desc( &rx_descriptor[1-act_frame], &rx_descriptor[2-act_frame], (alt_u32 *)rx_audio[1-act_frame], BUF_SIZE, 0 );
		//Ausgegangen wird von 64 Byte die eingelesen werden - der scatter gatter sollte dann ready nur anzeigen wenn nachfolgender Transfer gemacht wird!
		//Das muss unser Block beherzigen
		// Set up non-blocking transfer of sgdma receive descriptor
		alt_avalon_sgdma_do_async_transfer( sgdma_rx_dev, &rx_descriptor[1-act_frame] );

		// Copy received frame to song 
		for (i = 0; i < BUF_SIZE; i ++)
		{
			song_ptr_b[i] = rx_audio[act_frame][i];
		}

		#ifdef DEBUGOUT
			if(zeigen>0){
				for (i = 0; i < BUF_SIZE; i ++)
				{
					sprintf(outtext, "%u|",song_ptr_b[i]);
					//display_print(outtext);
					alt_printf(outtext);
				}
				alt_printf("\n");
				//zeigen--;
			}
		#endif
		#ifdef DEBUGDESCRIPTOR
			if(zeigend>0){
				show=&rx_descriptor[act_frame];
				sprintf(text,"\n%x",*show);
				display_print(text);
				sprintf(text,"\n%x",*(show+2));
				display_print(text);
				sprintf(text,"\n%x",*(show+4));
				display_print(text);
				sprintf(text,"\n%x",*(show+6));
				display_print(text);
				sprintf(text,"\n%x",*(show+7));
				display_print(text);
				sprintf(text,"\n%x",(alt_u32*)rx_audio[act_frame]);
				display_print(text);
				display_print("\n");
				//zeigend--;
			}
		#endif

		
		for (i = 0; i < BUF_SIZE/2; i ++)
		{
			//Play the received frame
			avail = (unsigned int)((IORD_32DIRECT(AUDIO_BASE,4)&0xFF000000)>>24);
			while(avail <= 0)avail = (unsigned int)((IORD_32DIRECT(AUDIO_BASE,4)&0xFF000000)>>24);
			// Read sample from SDRAM
			sample = (int)song[i];
			// and write it to the FIFO for left channel
			IOWR_32DIRECT(AUDIO_BASE,8,sample);

			// and write it to the FIFO for left channel (soll wl right bedeuten)
			IOWR_32DIRECT(AUDIO_BASE,12,sample);
		}
		
		act_frame = 1-act_frame;
		
		// Wait until receive descriptor transfer is complete
		while (status != 0)
		{
			status = alt_avalon_sgdma_check_descriptor_status(&rx_descriptor[act_frame]);
			#ifdef DEBUGSTATUS
				if(laststatus!=status){
					sprintf(outputBuffer, "avalon descriptor status: %d\n", status);//-119=EINPROGRESS
					//display_print(outputBuffer);
					alt_printf(outputBuffer);
					laststatus=status;
				}
			#endif
		}
		status=1;
	}
	return 0;
}
