
obj/user/evilhello:     file format elf32-i386


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
  80002c:	e8 1f 00 00 00       	call   800050 <libmain>
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
  800037:	83 ec 18             	sub    $0x18,%esp
	// try to print the kernel entry point as a string!  mua ha ha!
	sys_cputs((char*)0xf010000c, 100);
  80003a:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  800041:	00 
  800042:	c7 04 24 0c 00 10 f0 	movl   $0xf010000c,(%esp)
  800049:	e8 4e 00 00 00       	call   80009c <sys_cputs>
}
  80004e:	c9                   	leave  
  80004f:	c3                   	ret    

00800050 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800050:	55                   	push   %ebp
  800051:	89 e5                	mov    %esp,%ebp
  800053:	83 ec 18             	sub    $0x18,%esp
  800056:	8b 45 08             	mov    0x8(%ebp),%eax
  800059:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80005c:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800063:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800066:	85 c0                	test   %eax,%eax
  800068:	7e 08                	jle    800072 <libmain+0x22>
		binaryname = argv[0];
  80006a:	8b 0a                	mov    (%edx),%ecx
  80006c:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  800072:	89 54 24 04          	mov    %edx,0x4(%esp)
  800076:	89 04 24             	mov    %eax,(%esp)
  800079:	e8 b6 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80007e:	e8 05 00 00 00       	call   800088 <exit>
}
  800083:	c9                   	leave  
  800084:	c3                   	ret    
  800085:	00 00                	add    %al,(%eax)
	...

00800088 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800088:	55                   	push   %ebp
  800089:	89 e5                	mov    %esp,%ebp
  80008b:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80008e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800095:	e8 12 01 00 00       	call   8001ac <sys_env_destroy>
}
  80009a:	c9                   	leave  
  80009b:	c3                   	ret    

0080009c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009c:	55                   	push   %ebp
  80009d:	89 e5                	mov    %esp,%ebp
  80009f:	83 ec 08             	sub    $0x8,%esp
  8000a2:	89 1c 24             	mov    %ebx,(%esp)
  8000a5:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8000a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b4:	89 c3                	mov    %eax,%ebx
  8000b6:	89 c7                	mov    %eax,%edi
  8000b8:	51                   	push   %ecx
  8000b9:	52                   	push   %edx
  8000ba:	53                   	push   %ebx
  8000bb:	54                   	push   %esp
  8000bc:	55                   	push   %ebp
  8000bd:	56                   	push   %esi
  8000be:	57                   	push   %edi
  8000bf:	5f                   	pop    %edi
  8000c0:	5e                   	pop    %esi
  8000c1:	5d                   	pop    %ebp
  8000c2:	5c                   	pop    %esp
  8000c3:	5b                   	pop    %ebx
  8000c4:	5a                   	pop    %edx
  8000c5:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c6:	8b 1c 24             	mov    (%esp),%ebx
  8000c9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8000cd:	89 ec                	mov    %ebp,%esp
  8000cf:	5d                   	pop    %ebp
  8000d0:	c3                   	ret    

008000d1 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d1:	55                   	push   %ebp
  8000d2:	89 e5                	mov    %esp,%ebp
  8000d4:	83 ec 08             	sub    $0x8,%esp
  8000d7:	89 1c 24             	mov    %ebx,(%esp)
  8000da:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8000de:	ba 00 00 00 00       	mov    $0x0,%edx
  8000e3:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e8:	89 d1                	mov    %edx,%ecx
  8000ea:	89 d3                	mov    %edx,%ebx
  8000ec:	89 d7                	mov    %edx,%edi
  8000ee:	51                   	push   %ecx
  8000ef:	52                   	push   %edx
  8000f0:	53                   	push   %ebx
  8000f1:	54                   	push   %esp
  8000f2:	55                   	push   %ebp
  8000f3:	56                   	push   %esi
  8000f4:	57                   	push   %edi
  8000f5:	5f                   	pop    %edi
  8000f6:	5e                   	pop    %esi
  8000f7:	5d                   	pop    %ebp
  8000f8:	5c                   	pop    %esp
  8000f9:	5b                   	pop    %ebx
  8000fa:	5a                   	pop    %edx
  8000fb:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000fc:	8b 1c 24             	mov    (%esp),%ebx
  8000ff:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800103:	89 ec                	mov    %ebp,%esp
  800105:	5d                   	pop    %ebp
  800106:	c3                   	ret    

00800107 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800107:	55                   	push   %ebp
  800108:	89 e5                	mov    %esp,%ebp
  80010a:	83 ec 08             	sub    $0x8,%esp
  80010d:	89 1c 24             	mov    %ebx,(%esp)
  800110:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800114:	ba 00 00 00 00       	mov    $0x0,%edx
  800119:	b8 02 00 00 00       	mov    $0x2,%eax
  80011e:	89 d1                	mov    %edx,%ecx
  800120:	89 d3                	mov    %edx,%ebx
  800122:	89 d7                	mov    %edx,%edi
  800124:	51                   	push   %ecx
  800125:	52                   	push   %edx
  800126:	53                   	push   %ebx
  800127:	54                   	push   %esp
  800128:	55                   	push   %ebp
  800129:	56                   	push   %esi
  80012a:	57                   	push   %edi
  80012b:	5f                   	pop    %edi
  80012c:	5e                   	pop    %esi
  80012d:	5d                   	pop    %ebp
  80012e:	5c                   	pop    %esp
  80012f:	5b                   	pop    %ebx
  800130:	5a                   	pop    %edx
  800131:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800132:	8b 1c 24             	mov    (%esp),%ebx
  800135:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800139:	89 ec                	mov    %ebp,%esp
  80013b:	5d                   	pop    %ebp
  80013c:	c3                   	ret    

0080013d <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  80013d:	55                   	push   %ebp
  80013e:	89 e5                	mov    %esp,%ebp
  800140:	83 ec 08             	sub    $0x8,%esp
  800143:	89 1c 24             	mov    %ebx,(%esp)
  800146:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80014a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80014f:	b8 04 00 00 00       	mov    $0x4,%eax
  800154:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800157:	8b 55 08             	mov    0x8(%ebp),%edx
  80015a:	89 df                	mov    %ebx,%edi
  80015c:	51                   	push   %ecx
  80015d:	52                   	push   %edx
  80015e:	53                   	push   %ebx
  80015f:	54                   	push   %esp
  800160:	55                   	push   %ebp
  800161:	56                   	push   %esi
  800162:	57                   	push   %edi
  800163:	5f                   	pop    %edi
  800164:	5e                   	pop    %esi
  800165:	5d                   	pop    %ebp
  800166:	5c                   	pop    %esp
  800167:	5b                   	pop    %ebx
  800168:	5a                   	pop    %edx
  800169:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  80016a:	8b 1c 24             	mov    (%esp),%ebx
  80016d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800171:	89 ec                	mov    %ebp,%esp
  800173:	5d                   	pop    %ebp
  800174:	c3                   	ret    

00800175 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  800175:	55                   	push   %ebp
  800176:	89 e5                	mov    %esp,%ebp
  800178:	83 ec 08             	sub    $0x8,%esp
  80017b:	89 1c 24             	mov    %ebx,(%esp)
  80017e:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800182:	b9 00 00 00 00       	mov    $0x0,%ecx
  800187:	b8 05 00 00 00       	mov    $0x5,%eax
  80018c:	8b 55 08             	mov    0x8(%ebp),%edx
  80018f:	89 cb                	mov    %ecx,%ebx
  800191:	89 cf                	mov    %ecx,%edi
  800193:	51                   	push   %ecx
  800194:	52                   	push   %edx
  800195:	53                   	push   %ebx
  800196:	54                   	push   %esp
  800197:	55                   	push   %ebp
  800198:	56                   	push   %esi
  800199:	57                   	push   %edi
  80019a:	5f                   	pop    %edi
  80019b:	5e                   	pop    %esi
  80019c:	5d                   	pop    %ebp
  80019d:	5c                   	pop    %esp
  80019e:	5b                   	pop    %ebx
  80019f:	5a                   	pop    %edx
  8001a0:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  8001a1:	8b 1c 24             	mov    (%esp),%ebx
  8001a4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8001a8:	89 ec                	mov    %ebp,%esp
  8001aa:	5d                   	pop    %ebp
  8001ab:	c3                   	ret    

008001ac <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  8001ac:	55                   	push   %ebp
  8001ad:	89 e5                	mov    %esp,%ebp
  8001af:	83 ec 28             	sub    $0x28,%esp
  8001b2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8001b5:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8001b8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001bd:	b8 03 00 00 00       	mov    $0x3,%eax
  8001c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c5:	89 cb                	mov    %ecx,%ebx
  8001c7:	89 cf                	mov    %ecx,%edi
  8001c9:	51                   	push   %ecx
  8001ca:	52                   	push   %edx
  8001cb:	53                   	push   %ebx
  8001cc:	54                   	push   %esp
  8001cd:	55                   	push   %ebp
  8001ce:	56                   	push   %esi
  8001cf:	57                   	push   %edi
  8001d0:	5f                   	pop    %edi
  8001d1:	5e                   	pop    %esi
  8001d2:	5d                   	pop    %ebp
  8001d3:	5c                   	pop    %esp
  8001d4:	5b                   	pop    %ebx
  8001d5:	5a                   	pop    %edx
  8001d6:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  8001d7:	85 c0                	test   %eax,%eax
  8001d9:	7e 28                	jle    800203 <sys_env_destroy+0x57>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001db:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001df:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8001e6:	00 
  8001e7:	c7 44 24 08 12 12 80 	movl   $0x801212,0x8(%esp)
  8001ee:	00 
  8001ef:	c7 44 24 04 26 00 00 	movl   $0x26,0x4(%esp)
  8001f6:	00 
  8001f7:	c7 04 24 2f 12 80 00 	movl   $0x80122f,(%esp)
  8001fe:	e8 0d 00 00 00       	call   800210 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800203:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800206:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800209:	89 ec                	mov    %ebp,%esp
  80020b:	5d                   	pop    %ebp
  80020c:	c3                   	ret    
  80020d:	00 00                	add    %al,(%eax)
	...

00800210 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800210:	55                   	push   %ebp
  800211:	89 e5                	mov    %esp,%ebp
  800213:	56                   	push   %esi
  800214:	53                   	push   %ebx
  800215:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  800218:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  80021b:	a1 08 20 80 00       	mov    0x802008,%eax
  800220:	85 c0                	test   %eax,%eax
  800222:	74 10                	je     800234 <_panic+0x24>
		cprintf("%s: ", argv0);
  800224:	89 44 24 04          	mov    %eax,0x4(%esp)
  800228:	c7 04 24 3d 12 80 00 	movl   $0x80123d,(%esp)
  80022f:	e8 ad 00 00 00       	call   8002e1 <cprintf>
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800234:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80023a:	e8 c8 fe ff ff       	call   800107 <sys_getenvid>
  80023f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800242:	89 54 24 10          	mov    %edx,0x10(%esp)
  800246:	8b 55 08             	mov    0x8(%ebp),%edx
  800249:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80024d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800251:	89 44 24 04          	mov    %eax,0x4(%esp)
  800255:	c7 04 24 44 12 80 00 	movl   $0x801244,(%esp)
  80025c:	e8 80 00 00 00       	call   8002e1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800261:	89 74 24 04          	mov    %esi,0x4(%esp)
  800265:	8b 45 10             	mov    0x10(%ebp),%eax
  800268:	89 04 24             	mov    %eax,(%esp)
  80026b:	e8 10 00 00 00       	call   800280 <vcprintf>
	cprintf("\n");
  800270:	c7 04 24 42 12 80 00 	movl   $0x801242,(%esp)
  800277:	e8 65 00 00 00       	call   8002e1 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80027c:	cc                   	int3   
  80027d:	eb fd                	jmp    80027c <_panic+0x6c>
	...

00800280 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800289:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800290:	00 00 00 
	b.cnt = 0;
  800293:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80029a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80029d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002a0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ab:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002b5:	c7 04 24 fb 02 80 00 	movl   $0x8002fb,(%esp)
  8002bc:	e8 ff 02 00 00       	call   8005c0 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002c1:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8002c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002cb:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002d1:	89 04 24             	mov    %eax,(%esp)
  8002d4:	e8 c3 fd ff ff       	call   80009c <sys_cputs>

	return b.cnt;
}
  8002d9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002df:	c9                   	leave  
  8002e0:	c3                   	ret    

008002e1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002e1:	55                   	push   %ebp
  8002e2:	89 e5                	mov    %esp,%ebp
  8002e4:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  8002e7:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  8002ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f1:	89 04 24             	mov    %eax,(%esp)
  8002f4:	e8 87 ff ff ff       	call   800280 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002f9:	c9                   	leave  
  8002fa:	c3                   	ret    

008002fb <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002fb:	55                   	push   %ebp
  8002fc:	89 e5                	mov    %esp,%ebp
  8002fe:	53                   	push   %ebx
  8002ff:	83 ec 14             	sub    $0x14,%esp
  800302:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800305:	8b 03                	mov    (%ebx),%eax
  800307:	8b 55 08             	mov    0x8(%ebp),%edx
  80030a:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80030e:	83 c0 01             	add    $0x1,%eax
  800311:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800313:	3d ff 00 00 00       	cmp    $0xff,%eax
  800318:	75 19                	jne    800333 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80031a:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800321:	00 
  800322:	8d 43 08             	lea    0x8(%ebx),%eax
  800325:	89 04 24             	mov    %eax,(%esp)
  800328:	e8 6f fd ff ff       	call   80009c <sys_cputs>
		b->idx = 0;
  80032d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800333:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800337:	83 c4 14             	add    $0x14,%esp
  80033a:	5b                   	pop    %ebx
  80033b:	5d                   	pop    %ebp
  80033c:	c3                   	ret    
  80033d:	00 00                	add    %al,(%eax)
	...

00800340 <printnum_nopad>:

/*
* help function added by Lu to print only the num;
*/
static void printnum_nopad(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int *num_len){
  800340:	55                   	push   %ebp
  800341:	89 e5                	mov    %esp,%ebp
  800343:	83 ec 48             	sub    $0x48,%esp
  800346:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800349:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80034c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80034f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800352:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800355:	8b 45 08             	mov    0x8(%ebp),%eax
  800358:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80035b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80035e:	8b 45 10             	mov    0x10(%ebp),%eax
  800361:	8b 7d 14             	mov    0x14(%ebp),%edi
	if(num >= base){
  800364:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800367:	ba 00 00 00 00       	mov    $0x0,%edx
  80036c:	39 f2                	cmp    %esi,%edx
  80036e:	72 07                	jb     800377 <printnum_nopad+0x37>
  800370:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800373:	39 c8                	cmp    %ecx,%eax
  800375:	77 54                	ja     8003cb <printnum_nopad+0x8b>
		printnum_nopad(putch, putdat, num / base, base, num_len);
  800377:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80037b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80037f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800383:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800387:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80038a:	89 55 cc             	mov    %edx,-0x34(%ebp)
  80038d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800390:	89 54 24 08          	mov    %edx,0x8(%esp)
  800394:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80039b:	00 
  80039c:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80039f:	89 0c 24             	mov    %ecx,(%esp)
  8003a2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003a6:	e8 f5 0b 00 00       	call   800fa0 <__udivdi3>
  8003ab:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8003ae:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  8003b1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8003b5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8003b9:	89 04 24             	mov    %eax,(%esp)
  8003bc:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003c0:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003c3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003c6:	e8 75 ff ff ff       	call   800340 <printnum_nopad>
	}
	*num_len += 1 ;
  8003cb:	83 07 01             	addl   $0x1,(%edi)
	putch("0123456789abcdef"[num % base], putdat);
  8003ce:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8003d1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003d5:	8b 04 24             	mov    (%esp),%eax
  8003d8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8003dc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003df:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8003e2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8003e5:	89 54 24 08          	mov    %edx,0x8(%esp)
  8003e9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003f0:	00 
  8003f1:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8003f4:	89 0c 24             	mov    %ecx,(%esp)
  8003f7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003fb:	e8 d0 0c 00 00       	call   8010d0 <__umoddi3>
  800400:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800403:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800407:	0f be 80 67 12 80 00 	movsbl 0x801267(%eax),%eax
  80040e:	89 04 24             	mov    %eax,(%esp)
  800411:	ff 55 d4             	call   *-0x2c(%ebp)
}
  800414:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800417:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80041a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80041d:	89 ec                	mov    %ebp,%esp
  80041f:	5d                   	pop    %ebp
  800420:	c3                   	ret    

00800421 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800421:	55                   	push   %ebp
  800422:	89 e5                	mov    %esp,%ebp
  800424:	57                   	push   %edi
  800425:	56                   	push   %esi
  800426:	53                   	push   %ebx
  800427:	83 ec 5c             	sub    $0x5c,%esp
  80042a:	89 c7                	mov    %eax,%edi
  80042c:	89 d6                	mov    %edx,%esi
  80042e:	8b 45 08             	mov    0x8(%ebp),%eax
  800431:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800434:	8b 55 0c             	mov    0xc(%ebp),%edx
  800437:	89 55 cc             	mov    %edx,-0x34(%ebp)
  80043a:	8b 45 10             	mov    0x10(%ebp),%eax
  80043d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	if(padc == '-'){
  800440:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  800444:	75 4c                	jne    800492 <printnum+0x71>
		int num_len = 0;
  800446:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		printnum_nopad(putch, putdat, num, base, &num_len);
  80044d:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800450:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800454:	89 44 24 08          	mov    %eax,0x8(%esp)
  800458:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80045b:	89 0c 24             	mov    %ecx,(%esp)
  80045e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800461:	89 44 24 04          	mov    %eax,0x4(%esp)
  800465:	89 f2                	mov    %esi,%edx
  800467:	89 f8                	mov    %edi,%eax
  800469:	e8 d2 fe ff ff       	call   800340 <printnum_nopad>
		width -= num_len;
  80046e:	2b 5d e4             	sub    -0x1c(%ebp),%ebx
		while (width-- > 0)
  800471:	85 db                	test   %ebx,%ebx
  800473:	0f 8e e8 00 00 00    	jle    800561 <printnum+0x140>
			putch(' ', putdat);
  800479:	89 74 24 04          	mov    %esi,0x4(%esp)
  80047d:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800484:	ff d7                	call   *%edi
  800486:	83 eb 01             	sub    $0x1,%ebx
	// your code here:
	if(padc == '-'){
		int num_len = 0;
		printnum_nopad(putch, putdat, num, base, &num_len);
		width -= num_len;
		while (width-- > 0)
  800489:	85 db                	test   %ebx,%ebx
  80048b:	7f ec                	jg     800479 <printnum+0x58>
  80048d:	e9 cf 00 00 00       	jmp    800561 <printnum+0x140>
			putch(' ', putdat);
	}
	else{
		// first recursively print all preceding (more significant) digits
		if (num >= base) {
  800492:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  800495:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800499:	77 19                	ja     8004b4 <printnum+0x93>
  80049b:	90                   	nop
  80049c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8004a0:	72 05                	jb     8004a7 <printnum+0x86>
  8004a2:	39 45 c8             	cmp    %eax,-0x38(%ebp)
  8004a5:	73 0d                	jae    8004b4 <printnum+0x93>
			printnum(putch, putdat, num / base, base, width - 1, padc);
		} else {
			// print any needed pad characters before first digit
			while (--width > 0)
  8004a7:	83 eb 01             	sub    $0x1,%ebx
  8004aa:	85 db                	test   %ebx,%ebx
  8004ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8004b0:	7f 63                	jg     800515 <printnum+0xf4>
  8004b2:	eb 74                	jmp    800528 <printnum+0x107>
			putch(' ', putdat);
	}
	else{
		// first recursively print all preceding (more significant) digits
		if (num >= base) {
			printnum(putch, putdat, num / base, base, width - 1, padc);
  8004b4:	8b 55 18             	mov    0x18(%ebp),%edx
  8004b7:	89 54 24 10          	mov    %edx,0x10(%esp)
  8004bb:	83 eb 01             	sub    $0x1,%ebx
  8004be:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8004c2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004c6:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8004ca:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8004ce:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8004d1:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8004d4:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  8004d7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8004db:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004e2:	00 
  8004e3:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8004e6:	89 04 24             	mov    %eax,(%esp)
  8004e9:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8004ec:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004f0:	e8 ab 0a 00 00       	call   800fa0 <__udivdi3>
  8004f5:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8004f8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8004fb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8004ff:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800503:	89 04 24             	mov    %eax,(%esp)
  800506:	89 54 24 04          	mov    %edx,0x4(%esp)
  80050a:	89 f2                	mov    %esi,%edx
  80050c:	89 f8                	mov    %edi,%eax
  80050e:	e8 0e ff ff ff       	call   800421 <printnum>
  800513:	eb 13                	jmp    800528 <printnum+0x107>
		} else {
			// print any needed pad characters before first digit
			while (--width > 0)
				putch(padc, putdat);
  800515:	89 74 24 04          	mov    %esi,0x4(%esp)
  800519:	8b 45 18             	mov    0x18(%ebp),%eax
  80051c:	89 04 24             	mov    %eax,(%esp)
  80051f:	ff d7                	call   *%edi
		// first recursively print all preceding (more significant) digits
		if (num >= base) {
			printnum(putch, putdat, num / base, base, width - 1, padc);
		} else {
			// print any needed pad characters before first digit
			while (--width > 0)
  800521:	83 eb 01             	sub    $0x1,%ebx
  800524:	85 db                	test   %ebx,%ebx
  800526:	7f ed                	jg     800515 <printnum+0xf4>
				putch(padc, putdat);
		}

		// then print this (the least significant) digit
		putch("0123456789abcdef"[num % base], putdat);
  800528:	89 74 24 04          	mov    %esi,0x4(%esp)
  80052c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800530:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800533:	89 54 24 08          	mov    %edx,0x8(%esp)
  800537:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80053e:	00 
  80053f:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800542:	89 0c 24             	mov    %ecx,(%esp)
  800545:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800548:	89 44 24 04          	mov    %eax,0x4(%esp)
  80054c:	e8 7f 0b 00 00       	call   8010d0 <__umoddi3>
  800551:	89 74 24 04          	mov    %esi,0x4(%esp)
  800555:	0f be 80 67 12 80 00 	movsbl 0x801267(%eax),%eax
  80055c:	89 04 24             	mov    %eax,(%esp)
  80055f:	ff d7                	call   *%edi
	}
	
}
  800561:	83 c4 5c             	add    $0x5c,%esp
  800564:	5b                   	pop    %ebx
  800565:	5e                   	pop    %esi
  800566:	5f                   	pop    %edi
  800567:	5d                   	pop    %ebp
  800568:	c3                   	ret    

00800569 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800569:	55                   	push   %ebp
  80056a:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80056c:	83 fa 01             	cmp    $0x1,%edx
  80056f:	7e 0e                	jle    80057f <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800571:	8b 10                	mov    (%eax),%edx
  800573:	8d 4a 08             	lea    0x8(%edx),%ecx
  800576:	89 08                	mov    %ecx,(%eax)
  800578:	8b 02                	mov    (%edx),%eax
  80057a:	8b 52 04             	mov    0x4(%edx),%edx
  80057d:	eb 22                	jmp    8005a1 <getuint+0x38>
	else if (lflag)
  80057f:	85 d2                	test   %edx,%edx
  800581:	74 10                	je     800593 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800583:	8b 10                	mov    (%eax),%edx
  800585:	8d 4a 04             	lea    0x4(%edx),%ecx
  800588:	89 08                	mov    %ecx,(%eax)
  80058a:	8b 02                	mov    (%edx),%eax
  80058c:	ba 00 00 00 00       	mov    $0x0,%edx
  800591:	eb 0e                	jmp    8005a1 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800593:	8b 10                	mov    (%eax),%edx
  800595:	8d 4a 04             	lea    0x4(%edx),%ecx
  800598:	89 08                	mov    %ecx,(%eax)
  80059a:	8b 02                	mov    (%edx),%eax
  80059c:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8005a1:	5d                   	pop    %ebp
  8005a2:	c3                   	ret    

008005a3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005a3:	55                   	push   %ebp
  8005a4:	89 e5                	mov    %esp,%ebp
  8005a6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005a9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8005ad:	8b 10                	mov    (%eax),%edx
  8005af:	3b 50 04             	cmp    0x4(%eax),%edx
  8005b2:	73 0a                	jae    8005be <sprintputch+0x1b>
		*b->buf++ = ch;
  8005b4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8005b7:	88 0a                	mov    %cl,(%edx)
  8005b9:	83 c2 01             	add    $0x1,%edx
  8005bc:	89 10                	mov    %edx,(%eax)
}
  8005be:	5d                   	pop    %ebp
  8005bf:	c3                   	ret    

008005c0 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8005c0:	55                   	push   %ebp
  8005c1:	89 e5                	mov    %esp,%ebp
  8005c3:	57                   	push   %edi
  8005c4:	56                   	push   %esi
  8005c5:	53                   	push   %ebx
  8005c6:	83 ec 5c             	sub    $0x5c,%esp
  8005c9:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8005cc:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8005cf:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8005d6:	eb 12                	jmp    8005ea <vprintfmt+0x2a>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8005d8:	85 c0                	test   %eax,%eax
  8005da:	0f 84 c6 04 00 00    	je     800aa6 <vprintfmt+0x4e6>
				return;
			putch(ch, putdat);
  8005e0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005e4:	89 04 24             	mov    %eax,(%esp)
  8005e7:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005ea:	0f b6 03             	movzbl (%ebx),%eax
  8005ed:	83 c3 01             	add    $0x1,%ebx
  8005f0:	83 f8 25             	cmp    $0x25,%eax
  8005f3:	75 e3                	jne    8005d8 <vprintfmt+0x18>
  8005f5:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  8005f9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800600:	be ff ff ff ff       	mov    $0xffffffff,%esi
  800605:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  80060c:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800613:	eb 06                	jmp    80061b <vprintfmt+0x5b>
  800615:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  800619:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80061b:	0f b6 0b             	movzbl (%ebx),%ecx
  80061e:	0f b6 d1             	movzbl %cl,%edx
  800621:	8d 43 01             	lea    0x1(%ebx),%eax
  800624:	83 e9 23             	sub    $0x23,%ecx
  800627:	80 f9 55             	cmp    $0x55,%cl
  80062a:	0f 87 58 04 00 00    	ja     800a88 <vprintfmt+0x4c8>
  800630:	0f b6 c9             	movzbl %cl,%ecx
  800633:	ff 24 8d 70 13 80 00 	jmp    *0x801370(,%ecx,4)
  80063a:	c6 45 e0 2b          	movb   $0x2b,-0x20(%ebp)
  80063e:	eb d9                	jmp    800619 <vprintfmt+0x59>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800640:	8d 72 d0             	lea    -0x30(%edx),%esi
				ch = *fmt;
  800643:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800646:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800649:	83 f9 09             	cmp    $0x9,%ecx
  80064c:	76 08                	jbe    800656 <vprintfmt+0x96>
  80064e:	eb 40                	jmp    800690 <vprintfmt+0xd0>
  800650:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
			goto reswitch;
  800654:	eb c3                	jmp    800619 <vprintfmt+0x59>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800656:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  800659:	8d 0c b6             	lea    (%esi,%esi,4),%ecx
  80065c:	8d 74 4a d0          	lea    -0x30(%edx,%ecx,2),%esi
				ch = *fmt;
  800660:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800663:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800666:	83 f9 09             	cmp    $0x9,%ecx
  800669:	76 eb                	jbe    800656 <vprintfmt+0x96>
  80066b:	eb 23                	jmp    800690 <vprintfmt+0xd0>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80066d:	8b 55 14             	mov    0x14(%ebp),%edx
  800670:	8d 4a 04             	lea    0x4(%edx),%ecx
  800673:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800676:	8b 32                	mov    (%edx),%esi
			goto process_precision;
  800678:	eb 16                	jmp    800690 <vprintfmt+0xd0>

		case '.':
			if (width < 0)
  80067a:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80067d:	c1 fa 1f             	sar    $0x1f,%edx
  800680:	f7 d2                	not    %edx
  800682:	21 55 dc             	and    %edx,-0x24(%ebp)
  800685:	eb 92                	jmp    800619 <vprintfmt+0x59>
  800687:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  80068e:	eb 89                	jmp    800619 <vprintfmt+0x59>

		process_precision:
			if (width < 0)
  800690:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800694:	79 83                	jns    800619 <vprintfmt+0x59>
  800696:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800699:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80069c:	e9 78 ff ff ff       	jmp    800619 <vprintfmt+0x59>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8006a1:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
			goto reswitch;
  8006a5:	e9 6f ff ff ff       	jmp    800619 <vprintfmt+0x59>
  8006aa:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8006ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b0:	8d 50 04             	lea    0x4(%eax),%edx
  8006b3:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006ba:	8b 00                	mov    (%eax),%eax
  8006bc:	89 04 24             	mov    %eax,(%esp)
  8006bf:	ff 55 08             	call   *0x8(%ebp)
  8006c2:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  8006c5:	e9 20 ff ff ff       	jmp    8005ea <vprintfmt+0x2a>
  8006ca:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8006cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d0:	8d 50 04             	lea    0x4(%eax),%edx
  8006d3:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d6:	8b 00                	mov    (%eax),%eax
  8006d8:	89 c2                	mov    %eax,%edx
  8006da:	c1 fa 1f             	sar    $0x1f,%edx
  8006dd:	31 d0                	xor    %edx,%eax
  8006df:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006e1:	83 f8 06             	cmp    $0x6,%eax
  8006e4:	7f 0b                	jg     8006f1 <vprintfmt+0x131>
  8006e6:	8b 14 85 c8 14 80 00 	mov    0x8014c8(,%eax,4),%edx
  8006ed:	85 d2                	test   %edx,%edx
  8006ef:	75 23                	jne    800714 <vprintfmt+0x154>
				printfmt(putch, putdat, "error %d", err);
  8006f1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006f5:	c7 44 24 08 78 12 80 	movl   $0x801278,0x8(%esp)
  8006fc:	00 
  8006fd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800701:	8b 45 08             	mov    0x8(%ebp),%eax
  800704:	89 04 24             	mov    %eax,(%esp)
  800707:	e8 22 04 00 00       	call   800b2e <printfmt>
  80070c:	8b 5d cc             	mov    -0x34(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80070f:	e9 d6 fe ff ff       	jmp    8005ea <vprintfmt+0x2a>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800714:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800718:	c7 44 24 08 81 12 80 	movl   $0x801281,0x8(%esp)
  80071f:	00 
  800720:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800724:	8b 55 08             	mov    0x8(%ebp),%edx
  800727:	89 14 24             	mov    %edx,(%esp)
  80072a:	e8 ff 03 00 00       	call   800b2e <printfmt>
  80072f:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800732:	e9 b3 fe ff ff       	jmp    8005ea <vprintfmt+0x2a>
  800737:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80073a:	89 c3                	mov    %eax,%ebx
  80073c:	89 f1                	mov    %esi,%ecx
  80073e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800741:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800744:	8b 45 14             	mov    0x14(%ebp),%eax
  800747:	8d 50 04             	lea    0x4(%eax),%edx
  80074a:	89 55 14             	mov    %edx,0x14(%ebp)
  80074d:	8b 00                	mov    (%eax),%eax
  80074f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800752:	85 c0                	test   %eax,%eax
  800754:	75 07                	jne    80075d <vprintfmt+0x19d>
  800756:	c7 45 d0 84 12 80 00 	movl   $0x801284,-0x30(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  80075d:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  800761:	7e 06                	jle    800769 <vprintfmt+0x1a9>
  800763:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  800767:	75 13                	jne    80077c <vprintfmt+0x1bc>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800769:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80076c:	0f be 02             	movsbl (%edx),%eax
  80076f:	85 c0                	test   %eax,%eax
  800771:	0f 85 a2 00 00 00    	jne    800819 <vprintfmt+0x259>
  800777:	e9 8f 00 00 00       	jmp    80080b <vprintfmt+0x24b>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80077c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800780:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800783:	89 0c 24             	mov    %ecx,(%esp)
  800786:	e8 f0 03 00 00       	call   800b7b <strnlen>
  80078b:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80078e:	29 c2                	sub    %eax,%edx
  800790:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800793:	85 d2                	test   %edx,%edx
  800795:	7e d2                	jle    800769 <vprintfmt+0x1a9>
					putch(padc, putdat);
  800797:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  80079b:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  80079e:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  8007a1:	89 d3                	mov    %edx,%ebx
  8007a3:	89 ce                	mov    %ecx,%esi
  8007a5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007a9:	89 34 24             	mov    %esi,(%esp)
  8007ac:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007af:	83 eb 01             	sub    $0x1,%ebx
  8007b2:	85 db                	test   %ebx,%ebx
  8007b4:	7f ef                	jg     8007a5 <vprintfmt+0x1e5>
  8007b6:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  8007b9:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  8007bc:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8007c3:	eb a4                	jmp    800769 <vprintfmt+0x1a9>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8007c5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007c9:	74 1b                	je     8007e6 <vprintfmt+0x226>
  8007cb:	8d 50 e0             	lea    -0x20(%eax),%edx
  8007ce:	83 fa 5e             	cmp    $0x5e,%edx
  8007d1:	76 13                	jbe    8007e6 <vprintfmt+0x226>
					putch('?', putdat);
  8007d3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007da:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8007e1:	ff 55 08             	call   *0x8(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8007e4:	eb 0d                	jmp    8007f3 <vprintfmt+0x233>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8007e6:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8007e9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007ed:	89 04 24             	mov    %eax,(%esp)
  8007f0:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007f3:	83 ef 01             	sub    $0x1,%edi
  8007f6:	0f be 03             	movsbl (%ebx),%eax
  8007f9:	85 c0                	test   %eax,%eax
  8007fb:	74 05                	je     800802 <vprintfmt+0x242>
  8007fd:	83 c3 01             	add    $0x1,%ebx
  800800:	eb 28                	jmp    80082a <vprintfmt+0x26a>
  800802:	89 7d dc             	mov    %edi,-0x24(%ebp)
  800805:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800808:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80080b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80080f:	7f 2d                	jg     80083e <vprintfmt+0x27e>
  800811:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800814:	e9 d1 fd ff ff       	jmp    8005ea <vprintfmt+0x2a>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800819:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80081c:	83 c1 01             	add    $0x1,%ecx
  80081f:	89 7d e0             	mov    %edi,-0x20(%ebp)
  800822:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800825:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  800828:	89 cb                	mov    %ecx,%ebx
  80082a:	85 f6                	test   %esi,%esi
  80082c:	78 97                	js     8007c5 <vprintfmt+0x205>
  80082e:	83 ee 01             	sub    $0x1,%esi
  800831:	79 92                	jns    8007c5 <vprintfmt+0x205>
  800833:	89 7d dc             	mov    %edi,-0x24(%ebp)
  800836:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800839:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  80083c:	eb cd                	jmp    80080b <vprintfmt+0x24b>
  80083e:	8b 75 08             	mov    0x8(%ebp),%esi
  800841:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800844:	8b 5d dc             	mov    -0x24(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800847:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80084b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800852:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800854:	83 eb 01             	sub    $0x1,%ebx
  800857:	85 db                	test   %ebx,%ebx
  800859:	7f ec                	jg     800847 <vprintfmt+0x287>
  80085b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80085e:	e9 87 fd ff ff       	jmp    8005ea <vprintfmt+0x2a>
  800863:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800866:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
  80086a:	88 45 e4             	mov    %al,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80086d:	83 7d d0 01          	cmpl   $0x1,-0x30(%ebp)
  800871:	7e 16                	jle    800889 <vprintfmt+0x2c9>
		return va_arg(*ap, long long);
  800873:	8b 45 14             	mov    0x14(%ebp),%eax
  800876:	8d 50 08             	lea    0x8(%eax),%edx
  800879:	89 55 14             	mov    %edx,0x14(%ebp)
  80087c:	8b 10                	mov    (%eax),%edx
  80087e:	8b 48 04             	mov    0x4(%eax),%ecx
  800881:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800884:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800887:	eb 34                	jmp    8008bd <vprintfmt+0x2fd>
	else if (lflag)
  800889:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80088d:	74 18                	je     8008a7 <vprintfmt+0x2e7>
		return va_arg(*ap, long);
  80088f:	8b 45 14             	mov    0x14(%ebp),%eax
  800892:	8d 50 04             	lea    0x4(%eax),%edx
  800895:	89 55 14             	mov    %edx,0x14(%ebp)
  800898:	8b 00                	mov    (%eax),%eax
  80089a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80089d:	89 c1                	mov    %eax,%ecx
  80089f:	c1 f9 1f             	sar    $0x1f,%ecx
  8008a2:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8008a5:	eb 16                	jmp    8008bd <vprintfmt+0x2fd>
	else
		return va_arg(*ap, int);
  8008a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8008aa:	8d 50 04             	lea    0x4(%eax),%edx
  8008ad:	89 55 14             	mov    %edx,0x14(%ebp)
  8008b0:	8b 00                	mov    (%eax),%eax
  8008b2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8008b5:	89 c2                	mov    %eax,%edx
  8008b7:	c1 fa 1f             	sar    $0x1f,%edx
  8008ba:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8008bd:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8008c0:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if ((long long) num < 0) {
  8008c3:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8008c7:	79 2c                	jns    8008f5 <vprintfmt+0x335>
				putch('-', putdat);
  8008c9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008cd:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8008d4:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8008d7:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8008da:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8008dd:	f7 db                	neg    %ebx
  8008df:	83 d6 00             	adc    $0x0,%esi
  8008e2:	f7 de                	neg    %esi
  8008e4:	0f b6 4d e0          	movzbl -0x20(%ebp),%ecx
  8008e8:	88 4d e4             	mov    %cl,-0x1c(%ebp)
  8008eb:	ba 0a 00 00 00       	mov    $0xa,%edx
  8008f0:	e9 db 00 00 00       	jmp    8009d0 <vprintfmt+0x410>
			}
			else if (padc == '+'){
  8008f5:	80 7d e4 2b          	cmpb   $0x2b,-0x1c(%ebp)
  8008f9:	74 11                	je     80090c <vprintfmt+0x34c>
  8008fb:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
  8008ff:	88 45 e4             	mov    %al,-0x1c(%ebp)
  800902:	ba 0a 00 00 00       	mov    $0xa,%edx
  800907:	e9 c4 00 00 00       	jmp    8009d0 <vprintfmt+0x410>
				putch('+', putdat);
  80090c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800910:	c7 04 24 2b 00 00 00 	movl   $0x2b,(%esp)
  800917:	ff 55 08             	call   *0x8(%ebp)
  80091a:	ba 0a 00 00 00       	mov    $0xa,%edx
  80091f:	e9 ac 00 00 00       	jmp    8009d0 <vprintfmt+0x410>
  800924:	89 45 cc             	mov    %eax,-0x34(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800927:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80092a:	8d 45 14             	lea    0x14(%ebp),%eax
  80092d:	e8 37 fc ff ff       	call   800569 <getuint>
  800932:	89 c3                	mov    %eax,%ebx
  800934:	89 d6                	mov    %edx,%esi
  800936:	0f b6 55 e0          	movzbl -0x20(%ebp),%edx
  80093a:	88 55 e4             	mov    %dl,-0x1c(%ebp)
  80093d:	ba 0a 00 00 00       	mov    $0xa,%edx
			base = 10;
			goto number;
  800942:	e9 89 00 00 00       	jmp    8009d0 <vprintfmt+0x410>
  800947:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) octal
		case 'o':
			putch('0', putdat);
  80094a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80094e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800955:	ff 55 08             	call   *0x8(%ebp)
			num = getuint(&ap, lflag);
  800958:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80095b:	8d 45 14             	lea    0x14(%ebp),%eax
  80095e:	e8 06 fc ff ff       	call   800569 <getuint>
  800963:	89 c3                	mov    %eax,%ebx
  800965:	89 d6                	mov    %edx,%esi
  800967:	0f b6 4d e0          	movzbl -0x20(%ebp),%ecx
  80096b:	88 4d e4             	mov    %cl,-0x1c(%ebp)
  80096e:	ba 08 00 00 00       	mov    $0x8,%edx
			base = 8;
			goto number;
  800973:	eb 5b                	jmp    8009d0 <vprintfmt+0x410>
  800975:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  800978:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80097c:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800983:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800986:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80098a:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800991:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  800994:	8b 45 14             	mov    0x14(%ebp),%eax
  800997:	8d 50 04             	lea    0x4(%eax),%edx
  80099a:	89 55 14             	mov    %edx,0x14(%ebp)
  80099d:	8b 18                	mov    (%eax),%ebx
  80099f:	be 00 00 00 00       	mov    $0x0,%esi
  8009a4:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
  8009a8:	88 45 e4             	mov    %al,-0x1c(%ebp)
  8009ab:	ba 10 00 00 00       	mov    $0x10,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8009b0:	eb 1e                	jmp    8009d0 <vprintfmt+0x410>
  8009b2:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8009b5:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8009b8:	8d 45 14             	lea    0x14(%ebp),%eax
  8009bb:	e8 a9 fb ff ff       	call   800569 <getuint>
  8009c0:	89 c3                	mov    %eax,%ebx
  8009c2:	89 d6                	mov    %edx,%esi
  8009c4:	0f b6 55 e0          	movzbl -0x20(%ebp),%edx
  8009c8:	88 55 e4             	mov    %dl,-0x1c(%ebp)
  8009cb:	ba 10 00 00 00       	mov    $0x10,%edx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8009d0:	0f be 45 e4          	movsbl -0x1c(%ebp),%eax
  8009d4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8009d8:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8009db:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8009df:	89 54 24 08          	mov    %edx,0x8(%esp)
  8009e3:	89 1c 24             	mov    %ebx,(%esp)
  8009e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009ea:	89 fa                	mov    %edi,%edx
  8009ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ef:	e8 2d fa ff ff       	call   800421 <printnum>
  8009f4:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  8009f7:	e9 ee fb ff ff       	jmp    8005ea <vprintfmt+0x2a>
  8009fc:	89 45 cc             	mov    %eax,-0x34(%ebp)
            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
	    	uint32_t *num_now = putdat;
	    	char *ret_va = va_arg(ap, char *);
  8009ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800a02:	8d 50 04             	lea    0x4(%eax),%edx
  800a05:	89 55 14             	mov    %edx,0x14(%ebp)
  800a08:	8b 00                	mov    (%eax),%eax
	    	if(ret_va == NULL){
  800a0a:	85 c0                	test   %eax,%eax
  800a0c:	75 27                	jne    800a35 <vprintfmt+0x475>
				printfmt(putch, putdat, "%s", null_error);
  800a0e:	c7 44 24 0c f4 12 80 	movl   $0x8012f4,0xc(%esp)
  800a15:	00 
  800a16:	c7 44 24 08 81 12 80 	movl   $0x801281,0x8(%esp)
  800a1d:	00 
  800a1e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a22:	8b 45 08             	mov    0x8(%ebp),%eax
  800a25:	89 04 24             	mov    %eax,(%esp)
  800a28:	e8 01 01 00 00       	call   800b2e <printfmt>
  800a2d:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800a30:	e9 b5 fb ff ff       	jmp    8005ea <vprintfmt+0x2a>
	    	}
	    	else if ((*num_now) >> 7 != 0 ){		//how to aurrately discribe overflow?
  800a35:	8b 17                	mov    (%edi),%edx
  800a37:	89 d1                	mov    %edx,%ecx
  800a39:	c1 e9 07             	shr    $0x7,%ecx
  800a3c:	85 c9                	test   %ecx,%ecx
  800a3e:	74 29                	je     800a69 <vprintfmt+0x4a9>
				*ret_va = *(num_now);	//get putdat at first as next print instruction will change ret_va as it's a pointer which means it's dynamic;
  800a40:	88 10                	mov    %dl,(%eax)
				printfmt(putch, putdat, "%s", overflow_error);
  800a42:	c7 44 24 0c 2c 13 80 	movl   $0x80132c,0xc(%esp)
  800a49:	00 
  800a4a:	c7 44 24 08 81 12 80 	movl   $0x801281,0x8(%esp)
  800a51:	00 
  800a52:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a56:	8b 55 08             	mov    0x8(%ebp),%edx
  800a59:	89 14 24             	mov    %edx,(%esp)
  800a5c:	e8 cd 00 00 00       	call   800b2e <printfmt>
  800a61:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800a64:	e9 81 fb ff ff       	jmp    8005ea <vprintfmt+0x2a>
	    	}
	    	else{
				*ret_va = *(num_now);
  800a69:	88 10                	mov    %dl,(%eax)
  800a6b:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800a6e:	e9 77 fb ff ff       	jmp    8005ea <vprintfmt+0x2a>
  800a73:	89 45 cc             	mov    %eax,-0x34(%ebp)
            	break;
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a76:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a7a:	89 14 24             	mov    %edx,(%esp)
  800a7d:	ff 55 08             	call   *0x8(%ebp)
  800a80:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  800a83:	e9 62 fb ff ff       	jmp    8005ea <vprintfmt+0x2a>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a88:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a8c:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800a93:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a96:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800a99:	80 38 25             	cmpb   $0x25,(%eax)
  800a9c:	0f 84 48 fb ff ff    	je     8005ea <vprintfmt+0x2a>
  800aa2:	89 c3                	mov    %eax,%ebx
  800aa4:	eb f0                	jmp    800a96 <vprintfmt+0x4d6>
				/* do nothing */;
			break;
		}
	}
}
  800aa6:	83 c4 5c             	add    $0x5c,%esp
  800aa9:	5b                   	pop    %ebx
  800aaa:	5e                   	pop    %esi
  800aab:	5f                   	pop    %edi
  800aac:	5d                   	pop    %ebp
  800aad:	c3                   	ret    

00800aae <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800aae:	55                   	push   %ebp
  800aaf:	89 e5                	mov    %esp,%ebp
  800ab1:	83 ec 28             	sub    $0x28,%esp
  800ab4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800aba:	85 c0                	test   %eax,%eax
  800abc:	74 04                	je     800ac2 <vsnprintf+0x14>
  800abe:	85 d2                	test   %edx,%edx
  800ac0:	7f 07                	jg     800ac9 <vsnprintf+0x1b>
  800ac2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ac7:	eb 3b                	jmp    800b04 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800ac9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800acc:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800ad0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800ad3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800ada:	8b 45 14             	mov    0x14(%ebp),%eax
  800add:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ae1:	8b 45 10             	mov    0x10(%ebp),%eax
  800ae4:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ae8:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800aeb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aef:	c7 04 24 a3 05 80 00 	movl   $0x8005a3,(%esp)
  800af6:	e8 c5 fa ff ff       	call   8005c0 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800afb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800afe:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b01:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800b04:	c9                   	leave  
  800b05:	c3                   	ret    

00800b06 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b06:	55                   	push   %ebp
  800b07:	89 e5                	mov    %esp,%ebp
  800b09:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800b0c:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800b0f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b13:	8b 45 10             	mov    0x10(%ebp),%eax
  800b16:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b1a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b1d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b21:	8b 45 08             	mov    0x8(%ebp),%eax
  800b24:	89 04 24             	mov    %eax,(%esp)
  800b27:	e8 82 ff ff ff       	call   800aae <vsnprintf>
	va_end(ap);

	return rc;
}
  800b2c:	c9                   	leave  
  800b2d:	c3                   	ret    

00800b2e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800b2e:	55                   	push   %ebp
  800b2f:	89 e5                	mov    %esp,%ebp
  800b31:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800b34:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800b37:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b3b:	8b 45 10             	mov    0x10(%ebp),%eax
  800b3e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b42:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b45:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b49:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4c:	89 04 24             	mov    %eax,(%esp)
  800b4f:	e8 6c fa ff ff       	call   8005c0 <vprintfmt>
	va_end(ap);
}
  800b54:	c9                   	leave  
  800b55:	c3                   	ret    
	...

00800b60 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b60:	55                   	push   %ebp
  800b61:	89 e5                	mov    %esp,%ebp
  800b63:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b66:	b8 00 00 00 00       	mov    $0x0,%eax
  800b6b:	80 3a 00             	cmpb   $0x0,(%edx)
  800b6e:	74 09                	je     800b79 <strlen+0x19>
		n++;
  800b70:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b73:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b77:	75 f7                	jne    800b70 <strlen+0x10>
		n++;
	return n;
}
  800b79:	5d                   	pop    %ebp
  800b7a:	c3                   	ret    

00800b7b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b7b:	55                   	push   %ebp
  800b7c:	89 e5                	mov    %esp,%ebp
  800b7e:	53                   	push   %ebx
  800b7f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b85:	85 c9                	test   %ecx,%ecx
  800b87:	74 19                	je     800ba2 <strnlen+0x27>
  800b89:	80 3b 00             	cmpb   $0x0,(%ebx)
  800b8c:	74 14                	je     800ba2 <strnlen+0x27>
  800b8e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800b93:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b96:	39 c8                	cmp    %ecx,%eax
  800b98:	74 0d                	je     800ba7 <strnlen+0x2c>
  800b9a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800b9e:	75 f3                	jne    800b93 <strnlen+0x18>
  800ba0:	eb 05                	jmp    800ba7 <strnlen+0x2c>
  800ba2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800ba7:	5b                   	pop    %ebx
  800ba8:	5d                   	pop    %ebp
  800ba9:	c3                   	ret    

00800baa <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800baa:	55                   	push   %ebp
  800bab:	89 e5                	mov    %esp,%ebp
  800bad:	53                   	push   %ebx
  800bae:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bb4:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800bb9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800bbd:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800bc0:	83 c2 01             	add    $0x1,%edx
  800bc3:	84 c9                	test   %cl,%cl
  800bc5:	75 f2                	jne    800bb9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800bc7:	5b                   	pop    %ebx
  800bc8:	5d                   	pop    %ebp
  800bc9:	c3                   	ret    

00800bca <strcat>:

char *
strcat(char *dst, const char *src)
{
  800bca:	55                   	push   %ebp
  800bcb:	89 e5                	mov    %esp,%ebp
  800bcd:	53                   	push   %ebx
  800bce:	83 ec 08             	sub    $0x8,%esp
  800bd1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800bd4:	89 1c 24             	mov    %ebx,(%esp)
  800bd7:	e8 84 ff ff ff       	call   800b60 <strlen>
	strcpy(dst + len, src);
  800bdc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bdf:	89 54 24 04          	mov    %edx,0x4(%esp)
  800be3:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800be6:	89 04 24             	mov    %eax,(%esp)
  800be9:	e8 bc ff ff ff       	call   800baa <strcpy>
	return dst;
}
  800bee:	89 d8                	mov    %ebx,%eax
  800bf0:	83 c4 08             	add    $0x8,%esp
  800bf3:	5b                   	pop    %ebx
  800bf4:	5d                   	pop    %ebp
  800bf5:	c3                   	ret    

00800bf6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800bf6:	55                   	push   %ebp
  800bf7:	89 e5                	mov    %esp,%ebp
  800bf9:	56                   	push   %esi
  800bfa:	53                   	push   %ebx
  800bfb:	8b 45 08             	mov    0x8(%ebp),%eax
  800bfe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c01:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c04:	85 f6                	test   %esi,%esi
  800c06:	74 18                	je     800c20 <strncpy+0x2a>
  800c08:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800c0d:	0f b6 1a             	movzbl (%edx),%ebx
  800c10:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800c13:	80 3a 01             	cmpb   $0x1,(%edx)
  800c16:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c19:	83 c1 01             	add    $0x1,%ecx
  800c1c:	39 ce                	cmp    %ecx,%esi
  800c1e:	77 ed                	ja     800c0d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800c20:	5b                   	pop    %ebx
  800c21:	5e                   	pop    %esi
  800c22:	5d                   	pop    %ebp
  800c23:	c3                   	ret    

00800c24 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800c24:	55                   	push   %ebp
  800c25:	89 e5                	mov    %esp,%ebp
  800c27:	56                   	push   %esi
  800c28:	53                   	push   %ebx
  800c29:	8b 75 08             	mov    0x8(%ebp),%esi
  800c2c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c2f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c32:	89 f0                	mov    %esi,%eax
  800c34:	85 c9                	test   %ecx,%ecx
  800c36:	74 27                	je     800c5f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800c38:	83 e9 01             	sub    $0x1,%ecx
  800c3b:	74 1d                	je     800c5a <strlcpy+0x36>
  800c3d:	0f b6 1a             	movzbl (%edx),%ebx
  800c40:	84 db                	test   %bl,%bl
  800c42:	74 16                	je     800c5a <strlcpy+0x36>
			*dst++ = *src++;
  800c44:	88 18                	mov    %bl,(%eax)
  800c46:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c49:	83 e9 01             	sub    $0x1,%ecx
  800c4c:	74 0e                	je     800c5c <strlcpy+0x38>
			*dst++ = *src++;
  800c4e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c51:	0f b6 1a             	movzbl (%edx),%ebx
  800c54:	84 db                	test   %bl,%bl
  800c56:	75 ec                	jne    800c44 <strlcpy+0x20>
  800c58:	eb 02                	jmp    800c5c <strlcpy+0x38>
  800c5a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800c5c:	c6 00 00             	movb   $0x0,(%eax)
  800c5f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800c61:	5b                   	pop    %ebx
  800c62:	5e                   	pop    %esi
  800c63:	5d                   	pop    %ebp
  800c64:	c3                   	ret    

00800c65 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c65:	55                   	push   %ebp
  800c66:	89 e5                	mov    %esp,%ebp
  800c68:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c6b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c6e:	0f b6 01             	movzbl (%ecx),%eax
  800c71:	84 c0                	test   %al,%al
  800c73:	74 15                	je     800c8a <strcmp+0x25>
  800c75:	3a 02                	cmp    (%edx),%al
  800c77:	75 11                	jne    800c8a <strcmp+0x25>
		p++, q++;
  800c79:	83 c1 01             	add    $0x1,%ecx
  800c7c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800c7f:	0f b6 01             	movzbl (%ecx),%eax
  800c82:	84 c0                	test   %al,%al
  800c84:	74 04                	je     800c8a <strcmp+0x25>
  800c86:	3a 02                	cmp    (%edx),%al
  800c88:	74 ef                	je     800c79 <strcmp+0x14>
  800c8a:	0f b6 c0             	movzbl %al,%eax
  800c8d:	0f b6 12             	movzbl (%edx),%edx
  800c90:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c92:	5d                   	pop    %ebp
  800c93:	c3                   	ret    

00800c94 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c94:	55                   	push   %ebp
  800c95:	89 e5                	mov    %esp,%ebp
  800c97:	53                   	push   %ebx
  800c98:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800ca1:	85 c0                	test   %eax,%eax
  800ca3:	74 23                	je     800cc8 <strncmp+0x34>
  800ca5:	0f b6 1a             	movzbl (%edx),%ebx
  800ca8:	84 db                	test   %bl,%bl
  800caa:	74 25                	je     800cd1 <strncmp+0x3d>
  800cac:	3a 19                	cmp    (%ecx),%bl
  800cae:	75 21                	jne    800cd1 <strncmp+0x3d>
  800cb0:	83 e8 01             	sub    $0x1,%eax
  800cb3:	74 13                	je     800cc8 <strncmp+0x34>
		n--, p++, q++;
  800cb5:	83 c2 01             	add    $0x1,%edx
  800cb8:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800cbb:	0f b6 1a             	movzbl (%edx),%ebx
  800cbe:	84 db                	test   %bl,%bl
  800cc0:	74 0f                	je     800cd1 <strncmp+0x3d>
  800cc2:	3a 19                	cmp    (%ecx),%bl
  800cc4:	74 ea                	je     800cb0 <strncmp+0x1c>
  800cc6:	eb 09                	jmp    800cd1 <strncmp+0x3d>
  800cc8:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ccd:	5b                   	pop    %ebx
  800cce:	5d                   	pop    %ebp
  800ccf:	90                   	nop
  800cd0:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800cd1:	0f b6 02             	movzbl (%edx),%eax
  800cd4:	0f b6 11             	movzbl (%ecx),%edx
  800cd7:	29 d0                	sub    %edx,%eax
  800cd9:	eb f2                	jmp    800ccd <strncmp+0x39>

00800cdb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800cdb:	55                   	push   %ebp
  800cdc:	89 e5                	mov    %esp,%ebp
  800cde:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ce5:	0f b6 10             	movzbl (%eax),%edx
  800ce8:	84 d2                	test   %dl,%dl
  800cea:	74 18                	je     800d04 <strchr+0x29>
		if (*s == c)
  800cec:	38 ca                	cmp    %cl,%dl
  800cee:	75 0a                	jne    800cfa <strchr+0x1f>
  800cf0:	eb 17                	jmp    800d09 <strchr+0x2e>
  800cf2:	38 ca                	cmp    %cl,%dl
  800cf4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800cf8:	74 0f                	je     800d09 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800cfa:	83 c0 01             	add    $0x1,%eax
  800cfd:	0f b6 10             	movzbl (%eax),%edx
  800d00:	84 d2                	test   %dl,%dl
  800d02:	75 ee                	jne    800cf2 <strchr+0x17>
  800d04:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800d09:	5d                   	pop    %ebp
  800d0a:	c3                   	ret    

00800d0b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800d0b:	55                   	push   %ebp
  800d0c:	89 e5                	mov    %esp,%ebp
  800d0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d11:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d15:	0f b6 10             	movzbl (%eax),%edx
  800d18:	84 d2                	test   %dl,%dl
  800d1a:	74 18                	je     800d34 <strfind+0x29>
		if (*s == c)
  800d1c:	38 ca                	cmp    %cl,%dl
  800d1e:	75 0a                	jne    800d2a <strfind+0x1f>
  800d20:	eb 12                	jmp    800d34 <strfind+0x29>
  800d22:	38 ca                	cmp    %cl,%dl
  800d24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d28:	74 0a                	je     800d34 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800d2a:	83 c0 01             	add    $0x1,%eax
  800d2d:	0f b6 10             	movzbl (%eax),%edx
  800d30:	84 d2                	test   %dl,%dl
  800d32:	75 ee                	jne    800d22 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800d34:	5d                   	pop    %ebp
  800d35:	c3                   	ret    

00800d36 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d36:	55                   	push   %ebp
  800d37:	89 e5                	mov    %esp,%ebp
  800d39:	83 ec 0c             	sub    $0xc,%esp
  800d3c:	89 1c 24             	mov    %ebx,(%esp)
  800d3f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d43:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800d47:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d4a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d4d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800d50:	85 c9                	test   %ecx,%ecx
  800d52:	74 30                	je     800d84 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d54:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d5a:	75 25                	jne    800d81 <memset+0x4b>
  800d5c:	f6 c1 03             	test   $0x3,%cl
  800d5f:	75 20                	jne    800d81 <memset+0x4b>
		c &= 0xFF;
  800d61:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800d64:	89 d3                	mov    %edx,%ebx
  800d66:	c1 e3 08             	shl    $0x8,%ebx
  800d69:	89 d6                	mov    %edx,%esi
  800d6b:	c1 e6 18             	shl    $0x18,%esi
  800d6e:	89 d0                	mov    %edx,%eax
  800d70:	c1 e0 10             	shl    $0x10,%eax
  800d73:	09 f0                	or     %esi,%eax
  800d75:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800d77:	09 d8                	or     %ebx,%eax
  800d79:	c1 e9 02             	shr    $0x2,%ecx
  800d7c:	fc                   	cld    
  800d7d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d7f:	eb 03                	jmp    800d84 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d81:	fc                   	cld    
  800d82:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800d84:	89 f8                	mov    %edi,%eax
  800d86:	8b 1c 24             	mov    (%esp),%ebx
  800d89:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d8d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d91:	89 ec                	mov    %ebp,%esp
  800d93:	5d                   	pop    %ebp
  800d94:	c3                   	ret    

00800d95 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d95:	55                   	push   %ebp
  800d96:	89 e5                	mov    %esp,%ebp
  800d98:	83 ec 08             	sub    $0x8,%esp
  800d9b:	89 34 24             	mov    %esi,(%esp)
  800d9e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800da2:	8b 45 08             	mov    0x8(%ebp),%eax
  800da5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800da8:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800dab:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800dad:	39 c6                	cmp    %eax,%esi
  800daf:	73 35                	jae    800de6 <memmove+0x51>
  800db1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800db4:	39 d0                	cmp    %edx,%eax
  800db6:	73 2e                	jae    800de6 <memmove+0x51>
		s += n;
		d += n;
  800db8:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800dba:	f6 c2 03             	test   $0x3,%dl
  800dbd:	75 1b                	jne    800dda <memmove+0x45>
  800dbf:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800dc5:	75 13                	jne    800dda <memmove+0x45>
  800dc7:	f6 c1 03             	test   $0x3,%cl
  800dca:	75 0e                	jne    800dda <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800dcc:	83 ef 04             	sub    $0x4,%edi
  800dcf:	8d 72 fc             	lea    -0x4(%edx),%esi
  800dd2:	c1 e9 02             	shr    $0x2,%ecx
  800dd5:	fd                   	std    
  800dd6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800dd8:	eb 09                	jmp    800de3 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800dda:	83 ef 01             	sub    $0x1,%edi
  800ddd:	8d 72 ff             	lea    -0x1(%edx),%esi
  800de0:	fd                   	std    
  800de1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800de3:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800de4:	eb 20                	jmp    800e06 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800de6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800dec:	75 15                	jne    800e03 <memmove+0x6e>
  800dee:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800df4:	75 0d                	jne    800e03 <memmove+0x6e>
  800df6:	f6 c1 03             	test   $0x3,%cl
  800df9:	75 08                	jne    800e03 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800dfb:	c1 e9 02             	shr    $0x2,%ecx
  800dfe:	fc                   	cld    
  800dff:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e01:	eb 03                	jmp    800e06 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800e03:	fc                   	cld    
  800e04:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800e06:	8b 34 24             	mov    (%esp),%esi
  800e09:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e0d:	89 ec                	mov    %ebp,%esp
  800e0f:	5d                   	pop    %ebp
  800e10:	c3                   	ret    

00800e11 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800e11:	55                   	push   %ebp
  800e12:	89 e5                	mov    %esp,%ebp
  800e14:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800e17:	8b 45 10             	mov    0x10(%ebp),%eax
  800e1a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e1e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e21:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e25:	8b 45 08             	mov    0x8(%ebp),%eax
  800e28:	89 04 24             	mov    %eax,(%esp)
  800e2b:	e8 65 ff ff ff       	call   800d95 <memmove>
}
  800e30:	c9                   	leave  
  800e31:	c3                   	ret    

00800e32 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e32:	55                   	push   %ebp
  800e33:	89 e5                	mov    %esp,%ebp
  800e35:	57                   	push   %edi
  800e36:	56                   	push   %esi
  800e37:	53                   	push   %ebx
  800e38:	8b 75 08             	mov    0x8(%ebp),%esi
  800e3b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800e3e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e41:	85 c9                	test   %ecx,%ecx
  800e43:	74 36                	je     800e7b <memcmp+0x49>
		if (*s1 != *s2)
  800e45:	0f b6 06             	movzbl (%esi),%eax
  800e48:	0f b6 1f             	movzbl (%edi),%ebx
  800e4b:	38 d8                	cmp    %bl,%al
  800e4d:	74 20                	je     800e6f <memcmp+0x3d>
  800e4f:	eb 14                	jmp    800e65 <memcmp+0x33>
  800e51:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800e56:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800e5b:	83 c2 01             	add    $0x1,%edx
  800e5e:	83 e9 01             	sub    $0x1,%ecx
  800e61:	38 d8                	cmp    %bl,%al
  800e63:	74 12                	je     800e77 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800e65:	0f b6 c0             	movzbl %al,%eax
  800e68:	0f b6 db             	movzbl %bl,%ebx
  800e6b:	29 d8                	sub    %ebx,%eax
  800e6d:	eb 11                	jmp    800e80 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e6f:	83 e9 01             	sub    $0x1,%ecx
  800e72:	ba 00 00 00 00       	mov    $0x0,%edx
  800e77:	85 c9                	test   %ecx,%ecx
  800e79:	75 d6                	jne    800e51 <memcmp+0x1f>
  800e7b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800e80:	5b                   	pop    %ebx
  800e81:	5e                   	pop    %esi
  800e82:	5f                   	pop    %edi
  800e83:	5d                   	pop    %ebp
  800e84:	c3                   	ret    

00800e85 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e85:	55                   	push   %ebp
  800e86:	89 e5                	mov    %esp,%ebp
  800e88:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800e8b:	89 c2                	mov    %eax,%edx
  800e8d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800e90:	39 d0                	cmp    %edx,%eax
  800e92:	73 15                	jae    800ea9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e94:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800e98:	38 08                	cmp    %cl,(%eax)
  800e9a:	75 06                	jne    800ea2 <memfind+0x1d>
  800e9c:	eb 0b                	jmp    800ea9 <memfind+0x24>
  800e9e:	38 08                	cmp    %cl,(%eax)
  800ea0:	74 07                	je     800ea9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ea2:	83 c0 01             	add    $0x1,%eax
  800ea5:	39 c2                	cmp    %eax,%edx
  800ea7:	77 f5                	ja     800e9e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ea9:	5d                   	pop    %ebp
  800eaa:	c3                   	ret    

00800eab <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800eab:	55                   	push   %ebp
  800eac:	89 e5                	mov    %esp,%ebp
  800eae:	57                   	push   %edi
  800eaf:	56                   	push   %esi
  800eb0:	53                   	push   %ebx
  800eb1:	83 ec 04             	sub    $0x4,%esp
  800eb4:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800eba:	0f b6 02             	movzbl (%edx),%eax
  800ebd:	3c 20                	cmp    $0x20,%al
  800ebf:	74 04                	je     800ec5 <strtol+0x1a>
  800ec1:	3c 09                	cmp    $0x9,%al
  800ec3:	75 0e                	jne    800ed3 <strtol+0x28>
		s++;
  800ec5:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ec8:	0f b6 02             	movzbl (%edx),%eax
  800ecb:	3c 20                	cmp    $0x20,%al
  800ecd:	74 f6                	je     800ec5 <strtol+0x1a>
  800ecf:	3c 09                	cmp    $0x9,%al
  800ed1:	74 f2                	je     800ec5 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ed3:	3c 2b                	cmp    $0x2b,%al
  800ed5:	75 0c                	jne    800ee3 <strtol+0x38>
		s++;
  800ed7:	83 c2 01             	add    $0x1,%edx
  800eda:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800ee1:	eb 15                	jmp    800ef8 <strtol+0x4d>
	else if (*s == '-')
  800ee3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800eea:	3c 2d                	cmp    $0x2d,%al
  800eec:	75 0a                	jne    800ef8 <strtol+0x4d>
		s++, neg = 1;
  800eee:	83 c2 01             	add    $0x1,%edx
  800ef1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ef8:	85 db                	test   %ebx,%ebx
  800efa:	0f 94 c0             	sete   %al
  800efd:	74 05                	je     800f04 <strtol+0x59>
  800eff:	83 fb 10             	cmp    $0x10,%ebx
  800f02:	75 18                	jne    800f1c <strtol+0x71>
  800f04:	80 3a 30             	cmpb   $0x30,(%edx)
  800f07:	75 13                	jne    800f1c <strtol+0x71>
  800f09:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800f0d:	8d 76 00             	lea    0x0(%esi),%esi
  800f10:	75 0a                	jne    800f1c <strtol+0x71>
		s += 2, base = 16;
  800f12:	83 c2 02             	add    $0x2,%edx
  800f15:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f1a:	eb 15                	jmp    800f31 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f1c:	84 c0                	test   %al,%al
  800f1e:	66 90                	xchg   %ax,%ax
  800f20:	74 0f                	je     800f31 <strtol+0x86>
  800f22:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800f27:	80 3a 30             	cmpb   $0x30,(%edx)
  800f2a:	75 05                	jne    800f31 <strtol+0x86>
		s++, base = 8;
  800f2c:	83 c2 01             	add    $0x1,%edx
  800f2f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f31:	b8 00 00 00 00       	mov    $0x0,%eax
  800f36:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f38:	0f b6 0a             	movzbl (%edx),%ecx
  800f3b:	89 cf                	mov    %ecx,%edi
  800f3d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800f40:	80 fb 09             	cmp    $0x9,%bl
  800f43:	77 08                	ja     800f4d <strtol+0xa2>
			dig = *s - '0';
  800f45:	0f be c9             	movsbl %cl,%ecx
  800f48:	83 e9 30             	sub    $0x30,%ecx
  800f4b:	eb 1e                	jmp    800f6b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800f4d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800f50:	80 fb 19             	cmp    $0x19,%bl
  800f53:	77 08                	ja     800f5d <strtol+0xb2>
			dig = *s - 'a' + 10;
  800f55:	0f be c9             	movsbl %cl,%ecx
  800f58:	83 e9 57             	sub    $0x57,%ecx
  800f5b:	eb 0e                	jmp    800f6b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800f5d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800f60:	80 fb 19             	cmp    $0x19,%bl
  800f63:	77 15                	ja     800f7a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800f65:	0f be c9             	movsbl %cl,%ecx
  800f68:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800f6b:	39 f1                	cmp    %esi,%ecx
  800f6d:	7d 0b                	jge    800f7a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800f6f:	83 c2 01             	add    $0x1,%edx
  800f72:	0f af c6             	imul   %esi,%eax
  800f75:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800f78:	eb be                	jmp    800f38 <strtol+0x8d>
  800f7a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800f7c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f80:	74 05                	je     800f87 <strtol+0xdc>
		*endptr = (char *) s;
  800f82:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800f85:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800f87:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800f8b:	74 04                	je     800f91 <strtol+0xe6>
  800f8d:	89 c8                	mov    %ecx,%eax
  800f8f:	f7 d8                	neg    %eax
}
  800f91:	83 c4 04             	add    $0x4,%esp
  800f94:	5b                   	pop    %ebx
  800f95:	5e                   	pop    %esi
  800f96:	5f                   	pop    %edi
  800f97:	5d                   	pop    %ebp
  800f98:	c3                   	ret    
  800f99:	00 00                	add    %al,(%eax)
  800f9b:	00 00                	add    %al,(%eax)
  800f9d:	00 00                	add    %al,(%eax)
	...

00800fa0 <__udivdi3>:
  800fa0:	55                   	push   %ebp
  800fa1:	89 e5                	mov    %esp,%ebp
  800fa3:	57                   	push   %edi
  800fa4:	56                   	push   %esi
  800fa5:	83 ec 10             	sub    $0x10,%esp
  800fa8:	8b 45 14             	mov    0x14(%ebp),%eax
  800fab:	8b 55 08             	mov    0x8(%ebp),%edx
  800fae:	8b 75 10             	mov    0x10(%ebp),%esi
  800fb1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800fb4:	85 c0                	test   %eax,%eax
  800fb6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  800fb9:	75 35                	jne    800ff0 <__udivdi3+0x50>
  800fbb:	39 fe                	cmp    %edi,%esi
  800fbd:	77 61                	ja     801020 <__udivdi3+0x80>
  800fbf:	85 f6                	test   %esi,%esi
  800fc1:	75 0b                	jne    800fce <__udivdi3+0x2e>
  800fc3:	b8 01 00 00 00       	mov    $0x1,%eax
  800fc8:	31 d2                	xor    %edx,%edx
  800fca:	f7 f6                	div    %esi
  800fcc:	89 c6                	mov    %eax,%esi
  800fce:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  800fd1:	31 d2                	xor    %edx,%edx
  800fd3:	89 f8                	mov    %edi,%eax
  800fd5:	f7 f6                	div    %esi
  800fd7:	89 c7                	mov    %eax,%edi
  800fd9:	89 c8                	mov    %ecx,%eax
  800fdb:	f7 f6                	div    %esi
  800fdd:	89 c1                	mov    %eax,%ecx
  800fdf:	89 fa                	mov    %edi,%edx
  800fe1:	89 c8                	mov    %ecx,%eax
  800fe3:	83 c4 10             	add    $0x10,%esp
  800fe6:	5e                   	pop    %esi
  800fe7:	5f                   	pop    %edi
  800fe8:	5d                   	pop    %ebp
  800fe9:	c3                   	ret    
  800fea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ff0:	39 f8                	cmp    %edi,%eax
  800ff2:	77 1c                	ja     801010 <__udivdi3+0x70>
  800ff4:	0f bd d0             	bsr    %eax,%edx
  800ff7:	83 f2 1f             	xor    $0x1f,%edx
  800ffa:	89 55 f4             	mov    %edx,-0xc(%ebp)
  800ffd:	75 39                	jne    801038 <__udivdi3+0x98>
  800fff:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801002:	0f 86 a0 00 00 00    	jbe    8010a8 <__udivdi3+0x108>
  801008:	39 f8                	cmp    %edi,%eax
  80100a:	0f 82 98 00 00 00    	jb     8010a8 <__udivdi3+0x108>
  801010:	31 ff                	xor    %edi,%edi
  801012:	31 c9                	xor    %ecx,%ecx
  801014:	89 c8                	mov    %ecx,%eax
  801016:	89 fa                	mov    %edi,%edx
  801018:	83 c4 10             	add    $0x10,%esp
  80101b:	5e                   	pop    %esi
  80101c:	5f                   	pop    %edi
  80101d:	5d                   	pop    %ebp
  80101e:	c3                   	ret    
  80101f:	90                   	nop
  801020:	89 d1                	mov    %edx,%ecx
  801022:	89 fa                	mov    %edi,%edx
  801024:	89 c8                	mov    %ecx,%eax
  801026:	31 ff                	xor    %edi,%edi
  801028:	f7 f6                	div    %esi
  80102a:	89 c1                	mov    %eax,%ecx
  80102c:	89 fa                	mov    %edi,%edx
  80102e:	89 c8                	mov    %ecx,%eax
  801030:	83 c4 10             	add    $0x10,%esp
  801033:	5e                   	pop    %esi
  801034:	5f                   	pop    %edi
  801035:	5d                   	pop    %ebp
  801036:	c3                   	ret    
  801037:	90                   	nop
  801038:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80103c:	89 f2                	mov    %esi,%edx
  80103e:	d3 e0                	shl    %cl,%eax
  801040:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801043:	b8 20 00 00 00       	mov    $0x20,%eax
  801048:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80104b:	89 c1                	mov    %eax,%ecx
  80104d:	d3 ea                	shr    %cl,%edx
  80104f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801053:	0b 55 ec             	or     -0x14(%ebp),%edx
  801056:	d3 e6                	shl    %cl,%esi
  801058:	89 c1                	mov    %eax,%ecx
  80105a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80105d:	89 fe                	mov    %edi,%esi
  80105f:	d3 ee                	shr    %cl,%esi
  801061:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801065:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801068:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80106b:	d3 e7                	shl    %cl,%edi
  80106d:	89 c1                	mov    %eax,%ecx
  80106f:	d3 ea                	shr    %cl,%edx
  801071:	09 d7                	or     %edx,%edi
  801073:	89 f2                	mov    %esi,%edx
  801075:	89 f8                	mov    %edi,%eax
  801077:	f7 75 ec             	divl   -0x14(%ebp)
  80107a:	89 d6                	mov    %edx,%esi
  80107c:	89 c7                	mov    %eax,%edi
  80107e:	f7 65 e8             	mull   -0x18(%ebp)
  801081:	39 d6                	cmp    %edx,%esi
  801083:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801086:	72 30                	jb     8010b8 <__udivdi3+0x118>
  801088:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80108b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80108f:	d3 e2                	shl    %cl,%edx
  801091:	39 c2                	cmp    %eax,%edx
  801093:	73 05                	jae    80109a <__udivdi3+0xfa>
  801095:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801098:	74 1e                	je     8010b8 <__udivdi3+0x118>
  80109a:	89 f9                	mov    %edi,%ecx
  80109c:	31 ff                	xor    %edi,%edi
  80109e:	e9 71 ff ff ff       	jmp    801014 <__udivdi3+0x74>
  8010a3:	90                   	nop
  8010a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010a8:	31 ff                	xor    %edi,%edi
  8010aa:	b9 01 00 00 00       	mov    $0x1,%ecx
  8010af:	e9 60 ff ff ff       	jmp    801014 <__udivdi3+0x74>
  8010b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010b8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  8010bb:	31 ff                	xor    %edi,%edi
  8010bd:	89 c8                	mov    %ecx,%eax
  8010bf:	89 fa                	mov    %edi,%edx
  8010c1:	83 c4 10             	add    $0x10,%esp
  8010c4:	5e                   	pop    %esi
  8010c5:	5f                   	pop    %edi
  8010c6:	5d                   	pop    %ebp
  8010c7:	c3                   	ret    
	...

008010d0 <__umoddi3>:
  8010d0:	55                   	push   %ebp
  8010d1:	89 e5                	mov    %esp,%ebp
  8010d3:	57                   	push   %edi
  8010d4:	56                   	push   %esi
  8010d5:	83 ec 20             	sub    $0x20,%esp
  8010d8:	8b 55 14             	mov    0x14(%ebp),%edx
  8010db:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010de:	8b 7d 10             	mov    0x10(%ebp),%edi
  8010e1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010e4:	85 d2                	test   %edx,%edx
  8010e6:	89 c8                	mov    %ecx,%eax
  8010e8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8010eb:	75 13                	jne    801100 <__umoddi3+0x30>
  8010ed:	39 f7                	cmp    %esi,%edi
  8010ef:	76 3f                	jbe    801130 <__umoddi3+0x60>
  8010f1:	89 f2                	mov    %esi,%edx
  8010f3:	f7 f7                	div    %edi
  8010f5:	89 d0                	mov    %edx,%eax
  8010f7:	31 d2                	xor    %edx,%edx
  8010f9:	83 c4 20             	add    $0x20,%esp
  8010fc:	5e                   	pop    %esi
  8010fd:	5f                   	pop    %edi
  8010fe:	5d                   	pop    %ebp
  8010ff:	c3                   	ret    
  801100:	39 f2                	cmp    %esi,%edx
  801102:	77 4c                	ja     801150 <__umoddi3+0x80>
  801104:	0f bd ca             	bsr    %edx,%ecx
  801107:	83 f1 1f             	xor    $0x1f,%ecx
  80110a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80110d:	75 51                	jne    801160 <__umoddi3+0x90>
  80110f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801112:	0f 87 e0 00 00 00    	ja     8011f8 <__umoddi3+0x128>
  801118:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80111b:	29 f8                	sub    %edi,%eax
  80111d:	19 d6                	sbb    %edx,%esi
  80111f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801122:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801125:	89 f2                	mov    %esi,%edx
  801127:	83 c4 20             	add    $0x20,%esp
  80112a:	5e                   	pop    %esi
  80112b:	5f                   	pop    %edi
  80112c:	5d                   	pop    %ebp
  80112d:	c3                   	ret    
  80112e:	66 90                	xchg   %ax,%ax
  801130:	85 ff                	test   %edi,%edi
  801132:	75 0b                	jne    80113f <__umoddi3+0x6f>
  801134:	b8 01 00 00 00       	mov    $0x1,%eax
  801139:	31 d2                	xor    %edx,%edx
  80113b:	f7 f7                	div    %edi
  80113d:	89 c7                	mov    %eax,%edi
  80113f:	89 f0                	mov    %esi,%eax
  801141:	31 d2                	xor    %edx,%edx
  801143:	f7 f7                	div    %edi
  801145:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801148:	f7 f7                	div    %edi
  80114a:	eb a9                	jmp    8010f5 <__umoddi3+0x25>
  80114c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801150:	89 c8                	mov    %ecx,%eax
  801152:	89 f2                	mov    %esi,%edx
  801154:	83 c4 20             	add    $0x20,%esp
  801157:	5e                   	pop    %esi
  801158:	5f                   	pop    %edi
  801159:	5d                   	pop    %ebp
  80115a:	c3                   	ret    
  80115b:	90                   	nop
  80115c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801160:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801164:	d3 e2                	shl    %cl,%edx
  801166:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801169:	ba 20 00 00 00       	mov    $0x20,%edx
  80116e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  801171:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801174:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801178:	89 fa                	mov    %edi,%edx
  80117a:	d3 ea                	shr    %cl,%edx
  80117c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801180:	0b 55 f4             	or     -0xc(%ebp),%edx
  801183:	d3 e7                	shl    %cl,%edi
  801185:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801189:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80118c:	89 f2                	mov    %esi,%edx
  80118e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801191:	89 c7                	mov    %eax,%edi
  801193:	d3 ea                	shr    %cl,%edx
  801195:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801199:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80119c:	89 c2                	mov    %eax,%edx
  80119e:	d3 e6                	shl    %cl,%esi
  8011a0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8011a4:	d3 ea                	shr    %cl,%edx
  8011a6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011aa:	09 d6                	or     %edx,%esi
  8011ac:	89 f0                	mov    %esi,%eax
  8011ae:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8011b1:	d3 e7                	shl    %cl,%edi
  8011b3:	89 f2                	mov    %esi,%edx
  8011b5:	f7 75 f4             	divl   -0xc(%ebp)
  8011b8:	89 d6                	mov    %edx,%esi
  8011ba:	f7 65 e8             	mull   -0x18(%ebp)
  8011bd:	39 d6                	cmp    %edx,%esi
  8011bf:	72 2b                	jb     8011ec <__umoddi3+0x11c>
  8011c1:	39 c7                	cmp    %eax,%edi
  8011c3:	72 23                	jb     8011e8 <__umoddi3+0x118>
  8011c5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011c9:	29 c7                	sub    %eax,%edi
  8011cb:	19 d6                	sbb    %edx,%esi
  8011cd:	89 f0                	mov    %esi,%eax
  8011cf:	89 f2                	mov    %esi,%edx
  8011d1:	d3 ef                	shr    %cl,%edi
  8011d3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8011d7:	d3 e0                	shl    %cl,%eax
  8011d9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011dd:	09 f8                	or     %edi,%eax
  8011df:	d3 ea                	shr    %cl,%edx
  8011e1:	83 c4 20             	add    $0x20,%esp
  8011e4:	5e                   	pop    %esi
  8011e5:	5f                   	pop    %edi
  8011e6:	5d                   	pop    %ebp
  8011e7:	c3                   	ret    
  8011e8:	39 d6                	cmp    %edx,%esi
  8011ea:	75 d9                	jne    8011c5 <__umoddi3+0xf5>
  8011ec:	2b 45 e8             	sub    -0x18(%ebp),%eax
  8011ef:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  8011f2:	eb d1                	jmp    8011c5 <__umoddi3+0xf5>
  8011f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011f8:	39 f2                	cmp    %esi,%edx
  8011fa:	0f 82 18 ff ff ff    	jb     801118 <__umoddi3+0x48>
  801200:	e9 1d ff ff ff       	jmp    801122 <__umoddi3+0x52>
