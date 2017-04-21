
obj/user/testbss:     file format elf32-i386


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
  80002c:	e8 eb 00 00 00       	call   80011c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	int i;

	cprintf("Making sure bss works right...\n");
  80003a:	c7 04 24 d8 12 80 00 	movl   $0x8012d8,(%esp)
  800041:	e8 f3 01 00 00       	call   800239 <cprintf>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
  800046:	b8 01 00 00 00       	mov    $0x1,%eax
  80004b:	ba 20 20 80 00       	mov    $0x802020,%edx
  800050:	83 3d 20 20 80 00 00 	cmpl   $0x0,0x802020
  800057:	74 04                	je     80005d <umain+0x29>
  800059:	b0 00                	mov    $0x0,%al
  80005b:	eb 06                	jmp    800063 <umain+0x2f>
  80005d:	83 3c 82 00          	cmpl   $0x0,(%edx,%eax,4)
  800061:	74 20                	je     800083 <umain+0x4f>
			panic("bigarray[%d] isn't cleared!\n", i);
  800063:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800067:	c7 44 24 08 53 13 80 	movl   $0x801353,0x8(%esp)
  80006e:	00 
  80006f:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
  800076:	00 
  800077:	c7 04 24 70 13 80 00 	movl   $0x801370,(%esp)
  80007e:	e8 e5 00 00 00       	call   800168 <_panic>
umain(int argc, char **argv)
{
	int i;

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
  800083:	83 c0 01             	add    $0x1,%eax
  800086:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80008b:	75 d0                	jne    80005d <umain+0x29>
  80008d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
  800092:	ba 20 20 80 00       	mov    $0x802020,%edx
  800097:	89 04 82             	mov    %eax,(%edx,%eax,4)

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  80009a:	83 c0 01             	add    $0x1,%eax
  80009d:	3d 00 00 10 00       	cmp    $0x100000,%eax
  8000a2:	75 f3                	jne    800097 <umain+0x63>
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != i)
  8000a4:	b8 01 00 00 00       	mov    $0x1,%eax
  8000a9:	ba 20 20 80 00       	mov    $0x802020,%edx
  8000ae:	83 3d 20 20 80 00 00 	cmpl   $0x0,0x802020
  8000b5:	74 04                	je     8000bb <umain+0x87>
  8000b7:	b0 00                	mov    $0x0,%al
  8000b9:	eb 05                	jmp    8000c0 <umain+0x8c>
  8000bb:	39 04 82             	cmp    %eax,(%edx,%eax,4)
  8000be:	74 20                	je     8000e0 <umain+0xac>
			panic("bigarray[%d] didn't hold its value!\n", i);
  8000c0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000c4:	c7 44 24 08 f8 12 80 	movl   $0x8012f8,0x8(%esp)
  8000cb:	00 
  8000cc:	c7 44 24 04 16 00 00 	movl   $0x16,0x4(%esp)
  8000d3:	00 
  8000d4:	c7 04 24 70 13 80 00 	movl   $0x801370,(%esp)
  8000db:	e8 88 00 00 00       	call   800168 <_panic>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
  8000e0:	83 c0 01             	add    $0x1,%eax
  8000e3:	3d 00 00 10 00       	cmp    $0x100000,%eax
  8000e8:	75 d1                	jne    8000bb <umain+0x87>
		if (bigarray[i] != i)
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  8000ea:	c7 04 24 20 13 80 00 	movl   $0x801320,(%esp)
  8000f1:	e8 43 01 00 00       	call   800239 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000f6:	c7 05 20 30 c0 00 00 	movl   $0x0,0xc03020
  8000fd:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  800100:	c7 44 24 08 7f 13 80 	movl   $0x80137f,0x8(%esp)
  800107:	00 
  800108:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  80010f:	00 
  800110:	c7 04 24 70 13 80 00 	movl   $0x801370,(%esp)
  800117:	e8 4c 00 00 00       	call   800168 <_panic>

0080011c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80011c:	55                   	push   %ebp
  80011d:	89 e5                	mov    %esp,%ebp
  80011f:	83 ec 18             	sub    $0x18,%esp
  800122:	8b 45 08             	mov    0x8(%ebp),%eax
  800125:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800128:	c7 05 20 20 c0 00 00 	movl   $0x0,0xc02020
  80012f:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800132:	85 c0                	test   %eax,%eax
  800134:	7e 08                	jle    80013e <libmain+0x22>
		binaryname = argv[0];
  800136:	8b 0a                	mov    (%edx),%ecx
  800138:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  80013e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800142:	89 04 24             	mov    %eax,(%esp)
  800145:	e8 ea fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80014a:	e8 05 00 00 00       	call   800154 <exit>
}
  80014f:	c9                   	leave  
  800150:	c3                   	ret    
  800151:	00 00                	add    %al,(%eax)
	...

00800154 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800154:	55                   	push   %ebp
  800155:	89 e5                	mov    %esp,%ebp
  800157:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80015a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800161:	e8 a6 0e 00 00       	call   80100c <sys_env_destroy>
}
  800166:	c9                   	leave  
  800167:	c3                   	ret    

00800168 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	56                   	push   %esi
  80016c:	53                   	push   %ebx
  80016d:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  800170:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  800173:	a1 24 20 c0 00       	mov    0xc02024,%eax
  800178:	85 c0                	test   %eax,%eax
  80017a:	74 10                	je     80018c <_panic+0x24>
		cprintf("%s: ", argv0);
  80017c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800180:	c7 04 24 a0 13 80 00 	movl   $0x8013a0,(%esp)
  800187:	e8 ad 00 00 00       	call   800239 <cprintf>
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80018c:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800192:	e8 d0 0d 00 00       	call   800f67 <sys_getenvid>
  800197:	8b 55 0c             	mov    0xc(%ebp),%edx
  80019a:	89 54 24 10          	mov    %edx,0x10(%esp)
  80019e:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001a5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ad:	c7 04 24 a8 13 80 00 	movl   $0x8013a8,(%esp)
  8001b4:	e8 80 00 00 00       	call   800239 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001b9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001bd:	8b 45 10             	mov    0x10(%ebp),%eax
  8001c0:	89 04 24             	mov    %eax,(%esp)
  8001c3:	e8 10 00 00 00       	call   8001d8 <vcprintf>
	cprintf("\n");
  8001c8:	c7 04 24 6e 13 80 00 	movl   $0x80136e,(%esp)
  8001cf:	e8 65 00 00 00       	call   800239 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001d4:	cc                   	int3   
  8001d5:	eb fd                	jmp    8001d4 <_panic+0x6c>
	...

008001d8 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8001d8:	55                   	push   %ebp
  8001d9:	89 e5                	mov    %esp,%ebp
  8001db:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001e1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001e8:	00 00 00 
	b.cnt = 0;
  8001eb:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001f2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001f8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ff:	89 44 24 08          	mov    %eax,0x8(%esp)
  800203:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800209:	89 44 24 04          	mov    %eax,0x4(%esp)
  80020d:	c7 04 24 53 02 80 00 	movl   $0x800253,(%esp)
  800214:	e8 07 03 00 00       	call   800520 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800219:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80021f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800223:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800229:	89 04 24             	mov    %eax,(%esp)
  80022c:	e8 cb 0c 00 00       	call   800efc <sys_cputs>

	return b.cnt;
}
  800231:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800237:	c9                   	leave  
  800238:	c3                   	ret    

00800239 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800239:	55                   	push   %ebp
  80023a:	89 e5                	mov    %esp,%ebp
  80023c:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  80023f:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800242:	89 44 24 04          	mov    %eax,0x4(%esp)
  800246:	8b 45 08             	mov    0x8(%ebp),%eax
  800249:	89 04 24             	mov    %eax,(%esp)
  80024c:	e8 87 ff ff ff       	call   8001d8 <vcprintf>
	va_end(ap);

	return cnt;
}
  800251:	c9                   	leave  
  800252:	c3                   	ret    

00800253 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800253:	55                   	push   %ebp
  800254:	89 e5                	mov    %esp,%ebp
  800256:	53                   	push   %ebx
  800257:	83 ec 14             	sub    $0x14,%esp
  80025a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80025d:	8b 03                	mov    (%ebx),%eax
  80025f:	8b 55 08             	mov    0x8(%ebp),%edx
  800262:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800266:	83 c0 01             	add    $0x1,%eax
  800269:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80026b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800270:	75 19                	jne    80028b <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800272:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800279:	00 
  80027a:	8d 43 08             	lea    0x8(%ebx),%eax
  80027d:	89 04 24             	mov    %eax,(%esp)
  800280:	e8 77 0c 00 00       	call   800efc <sys_cputs>
		b->idx = 0;
  800285:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80028b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80028f:	83 c4 14             	add    $0x14,%esp
  800292:	5b                   	pop    %ebx
  800293:	5d                   	pop    %ebp
  800294:	c3                   	ret    
	...

008002a0 <printnum_nopad>:

/*
* help function added by Lu to print only the num;
*/
static void printnum_nopad(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int *num_len){
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	83 ec 48             	sub    $0x48,%esp
  8002a6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8002a9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8002ac:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8002af:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8002b2:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8002b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002bb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8002be:	8b 45 10             	mov    0x10(%ebp),%eax
  8002c1:	8b 7d 14             	mov    0x14(%ebp),%edi
	if(num >= base){
  8002c4:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8002cc:	39 f2                	cmp    %esi,%edx
  8002ce:	72 07                	jb     8002d7 <printnum_nopad+0x37>
  8002d0:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8002d3:	39 c8                	cmp    %ecx,%eax
  8002d5:	77 54                	ja     80032b <printnum_nopad+0x8b>
		printnum_nopad(putch, putdat, num / base, base, num_len);
  8002d7:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8002db:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002df:	8b 44 24 08          	mov    0x8(%esp),%eax
  8002e3:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8002e7:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8002ea:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8002ed:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8002f0:	89 54 24 08          	mov    %edx,0x8(%esp)
  8002f4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002fb:	00 
  8002fc:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8002ff:	89 0c 24             	mov    %ecx,(%esp)
  800302:	89 74 24 04          	mov    %esi,0x4(%esp)
  800306:	e8 65 0d 00 00       	call   801070 <__udivdi3>
  80030b:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80030e:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800311:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800315:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800319:	89 04 24             	mov    %eax,(%esp)
  80031c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800320:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800323:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800326:	e8 75 ff ff ff       	call   8002a0 <printnum_nopad>
	}
	*num_len += 1 ;
  80032b:	83 07 01             	addl   $0x1,(%edi)
	putch("0123456789abcdef"[num % base], putdat);
  80032e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800331:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800335:	8b 04 24             	mov    (%esp),%eax
  800338:	8b 54 24 04          	mov    0x4(%esp),%edx
  80033c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80033f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800342:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800345:	89 54 24 08          	mov    %edx,0x8(%esp)
  800349:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800350:	00 
  800351:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800354:	89 0c 24             	mov    %ecx,(%esp)
  800357:	89 74 24 04          	mov    %esi,0x4(%esp)
  80035b:	e8 40 0e 00 00       	call   8011a0 <__umoddi3>
  800360:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800363:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800367:	0f be 80 cb 13 80 00 	movsbl 0x8013cb(%eax),%eax
  80036e:	89 04 24             	mov    %eax,(%esp)
  800371:	ff 55 d4             	call   *-0x2c(%ebp)
}
  800374:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800377:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80037a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80037d:	89 ec                	mov    %ebp,%esp
  80037f:	5d                   	pop    %ebp
  800380:	c3                   	ret    

00800381 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800381:	55                   	push   %ebp
  800382:	89 e5                	mov    %esp,%ebp
  800384:	57                   	push   %edi
  800385:	56                   	push   %esi
  800386:	53                   	push   %ebx
  800387:	83 ec 5c             	sub    $0x5c,%esp
  80038a:	89 c7                	mov    %eax,%edi
  80038c:	89 d6                	mov    %edx,%esi
  80038e:	8b 45 08             	mov    0x8(%ebp),%eax
  800391:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800394:	8b 55 0c             	mov    0xc(%ebp),%edx
  800397:	89 55 cc             	mov    %edx,-0x34(%ebp)
  80039a:	8b 45 10             	mov    0x10(%ebp),%eax
  80039d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	if(padc == '-'){
  8003a0:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  8003a4:	75 4c                	jne    8003f2 <printnum+0x71>
		int num_len = 0;
  8003a6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		printnum_nopad(putch, putdat, num, base, &num_len);
  8003ad:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8003b0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003b4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003b8:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8003bb:	89 0c 24             	mov    %ecx,(%esp)
  8003be:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8003c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003c5:	89 f2                	mov    %esi,%edx
  8003c7:	89 f8                	mov    %edi,%eax
  8003c9:	e8 d2 fe ff ff       	call   8002a0 <printnum_nopad>
		width -= num_len;
  8003ce:	2b 5d e4             	sub    -0x1c(%ebp),%ebx
		while (width-- > 0)
  8003d1:	85 db                	test   %ebx,%ebx
  8003d3:	0f 8e e8 00 00 00    	jle    8004c1 <printnum+0x140>
			putch(' ', putdat);
  8003d9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003dd:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8003e4:	ff d7                	call   *%edi
  8003e6:	83 eb 01             	sub    $0x1,%ebx
	// your code here:
	if(padc == '-'){
		int num_len = 0;
		printnum_nopad(putch, putdat, num, base, &num_len);
		width -= num_len;
		while (width-- > 0)
  8003e9:	85 db                	test   %ebx,%ebx
  8003eb:	7f ec                	jg     8003d9 <printnum+0x58>
  8003ed:	e9 cf 00 00 00       	jmp    8004c1 <printnum+0x140>
			putch(' ', putdat);
	}
	else{
		// first recursively print all preceding (more significant) digits
		if (num >= base) {
  8003f2:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8003f5:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8003f9:	77 19                	ja     800414 <printnum+0x93>
  8003fb:	90                   	nop
  8003fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800400:	72 05                	jb     800407 <printnum+0x86>
  800402:	39 45 c8             	cmp    %eax,-0x38(%ebp)
  800405:	73 0d                	jae    800414 <printnum+0x93>
			printnum(putch, putdat, num / base, base, width - 1, padc);
		} else {
			// print any needed pad characters before first digit
			while (--width > 0)
  800407:	83 eb 01             	sub    $0x1,%ebx
  80040a:	85 db                	test   %ebx,%ebx
  80040c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800410:	7f 63                	jg     800475 <printnum+0xf4>
  800412:	eb 74                	jmp    800488 <printnum+0x107>
			putch(' ', putdat);
	}
	else{
		// first recursively print all preceding (more significant) digits
		if (num >= base) {
			printnum(putch, putdat, num / base, base, width - 1, padc);
  800414:	8b 55 18             	mov    0x18(%ebp),%edx
  800417:	89 54 24 10          	mov    %edx,0x10(%esp)
  80041b:	83 eb 01             	sub    $0x1,%ebx
  80041e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800422:	89 44 24 08          	mov    %eax,0x8(%esp)
  800426:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  80042a:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80042e:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800431:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800434:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  800437:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80043b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800442:	00 
  800443:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800446:	89 04 24             	mov    %eax,(%esp)
  800449:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80044c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800450:	e8 1b 0c 00 00       	call   801070 <__udivdi3>
  800455:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800458:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80045b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80045f:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800463:	89 04 24             	mov    %eax,(%esp)
  800466:	89 54 24 04          	mov    %edx,0x4(%esp)
  80046a:	89 f2                	mov    %esi,%edx
  80046c:	89 f8                	mov    %edi,%eax
  80046e:	e8 0e ff ff ff       	call   800381 <printnum>
  800473:	eb 13                	jmp    800488 <printnum+0x107>
		} else {
			// print any needed pad characters before first digit
			while (--width > 0)
				putch(padc, putdat);
  800475:	89 74 24 04          	mov    %esi,0x4(%esp)
  800479:	8b 45 18             	mov    0x18(%ebp),%eax
  80047c:	89 04 24             	mov    %eax,(%esp)
  80047f:	ff d7                	call   *%edi
		// first recursively print all preceding (more significant) digits
		if (num >= base) {
			printnum(putch, putdat, num / base, base, width - 1, padc);
		} else {
			// print any needed pad characters before first digit
			while (--width > 0)
  800481:	83 eb 01             	sub    $0x1,%ebx
  800484:	85 db                	test   %ebx,%ebx
  800486:	7f ed                	jg     800475 <printnum+0xf4>
				putch(padc, putdat);
		}

		// then print this (the least significant) digit
		putch("0123456789abcdef"[num % base], putdat);
  800488:	89 74 24 04          	mov    %esi,0x4(%esp)
  80048c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800490:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800493:	89 54 24 08          	mov    %edx,0x8(%esp)
  800497:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80049e:	00 
  80049f:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004a2:	89 0c 24             	mov    %ecx,(%esp)
  8004a5:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004ac:	e8 ef 0c 00 00       	call   8011a0 <__umoddi3>
  8004b1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004b5:	0f be 80 cb 13 80 00 	movsbl 0x8013cb(%eax),%eax
  8004bc:	89 04 24             	mov    %eax,(%esp)
  8004bf:	ff d7                	call   *%edi
	}
	
}
  8004c1:	83 c4 5c             	add    $0x5c,%esp
  8004c4:	5b                   	pop    %ebx
  8004c5:	5e                   	pop    %esi
  8004c6:	5f                   	pop    %edi
  8004c7:	5d                   	pop    %ebp
  8004c8:	c3                   	ret    

008004c9 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004c9:	55                   	push   %ebp
  8004ca:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004cc:	83 fa 01             	cmp    $0x1,%edx
  8004cf:	7e 0e                	jle    8004df <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004d1:	8b 10                	mov    (%eax),%edx
  8004d3:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004d6:	89 08                	mov    %ecx,(%eax)
  8004d8:	8b 02                	mov    (%edx),%eax
  8004da:	8b 52 04             	mov    0x4(%edx),%edx
  8004dd:	eb 22                	jmp    800501 <getuint+0x38>
	else if (lflag)
  8004df:	85 d2                	test   %edx,%edx
  8004e1:	74 10                	je     8004f3 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004e3:	8b 10                	mov    (%eax),%edx
  8004e5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004e8:	89 08                	mov    %ecx,(%eax)
  8004ea:	8b 02                	mov    (%edx),%eax
  8004ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8004f1:	eb 0e                	jmp    800501 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004f3:	8b 10                	mov    (%eax),%edx
  8004f5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004f8:	89 08                	mov    %ecx,(%eax)
  8004fa:	8b 02                	mov    (%edx),%eax
  8004fc:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800501:	5d                   	pop    %ebp
  800502:	c3                   	ret    

00800503 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800503:	55                   	push   %ebp
  800504:	89 e5                	mov    %esp,%ebp
  800506:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800509:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80050d:	8b 10                	mov    (%eax),%edx
  80050f:	3b 50 04             	cmp    0x4(%eax),%edx
  800512:	73 0a                	jae    80051e <sprintputch+0x1b>
		*b->buf++ = ch;
  800514:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800517:	88 0a                	mov    %cl,(%edx)
  800519:	83 c2 01             	add    $0x1,%edx
  80051c:	89 10                	mov    %edx,(%eax)
}
  80051e:	5d                   	pop    %ebp
  80051f:	c3                   	ret    

00800520 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800520:	55                   	push   %ebp
  800521:	89 e5                	mov    %esp,%ebp
  800523:	57                   	push   %edi
  800524:	56                   	push   %esi
  800525:	53                   	push   %ebx
  800526:	83 ec 5c             	sub    $0x5c,%esp
  800529:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80052c:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80052f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800536:	eb 12                	jmp    80054a <vprintfmt+0x2a>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800538:	85 c0                	test   %eax,%eax
  80053a:	0f 84 c6 04 00 00    	je     800a06 <vprintfmt+0x4e6>
				return;
			putch(ch, putdat);
  800540:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800544:	89 04 24             	mov    %eax,(%esp)
  800547:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80054a:	0f b6 03             	movzbl (%ebx),%eax
  80054d:	83 c3 01             	add    $0x1,%ebx
  800550:	83 f8 25             	cmp    $0x25,%eax
  800553:	75 e3                	jne    800538 <vprintfmt+0x18>
  800555:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  800559:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800560:	be ff ff ff ff       	mov    $0xffffffff,%esi
  800565:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  80056c:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800573:	eb 06                	jmp    80057b <vprintfmt+0x5b>
  800575:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  800579:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057b:	0f b6 0b             	movzbl (%ebx),%ecx
  80057e:	0f b6 d1             	movzbl %cl,%edx
  800581:	8d 43 01             	lea    0x1(%ebx),%eax
  800584:	83 e9 23             	sub    $0x23,%ecx
  800587:	80 f9 55             	cmp    $0x55,%cl
  80058a:	0f 87 58 04 00 00    	ja     8009e8 <vprintfmt+0x4c8>
  800590:	0f b6 c9             	movzbl %cl,%ecx
  800593:	ff 24 8d d4 14 80 00 	jmp    *0x8014d4(,%ecx,4)
  80059a:	c6 45 e0 2b          	movb   $0x2b,-0x20(%ebp)
  80059e:	eb d9                	jmp    800579 <vprintfmt+0x59>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005a0:	8d 72 d0             	lea    -0x30(%edx),%esi
				ch = *fmt;
  8005a3:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8005a6:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8005a9:	83 f9 09             	cmp    $0x9,%ecx
  8005ac:	76 08                	jbe    8005b6 <vprintfmt+0x96>
  8005ae:	eb 40                	jmp    8005f0 <vprintfmt+0xd0>
  8005b0:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
			goto reswitch;
  8005b4:	eb c3                	jmp    800579 <vprintfmt+0x59>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005b6:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  8005b9:	8d 0c b6             	lea    (%esi,%esi,4),%ecx
  8005bc:	8d 74 4a d0          	lea    -0x30(%edx,%ecx,2),%esi
				ch = *fmt;
  8005c0:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8005c3:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8005c6:	83 f9 09             	cmp    $0x9,%ecx
  8005c9:	76 eb                	jbe    8005b6 <vprintfmt+0x96>
  8005cb:	eb 23                	jmp    8005f0 <vprintfmt+0xd0>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005cd:	8b 55 14             	mov    0x14(%ebp),%edx
  8005d0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005d3:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005d6:	8b 32                	mov    (%edx),%esi
			goto process_precision;
  8005d8:	eb 16                	jmp    8005f0 <vprintfmt+0xd0>

		case '.':
			if (width < 0)
  8005da:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005dd:	c1 fa 1f             	sar    $0x1f,%edx
  8005e0:	f7 d2                	not    %edx
  8005e2:	21 55 dc             	and    %edx,-0x24(%ebp)
  8005e5:	eb 92                	jmp    800579 <vprintfmt+0x59>
  8005e7:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8005ee:	eb 89                	jmp    800579 <vprintfmt+0x59>

		process_precision:
			if (width < 0)
  8005f0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005f4:	79 83                	jns    800579 <vprintfmt+0x59>
  8005f6:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8005f9:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8005fc:	e9 78 ff ff ff       	jmp    800579 <vprintfmt+0x59>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800601:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
			goto reswitch;
  800605:	e9 6f ff ff ff       	jmp    800579 <vprintfmt+0x59>
  80060a:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80060d:	8b 45 14             	mov    0x14(%ebp),%eax
  800610:	8d 50 04             	lea    0x4(%eax),%edx
  800613:	89 55 14             	mov    %edx,0x14(%ebp)
  800616:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80061a:	8b 00                	mov    (%eax),%eax
  80061c:	89 04 24             	mov    %eax,(%esp)
  80061f:	ff 55 08             	call   *0x8(%ebp)
  800622:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  800625:	e9 20 ff ff ff       	jmp    80054a <vprintfmt+0x2a>
  80062a:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80062d:	8b 45 14             	mov    0x14(%ebp),%eax
  800630:	8d 50 04             	lea    0x4(%eax),%edx
  800633:	89 55 14             	mov    %edx,0x14(%ebp)
  800636:	8b 00                	mov    (%eax),%eax
  800638:	89 c2                	mov    %eax,%edx
  80063a:	c1 fa 1f             	sar    $0x1f,%edx
  80063d:	31 d0                	xor    %edx,%eax
  80063f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800641:	83 f8 06             	cmp    $0x6,%eax
  800644:	7f 0b                	jg     800651 <vprintfmt+0x131>
  800646:	8b 14 85 2c 16 80 00 	mov    0x80162c(,%eax,4),%edx
  80064d:	85 d2                	test   %edx,%edx
  80064f:	75 23                	jne    800674 <vprintfmt+0x154>
				printfmt(putch, putdat, "error %d", err);
  800651:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800655:	c7 44 24 08 dc 13 80 	movl   $0x8013dc,0x8(%esp)
  80065c:	00 
  80065d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800661:	8b 45 08             	mov    0x8(%ebp),%eax
  800664:	89 04 24             	mov    %eax,(%esp)
  800667:	e8 22 04 00 00       	call   800a8e <printfmt>
  80066c:	8b 5d cc             	mov    -0x34(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80066f:	e9 d6 fe ff ff       	jmp    80054a <vprintfmt+0x2a>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800674:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800678:	c7 44 24 08 e5 13 80 	movl   $0x8013e5,0x8(%esp)
  80067f:	00 
  800680:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800684:	8b 55 08             	mov    0x8(%ebp),%edx
  800687:	89 14 24             	mov    %edx,(%esp)
  80068a:	e8 ff 03 00 00       	call   800a8e <printfmt>
  80068f:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800692:	e9 b3 fe ff ff       	jmp    80054a <vprintfmt+0x2a>
  800697:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80069a:	89 c3                	mov    %eax,%ebx
  80069c:	89 f1                	mov    %esi,%ecx
  80069e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8006a1:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a7:	8d 50 04             	lea    0x4(%eax),%edx
  8006aa:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ad:	8b 00                	mov    (%eax),%eax
  8006af:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006b2:	85 c0                	test   %eax,%eax
  8006b4:	75 07                	jne    8006bd <vprintfmt+0x19d>
  8006b6:	c7 45 d0 e8 13 80 00 	movl   $0x8013e8,-0x30(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  8006bd:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8006c1:	7e 06                	jle    8006c9 <vprintfmt+0x1a9>
  8006c3:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  8006c7:	75 13                	jne    8006dc <vprintfmt+0x1bc>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006c9:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8006cc:	0f be 02             	movsbl (%edx),%eax
  8006cf:	85 c0                	test   %eax,%eax
  8006d1:	0f 85 a2 00 00 00    	jne    800779 <vprintfmt+0x259>
  8006d7:	e9 8f 00 00 00       	jmp    80076b <vprintfmt+0x24b>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006dc:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8006e0:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8006e3:	89 0c 24             	mov    %ecx,(%esp)
  8006e6:	e8 f0 03 00 00       	call   800adb <strnlen>
  8006eb:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8006ee:	29 c2                	sub    %eax,%edx
  8006f0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006f3:	85 d2                	test   %edx,%edx
  8006f5:	7e d2                	jle    8006c9 <vprintfmt+0x1a9>
					putch(padc, putdat);
  8006f7:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  8006fb:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  8006fe:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  800701:	89 d3                	mov    %edx,%ebx
  800703:	89 ce                	mov    %ecx,%esi
  800705:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800709:	89 34 24             	mov    %esi,(%esp)
  80070c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80070f:	83 eb 01             	sub    $0x1,%ebx
  800712:	85 db                	test   %ebx,%ebx
  800714:	7f ef                	jg     800705 <vprintfmt+0x1e5>
  800716:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  800719:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  80071c:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800723:	eb a4                	jmp    8006c9 <vprintfmt+0x1a9>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800725:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800729:	74 1b                	je     800746 <vprintfmt+0x226>
  80072b:	8d 50 e0             	lea    -0x20(%eax),%edx
  80072e:	83 fa 5e             	cmp    $0x5e,%edx
  800731:	76 13                	jbe    800746 <vprintfmt+0x226>
					putch('?', putdat);
  800733:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800736:	89 44 24 04          	mov    %eax,0x4(%esp)
  80073a:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800741:	ff 55 08             	call   *0x8(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800744:	eb 0d                	jmp    800753 <vprintfmt+0x233>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800746:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800749:	89 54 24 04          	mov    %edx,0x4(%esp)
  80074d:	89 04 24             	mov    %eax,(%esp)
  800750:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800753:	83 ef 01             	sub    $0x1,%edi
  800756:	0f be 03             	movsbl (%ebx),%eax
  800759:	85 c0                	test   %eax,%eax
  80075b:	74 05                	je     800762 <vprintfmt+0x242>
  80075d:	83 c3 01             	add    $0x1,%ebx
  800760:	eb 28                	jmp    80078a <vprintfmt+0x26a>
  800762:	89 7d dc             	mov    %edi,-0x24(%ebp)
  800765:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800768:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80076b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80076f:	7f 2d                	jg     80079e <vprintfmt+0x27e>
  800771:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800774:	e9 d1 fd ff ff       	jmp    80054a <vprintfmt+0x2a>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800779:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80077c:	83 c1 01             	add    $0x1,%ecx
  80077f:	89 7d e0             	mov    %edi,-0x20(%ebp)
  800782:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800785:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  800788:	89 cb                	mov    %ecx,%ebx
  80078a:	85 f6                	test   %esi,%esi
  80078c:	78 97                	js     800725 <vprintfmt+0x205>
  80078e:	83 ee 01             	sub    $0x1,%esi
  800791:	79 92                	jns    800725 <vprintfmt+0x205>
  800793:	89 7d dc             	mov    %edi,-0x24(%ebp)
  800796:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800799:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  80079c:	eb cd                	jmp    80076b <vprintfmt+0x24b>
  80079e:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a1:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8007a4:	8b 5d dc             	mov    -0x24(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007a7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007ab:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8007b2:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007b4:	83 eb 01             	sub    $0x1,%ebx
  8007b7:	85 db                	test   %ebx,%ebx
  8007b9:	7f ec                	jg     8007a7 <vprintfmt+0x287>
  8007bb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8007be:	e9 87 fd ff ff       	jmp    80054a <vprintfmt+0x2a>
  8007c3:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8007c6:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
  8007ca:	88 45 e4             	mov    %al,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007cd:	83 7d d0 01          	cmpl   $0x1,-0x30(%ebp)
  8007d1:	7e 16                	jle    8007e9 <vprintfmt+0x2c9>
		return va_arg(*ap, long long);
  8007d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d6:	8d 50 08             	lea    0x8(%eax),%edx
  8007d9:	89 55 14             	mov    %edx,0x14(%ebp)
  8007dc:	8b 10                	mov    (%eax),%edx
  8007de:	8b 48 04             	mov    0x4(%eax),%ecx
  8007e1:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8007e4:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8007e7:	eb 34                	jmp    80081d <vprintfmt+0x2fd>
	else if (lflag)
  8007e9:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8007ed:	74 18                	je     800807 <vprintfmt+0x2e7>
		return va_arg(*ap, long);
  8007ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f2:	8d 50 04             	lea    0x4(%eax),%edx
  8007f5:	89 55 14             	mov    %edx,0x14(%ebp)
  8007f8:	8b 00                	mov    (%eax),%eax
  8007fa:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8007fd:	89 c1                	mov    %eax,%ecx
  8007ff:	c1 f9 1f             	sar    $0x1f,%ecx
  800802:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800805:	eb 16                	jmp    80081d <vprintfmt+0x2fd>
	else
		return va_arg(*ap, int);
  800807:	8b 45 14             	mov    0x14(%ebp),%eax
  80080a:	8d 50 04             	lea    0x4(%eax),%edx
  80080d:	89 55 14             	mov    %edx,0x14(%ebp)
  800810:	8b 00                	mov    (%eax),%eax
  800812:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800815:	89 c2                	mov    %eax,%edx
  800817:	c1 fa 1f             	sar    $0x1f,%edx
  80081a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80081d:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800820:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if ((long long) num < 0) {
  800823:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800827:	79 2c                	jns    800855 <vprintfmt+0x335>
				putch('-', putdat);
  800829:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80082d:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800834:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800837:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80083a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80083d:	f7 db                	neg    %ebx
  80083f:	83 d6 00             	adc    $0x0,%esi
  800842:	f7 de                	neg    %esi
  800844:	0f b6 4d e0          	movzbl -0x20(%ebp),%ecx
  800848:	88 4d e4             	mov    %cl,-0x1c(%ebp)
  80084b:	ba 0a 00 00 00       	mov    $0xa,%edx
  800850:	e9 db 00 00 00       	jmp    800930 <vprintfmt+0x410>
			}
			else if (padc == '+'){
  800855:	80 7d e4 2b          	cmpb   $0x2b,-0x1c(%ebp)
  800859:	74 11                	je     80086c <vprintfmt+0x34c>
  80085b:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
  80085f:	88 45 e4             	mov    %al,-0x1c(%ebp)
  800862:	ba 0a 00 00 00       	mov    $0xa,%edx
  800867:	e9 c4 00 00 00       	jmp    800930 <vprintfmt+0x410>
				putch('+', putdat);
  80086c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800870:	c7 04 24 2b 00 00 00 	movl   $0x2b,(%esp)
  800877:	ff 55 08             	call   *0x8(%ebp)
  80087a:	ba 0a 00 00 00       	mov    $0xa,%edx
  80087f:	e9 ac 00 00 00       	jmp    800930 <vprintfmt+0x410>
  800884:	89 45 cc             	mov    %eax,-0x34(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800887:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80088a:	8d 45 14             	lea    0x14(%ebp),%eax
  80088d:	e8 37 fc ff ff       	call   8004c9 <getuint>
  800892:	89 c3                	mov    %eax,%ebx
  800894:	89 d6                	mov    %edx,%esi
  800896:	0f b6 55 e0          	movzbl -0x20(%ebp),%edx
  80089a:	88 55 e4             	mov    %dl,-0x1c(%ebp)
  80089d:	ba 0a 00 00 00       	mov    $0xa,%edx
			base = 10;
			goto number;
  8008a2:	e9 89 00 00 00       	jmp    800930 <vprintfmt+0x410>
  8008a7:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) octal
		case 'o':
			putch('0', putdat);
  8008aa:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008ae:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8008b5:	ff 55 08             	call   *0x8(%ebp)
			num = getuint(&ap, lflag);
  8008b8:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8008bb:	8d 45 14             	lea    0x14(%ebp),%eax
  8008be:	e8 06 fc ff ff       	call   8004c9 <getuint>
  8008c3:	89 c3                	mov    %eax,%ebx
  8008c5:	89 d6                	mov    %edx,%esi
  8008c7:	0f b6 4d e0          	movzbl -0x20(%ebp),%ecx
  8008cb:	88 4d e4             	mov    %cl,-0x1c(%ebp)
  8008ce:	ba 08 00 00 00       	mov    $0x8,%edx
			base = 8;
			goto number;
  8008d3:	eb 5b                	jmp    800930 <vprintfmt+0x410>
  8008d5:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  8008d8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008dc:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8008e3:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8008e6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008ea:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8008f1:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  8008f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f7:	8d 50 04             	lea    0x4(%eax),%edx
  8008fa:	89 55 14             	mov    %edx,0x14(%ebp)
  8008fd:	8b 18                	mov    (%eax),%ebx
  8008ff:	be 00 00 00 00       	mov    $0x0,%esi
  800904:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
  800908:	88 45 e4             	mov    %al,-0x1c(%ebp)
  80090b:	ba 10 00 00 00       	mov    $0x10,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800910:	eb 1e                	jmp    800930 <vprintfmt+0x410>
  800912:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800915:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800918:	8d 45 14             	lea    0x14(%ebp),%eax
  80091b:	e8 a9 fb ff ff       	call   8004c9 <getuint>
  800920:	89 c3                	mov    %eax,%ebx
  800922:	89 d6                	mov    %edx,%esi
  800924:	0f b6 55 e0          	movzbl -0x20(%ebp),%edx
  800928:	88 55 e4             	mov    %dl,-0x1c(%ebp)
  80092b:	ba 10 00 00 00       	mov    $0x10,%edx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800930:	0f be 45 e4          	movsbl -0x1c(%ebp),%eax
  800934:	89 44 24 10          	mov    %eax,0x10(%esp)
  800938:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80093b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80093f:	89 54 24 08          	mov    %edx,0x8(%esp)
  800943:	89 1c 24             	mov    %ebx,(%esp)
  800946:	89 74 24 04          	mov    %esi,0x4(%esp)
  80094a:	89 fa                	mov    %edi,%edx
  80094c:	8b 45 08             	mov    0x8(%ebp),%eax
  80094f:	e8 2d fa ff ff       	call   800381 <printnum>
  800954:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  800957:	e9 ee fb ff ff       	jmp    80054a <vprintfmt+0x2a>
  80095c:	89 45 cc             	mov    %eax,-0x34(%ebp)
            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
	    	uint32_t *num_now = putdat;
	    	char *ret_va = va_arg(ap, char *);
  80095f:	8b 45 14             	mov    0x14(%ebp),%eax
  800962:	8d 50 04             	lea    0x4(%eax),%edx
  800965:	89 55 14             	mov    %edx,0x14(%ebp)
  800968:	8b 00                	mov    (%eax),%eax
	    	if(ret_va == NULL){
  80096a:	85 c0                	test   %eax,%eax
  80096c:	75 27                	jne    800995 <vprintfmt+0x475>
				printfmt(putch, putdat, "%s", null_error);
  80096e:	c7 44 24 0c 58 14 80 	movl   $0x801458,0xc(%esp)
  800975:	00 
  800976:	c7 44 24 08 e5 13 80 	movl   $0x8013e5,0x8(%esp)
  80097d:	00 
  80097e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800982:	8b 45 08             	mov    0x8(%ebp),%eax
  800985:	89 04 24             	mov    %eax,(%esp)
  800988:	e8 01 01 00 00       	call   800a8e <printfmt>
  80098d:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800990:	e9 b5 fb ff ff       	jmp    80054a <vprintfmt+0x2a>
	    	}
	    	else if ((*num_now) >> 7 != 0 ){		//how to aurrately discribe overflow?
  800995:	8b 17                	mov    (%edi),%edx
  800997:	89 d1                	mov    %edx,%ecx
  800999:	c1 e9 07             	shr    $0x7,%ecx
  80099c:	85 c9                	test   %ecx,%ecx
  80099e:	74 29                	je     8009c9 <vprintfmt+0x4a9>
				*ret_va = *(num_now);	//get putdat at first as next print instruction will change ret_va as it's a pointer which means it's dynamic;
  8009a0:	88 10                	mov    %dl,(%eax)
				printfmt(putch, putdat, "%s", overflow_error);
  8009a2:	c7 44 24 0c 90 14 80 	movl   $0x801490,0xc(%esp)
  8009a9:	00 
  8009aa:	c7 44 24 08 e5 13 80 	movl   $0x8013e5,0x8(%esp)
  8009b1:	00 
  8009b2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8009b9:	89 14 24             	mov    %edx,(%esp)
  8009bc:	e8 cd 00 00 00       	call   800a8e <printfmt>
  8009c1:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  8009c4:	e9 81 fb ff ff       	jmp    80054a <vprintfmt+0x2a>
	    	}
	    	else{
				*ret_va = *(num_now);
  8009c9:	88 10                	mov    %dl,(%eax)
  8009cb:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  8009ce:	e9 77 fb ff ff       	jmp    80054a <vprintfmt+0x2a>
  8009d3:	89 45 cc             	mov    %eax,-0x34(%ebp)
            	break;
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8009d6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009da:	89 14 24             	mov    %edx,(%esp)
  8009dd:	ff 55 08             	call   *0x8(%ebp)
  8009e0:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  8009e3:	e9 62 fb ff ff       	jmp    80054a <vprintfmt+0x2a>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8009e8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009ec:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8009f3:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009f6:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8009f9:	80 38 25             	cmpb   $0x25,(%eax)
  8009fc:	0f 84 48 fb ff ff    	je     80054a <vprintfmt+0x2a>
  800a02:	89 c3                	mov    %eax,%ebx
  800a04:	eb f0                	jmp    8009f6 <vprintfmt+0x4d6>
				/* do nothing */;
			break;
		}
	}
}
  800a06:	83 c4 5c             	add    $0x5c,%esp
  800a09:	5b                   	pop    %ebx
  800a0a:	5e                   	pop    %esi
  800a0b:	5f                   	pop    %edi
  800a0c:	5d                   	pop    %ebp
  800a0d:	c3                   	ret    

00800a0e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a0e:	55                   	push   %ebp
  800a0f:	89 e5                	mov    %esp,%ebp
  800a11:	83 ec 28             	sub    $0x28,%esp
  800a14:	8b 45 08             	mov    0x8(%ebp),%eax
  800a17:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800a1a:	85 c0                	test   %eax,%eax
  800a1c:	74 04                	je     800a22 <vsnprintf+0x14>
  800a1e:	85 d2                	test   %edx,%edx
  800a20:	7f 07                	jg     800a29 <vsnprintf+0x1b>
  800a22:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a27:	eb 3b                	jmp    800a64 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a29:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a2c:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800a30:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a33:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a3a:	8b 45 14             	mov    0x14(%ebp),%eax
  800a3d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a41:	8b 45 10             	mov    0x10(%ebp),%eax
  800a44:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a48:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a4b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a4f:	c7 04 24 03 05 80 00 	movl   $0x800503,(%esp)
  800a56:	e8 c5 fa ff ff       	call   800520 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a5b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a5e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a61:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800a64:	c9                   	leave  
  800a65:	c3                   	ret    

00800a66 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a66:	55                   	push   %ebp
  800a67:	89 e5                	mov    %esp,%ebp
  800a69:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800a6c:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800a6f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a73:	8b 45 10             	mov    0x10(%ebp),%eax
  800a76:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a7d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a81:	8b 45 08             	mov    0x8(%ebp),%eax
  800a84:	89 04 24             	mov    %eax,(%esp)
  800a87:	e8 82 ff ff ff       	call   800a0e <vsnprintf>
	va_end(ap);

	return rc;
}
  800a8c:	c9                   	leave  
  800a8d:	c3                   	ret    

00800a8e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800a8e:	55                   	push   %ebp
  800a8f:	89 e5                	mov    %esp,%ebp
  800a91:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800a94:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800a97:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a9b:	8b 45 10             	mov    0x10(%ebp),%eax
  800a9e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800aa2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aa5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aa9:	8b 45 08             	mov    0x8(%ebp),%eax
  800aac:	89 04 24             	mov    %eax,(%esp)
  800aaf:	e8 6c fa ff ff       	call   800520 <vprintfmt>
	va_end(ap);
}
  800ab4:	c9                   	leave  
  800ab5:	c3                   	ret    
	...

00800ac0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800ac0:	55                   	push   %ebp
  800ac1:	89 e5                	mov    %esp,%ebp
  800ac3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800ac6:	b8 00 00 00 00       	mov    $0x0,%eax
  800acb:	80 3a 00             	cmpb   $0x0,(%edx)
  800ace:	74 09                	je     800ad9 <strlen+0x19>
		n++;
  800ad0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800ad3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800ad7:	75 f7                	jne    800ad0 <strlen+0x10>
		n++;
	return n;
}
  800ad9:	5d                   	pop    %ebp
  800ada:	c3                   	ret    

00800adb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800adb:	55                   	push   %ebp
  800adc:	89 e5                	mov    %esp,%ebp
  800ade:	53                   	push   %ebx
  800adf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ae2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ae5:	85 c9                	test   %ecx,%ecx
  800ae7:	74 19                	je     800b02 <strnlen+0x27>
  800ae9:	80 3b 00             	cmpb   $0x0,(%ebx)
  800aec:	74 14                	je     800b02 <strnlen+0x27>
  800aee:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800af3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800af6:	39 c8                	cmp    %ecx,%eax
  800af8:	74 0d                	je     800b07 <strnlen+0x2c>
  800afa:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800afe:	75 f3                	jne    800af3 <strnlen+0x18>
  800b00:	eb 05                	jmp    800b07 <strnlen+0x2c>
  800b02:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800b07:	5b                   	pop    %ebx
  800b08:	5d                   	pop    %ebp
  800b09:	c3                   	ret    

00800b0a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b0a:	55                   	push   %ebp
  800b0b:	89 e5                	mov    %esp,%ebp
  800b0d:	53                   	push   %ebx
  800b0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b11:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b14:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b19:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800b1d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800b20:	83 c2 01             	add    $0x1,%edx
  800b23:	84 c9                	test   %cl,%cl
  800b25:	75 f2                	jne    800b19 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800b27:	5b                   	pop    %ebx
  800b28:	5d                   	pop    %ebp
  800b29:	c3                   	ret    

00800b2a <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b2a:	55                   	push   %ebp
  800b2b:	89 e5                	mov    %esp,%ebp
  800b2d:	53                   	push   %ebx
  800b2e:	83 ec 08             	sub    $0x8,%esp
  800b31:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b34:	89 1c 24             	mov    %ebx,(%esp)
  800b37:	e8 84 ff ff ff       	call   800ac0 <strlen>
	strcpy(dst + len, src);
  800b3c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b3f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b43:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800b46:	89 04 24             	mov    %eax,(%esp)
  800b49:	e8 bc ff ff ff       	call   800b0a <strcpy>
	return dst;
}
  800b4e:	89 d8                	mov    %ebx,%eax
  800b50:	83 c4 08             	add    $0x8,%esp
  800b53:	5b                   	pop    %ebx
  800b54:	5d                   	pop    %ebp
  800b55:	c3                   	ret    

00800b56 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b56:	55                   	push   %ebp
  800b57:	89 e5                	mov    %esp,%ebp
  800b59:	56                   	push   %esi
  800b5a:	53                   	push   %ebx
  800b5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b61:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b64:	85 f6                	test   %esi,%esi
  800b66:	74 18                	je     800b80 <strncpy+0x2a>
  800b68:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800b6d:	0f b6 1a             	movzbl (%edx),%ebx
  800b70:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b73:	80 3a 01             	cmpb   $0x1,(%edx)
  800b76:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b79:	83 c1 01             	add    $0x1,%ecx
  800b7c:	39 ce                	cmp    %ecx,%esi
  800b7e:	77 ed                	ja     800b6d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b80:	5b                   	pop    %ebx
  800b81:	5e                   	pop    %esi
  800b82:	5d                   	pop    %ebp
  800b83:	c3                   	ret    

00800b84 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b84:	55                   	push   %ebp
  800b85:	89 e5                	mov    %esp,%ebp
  800b87:	56                   	push   %esi
  800b88:	53                   	push   %ebx
  800b89:	8b 75 08             	mov    0x8(%ebp),%esi
  800b8c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b8f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b92:	89 f0                	mov    %esi,%eax
  800b94:	85 c9                	test   %ecx,%ecx
  800b96:	74 27                	je     800bbf <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800b98:	83 e9 01             	sub    $0x1,%ecx
  800b9b:	74 1d                	je     800bba <strlcpy+0x36>
  800b9d:	0f b6 1a             	movzbl (%edx),%ebx
  800ba0:	84 db                	test   %bl,%bl
  800ba2:	74 16                	je     800bba <strlcpy+0x36>
			*dst++ = *src++;
  800ba4:	88 18                	mov    %bl,(%eax)
  800ba6:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ba9:	83 e9 01             	sub    $0x1,%ecx
  800bac:	74 0e                	je     800bbc <strlcpy+0x38>
			*dst++ = *src++;
  800bae:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800bb1:	0f b6 1a             	movzbl (%edx),%ebx
  800bb4:	84 db                	test   %bl,%bl
  800bb6:	75 ec                	jne    800ba4 <strlcpy+0x20>
  800bb8:	eb 02                	jmp    800bbc <strlcpy+0x38>
  800bba:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800bbc:	c6 00 00             	movb   $0x0,(%eax)
  800bbf:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800bc1:	5b                   	pop    %ebx
  800bc2:	5e                   	pop    %esi
  800bc3:	5d                   	pop    %ebp
  800bc4:	c3                   	ret    

00800bc5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800bc5:	55                   	push   %ebp
  800bc6:	89 e5                	mov    %esp,%ebp
  800bc8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bcb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800bce:	0f b6 01             	movzbl (%ecx),%eax
  800bd1:	84 c0                	test   %al,%al
  800bd3:	74 15                	je     800bea <strcmp+0x25>
  800bd5:	3a 02                	cmp    (%edx),%al
  800bd7:	75 11                	jne    800bea <strcmp+0x25>
		p++, q++;
  800bd9:	83 c1 01             	add    $0x1,%ecx
  800bdc:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800bdf:	0f b6 01             	movzbl (%ecx),%eax
  800be2:	84 c0                	test   %al,%al
  800be4:	74 04                	je     800bea <strcmp+0x25>
  800be6:	3a 02                	cmp    (%edx),%al
  800be8:	74 ef                	je     800bd9 <strcmp+0x14>
  800bea:	0f b6 c0             	movzbl %al,%eax
  800bed:	0f b6 12             	movzbl (%edx),%edx
  800bf0:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800bf2:	5d                   	pop    %ebp
  800bf3:	c3                   	ret    

00800bf4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800bf4:	55                   	push   %ebp
  800bf5:	89 e5                	mov    %esp,%ebp
  800bf7:	53                   	push   %ebx
  800bf8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bfe:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800c01:	85 c0                	test   %eax,%eax
  800c03:	74 23                	je     800c28 <strncmp+0x34>
  800c05:	0f b6 1a             	movzbl (%edx),%ebx
  800c08:	84 db                	test   %bl,%bl
  800c0a:	74 25                	je     800c31 <strncmp+0x3d>
  800c0c:	3a 19                	cmp    (%ecx),%bl
  800c0e:	75 21                	jne    800c31 <strncmp+0x3d>
  800c10:	83 e8 01             	sub    $0x1,%eax
  800c13:	74 13                	je     800c28 <strncmp+0x34>
		n--, p++, q++;
  800c15:	83 c2 01             	add    $0x1,%edx
  800c18:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c1b:	0f b6 1a             	movzbl (%edx),%ebx
  800c1e:	84 db                	test   %bl,%bl
  800c20:	74 0f                	je     800c31 <strncmp+0x3d>
  800c22:	3a 19                	cmp    (%ecx),%bl
  800c24:	74 ea                	je     800c10 <strncmp+0x1c>
  800c26:	eb 09                	jmp    800c31 <strncmp+0x3d>
  800c28:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c2d:	5b                   	pop    %ebx
  800c2e:	5d                   	pop    %ebp
  800c2f:	90                   	nop
  800c30:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c31:	0f b6 02             	movzbl (%edx),%eax
  800c34:	0f b6 11             	movzbl (%ecx),%edx
  800c37:	29 d0                	sub    %edx,%eax
  800c39:	eb f2                	jmp    800c2d <strncmp+0x39>

00800c3b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c3b:	55                   	push   %ebp
  800c3c:	89 e5                	mov    %esp,%ebp
  800c3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c41:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c45:	0f b6 10             	movzbl (%eax),%edx
  800c48:	84 d2                	test   %dl,%dl
  800c4a:	74 18                	je     800c64 <strchr+0x29>
		if (*s == c)
  800c4c:	38 ca                	cmp    %cl,%dl
  800c4e:	75 0a                	jne    800c5a <strchr+0x1f>
  800c50:	eb 17                	jmp    800c69 <strchr+0x2e>
  800c52:	38 ca                	cmp    %cl,%dl
  800c54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c58:	74 0f                	je     800c69 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c5a:	83 c0 01             	add    $0x1,%eax
  800c5d:	0f b6 10             	movzbl (%eax),%edx
  800c60:	84 d2                	test   %dl,%dl
  800c62:	75 ee                	jne    800c52 <strchr+0x17>
  800c64:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800c69:	5d                   	pop    %ebp
  800c6a:	c3                   	ret    

00800c6b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c6b:	55                   	push   %ebp
  800c6c:	89 e5                	mov    %esp,%ebp
  800c6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c71:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c75:	0f b6 10             	movzbl (%eax),%edx
  800c78:	84 d2                	test   %dl,%dl
  800c7a:	74 18                	je     800c94 <strfind+0x29>
		if (*s == c)
  800c7c:	38 ca                	cmp    %cl,%dl
  800c7e:	75 0a                	jne    800c8a <strfind+0x1f>
  800c80:	eb 12                	jmp    800c94 <strfind+0x29>
  800c82:	38 ca                	cmp    %cl,%dl
  800c84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c88:	74 0a                	je     800c94 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800c8a:	83 c0 01             	add    $0x1,%eax
  800c8d:	0f b6 10             	movzbl (%eax),%edx
  800c90:	84 d2                	test   %dl,%dl
  800c92:	75 ee                	jne    800c82 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800c94:	5d                   	pop    %ebp
  800c95:	c3                   	ret    

00800c96 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c96:	55                   	push   %ebp
  800c97:	89 e5                	mov    %esp,%ebp
  800c99:	83 ec 0c             	sub    $0xc,%esp
  800c9c:	89 1c 24             	mov    %ebx,(%esp)
  800c9f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ca3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800ca7:	8b 7d 08             	mov    0x8(%ebp),%edi
  800caa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cad:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800cb0:	85 c9                	test   %ecx,%ecx
  800cb2:	74 30                	je     800ce4 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800cb4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800cba:	75 25                	jne    800ce1 <memset+0x4b>
  800cbc:	f6 c1 03             	test   $0x3,%cl
  800cbf:	75 20                	jne    800ce1 <memset+0x4b>
		c &= 0xFF;
  800cc1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800cc4:	89 d3                	mov    %edx,%ebx
  800cc6:	c1 e3 08             	shl    $0x8,%ebx
  800cc9:	89 d6                	mov    %edx,%esi
  800ccb:	c1 e6 18             	shl    $0x18,%esi
  800cce:	89 d0                	mov    %edx,%eax
  800cd0:	c1 e0 10             	shl    $0x10,%eax
  800cd3:	09 f0                	or     %esi,%eax
  800cd5:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800cd7:	09 d8                	or     %ebx,%eax
  800cd9:	c1 e9 02             	shr    $0x2,%ecx
  800cdc:	fc                   	cld    
  800cdd:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800cdf:	eb 03                	jmp    800ce4 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ce1:	fc                   	cld    
  800ce2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ce4:	89 f8                	mov    %edi,%eax
  800ce6:	8b 1c 24             	mov    (%esp),%ebx
  800ce9:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ced:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800cf1:	89 ec                	mov    %ebp,%esp
  800cf3:	5d                   	pop    %ebp
  800cf4:	c3                   	ret    

00800cf5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800cf5:	55                   	push   %ebp
  800cf6:	89 e5                	mov    %esp,%ebp
  800cf8:	83 ec 08             	sub    $0x8,%esp
  800cfb:	89 34 24             	mov    %esi,(%esp)
  800cfe:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800d02:	8b 45 08             	mov    0x8(%ebp),%eax
  800d05:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800d08:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800d0b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800d0d:	39 c6                	cmp    %eax,%esi
  800d0f:	73 35                	jae    800d46 <memmove+0x51>
  800d11:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d14:	39 d0                	cmp    %edx,%eax
  800d16:	73 2e                	jae    800d46 <memmove+0x51>
		s += n;
		d += n;
  800d18:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d1a:	f6 c2 03             	test   $0x3,%dl
  800d1d:	75 1b                	jne    800d3a <memmove+0x45>
  800d1f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d25:	75 13                	jne    800d3a <memmove+0x45>
  800d27:	f6 c1 03             	test   $0x3,%cl
  800d2a:	75 0e                	jne    800d3a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800d2c:	83 ef 04             	sub    $0x4,%edi
  800d2f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d32:	c1 e9 02             	shr    $0x2,%ecx
  800d35:	fd                   	std    
  800d36:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d38:	eb 09                	jmp    800d43 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d3a:	83 ef 01             	sub    $0x1,%edi
  800d3d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800d40:	fd                   	std    
  800d41:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d43:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d44:	eb 20                	jmp    800d66 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d46:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d4c:	75 15                	jne    800d63 <memmove+0x6e>
  800d4e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d54:	75 0d                	jne    800d63 <memmove+0x6e>
  800d56:	f6 c1 03             	test   $0x3,%cl
  800d59:	75 08                	jne    800d63 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800d5b:	c1 e9 02             	shr    $0x2,%ecx
  800d5e:	fc                   	cld    
  800d5f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d61:	eb 03                	jmp    800d66 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d63:	fc                   	cld    
  800d64:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d66:	8b 34 24             	mov    (%esp),%esi
  800d69:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800d6d:	89 ec                	mov    %ebp,%esp
  800d6f:	5d                   	pop    %ebp
  800d70:	c3                   	ret    

00800d71 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800d71:	55                   	push   %ebp
  800d72:	89 e5                	mov    %esp,%ebp
  800d74:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800d77:	8b 45 10             	mov    0x10(%ebp),%eax
  800d7a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d7e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d81:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d85:	8b 45 08             	mov    0x8(%ebp),%eax
  800d88:	89 04 24             	mov    %eax,(%esp)
  800d8b:	e8 65 ff ff ff       	call   800cf5 <memmove>
}
  800d90:	c9                   	leave  
  800d91:	c3                   	ret    

00800d92 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d92:	55                   	push   %ebp
  800d93:	89 e5                	mov    %esp,%ebp
  800d95:	57                   	push   %edi
  800d96:	56                   	push   %esi
  800d97:	53                   	push   %ebx
  800d98:	8b 75 08             	mov    0x8(%ebp),%esi
  800d9b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800d9e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800da1:	85 c9                	test   %ecx,%ecx
  800da3:	74 36                	je     800ddb <memcmp+0x49>
		if (*s1 != *s2)
  800da5:	0f b6 06             	movzbl (%esi),%eax
  800da8:	0f b6 1f             	movzbl (%edi),%ebx
  800dab:	38 d8                	cmp    %bl,%al
  800dad:	74 20                	je     800dcf <memcmp+0x3d>
  800daf:	eb 14                	jmp    800dc5 <memcmp+0x33>
  800db1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800db6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800dbb:	83 c2 01             	add    $0x1,%edx
  800dbe:	83 e9 01             	sub    $0x1,%ecx
  800dc1:	38 d8                	cmp    %bl,%al
  800dc3:	74 12                	je     800dd7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800dc5:	0f b6 c0             	movzbl %al,%eax
  800dc8:	0f b6 db             	movzbl %bl,%ebx
  800dcb:	29 d8                	sub    %ebx,%eax
  800dcd:	eb 11                	jmp    800de0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800dcf:	83 e9 01             	sub    $0x1,%ecx
  800dd2:	ba 00 00 00 00       	mov    $0x0,%edx
  800dd7:	85 c9                	test   %ecx,%ecx
  800dd9:	75 d6                	jne    800db1 <memcmp+0x1f>
  800ddb:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800de0:	5b                   	pop    %ebx
  800de1:	5e                   	pop    %esi
  800de2:	5f                   	pop    %edi
  800de3:	5d                   	pop    %ebp
  800de4:	c3                   	ret    

00800de5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800de5:	55                   	push   %ebp
  800de6:	89 e5                	mov    %esp,%ebp
  800de8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800deb:	89 c2                	mov    %eax,%edx
  800ded:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800df0:	39 d0                	cmp    %edx,%eax
  800df2:	73 15                	jae    800e09 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800df4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800df8:	38 08                	cmp    %cl,(%eax)
  800dfa:	75 06                	jne    800e02 <memfind+0x1d>
  800dfc:	eb 0b                	jmp    800e09 <memfind+0x24>
  800dfe:	38 08                	cmp    %cl,(%eax)
  800e00:	74 07                	je     800e09 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800e02:	83 c0 01             	add    $0x1,%eax
  800e05:	39 c2                	cmp    %eax,%edx
  800e07:	77 f5                	ja     800dfe <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800e09:	5d                   	pop    %ebp
  800e0a:	c3                   	ret    

00800e0b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e0b:	55                   	push   %ebp
  800e0c:	89 e5                	mov    %esp,%ebp
  800e0e:	57                   	push   %edi
  800e0f:	56                   	push   %esi
  800e10:	53                   	push   %ebx
  800e11:	83 ec 04             	sub    $0x4,%esp
  800e14:	8b 55 08             	mov    0x8(%ebp),%edx
  800e17:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e1a:	0f b6 02             	movzbl (%edx),%eax
  800e1d:	3c 20                	cmp    $0x20,%al
  800e1f:	74 04                	je     800e25 <strtol+0x1a>
  800e21:	3c 09                	cmp    $0x9,%al
  800e23:	75 0e                	jne    800e33 <strtol+0x28>
		s++;
  800e25:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e28:	0f b6 02             	movzbl (%edx),%eax
  800e2b:	3c 20                	cmp    $0x20,%al
  800e2d:	74 f6                	je     800e25 <strtol+0x1a>
  800e2f:	3c 09                	cmp    $0x9,%al
  800e31:	74 f2                	je     800e25 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800e33:	3c 2b                	cmp    $0x2b,%al
  800e35:	75 0c                	jne    800e43 <strtol+0x38>
		s++;
  800e37:	83 c2 01             	add    $0x1,%edx
  800e3a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800e41:	eb 15                	jmp    800e58 <strtol+0x4d>
	else if (*s == '-')
  800e43:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800e4a:	3c 2d                	cmp    $0x2d,%al
  800e4c:	75 0a                	jne    800e58 <strtol+0x4d>
		s++, neg = 1;
  800e4e:	83 c2 01             	add    $0x1,%edx
  800e51:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e58:	85 db                	test   %ebx,%ebx
  800e5a:	0f 94 c0             	sete   %al
  800e5d:	74 05                	je     800e64 <strtol+0x59>
  800e5f:	83 fb 10             	cmp    $0x10,%ebx
  800e62:	75 18                	jne    800e7c <strtol+0x71>
  800e64:	80 3a 30             	cmpb   $0x30,(%edx)
  800e67:	75 13                	jne    800e7c <strtol+0x71>
  800e69:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800e6d:	8d 76 00             	lea    0x0(%esi),%esi
  800e70:	75 0a                	jne    800e7c <strtol+0x71>
		s += 2, base = 16;
  800e72:	83 c2 02             	add    $0x2,%edx
  800e75:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e7a:	eb 15                	jmp    800e91 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e7c:	84 c0                	test   %al,%al
  800e7e:	66 90                	xchg   %ax,%ax
  800e80:	74 0f                	je     800e91 <strtol+0x86>
  800e82:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800e87:	80 3a 30             	cmpb   $0x30,(%edx)
  800e8a:	75 05                	jne    800e91 <strtol+0x86>
		s++, base = 8;
  800e8c:	83 c2 01             	add    $0x1,%edx
  800e8f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e91:	b8 00 00 00 00       	mov    $0x0,%eax
  800e96:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e98:	0f b6 0a             	movzbl (%edx),%ecx
  800e9b:	89 cf                	mov    %ecx,%edi
  800e9d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ea0:	80 fb 09             	cmp    $0x9,%bl
  800ea3:	77 08                	ja     800ead <strtol+0xa2>
			dig = *s - '0';
  800ea5:	0f be c9             	movsbl %cl,%ecx
  800ea8:	83 e9 30             	sub    $0x30,%ecx
  800eab:	eb 1e                	jmp    800ecb <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800ead:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800eb0:	80 fb 19             	cmp    $0x19,%bl
  800eb3:	77 08                	ja     800ebd <strtol+0xb2>
			dig = *s - 'a' + 10;
  800eb5:	0f be c9             	movsbl %cl,%ecx
  800eb8:	83 e9 57             	sub    $0x57,%ecx
  800ebb:	eb 0e                	jmp    800ecb <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800ebd:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800ec0:	80 fb 19             	cmp    $0x19,%bl
  800ec3:	77 15                	ja     800eda <strtol+0xcf>
			dig = *s - 'A' + 10;
  800ec5:	0f be c9             	movsbl %cl,%ecx
  800ec8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ecb:	39 f1                	cmp    %esi,%ecx
  800ecd:	7d 0b                	jge    800eda <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800ecf:	83 c2 01             	add    $0x1,%edx
  800ed2:	0f af c6             	imul   %esi,%eax
  800ed5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800ed8:	eb be                	jmp    800e98 <strtol+0x8d>
  800eda:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800edc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ee0:	74 05                	je     800ee7 <strtol+0xdc>
		*endptr = (char *) s;
  800ee2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ee5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ee7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800eeb:	74 04                	je     800ef1 <strtol+0xe6>
  800eed:	89 c8                	mov    %ecx,%eax
  800eef:	f7 d8                	neg    %eax
}
  800ef1:	83 c4 04             	add    $0x4,%esp
  800ef4:	5b                   	pop    %ebx
  800ef5:	5e                   	pop    %esi
  800ef6:	5f                   	pop    %edi
  800ef7:	5d                   	pop    %ebp
  800ef8:	c3                   	ret    
  800ef9:	00 00                	add    %al,(%eax)
	...

00800efc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800efc:	55                   	push   %ebp
  800efd:	89 e5                	mov    %esp,%ebp
  800eff:	83 ec 08             	sub    $0x8,%esp
  800f02:	89 1c 24             	mov    %ebx,(%esp)
  800f05:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f09:	b8 00 00 00 00       	mov    $0x0,%eax
  800f0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f11:	8b 55 08             	mov    0x8(%ebp),%edx
  800f14:	89 c3                	mov    %eax,%ebx
  800f16:	89 c7                	mov    %eax,%edi
  800f18:	51                   	push   %ecx
  800f19:	52                   	push   %edx
  800f1a:	53                   	push   %ebx
  800f1b:	54                   	push   %esp
  800f1c:	55                   	push   %ebp
  800f1d:	56                   	push   %esi
  800f1e:	57                   	push   %edi
  800f1f:	5f                   	pop    %edi
  800f20:	5e                   	pop    %esi
  800f21:	5d                   	pop    %ebp
  800f22:	5c                   	pop    %esp
  800f23:	5b                   	pop    %ebx
  800f24:	5a                   	pop    %edx
  800f25:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800f26:	8b 1c 24             	mov    (%esp),%ebx
  800f29:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f2d:	89 ec                	mov    %ebp,%esp
  800f2f:	5d                   	pop    %ebp
  800f30:	c3                   	ret    

00800f31 <sys_cgetc>:

int
sys_cgetc(void)
{
  800f31:	55                   	push   %ebp
  800f32:	89 e5                	mov    %esp,%ebp
  800f34:	83 ec 08             	sub    $0x8,%esp
  800f37:	89 1c 24             	mov    %ebx,(%esp)
  800f3a:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f3e:	ba 00 00 00 00       	mov    $0x0,%edx
  800f43:	b8 01 00 00 00       	mov    $0x1,%eax
  800f48:	89 d1                	mov    %edx,%ecx
  800f4a:	89 d3                	mov    %edx,%ebx
  800f4c:	89 d7                	mov    %edx,%edi
  800f4e:	51                   	push   %ecx
  800f4f:	52                   	push   %edx
  800f50:	53                   	push   %ebx
  800f51:	54                   	push   %esp
  800f52:	55                   	push   %ebp
  800f53:	56                   	push   %esi
  800f54:	57                   	push   %edi
  800f55:	5f                   	pop    %edi
  800f56:	5e                   	pop    %esi
  800f57:	5d                   	pop    %ebp
  800f58:	5c                   	pop    %esp
  800f59:	5b                   	pop    %ebx
  800f5a:	5a                   	pop    %edx
  800f5b:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800f5c:	8b 1c 24             	mov    (%esp),%ebx
  800f5f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f63:	89 ec                	mov    %ebp,%esp
  800f65:	5d                   	pop    %ebp
  800f66:	c3                   	ret    

00800f67 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800f67:	55                   	push   %ebp
  800f68:	89 e5                	mov    %esp,%ebp
  800f6a:	83 ec 08             	sub    $0x8,%esp
  800f6d:	89 1c 24             	mov    %ebx,(%esp)
  800f70:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f74:	ba 00 00 00 00       	mov    $0x0,%edx
  800f79:	b8 02 00 00 00       	mov    $0x2,%eax
  800f7e:	89 d1                	mov    %edx,%ecx
  800f80:	89 d3                	mov    %edx,%ebx
  800f82:	89 d7                	mov    %edx,%edi
  800f84:	51                   	push   %ecx
  800f85:	52                   	push   %edx
  800f86:	53                   	push   %ebx
  800f87:	54                   	push   %esp
  800f88:	55                   	push   %ebp
  800f89:	56                   	push   %esi
  800f8a:	57                   	push   %edi
  800f8b:	5f                   	pop    %edi
  800f8c:	5e                   	pop    %esi
  800f8d:	5d                   	pop    %ebp
  800f8e:	5c                   	pop    %esp
  800f8f:	5b                   	pop    %ebx
  800f90:	5a                   	pop    %edx
  800f91:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f92:	8b 1c 24             	mov    (%esp),%ebx
  800f95:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f99:	89 ec                	mov    %ebp,%esp
  800f9b:	5d                   	pop    %ebp
  800f9c:	c3                   	ret    

00800f9d <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800f9d:	55                   	push   %ebp
  800f9e:	89 e5                	mov    %esp,%ebp
  800fa0:	83 ec 08             	sub    $0x8,%esp
  800fa3:	89 1c 24             	mov    %ebx,(%esp)
  800fa6:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800faa:	bb 00 00 00 00       	mov    $0x0,%ebx
  800faf:	b8 04 00 00 00       	mov    $0x4,%eax
  800fb4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fb7:	8b 55 08             	mov    0x8(%ebp),%edx
  800fba:	89 df                	mov    %ebx,%edi
  800fbc:	51                   	push   %ecx
  800fbd:	52                   	push   %edx
  800fbe:	53                   	push   %ebx
  800fbf:	54                   	push   %esp
  800fc0:	55                   	push   %ebp
  800fc1:	56                   	push   %esi
  800fc2:	57                   	push   %edi
  800fc3:	5f                   	pop    %edi
  800fc4:	5e                   	pop    %esi
  800fc5:	5d                   	pop    %ebp
  800fc6:	5c                   	pop    %esp
  800fc7:	5b                   	pop    %ebx
  800fc8:	5a                   	pop    %edx
  800fc9:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800fca:	8b 1c 24             	mov    (%esp),%ebx
  800fcd:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800fd1:	89 ec                	mov    %ebp,%esp
  800fd3:	5d                   	pop    %ebp
  800fd4:	c3                   	ret    

00800fd5 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  800fd5:	55                   	push   %ebp
  800fd6:	89 e5                	mov    %esp,%ebp
  800fd8:	83 ec 08             	sub    $0x8,%esp
  800fdb:	89 1c 24             	mov    %ebx,(%esp)
  800fde:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800fe2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fe7:	b8 05 00 00 00       	mov    $0x5,%eax
  800fec:	8b 55 08             	mov    0x8(%ebp),%edx
  800fef:	89 cb                	mov    %ecx,%ebx
  800ff1:	89 cf                	mov    %ecx,%edi
  800ff3:	51                   	push   %ecx
  800ff4:	52                   	push   %edx
  800ff5:	53                   	push   %ebx
  800ff6:	54                   	push   %esp
  800ff7:	55                   	push   %ebp
  800ff8:	56                   	push   %esi
  800ff9:	57                   	push   %edi
  800ffa:	5f                   	pop    %edi
  800ffb:	5e                   	pop    %esi
  800ffc:	5d                   	pop    %ebp
  800ffd:	5c                   	pop    %esp
  800ffe:	5b                   	pop    %ebx
  800fff:	5a                   	pop    %edx
  801000:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  801001:	8b 1c 24             	mov    (%esp),%ebx
  801004:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801008:	89 ec                	mov    %ebp,%esp
  80100a:	5d                   	pop    %ebp
  80100b:	c3                   	ret    

0080100c <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  80100c:	55                   	push   %ebp
  80100d:	89 e5                	mov    %esp,%ebp
  80100f:	83 ec 28             	sub    $0x28,%esp
  801012:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801015:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801018:	b9 00 00 00 00       	mov    $0x0,%ecx
  80101d:	b8 03 00 00 00       	mov    $0x3,%eax
  801022:	8b 55 08             	mov    0x8(%ebp),%edx
  801025:	89 cb                	mov    %ecx,%ebx
  801027:	89 cf                	mov    %ecx,%edi
  801029:	51                   	push   %ecx
  80102a:	52                   	push   %edx
  80102b:	53                   	push   %ebx
  80102c:	54                   	push   %esp
  80102d:	55                   	push   %ebp
  80102e:	56                   	push   %esi
  80102f:	57                   	push   %edi
  801030:	5f                   	pop    %edi
  801031:	5e                   	pop    %esi
  801032:	5d                   	pop    %ebp
  801033:	5c                   	pop    %esp
  801034:	5b                   	pop    %ebx
  801035:	5a                   	pop    %edx
  801036:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  801037:	85 c0                	test   %eax,%eax
  801039:	7e 28                	jle    801063 <sys_env_destroy+0x57>
		panic("syscall %d returned %d (> 0)", num, ret);
  80103b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80103f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801046:	00 
  801047:	c7 44 24 08 48 16 80 	movl   $0x801648,0x8(%esp)
  80104e:	00 
  80104f:	c7 44 24 04 26 00 00 	movl   $0x26,0x4(%esp)
  801056:	00 
  801057:	c7 04 24 65 16 80 00 	movl   $0x801665,(%esp)
  80105e:	e8 05 f1 ff ff       	call   800168 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801063:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801066:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801069:	89 ec                	mov    %ebp,%esp
  80106b:	5d                   	pop    %ebp
  80106c:	c3                   	ret    
  80106d:	00 00                	add    %al,(%eax)
	...

00801070 <__udivdi3>:
  801070:	55                   	push   %ebp
  801071:	89 e5                	mov    %esp,%ebp
  801073:	57                   	push   %edi
  801074:	56                   	push   %esi
  801075:	83 ec 10             	sub    $0x10,%esp
  801078:	8b 45 14             	mov    0x14(%ebp),%eax
  80107b:	8b 55 08             	mov    0x8(%ebp),%edx
  80107e:	8b 75 10             	mov    0x10(%ebp),%esi
  801081:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801084:	85 c0                	test   %eax,%eax
  801086:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801089:	75 35                	jne    8010c0 <__udivdi3+0x50>
  80108b:	39 fe                	cmp    %edi,%esi
  80108d:	77 61                	ja     8010f0 <__udivdi3+0x80>
  80108f:	85 f6                	test   %esi,%esi
  801091:	75 0b                	jne    80109e <__udivdi3+0x2e>
  801093:	b8 01 00 00 00       	mov    $0x1,%eax
  801098:	31 d2                	xor    %edx,%edx
  80109a:	f7 f6                	div    %esi
  80109c:	89 c6                	mov    %eax,%esi
  80109e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  8010a1:	31 d2                	xor    %edx,%edx
  8010a3:	89 f8                	mov    %edi,%eax
  8010a5:	f7 f6                	div    %esi
  8010a7:	89 c7                	mov    %eax,%edi
  8010a9:	89 c8                	mov    %ecx,%eax
  8010ab:	f7 f6                	div    %esi
  8010ad:	89 c1                	mov    %eax,%ecx
  8010af:	89 fa                	mov    %edi,%edx
  8010b1:	89 c8                	mov    %ecx,%eax
  8010b3:	83 c4 10             	add    $0x10,%esp
  8010b6:	5e                   	pop    %esi
  8010b7:	5f                   	pop    %edi
  8010b8:	5d                   	pop    %ebp
  8010b9:	c3                   	ret    
  8010ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8010c0:	39 f8                	cmp    %edi,%eax
  8010c2:	77 1c                	ja     8010e0 <__udivdi3+0x70>
  8010c4:	0f bd d0             	bsr    %eax,%edx
  8010c7:	83 f2 1f             	xor    $0x1f,%edx
  8010ca:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8010cd:	75 39                	jne    801108 <__udivdi3+0x98>
  8010cf:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  8010d2:	0f 86 a0 00 00 00    	jbe    801178 <__udivdi3+0x108>
  8010d8:	39 f8                	cmp    %edi,%eax
  8010da:	0f 82 98 00 00 00    	jb     801178 <__udivdi3+0x108>
  8010e0:	31 ff                	xor    %edi,%edi
  8010e2:	31 c9                	xor    %ecx,%ecx
  8010e4:	89 c8                	mov    %ecx,%eax
  8010e6:	89 fa                	mov    %edi,%edx
  8010e8:	83 c4 10             	add    $0x10,%esp
  8010eb:	5e                   	pop    %esi
  8010ec:	5f                   	pop    %edi
  8010ed:	5d                   	pop    %ebp
  8010ee:	c3                   	ret    
  8010ef:	90                   	nop
  8010f0:	89 d1                	mov    %edx,%ecx
  8010f2:	89 fa                	mov    %edi,%edx
  8010f4:	89 c8                	mov    %ecx,%eax
  8010f6:	31 ff                	xor    %edi,%edi
  8010f8:	f7 f6                	div    %esi
  8010fa:	89 c1                	mov    %eax,%ecx
  8010fc:	89 fa                	mov    %edi,%edx
  8010fe:	89 c8                	mov    %ecx,%eax
  801100:	83 c4 10             	add    $0x10,%esp
  801103:	5e                   	pop    %esi
  801104:	5f                   	pop    %edi
  801105:	5d                   	pop    %ebp
  801106:	c3                   	ret    
  801107:	90                   	nop
  801108:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80110c:	89 f2                	mov    %esi,%edx
  80110e:	d3 e0                	shl    %cl,%eax
  801110:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801113:	b8 20 00 00 00       	mov    $0x20,%eax
  801118:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80111b:	89 c1                	mov    %eax,%ecx
  80111d:	d3 ea                	shr    %cl,%edx
  80111f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801123:	0b 55 ec             	or     -0x14(%ebp),%edx
  801126:	d3 e6                	shl    %cl,%esi
  801128:	89 c1                	mov    %eax,%ecx
  80112a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80112d:	89 fe                	mov    %edi,%esi
  80112f:	d3 ee                	shr    %cl,%esi
  801131:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801135:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801138:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80113b:	d3 e7                	shl    %cl,%edi
  80113d:	89 c1                	mov    %eax,%ecx
  80113f:	d3 ea                	shr    %cl,%edx
  801141:	09 d7                	or     %edx,%edi
  801143:	89 f2                	mov    %esi,%edx
  801145:	89 f8                	mov    %edi,%eax
  801147:	f7 75 ec             	divl   -0x14(%ebp)
  80114a:	89 d6                	mov    %edx,%esi
  80114c:	89 c7                	mov    %eax,%edi
  80114e:	f7 65 e8             	mull   -0x18(%ebp)
  801151:	39 d6                	cmp    %edx,%esi
  801153:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801156:	72 30                	jb     801188 <__udivdi3+0x118>
  801158:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80115b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80115f:	d3 e2                	shl    %cl,%edx
  801161:	39 c2                	cmp    %eax,%edx
  801163:	73 05                	jae    80116a <__udivdi3+0xfa>
  801165:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801168:	74 1e                	je     801188 <__udivdi3+0x118>
  80116a:	89 f9                	mov    %edi,%ecx
  80116c:	31 ff                	xor    %edi,%edi
  80116e:	e9 71 ff ff ff       	jmp    8010e4 <__udivdi3+0x74>
  801173:	90                   	nop
  801174:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801178:	31 ff                	xor    %edi,%edi
  80117a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80117f:	e9 60 ff ff ff       	jmp    8010e4 <__udivdi3+0x74>
  801184:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801188:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80118b:	31 ff                	xor    %edi,%edi
  80118d:	89 c8                	mov    %ecx,%eax
  80118f:	89 fa                	mov    %edi,%edx
  801191:	83 c4 10             	add    $0x10,%esp
  801194:	5e                   	pop    %esi
  801195:	5f                   	pop    %edi
  801196:	5d                   	pop    %ebp
  801197:	c3                   	ret    
	...

008011a0 <__umoddi3>:
  8011a0:	55                   	push   %ebp
  8011a1:	89 e5                	mov    %esp,%ebp
  8011a3:	57                   	push   %edi
  8011a4:	56                   	push   %esi
  8011a5:	83 ec 20             	sub    $0x20,%esp
  8011a8:	8b 55 14             	mov    0x14(%ebp),%edx
  8011ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011ae:	8b 7d 10             	mov    0x10(%ebp),%edi
  8011b1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8011b4:	85 d2                	test   %edx,%edx
  8011b6:	89 c8                	mov    %ecx,%eax
  8011b8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8011bb:	75 13                	jne    8011d0 <__umoddi3+0x30>
  8011bd:	39 f7                	cmp    %esi,%edi
  8011bf:	76 3f                	jbe    801200 <__umoddi3+0x60>
  8011c1:	89 f2                	mov    %esi,%edx
  8011c3:	f7 f7                	div    %edi
  8011c5:	89 d0                	mov    %edx,%eax
  8011c7:	31 d2                	xor    %edx,%edx
  8011c9:	83 c4 20             	add    $0x20,%esp
  8011cc:	5e                   	pop    %esi
  8011cd:	5f                   	pop    %edi
  8011ce:	5d                   	pop    %ebp
  8011cf:	c3                   	ret    
  8011d0:	39 f2                	cmp    %esi,%edx
  8011d2:	77 4c                	ja     801220 <__umoddi3+0x80>
  8011d4:	0f bd ca             	bsr    %edx,%ecx
  8011d7:	83 f1 1f             	xor    $0x1f,%ecx
  8011da:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8011dd:	75 51                	jne    801230 <__umoddi3+0x90>
  8011df:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  8011e2:	0f 87 e0 00 00 00    	ja     8012c8 <__umoddi3+0x128>
  8011e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011eb:	29 f8                	sub    %edi,%eax
  8011ed:	19 d6                	sbb    %edx,%esi
  8011ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8011f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011f5:	89 f2                	mov    %esi,%edx
  8011f7:	83 c4 20             	add    $0x20,%esp
  8011fa:	5e                   	pop    %esi
  8011fb:	5f                   	pop    %edi
  8011fc:	5d                   	pop    %ebp
  8011fd:	c3                   	ret    
  8011fe:	66 90                	xchg   %ax,%ax
  801200:	85 ff                	test   %edi,%edi
  801202:	75 0b                	jne    80120f <__umoddi3+0x6f>
  801204:	b8 01 00 00 00       	mov    $0x1,%eax
  801209:	31 d2                	xor    %edx,%edx
  80120b:	f7 f7                	div    %edi
  80120d:	89 c7                	mov    %eax,%edi
  80120f:	89 f0                	mov    %esi,%eax
  801211:	31 d2                	xor    %edx,%edx
  801213:	f7 f7                	div    %edi
  801215:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801218:	f7 f7                	div    %edi
  80121a:	eb a9                	jmp    8011c5 <__umoddi3+0x25>
  80121c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801220:	89 c8                	mov    %ecx,%eax
  801222:	89 f2                	mov    %esi,%edx
  801224:	83 c4 20             	add    $0x20,%esp
  801227:	5e                   	pop    %esi
  801228:	5f                   	pop    %edi
  801229:	5d                   	pop    %ebp
  80122a:	c3                   	ret    
  80122b:	90                   	nop
  80122c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801230:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801234:	d3 e2                	shl    %cl,%edx
  801236:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801239:	ba 20 00 00 00       	mov    $0x20,%edx
  80123e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  801241:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801244:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801248:	89 fa                	mov    %edi,%edx
  80124a:	d3 ea                	shr    %cl,%edx
  80124c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801250:	0b 55 f4             	or     -0xc(%ebp),%edx
  801253:	d3 e7                	shl    %cl,%edi
  801255:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801259:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80125c:	89 f2                	mov    %esi,%edx
  80125e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801261:	89 c7                	mov    %eax,%edi
  801263:	d3 ea                	shr    %cl,%edx
  801265:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801269:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80126c:	89 c2                	mov    %eax,%edx
  80126e:	d3 e6                	shl    %cl,%esi
  801270:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801274:	d3 ea                	shr    %cl,%edx
  801276:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80127a:	09 d6                	or     %edx,%esi
  80127c:	89 f0                	mov    %esi,%eax
  80127e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801281:	d3 e7                	shl    %cl,%edi
  801283:	89 f2                	mov    %esi,%edx
  801285:	f7 75 f4             	divl   -0xc(%ebp)
  801288:	89 d6                	mov    %edx,%esi
  80128a:	f7 65 e8             	mull   -0x18(%ebp)
  80128d:	39 d6                	cmp    %edx,%esi
  80128f:	72 2b                	jb     8012bc <__umoddi3+0x11c>
  801291:	39 c7                	cmp    %eax,%edi
  801293:	72 23                	jb     8012b8 <__umoddi3+0x118>
  801295:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801299:	29 c7                	sub    %eax,%edi
  80129b:	19 d6                	sbb    %edx,%esi
  80129d:	89 f0                	mov    %esi,%eax
  80129f:	89 f2                	mov    %esi,%edx
  8012a1:	d3 ef                	shr    %cl,%edi
  8012a3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8012a7:	d3 e0                	shl    %cl,%eax
  8012a9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8012ad:	09 f8                	or     %edi,%eax
  8012af:	d3 ea                	shr    %cl,%edx
  8012b1:	83 c4 20             	add    $0x20,%esp
  8012b4:	5e                   	pop    %esi
  8012b5:	5f                   	pop    %edi
  8012b6:	5d                   	pop    %ebp
  8012b7:	c3                   	ret    
  8012b8:	39 d6                	cmp    %edx,%esi
  8012ba:	75 d9                	jne    801295 <__umoddi3+0xf5>
  8012bc:	2b 45 e8             	sub    -0x18(%ebp),%eax
  8012bf:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  8012c2:	eb d1                	jmp    801295 <__umoddi3+0xf5>
  8012c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012c8:	39 f2                	cmp    %esi,%edx
  8012ca:	0f 82 18 ff ff ff    	jb     8011e8 <__umoddi3+0x48>
  8012d0:	e9 1d ff ff ff       	jmp    8011f2 <__umoddi3+0x52>
