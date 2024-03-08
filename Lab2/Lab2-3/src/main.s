	.syntax unified
	.cpu cortex-m4
	.thumb
.data
	result: .word 0
	max_size: .word 0
	user_stack_bottom: .zero 128 //allocate space for stack
.text
	.global main
	m: .word 0x4E
	n: .word 0x82

GCD:
//TODO: Implement your GCD function
	//store lr to stack
	PUSH {lr}
	ADD R10, #4	//calculate stack size R10+=4(1 word)
	//if (m == 0) return n;
	CMP R0, #0
	ITT EQ
	MOVEQ R3, R1
	POPEQ {PC} //jump back to main

	//if (n == 0) return m;
	CMP R1, #0
	ITT EQ
	MOVEQ R3, R1
	POPEQ {PC} //jump back to main

	AND R4, R0, #1	// if (m%2 == 0)
	AND R5, R1, #1	// if (n%2 == 0)
	ORR R6, R4, R5	// if (m%2 == 0 & n%2 == 0)
	CMP R6, #0
	BEQ m_n_even

	// if (m%2 == 0) return GCD(m >> 1, n);
	CMP R4, #0
	BEQ m_even

	//if (n%2 == 0) return GCD(m, n >> 1);
	CMP R5, #0
	BEQ n_even

	//return GCD(abs(m - n), min(m, n));
	CMP R0, R1
	ITEEE GT
	SUBGT R0, R0, R1	//if(m>n) m=m-n
	SUBLE R9, R1, R0	//if(m<n) R9=n-m
	MOVLE R1, R0		//n=m
	MOVLE R0, R9		//m=R9
	BL GCD
	POP {PC}

m_n_even:	//return 2 * GCD(m >> 1, n >> 1);
	MOV R0, R0, LSR #1
	MOV R1, R1, LSR #1
	BL GCD
	MOV R3, R3, LSL #1
	POP {PC}

m_even:	//return GCD(m >> 1, n);
	MOV R0, R0, LSR #1 //m >> 1
	BL GCD
	POP {PC}

n_even: //return GCD(m, n >> 1);
	MOV R1, R1, LSR #1 //n >> 1
	BL GCD
	POP {PC}


main:
// r0 = m, r1 = n
	LDR R3, =user_stack_bottom
	ADD R3, R3, #128
	MSR MSP, R3
	LDR R0, =m
	LDR R1, =n
	LDR R0, [R0]	//m
	LDR R1, [R1]	//n
	LDR R2, =result
	MOV R3, #1		//initial R3=1
	LDR R7, =max_size
	MOV R10, #0
	BL GCD
// get return val and store into result
	STR R3, [R2]	//R3 store to result
	STR R10, [R7]	//R10 calculate max size
L: b L
