// Purpose:   To capture the pulse form a US sensor 
// Date:      2017 01 06
// Author:    Andrew Elder 
#include <avr/io.h>

#define trig PB1
#define echo PB0 //input capture
//ICR1 is input capture reg 
//(ICR1L) and then the high byte (ICR1H)
#define BAUD9600 103 //sets correct baud rate 
#define hi 0
#define lo 0
.global setup
setup: 
//declare pins to output 
//setup the serial monitor 
//setup the ultsonic sensor 
sbi _SFR_IO_ADDR(DDRB), DDB1  //sets PB1 to output (not tested)

  ldi r25,BAUD9600 >> 8       //Serial monitor setup 
  ldi r24,BAUD9600            
  call initUART 

  //setup for normal mode and interupt
  ldi r16, 0                    ; prepare for Normal Mode //sets pin to toggle on 9
  sts TCCR1A, r16               ; set Normal Mode, now configure the prescaler...
  ldi r16, 0b00000011           ; T1:2^24/2^10/2^16 (prescale) > 0.25 ovf/s > 0.125Hz
  sts TCCR1B, r16               ; Timer1 clock = system clock / prescale
  ldi r16,hi                    ; load TCNT1 (Timer1's 2-byte counter)
  sts TCNT1H,r16                ; T1:2^16-(2^24/2^8/120)=64989=0xFDDD->120ovf/s=60Hz
  ldi r16,lo                    ; LED flashing at 24Hz does not seem to produce PoV
  sts TCNT1L,r16                ; even at 60Hz there appears to be some noticeable flicker
  //setup the toggle pin??
  ldi r16, 1<<ICIE1 | 1<<TOIE1  //enable the input capture and OVF interupt
  sts TIMSK1, r16

  
ret

.global loop
loop:
//main code will consist of trigger routine (below)
//then input capture stuff
//then send to serial monitor 
//then repeat 


//call readUlt

/*   
  digitalWrite(Trig_pin, LOW);
  delayMicroseconds(2);
  digitalWrite(Trig_pin, HIGH);
  delayMicroseconds(10); //setup for reciving a signal
    
  digitalWrite(Trig_pin, LOW); //uses pulse o echo pin to capture
    
  duration = pulseIn(Echo_pin,HIGH); //what is the pulse in funciton
*/
rjmp loop      

.global TIMER1_CAPT_vect
TIMER1_CAPT_vect:
//input capture interup 
  ldi r25, 'R
  call printChar
  call printLn

  lds r25, ICR1L
  call printByte
  ldi r25, ',
  call printChar
  lds r25, ICR1H
  call printByte
  call printLn
  
  
reti

.global TIMER1_OVF_vect
TIMER1_OVF_vect:        
  ldi r16,hi                    ; load TCNT1 (Timer1's 2-byte counter)
  sts TCNT1H,r16                ; T1:2^16-(2^24/2^8/120)=64989=0xFDDD->120ovf/s=60Hz
  ldi r16,lo                    ; LED flashing at 24Hz does not seem to produce PoV
  sts TCNT1L,r16                ; even at 60Hz there appears to be some noticeable flicker
  
  in r16,_SFR_IO_ADDR(PORTB)    ; read the port
  ldi r17,1<<trig               ; prepare the bit(s) to toggle
  eor r16,r17                   ; toggle the bit(s), leaving the others unaffected
  out _SFR_IO_ADDR(PORTB),r16   ; update the port

  ldi r25, 'I
  call printChar
  call printLn
reti


.global readUlt
readUlt:

ret


