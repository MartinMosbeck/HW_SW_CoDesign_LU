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
//Wieviel Bytes bei Echtzeitverarbeitung am Stück geholt werden
#define BUF_SIZE 30//256//32768

//DBGOUT gibt die DATEN aus, die direkt von der HW kommen und beendet dann das Programm
//#define DBGOUT
//DBGOUT_SIZE*BUF_SIZE_DBGOUT Bytes werden ausgegeben
#define BUF_SIZE_DBGOUT 65532//Von 0-65532 erlaubt
#define DBGOUT_SIZE 1024//Von 1-1024 erlaubt
//DEBUGOUT gibt Debugdaten bei Echzeitverarbeitung aus (in der while(1) Programm Hauptschleife)
//Für Debugausgabe diese Direktive nehmen und nur diese und nur in der while(1)
//DEBUGOUT wird von DBGOUT overrult, das Hauptprogramm natürlich auch
//#define DEBUGOUT

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
	//SG-DMA-Variablen
	unsigned char act_frame = 0;
	int status = 1;
	unsigned char* sgdma_daten = NULL;
	//Laufvariable für die Streamausgabe
	unsigned int i = 0;

	char outtext[80];//Vornehmlich für Debugaufgaben
		
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

	// Allocate memory where sgdma writes the stream into
	#ifdef DBGOUT
	sgdma_daten= (short*)malloc(BUF_SIZE_DBGOUT*DBGOUT_SIZE);
	#else
	sgdma_daten = (short*)malloc(BUF_SIZE*DBGOUT_SIZE);
	#endif
	if (sgdma_daten == NULL){
		display_print("Could not allocate memory for audio file!\n");
		return -1;
	}
	int versatz=0;

	//Speicherbereich löschen um ihn sicher leer zu haben
	#ifdef DBGOUT
	for(i=0; i<BUF_SIZE_DBGOUT*DBGOUT_SIZE; i++){
	#else
	for(i=0; i<BUF_SIZE*DBGOUT_SIZE; i++){
	#endif
		sgdma_daten[i]=0;
	}

	#ifndef DBGOUT
	// Create sgdma receive descriptor
	alt_avalon_sgdma_construct_stream_to_mem_desc( &rx_descriptor[1], &rx_descriptor[2], &sgdma_daten[BUF_SIZE], BUF_SIZE, 0);
	alt_avalon_sgdma_construct_stream_to_mem_desc( &rx_descriptor[0], &rx_descriptor[2], &sgdma_daten[0], BUF_SIZE, 0 );

	display_print ("Ready to receive data!\n");

	// Set up non-blocking transfer of sgdma receive descriptor
	alt_avalon_sgdma_do_async_transfer( sgdma_rx_dev, &rx_descriptor[0] );
	//Auch am Anfang auf Daten warten
	while (alt_avalon_sgdma_check_descriptor_status(&rx_descriptor[0])!=0);

	act_frame = 1;
	i=0;
	unsigned char neueDaten[2] = {0,0};
	int frm=0;
	//------------------------HAUPTPROGRAMM-SCHLEIFE--------------------------------------------
	while(42)
	{
		//sgdma starten wenn der andere fertig ist und den anderen schon vorbereiten dass er gleich wieder gestartet werden kann
		if(status == 0){
			alt_avalon_sgdma_do_async_transfer(sgdma_rx_dev, &rx_descriptor[act_frame]);
			
			act_frame = 1-act_frame;
			
			neueDaten[1-act_frame] = 1;
			
			alt_avalon_sgdma_construct_stream_to_mem_desc( &rx_descriptor[act_frame], &rx_descriptor[2], &sgdma_daten[act_frame*BUF_SIZE] , BUF_SIZE, 0 );

			if(frm == 1-act_frame){
				alt_printf("[WARNUNG] Timingproblem: Daten konnten nicht in sgdma-Intervall abgearbeitet werden!\n");
			}
		}
		status = alt_avalon_sgdma_check_descriptor_status(&rx_descriptor[1-act_frame]);

		#ifdef DEBUGOUT
		if(i<BUF_SIZE){
			sprintf(outtext, "%02x",sgdma_daten[i+frm*BUF_SIZE]);
			alt_printf(outtext);
			i++;
			if(i==BUF_SIZE){
				frm=1-frm;
				alt_printf("\n");
			}
		}
		if(i==BUF_SIZE && neueDaten[frm]){
			i=0;
			neueDaten[frm]=0;
		}
		#endif

#ifndef DEBUGOUT
		//Hier kommt der RDS-Stream rein und kann was von der HW noch fehlt fertig verarbeitet werden
		for(; i<BUF_SIZE;){
			//Hier mit sgdma_daten[i+frm*BUF_SIZE] Byteweise abarbeiten vor dem i++
			
			
			
			
			i++;
			if(i==BUF_SIZE){
				frm=1-frm;
			}
		}
		if(i==BUF_SIZE && neueDaten[frm]){
			i=0;
			neueDaten[frm]=0;
		}
#endif
	}
	//------------------------HAUPTPROGRAMM-SCHLEIFE-ENDE---------------------------------------
	#endif

	#ifdef DBGOUT
	int zeigen=4;
	sprintf(outtext, "%02x\n\n",NULL);
	alt_printf(outtext);
	
	int runs;
	for(runs=0; runs<DBGOUT_SIZE; runs++){
		alt_avalon_sgdma_construct_stream_to_mem_desc( &rx_descriptor[runs], &rx_descriptor[runs+1],&sgdma_daten[runs*BUF_SIZE_DBGOUT] , BUF_SIZE_DBGOUT, 0 );
	}
	alt_avalon_sgdma_do_async_transfer(sgdma_rx_dev, &rx_descriptor[0]);
	display_print("Init abgeschlossen\n");
	while (alt_avalon_sgdma_check_descriptor_status(&rx_descriptor[0])!=0);
	display_print("Daten ok\n");
	
	for (i = 0; i < BUF_SIZE_DBGOUT*DBGOUT_SIZE; i ++){
		/*if(i%4==0){
			alt_printf(" ");
		}*/
		sprintf(outtext, "%02x",sgdma_daten[i]);
		//display_print(outtext);
		alt_printf(outtext);
	}
	alt_printf("\n\nENDE");
	sprintf(outtext, "%c",4);
	alt_printf(outtext);
	#endif
	return 0;
}
