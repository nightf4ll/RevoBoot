/*
 * Copyright (c) 1999 Apple Computer, Inc. All rights reserved.
 *
 * @APPLE_LICENSE_HEADER_START@
 * 
 * Portions Copyright (c) 1999 Apple Computer, Inc.  All Rights
 * Reserved.  This file contains Original Code and/or Modifications of
 * Original Code as defined in and that are subject to the Apple Public
 * Source License Version 1.1 (the "License").  You may not use this file
 * except in compliance with the License.  Please obtain a copy of the
 * License at http://www.apple.com/publicsource and read it before using
 * this file.
 * 
 * The Original Code and all software distributed under the License are
 * distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, EITHER
 * EXPRESS OR IMPLIED, AND APPLE HEREBY DISCLAIMS ALL SUCH WARRANTIES,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE OR NON- INFRINGEMENT.  Please see the
 * License for the specific language governing rights and limitations
 * under the License.
 * 
 * @APPLE_LICENSE_HEADER_END@
 */
/* 
 * Mach Operating System
 * Copyright (c) 1990 Carnegie-Mellon University
 * Copyright (c) 1989 Carnegie-Mellon University
 * All rights reserved.  The CMU software License Agreement specifies
 * the terms and conditions for use and redistribution.
 */

/*
 * boot2() -- second stage boot.
 *
 * This function must be located at 0:BOOTER_ADDR and will be called by boot1.
 */

#include <architecture/i386/asm_help.h>
#include "memory.h"

#define DEBUG   0           // Set to 0 by default. Use 1 for testing only!

#define data32  .byte 0x66
#define retf    .byte 0xcb

    .file "boot2.s"
    .section __INIT,__text	// turbo - This initialization code must reside within the first segment

    //.data
    .section __INIT,__data	// turbo - Data that must be in the first segment

    //.text
    .section __INIT,__text	// turbo

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Booter entry point. Called by boot1.
# This routine must be the first in the TEXT segment.
#
# Arguments:
#   DX    = Boot device
#
# Returns:
#
LABEL(boot2)                    # Entry point at 0:BOOTER_ADDR (will be called by boot1)
    pushl   %ecx                # Save general purpose registers
    pushl   %ebx
    pushl   %ebp
    pushl   %esi
    pushl   %edi
    push    %ds                 # Save DS, ES
    push    %es

#if DEBUG
#-------------------------------------------------------------------------------
# Writes an "R" to the console (flashing _ cursor) and waits for a key press.
#
#
    push    %ax
    push    %bx

    mov        $0x0e52, %ax        # AH=0x0e (function code), AL=0x52 (character to print: 'R') 
    mov     $0x0001, %bx        # BH=0x00 (page number), BL=0x01 (blue in graphics mode)
    int     $0x10               # Display byte in teletype mode
#
# Wait for a key press.
#
    mov     $0x00,   %ah
    int	    $0x16

    pop     %bx
    pop     %ax
#-------------------------------------------------------------------------------
#endif

    mov     %cs, %ax            # Update segment registers.
    mov     %ax, %ds            # Set DS and ES to match CS
    mov     %ax, %es

    data32
    call    __switch_stack      # Switch to new stack

    data32
    call    __real_to_prot      # Enter protected mode.

    # We are now in 32-bit protected mode.
    # Transfer execution to C by calling boot().
    
    pushl   %edx                # bootdev
    call    _boot

