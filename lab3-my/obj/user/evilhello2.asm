
obj/user/evilhello2:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 63 00 00 00       	call   800094 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <evil>:
#include <inc/x86.h>


// Call this function with ring0 privilege
void evil()
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
	// Kernel memory access
	*(char*)0xf010000a = 0;
  800037:	c6 05 0a 00 10 f0 00 	movb   $0x0,0xf010000a
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  80003e:	ba f8 03 00 00       	mov    $0x3f8,%edx
  800043:	b8 49 00 00 00       	mov    $0x49,%eax
  800048:	ee                   	out    %al,(%dx)
  800049:	b8 4e 00 00 00       	mov    $0x4e,%eax
  80004e:	ee                   	out    %al,(%dx)
  80004f:	b8 20 00 00 00       	mov    $0x20,%eax
  800054:	ee                   	out    %al,(%dx)
  800055:	b8 52 00 00 00       	mov    $0x52,%eax
  80005a:	ee                   	out    %al,(%dx)
  80005b:	b8 49 00 00 00       	mov    $0x49,%eax
  800060:	ee                   	out    %al,(%dx)
  800061:	b8 4e 00 00 00       	mov    $0x4e,%eax
  800066:	ee                   	out    %al,(%dx)
  800067:	b8 47 00 00 00       	mov    $0x47,%eax
  80006c:	ee                   	out    %al,(%dx)
  80006d:	b8 30 00 00 00       	mov    $0x30,%eax
  800072:	ee                   	out    %al,(%dx)
  800073:	b8 21 00 00 00       	mov    $0x21,%eax
  800078:	ee                   	out    %al,(%dx)
  800079:	ee                   	out    %al,(%dx)
  80007a:	ee                   	out    %al,(%dx)
  80007b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800080:	ee                   	out    %al,(%dx)
	outb(0x3f8, '0');
	outb(0x3f8, '!');
	outb(0x3f8, '!');
	outb(0x3f8, '!');
	outb(0x3f8, '\n');
}
  800081:	5d                   	pop    %ebp
  800082:	c3                   	ret    

00800083 <ring0_call>:
{
	__asm __volatile("sgdt %0" :  "=m" (*gdtd));
}

// Invoke a given function pointer with ring0 privilege, then return to ring3
void ring0_call(void (*fun_ptr)(void)) {
  800083:	55                   	push   %ebp
  800084:	89 e5                	mov    %esp,%ebp
    // Hint : use a wrapper function to call fun_ptr. Feel free
    //        to add any functions or global variables in this 
    //        file if necessary.

    // Lab3 : Your Code Here
}
  800086:	5d                   	pop    %ebp
  800087:	c3                   	ret    

00800088 <umain>:

void
umain(int argc, char **argv)
{
  800088:	55                   	push   %ebp
  800089:	89 e5                	mov    %esp,%ebp
        // call the evil function in ring0
	ring0_call(&evil);

	// call the evil function in ring3
	evil();
  80008b:	e8 a4 ff ff ff       	call   800034 <evil>
}
  800090:	5d                   	pop    %ebp
  800091:	c3                   	ret    
	...

00800094 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 18             	sub    $0x18,%esp
  80009a:	8b 45 08             	mov    0x8(%ebp),%eax
  80009d:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8000a0:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  8000a7:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000aa:	85 c0                	test   %eax,%eax
  8000ac:	7e 08                	jle    8000b6 <libmain+0x22>
		binaryname = argv[0];
  8000ae:	8b 0a                	mov    (%edx),%ecx
  8000b0:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  8000b6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8000ba:	89 04 24             	mov    %eax,(%esp)
  8000bd:	e8 c6 ff ff ff       	call   800088 <umain>

	// exit gracefully
	exit();
  8000c2:	e8 05 00 00 00       	call   8000cc <exit>
}
  8000c7:	c9                   	leave  
  8000c8:	c3                   	ret    
  8000c9:	00 00                	add    %al,(%eax)
	...

008000cc <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000d2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000d9:	e8 12 01 00 00       	call   8001f0 <sys_env_destroy>
}
  8000de:	c9                   	leave  
  8000df:	c3                   	ret    

008000e0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	83 ec 08             	sub    $0x8,%esp
  8000e6:	89 1c 24             	mov    %ebx,(%esp)
  8000e9:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8000ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8000f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f8:	89 c3                	mov    %eax,%ebx
  8000fa:	89 c7                	mov    %eax,%edi
  8000fc:	51                   	push   %ecx
  8000fd:	52                   	push   %edx
  8000fe:	53                   	push   %ebx
  8000ff:	54                   	push   %esp
  800100:	55                   	push   %ebp
  800101:	56                   	push   %esi
  800102:	57                   	push   %edi
  800103:	5f                   	pop    %edi
  800104:	5e                   	pop    %esi
  800105:	5d                   	pop    %ebp
  800106:	5c                   	pop    %esp
  800107:	5b                   	pop    %ebx
  800108:	5a                   	pop    %edx
  800109:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80010a:	8b 1c 24             	mov    (%esp),%ebx
  80010d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800111:	89 ec                	mov    %ebp,%esp
  800113:	5d                   	pop    %ebp
  800114:	c3                   	ret    

00800115 <sys_cgetc>:

int
sys_cgetc(void)
{
  800115:	55                   	push   %ebp
  800116:	89 e5                	mov    %esp,%ebp
  800118:	83 ec 08             	sub    $0x8,%esp
  80011b:	89 1c 24             	mov    %ebx,(%esp)
  80011e:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800122:	ba 00 00 00 00       	mov    $0x0,%edx
  800127:	b8 01 00 00 00       	mov    $0x1,%eax
  80012c:	89 d1                	mov    %edx,%ecx
  80012e:	89 d3                	mov    %edx,%ebx
  800130:	89 d7                	mov    %edx,%edi
  800132:	51                   	push   %ecx
  800133:	52                   	push   %edx
  800134:	53                   	push   %ebx
  800135:	54                   	push   %esp
  800136:	55                   	push   %ebp
  800137:	56                   	push   %esi
  800138:	57                   	push   %edi
  800139:	5f                   	pop    %edi
  80013a:	5e                   	pop    %esi
  80013b:	5d                   	pop    %ebp
  80013c:	5c                   	pop    %esp
  80013d:	5b                   	pop    %ebx
  80013e:	5a                   	pop    %edx
  80013f:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800140:	8b 1c 24             	mov    (%esp),%ebx
  800143:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800147:	89 ec                	mov    %ebp,%esp
  800149:	5d                   	pop    %ebp
  80014a:	c3                   	ret    

0080014b <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  80014b:	55                   	push   %ebp
  80014c:	89 e5                	mov    %esp,%ebp
  80014e:	83 ec 08             	sub    $0x8,%esp
  800151:	89 1c 24             	mov    %ebx,(%esp)
  800154:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800158:	ba 00 00 00 00       	mov    $0x0,%edx
  80015d:	b8 02 00 00 00       	mov    $0x2,%eax
  800162:	89 d1                	mov    %edx,%ecx
  800164:	89 d3                	mov    %edx,%ebx
  800166:	89 d7                	mov    %edx,%edi
  800168:	51                   	push   %ecx
  800169:	52                   	push   %edx
  80016a:	53                   	push   %ebx
  80016b:	54                   	push   %esp
  80016c:	55                   	push   %ebp
  80016d:	56                   	push   %esi
  80016e:	57                   	push   %edi
  80016f:	5f                   	pop    %edi
  800170:	5e                   	pop    %esi
  800171:	5d                   	pop    %ebp
  800172:	5c                   	pop    %esp
  800173:	5b                   	pop    %ebx
  800174:	5a                   	pop    %edx
  800175:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800176:	8b 1c 24             	mov    (%esp),%ebx
  800179:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80017d:	89 ec                	mov    %ebp,%esp
  80017f:	5d                   	pop    %ebp
  800180:	c3                   	ret    

00800181 <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800181:	55                   	push   %ebp
  800182:	89 e5                	mov    %esp,%ebp
  800184:	83 ec 08             	sub    $0x8,%esp
  800187:	89 1c 24             	mov    %ebx,(%esp)
  80018a:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80018e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800193:	b8 04 00 00 00       	mov    $0x4,%eax
  800198:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80019b:	8b 55 08             	mov    0x8(%ebp),%edx
  80019e:	89 df                	mov    %ebx,%edi
  8001a0:	51                   	push   %ecx
  8001a1:	52                   	push   %edx
  8001a2:	53                   	push   %ebx
  8001a3:	54                   	push   %esp
  8001a4:	55                   	push   %ebp
  8001a5:	56                   	push   %esi
  8001a6:	57                   	push   %edi
  8001a7:	5f                   	pop    %edi
  8001a8:	5e                   	pop    %esi
  8001a9:	5d                   	pop    %ebp
  8001aa:	5c                   	pop    %esp
  8001ab:	5b                   	pop    %ebx
  8001ac:	5a                   	pop    %edx
  8001ad:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  8001ae:	8b 1c 24             	mov    (%esp),%ebx
  8001b1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8001b5:	89 ec                	mov    %ebp,%esp
  8001b7:	5d                   	pop    %ebp
  8001b8:	c3                   	ret    

008001b9 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  8001b9:	55                   	push   %ebp
  8001ba:	89 e5                	mov    %esp,%ebp
  8001bc:	83 ec 08             	sub    $0x8,%esp
  8001bf:	89 1c 24             	mov    %ebx,(%esp)
  8001c2:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8001c6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001cb:	b8 05 00 00 00       	mov    $0x5,%eax
  8001d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d3:	89 cb                	mov    %ecx,%ebx
  8001d5:	89 cf                	mov    %ecx,%edi
  8001d7:	51                   	push   %ecx
  8001d8:	52                   	push   %edx
  8001d9:	53                   	push   %ebx
  8001da:	54                   	push   %esp
  8001db:	55                   	push   %ebp
  8001dc:	56                   	push   %esi
  8001dd:	57                   	push   %edi
  8001de:	5f                   	pop    %edi
  8001df:	5e                   	pop    %esi
  8001e0:	5d                   	pop    %ebp
  8001e1:	5c                   	pop    %esp
  8001e2:	5b                   	pop    %ebx
  8001e3:	5a                   	pop    %edx
  8001e4:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  8001e5:	8b 1c 24             	mov    (%esp),%ebx
  8001e8:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8001ec:	89 ec                	mov    %ebp,%esp
  8001ee:	5d                   	pop    %ebp
  8001ef:	c3                   	ret    

008001f0 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  8001f0:	55                   	push   %ebp
  8001f1:	89 e5                	mov    %esp,%ebp
  8001f3:	83 ec 28             	sub    $0x28,%esp
  8001f6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8001f9:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8001fc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800201:	b8 03 00 00 00       	mov    $0x3,%eax
  800206:	8b 55 08             	mov    0x8(%ebp),%edx
  800209:	89 cb                	mov    %ecx,%ebx
  80020b:	89 cf                	mov    %ecx,%edi
  80020d:	51                   	push   %ecx
  80020e:	52                   	push   %edx
  80020f:	53                   	push   %ebx
  800210:	54                   	push   %esp
  800211:	55                   	push   %ebp
  800212:	56                   	push   %esi
  800213:	57                   	push   %edi
  800214:	5f                   	pop    %edi
  800215:	5e                   	pop    %esi
  800216:	5d                   	pop    %ebp
  800217:	5c                   	pop    %esp
  800218:	5b                   	pop    %ebx
  800219:	5a                   	pop    %edx
  80021a:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  80021b:	85 c0                	test   %eax,%eax
  80021d:	7e 28                	jle    800247 <sys_env_destroy+0x57>
		panic("syscall %d returned %d (> 0)", num, ret);
  80021f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800223:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80022a:	00 
  80022b:	c7 44 24 08 62 12 80 	movl   $0x801262,0x8(%esp)
  800232:	00 
  800233:	c7 44 24 04 26 00 00 	movl   $0x26,0x4(%esp)
  80023a:	00 
  80023b:	c7 04 24 7f 12 80 00 	movl   $0x80127f,(%esp)
  800242:	e8 0d 00 00 00       	call   800254 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800247:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80024a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80024d:	89 ec                	mov    %ebp,%esp
  80024f:	5d                   	pop    %ebp
  800250:	c3                   	ret    
  800251:	00 00                	add    %al,(%eax)
	...

00800254 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800254:	55                   	push   %ebp
  800255:	89 e5                	mov    %esp,%ebp
  800257:	56                   	push   %esi
  800258:	53                   	push   %ebx
  800259:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  80025c:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  80025f:	a1 08 20 80 00       	mov    0x802008,%eax
  800264:	85 c0                	test   %eax,%eax
  800266:	74 10                	je     800278 <_panic+0x24>
		cprintf("%s: ", argv0);
  800268:	89 44 24 04          	mov    %eax,0x4(%esp)
  80026c:	c7 04 24 8d 12 80 00 	movl   $0x80128d,(%esp)
  800273:	e8 ad 00 00 00       	call   800325 <cprintf>
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800278:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80027e:	e8 c8 fe ff ff       	call   80014b <sys_getenvid>
  800283:	8b 55 0c             	mov    0xc(%ebp),%edx
  800286:	89 54 24 10          	mov    %edx,0x10(%esp)
  80028a:	8b 55 08             	mov    0x8(%ebp),%edx
  80028d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800291:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800295:	89 44 24 04          	mov    %eax,0x4(%esp)
  800299:	c7 04 24 94 12 80 00 	movl   $0x801294,(%esp)
  8002a0:	e8 80 00 00 00       	call   800325 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002a5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002a9:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ac:	89 04 24             	mov    %eax,(%esp)
  8002af:	e8 10 00 00 00       	call   8002c4 <vcprintf>
	cprintf("\n");
  8002b4:	c7 04 24 92 12 80 00 	movl   $0x801292,(%esp)
  8002bb:	e8 65 00 00 00       	call   800325 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002c0:	cc                   	int3   
  8002c1:	eb fd                	jmp    8002c0 <_panic+0x6c>
	...

008002c4 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8002c4:	55                   	push   %ebp
  8002c5:	89 e5                	mov    %esp,%ebp
  8002c7:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8002cd:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002d4:	00 00 00 
	b.cnt = 0;
  8002d7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002de:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002e4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8002eb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ef:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002f9:	c7 04 24 3f 03 80 00 	movl   $0x80033f,(%esp)
  800300:	e8 0b 03 00 00       	call   800610 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800305:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80030b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80030f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800315:	89 04 24             	mov    %eax,(%esp)
  800318:	e8 c3 fd ff ff       	call   8000e0 <sys_cputs>

	return b.cnt;
}
  80031d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800323:	c9                   	leave  
  800324:	c3                   	ret    

00800325 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800325:	55                   	push   %ebp
  800326:	89 e5                	mov    %esp,%ebp
  800328:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  80032b:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  80032e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800332:	8b 45 08             	mov    0x8(%ebp),%eax
  800335:	89 04 24             	mov    %eax,(%esp)
  800338:	e8 87 ff ff ff       	call   8002c4 <vcprintf>
	va_end(ap);

	return cnt;
}
  80033d:	c9                   	leave  
  80033e:	c3                   	ret    

0080033f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80033f:	55                   	push   %ebp
  800340:	89 e5                	mov    %esp,%ebp
  800342:	53                   	push   %ebx
  800343:	83 ec 14             	sub    $0x14,%esp
  800346:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800349:	8b 03                	mov    (%ebx),%eax
  80034b:	8b 55 08             	mov    0x8(%ebp),%edx
  80034e:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800352:	83 c0 01             	add    $0x1,%eax
  800355:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800357:	3d ff 00 00 00       	cmp    $0xff,%eax
  80035c:	75 19                	jne    800377 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80035e:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800365:	00 
  800366:	8d 43 08             	lea    0x8(%ebx),%eax
  800369:	89 04 24             	mov    %eax,(%esp)
  80036c:	e8 6f fd ff ff       	call   8000e0 <sys_cputs>
		b->idx = 0;
  800371:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800377:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80037b:	83 c4 14             	add    $0x14,%esp
  80037e:	5b                   	pop    %ebx
  80037f:	5d                   	pop    %ebp
  800380:	c3                   	ret    
	...

00800390 <printnum_nopad>:

/*
* help function added by Lu to print only the num;
*/
static void printnum_nopad(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int *num_len){
  800390:	55                   	push   %ebp
  800391:	89 e5                	mov    %esp,%ebp
  800393:	83 ec 48             	sub    $0x48,%esp
  800396:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800399:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80039c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80039f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8003a2:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8003a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003ab:	8b 75 0c             	mov    0xc(%ebp),%esi
  8003ae:	8b 45 10             	mov    0x10(%ebp),%eax
  8003b1:	8b 7d 14             	mov    0x14(%ebp),%edi
	if(num >= base){
  8003b4:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8003b7:	ba 00 00 00 00       	mov    $0x0,%edx
  8003bc:	39 f2                	cmp    %esi,%edx
  8003be:	72 07                	jb     8003c7 <printnum_nopad+0x37>
  8003c0:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8003c3:	39 c8                	cmp    %ecx,%eax
  8003c5:	77 54                	ja     80041b <printnum_nopad+0x8b>
		printnum_nopad(putch, putdat, num / base, base, num_len);
  8003c7:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8003cb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003cf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8003d3:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8003d7:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8003da:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8003dd:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8003e0:	89 54 24 08          	mov    %edx,0x8(%esp)
  8003e4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003eb:	00 
  8003ec:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8003ef:	89 0c 24             	mov    %ecx,(%esp)
  8003f2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003f6:	e8 f5 0b 00 00       	call   800ff0 <__udivdi3>
  8003fb:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8003fe:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800401:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800405:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800409:	89 04 24             	mov    %eax,(%esp)
  80040c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800410:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800413:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800416:	e8 75 ff ff ff       	call   800390 <printnum_nopad>
	}
	*num_len += 1 ;
  80041b:	83 07 01             	addl   $0x1,(%edi)
	putch("0123456789abcdef"[num % base], putdat);
  80041e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800421:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800425:	8b 04 24             	mov    (%esp),%eax
  800428:	8b 54 24 04          	mov    0x4(%esp),%edx
  80042c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80042f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800432:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800435:	89 54 24 08          	mov    %edx,0x8(%esp)
  800439:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800440:	00 
  800441:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800444:	89 0c 24             	mov    %ecx,(%esp)
  800447:	89 74 24 04          	mov    %esi,0x4(%esp)
  80044b:	e8 d0 0c 00 00       	call   801120 <__umoddi3>
  800450:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800453:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800457:	0f be 80 b7 12 80 00 	movsbl 0x8012b7(%eax),%eax
  80045e:	89 04 24             	mov    %eax,(%esp)
  800461:	ff 55 d4             	call   *-0x2c(%ebp)
}
  800464:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800467:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80046a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80046d:	89 ec                	mov    %ebp,%esp
  80046f:	5d                   	pop    %ebp
  800470:	c3                   	ret    

00800471 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800471:	55                   	push   %ebp
  800472:	89 e5                	mov    %esp,%ebp
  800474:	57                   	push   %edi
  800475:	56                   	push   %esi
  800476:	53                   	push   %ebx
  800477:	83 ec 5c             	sub    $0x5c,%esp
  80047a:	89 c7                	mov    %eax,%edi
  80047c:	89 d6                	mov    %edx,%esi
  80047e:	8b 45 08             	mov    0x8(%ebp),%eax
  800481:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800484:	8b 55 0c             	mov    0xc(%ebp),%edx
  800487:	89 55 cc             	mov    %edx,-0x34(%ebp)
  80048a:	8b 45 10             	mov    0x10(%ebp),%eax
  80048d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	if(padc == '-'){
  800490:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  800494:	75 4c                	jne    8004e2 <printnum+0x71>
		int num_len = 0;
  800496:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		printnum_nopad(putch, putdat, num, base, &num_len);
  80049d:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8004a0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004a4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004a8:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004ab:	89 0c 24             	mov    %ecx,(%esp)
  8004ae:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004b5:	89 f2                	mov    %esi,%edx
  8004b7:	89 f8                	mov    %edi,%eax
  8004b9:	e8 d2 fe ff ff       	call   800390 <printnum_nopad>
		width -= num_len;
  8004be:	2b 5d e4             	sub    -0x1c(%ebp),%ebx
		while (width-- > 0)
  8004c1:	85 db                	test   %ebx,%ebx
  8004c3:	0f 8e e8 00 00 00    	jle    8005b1 <printnum+0x140>
			putch(' ', putdat);
  8004c9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004cd:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8004d4:	ff d7                	call   *%edi
  8004d6:	83 eb 01             	sub    $0x1,%ebx
	// your code here:
	if(padc == '-'){
		int num_len = 0;
		printnum_nopad(putch, putdat, num, base, &num_len);
		width -= num_len;
		while (width-- > 0)
  8004d9:	85 db                	test   %ebx,%ebx
  8004db:	7f ec                	jg     8004c9 <printnum+0x58>
  8004dd:	e9 cf 00 00 00       	jmp    8005b1 <printnum+0x140>
			putch(' ', putdat);
	}
	else{
		// first recursively print all preceding (more significant) digits
		if (num >= base) {
  8004e2:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8004e5:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004e9:	77 19                	ja     800504 <printnum+0x93>
  8004eb:	90                   	nop
  8004ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8004f0:	72 05                	jb     8004f7 <printnum+0x86>
  8004f2:	39 45 c8             	cmp    %eax,-0x38(%ebp)
  8004f5:	73 0d                	jae    800504 <printnum+0x93>
			printnum(putch, putdat, num / base, base, width - 1, padc);
		} else {
			// print any needed pad characters before first digit
			while (--width > 0)
  8004f7:	83 eb 01             	sub    $0x1,%ebx
  8004fa:	85 db                	test   %ebx,%ebx
  8004fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800500:	7f 63                	jg     800565 <printnum+0xf4>
  800502:	eb 74                	jmp    800578 <printnum+0x107>
			putch(' ', putdat);
	}
	else{
		// first recursively print all preceding (more significant) digits
		if (num >= base) {
			printnum(putch, putdat, num / base, base, width - 1, padc);
  800504:	8b 55 18             	mov    0x18(%ebp),%edx
  800507:	89 54 24 10          	mov    %edx,0x10(%esp)
  80050b:	83 eb 01             	sub    $0x1,%ebx
  80050e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800512:	89 44 24 08          	mov    %eax,0x8(%esp)
  800516:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  80051a:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80051e:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800521:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800524:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  800527:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80052b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800532:	00 
  800533:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800536:	89 04 24             	mov    %eax,(%esp)
  800539:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80053c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800540:	e8 ab 0a 00 00       	call   800ff0 <__udivdi3>
  800545:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800548:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80054b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80054f:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800553:	89 04 24             	mov    %eax,(%esp)
  800556:	89 54 24 04          	mov    %edx,0x4(%esp)
  80055a:	89 f2                	mov    %esi,%edx
  80055c:	89 f8                	mov    %edi,%eax
  80055e:	e8 0e ff ff ff       	call   800471 <printnum>
  800563:	eb 13                	jmp    800578 <printnum+0x107>
		} else {
			// print any needed pad characters before first digit
			while (--width > 0)
				putch(padc, putdat);
  800565:	89 74 24 04          	mov    %esi,0x4(%esp)
  800569:	8b 45 18             	mov    0x18(%ebp),%eax
  80056c:	89 04 24             	mov    %eax,(%esp)
  80056f:	ff d7                	call   *%edi
		// first recursively print all preceding (more significant) digits
		if (num >= base) {
			printnum(putch, putdat, num / base, base, width - 1, padc);
		} else {
			// print any needed pad characters before first digit
			while (--width > 0)
  800571:	83 eb 01             	sub    $0x1,%ebx
  800574:	85 db                	test   %ebx,%ebx
  800576:	7f ed                	jg     800565 <printnum+0xf4>
				putch(padc, putdat);
		}

		// then print this (the least significant) digit
		putch("0123456789abcdef"[num % base], putdat);
  800578:	89 74 24 04          	mov    %esi,0x4(%esp)
  80057c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800580:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800583:	89 54 24 08          	mov    %edx,0x8(%esp)
  800587:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80058e:	00 
  80058f:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800592:	89 0c 24             	mov    %ecx,(%esp)
  800595:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800598:	89 44 24 04          	mov    %eax,0x4(%esp)
  80059c:	e8 7f 0b 00 00       	call   801120 <__umoddi3>
  8005a1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005a5:	0f be 80 b7 12 80 00 	movsbl 0x8012b7(%eax),%eax
  8005ac:	89 04 24             	mov    %eax,(%esp)
  8005af:	ff d7                	call   *%edi
	}
	
}
  8005b1:	83 c4 5c             	add    $0x5c,%esp
  8005b4:	5b                   	pop    %ebx
  8005b5:	5e                   	pop    %esi
  8005b6:	5f                   	pop    %edi
  8005b7:	5d                   	pop    %ebp
  8005b8:	c3                   	ret    

008005b9 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8005b9:	55                   	push   %ebp
  8005ba:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8005bc:	83 fa 01             	cmp    $0x1,%edx
  8005bf:	7e 0e                	jle    8005cf <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8005c1:	8b 10                	mov    (%eax),%edx
  8005c3:	8d 4a 08             	lea    0x8(%edx),%ecx
  8005c6:	89 08                	mov    %ecx,(%eax)
  8005c8:	8b 02                	mov    (%edx),%eax
  8005ca:	8b 52 04             	mov    0x4(%edx),%edx
  8005cd:	eb 22                	jmp    8005f1 <getuint+0x38>
	else if (lflag)
  8005cf:	85 d2                	test   %edx,%edx
  8005d1:	74 10                	je     8005e3 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8005d3:	8b 10                	mov    (%eax),%edx
  8005d5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005d8:	89 08                	mov    %ecx,(%eax)
  8005da:	8b 02                	mov    (%edx),%eax
  8005dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8005e1:	eb 0e                	jmp    8005f1 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8005e3:	8b 10                	mov    (%eax),%edx
  8005e5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005e8:	89 08                	mov    %ecx,(%eax)
  8005ea:	8b 02                	mov    (%edx),%eax
  8005ec:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8005f1:	5d                   	pop    %ebp
  8005f2:	c3                   	ret    

008005f3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005f3:	55                   	push   %ebp
  8005f4:	89 e5                	mov    %esp,%ebp
  8005f6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005f9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8005fd:	8b 10                	mov    (%eax),%edx
  8005ff:	3b 50 04             	cmp    0x4(%eax),%edx
  800602:	73 0a                	jae    80060e <sprintputch+0x1b>
		*b->buf++ = ch;
  800604:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800607:	88 0a                	mov    %cl,(%edx)
  800609:	83 c2 01             	add    $0x1,%edx
  80060c:	89 10                	mov    %edx,(%eax)
}
  80060e:	5d                   	pop    %ebp
  80060f:	c3                   	ret    

00800610 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800610:	55                   	push   %ebp
  800611:	89 e5                	mov    %esp,%ebp
  800613:	57                   	push   %edi
  800614:	56                   	push   %esi
  800615:	53                   	push   %ebx
  800616:	83 ec 5c             	sub    $0x5c,%esp
  800619:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80061c:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80061f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800626:	eb 12                	jmp    80063a <vprintfmt+0x2a>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800628:	85 c0                	test   %eax,%eax
  80062a:	0f 84 c6 04 00 00    	je     800af6 <vprintfmt+0x4e6>
				return;
			putch(ch, putdat);
  800630:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800634:	89 04 24             	mov    %eax,(%esp)
  800637:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80063a:	0f b6 03             	movzbl (%ebx),%eax
  80063d:	83 c3 01             	add    $0x1,%ebx
  800640:	83 f8 25             	cmp    $0x25,%eax
  800643:	75 e3                	jne    800628 <vprintfmt+0x18>
  800645:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  800649:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800650:	be ff ff ff ff       	mov    $0xffffffff,%esi
  800655:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  80065c:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800663:	eb 06                	jmp    80066b <vprintfmt+0x5b>
  800665:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  800669:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066b:	0f b6 0b             	movzbl (%ebx),%ecx
  80066e:	0f b6 d1             	movzbl %cl,%edx
  800671:	8d 43 01             	lea    0x1(%ebx),%eax
  800674:	83 e9 23             	sub    $0x23,%ecx
  800677:	80 f9 55             	cmp    $0x55,%cl
  80067a:	0f 87 58 04 00 00    	ja     800ad8 <vprintfmt+0x4c8>
  800680:	0f b6 c9             	movzbl %cl,%ecx
  800683:	ff 24 8d c0 13 80 00 	jmp    *0x8013c0(,%ecx,4)
  80068a:	c6 45 e0 2b          	movb   $0x2b,-0x20(%ebp)
  80068e:	eb d9                	jmp    800669 <vprintfmt+0x59>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800690:	8d 72 d0             	lea    -0x30(%edx),%esi
				ch = *fmt;
  800693:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800696:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800699:	83 f9 09             	cmp    $0x9,%ecx
  80069c:	76 08                	jbe    8006a6 <vprintfmt+0x96>
  80069e:	eb 40                	jmp    8006e0 <vprintfmt+0xd0>
  8006a0:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
			goto reswitch;
  8006a4:	eb c3                	jmp    800669 <vprintfmt+0x59>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8006a6:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  8006a9:	8d 0c b6             	lea    (%esi,%esi,4),%ecx
  8006ac:	8d 74 4a d0          	lea    -0x30(%edx,%ecx,2),%esi
				ch = *fmt;
  8006b0:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8006b3:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8006b6:	83 f9 09             	cmp    $0x9,%ecx
  8006b9:	76 eb                	jbe    8006a6 <vprintfmt+0x96>
  8006bb:	eb 23                	jmp    8006e0 <vprintfmt+0xd0>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8006bd:	8b 55 14             	mov    0x14(%ebp),%edx
  8006c0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006c3:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006c6:	8b 32                	mov    (%edx),%esi
			goto process_precision;
  8006c8:	eb 16                	jmp    8006e0 <vprintfmt+0xd0>

		case '.':
			if (width < 0)
  8006ca:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006cd:	c1 fa 1f             	sar    $0x1f,%edx
  8006d0:	f7 d2                	not    %edx
  8006d2:	21 55 dc             	and    %edx,-0x24(%ebp)
  8006d5:	eb 92                	jmp    800669 <vprintfmt+0x59>
  8006d7:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8006de:	eb 89                	jmp    800669 <vprintfmt+0x59>

		process_precision:
			if (width < 0)
  8006e0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006e4:	79 83                	jns    800669 <vprintfmt+0x59>
  8006e6:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8006e9:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8006ec:	e9 78 ff ff ff       	jmp    800669 <vprintfmt+0x59>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8006f1:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
			goto reswitch;
  8006f5:	e9 6f ff ff ff       	jmp    800669 <vprintfmt+0x59>
  8006fa:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8006fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800700:	8d 50 04             	lea    0x4(%eax),%edx
  800703:	89 55 14             	mov    %edx,0x14(%ebp)
  800706:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80070a:	8b 00                	mov    (%eax),%eax
  80070c:	89 04 24             	mov    %eax,(%esp)
  80070f:	ff 55 08             	call   *0x8(%ebp)
  800712:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  800715:	e9 20 ff ff ff       	jmp    80063a <vprintfmt+0x2a>
  80071a:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80071d:	8b 45 14             	mov    0x14(%ebp),%eax
  800720:	8d 50 04             	lea    0x4(%eax),%edx
  800723:	89 55 14             	mov    %edx,0x14(%ebp)
  800726:	8b 00                	mov    (%eax),%eax
  800728:	89 c2                	mov    %eax,%edx
  80072a:	c1 fa 1f             	sar    $0x1f,%edx
  80072d:	31 d0                	xor    %edx,%eax
  80072f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800731:	83 f8 06             	cmp    $0x6,%eax
  800734:	7f 0b                	jg     800741 <vprintfmt+0x131>
  800736:	8b 14 85 18 15 80 00 	mov    0x801518(,%eax,4),%edx
  80073d:	85 d2                	test   %edx,%edx
  80073f:	75 23                	jne    800764 <vprintfmt+0x154>
				printfmt(putch, putdat, "error %d", err);
  800741:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800745:	c7 44 24 08 c8 12 80 	movl   $0x8012c8,0x8(%esp)
  80074c:	00 
  80074d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800751:	8b 45 08             	mov    0x8(%ebp),%eax
  800754:	89 04 24             	mov    %eax,(%esp)
  800757:	e8 22 04 00 00       	call   800b7e <printfmt>
  80075c:	8b 5d cc             	mov    -0x34(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80075f:	e9 d6 fe ff ff       	jmp    80063a <vprintfmt+0x2a>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800764:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800768:	c7 44 24 08 d1 12 80 	movl   $0x8012d1,0x8(%esp)
  80076f:	00 
  800770:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800774:	8b 55 08             	mov    0x8(%ebp),%edx
  800777:	89 14 24             	mov    %edx,(%esp)
  80077a:	e8 ff 03 00 00       	call   800b7e <printfmt>
  80077f:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800782:	e9 b3 fe ff ff       	jmp    80063a <vprintfmt+0x2a>
  800787:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80078a:	89 c3                	mov    %eax,%ebx
  80078c:	89 f1                	mov    %esi,%ecx
  80078e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800791:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800794:	8b 45 14             	mov    0x14(%ebp),%eax
  800797:	8d 50 04             	lea    0x4(%eax),%edx
  80079a:	89 55 14             	mov    %edx,0x14(%ebp)
  80079d:	8b 00                	mov    (%eax),%eax
  80079f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8007a2:	85 c0                	test   %eax,%eax
  8007a4:	75 07                	jne    8007ad <vprintfmt+0x19d>
  8007a6:	c7 45 d0 d4 12 80 00 	movl   $0x8012d4,-0x30(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  8007ad:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8007b1:	7e 06                	jle    8007b9 <vprintfmt+0x1a9>
  8007b3:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  8007b7:	75 13                	jne    8007cc <vprintfmt+0x1bc>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007b9:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8007bc:	0f be 02             	movsbl (%edx),%eax
  8007bf:	85 c0                	test   %eax,%eax
  8007c1:	0f 85 a2 00 00 00    	jne    800869 <vprintfmt+0x259>
  8007c7:	e9 8f 00 00 00       	jmp    80085b <vprintfmt+0x24b>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007cc:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007d0:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8007d3:	89 0c 24             	mov    %ecx,(%esp)
  8007d6:	e8 f0 03 00 00       	call   800bcb <strnlen>
  8007db:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8007de:	29 c2                	sub    %eax,%edx
  8007e0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007e3:	85 d2                	test   %edx,%edx
  8007e5:	7e d2                	jle    8007b9 <vprintfmt+0x1a9>
					putch(padc, putdat);
  8007e7:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  8007eb:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  8007ee:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  8007f1:	89 d3                	mov    %edx,%ebx
  8007f3:	89 ce                	mov    %ecx,%esi
  8007f5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007f9:	89 34 24             	mov    %esi,(%esp)
  8007fc:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007ff:	83 eb 01             	sub    $0x1,%ebx
  800802:	85 db                	test   %ebx,%ebx
  800804:	7f ef                	jg     8007f5 <vprintfmt+0x1e5>
  800806:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  800809:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  80080c:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800813:	eb a4                	jmp    8007b9 <vprintfmt+0x1a9>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800815:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800819:	74 1b                	je     800836 <vprintfmt+0x226>
  80081b:	8d 50 e0             	lea    -0x20(%eax),%edx
  80081e:	83 fa 5e             	cmp    $0x5e,%edx
  800821:	76 13                	jbe    800836 <vprintfmt+0x226>
					putch('?', putdat);
  800823:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800826:	89 44 24 04          	mov    %eax,0x4(%esp)
  80082a:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800831:	ff 55 08             	call   *0x8(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800834:	eb 0d                	jmp    800843 <vprintfmt+0x233>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800836:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800839:	89 54 24 04          	mov    %edx,0x4(%esp)
  80083d:	89 04 24             	mov    %eax,(%esp)
  800840:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800843:	83 ef 01             	sub    $0x1,%edi
  800846:	0f be 03             	movsbl (%ebx),%eax
  800849:	85 c0                	test   %eax,%eax
  80084b:	74 05                	je     800852 <vprintfmt+0x242>
  80084d:	83 c3 01             	add    $0x1,%ebx
  800850:	eb 28                	jmp    80087a <vprintfmt+0x26a>
  800852:	89 7d dc             	mov    %edi,-0x24(%ebp)
  800855:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800858:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80085b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80085f:	7f 2d                	jg     80088e <vprintfmt+0x27e>
  800861:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800864:	e9 d1 fd ff ff       	jmp    80063a <vprintfmt+0x2a>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800869:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80086c:	83 c1 01             	add    $0x1,%ecx
  80086f:	89 7d e0             	mov    %edi,-0x20(%ebp)
  800872:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800875:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  800878:	89 cb                	mov    %ecx,%ebx
  80087a:	85 f6                	test   %esi,%esi
  80087c:	78 97                	js     800815 <vprintfmt+0x205>
  80087e:	83 ee 01             	sub    $0x1,%esi
  800881:	79 92                	jns    800815 <vprintfmt+0x205>
  800883:	89 7d dc             	mov    %edi,-0x24(%ebp)
  800886:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800889:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  80088c:	eb cd                	jmp    80085b <vprintfmt+0x24b>
  80088e:	8b 75 08             	mov    0x8(%ebp),%esi
  800891:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800894:	8b 5d dc             	mov    -0x24(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800897:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80089b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8008a2:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8008a4:	83 eb 01             	sub    $0x1,%ebx
  8008a7:	85 db                	test   %ebx,%ebx
  8008a9:	7f ec                	jg     800897 <vprintfmt+0x287>
  8008ab:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8008ae:	e9 87 fd ff ff       	jmp    80063a <vprintfmt+0x2a>
  8008b3:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8008b6:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
  8008ba:	88 45 e4             	mov    %al,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008bd:	83 7d d0 01          	cmpl   $0x1,-0x30(%ebp)
  8008c1:	7e 16                	jle    8008d9 <vprintfmt+0x2c9>
		return va_arg(*ap, long long);
  8008c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c6:	8d 50 08             	lea    0x8(%eax),%edx
  8008c9:	89 55 14             	mov    %edx,0x14(%ebp)
  8008cc:	8b 10                	mov    (%eax),%edx
  8008ce:	8b 48 04             	mov    0x4(%eax),%ecx
  8008d1:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8008d4:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8008d7:	eb 34                	jmp    80090d <vprintfmt+0x2fd>
	else if (lflag)
  8008d9:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8008dd:	74 18                	je     8008f7 <vprintfmt+0x2e7>
		return va_arg(*ap, long);
  8008df:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e2:	8d 50 04             	lea    0x4(%eax),%edx
  8008e5:	89 55 14             	mov    %edx,0x14(%ebp)
  8008e8:	8b 00                	mov    (%eax),%eax
  8008ea:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8008ed:	89 c1                	mov    %eax,%ecx
  8008ef:	c1 f9 1f             	sar    $0x1f,%ecx
  8008f2:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8008f5:	eb 16                	jmp    80090d <vprintfmt+0x2fd>
	else
		return va_arg(*ap, int);
  8008f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8008fa:	8d 50 04             	lea    0x4(%eax),%edx
  8008fd:	89 55 14             	mov    %edx,0x14(%ebp)
  800900:	8b 00                	mov    (%eax),%eax
  800902:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800905:	89 c2                	mov    %eax,%edx
  800907:	c1 fa 1f             	sar    $0x1f,%edx
  80090a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80090d:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800910:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if ((long long) num < 0) {
  800913:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800917:	79 2c                	jns    800945 <vprintfmt+0x335>
				putch('-', putdat);
  800919:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80091d:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800924:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800927:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80092a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80092d:	f7 db                	neg    %ebx
  80092f:	83 d6 00             	adc    $0x0,%esi
  800932:	f7 de                	neg    %esi
  800934:	0f b6 4d e0          	movzbl -0x20(%ebp),%ecx
  800938:	88 4d e4             	mov    %cl,-0x1c(%ebp)
  80093b:	ba 0a 00 00 00       	mov    $0xa,%edx
  800940:	e9 db 00 00 00       	jmp    800a20 <vprintfmt+0x410>
			}
			else if (padc == '+'){
  800945:	80 7d e4 2b          	cmpb   $0x2b,-0x1c(%ebp)
  800949:	74 11                	je     80095c <vprintfmt+0x34c>
  80094b:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
  80094f:	88 45 e4             	mov    %al,-0x1c(%ebp)
  800952:	ba 0a 00 00 00       	mov    $0xa,%edx
  800957:	e9 c4 00 00 00       	jmp    800a20 <vprintfmt+0x410>
				putch('+', putdat);
  80095c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800960:	c7 04 24 2b 00 00 00 	movl   $0x2b,(%esp)
  800967:	ff 55 08             	call   *0x8(%ebp)
  80096a:	ba 0a 00 00 00       	mov    $0xa,%edx
  80096f:	e9 ac 00 00 00       	jmp    800a20 <vprintfmt+0x410>
  800974:	89 45 cc             	mov    %eax,-0x34(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800977:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80097a:	8d 45 14             	lea    0x14(%ebp),%eax
  80097d:	e8 37 fc ff ff       	call   8005b9 <getuint>
  800982:	89 c3                	mov    %eax,%ebx
  800984:	89 d6                	mov    %edx,%esi
  800986:	0f b6 55 e0          	movzbl -0x20(%ebp),%edx
  80098a:	88 55 e4             	mov    %dl,-0x1c(%ebp)
  80098d:	ba 0a 00 00 00       	mov    $0xa,%edx
			base = 10;
			goto number;
  800992:	e9 89 00 00 00       	jmp    800a20 <vprintfmt+0x410>
  800997:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) octal
		case 'o':
			putch('0', putdat);
  80099a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80099e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8009a5:	ff 55 08             	call   *0x8(%ebp)
			num = getuint(&ap, lflag);
  8009a8:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8009ab:	8d 45 14             	lea    0x14(%ebp),%eax
  8009ae:	e8 06 fc ff ff       	call   8005b9 <getuint>
  8009b3:	89 c3                	mov    %eax,%ebx
  8009b5:	89 d6                	mov    %edx,%esi
  8009b7:	0f b6 4d e0          	movzbl -0x20(%ebp),%ecx
  8009bb:	88 4d e4             	mov    %cl,-0x1c(%ebp)
  8009be:	ba 08 00 00 00       	mov    $0x8,%edx
			base = 8;
			goto number;
  8009c3:	eb 5b                	jmp    800a20 <vprintfmt+0x410>
  8009c5:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  8009c8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009cc:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8009d3:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8009d6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009da:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8009e1:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  8009e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8009e7:	8d 50 04             	lea    0x4(%eax),%edx
  8009ea:	89 55 14             	mov    %edx,0x14(%ebp)
  8009ed:	8b 18                	mov    (%eax),%ebx
  8009ef:	be 00 00 00 00       	mov    $0x0,%esi
  8009f4:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
  8009f8:	88 45 e4             	mov    %al,-0x1c(%ebp)
  8009fb:	ba 10 00 00 00       	mov    $0x10,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800a00:	eb 1e                	jmp    800a20 <vprintfmt+0x410>
  800a02:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a05:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800a08:	8d 45 14             	lea    0x14(%ebp),%eax
  800a0b:	e8 a9 fb ff ff       	call   8005b9 <getuint>
  800a10:	89 c3                	mov    %eax,%ebx
  800a12:	89 d6                	mov    %edx,%esi
  800a14:	0f b6 55 e0          	movzbl -0x20(%ebp),%edx
  800a18:	88 55 e4             	mov    %dl,-0x1c(%ebp)
  800a1b:	ba 10 00 00 00       	mov    $0x10,%edx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a20:	0f be 45 e4          	movsbl -0x1c(%ebp),%eax
  800a24:	89 44 24 10          	mov    %eax,0x10(%esp)
  800a28:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800a2b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800a2f:	89 54 24 08          	mov    %edx,0x8(%esp)
  800a33:	89 1c 24             	mov    %ebx,(%esp)
  800a36:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a3a:	89 fa                	mov    %edi,%edx
  800a3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3f:	e8 2d fa ff ff       	call   800471 <printnum>
  800a44:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  800a47:	e9 ee fb ff ff       	jmp    80063a <vprintfmt+0x2a>
  800a4c:	89 45 cc             	mov    %eax,-0x34(%ebp)
            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
	    	uint32_t *num_now = putdat;
	    	char *ret_va = va_arg(ap, char *);
  800a4f:	8b 45 14             	mov    0x14(%ebp),%eax
  800a52:	8d 50 04             	lea    0x4(%eax),%edx
  800a55:	89 55 14             	mov    %edx,0x14(%ebp)
  800a58:	8b 00                	mov    (%eax),%eax
	    	if(ret_va == NULL){
  800a5a:	85 c0                	test   %eax,%eax
  800a5c:	75 27                	jne    800a85 <vprintfmt+0x475>
				printfmt(putch, putdat, "%s", null_error);
  800a5e:	c7 44 24 0c 44 13 80 	movl   $0x801344,0xc(%esp)
  800a65:	00 
  800a66:	c7 44 24 08 d1 12 80 	movl   $0x8012d1,0x8(%esp)
  800a6d:	00 
  800a6e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a72:	8b 45 08             	mov    0x8(%ebp),%eax
  800a75:	89 04 24             	mov    %eax,(%esp)
  800a78:	e8 01 01 00 00       	call   800b7e <printfmt>
  800a7d:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800a80:	e9 b5 fb ff ff       	jmp    80063a <vprintfmt+0x2a>
	    	}
	    	else if ((*num_now) >> 7 != 0 ){		//how to aurrately discribe overflow?
  800a85:	8b 17                	mov    (%edi),%edx
  800a87:	89 d1                	mov    %edx,%ecx
  800a89:	c1 e9 07             	shr    $0x7,%ecx
  800a8c:	85 c9                	test   %ecx,%ecx
  800a8e:	74 29                	je     800ab9 <vprintfmt+0x4a9>
				*ret_va = *(num_now);	//get putdat at first as next print instruction will change ret_va as it's a pointer which means it's dynamic;
  800a90:	88 10                	mov    %dl,(%eax)
				printfmt(putch, putdat, "%s", overflow_error);
  800a92:	c7 44 24 0c 7c 13 80 	movl   $0x80137c,0xc(%esp)
  800a99:	00 
  800a9a:	c7 44 24 08 d1 12 80 	movl   $0x8012d1,0x8(%esp)
  800aa1:	00 
  800aa2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800aa6:	8b 55 08             	mov    0x8(%ebp),%edx
  800aa9:	89 14 24             	mov    %edx,(%esp)
  800aac:	e8 cd 00 00 00       	call   800b7e <printfmt>
  800ab1:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800ab4:	e9 81 fb ff ff       	jmp    80063a <vprintfmt+0x2a>
	    	}
	    	else{
				*ret_va = *(num_now);
  800ab9:	88 10                	mov    %dl,(%eax)
  800abb:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800abe:	e9 77 fb ff ff       	jmp    80063a <vprintfmt+0x2a>
  800ac3:	89 45 cc             	mov    %eax,-0x34(%ebp)
            	break;
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800ac6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800aca:	89 14 24             	mov    %edx,(%esp)
  800acd:	ff 55 08             	call   *0x8(%ebp)
  800ad0:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  800ad3:	e9 62 fb ff ff       	jmp    80063a <vprintfmt+0x2a>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800ad8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800adc:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800ae3:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800ae6:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800ae9:	80 38 25             	cmpb   $0x25,(%eax)
  800aec:	0f 84 48 fb ff ff    	je     80063a <vprintfmt+0x2a>
  800af2:	89 c3                	mov    %eax,%ebx
  800af4:	eb f0                	jmp    800ae6 <vprintfmt+0x4d6>
				/* do nothing */;
			break;
		}
	}
}
  800af6:	83 c4 5c             	add    $0x5c,%esp
  800af9:	5b                   	pop    %ebx
  800afa:	5e                   	pop    %esi
  800afb:	5f                   	pop    %edi
  800afc:	5d                   	pop    %ebp
  800afd:	c3                   	ret    

00800afe <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800afe:	55                   	push   %ebp
  800aff:	89 e5                	mov    %esp,%ebp
  800b01:	83 ec 28             	sub    $0x28,%esp
  800b04:	8b 45 08             	mov    0x8(%ebp),%eax
  800b07:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800b0a:	85 c0                	test   %eax,%eax
  800b0c:	74 04                	je     800b12 <vsnprintf+0x14>
  800b0e:	85 d2                	test   %edx,%edx
  800b10:	7f 07                	jg     800b19 <vsnprintf+0x1b>
  800b12:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b17:	eb 3b                	jmp    800b54 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b19:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b1c:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800b20:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800b23:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b2a:	8b 45 14             	mov    0x14(%ebp),%eax
  800b2d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b31:	8b 45 10             	mov    0x10(%ebp),%eax
  800b34:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b38:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b3b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b3f:	c7 04 24 f3 05 80 00 	movl   $0x8005f3,(%esp)
  800b46:	e8 c5 fa ff ff       	call   800610 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b4b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b4e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b51:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800b54:	c9                   	leave  
  800b55:	c3                   	ret    

00800b56 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b56:	55                   	push   %ebp
  800b57:	89 e5                	mov    %esp,%ebp
  800b59:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800b5c:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800b5f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b63:	8b 45 10             	mov    0x10(%ebp),%eax
  800b66:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b6a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b6d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b71:	8b 45 08             	mov    0x8(%ebp),%eax
  800b74:	89 04 24             	mov    %eax,(%esp)
  800b77:	e8 82 ff ff ff       	call   800afe <vsnprintf>
	va_end(ap);

	return rc;
}
  800b7c:	c9                   	leave  
  800b7d:	c3                   	ret    

00800b7e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800b7e:	55                   	push   %ebp
  800b7f:	89 e5                	mov    %esp,%ebp
  800b81:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800b84:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800b87:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b8b:	8b 45 10             	mov    0x10(%ebp),%eax
  800b8e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b92:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b95:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b99:	8b 45 08             	mov    0x8(%ebp),%eax
  800b9c:	89 04 24             	mov    %eax,(%esp)
  800b9f:	e8 6c fa ff ff       	call   800610 <vprintfmt>
	va_end(ap);
}
  800ba4:	c9                   	leave  
  800ba5:	c3                   	ret    
	...

00800bb0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800bb0:	55                   	push   %ebp
  800bb1:	89 e5                	mov    %esp,%ebp
  800bb3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800bb6:	b8 00 00 00 00       	mov    $0x0,%eax
  800bbb:	80 3a 00             	cmpb   $0x0,(%edx)
  800bbe:	74 09                	je     800bc9 <strlen+0x19>
		n++;
  800bc0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800bc3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800bc7:	75 f7                	jne    800bc0 <strlen+0x10>
		n++;
	return n;
}
  800bc9:	5d                   	pop    %ebp
  800bca:	c3                   	ret    

00800bcb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800bcb:	55                   	push   %ebp
  800bcc:	89 e5                	mov    %esp,%ebp
  800bce:	53                   	push   %ebx
  800bcf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800bd2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800bd5:	85 c9                	test   %ecx,%ecx
  800bd7:	74 19                	je     800bf2 <strnlen+0x27>
  800bd9:	80 3b 00             	cmpb   $0x0,(%ebx)
  800bdc:	74 14                	je     800bf2 <strnlen+0x27>
  800bde:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800be3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800be6:	39 c8                	cmp    %ecx,%eax
  800be8:	74 0d                	je     800bf7 <strnlen+0x2c>
  800bea:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800bee:	75 f3                	jne    800be3 <strnlen+0x18>
  800bf0:	eb 05                	jmp    800bf7 <strnlen+0x2c>
  800bf2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800bf7:	5b                   	pop    %ebx
  800bf8:	5d                   	pop    %ebp
  800bf9:	c3                   	ret    

00800bfa <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800bfa:	55                   	push   %ebp
  800bfb:	89 e5                	mov    %esp,%ebp
  800bfd:	53                   	push   %ebx
  800bfe:	8b 45 08             	mov    0x8(%ebp),%eax
  800c01:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c04:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800c09:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800c0d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800c10:	83 c2 01             	add    $0x1,%edx
  800c13:	84 c9                	test   %cl,%cl
  800c15:	75 f2                	jne    800c09 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800c17:	5b                   	pop    %ebx
  800c18:	5d                   	pop    %ebp
  800c19:	c3                   	ret    

00800c1a <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c1a:	55                   	push   %ebp
  800c1b:	89 e5                	mov    %esp,%ebp
  800c1d:	53                   	push   %ebx
  800c1e:	83 ec 08             	sub    $0x8,%esp
  800c21:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800c24:	89 1c 24             	mov    %ebx,(%esp)
  800c27:	e8 84 ff ff ff       	call   800bb0 <strlen>
	strcpy(dst + len, src);
  800c2c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c2f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c33:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800c36:	89 04 24             	mov    %eax,(%esp)
  800c39:	e8 bc ff ff ff       	call   800bfa <strcpy>
	return dst;
}
  800c3e:	89 d8                	mov    %ebx,%eax
  800c40:	83 c4 08             	add    $0x8,%esp
  800c43:	5b                   	pop    %ebx
  800c44:	5d                   	pop    %ebp
  800c45:	c3                   	ret    

00800c46 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c46:	55                   	push   %ebp
  800c47:	89 e5                	mov    %esp,%ebp
  800c49:	56                   	push   %esi
  800c4a:	53                   	push   %ebx
  800c4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c4e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c51:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c54:	85 f6                	test   %esi,%esi
  800c56:	74 18                	je     800c70 <strncpy+0x2a>
  800c58:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800c5d:	0f b6 1a             	movzbl (%edx),%ebx
  800c60:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800c63:	80 3a 01             	cmpb   $0x1,(%edx)
  800c66:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c69:	83 c1 01             	add    $0x1,%ecx
  800c6c:	39 ce                	cmp    %ecx,%esi
  800c6e:	77 ed                	ja     800c5d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800c70:	5b                   	pop    %ebx
  800c71:	5e                   	pop    %esi
  800c72:	5d                   	pop    %ebp
  800c73:	c3                   	ret    

00800c74 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800c74:	55                   	push   %ebp
  800c75:	89 e5                	mov    %esp,%ebp
  800c77:	56                   	push   %esi
  800c78:	53                   	push   %ebx
  800c79:	8b 75 08             	mov    0x8(%ebp),%esi
  800c7c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c7f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c82:	89 f0                	mov    %esi,%eax
  800c84:	85 c9                	test   %ecx,%ecx
  800c86:	74 27                	je     800caf <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800c88:	83 e9 01             	sub    $0x1,%ecx
  800c8b:	74 1d                	je     800caa <strlcpy+0x36>
  800c8d:	0f b6 1a             	movzbl (%edx),%ebx
  800c90:	84 db                	test   %bl,%bl
  800c92:	74 16                	je     800caa <strlcpy+0x36>
			*dst++ = *src++;
  800c94:	88 18                	mov    %bl,(%eax)
  800c96:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c99:	83 e9 01             	sub    $0x1,%ecx
  800c9c:	74 0e                	je     800cac <strlcpy+0x38>
			*dst++ = *src++;
  800c9e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ca1:	0f b6 1a             	movzbl (%edx),%ebx
  800ca4:	84 db                	test   %bl,%bl
  800ca6:	75 ec                	jne    800c94 <strlcpy+0x20>
  800ca8:	eb 02                	jmp    800cac <strlcpy+0x38>
  800caa:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800cac:	c6 00 00             	movb   $0x0,(%eax)
  800caf:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800cb1:	5b                   	pop    %ebx
  800cb2:	5e                   	pop    %esi
  800cb3:	5d                   	pop    %ebp
  800cb4:	c3                   	ret    

00800cb5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800cb5:	55                   	push   %ebp
  800cb6:	89 e5                	mov    %esp,%ebp
  800cb8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cbb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800cbe:	0f b6 01             	movzbl (%ecx),%eax
  800cc1:	84 c0                	test   %al,%al
  800cc3:	74 15                	je     800cda <strcmp+0x25>
  800cc5:	3a 02                	cmp    (%edx),%al
  800cc7:	75 11                	jne    800cda <strcmp+0x25>
		p++, q++;
  800cc9:	83 c1 01             	add    $0x1,%ecx
  800ccc:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800ccf:	0f b6 01             	movzbl (%ecx),%eax
  800cd2:	84 c0                	test   %al,%al
  800cd4:	74 04                	je     800cda <strcmp+0x25>
  800cd6:	3a 02                	cmp    (%edx),%al
  800cd8:	74 ef                	je     800cc9 <strcmp+0x14>
  800cda:	0f b6 c0             	movzbl %al,%eax
  800cdd:	0f b6 12             	movzbl (%edx),%edx
  800ce0:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ce2:	5d                   	pop    %ebp
  800ce3:	c3                   	ret    

00800ce4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ce4:	55                   	push   %ebp
  800ce5:	89 e5                	mov    %esp,%ebp
  800ce7:	53                   	push   %ebx
  800ce8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ceb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cee:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800cf1:	85 c0                	test   %eax,%eax
  800cf3:	74 23                	je     800d18 <strncmp+0x34>
  800cf5:	0f b6 1a             	movzbl (%edx),%ebx
  800cf8:	84 db                	test   %bl,%bl
  800cfa:	74 25                	je     800d21 <strncmp+0x3d>
  800cfc:	3a 19                	cmp    (%ecx),%bl
  800cfe:	75 21                	jne    800d21 <strncmp+0x3d>
  800d00:	83 e8 01             	sub    $0x1,%eax
  800d03:	74 13                	je     800d18 <strncmp+0x34>
		n--, p++, q++;
  800d05:	83 c2 01             	add    $0x1,%edx
  800d08:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d0b:	0f b6 1a             	movzbl (%edx),%ebx
  800d0e:	84 db                	test   %bl,%bl
  800d10:	74 0f                	je     800d21 <strncmp+0x3d>
  800d12:	3a 19                	cmp    (%ecx),%bl
  800d14:	74 ea                	je     800d00 <strncmp+0x1c>
  800d16:	eb 09                	jmp    800d21 <strncmp+0x3d>
  800d18:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800d1d:	5b                   	pop    %ebx
  800d1e:	5d                   	pop    %ebp
  800d1f:	90                   	nop
  800d20:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800d21:	0f b6 02             	movzbl (%edx),%eax
  800d24:	0f b6 11             	movzbl (%ecx),%edx
  800d27:	29 d0                	sub    %edx,%eax
  800d29:	eb f2                	jmp    800d1d <strncmp+0x39>

00800d2b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800d2b:	55                   	push   %ebp
  800d2c:	89 e5                	mov    %esp,%ebp
  800d2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d31:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d35:	0f b6 10             	movzbl (%eax),%edx
  800d38:	84 d2                	test   %dl,%dl
  800d3a:	74 18                	je     800d54 <strchr+0x29>
		if (*s == c)
  800d3c:	38 ca                	cmp    %cl,%dl
  800d3e:	75 0a                	jne    800d4a <strchr+0x1f>
  800d40:	eb 17                	jmp    800d59 <strchr+0x2e>
  800d42:	38 ca                	cmp    %cl,%dl
  800d44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d48:	74 0f                	je     800d59 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800d4a:	83 c0 01             	add    $0x1,%eax
  800d4d:	0f b6 10             	movzbl (%eax),%edx
  800d50:	84 d2                	test   %dl,%dl
  800d52:	75 ee                	jne    800d42 <strchr+0x17>
  800d54:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800d59:	5d                   	pop    %ebp
  800d5a:	c3                   	ret    

00800d5b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800d5b:	55                   	push   %ebp
  800d5c:	89 e5                	mov    %esp,%ebp
  800d5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d61:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d65:	0f b6 10             	movzbl (%eax),%edx
  800d68:	84 d2                	test   %dl,%dl
  800d6a:	74 18                	je     800d84 <strfind+0x29>
		if (*s == c)
  800d6c:	38 ca                	cmp    %cl,%dl
  800d6e:	75 0a                	jne    800d7a <strfind+0x1f>
  800d70:	eb 12                	jmp    800d84 <strfind+0x29>
  800d72:	38 ca                	cmp    %cl,%dl
  800d74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d78:	74 0a                	je     800d84 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800d7a:	83 c0 01             	add    $0x1,%eax
  800d7d:	0f b6 10             	movzbl (%eax),%edx
  800d80:	84 d2                	test   %dl,%dl
  800d82:	75 ee                	jne    800d72 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800d84:	5d                   	pop    %ebp
  800d85:	c3                   	ret    

00800d86 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d86:	55                   	push   %ebp
  800d87:	89 e5                	mov    %esp,%ebp
  800d89:	83 ec 0c             	sub    $0xc,%esp
  800d8c:	89 1c 24             	mov    %ebx,(%esp)
  800d8f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d93:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800d97:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d9a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d9d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800da0:	85 c9                	test   %ecx,%ecx
  800da2:	74 30                	je     800dd4 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800da4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800daa:	75 25                	jne    800dd1 <memset+0x4b>
  800dac:	f6 c1 03             	test   $0x3,%cl
  800daf:	75 20                	jne    800dd1 <memset+0x4b>
		c &= 0xFF;
  800db1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800db4:	89 d3                	mov    %edx,%ebx
  800db6:	c1 e3 08             	shl    $0x8,%ebx
  800db9:	89 d6                	mov    %edx,%esi
  800dbb:	c1 e6 18             	shl    $0x18,%esi
  800dbe:	89 d0                	mov    %edx,%eax
  800dc0:	c1 e0 10             	shl    $0x10,%eax
  800dc3:	09 f0                	or     %esi,%eax
  800dc5:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800dc7:	09 d8                	or     %ebx,%eax
  800dc9:	c1 e9 02             	shr    $0x2,%ecx
  800dcc:	fc                   	cld    
  800dcd:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800dcf:	eb 03                	jmp    800dd4 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800dd1:	fc                   	cld    
  800dd2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800dd4:	89 f8                	mov    %edi,%eax
  800dd6:	8b 1c 24             	mov    (%esp),%ebx
  800dd9:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ddd:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800de1:	89 ec                	mov    %ebp,%esp
  800de3:	5d                   	pop    %ebp
  800de4:	c3                   	ret    

00800de5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800de5:	55                   	push   %ebp
  800de6:	89 e5                	mov    %esp,%ebp
  800de8:	83 ec 08             	sub    $0x8,%esp
  800deb:	89 34 24             	mov    %esi,(%esp)
  800dee:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800df2:	8b 45 08             	mov    0x8(%ebp),%eax
  800df5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800df8:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800dfb:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800dfd:	39 c6                	cmp    %eax,%esi
  800dff:	73 35                	jae    800e36 <memmove+0x51>
  800e01:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800e04:	39 d0                	cmp    %edx,%eax
  800e06:	73 2e                	jae    800e36 <memmove+0x51>
		s += n;
		d += n;
  800e08:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e0a:	f6 c2 03             	test   $0x3,%dl
  800e0d:	75 1b                	jne    800e2a <memmove+0x45>
  800e0f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e15:	75 13                	jne    800e2a <memmove+0x45>
  800e17:	f6 c1 03             	test   $0x3,%cl
  800e1a:	75 0e                	jne    800e2a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800e1c:	83 ef 04             	sub    $0x4,%edi
  800e1f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800e22:	c1 e9 02             	shr    $0x2,%ecx
  800e25:	fd                   	std    
  800e26:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e28:	eb 09                	jmp    800e33 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800e2a:	83 ef 01             	sub    $0x1,%edi
  800e2d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800e30:	fd                   	std    
  800e31:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800e33:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800e34:	eb 20                	jmp    800e56 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e36:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e3c:	75 15                	jne    800e53 <memmove+0x6e>
  800e3e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e44:	75 0d                	jne    800e53 <memmove+0x6e>
  800e46:	f6 c1 03             	test   $0x3,%cl
  800e49:	75 08                	jne    800e53 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800e4b:	c1 e9 02             	shr    $0x2,%ecx
  800e4e:	fc                   	cld    
  800e4f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e51:	eb 03                	jmp    800e56 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800e53:	fc                   	cld    
  800e54:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800e56:	8b 34 24             	mov    (%esp),%esi
  800e59:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e5d:	89 ec                	mov    %ebp,%esp
  800e5f:	5d                   	pop    %ebp
  800e60:	c3                   	ret    

00800e61 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800e61:	55                   	push   %ebp
  800e62:	89 e5                	mov    %esp,%ebp
  800e64:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800e67:	8b 45 10             	mov    0x10(%ebp),%eax
  800e6a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e6e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e71:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e75:	8b 45 08             	mov    0x8(%ebp),%eax
  800e78:	89 04 24             	mov    %eax,(%esp)
  800e7b:	e8 65 ff ff ff       	call   800de5 <memmove>
}
  800e80:	c9                   	leave  
  800e81:	c3                   	ret    

00800e82 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e82:	55                   	push   %ebp
  800e83:	89 e5                	mov    %esp,%ebp
  800e85:	57                   	push   %edi
  800e86:	56                   	push   %esi
  800e87:	53                   	push   %ebx
  800e88:	8b 75 08             	mov    0x8(%ebp),%esi
  800e8b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800e8e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e91:	85 c9                	test   %ecx,%ecx
  800e93:	74 36                	je     800ecb <memcmp+0x49>
		if (*s1 != *s2)
  800e95:	0f b6 06             	movzbl (%esi),%eax
  800e98:	0f b6 1f             	movzbl (%edi),%ebx
  800e9b:	38 d8                	cmp    %bl,%al
  800e9d:	74 20                	je     800ebf <memcmp+0x3d>
  800e9f:	eb 14                	jmp    800eb5 <memcmp+0x33>
  800ea1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800ea6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800eab:	83 c2 01             	add    $0x1,%edx
  800eae:	83 e9 01             	sub    $0x1,%ecx
  800eb1:	38 d8                	cmp    %bl,%al
  800eb3:	74 12                	je     800ec7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800eb5:	0f b6 c0             	movzbl %al,%eax
  800eb8:	0f b6 db             	movzbl %bl,%ebx
  800ebb:	29 d8                	sub    %ebx,%eax
  800ebd:	eb 11                	jmp    800ed0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ebf:	83 e9 01             	sub    $0x1,%ecx
  800ec2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ec7:	85 c9                	test   %ecx,%ecx
  800ec9:	75 d6                	jne    800ea1 <memcmp+0x1f>
  800ecb:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800ed0:	5b                   	pop    %ebx
  800ed1:	5e                   	pop    %esi
  800ed2:	5f                   	pop    %edi
  800ed3:	5d                   	pop    %ebp
  800ed4:	c3                   	ret    

00800ed5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ed5:	55                   	push   %ebp
  800ed6:	89 e5                	mov    %esp,%ebp
  800ed8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800edb:	89 c2                	mov    %eax,%edx
  800edd:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ee0:	39 d0                	cmp    %edx,%eax
  800ee2:	73 15                	jae    800ef9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ee4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800ee8:	38 08                	cmp    %cl,(%eax)
  800eea:	75 06                	jne    800ef2 <memfind+0x1d>
  800eec:	eb 0b                	jmp    800ef9 <memfind+0x24>
  800eee:	38 08                	cmp    %cl,(%eax)
  800ef0:	74 07                	je     800ef9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ef2:	83 c0 01             	add    $0x1,%eax
  800ef5:	39 c2                	cmp    %eax,%edx
  800ef7:	77 f5                	ja     800eee <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ef9:	5d                   	pop    %ebp
  800efa:	c3                   	ret    

00800efb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800efb:	55                   	push   %ebp
  800efc:	89 e5                	mov    %esp,%ebp
  800efe:	57                   	push   %edi
  800eff:	56                   	push   %esi
  800f00:	53                   	push   %ebx
  800f01:	83 ec 04             	sub    $0x4,%esp
  800f04:	8b 55 08             	mov    0x8(%ebp),%edx
  800f07:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f0a:	0f b6 02             	movzbl (%edx),%eax
  800f0d:	3c 20                	cmp    $0x20,%al
  800f0f:	74 04                	je     800f15 <strtol+0x1a>
  800f11:	3c 09                	cmp    $0x9,%al
  800f13:	75 0e                	jne    800f23 <strtol+0x28>
		s++;
  800f15:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f18:	0f b6 02             	movzbl (%edx),%eax
  800f1b:	3c 20                	cmp    $0x20,%al
  800f1d:	74 f6                	je     800f15 <strtol+0x1a>
  800f1f:	3c 09                	cmp    $0x9,%al
  800f21:	74 f2                	je     800f15 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800f23:	3c 2b                	cmp    $0x2b,%al
  800f25:	75 0c                	jne    800f33 <strtol+0x38>
		s++;
  800f27:	83 c2 01             	add    $0x1,%edx
  800f2a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800f31:	eb 15                	jmp    800f48 <strtol+0x4d>
	else if (*s == '-')
  800f33:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800f3a:	3c 2d                	cmp    $0x2d,%al
  800f3c:	75 0a                	jne    800f48 <strtol+0x4d>
		s++, neg = 1;
  800f3e:	83 c2 01             	add    $0x1,%edx
  800f41:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f48:	85 db                	test   %ebx,%ebx
  800f4a:	0f 94 c0             	sete   %al
  800f4d:	74 05                	je     800f54 <strtol+0x59>
  800f4f:	83 fb 10             	cmp    $0x10,%ebx
  800f52:	75 18                	jne    800f6c <strtol+0x71>
  800f54:	80 3a 30             	cmpb   $0x30,(%edx)
  800f57:	75 13                	jne    800f6c <strtol+0x71>
  800f59:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800f5d:	8d 76 00             	lea    0x0(%esi),%esi
  800f60:	75 0a                	jne    800f6c <strtol+0x71>
		s += 2, base = 16;
  800f62:	83 c2 02             	add    $0x2,%edx
  800f65:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f6a:	eb 15                	jmp    800f81 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f6c:	84 c0                	test   %al,%al
  800f6e:	66 90                	xchg   %ax,%ax
  800f70:	74 0f                	je     800f81 <strtol+0x86>
  800f72:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800f77:	80 3a 30             	cmpb   $0x30,(%edx)
  800f7a:	75 05                	jne    800f81 <strtol+0x86>
		s++, base = 8;
  800f7c:	83 c2 01             	add    $0x1,%edx
  800f7f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f81:	b8 00 00 00 00       	mov    $0x0,%eax
  800f86:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f88:	0f b6 0a             	movzbl (%edx),%ecx
  800f8b:	89 cf                	mov    %ecx,%edi
  800f8d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800f90:	80 fb 09             	cmp    $0x9,%bl
  800f93:	77 08                	ja     800f9d <strtol+0xa2>
			dig = *s - '0';
  800f95:	0f be c9             	movsbl %cl,%ecx
  800f98:	83 e9 30             	sub    $0x30,%ecx
  800f9b:	eb 1e                	jmp    800fbb <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800f9d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800fa0:	80 fb 19             	cmp    $0x19,%bl
  800fa3:	77 08                	ja     800fad <strtol+0xb2>
			dig = *s - 'a' + 10;
  800fa5:	0f be c9             	movsbl %cl,%ecx
  800fa8:	83 e9 57             	sub    $0x57,%ecx
  800fab:	eb 0e                	jmp    800fbb <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800fad:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800fb0:	80 fb 19             	cmp    $0x19,%bl
  800fb3:	77 15                	ja     800fca <strtol+0xcf>
			dig = *s - 'A' + 10;
  800fb5:	0f be c9             	movsbl %cl,%ecx
  800fb8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800fbb:	39 f1                	cmp    %esi,%ecx
  800fbd:	7d 0b                	jge    800fca <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800fbf:	83 c2 01             	add    $0x1,%edx
  800fc2:	0f af c6             	imul   %esi,%eax
  800fc5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800fc8:	eb be                	jmp    800f88 <strtol+0x8d>
  800fca:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800fcc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800fd0:	74 05                	je     800fd7 <strtol+0xdc>
		*endptr = (char *) s;
  800fd2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800fd5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800fd7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800fdb:	74 04                	je     800fe1 <strtol+0xe6>
  800fdd:	89 c8                	mov    %ecx,%eax
  800fdf:	f7 d8                	neg    %eax
}
  800fe1:	83 c4 04             	add    $0x4,%esp
  800fe4:	5b                   	pop    %ebx
  800fe5:	5e                   	pop    %esi
  800fe6:	5f                   	pop    %edi
  800fe7:	5d                   	pop    %ebp
  800fe8:	c3                   	ret    
  800fe9:	00 00                	add    %al,(%eax)
  800feb:	00 00                	add    %al,(%eax)
  800fed:	00 00                	add    %al,(%eax)
	...

00800ff0 <__udivdi3>:
  800ff0:	55                   	push   %ebp
  800ff1:	89 e5                	mov    %esp,%ebp
  800ff3:	57                   	push   %edi
  800ff4:	56                   	push   %esi
  800ff5:	83 ec 10             	sub    $0x10,%esp
  800ff8:	8b 45 14             	mov    0x14(%ebp),%eax
  800ffb:	8b 55 08             	mov    0x8(%ebp),%edx
  800ffe:	8b 75 10             	mov    0x10(%ebp),%esi
  801001:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801004:	85 c0                	test   %eax,%eax
  801006:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801009:	75 35                	jne    801040 <__udivdi3+0x50>
  80100b:	39 fe                	cmp    %edi,%esi
  80100d:	77 61                	ja     801070 <__udivdi3+0x80>
  80100f:	85 f6                	test   %esi,%esi
  801011:	75 0b                	jne    80101e <__udivdi3+0x2e>
  801013:	b8 01 00 00 00       	mov    $0x1,%eax
  801018:	31 d2                	xor    %edx,%edx
  80101a:	f7 f6                	div    %esi
  80101c:	89 c6                	mov    %eax,%esi
  80101e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801021:	31 d2                	xor    %edx,%edx
  801023:	89 f8                	mov    %edi,%eax
  801025:	f7 f6                	div    %esi
  801027:	89 c7                	mov    %eax,%edi
  801029:	89 c8                	mov    %ecx,%eax
  80102b:	f7 f6                	div    %esi
  80102d:	89 c1                	mov    %eax,%ecx
  80102f:	89 fa                	mov    %edi,%edx
  801031:	89 c8                	mov    %ecx,%eax
  801033:	83 c4 10             	add    $0x10,%esp
  801036:	5e                   	pop    %esi
  801037:	5f                   	pop    %edi
  801038:	5d                   	pop    %ebp
  801039:	c3                   	ret    
  80103a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801040:	39 f8                	cmp    %edi,%eax
  801042:	77 1c                	ja     801060 <__udivdi3+0x70>
  801044:	0f bd d0             	bsr    %eax,%edx
  801047:	83 f2 1f             	xor    $0x1f,%edx
  80104a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80104d:	75 39                	jne    801088 <__udivdi3+0x98>
  80104f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801052:	0f 86 a0 00 00 00    	jbe    8010f8 <__udivdi3+0x108>
  801058:	39 f8                	cmp    %edi,%eax
  80105a:	0f 82 98 00 00 00    	jb     8010f8 <__udivdi3+0x108>
  801060:	31 ff                	xor    %edi,%edi
  801062:	31 c9                	xor    %ecx,%ecx
  801064:	89 c8                	mov    %ecx,%eax
  801066:	89 fa                	mov    %edi,%edx
  801068:	83 c4 10             	add    $0x10,%esp
  80106b:	5e                   	pop    %esi
  80106c:	5f                   	pop    %edi
  80106d:	5d                   	pop    %ebp
  80106e:	c3                   	ret    
  80106f:	90                   	nop
  801070:	89 d1                	mov    %edx,%ecx
  801072:	89 fa                	mov    %edi,%edx
  801074:	89 c8                	mov    %ecx,%eax
  801076:	31 ff                	xor    %edi,%edi
  801078:	f7 f6                	div    %esi
  80107a:	89 c1                	mov    %eax,%ecx
  80107c:	89 fa                	mov    %edi,%edx
  80107e:	89 c8                	mov    %ecx,%eax
  801080:	83 c4 10             	add    $0x10,%esp
  801083:	5e                   	pop    %esi
  801084:	5f                   	pop    %edi
  801085:	5d                   	pop    %ebp
  801086:	c3                   	ret    
  801087:	90                   	nop
  801088:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80108c:	89 f2                	mov    %esi,%edx
  80108e:	d3 e0                	shl    %cl,%eax
  801090:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801093:	b8 20 00 00 00       	mov    $0x20,%eax
  801098:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80109b:	89 c1                	mov    %eax,%ecx
  80109d:	d3 ea                	shr    %cl,%edx
  80109f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8010a3:	0b 55 ec             	or     -0x14(%ebp),%edx
  8010a6:	d3 e6                	shl    %cl,%esi
  8010a8:	89 c1                	mov    %eax,%ecx
  8010aa:	89 75 e8             	mov    %esi,-0x18(%ebp)
  8010ad:	89 fe                	mov    %edi,%esi
  8010af:	d3 ee                	shr    %cl,%esi
  8010b1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8010b5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8010b8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010bb:	d3 e7                	shl    %cl,%edi
  8010bd:	89 c1                	mov    %eax,%ecx
  8010bf:	d3 ea                	shr    %cl,%edx
  8010c1:	09 d7                	or     %edx,%edi
  8010c3:	89 f2                	mov    %esi,%edx
  8010c5:	89 f8                	mov    %edi,%eax
  8010c7:	f7 75 ec             	divl   -0x14(%ebp)
  8010ca:	89 d6                	mov    %edx,%esi
  8010cc:	89 c7                	mov    %eax,%edi
  8010ce:	f7 65 e8             	mull   -0x18(%ebp)
  8010d1:	39 d6                	cmp    %edx,%esi
  8010d3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8010d6:	72 30                	jb     801108 <__udivdi3+0x118>
  8010d8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010db:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8010df:	d3 e2                	shl    %cl,%edx
  8010e1:	39 c2                	cmp    %eax,%edx
  8010e3:	73 05                	jae    8010ea <__udivdi3+0xfa>
  8010e5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  8010e8:	74 1e                	je     801108 <__udivdi3+0x118>
  8010ea:	89 f9                	mov    %edi,%ecx
  8010ec:	31 ff                	xor    %edi,%edi
  8010ee:	e9 71 ff ff ff       	jmp    801064 <__udivdi3+0x74>
  8010f3:	90                   	nop
  8010f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010f8:	31 ff                	xor    %edi,%edi
  8010fa:	b9 01 00 00 00       	mov    $0x1,%ecx
  8010ff:	e9 60 ff ff ff       	jmp    801064 <__udivdi3+0x74>
  801104:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801108:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80110b:	31 ff                	xor    %edi,%edi
  80110d:	89 c8                	mov    %ecx,%eax
  80110f:	89 fa                	mov    %edi,%edx
  801111:	83 c4 10             	add    $0x10,%esp
  801114:	5e                   	pop    %esi
  801115:	5f                   	pop    %edi
  801116:	5d                   	pop    %ebp
  801117:	c3                   	ret    
	...

00801120 <__umoddi3>:
  801120:	55                   	push   %ebp
  801121:	89 e5                	mov    %esp,%ebp
  801123:	57                   	push   %edi
  801124:	56                   	push   %esi
  801125:	83 ec 20             	sub    $0x20,%esp
  801128:	8b 55 14             	mov    0x14(%ebp),%edx
  80112b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80112e:	8b 7d 10             	mov    0x10(%ebp),%edi
  801131:	8b 75 0c             	mov    0xc(%ebp),%esi
  801134:	85 d2                	test   %edx,%edx
  801136:	89 c8                	mov    %ecx,%eax
  801138:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80113b:	75 13                	jne    801150 <__umoddi3+0x30>
  80113d:	39 f7                	cmp    %esi,%edi
  80113f:	76 3f                	jbe    801180 <__umoddi3+0x60>
  801141:	89 f2                	mov    %esi,%edx
  801143:	f7 f7                	div    %edi
  801145:	89 d0                	mov    %edx,%eax
  801147:	31 d2                	xor    %edx,%edx
  801149:	83 c4 20             	add    $0x20,%esp
  80114c:	5e                   	pop    %esi
  80114d:	5f                   	pop    %edi
  80114e:	5d                   	pop    %ebp
  80114f:	c3                   	ret    
  801150:	39 f2                	cmp    %esi,%edx
  801152:	77 4c                	ja     8011a0 <__umoddi3+0x80>
  801154:	0f bd ca             	bsr    %edx,%ecx
  801157:	83 f1 1f             	xor    $0x1f,%ecx
  80115a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80115d:	75 51                	jne    8011b0 <__umoddi3+0x90>
  80115f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801162:	0f 87 e0 00 00 00    	ja     801248 <__umoddi3+0x128>
  801168:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80116b:	29 f8                	sub    %edi,%eax
  80116d:	19 d6                	sbb    %edx,%esi
  80116f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801172:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801175:	89 f2                	mov    %esi,%edx
  801177:	83 c4 20             	add    $0x20,%esp
  80117a:	5e                   	pop    %esi
  80117b:	5f                   	pop    %edi
  80117c:	5d                   	pop    %ebp
  80117d:	c3                   	ret    
  80117e:	66 90                	xchg   %ax,%ax
  801180:	85 ff                	test   %edi,%edi
  801182:	75 0b                	jne    80118f <__umoddi3+0x6f>
  801184:	b8 01 00 00 00       	mov    $0x1,%eax
  801189:	31 d2                	xor    %edx,%edx
  80118b:	f7 f7                	div    %edi
  80118d:	89 c7                	mov    %eax,%edi
  80118f:	89 f0                	mov    %esi,%eax
  801191:	31 d2                	xor    %edx,%edx
  801193:	f7 f7                	div    %edi
  801195:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801198:	f7 f7                	div    %edi
  80119a:	eb a9                	jmp    801145 <__umoddi3+0x25>
  80119c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011a0:	89 c8                	mov    %ecx,%eax
  8011a2:	89 f2                	mov    %esi,%edx
  8011a4:	83 c4 20             	add    $0x20,%esp
  8011a7:	5e                   	pop    %esi
  8011a8:	5f                   	pop    %edi
  8011a9:	5d                   	pop    %ebp
  8011aa:	c3                   	ret    
  8011ab:	90                   	nop
  8011ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011b0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011b4:	d3 e2                	shl    %cl,%edx
  8011b6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8011b9:	ba 20 00 00 00       	mov    $0x20,%edx
  8011be:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8011c1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8011c4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8011c8:	89 fa                	mov    %edi,%edx
  8011ca:	d3 ea                	shr    %cl,%edx
  8011cc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011d0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8011d3:	d3 e7                	shl    %cl,%edi
  8011d5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8011d9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8011dc:	89 f2                	mov    %esi,%edx
  8011de:	89 7d e8             	mov    %edi,-0x18(%ebp)
  8011e1:	89 c7                	mov    %eax,%edi
  8011e3:	d3 ea                	shr    %cl,%edx
  8011e5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011e9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8011ec:	89 c2                	mov    %eax,%edx
  8011ee:	d3 e6                	shl    %cl,%esi
  8011f0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8011f4:	d3 ea                	shr    %cl,%edx
  8011f6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011fa:	09 d6                	or     %edx,%esi
  8011fc:	89 f0                	mov    %esi,%eax
  8011fe:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801201:	d3 e7                	shl    %cl,%edi
  801203:	89 f2                	mov    %esi,%edx
  801205:	f7 75 f4             	divl   -0xc(%ebp)
  801208:	89 d6                	mov    %edx,%esi
  80120a:	f7 65 e8             	mull   -0x18(%ebp)
  80120d:	39 d6                	cmp    %edx,%esi
  80120f:	72 2b                	jb     80123c <__umoddi3+0x11c>
  801211:	39 c7                	cmp    %eax,%edi
  801213:	72 23                	jb     801238 <__umoddi3+0x118>
  801215:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801219:	29 c7                	sub    %eax,%edi
  80121b:	19 d6                	sbb    %edx,%esi
  80121d:	89 f0                	mov    %esi,%eax
  80121f:	89 f2                	mov    %esi,%edx
  801221:	d3 ef                	shr    %cl,%edi
  801223:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801227:	d3 e0                	shl    %cl,%eax
  801229:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80122d:	09 f8                	or     %edi,%eax
  80122f:	d3 ea                	shr    %cl,%edx
  801231:	83 c4 20             	add    $0x20,%esp
  801234:	5e                   	pop    %esi
  801235:	5f                   	pop    %edi
  801236:	5d                   	pop    %ebp
  801237:	c3                   	ret    
  801238:	39 d6                	cmp    %edx,%esi
  80123a:	75 d9                	jne    801215 <__umoddi3+0xf5>
  80123c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80123f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801242:	eb d1                	jmp    801215 <__umoddi3+0xf5>
  801244:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801248:	39 f2                	cmp    %esi,%edx
  80124a:	0f 82 18 ff ff ff    	jb     801168 <__umoddi3+0x48>
  801250:	e9 1d ff ff ff       	jmp    801172 <__umoddi3+0x52>
