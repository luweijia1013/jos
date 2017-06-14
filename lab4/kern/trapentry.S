/* See COPYRIGHT for copyright information. */

#include <inc/mmu.h>
#include <inc/memlayout.h>
#include <inc/trap.h>

#include <kern/picirq.h>


###################################################################
# exceptions/interrupts
###################################################################

/* TRAPHANDLER defines a globally-visible function for handling a trap.
 * It pushes a trap number onto the stack, then jumps to _alltraps.
 * Use TRAPHANDLER for traps where the CPU automatically pushes an error code.
 *
 * You shouldn't call a TRAPHANDLER function from C, but you may
 * need to _declare_ one in C (for instance, to get a function pointer
 * during IDT setup).  You can declare the function with
 *   void NAME();
 * where NAME is the argument passed to TRAPHANDLER.
 */
#define TRAPHANDLER(name, num)						\
	.globl name;		/* define global symbol for 'name' */	\
	.type name, @function;	/* symbol type is function */		\
	.align 2;		/* align function definition */		\
	name:			/* function starts here */		\
	pushl $(num);							\
	jmp _alltraps

/* Use TRAPHANDLER_NOEC for traps where the CPU doesn't push an error code.
 * It pushes a 0 in place of the error code, so the trap frame has the same
 * format in either case.
 */
#define TRAPHANDLER_NOEC(name, num)					\
	.globl name;							\
	.type name, @function;						\
	.align 2;							\
	name:								\
	pushl $0;							\
	pushl $(num);							\
	jmp _alltraps

.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
TRAPHANDLER_NOEC(tp_en0,T_DIVIDE);
TRAPHANDLER_NOEC(tp_en1,T_DEBUG);
TRAPHANDLER_NOEC(tp_en2,T_NMI);
TRAPHANDLER_NOEC(tp_en3,T_BRKPT);
TRAPHANDLER_NOEC(tp_en4,T_OFLOW);
TRAPHANDLER_NOEC(tp_en5,T_BOUND);
TRAPHANDLER_NOEC(tp_en6,T_ILLOP);
TRAPHANDLER_NOEC(tp_en7,T_DEVICE);
TRAPHANDLER(tp_en8,T_DBLFLT);
TRAPHANDLER_NOEC(tp_en9,9);
TRAPHANDLER(tp_en10,T_TSS);
TRAPHANDLER(tp_en11,T_SEGNP);
TRAPHANDLER(tp_en12,T_STACK);
TRAPHANDLER(tp_en13,T_GPFLT);
TRAPHANDLER(tp_en14,T_PGFLT);
TRAPHANDLER_NOEC(tp_en15,15);
TRAPHANDLER_NOEC(tp_en16,T_FPERR);
TRAPHANDLER(tp_en17,T_ALIGN);
TRAPHANDLER_NOEC(tp_en18,T_MCHK);
TRAPHANDLER_NOEC(tp_en19,T_SIMDERR);


.data
.globl trap_entry
trap_entry:
	.long tp_en0
	.long tp_en1
	.long tp_en2
	.long tp_en3
	.long tp_en4
	.long tp_en5
	.long tp_en6
	.long tp_en7
	.long tp_en8
	.long tp_en9
	.long tp_en10
	.long tp_en11
	.long tp_en12
	.long tp_en13
	.long tp_en14
	.long tp_en15
	.long tp_en16
	.long tp_en17
	.long tp_en18
	.long tp_en19



.globl sysenter_handler;
.type sysenter_handler, @function;
.align 2;
sysenter_handler:
/*
 * Lab 3: Your code here for system call handling
 */
	pushl $GD_UD|3
	pushl %ebp
	pushfl
	pushl $GD_UT|3
	pushl %esi
	pushl $0
	pushl $0
	pushl %ds
	pushl %es
	pushal
 	pushw $GD_KD
 	pushw $GD_KD
 	popw %ds
 	popw %es
	pushl %esp
	call syscall_manager /*will not return*/
	popl %esp
	popal
	popl %es
	popl %ds
	//pushw $GD_UD|3
 	//pushw $GD_UD|3
 	//popw %ds
 	//popw %es
	movl %ebp,%ecx
	movl %esi,%edx
	sysexit

/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
	pushl %ds
	pushl %es
	pushal
	pushw $GD_KD
	pushw $GD_KD
	popw %ds
	popw %es
	pushl %esp
	call trap

