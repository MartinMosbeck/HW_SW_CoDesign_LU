#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <math.h>//Für pow()

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

void printBin(uint64_t* x, int u64){
	int i,grenze=31;
	char ausgabe[65];
	if(u64){
		grenze=63;
	}
	for(i=grenze;i>=0;--i){
		if(x[i]){
			ausgabe[grenze-i]='1';
		}else{
			ausgabe[grenze-i]='0';
		}
	}
	ausgabe[grenze-i]='\0';
	printf("%s",ausgabe);
}

//Mit signconvert, was unsere FPGA-HW auch macht
int fixpoint_mult(int a, int b){
	long ergebnis=(long)a*(long)b;
	return ergebnis>>16;
}

int main(int argc, char *argv[]){
	uint32_t dividend=0,divisor=0;
	uint64_t quotient=0;
	uint32_t sol=0;
	uint32_t akku=0;
	
	uint32_t sign1,sign2;
	uint32_t sign;
	
	if(argc==3){
	dividend=strtol(argv[1],NULL,16);//fixpoint-a
	divisor=strtol(argv[2],NULL,16);//fixpoint-b
	}
	printf("%f/%f=",zeigeFixpoint(dividend),zeigeFixpoint(divisor));
	
	//Unsign + neues Sign feststellen
	if(dividend&0x80000000){
		sign1=1;
		dividend = dividend-1;
		dividend = ~dividend; //bitwise negation
	}else{
		sign1=0;
	}
	if(divisor&0x80000000){
		sign2=1;
		divisor = divisor-1;
		divisor = ~divisor;
	}else{
		sign2=0;
	}
	sign=sign1 ^ sign2; //XOR
	
	printf("dividend:");
	printBin(&dividend,0);
	printf("\ndivisor:");
	printBin(&divisor,0);
	printf("\n");
	
	//Eigentliche DIV
	int i;
	for(i=63; i>=0; i--){
		printf("Schritt %i:\n",64-i);
		if(i>31 && (dividend&1<<(i-32))){
			akku= (akku<<1) | 1;//am Ende die nächste Zahl durch
		}else{
			akku=(akku<<1);
		}
		printf("AKKU:");
		printBin(&akku,0);
		quotient = quotient << 1;
		printf("\nQUOTIENT:");
		printBin(&quotient,1);
		if(divisor<akku){
			printf("\ndiv<akku\n");
			quotient = quotient | 1;
			akku = akku - divisor;
			printf("QUOTIENT:");
			printBin(&quotient,1);
		}
		printf("\n");
	}
	
	sol=(quotient>>16);
	
	//Resign
	if(sign){
		sol = ~sol;
		sol++;
	}
	printf("%f\n",zeigeFixpoint(sol));
	return EXIT_SUCCESS;
}