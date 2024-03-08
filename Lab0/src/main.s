.syntax unified
.cpu cortex-m4
.thumb
.data
Z: .word 60
X: .word 100
str: .asciz "Hello World!"
.text
.global main

.equ AA, 0x55
.equ tmp, 3
main:
ldr r1, =X
ldr r4, =Z
ldr r5, =tmp
ldr r6, [r1]
mul r3, r6, r5
str r3, [r4]
ldr r0, [r1]
movs r2, #AA
adds r2, r2, r0
str r2, [r1]
ldr r1, =str
ldrh r2, [r1]
L: B L
