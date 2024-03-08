	.syntax unified
	.cpu cortex-m4
	.thumb
.data
	infix_expr: .asciz "{ -99+ [ 10 + 20 - 10 }	"
	user_stack_bottom: .zero 128 //allocate space for stack
.text
	.global main
	//move infix_expr here. Please refer to the question below.

main:
	BL stack_init
	LDR R0, =infix_expr
	BL pare_check
L: B L

stack_init:
//TODO: Setup the stack pointer(sp) to user_stack.
	LDR R3, =user_stack_bottom	//R3 is stack bottom
	ADD R3, R3, #128
	MSR MSP, R3	//MSP=R3
	MRS R3, MSP	//R3=MSP
	BX LR

pare_check:
//TODO: check parentheses balance, and set the error code to R0.
	LDRB R1, [R0]
	ADD R0, R0, #1

Check_middle_left:
	CMP R1, #91	//check '['
	ITT EQ
	PUSHEQ {R1}
	BEQ pare_check


Check_middle_right:
	CMP R1, #93	//check ']'
	ITE EQ
	POPEQ {R2}	//pop '['
	BLNE Check_big_left

	CMP R2, #91
	ITT NE		//if(R2!='[')
	MOVNE R0, #-1 //error so R0=-1
	BNE L
	B pare_check

Check_big_left:
	CMP R1, #123	//check '{'
	ITT EQ
	PUSHEQ {R1}
	BEQ pare_check

Check_big_right:
	CMP R1, #125	//check '}'
	ITE EQ
	POPEQ {R2}
	BLNE Check_done

	CMP R2, #123	//if(R2!='{')
	ITT NE
	MOVNE R0, #-1	//error so R0=-1
	BNE L
	B pare_check

Check_done:
	CMP R1, #0	//if(R1=='\0') DONE
	BEQ DONE
	B pare_check

DONE:
	MRS R4, MSP
	CMP R3, R4	//R3 is stack bottom when stack is empty so if(R3==MSP) parentheses balance
	ITE EQ
	MOVEQ R0, #0
	MOVNE R0, #-1
	B L
