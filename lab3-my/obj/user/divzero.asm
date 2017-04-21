
obj/user/divzero:     file format elf32-i386


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
  80002c:	e8 37 00 00 00       	call   800068 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	zero = 0;
  80003a:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800041:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800044:	ba 01 00 00 00       	mov    $0x1,%edx
  800049:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004e:	89 d0                	mov    %edx,%eax
  800050:	c1 fa 1f             	sar    $0x1f,%edx
  800053:	f7 f9                	idiv   %ecx
  800055:	89 44 24 04          	mov    %eax,0x4(%esp)
  800059:	c7 04 24 28 12 80 00 	movl   $0x801228,(%esp)
  800060:	e8 b0 00 00 00       	call   800115 <cprintf>
}
  800065:	c9                   	leave  
  800066:	c3                   	ret    
	...

00800068 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800068:	55                   	push   %ebp
  800069:	89 e5                	mov    %esp,%ebp
  80006b:	83 ec 18             	sub    $0x18,%esp
  80006e:	8b 45 08             	mov    0x8(%ebp),%eax
  800071:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800074:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  80007b:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007e:	85 c0                	test   %eax,%eax
  800080:	7e 08                	jle    80008a <libmain+0x22>
		binaryname = argv[0];
  800082:	8b 0a                	mov    (%edx),%ecx
  800084:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  80008a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80008e:	89 04 24             	mov    %eax,(%esp)
  800091:	e8 9e ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800096:	e8 05 00 00 00       	call   8000a0 <exit>
}
  80009b:	c9                   	leave  
  80009c:	c3                   	ret    
  80009d:	00 00                	add    %al,(%eax)
	...

008000a0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000a6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ad:	e8 3a 0e 00 00       	call   800eec <sys_env_destroy>
}
  8000b2:	c9                   	leave  
  8000b3:	c3                   	ret    

008000b4 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8000bd:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8000c4:	00 00 00 
	b.cnt = 0;
  8000c7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8000ce:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8000d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000d4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8000db:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000df:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8000e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000e9:	c7 04 24 2f 01 80 00 	movl   $0x80012f,(%esp)
  8000f0:	e8 0b 03 00 00       	call   800400 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8000f5:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8000fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000ff:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800105:	89 04 24             	mov    %eax,(%esp)
  800108:	e8 cf 0c 00 00       	call   800ddc <sys_cputs>

	return b.cnt;
}
  80010d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800113:	c9                   	leave  
  800114:	c3                   	ret    

00800115 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800115:	55                   	push   %ebp
  800116:	89 e5                	mov    %esp,%ebp
  800118:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  80011b:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  80011e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800122:	8b 45 08             	mov    0x8(%ebp),%eax
  800125:	89 04 24             	mov    %eax,(%esp)
  800128:	e8 87 ff ff ff       	call   8000b4 <vcprintf>
	va_end(ap);

	return cnt;
}
  80012d:	c9                   	leave  
  80012e:	c3                   	ret    

0080012f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80012f:	55                   	push   %ebp
  800130:	89 e5                	mov    %esp,%ebp
  800132:	53                   	push   %ebx
  800133:	83 ec 14             	sub    $0x14,%esp
  800136:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800139:	8b 03                	mov    (%ebx),%eax
  80013b:	8b 55 08             	mov    0x8(%ebp),%edx
  80013e:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800142:	83 c0 01             	add    $0x1,%eax
  800145:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800147:	3d ff 00 00 00       	cmp    $0xff,%eax
  80014c:	75 19                	jne    800167 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80014e:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800155:	00 
  800156:	8d 43 08             	lea    0x8(%ebx),%eax
  800159:	89 04 24             	mov    %eax,(%esp)
  80015c:	e8 7b 0c 00 00       	call   800ddc <sys_cputs>
		b->idx = 0;
  800161:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800167:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80016b:	83 c4 14             	add    $0x14,%esp
  80016e:	5b                   	pop    %ebx
  80016f:	5d                   	pop    %ebp
  800170:	c3                   	ret    
	...

00800180 <printnum_nopad>:

/*
* help function added by Lu to print only the num;
*/
static void printnum_nopad(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int *num_len){
  800180:	55                   	push   %ebp
  800181:	89 e5                	mov    %esp,%ebp
  800183:	83 ec 48             	sub    $0x48,%esp
  800186:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800189:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80018c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80018f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800192:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800195:	8b 45 08             	mov    0x8(%ebp),%eax
  800198:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80019b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80019e:	8b 45 10             	mov    0x10(%ebp),%eax
  8001a1:	8b 7d 14             	mov    0x14(%ebp),%edi
	if(num >= base){
  8001a4:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8001ac:	39 f2                	cmp    %esi,%edx
  8001ae:	72 07                	jb     8001b7 <printnum_nopad+0x37>
  8001b0:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8001b3:	39 c8                	cmp    %ecx,%eax
  8001b5:	77 54                	ja     80020b <printnum_nopad+0x8b>
		printnum_nopad(putch, putdat, num / base, base, num_len);
  8001b7:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8001bb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001bf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8001c3:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8001c7:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8001ca:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8001cd:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8001d0:	89 54 24 08          	mov    %edx,0x8(%esp)
  8001d4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001db:	00 
  8001dc:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8001df:	89 0c 24             	mov    %ecx,(%esp)
  8001e2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001e6:	e8 d5 0d 00 00       	call   800fc0 <__udivdi3>
  8001eb:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8001ee:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  8001f1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8001f5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001f9:	89 04 24             	mov    %eax,(%esp)
  8001fc:	89 54 24 04          	mov    %edx,0x4(%esp)
  800200:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800203:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800206:	e8 75 ff ff ff       	call   800180 <printnum_nopad>
	}
	*num_len += 1 ;
  80020b:	83 07 01             	addl   $0x1,(%edi)
	putch("0123456789abcdef"[num % base], putdat);
  80020e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800211:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800215:	8b 04 24             	mov    (%esp),%eax
  800218:	8b 54 24 04          	mov    0x4(%esp),%edx
  80021c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80021f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800222:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800225:	89 54 24 08          	mov    %edx,0x8(%esp)
  800229:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800230:	00 
  800231:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800234:	89 0c 24             	mov    %ecx,(%esp)
  800237:	89 74 24 04          	mov    %esi,0x4(%esp)
  80023b:	e8 b0 0e 00 00       	call   8010f0 <__umoddi3>
  800240:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800243:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800247:	0f be 80 40 12 80 00 	movsbl 0x801240(%eax),%eax
  80024e:	89 04 24             	mov    %eax,(%esp)
  800251:	ff 55 d4             	call   *-0x2c(%ebp)
}
  800254:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800257:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80025a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80025d:	89 ec                	mov    %ebp,%esp
  80025f:	5d                   	pop    %ebp
  800260:	c3                   	ret    

00800261 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800261:	55                   	push   %ebp
  800262:	89 e5                	mov    %esp,%ebp
  800264:	57                   	push   %edi
  800265:	56                   	push   %esi
  800266:	53                   	push   %ebx
  800267:	83 ec 5c             	sub    $0x5c,%esp
  80026a:	89 c7                	mov    %eax,%edi
  80026c:	89 d6                	mov    %edx,%esi
  80026e:	8b 45 08             	mov    0x8(%ebp),%eax
  800271:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800274:	8b 55 0c             	mov    0xc(%ebp),%edx
  800277:	89 55 cc             	mov    %edx,-0x34(%ebp)
  80027a:	8b 45 10             	mov    0x10(%ebp),%eax
  80027d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	if(padc == '-'){
  800280:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  800284:	75 4c                	jne    8002d2 <printnum+0x71>
		int num_len = 0;
  800286:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		printnum_nopad(putch, putdat, num, base, &num_len);
  80028d:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800290:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800294:	89 44 24 08          	mov    %eax,0x8(%esp)
  800298:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80029b:	89 0c 24             	mov    %ecx,(%esp)
  80029e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8002a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002a5:	89 f2                	mov    %esi,%edx
  8002a7:	89 f8                	mov    %edi,%eax
  8002a9:	e8 d2 fe ff ff       	call   800180 <printnum_nopad>
		width -= num_len;
  8002ae:	2b 5d e4             	sub    -0x1c(%ebp),%ebx
		while (width-- > 0)
  8002b1:	85 db                	test   %ebx,%ebx
  8002b3:	0f 8e e8 00 00 00    	jle    8003a1 <printnum+0x140>
			putch(' ', putdat);
  8002b9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002bd:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8002c4:	ff d7                	call   *%edi
  8002c6:	83 eb 01             	sub    $0x1,%ebx
	// your code here:
	if(padc == '-'){
		int num_len = 0;
		printnum_nopad(putch, putdat, num, base, &num_len);
		width -= num_len;
		while (width-- > 0)
  8002c9:	85 db                	test   %ebx,%ebx
  8002cb:	7f ec                	jg     8002b9 <printnum+0x58>
  8002cd:	e9 cf 00 00 00       	jmp    8003a1 <printnum+0x140>
			putch(' ', putdat);
	}
	else{
		// first recursively print all preceding (more significant) digits
		if (num >= base) {
  8002d2:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8002d5:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8002d9:	77 19                	ja     8002f4 <printnum+0x93>
  8002db:	90                   	nop
  8002dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8002e0:	72 05                	jb     8002e7 <printnum+0x86>
  8002e2:	39 45 c8             	cmp    %eax,-0x38(%ebp)
  8002e5:	73 0d                	jae    8002f4 <printnum+0x93>
			printnum(putch, putdat, num / base, base, width - 1, padc);
		} else {
			// print any needed pad characters before first digit
			while (--width > 0)
  8002e7:	83 eb 01             	sub    $0x1,%ebx
  8002ea:	85 db                	test   %ebx,%ebx
  8002ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8002f0:	7f 63                	jg     800355 <printnum+0xf4>
  8002f2:	eb 74                	jmp    800368 <printnum+0x107>
			putch(' ', putdat);
	}
	else{
		// first recursively print all preceding (more significant) digits
		if (num >= base) {
			printnum(putch, putdat, num / base, base, width - 1, padc);
  8002f4:	8b 55 18             	mov    0x18(%ebp),%edx
  8002f7:	89 54 24 10          	mov    %edx,0x10(%esp)
  8002fb:	83 eb 01             	sub    $0x1,%ebx
  8002fe:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800302:	89 44 24 08          	mov    %eax,0x8(%esp)
  800306:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  80030a:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80030e:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800311:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800314:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  800317:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80031b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800322:	00 
  800323:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800326:	89 04 24             	mov    %eax,(%esp)
  800329:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80032c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800330:	e8 8b 0c 00 00       	call   800fc0 <__udivdi3>
  800335:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800338:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80033b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80033f:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800343:	89 04 24             	mov    %eax,(%esp)
  800346:	89 54 24 04          	mov    %edx,0x4(%esp)
  80034a:	89 f2                	mov    %esi,%edx
  80034c:	89 f8                	mov    %edi,%eax
  80034e:	e8 0e ff ff ff       	call   800261 <printnum>
  800353:	eb 13                	jmp    800368 <printnum+0x107>
		} else {
			// print any needed pad characters before first digit
			while (--width > 0)
				putch(padc, putdat);
  800355:	89 74 24 04          	mov    %esi,0x4(%esp)
  800359:	8b 45 18             	mov    0x18(%ebp),%eax
  80035c:	89 04 24             	mov    %eax,(%esp)
  80035f:	ff d7                	call   *%edi
		// first recursively print all preceding (more significant) digits
		if (num >= base) {
			printnum(putch, putdat, num / base, base, width - 1, padc);
		} else {
			// print any needed pad characters before first digit
			while (--width > 0)
  800361:	83 eb 01             	sub    $0x1,%ebx
  800364:	85 db                	test   %ebx,%ebx
  800366:	7f ed                	jg     800355 <printnum+0xf4>
				putch(padc, putdat);
		}

		// then print this (the least significant) digit
		putch("0123456789abcdef"[num % base], putdat);
  800368:	89 74 24 04          	mov    %esi,0x4(%esp)
  80036c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800370:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800373:	89 54 24 08          	mov    %edx,0x8(%esp)
  800377:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80037e:	00 
  80037f:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800382:	89 0c 24             	mov    %ecx,(%esp)
  800385:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800388:	89 44 24 04          	mov    %eax,0x4(%esp)
  80038c:	e8 5f 0d 00 00       	call   8010f0 <__umoddi3>
  800391:	89 74 24 04          	mov    %esi,0x4(%esp)
  800395:	0f be 80 40 12 80 00 	movsbl 0x801240(%eax),%eax
  80039c:	89 04 24             	mov    %eax,(%esp)
  80039f:	ff d7                	call   *%edi
	}
	
}
  8003a1:	83 c4 5c             	add    $0x5c,%esp
  8003a4:	5b                   	pop    %ebx
  8003a5:	5e                   	pop    %esi
  8003a6:	5f                   	pop    %edi
  8003a7:	5d                   	pop    %ebp
  8003a8:	c3                   	ret    

008003a9 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003a9:	55                   	push   %ebp
  8003aa:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003ac:	83 fa 01             	cmp    $0x1,%edx
  8003af:	7e 0e                	jle    8003bf <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003b1:	8b 10                	mov    (%eax),%edx
  8003b3:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003b6:	89 08                	mov    %ecx,(%eax)
  8003b8:	8b 02                	mov    (%edx),%eax
  8003ba:	8b 52 04             	mov    0x4(%edx),%edx
  8003bd:	eb 22                	jmp    8003e1 <getuint+0x38>
	else if (lflag)
  8003bf:	85 d2                	test   %edx,%edx
  8003c1:	74 10                	je     8003d3 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003c3:	8b 10                	mov    (%eax),%edx
  8003c5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003c8:	89 08                	mov    %ecx,(%eax)
  8003ca:	8b 02                	mov    (%edx),%eax
  8003cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8003d1:	eb 0e                	jmp    8003e1 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003d3:	8b 10                	mov    (%eax),%edx
  8003d5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003d8:	89 08                	mov    %ecx,(%eax)
  8003da:	8b 02                	mov    (%edx),%eax
  8003dc:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003e1:	5d                   	pop    %ebp
  8003e2:	c3                   	ret    

008003e3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003e3:	55                   	push   %ebp
  8003e4:	89 e5                	mov    %esp,%ebp
  8003e6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003e9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003ed:	8b 10                	mov    (%eax),%edx
  8003ef:	3b 50 04             	cmp    0x4(%eax),%edx
  8003f2:	73 0a                	jae    8003fe <sprintputch+0x1b>
		*b->buf++ = ch;
  8003f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003f7:	88 0a                	mov    %cl,(%edx)
  8003f9:	83 c2 01             	add    $0x1,%edx
  8003fc:	89 10                	mov    %edx,(%eax)
}
  8003fe:	5d                   	pop    %ebp
  8003ff:	c3                   	ret    

00800400 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800400:	55                   	push   %ebp
  800401:	89 e5                	mov    %esp,%ebp
  800403:	57                   	push   %edi
  800404:	56                   	push   %esi
  800405:	53                   	push   %ebx
  800406:	83 ec 5c             	sub    $0x5c,%esp
  800409:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80040c:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80040f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800416:	eb 12                	jmp    80042a <vprintfmt+0x2a>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800418:	85 c0                	test   %eax,%eax
  80041a:	0f 84 c6 04 00 00    	je     8008e6 <vprintfmt+0x4e6>
				return;
			putch(ch, putdat);
  800420:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800424:	89 04 24             	mov    %eax,(%esp)
  800427:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80042a:	0f b6 03             	movzbl (%ebx),%eax
  80042d:	83 c3 01             	add    $0x1,%ebx
  800430:	83 f8 25             	cmp    $0x25,%eax
  800433:	75 e3                	jne    800418 <vprintfmt+0x18>
  800435:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  800439:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800440:	be ff ff ff ff       	mov    $0xffffffff,%esi
  800445:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  80044c:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800453:	eb 06                	jmp    80045b <vprintfmt+0x5b>
  800455:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  800459:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045b:	0f b6 0b             	movzbl (%ebx),%ecx
  80045e:	0f b6 d1             	movzbl %cl,%edx
  800461:	8d 43 01             	lea    0x1(%ebx),%eax
  800464:	83 e9 23             	sub    $0x23,%ecx
  800467:	80 f9 55             	cmp    $0x55,%cl
  80046a:	0f 87 58 04 00 00    	ja     8008c8 <vprintfmt+0x4c8>
  800470:	0f b6 c9             	movzbl %cl,%ecx
  800473:	ff 24 8d 4c 13 80 00 	jmp    *0x80134c(,%ecx,4)
  80047a:	c6 45 e0 2b          	movb   $0x2b,-0x20(%ebp)
  80047e:	eb d9                	jmp    800459 <vprintfmt+0x59>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800480:	8d 72 d0             	lea    -0x30(%edx),%esi
				ch = *fmt;
  800483:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800486:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800489:	83 f9 09             	cmp    $0x9,%ecx
  80048c:	76 08                	jbe    800496 <vprintfmt+0x96>
  80048e:	eb 40                	jmp    8004d0 <vprintfmt+0xd0>
  800490:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
			goto reswitch;
  800494:	eb c3                	jmp    800459 <vprintfmt+0x59>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800496:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  800499:	8d 0c b6             	lea    (%esi,%esi,4),%ecx
  80049c:	8d 74 4a d0          	lea    -0x30(%edx,%ecx,2),%esi
				ch = *fmt;
  8004a0:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8004a3:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8004a6:	83 f9 09             	cmp    $0x9,%ecx
  8004a9:	76 eb                	jbe    800496 <vprintfmt+0x96>
  8004ab:	eb 23                	jmp    8004d0 <vprintfmt+0xd0>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004ad:	8b 55 14             	mov    0x14(%ebp),%edx
  8004b0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004b3:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004b6:	8b 32                	mov    (%edx),%esi
			goto process_precision;
  8004b8:	eb 16                	jmp    8004d0 <vprintfmt+0xd0>

		case '.':
			if (width < 0)
  8004ba:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8004bd:	c1 fa 1f             	sar    $0x1f,%edx
  8004c0:	f7 d2                	not    %edx
  8004c2:	21 55 dc             	and    %edx,-0x24(%ebp)
  8004c5:	eb 92                	jmp    800459 <vprintfmt+0x59>
  8004c7:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8004ce:	eb 89                	jmp    800459 <vprintfmt+0x59>

		process_precision:
			if (width < 0)
  8004d0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004d4:	79 83                	jns    800459 <vprintfmt+0x59>
  8004d6:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8004d9:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8004dc:	e9 78 ff ff ff       	jmp    800459 <vprintfmt+0x59>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004e1:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
			goto reswitch;
  8004e5:	e9 6f ff ff ff       	jmp    800459 <vprintfmt+0x59>
  8004ea:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f0:	8d 50 04             	lea    0x4(%eax),%edx
  8004f3:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004fa:	8b 00                	mov    (%eax),%eax
  8004fc:	89 04 24             	mov    %eax,(%esp)
  8004ff:	ff 55 08             	call   *0x8(%ebp)
  800502:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  800505:	e9 20 ff ff ff       	jmp    80042a <vprintfmt+0x2a>
  80050a:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80050d:	8b 45 14             	mov    0x14(%ebp),%eax
  800510:	8d 50 04             	lea    0x4(%eax),%edx
  800513:	89 55 14             	mov    %edx,0x14(%ebp)
  800516:	8b 00                	mov    (%eax),%eax
  800518:	89 c2                	mov    %eax,%edx
  80051a:	c1 fa 1f             	sar    $0x1f,%edx
  80051d:	31 d0                	xor    %edx,%eax
  80051f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800521:	83 f8 06             	cmp    $0x6,%eax
  800524:	7f 0b                	jg     800531 <vprintfmt+0x131>
  800526:	8b 14 85 a4 14 80 00 	mov    0x8014a4(,%eax,4),%edx
  80052d:	85 d2                	test   %edx,%edx
  80052f:	75 23                	jne    800554 <vprintfmt+0x154>
				printfmt(putch, putdat, "error %d", err);
  800531:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800535:	c7 44 24 08 51 12 80 	movl   $0x801251,0x8(%esp)
  80053c:	00 
  80053d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800541:	8b 45 08             	mov    0x8(%ebp),%eax
  800544:	89 04 24             	mov    %eax,(%esp)
  800547:	e8 22 04 00 00       	call   80096e <printfmt>
  80054c:	8b 5d cc             	mov    -0x34(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80054f:	e9 d6 fe ff ff       	jmp    80042a <vprintfmt+0x2a>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800554:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800558:	c7 44 24 08 5a 12 80 	movl   $0x80125a,0x8(%esp)
  80055f:	00 
  800560:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800564:	8b 55 08             	mov    0x8(%ebp),%edx
  800567:	89 14 24             	mov    %edx,(%esp)
  80056a:	e8 ff 03 00 00       	call   80096e <printfmt>
  80056f:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800572:	e9 b3 fe ff ff       	jmp    80042a <vprintfmt+0x2a>
  800577:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80057a:	89 c3                	mov    %eax,%ebx
  80057c:	89 f1                	mov    %esi,%ecx
  80057e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800581:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800584:	8b 45 14             	mov    0x14(%ebp),%eax
  800587:	8d 50 04             	lea    0x4(%eax),%edx
  80058a:	89 55 14             	mov    %edx,0x14(%ebp)
  80058d:	8b 00                	mov    (%eax),%eax
  80058f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800592:	85 c0                	test   %eax,%eax
  800594:	75 07                	jne    80059d <vprintfmt+0x19d>
  800596:	c7 45 d0 5d 12 80 00 	movl   $0x80125d,-0x30(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  80059d:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8005a1:	7e 06                	jle    8005a9 <vprintfmt+0x1a9>
  8005a3:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  8005a7:	75 13                	jne    8005bc <vprintfmt+0x1bc>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005a9:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005ac:	0f be 02             	movsbl (%edx),%eax
  8005af:	85 c0                	test   %eax,%eax
  8005b1:	0f 85 a2 00 00 00    	jne    800659 <vprintfmt+0x259>
  8005b7:	e9 8f 00 00 00       	jmp    80064b <vprintfmt+0x24b>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005bc:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005c0:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8005c3:	89 0c 24             	mov    %ecx,(%esp)
  8005c6:	e8 f0 03 00 00       	call   8009bb <strnlen>
  8005cb:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8005ce:	29 c2                	sub    %eax,%edx
  8005d0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005d3:	85 d2                	test   %edx,%edx
  8005d5:	7e d2                	jle    8005a9 <vprintfmt+0x1a9>
					putch(padc, putdat);
  8005d7:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  8005db:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  8005de:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  8005e1:	89 d3                	mov    %edx,%ebx
  8005e3:	89 ce                	mov    %ecx,%esi
  8005e5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005e9:	89 34 24             	mov    %esi,(%esp)
  8005ec:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005ef:	83 eb 01             	sub    $0x1,%ebx
  8005f2:	85 db                	test   %ebx,%ebx
  8005f4:	7f ef                	jg     8005e5 <vprintfmt+0x1e5>
  8005f6:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  8005f9:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  8005fc:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800603:	eb a4                	jmp    8005a9 <vprintfmt+0x1a9>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800605:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800609:	74 1b                	je     800626 <vprintfmt+0x226>
  80060b:	8d 50 e0             	lea    -0x20(%eax),%edx
  80060e:	83 fa 5e             	cmp    $0x5e,%edx
  800611:	76 13                	jbe    800626 <vprintfmt+0x226>
					putch('?', putdat);
  800613:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800616:	89 44 24 04          	mov    %eax,0x4(%esp)
  80061a:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800621:	ff 55 08             	call   *0x8(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800624:	eb 0d                	jmp    800633 <vprintfmt+0x233>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800626:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800629:	89 54 24 04          	mov    %edx,0x4(%esp)
  80062d:	89 04 24             	mov    %eax,(%esp)
  800630:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800633:	83 ef 01             	sub    $0x1,%edi
  800636:	0f be 03             	movsbl (%ebx),%eax
  800639:	85 c0                	test   %eax,%eax
  80063b:	74 05                	je     800642 <vprintfmt+0x242>
  80063d:	83 c3 01             	add    $0x1,%ebx
  800640:	eb 28                	jmp    80066a <vprintfmt+0x26a>
  800642:	89 7d dc             	mov    %edi,-0x24(%ebp)
  800645:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800648:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80064b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80064f:	7f 2d                	jg     80067e <vprintfmt+0x27e>
  800651:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800654:	e9 d1 fd ff ff       	jmp    80042a <vprintfmt+0x2a>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800659:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80065c:	83 c1 01             	add    $0x1,%ecx
  80065f:	89 7d e0             	mov    %edi,-0x20(%ebp)
  800662:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800665:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  800668:	89 cb                	mov    %ecx,%ebx
  80066a:	85 f6                	test   %esi,%esi
  80066c:	78 97                	js     800605 <vprintfmt+0x205>
  80066e:	83 ee 01             	sub    $0x1,%esi
  800671:	79 92                	jns    800605 <vprintfmt+0x205>
  800673:	89 7d dc             	mov    %edi,-0x24(%ebp)
  800676:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800679:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  80067c:	eb cd                	jmp    80064b <vprintfmt+0x24b>
  80067e:	8b 75 08             	mov    0x8(%ebp),%esi
  800681:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800684:	8b 5d dc             	mov    -0x24(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800687:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80068b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800692:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800694:	83 eb 01             	sub    $0x1,%ebx
  800697:	85 db                	test   %ebx,%ebx
  800699:	7f ec                	jg     800687 <vprintfmt+0x287>
  80069b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80069e:	e9 87 fd ff ff       	jmp    80042a <vprintfmt+0x2a>
  8006a3:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8006a6:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
  8006aa:	88 45 e4             	mov    %al,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006ad:	83 7d d0 01          	cmpl   $0x1,-0x30(%ebp)
  8006b1:	7e 16                	jle    8006c9 <vprintfmt+0x2c9>
		return va_arg(*ap, long long);
  8006b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b6:	8d 50 08             	lea    0x8(%eax),%edx
  8006b9:	89 55 14             	mov    %edx,0x14(%ebp)
  8006bc:	8b 10                	mov    (%eax),%edx
  8006be:	8b 48 04             	mov    0x4(%eax),%ecx
  8006c1:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8006c4:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8006c7:	eb 34                	jmp    8006fd <vprintfmt+0x2fd>
	else if (lflag)
  8006c9:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8006cd:	74 18                	je     8006e7 <vprintfmt+0x2e7>
		return va_arg(*ap, long);
  8006cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d2:	8d 50 04             	lea    0x4(%eax),%edx
  8006d5:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d8:	8b 00                	mov    (%eax),%eax
  8006da:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006dd:	89 c1                	mov    %eax,%ecx
  8006df:	c1 f9 1f             	sar    $0x1f,%ecx
  8006e2:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8006e5:	eb 16                	jmp    8006fd <vprintfmt+0x2fd>
	else
		return va_arg(*ap, int);
  8006e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ea:	8d 50 04             	lea    0x4(%eax),%edx
  8006ed:	89 55 14             	mov    %edx,0x14(%ebp)
  8006f0:	8b 00                	mov    (%eax),%eax
  8006f2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006f5:	89 c2                	mov    %eax,%edx
  8006f7:	c1 fa 1f             	sar    $0x1f,%edx
  8006fa:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006fd:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800700:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if ((long long) num < 0) {
  800703:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800707:	79 2c                	jns    800735 <vprintfmt+0x335>
				putch('-', putdat);
  800709:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80070d:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800714:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800717:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80071a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80071d:	f7 db                	neg    %ebx
  80071f:	83 d6 00             	adc    $0x0,%esi
  800722:	f7 de                	neg    %esi
  800724:	0f b6 4d e0          	movzbl -0x20(%ebp),%ecx
  800728:	88 4d e4             	mov    %cl,-0x1c(%ebp)
  80072b:	ba 0a 00 00 00       	mov    $0xa,%edx
  800730:	e9 db 00 00 00       	jmp    800810 <vprintfmt+0x410>
			}
			else if (padc == '+'){
  800735:	80 7d e4 2b          	cmpb   $0x2b,-0x1c(%ebp)
  800739:	74 11                	je     80074c <vprintfmt+0x34c>
  80073b:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
  80073f:	88 45 e4             	mov    %al,-0x1c(%ebp)
  800742:	ba 0a 00 00 00       	mov    $0xa,%edx
  800747:	e9 c4 00 00 00       	jmp    800810 <vprintfmt+0x410>
				putch('+', putdat);
  80074c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800750:	c7 04 24 2b 00 00 00 	movl   $0x2b,(%esp)
  800757:	ff 55 08             	call   *0x8(%ebp)
  80075a:	ba 0a 00 00 00       	mov    $0xa,%edx
  80075f:	e9 ac 00 00 00       	jmp    800810 <vprintfmt+0x410>
  800764:	89 45 cc             	mov    %eax,-0x34(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800767:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80076a:	8d 45 14             	lea    0x14(%ebp),%eax
  80076d:	e8 37 fc ff ff       	call   8003a9 <getuint>
  800772:	89 c3                	mov    %eax,%ebx
  800774:	89 d6                	mov    %edx,%esi
  800776:	0f b6 55 e0          	movzbl -0x20(%ebp),%edx
  80077a:	88 55 e4             	mov    %dl,-0x1c(%ebp)
  80077d:	ba 0a 00 00 00       	mov    $0xa,%edx
			base = 10;
			goto number;
  800782:	e9 89 00 00 00       	jmp    800810 <vprintfmt+0x410>
  800787:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) octal
		case 'o':
			putch('0', putdat);
  80078a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80078e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800795:	ff 55 08             	call   *0x8(%ebp)
			num = getuint(&ap, lflag);
  800798:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80079b:	8d 45 14             	lea    0x14(%ebp),%eax
  80079e:	e8 06 fc ff ff       	call   8003a9 <getuint>
  8007a3:	89 c3                	mov    %eax,%ebx
  8007a5:	89 d6                	mov    %edx,%esi
  8007a7:	0f b6 4d e0          	movzbl -0x20(%ebp),%ecx
  8007ab:	88 4d e4             	mov    %cl,-0x1c(%ebp)
  8007ae:	ba 08 00 00 00       	mov    $0x8,%edx
			base = 8;
			goto number;
  8007b3:	eb 5b                	jmp    800810 <vprintfmt+0x410>
  8007b5:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  8007b8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007bc:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007c3:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007c6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007ca:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007d1:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  8007d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d7:	8d 50 04             	lea    0x4(%eax),%edx
  8007da:	89 55 14             	mov    %edx,0x14(%ebp)
  8007dd:	8b 18                	mov    (%eax),%ebx
  8007df:	be 00 00 00 00       	mov    $0x0,%esi
  8007e4:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
  8007e8:	88 45 e4             	mov    %al,-0x1c(%ebp)
  8007eb:	ba 10 00 00 00       	mov    $0x10,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007f0:	eb 1e                	jmp    800810 <vprintfmt+0x410>
  8007f2:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007f5:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8007f8:	8d 45 14             	lea    0x14(%ebp),%eax
  8007fb:	e8 a9 fb ff ff       	call   8003a9 <getuint>
  800800:	89 c3                	mov    %eax,%ebx
  800802:	89 d6                	mov    %edx,%esi
  800804:	0f b6 55 e0          	movzbl -0x20(%ebp),%edx
  800808:	88 55 e4             	mov    %dl,-0x1c(%ebp)
  80080b:	ba 10 00 00 00       	mov    $0x10,%edx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800810:	0f be 45 e4          	movsbl -0x1c(%ebp),%eax
  800814:	89 44 24 10          	mov    %eax,0x10(%esp)
  800818:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80081b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80081f:	89 54 24 08          	mov    %edx,0x8(%esp)
  800823:	89 1c 24             	mov    %ebx,(%esp)
  800826:	89 74 24 04          	mov    %esi,0x4(%esp)
  80082a:	89 fa                	mov    %edi,%edx
  80082c:	8b 45 08             	mov    0x8(%ebp),%eax
  80082f:	e8 2d fa ff ff       	call   800261 <printnum>
  800834:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  800837:	e9 ee fb ff ff       	jmp    80042a <vprintfmt+0x2a>
  80083c:	89 45 cc             	mov    %eax,-0x34(%ebp)
            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
	    	uint32_t *num_now = putdat;
	    	char *ret_va = va_arg(ap, char *);
  80083f:	8b 45 14             	mov    0x14(%ebp),%eax
  800842:	8d 50 04             	lea    0x4(%eax),%edx
  800845:	89 55 14             	mov    %edx,0x14(%ebp)
  800848:	8b 00                	mov    (%eax),%eax
	    	if(ret_va == NULL){
  80084a:	85 c0                	test   %eax,%eax
  80084c:	75 27                	jne    800875 <vprintfmt+0x475>
				printfmt(putch, putdat, "%s", null_error);
  80084e:	c7 44 24 0c d0 12 80 	movl   $0x8012d0,0xc(%esp)
  800855:	00 
  800856:	c7 44 24 08 5a 12 80 	movl   $0x80125a,0x8(%esp)
  80085d:	00 
  80085e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800862:	8b 45 08             	mov    0x8(%ebp),%eax
  800865:	89 04 24             	mov    %eax,(%esp)
  800868:	e8 01 01 00 00       	call   80096e <printfmt>
  80086d:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800870:	e9 b5 fb ff ff       	jmp    80042a <vprintfmt+0x2a>
	    	}
	    	else if ((*num_now) >> 7 != 0 ){		//how to aurrately discribe overflow?
  800875:	8b 17                	mov    (%edi),%edx
  800877:	89 d1                	mov    %edx,%ecx
  800879:	c1 e9 07             	shr    $0x7,%ecx
  80087c:	85 c9                	test   %ecx,%ecx
  80087e:	74 29                	je     8008a9 <vprintfmt+0x4a9>
				*ret_va = *(num_now);	//get putdat at first as next print instruction will change ret_va as it's a pointer which means it's dynamic;
  800880:	88 10                	mov    %dl,(%eax)
				printfmt(putch, putdat, "%s", overflow_error);
  800882:	c7 44 24 0c 08 13 80 	movl   $0x801308,0xc(%esp)
  800889:	00 
  80088a:	c7 44 24 08 5a 12 80 	movl   $0x80125a,0x8(%esp)
  800891:	00 
  800892:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800896:	8b 55 08             	mov    0x8(%ebp),%edx
  800899:	89 14 24             	mov    %edx,(%esp)
  80089c:	e8 cd 00 00 00       	call   80096e <printfmt>
  8008a1:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  8008a4:	e9 81 fb ff ff       	jmp    80042a <vprintfmt+0x2a>
	    	}
	    	else{
				*ret_va = *(num_now);
  8008a9:	88 10                	mov    %dl,(%eax)
  8008ab:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  8008ae:	e9 77 fb ff ff       	jmp    80042a <vprintfmt+0x2a>
  8008b3:	89 45 cc             	mov    %eax,-0x34(%ebp)
            	break;
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008b6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008ba:	89 14 24             	mov    %edx,(%esp)
  8008bd:	ff 55 08             	call   *0x8(%ebp)
  8008c0:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  8008c3:	e9 62 fb ff ff       	jmp    80042a <vprintfmt+0x2a>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008c8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008cc:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8008d3:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008d6:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8008d9:	80 38 25             	cmpb   $0x25,(%eax)
  8008dc:	0f 84 48 fb ff ff    	je     80042a <vprintfmt+0x2a>
  8008e2:	89 c3                	mov    %eax,%ebx
  8008e4:	eb f0                	jmp    8008d6 <vprintfmt+0x4d6>
				/* do nothing */;
			break;
		}
	}
}
  8008e6:	83 c4 5c             	add    $0x5c,%esp
  8008e9:	5b                   	pop    %ebx
  8008ea:	5e                   	pop    %esi
  8008eb:	5f                   	pop    %edi
  8008ec:	5d                   	pop    %ebp
  8008ed:	c3                   	ret    

008008ee <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008ee:	55                   	push   %ebp
  8008ef:	89 e5                	mov    %esp,%ebp
  8008f1:	83 ec 28             	sub    $0x28,%esp
  8008f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  8008fa:	85 c0                	test   %eax,%eax
  8008fc:	74 04                	je     800902 <vsnprintf+0x14>
  8008fe:	85 d2                	test   %edx,%edx
  800900:	7f 07                	jg     800909 <vsnprintf+0x1b>
  800902:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800907:	eb 3b                	jmp    800944 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800909:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80090c:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800910:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800913:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80091a:	8b 45 14             	mov    0x14(%ebp),%eax
  80091d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800921:	8b 45 10             	mov    0x10(%ebp),%eax
  800924:	89 44 24 08          	mov    %eax,0x8(%esp)
  800928:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80092b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80092f:	c7 04 24 e3 03 80 00 	movl   $0x8003e3,(%esp)
  800936:	e8 c5 fa ff ff       	call   800400 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80093b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80093e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800941:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800944:	c9                   	leave  
  800945:	c3                   	ret    

00800946 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800946:	55                   	push   %ebp
  800947:	89 e5                	mov    %esp,%ebp
  800949:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  80094c:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  80094f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800953:	8b 45 10             	mov    0x10(%ebp),%eax
  800956:	89 44 24 08          	mov    %eax,0x8(%esp)
  80095a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80095d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800961:	8b 45 08             	mov    0x8(%ebp),%eax
  800964:	89 04 24             	mov    %eax,(%esp)
  800967:	e8 82 ff ff ff       	call   8008ee <vsnprintf>
	va_end(ap);

	return rc;
}
  80096c:	c9                   	leave  
  80096d:	c3                   	ret    

0080096e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80096e:	55                   	push   %ebp
  80096f:	89 e5                	mov    %esp,%ebp
  800971:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800974:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800977:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80097b:	8b 45 10             	mov    0x10(%ebp),%eax
  80097e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800982:	8b 45 0c             	mov    0xc(%ebp),%eax
  800985:	89 44 24 04          	mov    %eax,0x4(%esp)
  800989:	8b 45 08             	mov    0x8(%ebp),%eax
  80098c:	89 04 24             	mov    %eax,(%esp)
  80098f:	e8 6c fa ff ff       	call   800400 <vprintfmt>
	va_end(ap);
}
  800994:	c9                   	leave  
  800995:	c3                   	ret    
	...

008009a0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009a0:	55                   	push   %ebp
  8009a1:	89 e5                	mov    %esp,%ebp
  8009a3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ab:	80 3a 00             	cmpb   $0x0,(%edx)
  8009ae:	74 09                	je     8009b9 <strlen+0x19>
		n++;
  8009b0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009b3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009b7:	75 f7                	jne    8009b0 <strlen+0x10>
		n++;
	return n;
}
  8009b9:	5d                   	pop    %ebp
  8009ba:	c3                   	ret    

008009bb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009bb:	55                   	push   %ebp
  8009bc:	89 e5                	mov    %esp,%ebp
  8009be:	53                   	push   %ebx
  8009bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009c5:	85 c9                	test   %ecx,%ecx
  8009c7:	74 19                	je     8009e2 <strnlen+0x27>
  8009c9:	80 3b 00             	cmpb   $0x0,(%ebx)
  8009cc:	74 14                	je     8009e2 <strnlen+0x27>
  8009ce:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8009d3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009d6:	39 c8                	cmp    %ecx,%eax
  8009d8:	74 0d                	je     8009e7 <strnlen+0x2c>
  8009da:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  8009de:	75 f3                	jne    8009d3 <strnlen+0x18>
  8009e0:	eb 05                	jmp    8009e7 <strnlen+0x2c>
  8009e2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8009e7:	5b                   	pop    %ebx
  8009e8:	5d                   	pop    %ebp
  8009e9:	c3                   	ret    

008009ea <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009ea:	55                   	push   %ebp
  8009eb:	89 e5                	mov    %esp,%ebp
  8009ed:	53                   	push   %ebx
  8009ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009f4:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009f9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8009fd:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a00:	83 c2 01             	add    $0x1,%edx
  800a03:	84 c9                	test   %cl,%cl
  800a05:	75 f2                	jne    8009f9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800a07:	5b                   	pop    %ebx
  800a08:	5d                   	pop    %ebp
  800a09:	c3                   	ret    

00800a0a <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a0a:	55                   	push   %ebp
  800a0b:	89 e5                	mov    %esp,%ebp
  800a0d:	53                   	push   %ebx
  800a0e:	83 ec 08             	sub    $0x8,%esp
  800a11:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a14:	89 1c 24             	mov    %ebx,(%esp)
  800a17:	e8 84 ff ff ff       	call   8009a0 <strlen>
	strcpy(dst + len, src);
  800a1c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a1f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a23:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800a26:	89 04 24             	mov    %eax,(%esp)
  800a29:	e8 bc ff ff ff       	call   8009ea <strcpy>
	return dst;
}
  800a2e:	89 d8                	mov    %ebx,%eax
  800a30:	83 c4 08             	add    $0x8,%esp
  800a33:	5b                   	pop    %ebx
  800a34:	5d                   	pop    %ebp
  800a35:	c3                   	ret    

00800a36 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a36:	55                   	push   %ebp
  800a37:	89 e5                	mov    %esp,%ebp
  800a39:	56                   	push   %esi
  800a3a:	53                   	push   %ebx
  800a3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a41:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a44:	85 f6                	test   %esi,%esi
  800a46:	74 18                	je     800a60 <strncpy+0x2a>
  800a48:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800a4d:	0f b6 1a             	movzbl (%edx),%ebx
  800a50:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a53:	80 3a 01             	cmpb   $0x1,(%edx)
  800a56:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a59:	83 c1 01             	add    $0x1,%ecx
  800a5c:	39 ce                	cmp    %ecx,%esi
  800a5e:	77 ed                	ja     800a4d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a60:	5b                   	pop    %ebx
  800a61:	5e                   	pop    %esi
  800a62:	5d                   	pop    %ebp
  800a63:	c3                   	ret    

00800a64 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a64:	55                   	push   %ebp
  800a65:	89 e5                	mov    %esp,%ebp
  800a67:	56                   	push   %esi
  800a68:	53                   	push   %ebx
  800a69:	8b 75 08             	mov    0x8(%ebp),%esi
  800a6c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a6f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a72:	89 f0                	mov    %esi,%eax
  800a74:	85 c9                	test   %ecx,%ecx
  800a76:	74 27                	je     800a9f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800a78:	83 e9 01             	sub    $0x1,%ecx
  800a7b:	74 1d                	je     800a9a <strlcpy+0x36>
  800a7d:	0f b6 1a             	movzbl (%edx),%ebx
  800a80:	84 db                	test   %bl,%bl
  800a82:	74 16                	je     800a9a <strlcpy+0x36>
			*dst++ = *src++;
  800a84:	88 18                	mov    %bl,(%eax)
  800a86:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a89:	83 e9 01             	sub    $0x1,%ecx
  800a8c:	74 0e                	je     800a9c <strlcpy+0x38>
			*dst++ = *src++;
  800a8e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a91:	0f b6 1a             	movzbl (%edx),%ebx
  800a94:	84 db                	test   %bl,%bl
  800a96:	75 ec                	jne    800a84 <strlcpy+0x20>
  800a98:	eb 02                	jmp    800a9c <strlcpy+0x38>
  800a9a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a9c:	c6 00 00             	movb   $0x0,(%eax)
  800a9f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800aa1:	5b                   	pop    %ebx
  800aa2:	5e                   	pop    %esi
  800aa3:	5d                   	pop    %ebp
  800aa4:	c3                   	ret    

00800aa5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800aa5:	55                   	push   %ebp
  800aa6:	89 e5                	mov    %esp,%ebp
  800aa8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aab:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800aae:	0f b6 01             	movzbl (%ecx),%eax
  800ab1:	84 c0                	test   %al,%al
  800ab3:	74 15                	je     800aca <strcmp+0x25>
  800ab5:	3a 02                	cmp    (%edx),%al
  800ab7:	75 11                	jne    800aca <strcmp+0x25>
		p++, q++;
  800ab9:	83 c1 01             	add    $0x1,%ecx
  800abc:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800abf:	0f b6 01             	movzbl (%ecx),%eax
  800ac2:	84 c0                	test   %al,%al
  800ac4:	74 04                	je     800aca <strcmp+0x25>
  800ac6:	3a 02                	cmp    (%edx),%al
  800ac8:	74 ef                	je     800ab9 <strcmp+0x14>
  800aca:	0f b6 c0             	movzbl %al,%eax
  800acd:	0f b6 12             	movzbl (%edx),%edx
  800ad0:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ad2:	5d                   	pop    %ebp
  800ad3:	c3                   	ret    

00800ad4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ad4:	55                   	push   %ebp
  800ad5:	89 e5                	mov    %esp,%ebp
  800ad7:	53                   	push   %ebx
  800ad8:	8b 55 08             	mov    0x8(%ebp),%edx
  800adb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ade:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800ae1:	85 c0                	test   %eax,%eax
  800ae3:	74 23                	je     800b08 <strncmp+0x34>
  800ae5:	0f b6 1a             	movzbl (%edx),%ebx
  800ae8:	84 db                	test   %bl,%bl
  800aea:	74 25                	je     800b11 <strncmp+0x3d>
  800aec:	3a 19                	cmp    (%ecx),%bl
  800aee:	75 21                	jne    800b11 <strncmp+0x3d>
  800af0:	83 e8 01             	sub    $0x1,%eax
  800af3:	74 13                	je     800b08 <strncmp+0x34>
		n--, p++, q++;
  800af5:	83 c2 01             	add    $0x1,%edx
  800af8:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800afb:	0f b6 1a             	movzbl (%edx),%ebx
  800afe:	84 db                	test   %bl,%bl
  800b00:	74 0f                	je     800b11 <strncmp+0x3d>
  800b02:	3a 19                	cmp    (%ecx),%bl
  800b04:	74 ea                	je     800af0 <strncmp+0x1c>
  800b06:	eb 09                	jmp    800b11 <strncmp+0x3d>
  800b08:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b0d:	5b                   	pop    %ebx
  800b0e:	5d                   	pop    %ebp
  800b0f:	90                   	nop
  800b10:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b11:	0f b6 02             	movzbl (%edx),%eax
  800b14:	0f b6 11             	movzbl (%ecx),%edx
  800b17:	29 d0                	sub    %edx,%eax
  800b19:	eb f2                	jmp    800b0d <strncmp+0x39>

00800b1b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b1b:	55                   	push   %ebp
  800b1c:	89 e5                	mov    %esp,%ebp
  800b1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b21:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b25:	0f b6 10             	movzbl (%eax),%edx
  800b28:	84 d2                	test   %dl,%dl
  800b2a:	74 18                	je     800b44 <strchr+0x29>
		if (*s == c)
  800b2c:	38 ca                	cmp    %cl,%dl
  800b2e:	75 0a                	jne    800b3a <strchr+0x1f>
  800b30:	eb 17                	jmp    800b49 <strchr+0x2e>
  800b32:	38 ca                	cmp    %cl,%dl
  800b34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800b38:	74 0f                	je     800b49 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b3a:	83 c0 01             	add    $0x1,%eax
  800b3d:	0f b6 10             	movzbl (%eax),%edx
  800b40:	84 d2                	test   %dl,%dl
  800b42:	75 ee                	jne    800b32 <strchr+0x17>
  800b44:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800b49:	5d                   	pop    %ebp
  800b4a:	c3                   	ret    

00800b4b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b4b:	55                   	push   %ebp
  800b4c:	89 e5                	mov    %esp,%ebp
  800b4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b51:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b55:	0f b6 10             	movzbl (%eax),%edx
  800b58:	84 d2                	test   %dl,%dl
  800b5a:	74 18                	je     800b74 <strfind+0x29>
		if (*s == c)
  800b5c:	38 ca                	cmp    %cl,%dl
  800b5e:	75 0a                	jne    800b6a <strfind+0x1f>
  800b60:	eb 12                	jmp    800b74 <strfind+0x29>
  800b62:	38 ca                	cmp    %cl,%dl
  800b64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800b68:	74 0a                	je     800b74 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b6a:	83 c0 01             	add    $0x1,%eax
  800b6d:	0f b6 10             	movzbl (%eax),%edx
  800b70:	84 d2                	test   %dl,%dl
  800b72:	75 ee                	jne    800b62 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800b74:	5d                   	pop    %ebp
  800b75:	c3                   	ret    

00800b76 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b76:	55                   	push   %ebp
  800b77:	89 e5                	mov    %esp,%ebp
  800b79:	83 ec 0c             	sub    $0xc,%esp
  800b7c:	89 1c 24             	mov    %ebx,(%esp)
  800b7f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b83:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800b87:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b8a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b8d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b90:	85 c9                	test   %ecx,%ecx
  800b92:	74 30                	je     800bc4 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b94:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b9a:	75 25                	jne    800bc1 <memset+0x4b>
  800b9c:	f6 c1 03             	test   $0x3,%cl
  800b9f:	75 20                	jne    800bc1 <memset+0x4b>
		c &= 0xFF;
  800ba1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ba4:	89 d3                	mov    %edx,%ebx
  800ba6:	c1 e3 08             	shl    $0x8,%ebx
  800ba9:	89 d6                	mov    %edx,%esi
  800bab:	c1 e6 18             	shl    $0x18,%esi
  800bae:	89 d0                	mov    %edx,%eax
  800bb0:	c1 e0 10             	shl    $0x10,%eax
  800bb3:	09 f0                	or     %esi,%eax
  800bb5:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800bb7:	09 d8                	or     %ebx,%eax
  800bb9:	c1 e9 02             	shr    $0x2,%ecx
  800bbc:	fc                   	cld    
  800bbd:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bbf:	eb 03                	jmp    800bc4 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bc1:	fc                   	cld    
  800bc2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bc4:	89 f8                	mov    %edi,%eax
  800bc6:	8b 1c 24             	mov    (%esp),%ebx
  800bc9:	8b 74 24 04          	mov    0x4(%esp),%esi
  800bcd:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800bd1:	89 ec                	mov    %ebp,%esp
  800bd3:	5d                   	pop    %ebp
  800bd4:	c3                   	ret    

00800bd5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bd5:	55                   	push   %ebp
  800bd6:	89 e5                	mov    %esp,%ebp
  800bd8:	83 ec 08             	sub    $0x8,%esp
  800bdb:	89 34 24             	mov    %esi,(%esp)
  800bde:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800be2:	8b 45 08             	mov    0x8(%ebp),%eax
  800be5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800be8:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800beb:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800bed:	39 c6                	cmp    %eax,%esi
  800bef:	73 35                	jae    800c26 <memmove+0x51>
  800bf1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bf4:	39 d0                	cmp    %edx,%eax
  800bf6:	73 2e                	jae    800c26 <memmove+0x51>
		s += n;
		d += n;
  800bf8:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bfa:	f6 c2 03             	test   $0x3,%dl
  800bfd:	75 1b                	jne    800c1a <memmove+0x45>
  800bff:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c05:	75 13                	jne    800c1a <memmove+0x45>
  800c07:	f6 c1 03             	test   $0x3,%cl
  800c0a:	75 0e                	jne    800c1a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800c0c:	83 ef 04             	sub    $0x4,%edi
  800c0f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c12:	c1 e9 02             	shr    $0x2,%ecx
  800c15:	fd                   	std    
  800c16:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c18:	eb 09                	jmp    800c23 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c1a:	83 ef 01             	sub    $0x1,%edi
  800c1d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800c20:	fd                   	std    
  800c21:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c23:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c24:	eb 20                	jmp    800c46 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c26:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c2c:	75 15                	jne    800c43 <memmove+0x6e>
  800c2e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c34:	75 0d                	jne    800c43 <memmove+0x6e>
  800c36:	f6 c1 03             	test   $0x3,%cl
  800c39:	75 08                	jne    800c43 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800c3b:	c1 e9 02             	shr    $0x2,%ecx
  800c3e:	fc                   	cld    
  800c3f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c41:	eb 03                	jmp    800c46 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c43:	fc                   	cld    
  800c44:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c46:	8b 34 24             	mov    (%esp),%esi
  800c49:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800c4d:	89 ec                	mov    %ebp,%esp
  800c4f:	5d                   	pop    %ebp
  800c50:	c3                   	ret    

00800c51 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800c51:	55                   	push   %ebp
  800c52:	89 e5                	mov    %esp,%ebp
  800c54:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c57:	8b 45 10             	mov    0x10(%ebp),%eax
  800c5a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c5e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c61:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c65:	8b 45 08             	mov    0x8(%ebp),%eax
  800c68:	89 04 24             	mov    %eax,(%esp)
  800c6b:	e8 65 ff ff ff       	call   800bd5 <memmove>
}
  800c70:	c9                   	leave  
  800c71:	c3                   	ret    

00800c72 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c72:	55                   	push   %ebp
  800c73:	89 e5                	mov    %esp,%ebp
  800c75:	57                   	push   %edi
  800c76:	56                   	push   %esi
  800c77:	53                   	push   %ebx
  800c78:	8b 75 08             	mov    0x8(%ebp),%esi
  800c7b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800c7e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c81:	85 c9                	test   %ecx,%ecx
  800c83:	74 36                	je     800cbb <memcmp+0x49>
		if (*s1 != *s2)
  800c85:	0f b6 06             	movzbl (%esi),%eax
  800c88:	0f b6 1f             	movzbl (%edi),%ebx
  800c8b:	38 d8                	cmp    %bl,%al
  800c8d:	74 20                	je     800caf <memcmp+0x3d>
  800c8f:	eb 14                	jmp    800ca5 <memcmp+0x33>
  800c91:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800c96:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800c9b:	83 c2 01             	add    $0x1,%edx
  800c9e:	83 e9 01             	sub    $0x1,%ecx
  800ca1:	38 d8                	cmp    %bl,%al
  800ca3:	74 12                	je     800cb7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800ca5:	0f b6 c0             	movzbl %al,%eax
  800ca8:	0f b6 db             	movzbl %bl,%ebx
  800cab:	29 d8                	sub    %ebx,%eax
  800cad:	eb 11                	jmp    800cc0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800caf:	83 e9 01             	sub    $0x1,%ecx
  800cb2:	ba 00 00 00 00       	mov    $0x0,%edx
  800cb7:	85 c9                	test   %ecx,%ecx
  800cb9:	75 d6                	jne    800c91 <memcmp+0x1f>
  800cbb:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800cc0:	5b                   	pop    %ebx
  800cc1:	5e                   	pop    %esi
  800cc2:	5f                   	pop    %edi
  800cc3:	5d                   	pop    %ebp
  800cc4:	c3                   	ret    

00800cc5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cc5:	55                   	push   %ebp
  800cc6:	89 e5                	mov    %esp,%ebp
  800cc8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ccb:	89 c2                	mov    %eax,%edx
  800ccd:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800cd0:	39 d0                	cmp    %edx,%eax
  800cd2:	73 15                	jae    800ce9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cd4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800cd8:	38 08                	cmp    %cl,(%eax)
  800cda:	75 06                	jne    800ce2 <memfind+0x1d>
  800cdc:	eb 0b                	jmp    800ce9 <memfind+0x24>
  800cde:	38 08                	cmp    %cl,(%eax)
  800ce0:	74 07                	je     800ce9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ce2:	83 c0 01             	add    $0x1,%eax
  800ce5:	39 c2                	cmp    %eax,%edx
  800ce7:	77 f5                	ja     800cde <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ce9:	5d                   	pop    %ebp
  800cea:	c3                   	ret    

00800ceb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ceb:	55                   	push   %ebp
  800cec:	89 e5                	mov    %esp,%ebp
  800cee:	57                   	push   %edi
  800cef:	56                   	push   %esi
  800cf0:	53                   	push   %ebx
  800cf1:	83 ec 04             	sub    $0x4,%esp
  800cf4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cfa:	0f b6 02             	movzbl (%edx),%eax
  800cfd:	3c 20                	cmp    $0x20,%al
  800cff:	74 04                	je     800d05 <strtol+0x1a>
  800d01:	3c 09                	cmp    $0x9,%al
  800d03:	75 0e                	jne    800d13 <strtol+0x28>
		s++;
  800d05:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d08:	0f b6 02             	movzbl (%edx),%eax
  800d0b:	3c 20                	cmp    $0x20,%al
  800d0d:	74 f6                	je     800d05 <strtol+0x1a>
  800d0f:	3c 09                	cmp    $0x9,%al
  800d11:	74 f2                	je     800d05 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d13:	3c 2b                	cmp    $0x2b,%al
  800d15:	75 0c                	jne    800d23 <strtol+0x38>
		s++;
  800d17:	83 c2 01             	add    $0x1,%edx
  800d1a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800d21:	eb 15                	jmp    800d38 <strtol+0x4d>
	else if (*s == '-')
  800d23:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800d2a:	3c 2d                	cmp    $0x2d,%al
  800d2c:	75 0a                	jne    800d38 <strtol+0x4d>
		s++, neg = 1;
  800d2e:	83 c2 01             	add    $0x1,%edx
  800d31:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d38:	85 db                	test   %ebx,%ebx
  800d3a:	0f 94 c0             	sete   %al
  800d3d:	74 05                	je     800d44 <strtol+0x59>
  800d3f:	83 fb 10             	cmp    $0x10,%ebx
  800d42:	75 18                	jne    800d5c <strtol+0x71>
  800d44:	80 3a 30             	cmpb   $0x30,(%edx)
  800d47:	75 13                	jne    800d5c <strtol+0x71>
  800d49:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d4d:	8d 76 00             	lea    0x0(%esi),%esi
  800d50:	75 0a                	jne    800d5c <strtol+0x71>
		s += 2, base = 16;
  800d52:	83 c2 02             	add    $0x2,%edx
  800d55:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d5a:	eb 15                	jmp    800d71 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d5c:	84 c0                	test   %al,%al
  800d5e:	66 90                	xchg   %ax,%ax
  800d60:	74 0f                	je     800d71 <strtol+0x86>
  800d62:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800d67:	80 3a 30             	cmpb   $0x30,(%edx)
  800d6a:	75 05                	jne    800d71 <strtol+0x86>
		s++, base = 8;
  800d6c:	83 c2 01             	add    $0x1,%edx
  800d6f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d71:	b8 00 00 00 00       	mov    $0x0,%eax
  800d76:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d78:	0f b6 0a             	movzbl (%edx),%ecx
  800d7b:	89 cf                	mov    %ecx,%edi
  800d7d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d80:	80 fb 09             	cmp    $0x9,%bl
  800d83:	77 08                	ja     800d8d <strtol+0xa2>
			dig = *s - '0';
  800d85:	0f be c9             	movsbl %cl,%ecx
  800d88:	83 e9 30             	sub    $0x30,%ecx
  800d8b:	eb 1e                	jmp    800dab <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800d8d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800d90:	80 fb 19             	cmp    $0x19,%bl
  800d93:	77 08                	ja     800d9d <strtol+0xb2>
			dig = *s - 'a' + 10;
  800d95:	0f be c9             	movsbl %cl,%ecx
  800d98:	83 e9 57             	sub    $0x57,%ecx
  800d9b:	eb 0e                	jmp    800dab <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800d9d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800da0:	80 fb 19             	cmp    $0x19,%bl
  800da3:	77 15                	ja     800dba <strtol+0xcf>
			dig = *s - 'A' + 10;
  800da5:	0f be c9             	movsbl %cl,%ecx
  800da8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800dab:	39 f1                	cmp    %esi,%ecx
  800dad:	7d 0b                	jge    800dba <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800daf:	83 c2 01             	add    $0x1,%edx
  800db2:	0f af c6             	imul   %esi,%eax
  800db5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800db8:	eb be                	jmp    800d78 <strtol+0x8d>
  800dba:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800dbc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800dc0:	74 05                	je     800dc7 <strtol+0xdc>
		*endptr = (char *) s;
  800dc2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800dc5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800dc7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800dcb:	74 04                	je     800dd1 <strtol+0xe6>
  800dcd:	89 c8                	mov    %ecx,%eax
  800dcf:	f7 d8                	neg    %eax
}
  800dd1:	83 c4 04             	add    $0x4,%esp
  800dd4:	5b                   	pop    %ebx
  800dd5:	5e                   	pop    %esi
  800dd6:	5f                   	pop    %edi
  800dd7:	5d                   	pop    %ebp
  800dd8:	c3                   	ret    
  800dd9:	00 00                	add    %al,(%eax)
	...

00800ddc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ddc:	55                   	push   %ebp
  800ddd:	89 e5                	mov    %esp,%ebp
  800ddf:	83 ec 08             	sub    $0x8,%esp
  800de2:	89 1c 24             	mov    %ebx,(%esp)
  800de5:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800de9:	b8 00 00 00 00       	mov    $0x0,%eax
  800dee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df1:	8b 55 08             	mov    0x8(%ebp),%edx
  800df4:	89 c3                	mov    %eax,%ebx
  800df6:	89 c7                	mov    %eax,%edi
  800df8:	51                   	push   %ecx
  800df9:	52                   	push   %edx
  800dfa:	53                   	push   %ebx
  800dfb:	54                   	push   %esp
  800dfc:	55                   	push   %ebp
  800dfd:	56                   	push   %esi
  800dfe:	57                   	push   %edi
  800dff:	5f                   	pop    %edi
  800e00:	5e                   	pop    %esi
  800e01:	5d                   	pop    %ebp
  800e02:	5c                   	pop    %esp
  800e03:	5b                   	pop    %ebx
  800e04:	5a                   	pop    %edx
  800e05:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800e06:	8b 1c 24             	mov    (%esp),%ebx
  800e09:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e0d:	89 ec                	mov    %ebp,%esp
  800e0f:	5d                   	pop    %ebp
  800e10:	c3                   	ret    

00800e11 <sys_cgetc>:

int
sys_cgetc(void)
{
  800e11:	55                   	push   %ebp
  800e12:	89 e5                	mov    %esp,%ebp
  800e14:	83 ec 08             	sub    $0x8,%esp
  800e17:	89 1c 24             	mov    %ebx,(%esp)
  800e1a:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e1e:	ba 00 00 00 00       	mov    $0x0,%edx
  800e23:	b8 01 00 00 00       	mov    $0x1,%eax
  800e28:	89 d1                	mov    %edx,%ecx
  800e2a:	89 d3                	mov    %edx,%ebx
  800e2c:	89 d7                	mov    %edx,%edi
  800e2e:	51                   	push   %ecx
  800e2f:	52                   	push   %edx
  800e30:	53                   	push   %ebx
  800e31:	54                   	push   %esp
  800e32:	55                   	push   %ebp
  800e33:	56                   	push   %esi
  800e34:	57                   	push   %edi
  800e35:	5f                   	pop    %edi
  800e36:	5e                   	pop    %esi
  800e37:	5d                   	pop    %ebp
  800e38:	5c                   	pop    %esp
  800e39:	5b                   	pop    %ebx
  800e3a:	5a                   	pop    %edx
  800e3b:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e3c:	8b 1c 24             	mov    (%esp),%ebx
  800e3f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e43:	89 ec                	mov    %ebp,%esp
  800e45:	5d                   	pop    %ebp
  800e46:	c3                   	ret    

00800e47 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800e47:	55                   	push   %ebp
  800e48:	89 e5                	mov    %esp,%ebp
  800e4a:	83 ec 08             	sub    $0x8,%esp
  800e4d:	89 1c 24             	mov    %ebx,(%esp)
  800e50:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e54:	ba 00 00 00 00       	mov    $0x0,%edx
  800e59:	b8 02 00 00 00       	mov    $0x2,%eax
  800e5e:	89 d1                	mov    %edx,%ecx
  800e60:	89 d3                	mov    %edx,%ebx
  800e62:	89 d7                	mov    %edx,%edi
  800e64:	51                   	push   %ecx
  800e65:	52                   	push   %edx
  800e66:	53                   	push   %ebx
  800e67:	54                   	push   %esp
  800e68:	55                   	push   %ebp
  800e69:	56                   	push   %esi
  800e6a:	57                   	push   %edi
  800e6b:	5f                   	pop    %edi
  800e6c:	5e                   	pop    %esi
  800e6d:	5d                   	pop    %ebp
  800e6e:	5c                   	pop    %esp
  800e6f:	5b                   	pop    %ebx
  800e70:	5a                   	pop    %edx
  800e71:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e72:	8b 1c 24             	mov    (%esp),%ebx
  800e75:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e79:	89 ec                	mov    %ebp,%esp
  800e7b:	5d                   	pop    %ebp
  800e7c:	c3                   	ret    

00800e7d <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800e7d:	55                   	push   %ebp
  800e7e:	89 e5                	mov    %esp,%ebp
  800e80:	83 ec 08             	sub    $0x8,%esp
  800e83:	89 1c 24             	mov    %ebx,(%esp)
  800e86:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e8a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e8f:	b8 04 00 00 00       	mov    $0x4,%eax
  800e94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e97:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9a:	89 df                	mov    %ebx,%edi
  800e9c:	51                   	push   %ecx
  800e9d:	52                   	push   %edx
  800e9e:	53                   	push   %ebx
  800e9f:	54                   	push   %esp
  800ea0:	55                   	push   %ebp
  800ea1:	56                   	push   %esi
  800ea2:	57                   	push   %edi
  800ea3:	5f                   	pop    %edi
  800ea4:	5e                   	pop    %esi
  800ea5:	5d                   	pop    %ebp
  800ea6:	5c                   	pop    %esp
  800ea7:	5b                   	pop    %ebx
  800ea8:	5a                   	pop    %edx
  800ea9:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800eaa:	8b 1c 24             	mov    (%esp),%ebx
  800ead:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800eb1:	89 ec                	mov    %ebp,%esp
  800eb3:	5d                   	pop    %ebp
  800eb4:	c3                   	ret    

00800eb5 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  800eb5:	55                   	push   %ebp
  800eb6:	89 e5                	mov    %esp,%ebp
  800eb8:	83 ec 08             	sub    $0x8,%esp
  800ebb:	89 1c 24             	mov    %ebx,(%esp)
  800ebe:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800ec2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ec7:	b8 05 00 00 00       	mov    $0x5,%eax
  800ecc:	8b 55 08             	mov    0x8(%ebp),%edx
  800ecf:	89 cb                	mov    %ecx,%ebx
  800ed1:	89 cf                	mov    %ecx,%edi
  800ed3:	51                   	push   %ecx
  800ed4:	52                   	push   %edx
  800ed5:	53                   	push   %ebx
  800ed6:	54                   	push   %esp
  800ed7:	55                   	push   %ebp
  800ed8:	56                   	push   %esi
  800ed9:	57                   	push   %edi
  800eda:	5f                   	pop    %edi
  800edb:	5e                   	pop    %esi
  800edc:	5d                   	pop    %ebp
  800edd:	5c                   	pop    %esp
  800ede:	5b                   	pop    %ebx
  800edf:	5a                   	pop    %edx
  800ee0:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800ee1:	8b 1c 24             	mov    (%esp),%ebx
  800ee4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ee8:	89 ec                	mov    %ebp,%esp
  800eea:	5d                   	pop    %ebp
  800eeb:	c3                   	ret    

00800eec <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800eec:	55                   	push   %ebp
  800eed:	89 e5                	mov    %esp,%ebp
  800eef:	83 ec 28             	sub    $0x28,%esp
  800ef2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800ef5:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800ef8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800efd:	b8 03 00 00 00       	mov    $0x3,%eax
  800f02:	8b 55 08             	mov    0x8(%ebp),%edx
  800f05:	89 cb                	mov    %ecx,%ebx
  800f07:	89 cf                	mov    %ecx,%edi
  800f09:	51                   	push   %ecx
  800f0a:	52                   	push   %edx
  800f0b:	53                   	push   %ebx
  800f0c:	54                   	push   %esp
  800f0d:	55                   	push   %ebp
  800f0e:	56                   	push   %esi
  800f0f:	57                   	push   %edi
  800f10:	5f                   	pop    %edi
  800f11:	5e                   	pop    %esi
  800f12:	5d                   	pop    %ebp
  800f13:	5c                   	pop    %esp
  800f14:	5b                   	pop    %ebx
  800f15:	5a                   	pop    %edx
  800f16:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800f17:	85 c0                	test   %eax,%eax
  800f19:	7e 28                	jle    800f43 <sys_env_destroy+0x57>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f1b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f1f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800f26:	00 
  800f27:	c7 44 24 08 c0 14 80 	movl   $0x8014c0,0x8(%esp)
  800f2e:	00 
  800f2f:	c7 44 24 04 26 00 00 	movl   $0x26,0x4(%esp)
  800f36:	00 
  800f37:	c7 04 24 dd 14 80 00 	movl   $0x8014dd,(%esp)
  800f3e:	e8 0d 00 00 00       	call   800f50 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800f43:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800f46:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f49:	89 ec                	mov    %ebp,%esp
  800f4b:	5d                   	pop    %ebp
  800f4c:	c3                   	ret    
  800f4d:	00 00                	add    %al,(%eax)
	...

00800f50 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800f50:	55                   	push   %ebp
  800f51:	89 e5                	mov    %esp,%ebp
  800f53:	56                   	push   %esi
  800f54:	53                   	push   %ebx
  800f55:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  800f58:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  800f5b:	a1 0c 20 80 00       	mov    0x80200c,%eax
  800f60:	85 c0                	test   %eax,%eax
  800f62:	74 10                	je     800f74 <_panic+0x24>
		cprintf("%s: ", argv0);
  800f64:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f68:	c7 04 24 eb 14 80 00 	movl   $0x8014eb,(%esp)
  800f6f:	e8 a1 f1 ff ff       	call   800115 <cprintf>
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800f74:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800f7a:	e8 c8 fe ff ff       	call   800e47 <sys_getenvid>
  800f7f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f82:	89 54 24 10          	mov    %edx,0x10(%esp)
  800f86:	8b 55 08             	mov    0x8(%ebp),%edx
  800f89:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f8d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f91:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f95:	c7 04 24 f0 14 80 00 	movl   $0x8014f0,(%esp)
  800f9c:	e8 74 f1 ff ff       	call   800115 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800fa1:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fa5:	8b 45 10             	mov    0x10(%ebp),%eax
  800fa8:	89 04 24             	mov    %eax,(%esp)
  800fab:	e8 04 f1 ff ff       	call   8000b4 <vcprintf>
	cprintf("\n");
  800fb0:	c7 04 24 34 12 80 00 	movl   $0x801234,(%esp)
  800fb7:	e8 59 f1 ff ff       	call   800115 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800fbc:	cc                   	int3   
  800fbd:	eb fd                	jmp    800fbc <_panic+0x6c>
	...

00800fc0 <__udivdi3>:
  800fc0:	55                   	push   %ebp
  800fc1:	89 e5                	mov    %esp,%ebp
  800fc3:	57                   	push   %edi
  800fc4:	56                   	push   %esi
  800fc5:	83 ec 10             	sub    $0x10,%esp
  800fc8:	8b 45 14             	mov    0x14(%ebp),%eax
  800fcb:	8b 55 08             	mov    0x8(%ebp),%edx
  800fce:	8b 75 10             	mov    0x10(%ebp),%esi
  800fd1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800fd4:	85 c0                	test   %eax,%eax
  800fd6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  800fd9:	75 35                	jne    801010 <__udivdi3+0x50>
  800fdb:	39 fe                	cmp    %edi,%esi
  800fdd:	77 61                	ja     801040 <__udivdi3+0x80>
  800fdf:	85 f6                	test   %esi,%esi
  800fe1:	75 0b                	jne    800fee <__udivdi3+0x2e>
  800fe3:	b8 01 00 00 00       	mov    $0x1,%eax
  800fe8:	31 d2                	xor    %edx,%edx
  800fea:	f7 f6                	div    %esi
  800fec:	89 c6                	mov    %eax,%esi
  800fee:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  800ff1:	31 d2                	xor    %edx,%edx
  800ff3:	89 f8                	mov    %edi,%eax
  800ff5:	f7 f6                	div    %esi
  800ff7:	89 c7                	mov    %eax,%edi
  800ff9:	89 c8                	mov    %ecx,%eax
  800ffb:	f7 f6                	div    %esi
  800ffd:	89 c1                	mov    %eax,%ecx
  800fff:	89 fa                	mov    %edi,%edx
  801001:	89 c8                	mov    %ecx,%eax
  801003:	83 c4 10             	add    $0x10,%esp
  801006:	5e                   	pop    %esi
  801007:	5f                   	pop    %edi
  801008:	5d                   	pop    %ebp
  801009:	c3                   	ret    
  80100a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801010:	39 f8                	cmp    %edi,%eax
  801012:	77 1c                	ja     801030 <__udivdi3+0x70>
  801014:	0f bd d0             	bsr    %eax,%edx
  801017:	83 f2 1f             	xor    $0x1f,%edx
  80101a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80101d:	75 39                	jne    801058 <__udivdi3+0x98>
  80101f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801022:	0f 86 a0 00 00 00    	jbe    8010c8 <__udivdi3+0x108>
  801028:	39 f8                	cmp    %edi,%eax
  80102a:	0f 82 98 00 00 00    	jb     8010c8 <__udivdi3+0x108>
  801030:	31 ff                	xor    %edi,%edi
  801032:	31 c9                	xor    %ecx,%ecx
  801034:	89 c8                	mov    %ecx,%eax
  801036:	89 fa                	mov    %edi,%edx
  801038:	83 c4 10             	add    $0x10,%esp
  80103b:	5e                   	pop    %esi
  80103c:	5f                   	pop    %edi
  80103d:	5d                   	pop    %ebp
  80103e:	c3                   	ret    
  80103f:	90                   	nop
  801040:	89 d1                	mov    %edx,%ecx
  801042:	89 fa                	mov    %edi,%edx
  801044:	89 c8                	mov    %ecx,%eax
  801046:	31 ff                	xor    %edi,%edi
  801048:	f7 f6                	div    %esi
  80104a:	89 c1                	mov    %eax,%ecx
  80104c:	89 fa                	mov    %edi,%edx
  80104e:	89 c8                	mov    %ecx,%eax
  801050:	83 c4 10             	add    $0x10,%esp
  801053:	5e                   	pop    %esi
  801054:	5f                   	pop    %edi
  801055:	5d                   	pop    %ebp
  801056:	c3                   	ret    
  801057:	90                   	nop
  801058:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80105c:	89 f2                	mov    %esi,%edx
  80105e:	d3 e0                	shl    %cl,%eax
  801060:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801063:	b8 20 00 00 00       	mov    $0x20,%eax
  801068:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80106b:	89 c1                	mov    %eax,%ecx
  80106d:	d3 ea                	shr    %cl,%edx
  80106f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801073:	0b 55 ec             	or     -0x14(%ebp),%edx
  801076:	d3 e6                	shl    %cl,%esi
  801078:	89 c1                	mov    %eax,%ecx
  80107a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80107d:	89 fe                	mov    %edi,%esi
  80107f:	d3 ee                	shr    %cl,%esi
  801081:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801085:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801088:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80108b:	d3 e7                	shl    %cl,%edi
  80108d:	89 c1                	mov    %eax,%ecx
  80108f:	d3 ea                	shr    %cl,%edx
  801091:	09 d7                	or     %edx,%edi
  801093:	89 f2                	mov    %esi,%edx
  801095:	89 f8                	mov    %edi,%eax
  801097:	f7 75 ec             	divl   -0x14(%ebp)
  80109a:	89 d6                	mov    %edx,%esi
  80109c:	89 c7                	mov    %eax,%edi
  80109e:	f7 65 e8             	mull   -0x18(%ebp)
  8010a1:	39 d6                	cmp    %edx,%esi
  8010a3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8010a6:	72 30                	jb     8010d8 <__udivdi3+0x118>
  8010a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010ab:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8010af:	d3 e2                	shl    %cl,%edx
  8010b1:	39 c2                	cmp    %eax,%edx
  8010b3:	73 05                	jae    8010ba <__udivdi3+0xfa>
  8010b5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  8010b8:	74 1e                	je     8010d8 <__udivdi3+0x118>
  8010ba:	89 f9                	mov    %edi,%ecx
  8010bc:	31 ff                	xor    %edi,%edi
  8010be:	e9 71 ff ff ff       	jmp    801034 <__udivdi3+0x74>
  8010c3:	90                   	nop
  8010c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010c8:	31 ff                	xor    %edi,%edi
  8010ca:	b9 01 00 00 00       	mov    $0x1,%ecx
  8010cf:	e9 60 ff ff ff       	jmp    801034 <__udivdi3+0x74>
  8010d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010d8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  8010db:	31 ff                	xor    %edi,%edi
  8010dd:	89 c8                	mov    %ecx,%eax
  8010df:	89 fa                	mov    %edi,%edx
  8010e1:	83 c4 10             	add    $0x10,%esp
  8010e4:	5e                   	pop    %esi
  8010e5:	5f                   	pop    %edi
  8010e6:	5d                   	pop    %ebp
  8010e7:	c3                   	ret    
	...

008010f0 <__umoddi3>:
  8010f0:	55                   	push   %ebp
  8010f1:	89 e5                	mov    %esp,%ebp
  8010f3:	57                   	push   %edi
  8010f4:	56                   	push   %esi
  8010f5:	83 ec 20             	sub    $0x20,%esp
  8010f8:	8b 55 14             	mov    0x14(%ebp),%edx
  8010fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010fe:	8b 7d 10             	mov    0x10(%ebp),%edi
  801101:	8b 75 0c             	mov    0xc(%ebp),%esi
  801104:	85 d2                	test   %edx,%edx
  801106:	89 c8                	mov    %ecx,%eax
  801108:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80110b:	75 13                	jne    801120 <__umoddi3+0x30>
  80110d:	39 f7                	cmp    %esi,%edi
  80110f:	76 3f                	jbe    801150 <__umoddi3+0x60>
  801111:	89 f2                	mov    %esi,%edx
  801113:	f7 f7                	div    %edi
  801115:	89 d0                	mov    %edx,%eax
  801117:	31 d2                	xor    %edx,%edx
  801119:	83 c4 20             	add    $0x20,%esp
  80111c:	5e                   	pop    %esi
  80111d:	5f                   	pop    %edi
  80111e:	5d                   	pop    %ebp
  80111f:	c3                   	ret    
  801120:	39 f2                	cmp    %esi,%edx
  801122:	77 4c                	ja     801170 <__umoddi3+0x80>
  801124:	0f bd ca             	bsr    %edx,%ecx
  801127:	83 f1 1f             	xor    $0x1f,%ecx
  80112a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80112d:	75 51                	jne    801180 <__umoddi3+0x90>
  80112f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801132:	0f 87 e0 00 00 00    	ja     801218 <__umoddi3+0x128>
  801138:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80113b:	29 f8                	sub    %edi,%eax
  80113d:	19 d6                	sbb    %edx,%esi
  80113f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801142:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801145:	89 f2                	mov    %esi,%edx
  801147:	83 c4 20             	add    $0x20,%esp
  80114a:	5e                   	pop    %esi
  80114b:	5f                   	pop    %edi
  80114c:	5d                   	pop    %ebp
  80114d:	c3                   	ret    
  80114e:	66 90                	xchg   %ax,%ax
  801150:	85 ff                	test   %edi,%edi
  801152:	75 0b                	jne    80115f <__umoddi3+0x6f>
  801154:	b8 01 00 00 00       	mov    $0x1,%eax
  801159:	31 d2                	xor    %edx,%edx
  80115b:	f7 f7                	div    %edi
  80115d:	89 c7                	mov    %eax,%edi
  80115f:	89 f0                	mov    %esi,%eax
  801161:	31 d2                	xor    %edx,%edx
  801163:	f7 f7                	div    %edi
  801165:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801168:	f7 f7                	div    %edi
  80116a:	eb a9                	jmp    801115 <__umoddi3+0x25>
  80116c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801170:	89 c8                	mov    %ecx,%eax
  801172:	89 f2                	mov    %esi,%edx
  801174:	83 c4 20             	add    $0x20,%esp
  801177:	5e                   	pop    %esi
  801178:	5f                   	pop    %edi
  801179:	5d                   	pop    %ebp
  80117a:	c3                   	ret    
  80117b:	90                   	nop
  80117c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801180:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801184:	d3 e2                	shl    %cl,%edx
  801186:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801189:	ba 20 00 00 00       	mov    $0x20,%edx
  80118e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  801191:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801194:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801198:	89 fa                	mov    %edi,%edx
  80119a:	d3 ea                	shr    %cl,%edx
  80119c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011a0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8011a3:	d3 e7                	shl    %cl,%edi
  8011a5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8011a9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8011ac:	89 f2                	mov    %esi,%edx
  8011ae:	89 7d e8             	mov    %edi,-0x18(%ebp)
  8011b1:	89 c7                	mov    %eax,%edi
  8011b3:	d3 ea                	shr    %cl,%edx
  8011b5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011b9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8011bc:	89 c2                	mov    %eax,%edx
  8011be:	d3 e6                	shl    %cl,%esi
  8011c0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8011c4:	d3 ea                	shr    %cl,%edx
  8011c6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011ca:	09 d6                	or     %edx,%esi
  8011cc:	89 f0                	mov    %esi,%eax
  8011ce:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8011d1:	d3 e7                	shl    %cl,%edi
  8011d3:	89 f2                	mov    %esi,%edx
  8011d5:	f7 75 f4             	divl   -0xc(%ebp)
  8011d8:	89 d6                	mov    %edx,%esi
  8011da:	f7 65 e8             	mull   -0x18(%ebp)
  8011dd:	39 d6                	cmp    %edx,%esi
  8011df:	72 2b                	jb     80120c <__umoddi3+0x11c>
  8011e1:	39 c7                	cmp    %eax,%edi
  8011e3:	72 23                	jb     801208 <__umoddi3+0x118>
  8011e5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011e9:	29 c7                	sub    %eax,%edi
  8011eb:	19 d6                	sbb    %edx,%esi
  8011ed:	89 f0                	mov    %esi,%eax
  8011ef:	89 f2                	mov    %esi,%edx
  8011f1:	d3 ef                	shr    %cl,%edi
  8011f3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8011f7:	d3 e0                	shl    %cl,%eax
  8011f9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011fd:	09 f8                	or     %edi,%eax
  8011ff:	d3 ea                	shr    %cl,%edx
  801201:	83 c4 20             	add    $0x20,%esp
  801204:	5e                   	pop    %esi
  801205:	5f                   	pop    %edi
  801206:	5d                   	pop    %ebp
  801207:	c3                   	ret    
  801208:	39 d6                	cmp    %edx,%esi
  80120a:	75 d9                	jne    8011e5 <__umoddi3+0xf5>
  80120c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80120f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801212:	eb d1                	jmp    8011e5 <__umoddi3+0xf5>
  801214:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801218:	39 f2                	cmp    %esi,%edx
  80121a:	0f 82 18 ff ff ff    	jb     801138 <__umoddi3+0x48>
  801220:	e9 1d ff ff ff       	jmp    801142 <__umoddi3+0x52>
