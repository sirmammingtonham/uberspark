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

/**
 * XMHF core global data module
 * author: amit vasudevan (amitvasudevan@acm.org)
 */

#include <xmhf-core.h>

//bplt-data.c

//system e820 map
GRUBE820 g_e820map[MAX_E820_ENTRIES] __attribute__(( section(".data") ));

//SMP CPU map; lapic id, base, ver and bsp indication for each available core
PCPU	g_cpumap[MAX_PCPU_ENTRIES] __attribute__(( section(".data") ));

//runtime stacks for individual cores
u8 g_cpustacks[RUNTIME_STACK_SIZE * MAX_PCPU_ENTRIES] __attribute__(( section(".stack") ));

//VCPU structure for each "guest OS" core
//VCPU g_vcpubuffers[MAX_VCPU_ENTRIES] __attribute__(( section(".data") ));
VCPU g_bplt_vcpu[MAX_VCPU_ENTRIES] __attribute__(( section(".data") ));


//master id table, contains core lapic id to VCPU mapping information
MIDTAB g_midtable[MAX_MIDTAB_ENTRIES] __attribute__(( section(".data") ));

//number of entries in the master id table, in essence the number of 
//physical cores in the system
u32 g_midtable_numentries __attribute__(( section(".data") )) = 0;

//variable that is incremented by 1 by all cores that boot up, this should
//be finally equal to g_midtable_numentries at runtime which signifies
//that all physical cores have been booted up and initialized by the runtime
u32 g_cpus_active __attribute__(( section(".data") )) = 0;

//SMP lock for the above variable
u32 g_lock_cpus_active __attribute__(( section(".data") )) = 1;
    
//variable that is set to 1 by the BSP after rallying all the other cores.
//this is used by the application cores to enter the "wait-for-SIPI" state    
u32 g_ap_go_signal __attribute__(( section(".data") )) = 0;

//SMP lock for the above variable
u32 g_lock_ap_go_signal __attribute__(( section(".data") )) = 1;


//rntm-data.c

//runtime parameter block pointer 
RPB *rpb __attribute__(( section(".data") )); 

#ifndef __XMHF_VERIFICATION__
//runtime DMA protection buffer
u8 g_rntm_dmaprot_buffer[SIZE_G_RNTM_DMAPROT_BUFFER] __attribute__(( section(".palign_data") ));
#else //__XMHF_VERIFICATION__
//DMA table initialization is currently audited manually
#endif

//variable that is incremented by 1 by all cores that cycle through appmain
//successfully, this should be finally equal to g_midtable_numentries at
//runtime which signifies that EMHF appmain executed successfully on all
//cores
u32 g_appmain_success_counter __attribute__(( section(".data") )) = 0;

//SMP lock for the above variable
u32 g_lock_appmain_success_counter __attribute__(( section(".data") )) = 1;


//xc-apihub.c

//----------------------------------------------------------------------
/*
 * 	apih-pbvph-data.c
 * 
 *  XMHF core API interface component pass-by-value parameter handling
 *  backend
 * 
 *  global data variables
 * 
 *  author: amit vasudevan (amitvasudevan@acm.org)
 */

XMHF_HYPAPP_PARAMETERBLOCK *paramcore = (XMHF_HYPAPP_PARAMETERBLOCK *)&paramcore_start;

XMHF_HYPAPP_PARAMETERBLOCK *paramhypapp = (XMHF_HYPAPP_PARAMETERBLOCK *)&paramhypapp_start;

//hypapp PAE page tables
u64 hypapp_3level_pdpt[PAE_MAXPTRS_PER_PDPT] __attribute__(( section(".palign_data") ));
u64 hypapp_3level_pdt[PAE_PTRS_PER_PDPT * PAE_PTRS_PER_PDT] __attribute__(( section(".palign_data") ));

//core PAE page tables
u64 core_3level_pdpt[PAE_MAXPTRS_PER_PDPT] __attribute__(( section(".palign_data") ));
u64 core_3level_pdt[PAE_PTRS_PER_PDPT * PAE_PTRS_PER_PDT] __attribute__(( section(".palign_data") ));

//----------------------------------------------------------------------
XMHF_HYPAPP_HEADER *g_hypappheader=(XMHF_HYPAPP_HEADER *)__TARGET_BASE_XMHFHYPAPP;

//hypapp callback hub entry point and hypapp top of stack
u32 hypapp_cbhub_pc=0;
u32 hypapp_tos=0;

//core and hypapp page table base address (PTBA)
u32 core_ptba=0;
u32 hypapp_ptba=0;
