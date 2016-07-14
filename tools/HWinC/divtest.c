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
	
	//Eigentliche DIV
	int i;
	for(i=63; i>=0; i--){
		if(i>31 && (dividend&1<<(i-32))){
			akku= (akku<<1) | 1;//am Ende die nächste Zahl durch
		}else{
			akku=(akku<<1);
		}
		quotient = quotient << 1;
		if(divisor<akku){
			quotient = quotient | 1;
			akku = akku - divisor;
		}
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