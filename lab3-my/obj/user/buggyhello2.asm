
obj/user/buggyhello2:     file format elf32-i386


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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	sys_cputs(hello, 1024*1024);
  80003a:	c7 44 24 04 00 00 10 	movl   $0x100000,0x4(%esp)
  800041:	00 
  800042:	a1 00 20 80 00       	mov    0x802000,%eax
  800047:	89 04 24             	mov    %eax,(%esp)
  80004a:	e8 51 00 00 00       	call   8000a0 <sys_cputs>
}
  80004f:	c9                   	leave  
  800050:	c3                   	ret    
  800051:	00 00                	add    %al,(%eax)
	...

00800054 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	83 ec 18             	sub    $0x18,%esp
  80005a:	8b 45 08             	mov    0x8(%ebp),%eax
  80005d:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800060:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  800067:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006a:	85 c0                	test   %eax,%eax
  80006c:	7e 08                	jle    800076 <libmain+0x22>
		binaryname = argv[0];
  80006e:	8b 0a                	mov    (%edx),%ecx
  800070:	89 0d 04 20 80 00    	mov    %ecx,0x802004

	// call user main routine
	umain(argc, argv);
  800076:	89 54 24 04          	mov    %edx,0x4(%esp)
  80007a:	89 04 24             	mov    %eax,(%esp)
  80007d:	e8 b2 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800082:	e8 05 00 00 00       	call   80008c <exit>
}
  800087:	c9                   	leave  
  800088:	c3                   	ret    
  800089:	00 00                	add    %al,(%eax)
	...

0080008c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008c:	55                   	push   %ebp
  80008d:	89 e5                	mov    %esp,%ebp
  80008f:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800092:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800099:	e8 12 01 00 00       	call   8001b0 <sys_env_destroy>
}
  80009e:	c9                   	leave  
  80009f:	c3                   	ret    

008000a0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	83 ec 08             	sub    $0x8,%esp
  8000a6:	89 1c 24             	mov    %ebx,(%esp)
  8000a9:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8000ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b8:	89 c3                	mov    %eax,%ebx
  8000ba:	89 c7                	mov    %eax,%edi
  8000bc:	51                   	push   %ecx
  8000bd:	52                   	push   %edx
  8000be:	53                   	push   %ebx
  8000bf:	54                   	push   %esp
  8000c0:	55                   	push   %ebp
  8000c1:	56                   	push   %esi
  8000c2:	57                   	push   %edi
  8000c3:	5f                   	pop    %edi
  8000c4:	5e                   	pop    %esi
  8000c5:	5d                   	pop    %ebp
  8000c6:	5c                   	pop    %esp
  8000c7:	5b                   	pop    %ebx
  8000c8:	5a                   	pop    %edx
  8000c9:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000ca:	8b 1c 24             	mov    (%esp),%ebx
  8000cd:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8000d1:	89 ec                	mov    %ebp,%esp
  8000d3:	5d                   	pop    %ebp
  8000d4:	c3                   	ret    

008000d5 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d5:	55                   	push   %ebp
  8000d6:	89 e5                	mov    %esp,%ebp
  8000d8:	83 ec 08             	sub    $0x8,%esp
  8000db:	89 1c 24             	mov    %ebx,(%esp)
  8000de:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8000e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8000e7:	b8 01 00 00 00       	mov    $0x1,%eax
  8000ec:	89 d1                	mov    %edx,%ecx
  8000ee:	89 d3                	mov    %edx,%ebx
  8000f0:	89 d7                	mov    %edx,%edi
  8000f2:	51                   	push   %ecx
  8000f3:	52                   	push   %edx
  8000f4:	53                   	push   %ebx
  8000f5:	54                   	push   %esp
  8000f6:	55                   	push   %ebp
  8000f7:	56                   	push   %esi
  8000f8:	57                   	push   %edi
  8000f9:	5f                   	pop    %edi
  8000fa:	5e                   	pop    %esi
  8000fb:	5d                   	pop    %ebp
  8000fc:	5c                   	pop    %esp
  8000fd:	5b                   	pop    %ebx
  8000fe:	5a                   	pop    %edx
  8000ff:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800100:	8b 1c 24             	mov    (%esp),%ebx
  800103:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800107:	89 ec                	mov    %ebp,%esp
  800109:	5d                   	pop    %ebp
  80010a:	c3                   	ret    

0080010b <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  80010b:	55                   	push   %ebp
  80010c:	89 e5                	mov    %esp,%ebp
  80010e:	83 ec 08             	sub    $0x8,%esp
  800111:	89 1c 24             	mov    %ebx,(%esp)
  800114:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800118:	ba 00 00 00 00       	mov    $0x0,%edx
  80011d:	b8 02 00 00 00       	mov    $0x2,%eax
  800122:	89 d1                	mov    %edx,%ecx
  800124:	89 d3                	mov    %edx,%ebx
  800126:	89 d7                	mov    %edx,%edi
  800128:	51                   	push   %ecx
  800129:	52                   	push   %edx
  80012a:	53                   	push   %ebx
  80012b:	54                   	push   %esp
  80012c:	55                   	push   %ebp
  80012d:	56                   	push   %esi
  80012e:	57                   	push   %edi
  80012f:	5f                   	pop    %edi
  800130:	5e                   	pop    %esi
  800131:	5d                   	pop    %ebp
  800132:	5c                   	pop    %esp
  800133:	5b                   	pop    %ebx
  800134:	5a                   	pop    %edx
  800135:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800136:	8b 1c 24             	mov    (%esp),%ebx
  800139:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80013d:	89 ec                	mov    %ebp,%esp
  80013f:	5d                   	pop    %ebp
  800140:	c3                   	ret    

00800141 <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800141:	55                   	push   %ebp
  800142:	89 e5                	mov    %esp,%ebp
  800144:	83 ec 08             	sub    $0x8,%esp
  800147:	89 1c 24             	mov    %ebx,(%esp)
  80014a:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80014e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800153:	b8 04 00 00 00       	mov    $0x4,%eax
  800158:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80015b:	8b 55 08             	mov    0x8(%ebp),%edx
  80015e:	89 df                	mov    %ebx,%edi
  800160:	51                   	push   %ecx
  800161:	52                   	push   %edx
  800162:	53                   	push   %ebx
  800163:	54                   	push   %esp
  800164:	55                   	push   %ebp
  800165:	56                   	push   %esi
  800166:	57                   	push   %edi
  800167:	5f                   	pop    %edi
  800168:	5e                   	pop    %esi
  800169:	5d                   	pop    %ebp
  80016a:	5c                   	pop    %esp
  80016b:	5b                   	pop    %ebx
  80016c:	5a                   	pop    %edx
  80016d:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  80016e:	8b 1c 24             	mov    (%esp),%ebx
  800171:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800175:	89 ec                	mov    %ebp,%esp
  800177:	5d                   	pop    %ebp
  800178:	c3                   	ret    

00800179 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  800179:	55                   	push   %ebp
  80017a:	89 e5                	mov    %esp,%ebp
  80017c:	83 ec 08             	sub    $0x8,%esp
  80017f:	89 1c 24             	mov    %ebx,(%esp)
  800182:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800186:	b9 00 00 00 00       	mov    $0x0,%ecx
  80018b:	b8 05 00 00 00       	mov    $0x5,%eax
  800190:	8b 55 08             	mov    0x8(%ebp),%edx
  800193:	89 cb                	mov    %ecx,%ebx
  800195:	89 cf                	mov    %ecx,%edi
  800197:	51                   	push   %ecx
  800198:	52                   	push   %edx
  800199:	53                   	push   %ebx
  80019a:	54                   	push   %esp
  80019b:	55                   	push   %ebp
  80019c:	56                   	push   %esi
  80019d:	57                   	push   %edi
  80019e:	5f                   	pop    %edi
  80019f:	5e                   	pop    %esi
  8001a0:	5d                   	pop    %ebp
  8001a1:	5c                   	pop    %esp
  8001a2:	5b                   	pop    %ebx
  8001a3:	5a                   	pop    %edx
  8001a4:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  8001a5:	8b 1c 24             	mov    (%esp),%ebx
  8001a8:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8001ac:	89 ec                	mov    %ebp,%esp
  8001ae:	5d                   	pop    %ebp
  8001af:	c3                   	ret    

008001b0 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	83 ec 28             	sub    $0x28,%esp
  8001b6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8001b9:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8001bc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001c1:	b8 03 00 00 00       	mov    $0x3,%eax
  8001c6:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c9:	89 cb                	mov    %ecx,%ebx
  8001cb:	89 cf                	mov    %ecx,%edi
  8001cd:	51                   	push   %ecx
  8001ce:	52                   	push   %edx
  8001cf:	53                   	push   %ebx
  8001d0:	54                   	push   %esp
  8001d1:	55                   	push   %ebp
  8001d2:	56                   	push   %esi
  8001d3:	57                   	push   %edi
  8001d4:	5f                   	pop    %edi
  8001d5:	5e                   	pop    %esi
  8001d6:	5d                   	pop    %ebp
  8001d7:	5c                   	pop    %esp
  8001d8:	5b                   	pop    %ebx
  8001d9:	5a                   	pop    %edx
  8001da:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  8001db:	85 c0                	test   %eax,%eax
  8001dd:	7e 28                	jle    800207 <sys_env_destroy+0x57>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001df:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001e3:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8001ea:	00 
  8001eb:	c7 44 24 08 30 12 80 	movl   $0x801230,0x8(%esp)
  8001f2:	00 
  8001f3:	c7 44 24 04 26 00 00 	movl   $0x26,0x4(%esp)
  8001fa:	00 
  8001fb:	c7 04 24 4d 12 80 00 	movl   $0x80124d,(%esp)
  800202:	e8 0d 00 00 00       	call   800214 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800207:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80020a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80020d:	89 ec                	mov    %ebp,%esp
  80020f:	5d                   	pop    %ebp
  800210:	c3                   	ret    
  800211:	00 00                	add    %al,(%eax)
	...

00800214 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
  800217:	56                   	push   %esi
  800218:	53                   	push   %ebx
  800219:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  80021c:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  80021f:	a1 0c 20 80 00       	mov    0x80200c,%eax
  800224:	85 c0                	test   %eax,%eax
  800226:	74 10                	je     800238 <_panic+0x24>
		cprintf("%s: ", argv0);
  800228:	89 44 24 04          	mov    %eax,0x4(%esp)
  80022c:	c7 04 24 5b 12 80 00 	movl   $0x80125b,(%esp)
  800233:	e8 ad 00 00 00       	call   8002e5 <cprintf>
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800238:	8b 1d 04 20 80 00    	mov    0x802004,%ebx
  80023e:	e8 c8 fe ff ff       	call   80010b <sys_getenvid>
  800243:	8b 55 0c             	mov    0xc(%ebp),%edx
  800246:	89 54 24 10          	mov    %edx,0x10(%esp)
  80024a:	8b 55 08             	mov    0x8(%ebp),%edx
  80024d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800251:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800255:	89 44 24 04          	mov    %eax,0x4(%esp)
  800259:	c7 04 24 60 12 80 00 	movl   $0x801260,(%esp)
  800260:	e8 80 00 00 00       	call   8002e5 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800265:	89 74 24 04          	mov    %esi,0x4(%esp)
  800269:	8b 45 10             	mov    0x10(%ebp),%eax
  80026c:	89 04 24             	mov    %eax,(%esp)
  80026f:	e8 10 00 00 00       	call   800284 <vcprintf>
	cprintf("\n");
  800274:	c7 04 24 24 12 80 00 	movl   $0x801224,(%esp)
  80027b:	e8 65 00 00 00       	call   8002e5 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800280:	cc                   	int3   
  800281:	eb fd                	jmp    800280 <_panic+0x6c>
	...

00800284 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800284:	55                   	push   %ebp
  800285:	89 e5                	mov    %esp,%ebp
  800287:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80028d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800294:	00 00 00 
	b.cnt = 0;
  800297:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80029e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002a4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ab:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002af:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002b9:	c7 04 24 ff 02 80 00 	movl   $0x8002ff,(%esp)
  8002c0:	e8 0b 03 00 00       	call   8005d0 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002c5:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8002cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002cf:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002d5:	89 04 24             	mov    %eax,(%esp)
  8002d8:	e8 c3 fd ff ff       	call   8000a0 <sys_cputs>

	return b.cnt;
}
  8002dd:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002e3:	c9                   	leave  
  8002e4:	c3                   	ret    

008002e5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002e5:	55                   	push   %ebp
  8002e6:	89 e5                	mov    %esp,%ebp
  8002e8:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  8002eb:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  8002ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f5:	89 04 24             	mov    %eax,(%esp)
  8002f8:	e8 87 ff ff ff       	call   800284 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002fd:	c9                   	leave  
  8002fe:	c3                   	ret    

008002ff <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002ff:	55                   	push   %ebp
  800300:	89 e5                	mov    %esp,%ebp
  800302:	53                   	push   %ebx
  800303:	83 ec 14             	sub    $0x14,%esp
  800306:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800309:	8b 03                	mov    (%ebx),%eax
  80030b:	8b 55 08             	mov    0x8(%ebp),%edx
  80030e:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800312:	83 c0 01             	add    $0x1,%eax
  800315:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800317:	3d ff 00 00 00       	cmp    $0xff,%eax
  80031c:	75 19                	jne    800337 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80031e:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800325:	00 
  800326:	8d 43 08             	lea    0x8(%ebx),%eax
  800329:	89 04 24             	mov    %eax,(%esp)
  80032c:	e8 6f fd ff ff       	call   8000a0 <sys_cputs>
		b->idx = 0;
  800331:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800337:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80033b:	83 c4 14             	add    $0x14,%esp
  80033e:	5b                   	pop    %ebx
  80033f:	5d                   	pop    %ebp
  800340:	c3                   	ret    
	...

00800350 <printnum_nopad>:

/*
* help function added by Lu to print only the num;
*/
static void printnum_nopad(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int *num_len){
  800350:	55                   	push   %ebp
  800351:	89 e5                	mov    %esp,%ebp
  800353:	83 ec 48             	sub    $0x48,%esp
  800356:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800359:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80035c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80035f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800362:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800365:	8b 45 08             	mov    0x8(%ebp),%eax
  800368:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80036b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80036e:	8b 45 10             	mov    0x10(%ebp),%eax
  800371:	8b 7d 14             	mov    0x14(%ebp),%edi
	if(num >= base){
  800374:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800377:	ba 00 00 00 00       	mov    $0x0,%edx
  80037c:	39 f2                	cmp    %esi,%edx
  80037e:	72 07                	jb     800387 <printnum_nopad+0x37>
  800380:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800383:	39 c8                	cmp    %ecx,%eax
  800385:	77 54                	ja     8003db <printnum_nopad+0x8b>
		printnum_nopad(putch, putdat, num / base, base, num_len);
  800387:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80038b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80038f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800393:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800397:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80039a:	89 55 cc             	mov    %edx,-0x34(%ebp)
  80039d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8003a0:	89 54 24 08          	mov    %edx,0x8(%esp)
  8003a4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003ab:	00 
  8003ac:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8003af:	89 0c 24             	mov    %ecx,(%esp)
  8003b2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003b6:	e8 f5 0b 00 00       	call   800fb0 <__udivdi3>
  8003bb:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8003be:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  8003c1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8003c5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8003c9:	89 04 24             	mov    %eax,(%esp)
  8003cc:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003d0:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003d3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003d6:	e8 75 ff ff ff       	call   800350 <printnum_nopad>
	}
	*num_len += 1 ;
  8003db:	83 07 01             	addl   $0x1,(%edi)
	putch("0123456789abcdef"[num % base], putdat);
  8003de:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8003e1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003e5:	8b 04 24             	mov    (%esp),%eax
  8003e8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8003ec:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003ef:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8003f2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8003f5:	89 54 24 08          	mov    %edx,0x8(%esp)
  8003f9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800400:	00 
  800401:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800404:	89 0c 24             	mov    %ecx,(%esp)
  800407:	89 74 24 04          	mov    %esi,0x4(%esp)
  80040b:	e8 d0 0c 00 00       	call   8010e0 <__umoddi3>
  800410:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800413:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800417:	0f be 80 83 12 80 00 	movsbl 0x801283(%eax),%eax
  80041e:	89 04 24             	mov    %eax,(%esp)
  800421:	ff 55 d4             	call   *-0x2c(%ebp)
}
  800424:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800427:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80042a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80042d:	89 ec                	mov    %ebp,%esp
  80042f:	5d                   	pop    %ebp
  800430:	c3                   	ret    

00800431 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800431:	55                   	push   %ebp
  800432:	89 e5                	mov    %esp,%ebp
  800434:	57                   	push   %edi
  800435:	56                   	push   %esi
  800436:	53                   	push   %ebx
  800437:	83 ec 5c             	sub    $0x5c,%esp
  80043a:	89 c7                	mov    %eax,%edi
  80043c:	89 d6                	mov    %edx,%esi
  80043e:	8b 45 08             	mov    0x8(%ebp),%eax
  800441:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800444:	8b 55 0c             	mov    0xc(%ebp),%edx
  800447:	89 55 cc             	mov    %edx,-0x34(%ebp)
  80044a:	8b 45 10             	mov    0x10(%ebp),%eax
  80044d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	if(padc == '-'){
  800450:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  800454:	75 4c                	jne    8004a2 <printnum+0x71>
		int num_len = 0;
  800456:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		printnum_nopad(putch, putdat, num, base, &num_len);
  80045d:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800460:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800464:	89 44 24 08          	mov    %eax,0x8(%esp)
  800468:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80046b:	89 0c 24             	mov    %ecx,(%esp)
  80046e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800471:	89 44 24 04          	mov    %eax,0x4(%esp)
  800475:	89 f2                	mov    %esi,%edx
  800477:	89 f8                	mov    %edi,%eax
  800479:	e8 d2 fe ff ff       	call   800350 <printnum_nopad>
		width -= num_len;
  80047e:	2b 5d e4             	sub    -0x1c(%ebp),%ebx
		while (width-- > 0)
  800481:	85 db                	test   %ebx,%ebx
  800483:	0f 8e e8 00 00 00    	jle    800571 <printnum+0x140>
			putch(' ', putdat);
  800489:	89 74 24 04          	mov    %esi,0x4(%esp)
  80048d:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800494:	ff d7                	call   *%edi
  800496:	83 eb 01             	sub    $0x1,%ebx
	// your code here:
	if(padc == '-'){
		int num_len = 0;
		printnum_nopad(putch, putdat, num, base, &num_len);
		width -= num_len;
		while (width-- > 0)
  800499:	85 db                	test   %ebx,%ebx
  80049b:	7f ec                	jg     800489 <printnum+0x58>
  80049d:	e9 cf 00 00 00       	jmp    800571 <printnum+0x140>
			putch(' ', putdat);
	}
	else{
		// first recursively print all preceding (more significant) digits
		if (num >= base) {
  8004a2:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8004a5:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004a9:	77 19                	ja     8004c4 <printnum+0x93>
  8004ab:	90                   	nop
  8004ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8004b0:	72 05                	jb     8004b7 <printnum+0x86>
  8004b2:	39 45 c8             	cmp    %eax,-0x38(%ebp)
  8004b5:	73 0d                	jae    8004c4 <printnum+0x93>
			printnum(putch, putdat, num / base, base, width - 1, padc);
		} else {
			// print any needed pad characters before first digit
			while (--width > 0)
  8004b7:	83 eb 01             	sub    $0x1,%ebx
  8004ba:	85 db                	test   %ebx,%ebx
  8004bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8004c0:	7f 63                	jg     800525 <printnum+0xf4>
  8004c2:	eb 74                	jmp    800538 <printnum+0x107>
			putch(' ', putdat);
	}
	else{
		// first recursively print all preceding (more significant) digits
		if (num >= base) {
			printnum(putch, putdat, num / base, base, width - 1, padc);
  8004c4:	8b 55 18             	mov    0x18(%ebp),%edx
  8004c7:	89 54 24 10          	mov    %edx,0x10(%esp)
  8004cb:	83 eb 01             	sub    $0x1,%ebx
  8004ce:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8004d2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004d6:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8004da:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8004de:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8004e1:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8004e4:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  8004e7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8004eb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004f2:	00 
  8004f3:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8004f6:	89 04 24             	mov    %eax,(%esp)
  8004f9:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8004fc:	89 54 24 04          	mov    %edx,0x4(%esp)
  800500:	e8 ab 0a 00 00       	call   800fb0 <__udivdi3>
  800505:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800508:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80050b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80050f:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800513:	89 04 24             	mov    %eax,(%esp)
  800516:	89 54 24 04          	mov    %edx,0x4(%esp)
  80051a:	89 f2                	mov    %esi,%edx
  80051c:	89 f8                	mov    %edi,%eax
  80051e:	e8 0e ff ff ff       	call   800431 <printnum>
  800523:	eb 13                	jmp    800538 <printnum+0x107>
		} else {
			// print any needed pad characters before first digit
			while (--width > 0)
				putch(padc, putdat);
  800525:	89 74 24 04          	mov    %esi,0x4(%esp)
  800529:	8b 45 18             	mov    0x18(%ebp),%eax
  80052c:	89 04 24             	mov    %eax,(%esp)
  80052f:	ff d7                	call   *%edi
		// first recursively print all preceding (more significant) digits
		if (num >= base) {
			printnum(putch, putdat, num / base, base, width - 1, padc);
		} else {
			// print any needed pad characters before first digit
			while (--width > 0)
  800531:	83 eb 01             	sub    $0x1,%ebx
  800534:	85 db                	test   %ebx,%ebx
  800536:	7f ed                	jg     800525 <printnum+0xf4>
				putch(padc, putdat);
		}

		// then print this (the least significant) digit
		putch("0123456789abcdef"[num % base], putdat);
  800538:	89 74 24 04          	mov    %esi,0x4(%esp)
  80053c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800540:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800543:	89 54 24 08          	mov    %edx,0x8(%esp)
  800547:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80054e:	00 
  80054f:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800552:	89 0c 24             	mov    %ecx,(%esp)
  800555:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800558:	89 44 24 04          	mov    %eax,0x4(%esp)
  80055c:	e8 7f 0b 00 00       	call   8010e0 <__umoddi3>
  800561:	89 74 24 04          	mov    %esi,0x4(%esp)
  800565:	0f be 80 83 12 80 00 	movsbl 0x801283(%eax),%eax
  80056c:	89 04 24             	mov    %eax,(%esp)
  80056f:	ff d7                	call   *%edi
	}
	
}
  800571:	83 c4 5c             	add    $0x5c,%esp
  800574:	5b                   	pop    %ebx
  800575:	5e                   	pop    %esi
  800576:	5f                   	pop    %edi
  800577:	5d                   	pop    %ebp
  800578:	c3                   	ret    

00800579 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800579:	55                   	push   %ebp
  80057a:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80057c:	83 fa 01             	cmp    $0x1,%edx
  80057f:	7e 0e                	jle    80058f <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800581:	8b 10                	mov    (%eax),%edx
  800583:	8d 4a 08             	lea    0x8(%edx),%ecx
  800586:	89 08                	mov    %ecx,(%eax)
  800588:	8b 02                	mov    (%edx),%eax
  80058a:	8b 52 04             	mov    0x4(%edx),%edx
  80058d:	eb 22                	jmp    8005b1 <getuint+0x38>
	else if (lflag)
  80058f:	85 d2                	test   %edx,%edx
  800591:	74 10                	je     8005a3 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800593:	8b 10                	mov    (%eax),%edx
  800595:	8d 4a 04             	lea    0x4(%edx),%ecx
  800598:	89 08                	mov    %ecx,(%eax)
  80059a:	8b 02                	mov    (%edx),%eax
  80059c:	ba 00 00 00 00       	mov    $0x0,%edx
  8005a1:	eb 0e                	jmp    8005b1 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8005a3:	8b 10                	mov    (%eax),%edx
  8005a5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005a8:	89 08                	mov    %ecx,(%eax)
  8005aa:	8b 02                	mov    (%edx),%eax
  8005ac:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8005b1:	5d                   	pop    %ebp
  8005b2:	c3                   	ret    

008005b3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005b3:	55                   	push   %ebp
  8005b4:	89 e5                	mov    %esp,%ebp
  8005b6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005b9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8005bd:	8b 10                	mov    (%eax),%edx
  8005bf:	3b 50 04             	cmp    0x4(%eax),%edx
  8005c2:	73 0a                	jae    8005ce <sprintputch+0x1b>
		*b->buf++ = ch;
  8005c4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8005c7:	88 0a                	mov    %cl,(%edx)
  8005c9:	83 c2 01             	add    $0x1,%edx
  8005cc:	89 10                	mov    %edx,(%eax)
}
  8005ce:	5d                   	pop    %ebp
  8005cf:	c3                   	ret    

008005d0 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8005d0:	55                   	push   %ebp
  8005d1:	89 e5                	mov    %esp,%ebp
  8005d3:	57                   	push   %edi
  8005d4:	56                   	push   %esi
  8005d5:	53                   	push   %ebx
  8005d6:	83 ec 5c             	sub    $0x5c,%esp
  8005d9:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8005dc:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8005df:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8005e6:	eb 12                	jmp    8005fa <vprintfmt+0x2a>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8005e8:	85 c0                	test   %eax,%eax
  8005ea:	0f 84 c6 04 00 00    	je     800ab6 <vprintfmt+0x4e6>
				return;
			putch(ch, putdat);
  8005f0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005f4:	89 04 24             	mov    %eax,(%esp)
  8005f7:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005fa:	0f b6 03             	movzbl (%ebx),%eax
  8005fd:	83 c3 01             	add    $0x1,%ebx
  800600:	83 f8 25             	cmp    $0x25,%eax
  800603:	75 e3                	jne    8005e8 <vprintfmt+0x18>
  800605:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  800609:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800610:	be ff ff ff ff       	mov    $0xffffffff,%esi
  800615:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  80061c:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800623:	eb 06                	jmp    80062b <vprintfmt+0x5b>
  800625:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  800629:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80062b:	0f b6 0b             	movzbl (%ebx),%ecx
  80062e:	0f b6 d1             	movzbl %cl,%edx
  800631:	8d 43 01             	lea    0x1(%ebx),%eax
  800634:	83 e9 23             	sub    $0x23,%ecx
  800637:	80 f9 55             	cmp    $0x55,%cl
  80063a:	0f 87 58 04 00 00    	ja     800a98 <vprintfmt+0x4c8>
  800640:	0f b6 c9             	movzbl %cl,%ecx
  800643:	ff 24 8d 8c 13 80 00 	jmp    *0x80138c(,%ecx,4)
  80064a:	c6 45 e0 2b          	movb   $0x2b,-0x20(%ebp)
  80064e:	eb d9                	jmp    800629 <vprintfmt+0x59>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800650:	8d 72 d0             	lea    -0x30(%edx),%esi
				ch = *fmt;
  800653:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800656:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800659:	83 f9 09             	cmp    $0x9,%ecx
  80065c:	76 08                	jbe    800666 <vprintfmt+0x96>
  80065e:	eb 40                	jmp    8006a0 <vprintfmt+0xd0>
  800660:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
			goto reswitch;
  800664:	eb c3                	jmp    800629 <vprintfmt+0x59>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800666:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  800669:	8d 0c b6             	lea    (%esi,%esi,4),%ecx
  80066c:	8d 74 4a d0          	lea    -0x30(%edx,%ecx,2),%esi
				ch = *fmt;
  800670:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800673:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800676:	83 f9 09             	cmp    $0x9,%ecx
  800679:	76 eb                	jbe    800666 <vprintfmt+0x96>
  80067b:	eb 23                	jmp    8006a0 <vprintfmt+0xd0>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80067d:	8b 55 14             	mov    0x14(%ebp),%edx
  800680:	8d 4a 04             	lea    0x4(%edx),%ecx
  800683:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800686:	8b 32                	mov    (%edx),%esi
			goto process_precision;
  800688:	eb 16                	jmp    8006a0 <vprintfmt+0xd0>

		case '.':
			if (width < 0)
  80068a:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80068d:	c1 fa 1f             	sar    $0x1f,%edx
  800690:	f7 d2                	not    %edx
  800692:	21 55 dc             	and    %edx,-0x24(%ebp)
  800695:	eb 92                	jmp    800629 <vprintfmt+0x59>
  800697:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  80069e:	eb 89                	jmp    800629 <vprintfmt+0x59>

		process_precision:
			if (width < 0)
  8006a0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006a4:	79 83                	jns    800629 <vprintfmt+0x59>
  8006a6:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8006a9:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8006ac:	e9 78 ff ff ff       	jmp    800629 <vprintfmt+0x59>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8006b1:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
			goto reswitch;
  8006b5:	e9 6f ff ff ff       	jmp    800629 <vprintfmt+0x59>
  8006ba:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8006bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c0:	8d 50 04             	lea    0x4(%eax),%edx
  8006c3:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006ca:	8b 00                	mov    (%eax),%eax
  8006cc:	89 04 24             	mov    %eax,(%esp)
  8006cf:	ff 55 08             	call   *0x8(%ebp)
  8006d2:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  8006d5:	e9 20 ff ff ff       	jmp    8005fa <vprintfmt+0x2a>
  8006da:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8006dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e0:	8d 50 04             	lea    0x4(%eax),%edx
  8006e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e6:	8b 00                	mov    (%eax),%eax
  8006e8:	89 c2                	mov    %eax,%edx
  8006ea:	c1 fa 1f             	sar    $0x1f,%edx
  8006ed:	31 d0                	xor    %edx,%eax
  8006ef:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006f1:	83 f8 06             	cmp    $0x6,%eax
  8006f4:	7f 0b                	jg     800701 <vprintfmt+0x131>
  8006f6:	8b 14 85 e4 14 80 00 	mov    0x8014e4(,%eax,4),%edx
  8006fd:	85 d2                	test   %edx,%edx
  8006ff:	75 23                	jne    800724 <vprintfmt+0x154>
				printfmt(putch, putdat, "error %d", err);
  800701:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800705:	c7 44 24 08 94 12 80 	movl   $0x801294,0x8(%esp)
  80070c:	00 
  80070d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800711:	8b 45 08             	mov    0x8(%ebp),%eax
  800714:	89 04 24             	mov    %eax,(%esp)
  800717:	e8 22 04 00 00       	call   800b3e <printfmt>
  80071c:	8b 5d cc             	mov    -0x34(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80071f:	e9 d6 fe ff ff       	jmp    8005fa <vprintfmt+0x2a>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800724:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800728:	c7 44 24 08 9d 12 80 	movl   $0x80129d,0x8(%esp)
  80072f:	00 
  800730:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800734:	8b 55 08             	mov    0x8(%ebp),%edx
  800737:	89 14 24             	mov    %edx,(%esp)
  80073a:	e8 ff 03 00 00       	call   800b3e <printfmt>
  80073f:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800742:	e9 b3 fe ff ff       	jmp    8005fa <vprintfmt+0x2a>
  800747:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80074a:	89 c3                	mov    %eax,%ebx
  80074c:	89 f1                	mov    %esi,%ecx
  80074e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800751:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800754:	8b 45 14             	mov    0x14(%ebp),%eax
  800757:	8d 50 04             	lea    0x4(%eax),%edx
  80075a:	89 55 14             	mov    %edx,0x14(%ebp)
  80075d:	8b 00                	mov    (%eax),%eax
  80075f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800762:	85 c0                	test   %eax,%eax
  800764:	75 07                	jne    80076d <vprintfmt+0x19d>
  800766:	c7 45 d0 a0 12 80 00 	movl   $0x8012a0,-0x30(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  80076d:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  800771:	7e 06                	jle    800779 <vprintfmt+0x1a9>
  800773:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  800777:	75 13                	jne    80078c <vprintfmt+0x1bc>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800779:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80077c:	0f be 02             	movsbl (%edx),%eax
  80077f:	85 c0                	test   %eax,%eax
  800781:	0f 85 a2 00 00 00    	jne    800829 <vprintfmt+0x259>
  800787:	e9 8f 00 00 00       	jmp    80081b <vprintfmt+0x24b>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80078c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800790:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800793:	89 0c 24             	mov    %ecx,(%esp)
  800796:	e8 f0 03 00 00       	call   800b8b <strnlen>
  80079b:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80079e:	29 c2                	sub    %eax,%edx
  8007a0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007a3:	85 d2                	test   %edx,%edx
  8007a5:	7e d2                	jle    800779 <vprintfmt+0x1a9>
					putch(padc, putdat);
  8007a7:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  8007ab:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  8007ae:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  8007b1:	89 d3                	mov    %edx,%ebx
  8007b3:	89 ce                	mov    %ecx,%esi
  8007b5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007b9:	89 34 24             	mov    %esi,(%esp)
  8007bc:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007bf:	83 eb 01             	sub    $0x1,%ebx
  8007c2:	85 db                	test   %ebx,%ebx
  8007c4:	7f ef                	jg     8007b5 <vprintfmt+0x1e5>
  8007c6:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  8007c9:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  8007cc:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8007d3:	eb a4                	jmp    800779 <vprintfmt+0x1a9>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8007d5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007d9:	74 1b                	je     8007f6 <vprintfmt+0x226>
  8007db:	8d 50 e0             	lea    -0x20(%eax),%edx
  8007de:	83 fa 5e             	cmp    $0x5e,%edx
  8007e1:	76 13                	jbe    8007f6 <vprintfmt+0x226>
					putch('?', putdat);
  8007e3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007ea:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8007f1:	ff 55 08             	call   *0x8(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8007f4:	eb 0d                	jmp    800803 <vprintfmt+0x233>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8007f6:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8007f9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007fd:	89 04 24             	mov    %eax,(%esp)
  800800:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800803:	83 ef 01             	sub    $0x1,%edi
  800806:	0f be 03             	movsbl (%ebx),%eax
  800809:	85 c0                	test   %eax,%eax
  80080b:	74 05                	je     800812 <vprintfmt+0x242>
  80080d:	83 c3 01             	add    $0x1,%ebx
  800810:	eb 28                	jmp    80083a <vprintfmt+0x26a>
  800812:	89 7d dc             	mov    %edi,-0x24(%ebp)
  800815:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800818:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80081b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80081f:	7f 2d                	jg     80084e <vprintfmt+0x27e>
  800821:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800824:	e9 d1 fd ff ff       	jmp    8005fa <vprintfmt+0x2a>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800829:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80082c:	83 c1 01             	add    $0x1,%ecx
  80082f:	89 7d e0             	mov    %edi,-0x20(%ebp)
  800832:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800835:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  800838:	89 cb                	mov    %ecx,%ebx
  80083a:	85 f6                	test   %esi,%esi
  80083c:	78 97                	js     8007d5 <vprintfmt+0x205>
  80083e:	83 ee 01             	sub    $0x1,%esi
  800841:	79 92                	jns    8007d5 <vprintfmt+0x205>
  800843:	89 7d dc             	mov    %edi,-0x24(%ebp)
  800846:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800849:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  80084c:	eb cd                	jmp    80081b <vprintfmt+0x24b>
  80084e:	8b 75 08             	mov    0x8(%ebp),%esi
  800851:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800854:	8b 5d dc             	mov    -0x24(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800857:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80085b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800862:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800864:	83 eb 01             	sub    $0x1,%ebx
  800867:	85 db                	test   %ebx,%ebx
  800869:	7f ec                	jg     800857 <vprintfmt+0x287>
  80086b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80086e:	e9 87 fd ff ff       	jmp    8005fa <vprintfmt+0x2a>
  800873:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800876:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
  80087a:	88 45 e4             	mov    %al,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80087d:	83 7d d0 01          	cmpl   $0x1,-0x30(%ebp)
  800881:	7e 16                	jle    800899 <vprintfmt+0x2c9>
		return va_arg(*ap, long long);
  800883:	8b 45 14             	mov    0x14(%ebp),%eax
  800886:	8d 50 08             	lea    0x8(%eax),%edx
  800889:	89 55 14             	mov    %edx,0x14(%ebp)
  80088c:	8b 10                	mov    (%eax),%edx
  80088e:	8b 48 04             	mov    0x4(%eax),%ecx
  800891:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800894:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800897:	eb 34                	jmp    8008cd <vprintfmt+0x2fd>
	else if (lflag)
  800899:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80089d:	74 18                	je     8008b7 <vprintfmt+0x2e7>
		return va_arg(*ap, long);
  80089f:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a2:	8d 50 04             	lea    0x4(%eax),%edx
  8008a5:	89 55 14             	mov    %edx,0x14(%ebp)
  8008a8:	8b 00                	mov    (%eax),%eax
  8008aa:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8008ad:	89 c1                	mov    %eax,%ecx
  8008af:	c1 f9 1f             	sar    $0x1f,%ecx
  8008b2:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8008b5:	eb 16                	jmp    8008cd <vprintfmt+0x2fd>
	else
		return va_arg(*ap, int);
  8008b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ba:	8d 50 04             	lea    0x4(%eax),%edx
  8008bd:	89 55 14             	mov    %edx,0x14(%ebp)
  8008c0:	8b 00                	mov    (%eax),%eax
  8008c2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8008c5:	89 c2                	mov    %eax,%edx
  8008c7:	c1 fa 1f             	sar    $0x1f,%edx
  8008ca:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8008cd:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8008d0:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if ((long long) num < 0) {
  8008d3:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8008d7:	79 2c                	jns    800905 <vprintfmt+0x335>
				putch('-', putdat);
  8008d9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008dd:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8008e4:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8008e7:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8008ea:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8008ed:	f7 db                	neg    %ebx
  8008ef:	83 d6 00             	adc    $0x0,%esi
  8008f2:	f7 de                	neg    %esi
  8008f4:	0f b6 4d e0          	movzbl -0x20(%ebp),%ecx
  8008f8:	88 4d e4             	mov    %cl,-0x1c(%ebp)
  8008fb:	ba 0a 00 00 00       	mov    $0xa,%edx
  800900:	e9 db 00 00 00       	jmp    8009e0 <vprintfmt+0x410>
			}
			else if (padc == '+'){
  800905:	80 7d e4 2b          	cmpb   $0x2b,-0x1c(%ebp)
  800909:	74 11                	je     80091c <vprintfmt+0x34c>
  80090b:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
  80090f:	88 45 e4             	mov    %al,-0x1c(%ebp)
  800912:	ba 0a 00 00 00       	mov    $0xa,%edx
  800917:	e9 c4 00 00 00       	jmp    8009e0 <vprintfmt+0x410>
				putch('+', putdat);
  80091c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800920:	c7 04 24 2b 00 00 00 	movl   $0x2b,(%esp)
  800927:	ff 55 08             	call   *0x8(%ebp)
  80092a:	ba 0a 00 00 00       	mov    $0xa,%edx
  80092f:	e9 ac 00 00 00       	jmp    8009e0 <vprintfmt+0x410>
  800934:	89 45 cc             	mov    %eax,-0x34(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800937:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80093a:	8d 45 14             	lea    0x14(%ebp),%eax
  80093d:	e8 37 fc ff ff       	call   800579 <getuint>
  800942:	89 c3                	mov    %eax,%ebx
  800944:	89 d6                	mov    %edx,%esi
  800946:	0f b6 55 e0          	movzbl -0x20(%ebp),%edx
  80094a:	88 55 e4             	mov    %dl,-0x1c(%ebp)
  80094d:	ba 0a 00 00 00       	mov    $0xa,%edx
			base = 10;
			goto number;
  800952:	e9 89 00 00 00       	jmp    8009e0 <vprintfmt+0x410>
  800957:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) octal
		case 'o':
			putch('0', putdat);
  80095a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80095e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800965:	ff 55 08             	call   *0x8(%ebp)
			num = getuint(&ap, lflag);
  800968:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80096b:	8d 45 14             	lea    0x14(%ebp),%eax
  80096e:	e8 06 fc ff ff       	call   800579 <getuint>
  800973:	89 c3                	mov    %eax,%ebx
  800975:	89 d6                	mov    %edx,%esi
  800977:	0f b6 4d e0          	movzbl -0x20(%ebp),%ecx
  80097b:	88 4d e4             	mov    %cl,-0x1c(%ebp)
  80097e:	ba 08 00 00 00       	mov    $0x8,%edx
			base = 8;
			goto number;
  800983:	eb 5b                	jmp    8009e0 <vprintfmt+0x410>
  800985:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  800988:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80098c:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800993:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800996:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80099a:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8009a1:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  8009a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a7:	8d 50 04             	lea    0x4(%eax),%edx
  8009aa:	89 55 14             	mov    %edx,0x14(%ebp)
  8009ad:	8b 18                	mov    (%eax),%ebx
  8009af:	be 00 00 00 00       	mov    $0x0,%esi
  8009b4:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
  8009b8:	88 45 e4             	mov    %al,-0x1c(%ebp)
  8009bb:	ba 10 00 00 00       	mov    $0x10,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8009c0:	eb 1e                	jmp    8009e0 <vprintfmt+0x410>
  8009c2:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8009c5:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8009c8:	8d 45 14             	lea    0x14(%ebp),%eax
  8009cb:	e8 a9 fb ff ff       	call   800579 <getuint>
  8009d0:	89 c3                	mov    %eax,%ebx
  8009d2:	89 d6                	mov    %edx,%esi
  8009d4:	0f b6 55 e0          	movzbl -0x20(%ebp),%edx
  8009d8:	88 55 e4             	mov    %dl,-0x1c(%ebp)
  8009db:	ba 10 00 00 00       	mov    $0x10,%edx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8009e0:	0f be 45 e4          	movsbl -0x1c(%ebp),%eax
  8009e4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8009e8:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8009eb:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8009ef:	89 54 24 08          	mov    %edx,0x8(%esp)
  8009f3:	89 1c 24             	mov    %ebx,(%esp)
  8009f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009fa:	89 fa                	mov    %edi,%edx
  8009fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ff:	e8 2d fa ff ff       	call   800431 <printnum>
  800a04:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  800a07:	e9 ee fb ff ff       	jmp    8005fa <vprintfmt+0x2a>
  800a0c:	89 45 cc             	mov    %eax,-0x34(%ebp)
            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
	    	uint32_t *num_now = putdat;
	    	char *ret_va = va_arg(ap, char *);
  800a0f:	8b 45 14             	mov    0x14(%ebp),%eax
  800a12:	8d 50 04             	lea    0x4(%eax),%edx
  800a15:	89 55 14             	mov    %edx,0x14(%ebp)
  800a18:	8b 00                	mov    (%eax),%eax
	    	if(ret_va == NULL){
  800a1a:	85 c0                	test   %eax,%eax
  800a1c:	75 27                	jne    800a45 <vprintfmt+0x475>
				printfmt(putch, putdat, "%s", null_error);
  800a1e:	c7 44 24 0c 10 13 80 	movl   $0x801310,0xc(%esp)
  800a25:	00 
  800a26:	c7 44 24 08 9d 12 80 	movl   $0x80129d,0x8(%esp)
  800a2d:	00 
  800a2e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a32:	8b 45 08             	mov    0x8(%ebp),%eax
  800a35:	89 04 24             	mov    %eax,(%esp)
  800a38:	e8 01 01 00 00       	call   800b3e <printfmt>
  800a3d:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800a40:	e9 b5 fb ff ff       	jmp    8005fa <vprintfmt+0x2a>
	    	}
	    	else if ((*num_now) >> 7 != 0 ){		//how to aurrately discribe overflow?
  800a45:	8b 17                	mov    (%edi),%edx
  800a47:	89 d1                	mov    %edx,%ecx
  800a49:	c1 e9 07             	shr    $0x7,%ecx
  800a4c:	85 c9                	test   %ecx,%ecx
  800a4e:	74 29                	je     800a79 <vprintfmt+0x4a9>
				*ret_va = *(num_now);	//get putdat at first as next print instruction will change ret_va as it's a pointer which means it's dynamic;
  800a50:	88 10                	mov    %dl,(%eax)
				printfmt(putch, putdat, "%s", overflow_error);
  800a52:	c7 44 24 0c 48 13 80 	movl   $0x801348,0xc(%esp)
  800a59:	00 
  800a5a:	c7 44 24 08 9d 12 80 	movl   $0x80129d,0x8(%esp)
  800a61:	00 
  800a62:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a66:	8b 55 08             	mov    0x8(%ebp),%edx
  800a69:	89 14 24             	mov    %edx,(%esp)
  800a6c:	e8 cd 00 00 00       	call   800b3e <printfmt>
  800a71:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800a74:	e9 81 fb ff ff       	jmp    8005fa <vprintfmt+0x2a>
	    	}
	    	else{
				*ret_va = *(num_now);
  800a79:	88 10                	mov    %dl,(%eax)
  800a7b:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800a7e:	e9 77 fb ff ff       	jmp    8005fa <vprintfmt+0x2a>
  800a83:	89 45 cc             	mov    %eax,-0x34(%ebp)
            	break;
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a86:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a8a:	89 14 24             	mov    %edx,(%esp)
  800a8d:	ff 55 08             	call   *0x8(%ebp)
  800a90:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  800a93:	e9 62 fb ff ff       	jmp    8005fa <vprintfmt+0x2a>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a98:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a9c:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800aa3:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800aa6:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800aa9:	80 38 25             	cmpb   $0x25,(%eax)
  800aac:	0f 84 48 fb ff ff    	je     8005fa <vprintfmt+0x2a>
  800ab2:	89 c3                	mov    %eax,%ebx
  800ab4:	eb f0                	jmp    800aa6 <vprintfmt+0x4d6>
				/* do nothing */;
			break;
		}
	}
}
  800ab6:	83 c4 5c             	add    $0x5c,%esp
  800ab9:	5b                   	pop    %ebx
  800aba:	5e                   	pop    %esi
  800abb:	5f                   	pop    %edi
  800abc:	5d                   	pop    %ebp
  800abd:	c3                   	ret    

00800abe <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800abe:	55                   	push   %ebp
  800abf:	89 e5                	mov    %esp,%ebp
  800ac1:	83 ec 28             	sub    $0x28,%esp
  800ac4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800aca:	85 c0                	test   %eax,%eax
  800acc:	74 04                	je     800ad2 <vsnprintf+0x14>
  800ace:	85 d2                	test   %edx,%edx
  800ad0:	7f 07                	jg     800ad9 <vsnprintf+0x1b>
  800ad2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ad7:	eb 3b                	jmp    800b14 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800ad9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800adc:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800ae0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800ae3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800aea:	8b 45 14             	mov    0x14(%ebp),%eax
  800aed:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800af1:	8b 45 10             	mov    0x10(%ebp),%eax
  800af4:	89 44 24 08          	mov    %eax,0x8(%esp)
  800af8:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800afb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aff:	c7 04 24 b3 05 80 00 	movl   $0x8005b3,(%esp)
  800b06:	e8 c5 fa ff ff       	call   8005d0 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b0b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b0e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b11:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800b14:	c9                   	leave  
  800b15:	c3                   	ret    

00800b16 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b16:	55                   	push   %ebp
  800b17:	89 e5                	mov    %esp,%ebp
  800b19:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800b1c:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800b1f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b23:	8b 45 10             	mov    0x10(%ebp),%eax
  800b26:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b2a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b2d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b31:	8b 45 08             	mov    0x8(%ebp),%eax
  800b34:	89 04 24             	mov    %eax,(%esp)
  800b37:	e8 82 ff ff ff       	call   800abe <vsnprintf>
	va_end(ap);

	return rc;
}
  800b3c:	c9                   	leave  
  800b3d:	c3                   	ret    

00800b3e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800b3e:	55                   	push   %ebp
  800b3f:	89 e5                	mov    %esp,%ebp
  800b41:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800b44:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800b47:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b4b:	8b 45 10             	mov    0x10(%ebp),%eax
  800b4e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b52:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b55:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b59:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5c:	89 04 24             	mov    %eax,(%esp)
  800b5f:	e8 6c fa ff ff       	call   8005d0 <vprintfmt>
	va_end(ap);
}
  800b64:	c9                   	leave  
  800b65:	c3                   	ret    
	...

00800b70 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b70:	55                   	push   %ebp
  800b71:	89 e5                	mov    %esp,%ebp
  800b73:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b76:	b8 00 00 00 00       	mov    $0x0,%eax
  800b7b:	80 3a 00             	cmpb   $0x0,(%edx)
  800b7e:	74 09                	je     800b89 <strlen+0x19>
		n++;
  800b80:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b83:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b87:	75 f7                	jne    800b80 <strlen+0x10>
		n++;
	return n;
}
  800b89:	5d                   	pop    %ebp
  800b8a:	c3                   	ret    

00800b8b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b8b:	55                   	push   %ebp
  800b8c:	89 e5                	mov    %esp,%ebp
  800b8e:	53                   	push   %ebx
  800b8f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b95:	85 c9                	test   %ecx,%ecx
  800b97:	74 19                	je     800bb2 <strnlen+0x27>
  800b99:	80 3b 00             	cmpb   $0x0,(%ebx)
  800b9c:	74 14                	je     800bb2 <strnlen+0x27>
  800b9e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800ba3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ba6:	39 c8                	cmp    %ecx,%eax
  800ba8:	74 0d                	je     800bb7 <strnlen+0x2c>
  800baa:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800bae:	75 f3                	jne    800ba3 <strnlen+0x18>
  800bb0:	eb 05                	jmp    800bb7 <strnlen+0x2c>
  800bb2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800bb7:	5b                   	pop    %ebx
  800bb8:	5d                   	pop    %ebp
  800bb9:	c3                   	ret    

00800bba <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800bba:	55                   	push   %ebp
  800bbb:	89 e5                	mov    %esp,%ebp
  800bbd:	53                   	push   %ebx
  800bbe:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bc4:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800bc9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800bcd:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800bd0:	83 c2 01             	add    $0x1,%edx
  800bd3:	84 c9                	test   %cl,%cl
  800bd5:	75 f2                	jne    800bc9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800bd7:	5b                   	pop    %ebx
  800bd8:	5d                   	pop    %ebp
  800bd9:	c3                   	ret    

00800bda <strcat>:

char *
strcat(char *dst, const char *src)
{
  800bda:	55                   	push   %ebp
  800bdb:	89 e5                	mov    %esp,%ebp
  800bdd:	53                   	push   %ebx
  800bde:	83 ec 08             	sub    $0x8,%esp
  800be1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800be4:	89 1c 24             	mov    %ebx,(%esp)
  800be7:	e8 84 ff ff ff       	call   800b70 <strlen>
	strcpy(dst + len, src);
  800bec:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bef:	89 54 24 04          	mov    %edx,0x4(%esp)
  800bf3:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800bf6:	89 04 24             	mov    %eax,(%esp)
  800bf9:	e8 bc ff ff ff       	call   800bba <strcpy>
	return dst;
}
  800bfe:	89 d8                	mov    %ebx,%eax
  800c00:	83 c4 08             	add    $0x8,%esp
  800c03:	5b                   	pop    %ebx
  800c04:	5d                   	pop    %ebp
  800c05:	c3                   	ret    

00800c06 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c06:	55                   	push   %ebp
  800c07:	89 e5                	mov    %esp,%ebp
  800c09:	56                   	push   %esi
  800c0a:	53                   	push   %ebx
  800c0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c0e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c11:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c14:	85 f6                	test   %esi,%esi
  800c16:	74 18                	je     800c30 <strncpy+0x2a>
  800c18:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800c1d:	0f b6 1a             	movzbl (%edx),%ebx
  800c20:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800c23:	80 3a 01             	cmpb   $0x1,(%edx)
  800c26:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c29:	83 c1 01             	add    $0x1,%ecx
  800c2c:	39 ce                	cmp    %ecx,%esi
  800c2e:	77 ed                	ja     800c1d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800c30:	5b                   	pop    %ebx
  800c31:	5e                   	pop    %esi
  800c32:	5d                   	pop    %ebp
  800c33:	c3                   	ret    

00800c34 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800c34:	55                   	push   %ebp
  800c35:	89 e5                	mov    %esp,%ebp
  800c37:	56                   	push   %esi
  800c38:	53                   	push   %ebx
  800c39:	8b 75 08             	mov    0x8(%ebp),%esi
  800c3c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c3f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c42:	89 f0                	mov    %esi,%eax
  800c44:	85 c9                	test   %ecx,%ecx
  800c46:	74 27                	je     800c6f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800c48:	83 e9 01             	sub    $0x1,%ecx
  800c4b:	74 1d                	je     800c6a <strlcpy+0x36>
  800c4d:	0f b6 1a             	movzbl (%edx),%ebx
  800c50:	84 db                	test   %bl,%bl
  800c52:	74 16                	je     800c6a <strlcpy+0x36>
			*dst++ = *src++;
  800c54:	88 18                	mov    %bl,(%eax)
  800c56:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c59:	83 e9 01             	sub    $0x1,%ecx
  800c5c:	74 0e                	je     800c6c <strlcpy+0x38>
			*dst++ = *src++;
  800c5e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c61:	0f b6 1a             	movzbl (%edx),%ebx
  800c64:	84 db                	test   %bl,%bl
  800c66:	75 ec                	jne    800c54 <strlcpy+0x20>
  800c68:	eb 02                	jmp    800c6c <strlcpy+0x38>
  800c6a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800c6c:	c6 00 00             	movb   $0x0,(%eax)
  800c6f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800c71:	5b                   	pop    %ebx
  800c72:	5e                   	pop    %esi
  800c73:	5d                   	pop    %ebp
  800c74:	c3                   	ret    

00800c75 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c75:	55                   	push   %ebp
  800c76:	89 e5                	mov    %esp,%ebp
  800c78:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c7b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c7e:	0f b6 01             	movzbl (%ecx),%eax
  800c81:	84 c0                	test   %al,%al
  800c83:	74 15                	je     800c9a <strcmp+0x25>
  800c85:	3a 02                	cmp    (%edx),%al
  800c87:	75 11                	jne    800c9a <strcmp+0x25>
		p++, q++;
  800c89:	83 c1 01             	add    $0x1,%ecx
  800c8c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800c8f:	0f b6 01             	movzbl (%ecx),%eax
  800c92:	84 c0                	test   %al,%al
  800c94:	74 04                	je     800c9a <strcmp+0x25>
  800c96:	3a 02                	cmp    (%edx),%al
  800c98:	74 ef                	je     800c89 <strcmp+0x14>
  800c9a:	0f b6 c0             	movzbl %al,%eax
  800c9d:	0f b6 12             	movzbl (%edx),%edx
  800ca0:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ca2:	5d                   	pop    %ebp
  800ca3:	c3                   	ret    

00800ca4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ca4:	55                   	push   %ebp
  800ca5:	89 e5                	mov    %esp,%ebp
  800ca7:	53                   	push   %ebx
  800ca8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cae:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800cb1:	85 c0                	test   %eax,%eax
  800cb3:	74 23                	je     800cd8 <strncmp+0x34>
  800cb5:	0f b6 1a             	movzbl (%edx),%ebx
  800cb8:	84 db                	test   %bl,%bl
  800cba:	74 25                	je     800ce1 <strncmp+0x3d>
  800cbc:	3a 19                	cmp    (%ecx),%bl
  800cbe:	75 21                	jne    800ce1 <strncmp+0x3d>
  800cc0:	83 e8 01             	sub    $0x1,%eax
  800cc3:	74 13                	je     800cd8 <strncmp+0x34>
		n--, p++, q++;
  800cc5:	83 c2 01             	add    $0x1,%edx
  800cc8:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ccb:	0f b6 1a             	movzbl (%edx),%ebx
  800cce:	84 db                	test   %bl,%bl
  800cd0:	74 0f                	je     800ce1 <strncmp+0x3d>
  800cd2:	3a 19                	cmp    (%ecx),%bl
  800cd4:	74 ea                	je     800cc0 <strncmp+0x1c>
  800cd6:	eb 09                	jmp    800ce1 <strncmp+0x3d>
  800cd8:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800cdd:	5b                   	pop    %ebx
  800cde:	5d                   	pop    %ebp
  800cdf:	90                   	nop
  800ce0:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ce1:	0f b6 02             	movzbl (%edx),%eax
  800ce4:	0f b6 11             	movzbl (%ecx),%edx
  800ce7:	29 d0                	sub    %edx,%eax
  800ce9:	eb f2                	jmp    800cdd <strncmp+0x39>

00800ceb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ceb:	55                   	push   %ebp
  800cec:	89 e5                	mov    %esp,%ebp
  800cee:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cf5:	0f b6 10             	movzbl (%eax),%edx
  800cf8:	84 d2                	test   %dl,%dl
  800cfa:	74 18                	je     800d14 <strchr+0x29>
		if (*s == c)
  800cfc:	38 ca                	cmp    %cl,%dl
  800cfe:	75 0a                	jne    800d0a <strchr+0x1f>
  800d00:	eb 17                	jmp    800d19 <strchr+0x2e>
  800d02:	38 ca                	cmp    %cl,%dl
  800d04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d08:	74 0f                	je     800d19 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800d0a:	83 c0 01             	add    $0x1,%eax
  800d0d:	0f b6 10             	movzbl (%eax),%edx
  800d10:	84 d2                	test   %dl,%dl
  800d12:	75 ee                	jne    800d02 <strchr+0x17>
  800d14:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800d19:	5d                   	pop    %ebp
  800d1a:	c3                   	ret    

00800d1b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800d1b:	55                   	push   %ebp
  800d1c:	89 e5                	mov    %esp,%ebp
  800d1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d21:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d25:	0f b6 10             	movzbl (%eax),%edx
  800d28:	84 d2                	test   %dl,%dl
  800d2a:	74 18                	je     800d44 <strfind+0x29>
		if (*s == c)
  800d2c:	38 ca                	cmp    %cl,%dl
  800d2e:	75 0a                	jne    800d3a <strfind+0x1f>
  800d30:	eb 12                	jmp    800d44 <strfind+0x29>
  800d32:	38 ca                	cmp    %cl,%dl
  800d34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d38:	74 0a                	je     800d44 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800d3a:	83 c0 01             	add    $0x1,%eax
  800d3d:	0f b6 10             	movzbl (%eax),%edx
  800d40:	84 d2                	test   %dl,%dl
  800d42:	75 ee                	jne    800d32 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800d44:	5d                   	pop    %ebp
  800d45:	c3                   	ret    

00800d46 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d46:	55                   	push   %ebp
  800d47:	89 e5                	mov    %esp,%ebp
  800d49:	83 ec 0c             	sub    $0xc,%esp
  800d4c:	89 1c 24             	mov    %ebx,(%esp)
  800d4f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d53:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800d57:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d5a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d5d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800d60:	85 c9                	test   %ecx,%ecx
  800d62:	74 30                	je     800d94 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d64:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d6a:	75 25                	jne    800d91 <memset+0x4b>
  800d6c:	f6 c1 03             	test   $0x3,%cl
  800d6f:	75 20                	jne    800d91 <memset+0x4b>
		c &= 0xFF;
  800d71:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800d74:	89 d3                	mov    %edx,%ebx
  800d76:	c1 e3 08             	shl    $0x8,%ebx
  800d79:	89 d6                	mov    %edx,%esi
  800d7b:	c1 e6 18             	shl    $0x18,%esi
  800d7e:	89 d0                	mov    %edx,%eax
  800d80:	c1 e0 10             	shl    $0x10,%eax
  800d83:	09 f0                	or     %esi,%eax
  800d85:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800d87:	09 d8                	or     %ebx,%eax
  800d89:	c1 e9 02             	shr    $0x2,%ecx
  800d8c:	fc                   	cld    
  800d8d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d8f:	eb 03                	jmp    800d94 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d91:	fc                   	cld    
  800d92:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800d94:	89 f8                	mov    %edi,%eax
  800d96:	8b 1c 24             	mov    (%esp),%ebx
  800d99:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d9d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800da1:	89 ec                	mov    %ebp,%esp
  800da3:	5d                   	pop    %ebp
  800da4:	c3                   	ret    

00800da5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800da5:	55                   	push   %ebp
  800da6:	89 e5                	mov    %esp,%ebp
  800da8:	83 ec 08             	sub    $0x8,%esp
  800dab:	89 34 24             	mov    %esi,(%esp)
  800dae:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800db2:	8b 45 08             	mov    0x8(%ebp),%eax
  800db5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800db8:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800dbb:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800dbd:	39 c6                	cmp    %eax,%esi
  800dbf:	73 35                	jae    800df6 <memmove+0x51>
  800dc1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800dc4:	39 d0                	cmp    %edx,%eax
  800dc6:	73 2e                	jae    800df6 <memmove+0x51>
		s += n;
		d += n;
  800dc8:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800dca:	f6 c2 03             	test   $0x3,%dl
  800dcd:	75 1b                	jne    800dea <memmove+0x45>
  800dcf:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800dd5:	75 13                	jne    800dea <memmove+0x45>
  800dd7:	f6 c1 03             	test   $0x3,%cl
  800dda:	75 0e                	jne    800dea <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800ddc:	83 ef 04             	sub    $0x4,%edi
  800ddf:	8d 72 fc             	lea    -0x4(%edx),%esi
  800de2:	c1 e9 02             	shr    $0x2,%ecx
  800de5:	fd                   	std    
  800de6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800de8:	eb 09                	jmp    800df3 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800dea:	83 ef 01             	sub    $0x1,%edi
  800ded:	8d 72 ff             	lea    -0x1(%edx),%esi
  800df0:	fd                   	std    
  800df1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800df3:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800df4:	eb 20                	jmp    800e16 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800df6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800dfc:	75 15                	jne    800e13 <memmove+0x6e>
  800dfe:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e04:	75 0d                	jne    800e13 <memmove+0x6e>
  800e06:	f6 c1 03             	test   $0x3,%cl
  800e09:	75 08                	jne    800e13 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800e0b:	c1 e9 02             	shr    $0x2,%ecx
  800e0e:	fc                   	cld    
  800e0f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e11:	eb 03                	jmp    800e16 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800e13:	fc                   	cld    
  800e14:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800e16:	8b 34 24             	mov    (%esp),%esi
  800e19:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e1d:	89 ec                	mov    %ebp,%esp
  800e1f:	5d                   	pop    %ebp
  800e20:	c3                   	ret    

00800e21 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800e21:	55                   	push   %ebp
  800e22:	89 e5                	mov    %esp,%ebp
  800e24:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800e27:	8b 45 10             	mov    0x10(%ebp),%eax
  800e2a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e31:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e35:	8b 45 08             	mov    0x8(%ebp),%eax
  800e38:	89 04 24             	mov    %eax,(%esp)
  800e3b:	e8 65 ff ff ff       	call   800da5 <memmove>
}
  800e40:	c9                   	leave  
  800e41:	c3                   	ret    

00800e42 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e42:	55                   	push   %ebp
  800e43:	89 e5                	mov    %esp,%ebp
  800e45:	57                   	push   %edi
  800e46:	56                   	push   %esi
  800e47:	53                   	push   %ebx
  800e48:	8b 75 08             	mov    0x8(%ebp),%esi
  800e4b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800e4e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e51:	85 c9                	test   %ecx,%ecx
  800e53:	74 36                	je     800e8b <memcmp+0x49>
		if (*s1 != *s2)
  800e55:	0f b6 06             	movzbl (%esi),%eax
  800e58:	0f b6 1f             	movzbl (%edi),%ebx
  800e5b:	38 d8                	cmp    %bl,%al
  800e5d:	74 20                	je     800e7f <memcmp+0x3d>
  800e5f:	eb 14                	jmp    800e75 <memcmp+0x33>
  800e61:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800e66:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800e6b:	83 c2 01             	add    $0x1,%edx
  800e6e:	83 e9 01             	sub    $0x1,%ecx
  800e71:	38 d8                	cmp    %bl,%al
  800e73:	74 12                	je     800e87 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800e75:	0f b6 c0             	movzbl %al,%eax
  800e78:	0f b6 db             	movzbl %bl,%ebx
  800e7b:	29 d8                	sub    %ebx,%eax
  800e7d:	eb 11                	jmp    800e90 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e7f:	83 e9 01             	sub    $0x1,%ecx
  800e82:	ba 00 00 00 00       	mov    $0x0,%edx
  800e87:	85 c9                	test   %ecx,%ecx
  800e89:	75 d6                	jne    800e61 <memcmp+0x1f>
  800e8b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800e90:	5b                   	pop    %ebx
  800e91:	5e                   	pop    %esi
  800e92:	5f                   	pop    %edi
  800e93:	5d                   	pop    %ebp
  800e94:	c3                   	ret    

00800e95 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e95:	55                   	push   %ebp
  800e96:	89 e5                	mov    %esp,%ebp
  800e98:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800e9b:	89 c2                	mov    %eax,%edx
  800e9d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ea0:	39 d0                	cmp    %edx,%eax
  800ea2:	73 15                	jae    800eb9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ea4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800ea8:	38 08                	cmp    %cl,(%eax)
  800eaa:	75 06                	jne    800eb2 <memfind+0x1d>
  800eac:	eb 0b                	jmp    800eb9 <memfind+0x24>
  800eae:	38 08                	cmp    %cl,(%eax)
  800eb0:	74 07                	je     800eb9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800eb2:	83 c0 01             	add    $0x1,%eax
  800eb5:	39 c2                	cmp    %eax,%edx
  800eb7:	77 f5                	ja     800eae <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800eb9:	5d                   	pop    %ebp
  800eba:	c3                   	ret    

00800ebb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ebb:	55                   	push   %ebp
  800ebc:	89 e5                	mov    %esp,%ebp
  800ebe:	57                   	push   %edi
  800ebf:	56                   	push   %esi
  800ec0:	53                   	push   %ebx
  800ec1:	83 ec 04             	sub    $0x4,%esp
  800ec4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800eca:	0f b6 02             	movzbl (%edx),%eax
  800ecd:	3c 20                	cmp    $0x20,%al
  800ecf:	74 04                	je     800ed5 <strtol+0x1a>
  800ed1:	3c 09                	cmp    $0x9,%al
  800ed3:	75 0e                	jne    800ee3 <strtol+0x28>
		s++;
  800ed5:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ed8:	0f b6 02             	movzbl (%edx),%eax
  800edb:	3c 20                	cmp    $0x20,%al
  800edd:	74 f6                	je     800ed5 <strtol+0x1a>
  800edf:	3c 09                	cmp    $0x9,%al
  800ee1:	74 f2                	je     800ed5 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ee3:	3c 2b                	cmp    $0x2b,%al
  800ee5:	75 0c                	jne    800ef3 <strtol+0x38>
		s++;
  800ee7:	83 c2 01             	add    $0x1,%edx
  800eea:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800ef1:	eb 15                	jmp    800f08 <strtol+0x4d>
	else if (*s == '-')
  800ef3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800efa:	3c 2d                	cmp    $0x2d,%al
  800efc:	75 0a                	jne    800f08 <strtol+0x4d>
		s++, neg = 1;
  800efe:	83 c2 01             	add    $0x1,%edx
  800f01:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f08:	85 db                	test   %ebx,%ebx
  800f0a:	0f 94 c0             	sete   %al
  800f0d:	74 05                	je     800f14 <strtol+0x59>
  800f0f:	83 fb 10             	cmp    $0x10,%ebx
  800f12:	75 18                	jne    800f2c <strtol+0x71>
  800f14:	80 3a 30             	cmpb   $0x30,(%edx)
  800f17:	75 13                	jne    800f2c <strtol+0x71>
  800f19:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800f1d:	8d 76 00             	lea    0x0(%esi),%esi
  800f20:	75 0a                	jne    800f2c <strtol+0x71>
		s += 2, base = 16;
  800f22:	83 c2 02             	add    $0x2,%edx
  800f25:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f2a:	eb 15                	jmp    800f41 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f2c:	84 c0                	test   %al,%al
  800f2e:	66 90                	xchg   %ax,%ax
  800f30:	74 0f                	je     800f41 <strtol+0x86>
  800f32:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800f37:	80 3a 30             	cmpb   $0x30,(%edx)
  800f3a:	75 05                	jne    800f41 <strtol+0x86>
		s++, base = 8;
  800f3c:	83 c2 01             	add    $0x1,%edx
  800f3f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f41:	b8 00 00 00 00       	mov    $0x0,%eax
  800f46:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f48:	0f b6 0a             	movzbl (%edx),%ecx
  800f4b:	89 cf                	mov    %ecx,%edi
  800f4d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800f50:	80 fb 09             	cmp    $0x9,%bl
  800f53:	77 08                	ja     800f5d <strtol+0xa2>
			dig = *s - '0';
  800f55:	0f be c9             	movsbl %cl,%ecx
  800f58:	83 e9 30             	sub    $0x30,%ecx
  800f5b:	eb 1e                	jmp    800f7b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800f5d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800f60:	80 fb 19             	cmp    $0x19,%bl
  800f63:	77 08                	ja     800f6d <strtol+0xb2>
			dig = *s - 'a' + 10;
  800f65:	0f be c9             	movsbl %cl,%ecx
  800f68:	83 e9 57             	sub    $0x57,%ecx
  800f6b:	eb 0e                	jmp    800f7b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800f6d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800f70:	80 fb 19             	cmp    $0x19,%bl
  800f73:	77 15                	ja     800f8a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800f75:	0f be c9             	movsbl %cl,%ecx
  800f78:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800f7b:	39 f1                	cmp    %esi,%ecx
  800f7d:	7d 0b                	jge    800f8a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800f7f:	83 c2 01             	add    $0x1,%edx
  800f82:	0f af c6             	imul   %esi,%eax
  800f85:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800f88:	eb be                	jmp    800f48 <strtol+0x8d>
  800f8a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800f8c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f90:	74 05                	je     800f97 <strtol+0xdc>
		*endptr = (char *) s;
  800f92:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800f95:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800f97:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800f9b:	74 04                	je     800fa1 <strtol+0xe6>
  800f9d:	89 c8                	mov    %ecx,%eax
  800f9f:	f7 d8                	neg    %eax
}
  800fa1:	83 c4 04             	add    $0x4,%esp
  800fa4:	5b                   	pop    %ebx
  800fa5:	5e                   	pop    %esi
  800fa6:	5f                   	pop    %edi
  800fa7:	5d                   	pop    %ebp
  800fa8:	c3                   	ret    
  800fa9:	00 00                	add    %al,(%eax)
  800fab:	00 00                	add    %al,(%eax)
  800fad:	00 00                	add    %al,(%eax)
	...

00800fb0 <__udivdi3>:
  800fb0:	55                   	push   %ebp
  800fb1:	89 e5                	mov    %esp,%ebp
  800fb3:	57                   	push   %edi
  800fb4:	56                   	push   %esi
  800fb5:	83 ec 10             	sub    $0x10,%esp
  800fb8:	8b 45 14             	mov    0x14(%ebp),%eax
  800fbb:	8b 55 08             	mov    0x8(%ebp),%edx
  800fbe:	8b 75 10             	mov    0x10(%ebp),%esi
  800fc1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800fc4:	85 c0                	test   %eax,%eax
  800fc6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  800fc9:	75 35                	jne    801000 <__udivdi3+0x50>
  800fcb:	39 fe                	cmp    %edi,%esi
  800fcd:	77 61                	ja     801030 <__udivdi3+0x80>
  800fcf:	85 f6                	test   %esi,%esi
  800fd1:	75 0b                	jne    800fde <__udivdi3+0x2e>
  800fd3:	b8 01 00 00 00       	mov    $0x1,%eax
  800fd8:	31 d2                	xor    %edx,%edx
  800fda:	f7 f6                	div    %esi
  800fdc:	89 c6                	mov    %eax,%esi
  800fde:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  800fe1:	31 d2                	xor    %edx,%edx
  800fe3:	89 f8                	mov    %edi,%eax
  800fe5:	f7 f6                	div    %esi
  800fe7:	89 c7                	mov    %eax,%edi
  800fe9:	89 c8                	mov    %ecx,%eax
  800feb:	f7 f6                	div    %esi
  800fed:	89 c1                	mov    %eax,%ecx
  800fef:	89 fa                	mov    %edi,%edx
  800ff1:	89 c8                	mov    %ecx,%eax
  800ff3:	83 c4 10             	add    $0x10,%esp
  800ff6:	5e                   	pop    %esi
  800ff7:	5f                   	pop    %edi
  800ff8:	5d                   	pop    %ebp
  800ff9:	c3                   	ret    
  800ffa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801000:	39 f8                	cmp    %edi,%eax
  801002:	77 1c                	ja     801020 <__udivdi3+0x70>
  801004:	0f bd d0             	bsr    %eax,%edx
  801007:	83 f2 1f             	xor    $0x1f,%edx
  80100a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80100d:	75 39                	jne    801048 <__udivdi3+0x98>
  80100f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801012:	0f 86 a0 00 00 00    	jbe    8010b8 <__udivdi3+0x108>
  801018:	39 f8                	cmp    %edi,%eax
  80101a:	0f 82 98 00 00 00    	jb     8010b8 <__udivdi3+0x108>
  801020:	31 ff                	xor    %edi,%edi
  801022:	31 c9                	xor    %ecx,%ecx
  801024:	89 c8                	mov    %ecx,%eax
  801026:	89 fa                	mov    %edi,%edx
  801028:	83 c4 10             	add    $0x10,%esp
  80102b:	5e                   	pop    %esi
  80102c:	5f                   	pop    %edi
  80102d:	5d                   	pop    %ebp
  80102e:	c3                   	ret    
  80102f:	90                   	nop
  801030:	89 d1                	mov    %edx,%ecx
  801032:	89 fa                	mov    %edi,%edx
  801034:	89 c8                	mov    %ecx,%eax
  801036:	31 ff                	xor    %edi,%edi
  801038:	f7 f6                	div    %esi
  80103a:	89 c1                	mov    %eax,%ecx
  80103c:	89 fa                	mov    %edi,%edx
  80103e:	89 c8                	mov    %ecx,%eax
  801040:	83 c4 10             	add    $0x10,%esp
  801043:	5e                   	pop    %esi
  801044:	5f                   	pop    %edi
  801045:	5d                   	pop    %ebp
  801046:	c3                   	ret    
  801047:	90                   	nop
  801048:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80104c:	89 f2                	mov    %esi,%edx
  80104e:	d3 e0                	shl    %cl,%eax
  801050:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801053:	b8 20 00 00 00       	mov    $0x20,%eax
  801058:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80105b:	89 c1                	mov    %eax,%ecx
  80105d:	d3 ea                	shr    %cl,%edx
  80105f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801063:	0b 55 ec             	or     -0x14(%ebp),%edx
  801066:	d3 e6                	shl    %cl,%esi
  801068:	89 c1                	mov    %eax,%ecx
  80106a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80106d:	89 fe                	mov    %edi,%esi
  80106f:	d3 ee                	shr    %cl,%esi
  801071:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801075:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801078:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80107b:	d3 e7                	shl    %cl,%edi
  80107d:	89 c1                	mov    %eax,%ecx
  80107f:	d3 ea                	shr    %cl,%edx
  801081:	09 d7                	or     %edx,%edi
  801083:	89 f2                	mov    %esi,%edx
  801085:	89 f8                	mov    %edi,%eax
  801087:	f7 75 ec             	divl   -0x14(%ebp)
  80108a:	89 d6                	mov    %edx,%esi
  80108c:	89 c7                	mov    %eax,%edi
  80108e:	f7 65 e8             	mull   -0x18(%ebp)
  801091:	39 d6                	cmp    %edx,%esi
  801093:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801096:	72 30                	jb     8010c8 <__udivdi3+0x118>
  801098:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80109b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80109f:	d3 e2                	shl    %cl,%edx
  8010a1:	39 c2                	cmp    %eax,%edx
  8010a3:	73 05                	jae    8010aa <__udivdi3+0xfa>
  8010a5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  8010a8:	74 1e                	je     8010c8 <__udivdi3+0x118>
  8010aa:	89 f9                	mov    %edi,%ecx
  8010ac:	31 ff                	xor    %edi,%edi
  8010ae:	e9 71 ff ff ff       	jmp    801024 <__udivdi3+0x74>
  8010b3:	90                   	nop
  8010b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010b8:	31 ff                	xor    %edi,%edi
  8010ba:	b9 01 00 00 00       	mov    $0x1,%ecx
  8010bf:	e9 60 ff ff ff       	jmp    801024 <__udivdi3+0x74>
  8010c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010c8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  8010cb:	31 ff                	xor    %edi,%edi
  8010cd:	89 c8                	mov    %ecx,%eax
  8010cf:	89 fa                	mov    %edi,%edx
  8010d1:	83 c4 10             	add    $0x10,%esp
  8010d4:	5e                   	pop    %esi
  8010d5:	5f                   	pop    %edi
  8010d6:	5d                   	pop    %ebp
  8010d7:	c3                   	ret    
	...

008010e0 <__umoddi3>:
  8010e0:	55                   	push   %ebp
  8010e1:	89 e5                	mov    %esp,%ebp
  8010e3:	57                   	push   %edi
  8010e4:	56                   	push   %esi
  8010e5:	83 ec 20             	sub    $0x20,%esp
  8010e8:	8b 55 14             	mov    0x14(%ebp),%edx
  8010eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010ee:	8b 7d 10             	mov    0x10(%ebp),%edi
  8010f1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010f4:	85 d2                	test   %edx,%edx
  8010f6:	89 c8                	mov    %ecx,%eax
  8010f8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8010fb:	75 13                	jne    801110 <__umoddi3+0x30>
  8010fd:	39 f7                	cmp    %esi,%edi
  8010ff:	76 3f                	jbe    801140 <__umoddi3+0x60>
  801101:	89 f2                	mov    %esi,%edx
  801103:	f7 f7                	div    %edi
  801105:	89 d0                	mov    %edx,%eax
  801107:	31 d2                	xor    %edx,%edx
  801109:	83 c4 20             	add    $0x20,%esp
  80110c:	5e                   	pop    %esi
  80110d:	5f                   	pop    %edi
  80110e:	5d                   	pop    %ebp
  80110f:	c3                   	ret    
  801110:	39 f2                	cmp    %esi,%edx
  801112:	77 4c                	ja     801160 <__umoddi3+0x80>
  801114:	0f bd ca             	bsr    %edx,%ecx
  801117:	83 f1 1f             	xor    $0x1f,%ecx
  80111a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80111d:	75 51                	jne    801170 <__umoddi3+0x90>
  80111f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801122:	0f 87 e0 00 00 00    	ja     801208 <__umoddi3+0x128>
  801128:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80112b:	29 f8                	sub    %edi,%eax
  80112d:	19 d6                	sbb    %edx,%esi
  80112f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801132:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801135:	89 f2                	mov    %esi,%edx
  801137:	83 c4 20             	add    $0x20,%esp
  80113a:	5e                   	pop    %esi
  80113b:	5f                   	pop    %edi
  80113c:	5d                   	pop    %ebp
  80113d:	c3                   	ret    
  80113e:	66 90                	xchg   %ax,%ax
  801140:	85 ff                	test   %edi,%edi
  801142:	75 0b                	jne    80114f <__umoddi3+0x6f>
  801144:	b8 01 00 00 00       	mov    $0x1,%eax
  801149:	31 d2                	xor    %edx,%edx
  80114b:	f7 f7                	div    %edi
  80114d:	89 c7                	mov    %eax,%edi
  80114f:	89 f0                	mov    %esi,%eax
  801151:	31 d2                	xor    %edx,%edx
  801153:	f7 f7                	div    %edi
  801155:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801158:	f7 f7                	div    %edi
  80115a:	eb a9                	jmp    801105 <__umoddi3+0x25>
  80115c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801160:	89 c8                	mov    %ecx,%eax
  801162:	89 f2                	mov    %esi,%edx
  801164:	83 c4 20             	add    $0x20,%esp
  801167:	5e                   	pop    %esi
  801168:	5f                   	pop    %edi
  801169:	5d                   	pop    %ebp
  80116a:	c3                   	ret    
  80116b:	90                   	nop
  80116c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801170:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801174:	d3 e2                	shl    %cl,%edx
  801176:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801179:	ba 20 00 00 00       	mov    $0x20,%edx
  80117e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  801181:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801184:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801188:	89 fa                	mov    %edi,%edx
  80118a:	d3 ea                	shr    %cl,%edx
  80118c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801190:	0b 55 f4             	or     -0xc(%ebp),%edx
  801193:	d3 e7                	shl    %cl,%edi
  801195:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801199:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80119c:	89 f2                	mov    %esi,%edx
  80119e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  8011a1:	89 c7                	mov    %eax,%edi
  8011a3:	d3 ea                	shr    %cl,%edx
  8011a5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011a9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8011ac:	89 c2                	mov    %eax,%edx
  8011ae:	d3 e6                	shl    %cl,%esi
  8011b0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8011b4:	d3 ea                	shr    %cl,%edx
  8011b6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011ba:	09 d6                	or     %edx,%esi
  8011bc:	89 f0                	mov    %esi,%eax
  8011be:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8011c1:	d3 e7                	shl    %cl,%edi
  8011c3:	89 f2                	mov    %esi,%edx
  8011c5:	f7 75 f4             	divl   -0xc(%ebp)
  8011c8:	89 d6                	mov    %edx,%esi
  8011ca:	f7 65 e8             	mull   -0x18(%ebp)
  8011cd:	39 d6                	cmp    %edx,%esi
  8011cf:	72 2b                	jb     8011fc <__umoddi3+0x11c>
  8011d1:	39 c7                	cmp    %eax,%edi
  8011d3:	72 23                	jb     8011f8 <__umoddi3+0x118>
  8011d5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011d9:	29 c7                	sub    %eax,%edi
  8011db:	19 d6                	sbb    %edx,%esi
  8011dd:	89 f0                	mov    %esi,%eax
  8011df:	89 f2                	mov    %esi,%edx
  8011e1:	d3 ef                	shr    %cl,%edi
  8011e3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8011e7:	d3 e0                	shl    %cl,%eax
  8011e9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011ed:	09 f8                	or     %edi,%eax
  8011ef:	d3 ea                	shr    %cl,%edx
  8011f1:	83 c4 20             	add    $0x20,%esp
  8011f4:	5e                   	pop    %esi
  8011f5:	5f                   	pop    %edi
  8011f6:	5d                   	pop    %ebp
  8011f7:	c3                   	ret    
  8011f8:	39 d6                	cmp    %edx,%esi
  8011fa:	75 d9                	jne    8011d5 <__umoddi3+0xf5>
  8011fc:	2b 45 e8             	sub    -0x18(%ebp),%eax
  8011ff:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801202:	eb d1                	jmp    8011d5 <__umoddi3+0xf5>
  801204:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801208:	39 f2                	cmp    %esi,%edx
  80120a:	0f 82 18 ff ff ff    	jb     801128 <__umoddi3+0x48>
  801210:	e9 1d ff ff ff       	jmp    801132 <__umoddi3+0x52>
