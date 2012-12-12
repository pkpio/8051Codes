#include <at89c5131.h>
#define motorPos P0_0
#define motorNeg P0_1
#define test P1_7
int speed=0;
int timerDelay=0;
bit speedDirection=1;
bit rotateDir = 1;

void timerInterrupt()interrupt 1{
	if(timerDelay == 50){
		if(speedDirection){
			if(speed<6){ speed++;}
			else { speedDirection =0; speed++; test = ~test;}
		}
		else {
			if(speed>1) { speed--;}
			else {speedDirection =1; speed--; rotateDir = ~rotateDir;}
		}
		
		timerDelay = 0;
	} else{
		timerDelay++;
	}
}

void delay(int delayTime){
	int i,j;
	for(i=0;i<delayTime;i++){
		for(j=0;j<255;j++){}
	}
}

void rotateMotor(int speed){
	int onTime;
	int offTime;
	onTime = speed*10;
	offTime = 70-onTime;
	motorPos = rotateDir;
	motorNeg = ~rotateDir;
	delay(onTime);
	motorPos = 0;
	motorNeg = 0;
	delay(offTime);
}

void main(void) {
	//Setting the timer 0 for interrupts
	EA = 1;
	ET0 = 1;
	IT0 = 1;
	TMOD = 1;
	TCON = 1;
	TR0 = 1;
	while(1){
		rotateMotor(speed);
	}
}
