/*
 * @XMHF_LICENSE_HEADER_START@
 *
 * eXtensible, Modular Hypervisor Framework (XMHF)
 * Copyright (c) 2009-2012 Carnegie Mellon University
 * Copyright (c) 2010-2012 VDG Inc.
 * All Rights Reserved.
 *
 * Developed by: XMHF Team
 *               Carnegie Mellon University / CyLab
 *               VDG Inc.
 *               http://xmhf.org
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * Redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following disclaimer.
 *
 * Redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in
 * the documentation and/or other materials provided with the
 * distribution.
 *
 * Neither the names of Carnegie Mellon or VDG Inc, nor the names of
 * its contributors may be used to endorse or promote products derived
 * from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND
 * CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS
 * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 * TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 * ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
 * TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
 * THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 *
 * @XMHF_LICENSE_HEADER_END@
 */

/*
 * risc-v cpu hardware model implementation
 * author: ethan joseph (ethanj217@gmail.com)
*/

#define uint32_t unsigned long

extern uint32_t hwm_cpu_x0;		//zero//	hardwired zero
extern uint32_t hwm_cpu_x1;		//ra//	return address
extern uint32_t hwm_cpu_x2;		//sp//stack pointer
extern uint32_t hwm_cpu_x3;		//gp//	global pointer
extern uint32_t hwm_cpu_x4;		//tp//	thread pointer
extern uint32_t hwm_cpu_x5;		//t0//	temporary registers
extern uint32_t hwm_cpu_x6;		//t1//	temporary registers
extern uint32_t hwm_cpu_x7;		//t2//	temporary registers
extern uint32_t hwm_cpu_x8;		//s0/fp//	saved register / frame pointer
extern uint32_t hwm_cpu_x9;		//s1//	saved register
extern uint32_t hwm_cpu_x10;	//a0//	function arguments / return values
extern uint32_t hwm_cpu_x11;	//a1//	function arguments / return values
extern uint32_t hwm_cpu_x12;	//a2//	function arguments
extern uint32_t hwm_cpu_x13;	//a3//	function arguments
extern uint32_t hwm_cpu_x14;	//a4//	function arguments
extern uint32_t hwm_cpu_x15;	//a5//	function arguments
extern uint32_t hwm_cpu_x16;	//a6//	function arguments
extern uint32_t hwm_cpu_x17;	//a7//	function arguments
extern uint32_t hwm_cpu_x18;	//s2//	saved registers
extern uint32_t hwm_cpu_x19;	//s3//	saved registers
extern uint32_t hwm_cpu_x20;	//s4//	saved registers
extern uint32_t hwm_cpu_x21;	//s5//	saved registers
extern uint32_t hwm_cpu_x22;	//s6//	saved registers
extern uint32_t hwm_cpu_x23;	//s7//	saved registers
extern uint32_t hwm_cpu_x24;	//s8//	saved registers
extern uint32_t hwm_cpu_x25;	//s9//	saved registers
extern uint32_t hwm_cpu_x26;	//s10//	saved registers
extern uint32_t hwm_cpu_x27;	//s11//	saved registers
extern uint32_t hwm_cpu_x28;	//t3//	temporary registers
extern uint32_t hwm_cpu_x29;	//t4//	temporary registers
extern uint32_t hwm_cpu_x30;	//t5//	temporary registers
extern uint32_t hwm_cpu_x31;	//t6//	temporary registers
