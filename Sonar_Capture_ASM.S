// Purpose:   To capture the pulse form a US sensor 
// Date:      2017 01 06
// Author:    Andrew Elder 
#include <avr/io.h>


#define trig PB1
#define echo PB0 //input capture
//ICR1 is input capture reg 
//(ICR1L) and then the high byte (ICR1H)
#define BAUD9600 103 //sets correct baud rate 

.global setup
setup: 
//declare pins to output 
//setup the serial monitor 
//setup the ultsonic sensor 
sbi _SFR_IO_ADDR(DDRB), DDB1  //sets PB1 to output (not tested)

  ldi r25,BAUD9600 >> 8       //Serial monitor setup 
  ldi r24,BAUD9600            
  call initUART               

  call printLn
  ldi r25, 239
  call printByte
  
ret

.global loop
loop:
//main code will consist of trigger routine (below)
//then input capture stuff
//then send to serial monitor 
//then repeat 



/*   
  digitalWrite(Trig_pin, LOW);
  delayMicroseconds(2);
  digitalWrite(Trig_pin, HIGH);
  delayMicroseconds(10); //setup for reciving a signal
    
  digitalWrite(Trig_pin, LOW); //uses pulse o echo pin to capture
    
  duration = pulseIn(Echo_pin,HIGH); //what is the pulse in funciton
*/

rjmp loop             


.global initUART
initUART:
  sts UBRR0H, r25                 //The UBRR0H and L registers control the baud rate
  sts UBRR0L, r24                 //The UBRR0H and L registers control the baud rate
  ldi r16, 1<<TXEN0 | 1<<RXEN0    //These bits in the UCSR0B register enables transmitting functions if set (Pin 1 on the arduino uno)
                                  //and receiving functions if set (Pin 0 on the arduino uno)
                                  //Set both bits if you want to enable both (also disable UCSZ03)
  sts UCSR0B, r16                 //Set both even though we're only transmitting to serial monitor in this example
  ldi r16, 3 << UCSZ00            //Set the UCSZ00 and UCSZ01 bits so we get an 8 bit data size (enough for char)
  sts UCSR0C, r16                 //Data is 8 bit data size
 ret


.global printChar
printChar:
1:
  lds r16, UCSR0A
  sbrs r16, UDRE0
  rjmp 1b
  sts UDR0, r25
ret

.global printByte
printByte:
  //base around GPR 25 
  //subtrack powers of ten to get the indivdual digits 
  //subtrack by 100 for first digit 
  //subtrack by 10 for second 
  //add for 48(other value) to get assci value
  mov r20, r25 //we want another copy 
  clr r21
  clr r23
  clr r24
  
  hundreds: 
  inc r21 //if 1 in reg could mean >100
  subi r20, 100 //repeats subtracking until negitive 
  brcc hundreds //find the right compare 
  
  ldi r22, 100 //this gets the regiter out of negtive but with no 
  add r20, r22 //leading zeros 
  
  tens: 
  inc r23
  subi r20, 10 //does the same as 100
  brcc tens 
  
  ldi r22, 10 //adds 10 to get back 
  add r20, r22 //adding to a negitive number could be a problem
  
  ones:
  inc r24
  subi r20, 1
  brcc ones

  dec r21 //get rid of the extra inc 
  dec r23
  dec r24 
  
  ldi r22, 48 //adds to get the assci vals of these # 
  add r21, r22 //works for some reason 
  add r23, r22
  add r24, r22
  
  mov r25, r21 //uses print char to print number 

  call printChar //these statment no the problem
  skip:
  mov r25, r23

  call printChar
  skip1:
  mov r25, r24
  call printChar
ret

.global printLn
printLn:
  ldi r25, '\n
  call printChar
ret
