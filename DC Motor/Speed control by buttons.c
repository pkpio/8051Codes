#include <at89c5131.h>
#define motorPos P0_0
#define motorNeg P0_1
#define test P1_7
#define up P1_0
#define down P1_1
int speed=0;
int timerDelay=0;
bit speedDirection=1;
bit rotateDir = 1;
bit prevUp;
bit prevDown;

void timerInterrupt()interrupt 1{
	
	if(prevUp != up){
		if(rotateDir){
			if(speed != 7){speed++;}
		}else{
			if(speed != 0){speed--;}
			else{rotateDir = ~rotateDir;}
		}
		prevUp = up;
	}
	
	if(prevDown != down){
		if(rotateDir){
			if(speed != 0){speed--;}
			else{rotateDir = ~rotateDir;}
		}else{
			if(speed != 7){speed++;}
		}
		prevDown = down;
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
	prevUp = up;
	prevDown = down;
	while(1){
		rotateMotor(speed);
	}
}
