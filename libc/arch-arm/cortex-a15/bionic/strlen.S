/* Copyright (c) 2010-2011,2013 Linaro Limited
   All rights reserved.

   Redistribution and use in source and binary forms, with or without
   modification, are permitted provided that the following conditions
   are met:

      * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.

      * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.

      * Neither the name of Linaro Limited nor the names of its
      contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.

   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
   A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
   HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
   LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
   DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
   THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
   OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/*
   Assumes:
   ARMv6T2, AArch32

   Adapted to Bionic by Bernhard Rosenkränzer <bero@linaro.org>
 */

#include <private/bionic_asm.h>

#ifdef __ARMEB__
#define S2LO		lsl
#define S2HI		lsr
#else
#define S2LO		lsr
#define S2HI		lsl
#endif

	.text
	/* This code requires Thumb.  */
	.thumb
	.syntax unified

/* Parameters and result.  */
#define srcin		r0
#define result		r0

/* Internal variables.  */
#define src		r1
#define data1a		r2
#define data1b		r3
#define const_m1	r12
#define const_0		r4
#define tmp1		r4		/* Overlaps const_0  */
#define tmp2		r5

ENTRY(strlen)
    pld     [r0, #0]
    mov     r1, r0

    ands    r3, r0, #7
    beq     .L_mainloop

    // Align to a double word (64 bits).
    rsb     r3, r3, #8
    lsls    ip, r3, #31
    beq     .L_align_to_32

    ldrb    r2, [r1], #1
    cbz     r2, .L_update_count_and_return

.L_align_to_32:
    bcc     .L_align_to_64
    ands    ip, r3, #2
    beq     .L_align_to_64

    ldrb    r2, [r1], #1
    cbz     r2, .L_update_count_and_return
    ldrb    r2, [r1], #1
    cbz     r2, .L_update_count_and_return

.L_align_to_64:
    tst     r3, #4
    beq     .L_mainloop
    ldr     r3, [r1], #4

    sub     ip, r3, #0x01010101
    bic     ip, ip, r3
    ands    ip, ip, #0x80808080
    bne     .L_zero_in_second_register

    .p2align 2
.L_mainloop:
    ldrd    r2, r3, [r1], #8

    pld     [r1, #64]

    sub     ip, r2, #0x01010101
    bic     ip, ip, r2
    ands    ip, ip, #0x80808080
    bne     .L_zero_in_first_register

    sub     ip, r3, #0x01010101
    bic     ip, ip, r3
    ands    ip, ip, #0x80808080
    bne     .L_zero_in_second_register
    b       .L_mainloop

.L_update_count_and_return:
    sub     r0, r1, r0
    sub     r0, r0, #1
    bx      lr

.L_zero_in_first_register:
    sub     r0, r1, r0
    lsls    r3, ip, #17
    bne     .L_sub8_and_return
    bcs     .L_sub7_and_return
    lsls    ip, ip, #1
    bne     .L_sub6_and_return

    sub     r0, r0, #5
    bx      lr

.L_sub8_and_return:
    sub     r0, r0, #8
    bx      lr

.L_sub7_and_return:
    sub     r0, r0, #7
    bx      lr

.L_sub6_and_return:
    sub     r0, r0, #6
    bx      lr

.L_zero_in_second_register:
    sub     r0, r1, r0
    lsls    r3, ip, #17
    bne     .L_sub4_and_return
    bcs     .L_sub3_and_return
    lsls    ip, ip, #1
    bne     .L_sub2_and_return

    sub     r0, r0, #1
    bx      lr

.L_sub4_and_return:
    sub     r0, r0, #4
    bx      lr

.L_sub3_and_return:
    sub     r0, r0, #3
    bx      lr

.L_sub2_and_return:
    sub     r0, r0, #2
    bx      lr
END(strlen)
