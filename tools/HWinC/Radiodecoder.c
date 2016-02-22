#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <math.h>//Für pow()

int lookup_sin[25]={
	0b00000000000000000000000000000000,
	0b00000000111111110111111010101101,
	0b00000000001000000001010111010110,
	0b11111111000001001000100011010011,
	0b11111111110000000101010111011101,
	0b00000000111100110111100001110000,
	0b00000000010111100011110101101001,
	0b11111111000110000101110101000010,
	0b11111111100001001010101111001011,
	0b00000000110110000010010111011111,
	0b00000000100101100111100100011000,
	0b11111111001110101011111110100101,
	0b11111111010100001100000110000110,
	0b00000000101011110011111001111010,
	0b00000000110001010100000001011011,
	0b11111111011010011000011011101000,
	0b11111111001001111101101000100001,
	0b00000000011110110101010000110101,
	0b00000000111001111010001010111110,
	0b11111111101000011100001010010111,
	0b11111111000011001000011110010000,
	0b00000000001111111010101000100011,
	0b00000000111110110111011100101101,
	0b11111111110111111110101000101010,
	0b11111111000000001000000101010011
};
int lookup_cos[25]={
	0b00000001000000000000000000000000,
	0b00000000000100000001001100001010,
	0b11111111000000100000010011000110,
	0b11111111110100000000011111001000,
	0b00000000111101111111010100010000,
	0b00000000010011110001101110111100,
	0b11111111000100011111101000101100,
	0b11111111100100110000000000100001,
	0b00000000111000000101010110100010,
	0b00000000100010010010101111110001,
	0b11111111001100001110010001000100,
	0b11111111010111001101000111001001,
	0b00000000101110101001110110110000,
	0b00000000101110101001110110110000,
	0b11111111010111001101000111001001,
	0b11111111001100001110010001000100,
	0b00000000100010010010101111110001,
	0b00000000111000000101010110100010,
	0b11111111100100110000000000100001,
	0b11111111000100011111101000101100,
	0b00000000010011110001101110111100,
	0b00000000111101111111010100010000,
	0b11111111110100000000011111001000,
	0b11111111000000100000010011000110,
	0b00000000000100000001001100001010
};

int lookup_sin16[25]={
        0b00000000000000000000000000000000,
        0b00000000000000001111111101111110,
        0b00000000000000000010000000010101,
        0b11111111111111110000010010001001,
        0b11111111111111111100000001010110,
        0b00000000000000001111001101111000,
        0b00000000000000000101111000111101,
        0b11111111111111110001100001011110,
        0b11111111111111111000010010101100,
        0b00000000000000001101100000100101,
        0b00000000000000001001011001111001,
        0b11111111111111110011101011000000,
        0b11111111111111110101000011000010,
        0b00000000000000001010111100111110,
        0b00000000000000001100010101000000,
        0b11111111111111110110100110000111,
        0b11111111111111110010011111011011,
        0b00000000000000000111101101010100,
        0b00000000000000001110011110100010,
        0b11111111111111111010000111000011,
        0b11111111111111110000110010001000,
        0b00000000000000000011111110101010,
        0b00000000000000001111101101110111,
        0b11111111111111111101111111101011,
        0b11111111111111110000000010000010

};
int lookup_cos16[25]={
        0b00000000000000010000000000000000,
        0b00000000000000000001000000010011,
        0b11111111111111110000001000000101,
        0b11111111111111111101000000001000,
        0b00000000000000001111011111110101,
        0b00000000000000000100111100011011,
        0b11111111111111110001000111111011,
        0b11111111111111111001001100000001,
        0b00000000000000001110000001010101,
        0b00000000000000001000100100101011,
        0b11111111111111110011000011100101,
        0b11111111111111110101110011010010,
        0b00000000000000001011101010011101,
        0b00000000000000001011101010011101,
        0b11111111111111110101110011010010,
        0b11111111111111110011000011100101,
        0b00000000000000001000100100101011,
        0b00000000000000001110000001010101,
        0b11111111111111111001001100000001,
        0b11111111111111110001000111111011,
        0b00000000000000000100111100011011,
        0b00000000000000001111011111110101,
        0b11111111111111111101000000001000,
        0b11111111111111110000001000000101,
        0b00000000000000000001000000010011
};
//dafür ist -lm beim compilieren nötig
//==gcc Radiodecoder.c -lm -g -o Radiodecoder
float zeigeFixpoint(uint32_t x){
	float zahl=0;
	int i;
	if(x&0x80000000){//Negative Zahl
		zahl=-32768;//-128;
	}
	for(i=0; i<31; i++){
		if(1<<i & x){
			zahl+=pow(2,i-16);//24);
		}
	}
	//printf("%3.12f\n",zahl);
	return zahl;
}
//Mathematisch korrekt?
/*uint32_t fixpoint_mult(uint32_t a, uint32_t b){
	uint64_t ergebnis=0, i;
	for(i=0; i<32; i++){
		if(1<<i & b){
			ergebnis+=((uint64_t)a<<i);
		}
	}
	return (ergebnis&0x00FFFFFFFF000000)>>24;
}*/
//Mit signconvert, was unsere FPGA-HW auch macht
int fixpoint_mult(int a, int b){
	long ergebnis=(long)a*(long)b;
	return ergebnis>>16;//>>24;
}

int main(int argc, char *argv[]){
	//!!!x86 ist Little Endian, ist aber egal
	//Einlesen der Enqueuerten Daten (I,Q,I,Q,...)
	FILE *eingabeDatei;
	eingabeDatei=fopen(argv[1],"r");
	if(NULL==eingabeDatei)printf("Datei kann nicht geöffnet werden!\n");
	fseek(eingabeDatei,0L,SEEK_END);
	size_t anzBytes=ftell(eingabeDatei)/2;
	fseek(eingabeDatei,0L,SEEK_SET);//rewind(eingabeDatei);
	uint8_t c[2]="";
	uint8_t * I=malloc(anzBytes/2);
	uint8_t * Q=malloc(anzBytes/2);
	int i=0;
	for(;i<anzBytes/2;){
		c[0]=fgetc(eingabeDatei);
		c[1]=fgetc(eingabeDatei);
		I[i]=strtol(c, NULL, 16);
		c[0]=fgetc(eingabeDatei);
		c[1]=fgetc(eingabeDatei);
		Q[i++]=strtol(c,NULL,16);
	}
	fclose(eingabeDatei);
	
	//Decoding bis zum Output
	uint32_t Itemp, Qtemp;//"Signale"
	uint32_t Iout, Qout;
	int t_cur=0;
	int deci_cnt=0;
	int valid=0;
	uint32_t I_con=0, Q_con=0;
	uint32_t demodulated;
	
	int validvalid=1;
	uint32_t data_fixp;
	uint8_t * outputvector=malloc(anzBytes/2/20/2);
	int outputpos=0;
	for(i=0; i<anzBytes/2; ++i){
		//printf("I[%i]=%i, Q[%i]=%i\n",i,I[i],i,Q[i]);
		//Mixer
		Itemp=(I[i]-127)<<16;//<<24;
		Qtemp=(Q[i]-127)<<16;//<<24;
		//printf("I[%i]-127=%i, Q[%i]-127=%i\n",i,I[i]-127,i,Q[i]-127);
		//printf("Itemp = %f, Qtemp = %f\n", zeigeFixpoint(Itemp), zeigeFixpoint(Qtemp));
		
		Iout=fixpoint_mult(Itemp,lookup_cos16[t_cur]) - fixpoint_mult(Qtemp,lookup_sin16[t_cur]);
		Qout=fixpoint_mult(Itemp,lookup_sin16[t_cur]) + fixpoint_mult(Qtemp,lookup_cos16[t_cur]);
		//printf("Iout = %f, Qout = %f\n", zeigeFixpoint(Iout), zeigeFixpoint(Qout));
		
		if (24==t_cur) t_cur=0;
		else t_cur++;
	
		//Decimator
		if(20-1==deci_cnt){
			//printf("#%i\n",i+1);
			//printf("Iout = %f, Qout = %f\n", zeigeFixpoint(Iout), zeigeFixpoint(Qout));
			//printf("I_con = %f, Q_con = %f\n", zeigeFixpoint(I_con), zeigeFixpoint(Q_con));
			valid=1;
			deci_cnt=0;
			//printf("Decimator sagt ja!\n");
		}else{
			valid=0;
			deci_cnt++;
		}
		
		//Demodulator - ab hier nur wenns decimiertes ist weiterverarbeiten
		if(valid){
			//HW-Original (es wird damit der Realteil=I genommen)
			//demodulated=fixpoint_mult(Iout,I_con) - fixpoint_mult(Qout,Q_con);
			//Eigentlich soll aber der Imaginärteil(=Q) des Programmes genommen werden
			demodulated=fixpoint_mult(Iout,Q_con) + fixpoint_mult(Qout,I_con);
			I_con=Iout;
			Q_con=fixpoint_mult(0xFFFF0000,Qout);//0xFF000000,Qout);
			//printf("demodulated = %f, I_con = %f, Q_con = %f\n",zeigeFixpoint(demodulated),zeigeFixpoint(I_con),zeigeFixpoint(Q_con));
		}
		
		//Outlogic
		if(valid){
			validvalid=1-validvalid;//jedes zweite nehmen (=Decimator)
			if(validvalid){
				//printf("Outputlogic sagt ja!\n");
				//data_fixp=fixpoint_mult(demodulated,0x001E0000);//0x1E000000);
				data_fixp=fixpoint_mult(demodulated,0x00000300);
				//printf("data_fixp = %f\n",zeigeFixpoint(data_fixp));
				outputvector[outputpos++]=(data_fixp + 0b01111111000000000000000000000000)>>24;//>>24;
				//printf("\n");
			}
		}
	}
	free(I);
	free(Q);
	
	for(i=0; i<=outputpos; i++){
		printf("%02x",outputvector[i]);
	}
	free(outputvector);
	return EXIT_SUCCESS;
}
