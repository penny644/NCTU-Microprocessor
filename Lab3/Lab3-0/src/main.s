 	.syntax unified
 	.cpu cortex-m4
 	.thumb

.data
	 leds: .byte 0

.text
	 .global main
	 .equ RCC_AHB2ENR, 0x4002104C
	 .equ GPIOA_MODER, 0x48000000
	 .equ GPIOA_OTYPER, 0x48000004
	 .equ GPIOA_OSPEEDR, 0x48000008
	 .equ GPIOA_PUPDR, 0x4800000C
	 .equ GPIOA_ODR, 0x48000014
	//LED on PA5
main:
	 //enable AHB2 clock
	 ldr R0, =RCC_AHB2ENR
	 mov R1, #1
	 str R1, [R0]

 	//Set PA5 as output
	 mov R0, #0x400
	 ldr R1, =GPIOA_MODER
 	 ldr R2, [R1]
	 and R2, #0xfffff3ff
	 orr R2, R2, R0
	 str R2, [R1]

 //set PA5 high speed mode
	 mov R0, #0x800
	 ldr R1, =GPIOA_OSPEEDR
	 ldrh R0, [R1]

	 ldr R0, =GPIOA_ODR

L1:
	 mov R1, #0
	 str R1, [R0]
	 B L1
