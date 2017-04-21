
obj/user/softint:     file format elf32-i386


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
  80002c:	e8 0b 00 00 00       	call   80003c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
	asm volatile("int $14");	// page fault
  800037:	cd 0e                	int    $0xe
}
  800039:	5d                   	pop    %ebp
  80003a:	c3                   	ret    
	...

0080003c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003c:	55                   	push   %ebp
  80003d:	89 e5                	mov    %esp,%ebp
  80003f:	83 ec 18             	sub    $0x18,%esp
  800042:	8b 45 08             	mov    0x8(%ebp),%eax
  800045:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800048:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  80004f:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800052:	85 c0                	test   %eax,%eax
  800054:	7e 08                	jle    80005e <libmain+0x22>
		binaryname = argv[0];
  800056:	8b 0a                	mov    (%edx),%ecx
  800058:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  80005e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800062:	89 04 24             	mov    %eax,(%esp)
  800065:	e8 ca ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80006a:	e8 05 00 00 00       	call   800074 <exit>
}
  80006f:	c9                   	leave  
  800070:	c3                   	ret    
  800071:	00 00                	add    %al,(%eax)
	...

00800074 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800074:	55                   	push   %ebp
  800075:	89 e5                	mov    %esp,%ebp
  800077:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80007a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800081:	e8 12 01 00 00       	call   800198 <sys_env_destroy>
}
  800086:	c9                   	leave  
  800087:	c3                   	ret    

00800088 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800088:	55                   	push   %ebp
  800089:	89 e5                	mov    %esp,%ebp
  80008b:	83 ec 08             	sub    $0x8,%esp
  80008e:	89 1c 24             	mov    %ebx,(%esp)
  800091:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800095:	b8 00 00 00 00       	mov    $0x0,%eax
  80009a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80009d:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a0:	89 c3                	mov    %eax,%ebx
  8000a2:	89 c7                	mov    %eax,%edi
  8000a4:	51                   	push   %ecx
  8000a5:	52                   	push   %edx
  8000a6:	53                   	push   %ebx
  8000a7:	54                   	push   %esp
  8000a8:	55                   	push   %ebp
  8000a9:	56                   	push   %esi
  8000aa:	57                   	push   %edi
  8000ab:	5f                   	pop    %edi
  8000ac:	5e                   	pop    %esi
  8000ad:	5d                   	pop    %ebp
  8000ae:	5c                   	pop    %esp
  8000af:	5b                   	pop    %ebx
  8000b0:	5a                   	pop    %edx
  8000b1:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b2:	8b 1c 24             	mov    (%esp),%ebx
  8000b5:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8000b9:	89 ec                	mov    %ebp,%esp
  8000bb:	5d                   	pop    %ebp
  8000bc:	c3                   	ret    

008000bd <sys_cgetc>:

int
sys_cgetc(void)
{
  8000bd:	55                   	push   %ebp
  8000be:	89 e5                	mov    %esp,%ebp
  8000c0:	83 ec 08             	sub    $0x8,%esp
  8000c3:	89 1c 24             	mov    %ebx,(%esp)
  8000c6:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8000ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8000cf:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d4:	89 d1                	mov    %edx,%ecx
  8000d6:	89 d3                	mov    %edx,%ebx
  8000d8:	89 d7                	mov    %edx,%edi
  8000da:	51                   	push   %ecx
  8000db:	52                   	push   %edx
  8000dc:	53                   	push   %ebx
  8000dd:	54                   	push   %esp
  8000de:	55                   	push   %ebp
  8000df:	56                   	push   %esi
  8000e0:	57                   	push   %edi
  8000e1:	5f                   	pop    %edi
  8000e2:	5e                   	pop    %esi
  8000e3:	5d                   	pop    %ebp
  8000e4:	5c                   	pop    %esp
  8000e5:	5b                   	pop    %ebx
  8000e6:	5a                   	pop    %edx
  8000e7:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e8:	8b 1c 24             	mov    (%esp),%ebx
  8000eb:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8000ef:	89 ec                	mov    %ebp,%esp
  8000f1:	5d                   	pop    %ebp
  8000f2:	c3                   	ret    

008000f3 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8000f3:	55                   	push   %ebp
  8000f4:	89 e5                	mov    %esp,%ebp
  8000f6:	83 ec 08             	sub    $0x8,%esp
  8000f9:	89 1c 24             	mov    %ebx,(%esp)
  8000fc:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800100:	ba 00 00 00 00       	mov    $0x0,%edx
  800105:	b8 02 00 00 00       	mov    $0x2,%eax
  80010a:	89 d1                	mov    %edx,%ecx
  80010c:	89 d3                	mov    %edx,%ebx
  80010e:	89 d7                	mov    %edx,%edi
  800110:	51                   	push   %ecx
  800111:	52                   	push   %edx
  800112:	53                   	push   %ebx
  800113:	54                   	push   %esp
  800114:	55                   	push   %ebp
  800115:	56                   	push   %esi
  800116:	57                   	push   %edi
  800117:	5f                   	pop    %edi
  800118:	5e                   	pop    %esi
  800119:	5d                   	pop    %ebp
  80011a:	5c                   	pop    %esp
  80011b:	5b                   	pop    %ebx
  80011c:	5a                   	pop    %edx
  80011d:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80011e:	8b 1c 24             	mov    (%esp),%ebx
  800121:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800125:	89 ec                	mov    %ebp,%esp
  800127:	5d                   	pop    %ebp
  800128:	c3                   	ret    

00800129 <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800129:	55                   	push   %ebp
  80012a:	89 e5                	mov    %esp,%ebp
  80012c:	83 ec 08             	sub    $0x8,%esp
  80012f:	89 1c 24             	mov    %ebx,(%esp)
  800132:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800136:	bb 00 00 00 00       	mov    $0x0,%ebx
  80013b:	b8 04 00 00 00       	mov    $0x4,%eax
  800140:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800143:	8b 55 08             	mov    0x8(%ebp),%edx
  800146:	89 df                	mov    %ebx,%edi
  800148:	51                   	push   %ecx
  800149:	52                   	push   %edx
  80014a:	53                   	push   %ebx
  80014b:	54                   	push   %esp
  80014c:	55                   	push   %ebp
  80014d:	56                   	push   %esi
  80014e:	57                   	push   %edi
  80014f:	5f                   	pop    %edi
  800150:	5e                   	pop    %esi
  800151:	5d                   	pop    %ebp
  800152:	5c                   	pop    %esp
  800153:	5b                   	pop    %ebx
  800154:	5a                   	pop    %edx
  800155:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800156:	8b 1c 24             	mov    (%esp),%ebx
  800159:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80015d:	89 ec                	mov    %ebp,%esp
  80015f:	5d                   	pop    %ebp
  800160:	c3                   	ret    

00800161 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  800161:	55                   	push   %ebp
  800162:	89 e5                	mov    %esp,%ebp
  800164:	83 ec 08             	sub    $0x8,%esp
  800167:	89 1c 24             	mov    %ebx,(%esp)
  80016a:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80016e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800173:	b8 05 00 00 00       	mov    $0x5,%eax
  800178:	8b 55 08             	mov    0x8(%ebp),%edx
  80017b:	89 cb                	mov    %ecx,%ebx
  80017d:	89 cf                	mov    %ecx,%edi
  80017f:	51                   	push   %ecx
  800180:	52                   	push   %edx
  800181:	53                   	push   %ebx
  800182:	54                   	push   %esp
  800183:	55                   	push   %ebp
  800184:	56                   	push   %esi
  800185:	57                   	push   %edi
  800186:	5f                   	pop    %edi
  800187:	5e                   	pop    %esi
  800188:	5d                   	pop    %ebp
  800189:	5c                   	pop    %esp
  80018a:	5b                   	pop    %ebx
  80018b:	5a                   	pop    %edx
  80018c:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  80018d:	8b 1c 24             	mov    (%esp),%ebx
  800190:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800194:	89 ec                	mov    %ebp,%esp
  800196:	5d                   	pop    %ebp
  800197:	c3                   	ret    

00800198 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800198:	55                   	push   %ebp
  800199:	89 e5                	mov    %esp,%ebp
  80019b:	83 ec 28             	sub    $0x28,%esp
  80019e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8001a1:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8001a4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001a9:	b8 03 00 00 00       	mov    $0x3,%eax
  8001ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b1:	89 cb                	mov    %ecx,%ebx
  8001b3:	89 cf                	mov    %ecx,%edi
  8001b5:	51                   	push   %ecx
  8001b6:	52                   	push   %edx
  8001b7:	53                   	push   %ebx
  8001b8:	54                   	push   %esp
  8001b9:	55                   	push   %ebp
  8001ba:	56                   	push   %esi
  8001bb:	57                   	push   %edi
  8001bc:	5f                   	pop    %edi
  8001bd:	5e                   	pop    %esi
  8001be:	5d                   	pop    %ebp
  8001bf:	5c                   	pop    %esp
  8001c0:	5b                   	pop    %ebx
  8001c1:	5a                   	pop    %edx
  8001c2:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  8001c3:	85 c0                	test   %eax,%eax
  8001c5:	7e 28                	jle    8001ef <sys_env_destroy+0x57>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001cb:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8001d2:	00 
  8001d3:	c7 44 24 08 02 12 80 	movl   $0x801202,0x8(%esp)
  8001da:	00 
  8001db:	c7 44 24 04 26 00 00 	movl   $0x26,0x4(%esp)
  8001e2:	00 
  8001e3:	c7 04 24 1f 12 80 00 	movl   $0x80121f,(%esp)
  8001ea:	e8 0d 00 00 00       	call   8001fc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8001ef:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8001f2:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8001f5:	89 ec                	mov    %ebp,%esp
  8001f7:	5d                   	pop    %ebp
  8001f8:	c3                   	ret    
  8001f9:	00 00                	add    %al,(%eax)
	...

008001fc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001fc:	55                   	push   %ebp
  8001fd:	89 e5                	mov    %esp,%ebp
  8001ff:	56                   	push   %esi
  800200:	53                   	push   %ebx
  800201:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  800204:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  800207:	a1 08 20 80 00       	mov    0x802008,%eax
  80020c:	85 c0                	test   %eax,%eax
  80020e:	74 10                	je     800220 <_panic+0x24>
		cprintf("%s: ", argv0);
  800210:	89 44 24 04          	mov    %eax,0x4(%esp)
  800214:	c7 04 24 2d 12 80 00 	movl   $0x80122d,(%esp)
  80021b:	e8 ad 00 00 00       	call   8002cd <cprintf>
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800220:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800226:	e8 c8 fe ff ff       	call   8000f3 <sys_getenvid>
  80022b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80022e:	89 54 24 10          	mov    %edx,0x10(%esp)
  800232:	8b 55 08             	mov    0x8(%ebp),%edx
  800235:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800239:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80023d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800241:	c7 04 24 34 12 80 00 	movl   $0x801234,(%esp)
  800248:	e8 80 00 00 00       	call   8002cd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80024d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800251:	8b 45 10             	mov    0x10(%ebp),%eax
  800254:	89 04 24             	mov    %eax,(%esp)
  800257:	e8 10 00 00 00       	call   80026c <vcprintf>
	cprintf("\n");
  80025c:	c7 04 24 32 12 80 00 	movl   $0x801232,(%esp)
  800263:	e8 65 00 00 00       	call   8002cd <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800268:	cc                   	int3   
  800269:	eb fd                	jmp    800268 <_panic+0x6c>
	...

0080026c <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800275:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80027c:	00 00 00 
	b.cnt = 0;
  80027f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800286:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800289:	8b 45 0c             	mov    0xc(%ebp),%eax
  80028c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800290:	8b 45 08             	mov    0x8(%ebp),%eax
  800293:	89 44 24 08          	mov    %eax,0x8(%esp)
  800297:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80029d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002a1:	c7 04 24 e7 02 80 00 	movl   $0x8002e7,(%esp)
  8002a8:	e8 03 03 00 00       	call   8005b0 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002ad:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8002b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002b7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002bd:	89 04 24             	mov    %eax,(%esp)
  8002c0:	e8 c3 fd ff ff       	call   800088 <sys_cputs>

	return b.cnt;
}
  8002c5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002cb:	c9                   	leave  
  8002cc:	c3                   	ret    

008002cd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002cd:	55                   	push   %ebp
  8002ce:	89 e5                	mov    %esp,%ebp
  8002d0:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  8002d3:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  8002d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002da:	8b 45 08             	mov    0x8(%ebp),%eax
  8002dd:	89 04 24             	mov    %eax,(%esp)
  8002e0:	e8 87 ff ff ff       	call   80026c <vcprintf>
	va_end(ap);

	return cnt;
}
  8002e5:	c9                   	leave  
  8002e6:	c3                   	ret    

008002e7 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002e7:	55                   	push   %ebp
  8002e8:	89 e5                	mov    %esp,%ebp
  8002ea:	53                   	push   %ebx
  8002eb:	83 ec 14             	sub    $0x14,%esp
  8002ee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002f1:	8b 03                	mov    (%ebx),%eax
  8002f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f6:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8002fa:	83 c0 01             	add    $0x1,%eax
  8002fd:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8002ff:	3d ff 00 00 00       	cmp    $0xff,%eax
  800304:	75 19                	jne    80031f <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800306:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80030d:	00 
  80030e:	8d 43 08             	lea    0x8(%ebx),%eax
  800311:	89 04 24             	mov    %eax,(%esp)
  800314:	e8 6f fd ff ff       	call   800088 <sys_cputs>
		b->idx = 0;
  800319:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80031f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800323:	83 c4 14             	add    $0x14,%esp
  800326:	5b                   	pop    %ebx
  800327:	5d                   	pop    %ebp
  800328:	c3                   	ret    
  800329:	00 00                	add    %al,(%eax)
  80032b:	00 00                	add    %al,(%eax)
  80032d:	00 00                	add    %al,(%eax)
	...

00800330 <printnum_nopad>:

/*
* help function added by Lu to print only the num;
*/
static void printnum_nopad(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int *num_len){
  800330:	55                   	push   %ebp
  800331:	89 e5                	mov    %esp,%ebp
  800333:	83 ec 48             	sub    $0x48,%esp
  800336:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800339:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80033c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80033f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800342:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800345:	8b 45 08             	mov    0x8(%ebp),%eax
  800348:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80034b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80034e:	8b 45 10             	mov    0x10(%ebp),%eax
  800351:	8b 7d 14             	mov    0x14(%ebp),%edi
	if(num >= base){
  800354:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800357:	ba 00 00 00 00       	mov    $0x0,%edx
  80035c:	39 f2                	cmp    %esi,%edx
  80035e:	72 07                	jb     800367 <printnum_nopad+0x37>
  800360:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800363:	39 c8                	cmp    %ecx,%eax
  800365:	77 54                	ja     8003bb <printnum_nopad+0x8b>
		printnum_nopad(putch, putdat, num / base, base, num_len);
  800367:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80036b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80036f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800373:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800377:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80037a:	89 55 cc             	mov    %edx,-0x34(%ebp)
  80037d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800380:	89 54 24 08          	mov    %edx,0x8(%esp)
  800384:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80038b:	00 
  80038c:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80038f:	89 0c 24             	mov    %ecx,(%esp)
  800392:	89 74 24 04          	mov    %esi,0x4(%esp)
  800396:	e8 f5 0b 00 00       	call   800f90 <__udivdi3>
  80039b:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80039e:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  8003a1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8003a5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8003a9:	89 04 24             	mov    %eax,(%esp)
  8003ac:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003b0:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003b3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003b6:	e8 75 ff ff ff       	call   800330 <printnum_nopad>
	}
	*num_len += 1 ;
  8003bb:	83 07 01             	addl   $0x1,(%edi)
	putch("0123456789abcdef"[num % base], putdat);
  8003be:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8003c1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003c5:	8b 04 24             	mov    (%esp),%eax
  8003c8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8003cc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003cf:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8003d2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8003d5:	89 54 24 08          	mov    %edx,0x8(%esp)
  8003d9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003e0:	00 
  8003e1:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8003e4:	89 0c 24             	mov    %ecx,(%esp)
  8003e7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003eb:	e8 d0 0c 00 00       	call   8010c0 <__umoddi3>
  8003f0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003f3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8003f7:	0f be 80 57 12 80 00 	movsbl 0x801257(%eax),%eax
  8003fe:	89 04 24             	mov    %eax,(%esp)
  800401:	ff 55 d4             	call   *-0x2c(%ebp)
}
  800404:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800407:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80040a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80040d:	89 ec                	mov    %ebp,%esp
  80040f:	5d                   	pop    %ebp
  800410:	c3                   	ret    

00800411 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800411:	55                   	push   %ebp
  800412:	89 e5                	mov    %esp,%ebp
  800414:	57                   	push   %edi
  800415:	56                   	push   %esi
  800416:	53                   	push   %ebx
  800417:	83 ec 5c             	sub    $0x5c,%esp
  80041a:	89 c7                	mov    %eax,%edi
  80041c:	89 d6                	mov    %edx,%esi
  80041e:	8b 45 08             	mov    0x8(%ebp),%eax
  800421:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800424:	8b 55 0c             	mov    0xc(%ebp),%edx
  800427:	89 55 cc             	mov    %edx,-0x34(%ebp)
  80042a:	8b 45 10             	mov    0x10(%ebp),%eax
  80042d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	if(padc == '-'){
  800430:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  800434:	75 4c                	jne    800482 <printnum+0x71>
		int num_len = 0;
  800436:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		printnum_nopad(putch, putdat, num, base, &num_len);
  80043d:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800440:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800444:	89 44 24 08          	mov    %eax,0x8(%esp)
  800448:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80044b:	89 0c 24             	mov    %ecx,(%esp)
  80044e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800451:	89 44 24 04          	mov    %eax,0x4(%esp)
  800455:	89 f2                	mov    %esi,%edx
  800457:	89 f8                	mov    %edi,%eax
  800459:	e8 d2 fe ff ff       	call   800330 <printnum_nopad>
		width -= num_len;
  80045e:	2b 5d e4             	sub    -0x1c(%ebp),%ebx
		while (width-- > 0)
  800461:	85 db                	test   %ebx,%ebx
  800463:	0f 8e e8 00 00 00    	jle    800551 <printnum+0x140>
			putch(' ', putdat);
  800469:	89 74 24 04          	mov    %esi,0x4(%esp)
  80046d:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800474:	ff d7                	call   *%edi
  800476:	83 eb 01             	sub    $0x1,%ebx
	// your code here:
	if(padc == '-'){
		int num_len = 0;
		printnum_nopad(putch, putdat, num, base, &num_len);
		width -= num_len;
		while (width-- > 0)
  800479:	85 db                	test   %ebx,%ebx
  80047b:	7f ec                	jg     800469 <printnum+0x58>
  80047d:	e9 cf 00 00 00       	jmp    800551 <printnum+0x140>
			putch(' ', putdat);
	}
	else{
		// first recursively print all preceding (more significant) digits
		if (num >= base) {
  800482:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  800485:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800489:	77 19                	ja     8004a4 <printnum+0x93>
  80048b:	90                   	nop
  80048c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800490:	72 05                	jb     800497 <printnum+0x86>
  800492:	39 45 c8             	cmp    %eax,-0x38(%ebp)
  800495:	73 0d                	jae    8004a4 <printnum+0x93>
			printnum(putch, putdat, num / base, base, width - 1, padc);
		} else {
			// print any needed pad characters before first digit
			while (--width > 0)
  800497:	83 eb 01             	sub    $0x1,%ebx
  80049a:	85 db                	test   %ebx,%ebx
  80049c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8004a0:	7f 63                	jg     800505 <printnum+0xf4>
  8004a2:	eb 74                	jmp    800518 <printnum+0x107>
			putch(' ', putdat);
	}
	else{
		// first recursively print all preceding (more significant) digits
		if (num >= base) {
			printnum(putch, putdat, num / base, base, width - 1, padc);
  8004a4:	8b 55 18             	mov    0x18(%ebp),%edx
  8004a7:	89 54 24 10          	mov    %edx,0x10(%esp)
  8004ab:	83 eb 01             	sub    $0x1,%ebx
  8004ae:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8004b2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004b6:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8004ba:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8004be:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8004c1:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8004c4:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  8004c7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8004cb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004d2:	00 
  8004d3:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8004d6:	89 04 24             	mov    %eax,(%esp)
  8004d9:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8004dc:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004e0:	e8 ab 0a 00 00       	call   800f90 <__udivdi3>
  8004e5:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8004e8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8004eb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8004ef:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8004f3:	89 04 24             	mov    %eax,(%esp)
  8004f6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004fa:	89 f2                	mov    %esi,%edx
  8004fc:	89 f8                	mov    %edi,%eax
  8004fe:	e8 0e ff ff ff       	call   800411 <printnum>
  800503:	eb 13                	jmp    800518 <printnum+0x107>
		} else {
			// print any needed pad characters before first digit
			while (--width > 0)
				putch(padc, putdat);
  800505:	89 74 24 04          	mov    %esi,0x4(%esp)
  800509:	8b 45 18             	mov    0x18(%ebp),%eax
  80050c:	89 04 24             	mov    %eax,(%esp)
  80050f:	ff d7                	call   *%edi
		// first recursively print all preceding (more significant) digits
		if (num >= base) {
			printnum(putch, putdat, num / base, base, width - 1, padc);
		} else {
			// print any needed pad characters before first digit
			while (--width > 0)
  800511:	83 eb 01             	sub    $0x1,%ebx
  800514:	85 db                	test   %ebx,%ebx
  800516:	7f ed                	jg     800505 <printnum+0xf4>
				putch(padc, putdat);
		}

		// then print this (the least significant) digit
		putch("0123456789abcdef"[num % base], putdat);
  800518:	89 74 24 04          	mov    %esi,0x4(%esp)
  80051c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800520:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800523:	89 54 24 08          	mov    %edx,0x8(%esp)
  800527:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80052e:	00 
  80052f:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800532:	89 0c 24             	mov    %ecx,(%esp)
  800535:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800538:	89 44 24 04          	mov    %eax,0x4(%esp)
  80053c:	e8 7f 0b 00 00       	call   8010c0 <__umoddi3>
  800541:	89 74 24 04          	mov    %esi,0x4(%esp)
  800545:	0f be 80 57 12 80 00 	movsbl 0x801257(%eax),%eax
  80054c:	89 04 24             	mov    %eax,(%esp)
  80054f:	ff d7                	call   *%edi
	}
	
}
  800551:	83 c4 5c             	add    $0x5c,%esp
  800554:	5b                   	pop    %ebx
  800555:	5e                   	pop    %esi
  800556:	5f                   	pop    %edi
  800557:	5d                   	pop    %ebp
  800558:	c3                   	ret    

00800559 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800559:	55                   	push   %ebp
  80055a:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80055c:	83 fa 01             	cmp    $0x1,%edx
  80055f:	7e 0e                	jle    80056f <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800561:	8b 10                	mov    (%eax),%edx
  800563:	8d 4a 08             	lea    0x8(%edx),%ecx
  800566:	89 08                	mov    %ecx,(%eax)
  800568:	8b 02                	mov    (%edx),%eax
  80056a:	8b 52 04             	mov    0x4(%edx),%edx
  80056d:	eb 22                	jmp    800591 <getuint+0x38>
	else if (lflag)
  80056f:	85 d2                	test   %edx,%edx
  800571:	74 10                	je     800583 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800573:	8b 10                	mov    (%eax),%edx
  800575:	8d 4a 04             	lea    0x4(%edx),%ecx
  800578:	89 08                	mov    %ecx,(%eax)
  80057a:	8b 02                	mov    (%edx),%eax
  80057c:	ba 00 00 00 00       	mov    $0x0,%edx
  800581:	eb 0e                	jmp    800591 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800583:	8b 10                	mov    (%eax),%edx
  800585:	8d 4a 04             	lea    0x4(%edx),%ecx
  800588:	89 08                	mov    %ecx,(%eax)
  80058a:	8b 02                	mov    (%edx),%eax
  80058c:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800591:	5d                   	pop    %ebp
  800592:	c3                   	ret    

00800593 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800593:	55                   	push   %ebp
  800594:	89 e5                	mov    %esp,%ebp
  800596:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800599:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80059d:	8b 10                	mov    (%eax),%edx
  80059f:	3b 50 04             	cmp    0x4(%eax),%edx
  8005a2:	73 0a                	jae    8005ae <sprintputch+0x1b>
		*b->buf++ = ch;
  8005a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8005a7:	88 0a                	mov    %cl,(%edx)
  8005a9:	83 c2 01             	add    $0x1,%edx
  8005ac:	89 10                	mov    %edx,(%eax)
}
  8005ae:	5d                   	pop    %ebp
  8005af:	c3                   	ret    

008005b0 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8005b0:	55                   	push   %ebp
  8005b1:	89 e5                	mov    %esp,%ebp
  8005b3:	57                   	push   %edi
  8005b4:	56                   	push   %esi
  8005b5:	53                   	push   %ebx
  8005b6:	83 ec 5c             	sub    $0x5c,%esp
  8005b9:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8005bc:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8005bf:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8005c6:	eb 12                	jmp    8005da <vprintfmt+0x2a>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8005c8:	85 c0                	test   %eax,%eax
  8005ca:	0f 84 c6 04 00 00    	je     800a96 <vprintfmt+0x4e6>
				return;
			putch(ch, putdat);
  8005d0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005d4:	89 04 24             	mov    %eax,(%esp)
  8005d7:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005da:	0f b6 03             	movzbl (%ebx),%eax
  8005dd:	83 c3 01             	add    $0x1,%ebx
  8005e0:	83 f8 25             	cmp    $0x25,%eax
  8005e3:	75 e3                	jne    8005c8 <vprintfmt+0x18>
  8005e5:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  8005e9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8005f0:	be ff ff ff ff       	mov    $0xffffffff,%esi
  8005f5:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8005fc:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800603:	eb 06                	jmp    80060b <vprintfmt+0x5b>
  800605:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  800609:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80060b:	0f b6 0b             	movzbl (%ebx),%ecx
  80060e:	0f b6 d1             	movzbl %cl,%edx
  800611:	8d 43 01             	lea    0x1(%ebx),%eax
  800614:	83 e9 23             	sub    $0x23,%ecx
  800617:	80 f9 55             	cmp    $0x55,%cl
  80061a:	0f 87 58 04 00 00    	ja     800a78 <vprintfmt+0x4c8>
  800620:	0f b6 c9             	movzbl %cl,%ecx
  800623:	ff 24 8d 60 13 80 00 	jmp    *0x801360(,%ecx,4)
  80062a:	c6 45 e0 2b          	movb   $0x2b,-0x20(%ebp)
  80062e:	eb d9                	jmp    800609 <vprintfmt+0x59>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800630:	8d 72 d0             	lea    -0x30(%edx),%esi
				ch = *fmt;
  800633:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800636:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800639:	83 f9 09             	cmp    $0x9,%ecx
  80063c:	76 08                	jbe    800646 <vprintfmt+0x96>
  80063e:	eb 40                	jmp    800680 <vprintfmt+0xd0>
  800640:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
			goto reswitch;
  800644:	eb c3                	jmp    800609 <vprintfmt+0x59>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800646:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  800649:	8d 0c b6             	lea    (%esi,%esi,4),%ecx
  80064c:	8d 74 4a d0          	lea    -0x30(%edx,%ecx,2),%esi
				ch = *fmt;
  800650:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800653:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800656:	83 f9 09             	cmp    $0x9,%ecx
  800659:	76 eb                	jbe    800646 <vprintfmt+0x96>
  80065b:	eb 23                	jmp    800680 <vprintfmt+0xd0>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80065d:	8b 55 14             	mov    0x14(%ebp),%edx
  800660:	8d 4a 04             	lea    0x4(%edx),%ecx
  800663:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800666:	8b 32                	mov    (%edx),%esi
			goto process_precision;
  800668:	eb 16                	jmp    800680 <vprintfmt+0xd0>

		case '.':
			if (width < 0)
  80066a:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80066d:	c1 fa 1f             	sar    $0x1f,%edx
  800670:	f7 d2                	not    %edx
  800672:	21 55 dc             	and    %edx,-0x24(%ebp)
  800675:	eb 92                	jmp    800609 <vprintfmt+0x59>
  800677:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  80067e:	eb 89                	jmp    800609 <vprintfmt+0x59>

		process_precision:
			if (width < 0)
  800680:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800684:	79 83                	jns    800609 <vprintfmt+0x59>
  800686:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800689:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80068c:	e9 78 ff ff ff       	jmp    800609 <vprintfmt+0x59>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800691:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
			goto reswitch;
  800695:	e9 6f ff ff ff       	jmp    800609 <vprintfmt+0x59>
  80069a:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80069d:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a0:	8d 50 04             	lea    0x4(%eax),%edx
  8006a3:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006aa:	8b 00                	mov    (%eax),%eax
  8006ac:	89 04 24             	mov    %eax,(%esp)
  8006af:	ff 55 08             	call   *0x8(%ebp)
  8006b2:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  8006b5:	e9 20 ff ff ff       	jmp    8005da <vprintfmt+0x2a>
  8006ba:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8006bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c0:	8d 50 04             	lea    0x4(%eax),%edx
  8006c3:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c6:	8b 00                	mov    (%eax),%eax
  8006c8:	89 c2                	mov    %eax,%edx
  8006ca:	c1 fa 1f             	sar    $0x1f,%edx
  8006cd:	31 d0                	xor    %edx,%eax
  8006cf:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006d1:	83 f8 06             	cmp    $0x6,%eax
  8006d4:	7f 0b                	jg     8006e1 <vprintfmt+0x131>
  8006d6:	8b 14 85 b8 14 80 00 	mov    0x8014b8(,%eax,4),%edx
  8006dd:	85 d2                	test   %edx,%edx
  8006df:	75 23                	jne    800704 <vprintfmt+0x154>
				printfmt(putch, putdat, "error %d", err);
  8006e1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006e5:	c7 44 24 08 68 12 80 	movl   $0x801268,0x8(%esp)
  8006ec:	00 
  8006ed:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f4:	89 04 24             	mov    %eax,(%esp)
  8006f7:	e8 22 04 00 00       	call   800b1e <printfmt>
  8006fc:	8b 5d cc             	mov    -0x34(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006ff:	e9 d6 fe ff ff       	jmp    8005da <vprintfmt+0x2a>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800704:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800708:	c7 44 24 08 71 12 80 	movl   $0x801271,0x8(%esp)
  80070f:	00 
  800710:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800714:	8b 55 08             	mov    0x8(%ebp),%edx
  800717:	89 14 24             	mov    %edx,(%esp)
  80071a:	e8 ff 03 00 00       	call   800b1e <printfmt>
  80071f:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800722:	e9 b3 fe ff ff       	jmp    8005da <vprintfmt+0x2a>
  800727:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80072a:	89 c3                	mov    %eax,%ebx
  80072c:	89 f1                	mov    %esi,%ecx
  80072e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800731:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800734:	8b 45 14             	mov    0x14(%ebp),%eax
  800737:	8d 50 04             	lea    0x4(%eax),%edx
  80073a:	89 55 14             	mov    %edx,0x14(%ebp)
  80073d:	8b 00                	mov    (%eax),%eax
  80073f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800742:	85 c0                	test   %eax,%eax
  800744:	75 07                	jne    80074d <vprintfmt+0x19d>
  800746:	c7 45 d0 74 12 80 00 	movl   $0x801274,-0x30(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  80074d:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  800751:	7e 06                	jle    800759 <vprintfmt+0x1a9>
  800753:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  800757:	75 13                	jne    80076c <vprintfmt+0x1bc>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800759:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80075c:	0f be 02             	movsbl (%edx),%eax
  80075f:	85 c0                	test   %eax,%eax
  800761:	0f 85 a2 00 00 00    	jne    800809 <vprintfmt+0x259>
  800767:	e9 8f 00 00 00       	jmp    8007fb <vprintfmt+0x24b>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80076c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800770:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800773:	89 0c 24             	mov    %ecx,(%esp)
  800776:	e8 f0 03 00 00       	call   800b6b <strnlen>
  80077b:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80077e:	29 c2                	sub    %eax,%edx
  800780:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800783:	85 d2                	test   %edx,%edx
  800785:	7e d2                	jle    800759 <vprintfmt+0x1a9>
					putch(padc, putdat);
  800787:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  80078b:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  80078e:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  800791:	89 d3                	mov    %edx,%ebx
  800793:	89 ce                	mov    %ecx,%esi
  800795:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800799:	89 34 24             	mov    %esi,(%esp)
  80079c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80079f:	83 eb 01             	sub    $0x1,%ebx
  8007a2:	85 db                	test   %ebx,%ebx
  8007a4:	7f ef                	jg     800795 <vprintfmt+0x1e5>
  8007a6:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  8007a9:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  8007ac:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8007b3:	eb a4                	jmp    800759 <vprintfmt+0x1a9>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8007b5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007b9:	74 1b                	je     8007d6 <vprintfmt+0x226>
  8007bb:	8d 50 e0             	lea    -0x20(%eax),%edx
  8007be:	83 fa 5e             	cmp    $0x5e,%edx
  8007c1:	76 13                	jbe    8007d6 <vprintfmt+0x226>
					putch('?', putdat);
  8007c3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007ca:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8007d1:	ff 55 08             	call   *0x8(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8007d4:	eb 0d                	jmp    8007e3 <vprintfmt+0x233>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8007d6:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8007d9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007dd:	89 04 24             	mov    %eax,(%esp)
  8007e0:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007e3:	83 ef 01             	sub    $0x1,%edi
  8007e6:	0f be 03             	movsbl (%ebx),%eax
  8007e9:	85 c0                	test   %eax,%eax
  8007eb:	74 05                	je     8007f2 <vprintfmt+0x242>
  8007ed:	83 c3 01             	add    $0x1,%ebx
  8007f0:	eb 28                	jmp    80081a <vprintfmt+0x26a>
  8007f2:	89 7d dc             	mov    %edi,-0x24(%ebp)
  8007f5:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8007f8:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007fb:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007ff:	7f 2d                	jg     80082e <vprintfmt+0x27e>
  800801:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800804:	e9 d1 fd ff ff       	jmp    8005da <vprintfmt+0x2a>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800809:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80080c:	83 c1 01             	add    $0x1,%ecx
  80080f:	89 7d e0             	mov    %edi,-0x20(%ebp)
  800812:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800815:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  800818:	89 cb                	mov    %ecx,%ebx
  80081a:	85 f6                	test   %esi,%esi
  80081c:	78 97                	js     8007b5 <vprintfmt+0x205>
  80081e:	83 ee 01             	sub    $0x1,%esi
  800821:	79 92                	jns    8007b5 <vprintfmt+0x205>
  800823:	89 7d dc             	mov    %edi,-0x24(%ebp)
  800826:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800829:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  80082c:	eb cd                	jmp    8007fb <vprintfmt+0x24b>
  80082e:	8b 75 08             	mov    0x8(%ebp),%esi
  800831:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800834:	8b 5d dc             	mov    -0x24(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800837:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80083b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800842:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800844:	83 eb 01             	sub    $0x1,%ebx
  800847:	85 db                	test   %ebx,%ebx
  800849:	7f ec                	jg     800837 <vprintfmt+0x287>
  80084b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80084e:	e9 87 fd ff ff       	jmp    8005da <vprintfmt+0x2a>
  800853:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800856:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
  80085a:	88 45 e4             	mov    %al,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80085d:	83 7d d0 01          	cmpl   $0x1,-0x30(%ebp)
  800861:	7e 16                	jle    800879 <vprintfmt+0x2c9>
		return va_arg(*ap, long long);
  800863:	8b 45 14             	mov    0x14(%ebp),%eax
  800866:	8d 50 08             	lea    0x8(%eax),%edx
  800869:	89 55 14             	mov    %edx,0x14(%ebp)
  80086c:	8b 10                	mov    (%eax),%edx
  80086e:	8b 48 04             	mov    0x4(%eax),%ecx
  800871:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800874:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800877:	eb 34                	jmp    8008ad <vprintfmt+0x2fd>
	else if (lflag)
  800879:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80087d:	74 18                	je     800897 <vprintfmt+0x2e7>
		return va_arg(*ap, long);
  80087f:	8b 45 14             	mov    0x14(%ebp),%eax
  800882:	8d 50 04             	lea    0x4(%eax),%edx
  800885:	89 55 14             	mov    %edx,0x14(%ebp)
  800888:	8b 00                	mov    (%eax),%eax
  80088a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80088d:	89 c1                	mov    %eax,%ecx
  80088f:	c1 f9 1f             	sar    $0x1f,%ecx
  800892:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800895:	eb 16                	jmp    8008ad <vprintfmt+0x2fd>
	else
		return va_arg(*ap, int);
  800897:	8b 45 14             	mov    0x14(%ebp),%eax
  80089a:	8d 50 04             	lea    0x4(%eax),%edx
  80089d:	89 55 14             	mov    %edx,0x14(%ebp)
  8008a0:	8b 00                	mov    (%eax),%eax
  8008a2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8008a5:	89 c2                	mov    %eax,%edx
  8008a7:	c1 fa 1f             	sar    $0x1f,%edx
  8008aa:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8008ad:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8008b0:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if ((long long) num < 0) {
  8008b3:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8008b7:	79 2c                	jns    8008e5 <vprintfmt+0x335>
				putch('-', putdat);
  8008b9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008bd:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8008c4:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8008c7:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8008ca:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8008cd:	f7 db                	neg    %ebx
  8008cf:	83 d6 00             	adc    $0x0,%esi
  8008d2:	f7 de                	neg    %esi
  8008d4:	0f b6 4d e0          	movzbl -0x20(%ebp),%ecx
  8008d8:	88 4d e4             	mov    %cl,-0x1c(%ebp)
  8008db:	ba 0a 00 00 00       	mov    $0xa,%edx
  8008e0:	e9 db 00 00 00       	jmp    8009c0 <vprintfmt+0x410>
			}
			else if (padc == '+'){
  8008e5:	80 7d e4 2b          	cmpb   $0x2b,-0x1c(%ebp)
  8008e9:	74 11                	je     8008fc <vprintfmt+0x34c>
  8008eb:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
  8008ef:	88 45 e4             	mov    %al,-0x1c(%ebp)
  8008f2:	ba 0a 00 00 00       	mov    $0xa,%edx
  8008f7:	e9 c4 00 00 00       	jmp    8009c0 <vprintfmt+0x410>
				putch('+', putdat);
  8008fc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800900:	c7 04 24 2b 00 00 00 	movl   $0x2b,(%esp)
  800907:	ff 55 08             	call   *0x8(%ebp)
  80090a:	ba 0a 00 00 00       	mov    $0xa,%edx
  80090f:	e9 ac 00 00 00       	jmp    8009c0 <vprintfmt+0x410>
  800914:	89 45 cc             	mov    %eax,-0x34(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800917:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80091a:	8d 45 14             	lea    0x14(%ebp),%eax
  80091d:	e8 37 fc ff ff       	call   800559 <getuint>
  800922:	89 c3                	mov    %eax,%ebx
  800924:	89 d6                	mov    %edx,%esi
  800926:	0f b6 55 e0          	movzbl -0x20(%ebp),%edx
  80092a:	88 55 e4             	mov    %dl,-0x1c(%ebp)
  80092d:	ba 0a 00 00 00       	mov    $0xa,%edx
			base = 10;
			goto number;
  800932:	e9 89 00 00 00       	jmp    8009c0 <vprintfmt+0x410>
  800937:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) octal
		case 'o':
			putch('0', putdat);
  80093a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80093e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800945:	ff 55 08             	call   *0x8(%ebp)
			num = getuint(&ap, lflag);
  800948:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80094b:	8d 45 14             	lea    0x14(%ebp),%eax
  80094e:	e8 06 fc ff ff       	call   800559 <getuint>
  800953:	89 c3                	mov    %eax,%ebx
  800955:	89 d6                	mov    %edx,%esi
  800957:	0f b6 4d e0          	movzbl -0x20(%ebp),%ecx
  80095b:	88 4d e4             	mov    %cl,-0x1c(%ebp)
  80095e:	ba 08 00 00 00       	mov    $0x8,%edx
			base = 8;
			goto number;
  800963:	eb 5b                	jmp    8009c0 <vprintfmt+0x410>
  800965:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  800968:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80096c:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800973:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800976:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80097a:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800981:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  800984:	8b 45 14             	mov    0x14(%ebp),%eax
  800987:	8d 50 04             	lea    0x4(%eax),%edx
  80098a:	89 55 14             	mov    %edx,0x14(%ebp)
  80098d:	8b 18                	mov    (%eax),%ebx
  80098f:	be 00 00 00 00       	mov    $0x0,%esi
  800994:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
  800998:	88 45 e4             	mov    %al,-0x1c(%ebp)
  80099b:	ba 10 00 00 00       	mov    $0x10,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8009a0:	eb 1e                	jmp    8009c0 <vprintfmt+0x410>
  8009a2:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8009a5:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8009a8:	8d 45 14             	lea    0x14(%ebp),%eax
  8009ab:	e8 a9 fb ff ff       	call   800559 <getuint>
  8009b0:	89 c3                	mov    %eax,%ebx
  8009b2:	89 d6                	mov    %edx,%esi
  8009b4:	0f b6 55 e0          	movzbl -0x20(%ebp),%edx
  8009b8:	88 55 e4             	mov    %dl,-0x1c(%ebp)
  8009bb:	ba 10 00 00 00       	mov    $0x10,%edx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8009c0:	0f be 45 e4          	movsbl -0x1c(%ebp),%eax
  8009c4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8009c8:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8009cb:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8009cf:	89 54 24 08          	mov    %edx,0x8(%esp)
  8009d3:	89 1c 24             	mov    %ebx,(%esp)
  8009d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009da:	89 fa                	mov    %edi,%edx
  8009dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009df:	e8 2d fa ff ff       	call   800411 <printnum>
  8009e4:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  8009e7:	e9 ee fb ff ff       	jmp    8005da <vprintfmt+0x2a>
  8009ec:	89 45 cc             	mov    %eax,-0x34(%ebp)
            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
	    	uint32_t *num_now = putdat;
	    	char *ret_va = va_arg(ap, char *);
  8009ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8009f2:	8d 50 04             	lea    0x4(%eax),%edx
  8009f5:	89 55 14             	mov    %edx,0x14(%ebp)
  8009f8:	8b 00                	mov    (%eax),%eax
	    	if(ret_va == NULL){
  8009fa:	85 c0                	test   %eax,%eax
  8009fc:	75 27                	jne    800a25 <vprintfmt+0x475>
				printfmt(putch, putdat, "%s", null_error);
  8009fe:	c7 44 24 0c e4 12 80 	movl   $0x8012e4,0xc(%esp)
  800a05:	00 
  800a06:	c7 44 24 08 71 12 80 	movl   $0x801271,0x8(%esp)
  800a0d:	00 
  800a0e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a12:	8b 45 08             	mov    0x8(%ebp),%eax
  800a15:	89 04 24             	mov    %eax,(%esp)
  800a18:	e8 01 01 00 00       	call   800b1e <printfmt>
  800a1d:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800a20:	e9 b5 fb ff ff       	jmp    8005da <vprintfmt+0x2a>
	    	}
	    	else if ((*num_now) >> 7 != 0 ){		//how to aurrately discribe overflow?
  800a25:	8b 17                	mov    (%edi),%edx
  800a27:	89 d1                	mov    %edx,%ecx
  800a29:	c1 e9 07             	shr    $0x7,%ecx
  800a2c:	85 c9                	test   %ecx,%ecx
  800a2e:	74 29                	je     800a59 <vprintfmt+0x4a9>
				*ret_va = *(num_now);	//get putdat at first as next print instruction will change ret_va as it's a pointer which means it's dynamic;
  800a30:	88 10                	mov    %dl,(%eax)
				printfmt(putch, putdat, "%s", overflow_error);
  800a32:	c7 44 24 0c 1c 13 80 	movl   $0x80131c,0xc(%esp)
  800a39:	00 
  800a3a:	c7 44 24 08 71 12 80 	movl   $0x801271,0x8(%esp)
  800a41:	00 
  800a42:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a46:	8b 55 08             	mov    0x8(%ebp),%edx
  800a49:	89 14 24             	mov    %edx,(%esp)
  800a4c:	e8 cd 00 00 00       	call   800b1e <printfmt>
  800a51:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800a54:	e9 81 fb ff ff       	jmp    8005da <vprintfmt+0x2a>
	    	}
	    	else{
				*ret_va = *(num_now);
  800a59:	88 10                	mov    %dl,(%eax)
  800a5b:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800a5e:	e9 77 fb ff ff       	jmp    8005da <vprintfmt+0x2a>
  800a63:	89 45 cc             	mov    %eax,-0x34(%ebp)
            	break;
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a66:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a6a:	89 14 24             	mov    %edx,(%esp)
  800a6d:	ff 55 08             	call   *0x8(%ebp)
  800a70:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  800a73:	e9 62 fb ff ff       	jmp    8005da <vprintfmt+0x2a>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a78:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a7c:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800a83:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a86:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800a89:	80 38 25             	cmpb   $0x25,(%eax)
  800a8c:	0f 84 48 fb ff ff    	je     8005da <vprintfmt+0x2a>
  800a92:	89 c3                	mov    %eax,%ebx
  800a94:	eb f0                	jmp    800a86 <vprintfmt+0x4d6>
				/* do nothing */;
			break;
		}
	}
}
  800a96:	83 c4 5c             	add    $0x5c,%esp
  800a99:	5b                   	pop    %ebx
  800a9a:	5e                   	pop    %esi
  800a9b:	5f                   	pop    %edi
  800a9c:	5d                   	pop    %ebp
  800a9d:	c3                   	ret    

00800a9e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a9e:	55                   	push   %ebp
  800a9f:	89 e5                	mov    %esp,%ebp
  800aa1:	83 ec 28             	sub    $0x28,%esp
  800aa4:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800aaa:	85 c0                	test   %eax,%eax
  800aac:	74 04                	je     800ab2 <vsnprintf+0x14>
  800aae:	85 d2                	test   %edx,%edx
  800ab0:	7f 07                	jg     800ab9 <vsnprintf+0x1b>
  800ab2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ab7:	eb 3b                	jmp    800af4 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800ab9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800abc:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800ac0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800ac3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800aca:	8b 45 14             	mov    0x14(%ebp),%eax
  800acd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ad1:	8b 45 10             	mov    0x10(%ebp),%eax
  800ad4:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ad8:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800adb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800adf:	c7 04 24 93 05 80 00 	movl   $0x800593,(%esp)
  800ae6:	e8 c5 fa ff ff       	call   8005b0 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800aeb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800aee:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800af1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800af4:	c9                   	leave  
  800af5:	c3                   	ret    

00800af6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800af6:	55                   	push   %ebp
  800af7:	89 e5                	mov    %esp,%ebp
  800af9:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800afc:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800aff:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b03:	8b 45 10             	mov    0x10(%ebp),%eax
  800b06:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b0a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b0d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b11:	8b 45 08             	mov    0x8(%ebp),%eax
  800b14:	89 04 24             	mov    %eax,(%esp)
  800b17:	e8 82 ff ff ff       	call   800a9e <vsnprintf>
	va_end(ap);

	return rc;
}
  800b1c:	c9                   	leave  
  800b1d:	c3                   	ret    

00800b1e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800b1e:	55                   	push   %ebp
  800b1f:	89 e5                	mov    %esp,%ebp
  800b21:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800b24:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800b27:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b2b:	8b 45 10             	mov    0x10(%ebp),%eax
  800b2e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b32:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b35:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b39:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3c:	89 04 24             	mov    %eax,(%esp)
  800b3f:	e8 6c fa ff ff       	call   8005b0 <vprintfmt>
	va_end(ap);
}
  800b44:	c9                   	leave  
  800b45:	c3                   	ret    
	...

00800b50 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b50:	55                   	push   %ebp
  800b51:	89 e5                	mov    %esp,%ebp
  800b53:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b56:	b8 00 00 00 00       	mov    $0x0,%eax
  800b5b:	80 3a 00             	cmpb   $0x0,(%edx)
  800b5e:	74 09                	je     800b69 <strlen+0x19>
		n++;
  800b60:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b63:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b67:	75 f7                	jne    800b60 <strlen+0x10>
		n++;
	return n;
}
  800b69:	5d                   	pop    %ebp
  800b6a:	c3                   	ret    

00800b6b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b6b:	55                   	push   %ebp
  800b6c:	89 e5                	mov    %esp,%ebp
  800b6e:	53                   	push   %ebx
  800b6f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b75:	85 c9                	test   %ecx,%ecx
  800b77:	74 19                	je     800b92 <strnlen+0x27>
  800b79:	80 3b 00             	cmpb   $0x0,(%ebx)
  800b7c:	74 14                	je     800b92 <strnlen+0x27>
  800b7e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800b83:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b86:	39 c8                	cmp    %ecx,%eax
  800b88:	74 0d                	je     800b97 <strnlen+0x2c>
  800b8a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800b8e:	75 f3                	jne    800b83 <strnlen+0x18>
  800b90:	eb 05                	jmp    800b97 <strnlen+0x2c>
  800b92:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800b97:	5b                   	pop    %ebx
  800b98:	5d                   	pop    %ebp
  800b99:	c3                   	ret    

00800b9a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b9a:	55                   	push   %ebp
  800b9b:	89 e5                	mov    %esp,%ebp
  800b9d:	53                   	push   %ebx
  800b9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ba4:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800ba9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800bad:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800bb0:	83 c2 01             	add    $0x1,%edx
  800bb3:	84 c9                	test   %cl,%cl
  800bb5:	75 f2                	jne    800ba9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800bb7:	5b                   	pop    %ebx
  800bb8:	5d                   	pop    %ebp
  800bb9:	c3                   	ret    

00800bba <strcat>:

char *
strcat(char *dst, const char *src)
{
  800bba:	55                   	push   %ebp
  800bbb:	89 e5                	mov    %esp,%ebp
  800bbd:	53                   	push   %ebx
  800bbe:	83 ec 08             	sub    $0x8,%esp
  800bc1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800bc4:	89 1c 24             	mov    %ebx,(%esp)
  800bc7:	e8 84 ff ff ff       	call   800b50 <strlen>
	strcpy(dst + len, src);
  800bcc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bcf:	89 54 24 04          	mov    %edx,0x4(%esp)
  800bd3:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800bd6:	89 04 24             	mov    %eax,(%esp)
  800bd9:	e8 bc ff ff ff       	call   800b9a <strcpy>
	return dst;
}
  800bde:	89 d8                	mov    %ebx,%eax
  800be0:	83 c4 08             	add    $0x8,%esp
  800be3:	5b                   	pop    %ebx
  800be4:	5d                   	pop    %ebp
  800be5:	c3                   	ret    

00800be6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800be6:	55                   	push   %ebp
  800be7:	89 e5                	mov    %esp,%ebp
  800be9:	56                   	push   %esi
  800bea:	53                   	push   %ebx
  800beb:	8b 45 08             	mov    0x8(%ebp),%eax
  800bee:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bf1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800bf4:	85 f6                	test   %esi,%esi
  800bf6:	74 18                	je     800c10 <strncpy+0x2a>
  800bf8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800bfd:	0f b6 1a             	movzbl (%edx),%ebx
  800c00:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800c03:	80 3a 01             	cmpb   $0x1,(%edx)
  800c06:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c09:	83 c1 01             	add    $0x1,%ecx
  800c0c:	39 ce                	cmp    %ecx,%esi
  800c0e:	77 ed                	ja     800bfd <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800c10:	5b                   	pop    %ebx
  800c11:	5e                   	pop    %esi
  800c12:	5d                   	pop    %ebp
  800c13:	c3                   	ret    

00800c14 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800c14:	55                   	push   %ebp
  800c15:	89 e5                	mov    %esp,%ebp
  800c17:	56                   	push   %esi
  800c18:	53                   	push   %ebx
  800c19:	8b 75 08             	mov    0x8(%ebp),%esi
  800c1c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c1f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c22:	89 f0                	mov    %esi,%eax
  800c24:	85 c9                	test   %ecx,%ecx
  800c26:	74 27                	je     800c4f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800c28:	83 e9 01             	sub    $0x1,%ecx
  800c2b:	74 1d                	je     800c4a <strlcpy+0x36>
  800c2d:	0f b6 1a             	movzbl (%edx),%ebx
  800c30:	84 db                	test   %bl,%bl
  800c32:	74 16                	je     800c4a <strlcpy+0x36>
			*dst++ = *src++;
  800c34:	88 18                	mov    %bl,(%eax)
  800c36:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c39:	83 e9 01             	sub    $0x1,%ecx
  800c3c:	74 0e                	je     800c4c <strlcpy+0x38>
			*dst++ = *src++;
  800c3e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c41:	0f b6 1a             	movzbl (%edx),%ebx
  800c44:	84 db                	test   %bl,%bl
  800c46:	75 ec                	jne    800c34 <strlcpy+0x20>
  800c48:	eb 02                	jmp    800c4c <strlcpy+0x38>
  800c4a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800c4c:	c6 00 00             	movb   $0x0,(%eax)
  800c4f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800c51:	5b                   	pop    %ebx
  800c52:	5e                   	pop    %esi
  800c53:	5d                   	pop    %ebp
  800c54:	c3                   	ret    

00800c55 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c55:	55                   	push   %ebp
  800c56:	89 e5                	mov    %esp,%ebp
  800c58:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c5b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c5e:	0f b6 01             	movzbl (%ecx),%eax
  800c61:	84 c0                	test   %al,%al
  800c63:	74 15                	je     800c7a <strcmp+0x25>
  800c65:	3a 02                	cmp    (%edx),%al
  800c67:	75 11                	jne    800c7a <strcmp+0x25>
		p++, q++;
  800c69:	83 c1 01             	add    $0x1,%ecx
  800c6c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800c6f:	0f b6 01             	movzbl (%ecx),%eax
  800c72:	84 c0                	test   %al,%al
  800c74:	74 04                	je     800c7a <strcmp+0x25>
  800c76:	3a 02                	cmp    (%edx),%al
  800c78:	74 ef                	je     800c69 <strcmp+0x14>
  800c7a:	0f b6 c0             	movzbl %al,%eax
  800c7d:	0f b6 12             	movzbl (%edx),%edx
  800c80:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c82:	5d                   	pop    %ebp
  800c83:	c3                   	ret    

00800c84 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c84:	55                   	push   %ebp
  800c85:	89 e5                	mov    %esp,%ebp
  800c87:	53                   	push   %ebx
  800c88:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800c91:	85 c0                	test   %eax,%eax
  800c93:	74 23                	je     800cb8 <strncmp+0x34>
  800c95:	0f b6 1a             	movzbl (%edx),%ebx
  800c98:	84 db                	test   %bl,%bl
  800c9a:	74 25                	je     800cc1 <strncmp+0x3d>
  800c9c:	3a 19                	cmp    (%ecx),%bl
  800c9e:	75 21                	jne    800cc1 <strncmp+0x3d>
  800ca0:	83 e8 01             	sub    $0x1,%eax
  800ca3:	74 13                	je     800cb8 <strncmp+0x34>
		n--, p++, q++;
  800ca5:	83 c2 01             	add    $0x1,%edx
  800ca8:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800cab:	0f b6 1a             	movzbl (%edx),%ebx
  800cae:	84 db                	test   %bl,%bl
  800cb0:	74 0f                	je     800cc1 <strncmp+0x3d>
  800cb2:	3a 19                	cmp    (%ecx),%bl
  800cb4:	74 ea                	je     800ca0 <strncmp+0x1c>
  800cb6:	eb 09                	jmp    800cc1 <strncmp+0x3d>
  800cb8:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800cbd:	5b                   	pop    %ebx
  800cbe:	5d                   	pop    %ebp
  800cbf:	90                   	nop
  800cc0:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800cc1:	0f b6 02             	movzbl (%edx),%eax
  800cc4:	0f b6 11             	movzbl (%ecx),%edx
  800cc7:	29 d0                	sub    %edx,%eax
  800cc9:	eb f2                	jmp    800cbd <strncmp+0x39>

00800ccb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ccb:	55                   	push   %ebp
  800ccc:	89 e5                	mov    %esp,%ebp
  800cce:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cd5:	0f b6 10             	movzbl (%eax),%edx
  800cd8:	84 d2                	test   %dl,%dl
  800cda:	74 18                	je     800cf4 <strchr+0x29>
		if (*s == c)
  800cdc:	38 ca                	cmp    %cl,%dl
  800cde:	75 0a                	jne    800cea <strchr+0x1f>
  800ce0:	eb 17                	jmp    800cf9 <strchr+0x2e>
  800ce2:	38 ca                	cmp    %cl,%dl
  800ce4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ce8:	74 0f                	je     800cf9 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800cea:	83 c0 01             	add    $0x1,%eax
  800ced:	0f b6 10             	movzbl (%eax),%edx
  800cf0:	84 d2                	test   %dl,%dl
  800cf2:	75 ee                	jne    800ce2 <strchr+0x17>
  800cf4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800cf9:	5d                   	pop    %ebp
  800cfa:	c3                   	ret    

00800cfb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800cfb:	55                   	push   %ebp
  800cfc:	89 e5                	mov    %esp,%ebp
  800cfe:	8b 45 08             	mov    0x8(%ebp),%eax
  800d01:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d05:	0f b6 10             	movzbl (%eax),%edx
  800d08:	84 d2                	test   %dl,%dl
  800d0a:	74 18                	je     800d24 <strfind+0x29>
		if (*s == c)
  800d0c:	38 ca                	cmp    %cl,%dl
  800d0e:	75 0a                	jne    800d1a <strfind+0x1f>
  800d10:	eb 12                	jmp    800d24 <strfind+0x29>
  800d12:	38 ca                	cmp    %cl,%dl
  800d14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d18:	74 0a                	je     800d24 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800d1a:	83 c0 01             	add    $0x1,%eax
  800d1d:	0f b6 10             	movzbl (%eax),%edx
  800d20:	84 d2                	test   %dl,%dl
  800d22:	75 ee                	jne    800d12 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800d24:	5d                   	pop    %ebp
  800d25:	c3                   	ret    

00800d26 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d26:	55                   	push   %ebp
  800d27:	89 e5                	mov    %esp,%ebp
  800d29:	83 ec 0c             	sub    $0xc,%esp
  800d2c:	89 1c 24             	mov    %ebx,(%esp)
  800d2f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d33:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800d37:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d3d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800d40:	85 c9                	test   %ecx,%ecx
  800d42:	74 30                	je     800d74 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d44:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d4a:	75 25                	jne    800d71 <memset+0x4b>
  800d4c:	f6 c1 03             	test   $0x3,%cl
  800d4f:	75 20                	jne    800d71 <memset+0x4b>
		c &= 0xFF;
  800d51:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800d54:	89 d3                	mov    %edx,%ebx
  800d56:	c1 e3 08             	shl    $0x8,%ebx
  800d59:	89 d6                	mov    %edx,%esi
  800d5b:	c1 e6 18             	shl    $0x18,%esi
  800d5e:	89 d0                	mov    %edx,%eax
  800d60:	c1 e0 10             	shl    $0x10,%eax
  800d63:	09 f0                	or     %esi,%eax
  800d65:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800d67:	09 d8                	or     %ebx,%eax
  800d69:	c1 e9 02             	shr    $0x2,%ecx
  800d6c:	fc                   	cld    
  800d6d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d6f:	eb 03                	jmp    800d74 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d71:	fc                   	cld    
  800d72:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800d74:	89 f8                	mov    %edi,%eax
  800d76:	8b 1c 24             	mov    (%esp),%ebx
  800d79:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d7d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d81:	89 ec                	mov    %ebp,%esp
  800d83:	5d                   	pop    %ebp
  800d84:	c3                   	ret    

00800d85 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d85:	55                   	push   %ebp
  800d86:	89 e5                	mov    %esp,%ebp
  800d88:	83 ec 08             	sub    $0x8,%esp
  800d8b:	89 34 24             	mov    %esi,(%esp)
  800d8e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800d92:	8b 45 08             	mov    0x8(%ebp),%eax
  800d95:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800d98:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800d9b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800d9d:	39 c6                	cmp    %eax,%esi
  800d9f:	73 35                	jae    800dd6 <memmove+0x51>
  800da1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800da4:	39 d0                	cmp    %edx,%eax
  800da6:	73 2e                	jae    800dd6 <memmove+0x51>
		s += n;
		d += n;
  800da8:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800daa:	f6 c2 03             	test   $0x3,%dl
  800dad:	75 1b                	jne    800dca <memmove+0x45>
  800daf:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800db5:	75 13                	jne    800dca <memmove+0x45>
  800db7:	f6 c1 03             	test   $0x3,%cl
  800dba:	75 0e                	jne    800dca <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800dbc:	83 ef 04             	sub    $0x4,%edi
  800dbf:	8d 72 fc             	lea    -0x4(%edx),%esi
  800dc2:	c1 e9 02             	shr    $0x2,%ecx
  800dc5:	fd                   	std    
  800dc6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800dc8:	eb 09                	jmp    800dd3 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800dca:	83 ef 01             	sub    $0x1,%edi
  800dcd:	8d 72 ff             	lea    -0x1(%edx),%esi
  800dd0:	fd                   	std    
  800dd1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800dd3:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800dd4:	eb 20                	jmp    800df6 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800dd6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ddc:	75 15                	jne    800df3 <memmove+0x6e>
  800dde:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800de4:	75 0d                	jne    800df3 <memmove+0x6e>
  800de6:	f6 c1 03             	test   $0x3,%cl
  800de9:	75 08                	jne    800df3 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800deb:	c1 e9 02             	shr    $0x2,%ecx
  800dee:	fc                   	cld    
  800def:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800df1:	eb 03                	jmp    800df6 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800df3:	fc                   	cld    
  800df4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800df6:	8b 34 24             	mov    (%esp),%esi
  800df9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800dfd:	89 ec                	mov    %ebp,%esp
  800dff:	5d                   	pop    %ebp
  800e00:	c3                   	ret    

00800e01 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800e01:	55                   	push   %ebp
  800e02:	89 e5                	mov    %esp,%ebp
  800e04:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800e07:	8b 45 10             	mov    0x10(%ebp),%eax
  800e0a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e0e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e11:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e15:	8b 45 08             	mov    0x8(%ebp),%eax
  800e18:	89 04 24             	mov    %eax,(%esp)
  800e1b:	e8 65 ff ff ff       	call   800d85 <memmove>
}
  800e20:	c9                   	leave  
  800e21:	c3                   	ret    

00800e22 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e22:	55                   	push   %ebp
  800e23:	89 e5                	mov    %esp,%ebp
  800e25:	57                   	push   %edi
  800e26:	56                   	push   %esi
  800e27:	53                   	push   %ebx
  800e28:	8b 75 08             	mov    0x8(%ebp),%esi
  800e2b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800e2e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e31:	85 c9                	test   %ecx,%ecx
  800e33:	74 36                	je     800e6b <memcmp+0x49>
		if (*s1 != *s2)
  800e35:	0f b6 06             	movzbl (%esi),%eax
  800e38:	0f b6 1f             	movzbl (%edi),%ebx
  800e3b:	38 d8                	cmp    %bl,%al
  800e3d:	74 20                	je     800e5f <memcmp+0x3d>
  800e3f:	eb 14                	jmp    800e55 <memcmp+0x33>
  800e41:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800e46:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800e4b:	83 c2 01             	add    $0x1,%edx
  800e4e:	83 e9 01             	sub    $0x1,%ecx
  800e51:	38 d8                	cmp    %bl,%al
  800e53:	74 12                	je     800e67 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800e55:	0f b6 c0             	movzbl %al,%eax
  800e58:	0f b6 db             	movzbl %bl,%ebx
  800e5b:	29 d8                	sub    %ebx,%eax
  800e5d:	eb 11                	jmp    800e70 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e5f:	83 e9 01             	sub    $0x1,%ecx
  800e62:	ba 00 00 00 00       	mov    $0x0,%edx
  800e67:	85 c9                	test   %ecx,%ecx
  800e69:	75 d6                	jne    800e41 <memcmp+0x1f>
  800e6b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800e70:	5b                   	pop    %ebx
  800e71:	5e                   	pop    %esi
  800e72:	5f                   	pop    %edi
  800e73:	5d                   	pop    %ebp
  800e74:	c3                   	ret    

00800e75 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e75:	55                   	push   %ebp
  800e76:	89 e5                	mov    %esp,%ebp
  800e78:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800e7b:	89 c2                	mov    %eax,%edx
  800e7d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800e80:	39 d0                	cmp    %edx,%eax
  800e82:	73 15                	jae    800e99 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e84:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800e88:	38 08                	cmp    %cl,(%eax)
  800e8a:	75 06                	jne    800e92 <memfind+0x1d>
  800e8c:	eb 0b                	jmp    800e99 <memfind+0x24>
  800e8e:	38 08                	cmp    %cl,(%eax)
  800e90:	74 07                	je     800e99 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800e92:	83 c0 01             	add    $0x1,%eax
  800e95:	39 c2                	cmp    %eax,%edx
  800e97:	77 f5                	ja     800e8e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800e99:	5d                   	pop    %ebp
  800e9a:	c3                   	ret    

00800e9b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e9b:	55                   	push   %ebp
  800e9c:	89 e5                	mov    %esp,%ebp
  800e9e:	57                   	push   %edi
  800e9f:	56                   	push   %esi
  800ea0:	53                   	push   %ebx
  800ea1:	83 ec 04             	sub    $0x4,%esp
  800ea4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800eaa:	0f b6 02             	movzbl (%edx),%eax
  800ead:	3c 20                	cmp    $0x20,%al
  800eaf:	74 04                	je     800eb5 <strtol+0x1a>
  800eb1:	3c 09                	cmp    $0x9,%al
  800eb3:	75 0e                	jne    800ec3 <strtol+0x28>
		s++;
  800eb5:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800eb8:	0f b6 02             	movzbl (%edx),%eax
  800ebb:	3c 20                	cmp    $0x20,%al
  800ebd:	74 f6                	je     800eb5 <strtol+0x1a>
  800ebf:	3c 09                	cmp    $0x9,%al
  800ec1:	74 f2                	je     800eb5 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ec3:	3c 2b                	cmp    $0x2b,%al
  800ec5:	75 0c                	jne    800ed3 <strtol+0x38>
		s++;
  800ec7:	83 c2 01             	add    $0x1,%edx
  800eca:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800ed1:	eb 15                	jmp    800ee8 <strtol+0x4d>
	else if (*s == '-')
  800ed3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800eda:	3c 2d                	cmp    $0x2d,%al
  800edc:	75 0a                	jne    800ee8 <strtol+0x4d>
		s++, neg = 1;
  800ede:	83 c2 01             	add    $0x1,%edx
  800ee1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ee8:	85 db                	test   %ebx,%ebx
  800eea:	0f 94 c0             	sete   %al
  800eed:	74 05                	je     800ef4 <strtol+0x59>
  800eef:	83 fb 10             	cmp    $0x10,%ebx
  800ef2:	75 18                	jne    800f0c <strtol+0x71>
  800ef4:	80 3a 30             	cmpb   $0x30,(%edx)
  800ef7:	75 13                	jne    800f0c <strtol+0x71>
  800ef9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800efd:	8d 76 00             	lea    0x0(%esi),%esi
  800f00:	75 0a                	jne    800f0c <strtol+0x71>
		s += 2, base = 16;
  800f02:	83 c2 02             	add    $0x2,%edx
  800f05:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f0a:	eb 15                	jmp    800f21 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f0c:	84 c0                	test   %al,%al
  800f0e:	66 90                	xchg   %ax,%ax
  800f10:	74 0f                	je     800f21 <strtol+0x86>
  800f12:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800f17:	80 3a 30             	cmpb   $0x30,(%edx)
  800f1a:	75 05                	jne    800f21 <strtol+0x86>
		s++, base = 8;
  800f1c:	83 c2 01             	add    $0x1,%edx
  800f1f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f21:	b8 00 00 00 00       	mov    $0x0,%eax
  800f26:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f28:	0f b6 0a             	movzbl (%edx),%ecx
  800f2b:	89 cf                	mov    %ecx,%edi
  800f2d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800f30:	80 fb 09             	cmp    $0x9,%bl
  800f33:	77 08                	ja     800f3d <strtol+0xa2>
			dig = *s - '0';
  800f35:	0f be c9             	movsbl %cl,%ecx
  800f38:	83 e9 30             	sub    $0x30,%ecx
  800f3b:	eb 1e                	jmp    800f5b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800f3d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800f40:	80 fb 19             	cmp    $0x19,%bl
  800f43:	77 08                	ja     800f4d <strtol+0xb2>
			dig = *s - 'a' + 10;
  800f45:	0f be c9             	movsbl %cl,%ecx
  800f48:	83 e9 57             	sub    $0x57,%ecx
  800f4b:	eb 0e                	jmp    800f5b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800f4d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800f50:	80 fb 19             	cmp    $0x19,%bl
  800f53:	77 15                	ja     800f6a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800f55:	0f be c9             	movsbl %cl,%ecx
  800f58:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800f5b:	39 f1                	cmp    %esi,%ecx
  800f5d:	7d 0b                	jge    800f6a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800f5f:	83 c2 01             	add    $0x1,%edx
  800f62:	0f af c6             	imul   %esi,%eax
  800f65:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800f68:	eb be                	jmp    800f28 <strtol+0x8d>
  800f6a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800f6c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f70:	74 05                	je     800f77 <strtol+0xdc>
		*endptr = (char *) s;
  800f72:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800f75:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800f77:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800f7b:	74 04                	je     800f81 <strtol+0xe6>
  800f7d:	89 c8                	mov    %ecx,%eax
  800f7f:	f7 d8                	neg    %eax
}
  800f81:	83 c4 04             	add    $0x4,%esp
  800f84:	5b                   	pop    %ebx
  800f85:	5e                   	pop    %esi
  800f86:	5f                   	pop    %edi
  800f87:	5d                   	pop    %ebp
  800f88:	c3                   	ret    
  800f89:	00 00                	add    %al,(%eax)
  800f8b:	00 00                	add    %al,(%eax)
  800f8d:	00 00                	add    %al,(%eax)
	...

00800f90 <__udivdi3>:
  800f90:	55                   	push   %ebp
  800f91:	89 e5                	mov    %esp,%ebp
  800f93:	57                   	push   %edi
  800f94:	56                   	push   %esi
  800f95:	83 ec 10             	sub    $0x10,%esp
  800f98:	8b 45 14             	mov    0x14(%ebp),%eax
  800f9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f9e:	8b 75 10             	mov    0x10(%ebp),%esi
  800fa1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800fa4:	85 c0                	test   %eax,%eax
  800fa6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  800fa9:	75 35                	jne    800fe0 <__udivdi3+0x50>
  800fab:	39 fe                	cmp    %edi,%esi
  800fad:	77 61                	ja     801010 <__udivdi3+0x80>
  800faf:	85 f6                	test   %esi,%esi
  800fb1:	75 0b                	jne    800fbe <__udivdi3+0x2e>
  800fb3:	b8 01 00 00 00       	mov    $0x1,%eax
  800fb8:	31 d2                	xor    %edx,%edx
  800fba:	f7 f6                	div    %esi
  800fbc:	89 c6                	mov    %eax,%esi
  800fbe:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  800fc1:	31 d2                	xor    %edx,%edx
  800fc3:	89 f8                	mov    %edi,%eax
  800fc5:	f7 f6                	div    %esi
  800fc7:	89 c7                	mov    %eax,%edi
  800fc9:	89 c8                	mov    %ecx,%eax
  800fcb:	f7 f6                	div    %esi
  800fcd:	89 c1                	mov    %eax,%ecx
  800fcf:	89 fa                	mov    %edi,%edx
  800fd1:	89 c8                	mov    %ecx,%eax
  800fd3:	83 c4 10             	add    $0x10,%esp
  800fd6:	5e                   	pop    %esi
  800fd7:	5f                   	pop    %edi
  800fd8:	5d                   	pop    %ebp
  800fd9:	c3                   	ret    
  800fda:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800fe0:	39 f8                	cmp    %edi,%eax
  800fe2:	77 1c                	ja     801000 <__udivdi3+0x70>
  800fe4:	0f bd d0             	bsr    %eax,%edx
  800fe7:	83 f2 1f             	xor    $0x1f,%edx
  800fea:	89 55 f4             	mov    %edx,-0xc(%ebp)
  800fed:	75 39                	jne    801028 <__udivdi3+0x98>
  800fef:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  800ff2:	0f 86 a0 00 00 00    	jbe    801098 <__udivdi3+0x108>
  800ff8:	39 f8                	cmp    %edi,%eax
  800ffa:	0f 82 98 00 00 00    	jb     801098 <__udivdi3+0x108>
  801000:	31 ff                	xor    %edi,%edi
  801002:	31 c9                	xor    %ecx,%ecx
  801004:	89 c8                	mov    %ecx,%eax
  801006:	89 fa                	mov    %edi,%edx
  801008:	83 c4 10             	add    $0x10,%esp
  80100b:	5e                   	pop    %esi
  80100c:	5f                   	pop    %edi
  80100d:	5d                   	pop    %ebp
  80100e:	c3                   	ret    
  80100f:	90                   	nop
  801010:	89 d1                	mov    %edx,%ecx
  801012:	89 fa                	mov    %edi,%edx
  801014:	89 c8                	mov    %ecx,%eax
  801016:	31 ff                	xor    %edi,%edi
  801018:	f7 f6                	div    %esi
  80101a:	89 c1                	mov    %eax,%ecx
  80101c:	89 fa                	mov    %edi,%edx
  80101e:	89 c8                	mov    %ecx,%eax
  801020:	83 c4 10             	add    $0x10,%esp
  801023:	5e                   	pop    %esi
  801024:	5f                   	pop    %edi
  801025:	5d                   	pop    %ebp
  801026:	c3                   	ret    
  801027:	90                   	nop
  801028:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80102c:	89 f2                	mov    %esi,%edx
  80102e:	d3 e0                	shl    %cl,%eax
  801030:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801033:	b8 20 00 00 00       	mov    $0x20,%eax
  801038:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80103b:	89 c1                	mov    %eax,%ecx
  80103d:	d3 ea                	shr    %cl,%edx
  80103f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801043:	0b 55 ec             	or     -0x14(%ebp),%edx
  801046:	d3 e6                	shl    %cl,%esi
  801048:	89 c1                	mov    %eax,%ecx
  80104a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80104d:	89 fe                	mov    %edi,%esi
  80104f:	d3 ee                	shr    %cl,%esi
  801051:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801055:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801058:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80105b:	d3 e7                	shl    %cl,%edi
  80105d:	89 c1                	mov    %eax,%ecx
  80105f:	d3 ea                	shr    %cl,%edx
  801061:	09 d7                	or     %edx,%edi
  801063:	89 f2                	mov    %esi,%edx
  801065:	89 f8                	mov    %edi,%eax
  801067:	f7 75 ec             	divl   -0x14(%ebp)
  80106a:	89 d6                	mov    %edx,%esi
  80106c:	89 c7                	mov    %eax,%edi
  80106e:	f7 65 e8             	mull   -0x18(%ebp)
  801071:	39 d6                	cmp    %edx,%esi
  801073:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801076:	72 30                	jb     8010a8 <__udivdi3+0x118>
  801078:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80107b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80107f:	d3 e2                	shl    %cl,%edx
  801081:	39 c2                	cmp    %eax,%edx
  801083:	73 05                	jae    80108a <__udivdi3+0xfa>
  801085:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801088:	74 1e                	je     8010a8 <__udivdi3+0x118>
  80108a:	89 f9                	mov    %edi,%ecx
  80108c:	31 ff                	xor    %edi,%edi
  80108e:	e9 71 ff ff ff       	jmp    801004 <__udivdi3+0x74>
  801093:	90                   	nop
  801094:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801098:	31 ff                	xor    %edi,%edi
  80109a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80109f:	e9 60 ff ff ff       	jmp    801004 <__udivdi3+0x74>
  8010a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010a8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  8010ab:	31 ff                	xor    %edi,%edi
  8010ad:	89 c8                	mov    %ecx,%eax
  8010af:	89 fa                	mov    %edi,%edx
  8010b1:	83 c4 10             	add    $0x10,%esp
  8010b4:	5e                   	pop    %esi
  8010b5:	5f                   	pop    %edi
  8010b6:	5d                   	pop    %ebp
  8010b7:	c3                   	ret    
	...

008010c0 <__umoddi3>:
  8010c0:	55                   	push   %ebp
  8010c1:	89 e5                	mov    %esp,%ebp
  8010c3:	57                   	push   %edi
  8010c4:	56                   	push   %esi
  8010c5:	83 ec 20             	sub    $0x20,%esp
  8010c8:	8b 55 14             	mov    0x14(%ebp),%edx
  8010cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010ce:	8b 7d 10             	mov    0x10(%ebp),%edi
  8010d1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010d4:	85 d2                	test   %edx,%edx
  8010d6:	89 c8                	mov    %ecx,%eax
  8010d8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8010db:	75 13                	jne    8010f0 <__umoddi3+0x30>
  8010dd:	39 f7                	cmp    %esi,%edi
  8010df:	76 3f                	jbe    801120 <__umoddi3+0x60>
  8010e1:	89 f2                	mov    %esi,%edx
  8010e3:	f7 f7                	div    %edi
  8010e5:	89 d0                	mov    %edx,%eax
  8010e7:	31 d2                	xor    %edx,%edx
  8010e9:	83 c4 20             	add    $0x20,%esp
  8010ec:	5e                   	pop    %esi
  8010ed:	5f                   	pop    %edi
  8010ee:	5d                   	pop    %ebp
  8010ef:	c3                   	ret    
  8010f0:	39 f2                	cmp    %esi,%edx
  8010f2:	77 4c                	ja     801140 <__umoddi3+0x80>
  8010f4:	0f bd ca             	bsr    %edx,%ecx
  8010f7:	83 f1 1f             	xor    $0x1f,%ecx
  8010fa:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8010fd:	75 51                	jne    801150 <__umoddi3+0x90>
  8010ff:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801102:	0f 87 e0 00 00 00    	ja     8011e8 <__umoddi3+0x128>
  801108:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80110b:	29 f8                	sub    %edi,%eax
  80110d:	19 d6                	sbb    %edx,%esi
  80110f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801112:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801115:	89 f2                	mov    %esi,%edx
  801117:	83 c4 20             	add    $0x20,%esp
  80111a:	5e                   	pop    %esi
  80111b:	5f                   	pop    %edi
  80111c:	5d                   	pop    %ebp
  80111d:	c3                   	ret    
  80111e:	66 90                	xchg   %ax,%ax
  801120:	85 ff                	test   %edi,%edi
  801122:	75 0b                	jne    80112f <__umoddi3+0x6f>
  801124:	b8 01 00 00 00       	mov    $0x1,%eax
  801129:	31 d2                	xor    %edx,%edx
  80112b:	f7 f7                	div    %edi
  80112d:	89 c7                	mov    %eax,%edi
  80112f:	89 f0                	mov    %esi,%eax
  801131:	31 d2                	xor    %edx,%edx
  801133:	f7 f7                	div    %edi
  801135:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801138:	f7 f7                	div    %edi
  80113a:	eb a9                	jmp    8010e5 <__umoddi3+0x25>
  80113c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801140:	89 c8                	mov    %ecx,%eax
  801142:	89 f2                	mov    %esi,%edx
  801144:	83 c4 20             	add    $0x20,%esp
  801147:	5e                   	pop    %esi
  801148:	5f                   	pop    %edi
  801149:	5d                   	pop    %ebp
  80114a:	c3                   	ret    
  80114b:	90                   	nop
  80114c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801150:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801154:	d3 e2                	shl    %cl,%edx
  801156:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801159:	ba 20 00 00 00       	mov    $0x20,%edx
  80115e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  801161:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801164:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801168:	89 fa                	mov    %edi,%edx
  80116a:	d3 ea                	shr    %cl,%edx
  80116c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801170:	0b 55 f4             	or     -0xc(%ebp),%edx
  801173:	d3 e7                	shl    %cl,%edi
  801175:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801179:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80117c:	89 f2                	mov    %esi,%edx
  80117e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801181:	89 c7                	mov    %eax,%edi
  801183:	d3 ea                	shr    %cl,%edx
  801185:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801189:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80118c:	89 c2                	mov    %eax,%edx
  80118e:	d3 e6                	shl    %cl,%esi
  801190:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801194:	d3 ea                	shr    %cl,%edx
  801196:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80119a:	09 d6                	or     %edx,%esi
  80119c:	89 f0                	mov    %esi,%eax
  80119e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8011a1:	d3 e7                	shl    %cl,%edi
  8011a3:	89 f2                	mov    %esi,%edx
  8011a5:	f7 75 f4             	divl   -0xc(%ebp)
  8011a8:	89 d6                	mov    %edx,%esi
  8011aa:	f7 65 e8             	mull   -0x18(%ebp)
  8011ad:	39 d6                	cmp    %edx,%esi
  8011af:	72 2b                	jb     8011dc <__umoddi3+0x11c>
  8011b1:	39 c7                	cmp    %eax,%edi
  8011b3:	72 23                	jb     8011d8 <__umoddi3+0x118>
  8011b5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011b9:	29 c7                	sub    %eax,%edi
  8011bb:	19 d6                	sbb    %edx,%esi
  8011bd:	89 f0                	mov    %esi,%eax
  8011bf:	89 f2                	mov    %esi,%edx
  8011c1:	d3 ef                	shr    %cl,%edi
  8011c3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8011c7:	d3 e0                	shl    %cl,%eax
  8011c9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011cd:	09 f8                	or     %edi,%eax
  8011cf:	d3 ea                	shr    %cl,%edx
  8011d1:	83 c4 20             	add    $0x20,%esp
  8011d4:	5e                   	pop    %esi
  8011d5:	5f                   	pop    %edi
  8011d6:	5d                   	pop    %ebp
  8011d7:	c3                   	ret    
  8011d8:	39 d6                	cmp    %edx,%esi
  8011da:	75 d9                	jne    8011b5 <__umoddi3+0xf5>
  8011dc:	2b 45 e8             	sub    -0x18(%ebp),%eax
  8011df:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  8011e2:	eb d1                	jmp    8011b5 <__umoddi3+0xf5>
  8011e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011e8:	39 f2                	cmp    %esi,%edx
  8011ea:	0f 82 18 ff ff ff    	jb     801108 <__umoddi3+0x48>
  8011f0:	e9 1d ff ff ff       	jmp    801112 <__umoddi3+0x52>
