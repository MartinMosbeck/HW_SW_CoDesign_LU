#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <math.h>//Für pow()

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
#define ANZ_NACHKOMMA 16//Gesamt 32 bit,d.h. der Rest ist Vorkomma
float zeigeFixpoint(uint32_t x){
	float zahl=0;
	int i;
	if(x&0x80000000){//Negative Zahl
		zahl-=pow(2,31-ANZ_NACHKOMMA);
	}
	for(i=0; i<31; i++){
		if(1<<i & x){
			zahl+=pow(2,i-ANZ_NACHKOMMA);
		}
	}
	//printf("%3.12f\n",zahl);
	return zahl;
}

void testbenchPrint(int index, uint8_t I, uint8_t Q){
	char bitvektor[9];
	bitvektor[8]=0;
	int i;
	for(i=0; i<8; ++i){
		bitvektor[7-i]= (I & 1) + '0';
		I>>=1;
	}
	printf("\t\t--%d\n",index);
	printf("\t\tIin <= \"%s\";\n",bitvektor);
	for(i=0; i<8; ++i){
		bitvektor[7-i]= (Q & 1) + '0';
		Q>>=1;
	}
	printf("\t\tQin <= \"%s\";\n",bitvektor);
	printf("\t\tcounter <= counter + 10000;\n");
	printf("\t\tclk <= '1'; wait for 5 ns;\n");
	printf("\t\tclk <= '0'; wait for 5 ns;\n");
}

//Mit signconvert, was unsere FPGA-HW auch macht
int fixpoint_mult(int a, int b){
	long ergebnis=(long)a*(long)b;
	return ergebnis>>16;
}

int main(int argc, char *argv[]){
	//!!!x86 ist Little Endian, ist aber egal
	//Einlesen der Enqueuerten Daten (I,Q,I,Q,...)
	FILE *eingabeDatei;
	eingabeDatei=fopen(argv[1],"r");
	if(NULL==eingabeDatei)printf("Datei kann nicht geöffnet werden!\n");
	fseek(eingabeDatei,0L,SEEK_END);
	size_t anzBytes=ftell(eingabeDatei)/2;
	fseek(eingabeDatei,0L,SEEK_SET);
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
		Itemp=(I[i]-127)<<16;
		Qtemp=(Q[i]-127)<<16;
		//printf("I[%i]-127=%i, Q[%i]-127=%i\n",i,I[i]-127,i,Q[i]-127);
		//testbenchPrint(i,I[i],Q[i]);
		//printf("Itemp = %u, Qtemp = %u\n", Itemp, Qtemp);
		//printf("Itemp = %f, Qtemp = %f\n", zeigeFixpoint(Itemp), zeigeFixpoint(Qtemp));
		
		Iout=fixpoint_mult(Itemp,lookup_cos16[t_cur]) - fixpoint_mult(Qtemp,lookup_sin16[t_cur]);
		Qout=fixpoint_mult(Itemp,lookup_sin16[t_cur]) + fixpoint_mult(Qtemp,lookup_cos16[t_cur]);
		//printf("Itemp1 = %u, Itemp2 = %u, Qtemp1 = %u, Qtemp2 = %u\n",fixpoint_mult(Itemp,lookup_cos16[t_cur]),fixpoint_mult(Qtemp,lookup_sin16[t_cur]),fixpoint_mult(Itemp,lookup_sin16[t_cur]),fixpoint_mult(Qtemp,lookup_cos16[t_cur]));
		//printf("Iout = %u, Qout = %u\n", Iout, Qout);
		//printf("%i\t\t%u\t\t%u\n",60000+i*10000,Iout,Qout);
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
			demodulated=fixpoint_mult(Iout,Q_con) + fixpoint_mult(Qout,I_con);
			I_con=Iout;
			Q_con=fixpoint_mult(0xFFFF0000,Qout);
			//printf("demodulated = %f, I_con = %f, Q_con = %f\n",zeigeFixpoint(demodulated),zeigeFixpoint(I_con),zeigeFixpoint(Q_con));
		}
		
		//Outlogic
		if(valid){
			validvalid=1-validvalid;//jedes zweite nehmen (=Decimator)
			if(validvalid){
				//printf("Outputlogic sagt ja!\n");
				data_fixp=fixpoint_mult(demodulated,0x00000300);
				//printf("data_fixp = %f\n",zeigeFixpoint(data_fixp));
				outputvector[outputpos++]=(data_fixp + 0b00000000011111110000000000000000)>>16;
				//printf("\n");
			}
		}
		//printf("\n");
	}
	free(I);
	free(Q);
	
	for(i=0; i<=outputpos; i++){
		printf("%02x",outputvector[i]);
	}
	free(outputvector);
	return EXIT_SUCCESS;
}
