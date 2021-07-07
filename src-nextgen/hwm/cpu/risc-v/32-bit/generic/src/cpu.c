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
 * TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;	LOSS OF USE,
 * DATA, OR PROFITS;	OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
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

#include <uberspark/include/uberspark.h>

const uint32_t hwm_cpu_x0 = 0;	//zero//	hardwired zero
uint32_t hwm_cpu_x1 = 0;		//ra//	return address
uint32_t hwm_cpu_x2 = 0;		//sp//	stack pointer
uint32_t hwm_cpu_x3 = 0;		//gp//	global pointer
uint32_t hwm_cpu_x4 = 0;		//tp//	thread pointer
uint32_t hwm_cpu_x5 = 0;		//t0//	temporary registers
uint32_t hwm_cpu_x6 = 0;		//t1//	temporary registers
uint32_t hwm_cpu_x7 = 0;		//t2//	temporary registers
uint32_t hwm_cpu_x8 = 0;		//s0/fp//	saved register / frame pointer
uint32_t hwm_cpu_x9 = 0;		//s1//	saved register
uint32_t hwm_cpu_x10 = 0;		//a0//	function arguments / return values
uint32_t hwm_cpu_x11 = 0;		//a1//	function arguments / return values
uint32_t hwm_cpu_x12 = 0;		//a2//	function arguments
uint32_t hwm_cpu_x13 = 0;		//a3//	function arguments
uint32_t hwm_cpu_x14 = 0;		//a4//	function arguments
uint32_t hwm_cpu_x15 = 0;		//a5//	function arguments
uint32_t hwm_cpu_x16 = 0;		//a6//	function arguments
uint32_t hwm_cpu_x17 = 0;		//a7//	function arguments
uint32_t hwm_cpu_x18 = 0;		//s2//	saved registers
uint32_t hwm_cpu_x19 = 0;		//s3//	saved registers
uint32_t hwm_cpu_x20 = 0;		//s4//	saved registers
uint32_t hwm_cpu_x21 = 0;		//s5//	saved registers
uint32_t hwm_cpu_x22 = 0;		//s6//	saved registers
uint32_t hwm_cpu_x23 = 0;		//s7//	saved registers
uint32_t hwm_cpu_x24 = 0;		//s8//	saved registers
uint32_t hwm_cpu_x25 = 0;		//s9//	saved registers
uint32_t hwm_cpu_x26 = 0;		//s10//	saved registers
uint32_t hwm_cpu_x27 = 0;		//s11//	saved registers
uint32_t hwm_cpu_x28 = 0;		//t3//	temporary registers
uint32_t hwm_cpu_x29 = 0;		//t4//	temporary registers
uint32_t hwm_cpu_x30 = 0;		//t5//	temporary registers
uint32_t hwm_cpu_x31 = 0;		//t6//	temporary registers
