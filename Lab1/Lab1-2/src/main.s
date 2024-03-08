	.syntax unified
	.cpu cortex-m4
	.thumb
.text
	.global main
	.equ N, 2
	.equ f0, 0
	.equ f1, 1
fib:
//TODO
	//if(R0==0) cout<<f0
	cmp R0, #0
	beq finish_0
	//if(R0==1) cout<<f1
	cmp R0, #1
	beq finish_1
	//if(R0>100|R0<0) cout<<-1
	cmp R0, #100
	bgt finish_NOV
	cmp R0, #0
	blt finish_NOV
	//R1=0 R2=1
	ldr R1, =f0
	ldr R2, =f1
	b calc

calc:
	add R3, R1, R2	//R3=R1+R2
	mov R5, R3, lsr #31 //if(R5[31]==1) overflow
	and R5, R5, #1
	cmp R5, #1
	beq finish_ov
	sub R0, R0, #1 //N--
	cmp R0, #1	//if(N==1) cout<<fn
	beq finish_N
	mov R1, R2	//R1=R2 R2=R3
	mov R2, R3
	b calc

finish_0:
	mov R4, #f0
	b finish

finish_1:
	mov R4, #f1
	b finish

finish_NOV:
	mov R4, #-1
	b finish

finish_ov:
	mov R4, #-2
	b finish

finish_N:
	mov R4, R3
	b finish

finish:
	bx lr
main:
	movs R0, #N
	bl fib

L: b L
