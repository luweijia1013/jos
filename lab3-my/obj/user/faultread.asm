
obj/user/faultread:     file format elf32-i386


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

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	cprintf("I read %08x from location 0!\n", *(unsigned*)0);
  80003a:	a1 00 00 00 00       	mov    0x0,%eax
  80003f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800043:	c7 04 24 08 12 80 00 	movl   $0x801208,(%esp)
  80004a:	e8 b2 00 00 00       	call   800101 <cprintf>
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
  800060:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800067:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006a:	85 c0                	test   %eax,%eax
  80006c:	7e 08                	jle    800076 <libmain+0x22>
		binaryname = argv[0];
  80006e:	8b 0a                	mov    (%edx),%ecx
  800070:	89 0d 00 20 80 00    	mov    %ecx,0x802000

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
  800099:	e8 2e 0e 00 00       	call   800ecc <sys_env_destroy>
}
  80009e:	c9                   	leave  
  80009f:	c3                   	ret    

008000a0 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8000a9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8000b0:	00 00 00 
	b.cnt = 0;
  8000b3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8000ba:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8000bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000c0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8000c7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000cb:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8000d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000d5:	c7 04 24 1b 01 80 00 	movl   $0x80011b,(%esp)
  8000dc:	e8 ff 02 00 00       	call   8003e0 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8000e1:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8000e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000eb:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8000f1:	89 04 24             	mov    %eax,(%esp)
  8000f4:	e8 c3 0c 00 00       	call   800dbc <sys_cputs>

	return b.cnt;
}
  8000f9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8000ff:	c9                   	leave  
  800100:	c3                   	ret    

00800101 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800101:	55                   	push   %ebp
  800102:	89 e5                	mov    %esp,%ebp
  800104:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  800107:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  80010a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80010e:	8b 45 08             	mov    0x8(%ebp),%eax
  800111:	89 04 24             	mov    %eax,(%esp)
  800114:	e8 87 ff ff ff       	call   8000a0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800119:	c9                   	leave  
  80011a:	c3                   	ret    

0080011b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80011b:	55                   	push   %ebp
  80011c:	89 e5                	mov    %esp,%ebp
  80011e:	53                   	push   %ebx
  80011f:	83 ec 14             	sub    $0x14,%esp
  800122:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800125:	8b 03                	mov    (%ebx),%eax
  800127:	8b 55 08             	mov    0x8(%ebp),%edx
  80012a:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80012e:	83 c0 01             	add    $0x1,%eax
  800131:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800133:	3d ff 00 00 00       	cmp    $0xff,%eax
  800138:	75 19                	jne    800153 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80013a:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800141:	00 
  800142:	8d 43 08             	lea    0x8(%ebx),%eax
  800145:	89 04 24             	mov    %eax,(%esp)
  800148:	e8 6f 0c 00 00       	call   800dbc <sys_cputs>
		b->idx = 0;
  80014d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800153:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800157:	83 c4 14             	add    $0x14,%esp
  80015a:	5b                   	pop    %ebx
  80015b:	5d                   	pop    %ebp
  80015c:	c3                   	ret    
  80015d:	00 00                	add    %al,(%eax)
	...

00800160 <printnum_nopad>:

/*
* help function added by Lu to print only the num;
*/
static void printnum_nopad(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int *num_len){
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	83 ec 48             	sub    $0x48,%esp
  800166:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800169:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80016c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80016f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800172:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800175:	8b 45 08             	mov    0x8(%ebp),%eax
  800178:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80017b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80017e:	8b 45 10             	mov    0x10(%ebp),%eax
  800181:	8b 7d 14             	mov    0x14(%ebp),%edi
	if(num >= base){
  800184:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800187:	ba 00 00 00 00       	mov    $0x0,%edx
  80018c:	39 f2                	cmp    %esi,%edx
  80018e:	72 07                	jb     800197 <printnum_nopad+0x37>
  800190:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800193:	39 c8                	cmp    %ecx,%eax
  800195:	77 54                	ja     8001eb <printnum_nopad+0x8b>
		printnum_nopad(putch, putdat, num / base, base, num_len);
  800197:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80019b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80019f:	8b 44 24 08          	mov    0x8(%esp),%eax
  8001a3:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8001a7:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8001aa:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8001ad:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8001b0:	89 54 24 08          	mov    %edx,0x8(%esp)
  8001b4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001bb:	00 
  8001bc:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8001bf:	89 0c 24             	mov    %ecx,(%esp)
  8001c2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001c6:	e8 d5 0d 00 00       	call   800fa0 <__udivdi3>
  8001cb:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8001ce:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  8001d1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8001d5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001d9:	89 04 24             	mov    %eax,(%esp)
  8001dc:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001e0:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8001e3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8001e6:	e8 75 ff ff ff       	call   800160 <printnum_nopad>
	}
	*num_len += 1 ;
  8001eb:	83 07 01             	addl   $0x1,(%edi)
	putch("0123456789abcdef"[num % base], putdat);
  8001ee:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8001f1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8001f5:	8b 04 24             	mov    (%esp),%eax
  8001f8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8001fc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001ff:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800202:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800205:	89 54 24 08          	mov    %edx,0x8(%esp)
  800209:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800210:	00 
  800211:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800214:	89 0c 24             	mov    %ecx,(%esp)
  800217:	89 74 24 04          	mov    %esi,0x4(%esp)
  80021b:	e8 b0 0e 00 00       	call   8010d0 <__umoddi3>
  800220:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800223:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800227:	0f be 80 30 12 80 00 	movsbl 0x801230(%eax),%eax
  80022e:	89 04 24             	mov    %eax,(%esp)
  800231:	ff 55 d4             	call   *-0x2c(%ebp)
}
  800234:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800237:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80023a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80023d:	89 ec                	mov    %ebp,%esp
  80023f:	5d                   	pop    %ebp
  800240:	c3                   	ret    

00800241 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800241:	55                   	push   %ebp
  800242:	89 e5                	mov    %esp,%ebp
  800244:	57                   	push   %edi
  800245:	56                   	push   %esi
  800246:	53                   	push   %ebx
  800247:	83 ec 5c             	sub    $0x5c,%esp
  80024a:	89 c7                	mov    %eax,%edi
  80024c:	89 d6                	mov    %edx,%esi
  80024e:	8b 45 08             	mov    0x8(%ebp),%eax
  800251:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800254:	8b 55 0c             	mov    0xc(%ebp),%edx
  800257:	89 55 cc             	mov    %edx,-0x34(%ebp)
  80025a:	8b 45 10             	mov    0x10(%ebp),%eax
  80025d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	if(padc == '-'){
  800260:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  800264:	75 4c                	jne    8002b2 <printnum+0x71>
		int num_len = 0;
  800266:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		printnum_nopad(putch, putdat, num, base, &num_len);
  80026d:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800270:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800274:	89 44 24 08          	mov    %eax,0x8(%esp)
  800278:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80027b:	89 0c 24             	mov    %ecx,(%esp)
  80027e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800281:	89 44 24 04          	mov    %eax,0x4(%esp)
  800285:	89 f2                	mov    %esi,%edx
  800287:	89 f8                	mov    %edi,%eax
  800289:	e8 d2 fe ff ff       	call   800160 <printnum_nopad>
		width -= num_len;
  80028e:	2b 5d e4             	sub    -0x1c(%ebp),%ebx
		while (width-- > 0)
  800291:	85 db                	test   %ebx,%ebx
  800293:	0f 8e e8 00 00 00    	jle    800381 <printnum+0x140>
			putch(' ', putdat);
  800299:	89 74 24 04          	mov    %esi,0x4(%esp)
  80029d:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8002a4:	ff d7                	call   *%edi
  8002a6:	83 eb 01             	sub    $0x1,%ebx
	// your code here:
	if(padc == '-'){
		int num_len = 0;
		printnum_nopad(putch, putdat, num, base, &num_len);
		width -= num_len;
		while (width-- > 0)
  8002a9:	85 db                	test   %ebx,%ebx
  8002ab:	7f ec                	jg     800299 <printnum+0x58>
  8002ad:	e9 cf 00 00 00       	jmp    800381 <printnum+0x140>
			putch(' ', putdat);
	}
	else{
		// first recursively print all preceding (more significant) digits
		if (num >= base) {
  8002b2:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8002b5:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8002b9:	77 19                	ja     8002d4 <printnum+0x93>
  8002bb:	90                   	nop
  8002bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8002c0:	72 05                	jb     8002c7 <printnum+0x86>
  8002c2:	39 45 c8             	cmp    %eax,-0x38(%ebp)
  8002c5:	73 0d                	jae    8002d4 <printnum+0x93>
			printnum(putch, putdat, num / base, base, width - 1, padc);
		} else {
			// print any needed pad characters before first digit
			while (--width > 0)
  8002c7:	83 eb 01             	sub    $0x1,%ebx
  8002ca:	85 db                	test   %ebx,%ebx
  8002cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8002d0:	7f 63                	jg     800335 <printnum+0xf4>
  8002d2:	eb 74                	jmp    800348 <printnum+0x107>
			putch(' ', putdat);
	}
	else{
		// first recursively print all preceding (more significant) digits
		if (num >= base) {
			printnum(putch, putdat, num / base, base, width - 1, padc);
  8002d4:	8b 55 18             	mov    0x18(%ebp),%edx
  8002d7:	89 54 24 10          	mov    %edx,0x10(%esp)
  8002db:	83 eb 01             	sub    $0x1,%ebx
  8002de:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002e2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002e6:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8002ea:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8002ee:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8002f1:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8002f4:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  8002f7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002fb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800302:	00 
  800303:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800306:	89 04 24             	mov    %eax,(%esp)
  800309:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80030c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800310:	e8 8b 0c 00 00       	call   800fa0 <__udivdi3>
  800315:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800318:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80031b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80031f:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800323:	89 04 24             	mov    %eax,(%esp)
  800326:	89 54 24 04          	mov    %edx,0x4(%esp)
  80032a:	89 f2                	mov    %esi,%edx
  80032c:	89 f8                	mov    %edi,%eax
  80032e:	e8 0e ff ff ff       	call   800241 <printnum>
  800333:	eb 13                	jmp    800348 <printnum+0x107>
		} else {
			// print any needed pad characters before first digit
			while (--width > 0)
				putch(padc, putdat);
  800335:	89 74 24 04          	mov    %esi,0x4(%esp)
  800339:	8b 45 18             	mov    0x18(%ebp),%eax
  80033c:	89 04 24             	mov    %eax,(%esp)
  80033f:	ff d7                	call   *%edi
		// first recursively print all preceding (more significant) digits
		if (num >= base) {
			printnum(putch, putdat, num / base, base, width - 1, padc);
		} else {
			// print any needed pad characters before first digit
			while (--width > 0)
  800341:	83 eb 01             	sub    $0x1,%ebx
  800344:	85 db                	test   %ebx,%ebx
  800346:	7f ed                	jg     800335 <printnum+0xf4>
				putch(padc, putdat);
		}

		// then print this (the least significant) digit
		putch("0123456789abcdef"[num % base], putdat);
  800348:	89 74 24 04          	mov    %esi,0x4(%esp)
  80034c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800350:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800353:	89 54 24 08          	mov    %edx,0x8(%esp)
  800357:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80035e:	00 
  80035f:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800362:	89 0c 24             	mov    %ecx,(%esp)
  800365:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800368:	89 44 24 04          	mov    %eax,0x4(%esp)
  80036c:	e8 5f 0d 00 00       	call   8010d0 <__umoddi3>
  800371:	89 74 24 04          	mov    %esi,0x4(%esp)
  800375:	0f be 80 30 12 80 00 	movsbl 0x801230(%eax),%eax
  80037c:	89 04 24             	mov    %eax,(%esp)
  80037f:	ff d7                	call   *%edi
	}
	
}
  800381:	83 c4 5c             	add    $0x5c,%esp
  800384:	5b                   	pop    %ebx
  800385:	5e                   	pop    %esi
  800386:	5f                   	pop    %edi
  800387:	5d                   	pop    %ebp
  800388:	c3                   	ret    

00800389 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800389:	55                   	push   %ebp
  80038a:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80038c:	83 fa 01             	cmp    $0x1,%edx
  80038f:	7e 0e                	jle    80039f <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800391:	8b 10                	mov    (%eax),%edx
  800393:	8d 4a 08             	lea    0x8(%edx),%ecx
  800396:	89 08                	mov    %ecx,(%eax)
  800398:	8b 02                	mov    (%edx),%eax
  80039a:	8b 52 04             	mov    0x4(%edx),%edx
  80039d:	eb 22                	jmp    8003c1 <getuint+0x38>
	else if (lflag)
  80039f:	85 d2                	test   %edx,%edx
  8003a1:	74 10                	je     8003b3 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003a3:	8b 10                	mov    (%eax),%edx
  8003a5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003a8:	89 08                	mov    %ecx,(%eax)
  8003aa:	8b 02                	mov    (%edx),%eax
  8003ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b1:	eb 0e                	jmp    8003c1 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003b3:	8b 10                	mov    (%eax),%edx
  8003b5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003b8:	89 08                	mov    %ecx,(%eax)
  8003ba:	8b 02                	mov    (%edx),%eax
  8003bc:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003c1:	5d                   	pop    %ebp
  8003c2:	c3                   	ret    

008003c3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003c3:	55                   	push   %ebp
  8003c4:	89 e5                	mov    %esp,%ebp
  8003c6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003c9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003cd:	8b 10                	mov    (%eax),%edx
  8003cf:	3b 50 04             	cmp    0x4(%eax),%edx
  8003d2:	73 0a                	jae    8003de <sprintputch+0x1b>
		*b->buf++ = ch;
  8003d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003d7:	88 0a                	mov    %cl,(%edx)
  8003d9:	83 c2 01             	add    $0x1,%edx
  8003dc:	89 10                	mov    %edx,(%eax)
}
  8003de:	5d                   	pop    %ebp
  8003df:	c3                   	ret    

008003e0 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003e0:	55                   	push   %ebp
  8003e1:	89 e5                	mov    %esp,%ebp
  8003e3:	57                   	push   %edi
  8003e4:	56                   	push   %esi
  8003e5:	53                   	push   %ebx
  8003e6:	83 ec 5c             	sub    $0x5c,%esp
  8003e9:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8003ec:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8003ef:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8003f6:	eb 12                	jmp    80040a <vprintfmt+0x2a>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003f8:	85 c0                	test   %eax,%eax
  8003fa:	0f 84 c6 04 00 00    	je     8008c6 <vprintfmt+0x4e6>
				return;
			putch(ch, putdat);
  800400:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800404:	89 04 24             	mov    %eax,(%esp)
  800407:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80040a:	0f b6 03             	movzbl (%ebx),%eax
  80040d:	83 c3 01             	add    $0x1,%ebx
  800410:	83 f8 25             	cmp    $0x25,%eax
  800413:	75 e3                	jne    8003f8 <vprintfmt+0x18>
  800415:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  800419:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800420:	be ff ff ff ff       	mov    $0xffffffff,%esi
  800425:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  80042c:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800433:	eb 06                	jmp    80043b <vprintfmt+0x5b>
  800435:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  800439:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043b:	0f b6 0b             	movzbl (%ebx),%ecx
  80043e:	0f b6 d1             	movzbl %cl,%edx
  800441:	8d 43 01             	lea    0x1(%ebx),%eax
  800444:	83 e9 23             	sub    $0x23,%ecx
  800447:	80 f9 55             	cmp    $0x55,%cl
  80044a:	0f 87 58 04 00 00    	ja     8008a8 <vprintfmt+0x4c8>
  800450:	0f b6 c9             	movzbl %cl,%ecx
  800453:	ff 24 8d 3c 13 80 00 	jmp    *0x80133c(,%ecx,4)
  80045a:	c6 45 e0 2b          	movb   $0x2b,-0x20(%ebp)
  80045e:	eb d9                	jmp    800439 <vprintfmt+0x59>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800460:	8d 72 d0             	lea    -0x30(%edx),%esi
				ch = *fmt;
  800463:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800466:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800469:	83 f9 09             	cmp    $0x9,%ecx
  80046c:	76 08                	jbe    800476 <vprintfmt+0x96>
  80046e:	eb 40                	jmp    8004b0 <vprintfmt+0xd0>
  800470:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
			goto reswitch;
  800474:	eb c3                	jmp    800439 <vprintfmt+0x59>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800476:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  800479:	8d 0c b6             	lea    (%esi,%esi,4),%ecx
  80047c:	8d 74 4a d0          	lea    -0x30(%edx,%ecx,2),%esi
				ch = *fmt;
  800480:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800483:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800486:	83 f9 09             	cmp    $0x9,%ecx
  800489:	76 eb                	jbe    800476 <vprintfmt+0x96>
  80048b:	eb 23                	jmp    8004b0 <vprintfmt+0xd0>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80048d:	8b 55 14             	mov    0x14(%ebp),%edx
  800490:	8d 4a 04             	lea    0x4(%edx),%ecx
  800493:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800496:	8b 32                	mov    (%edx),%esi
			goto process_precision;
  800498:	eb 16                	jmp    8004b0 <vprintfmt+0xd0>

		case '.':
			if (width < 0)
  80049a:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80049d:	c1 fa 1f             	sar    $0x1f,%edx
  8004a0:	f7 d2                	not    %edx
  8004a2:	21 55 dc             	and    %edx,-0x24(%ebp)
  8004a5:	eb 92                	jmp    800439 <vprintfmt+0x59>
  8004a7:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8004ae:	eb 89                	jmp    800439 <vprintfmt+0x59>

		process_precision:
			if (width < 0)
  8004b0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004b4:	79 83                	jns    800439 <vprintfmt+0x59>
  8004b6:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8004b9:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8004bc:	e9 78 ff ff ff       	jmp    800439 <vprintfmt+0x59>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004c1:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
			goto reswitch;
  8004c5:	e9 6f ff ff ff       	jmp    800439 <vprintfmt+0x59>
  8004ca:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d0:	8d 50 04             	lea    0x4(%eax),%edx
  8004d3:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004da:	8b 00                	mov    (%eax),%eax
  8004dc:	89 04 24             	mov    %eax,(%esp)
  8004df:	ff 55 08             	call   *0x8(%ebp)
  8004e2:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  8004e5:	e9 20 ff ff ff       	jmp    80040a <vprintfmt+0x2a>
  8004ea:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f0:	8d 50 04             	lea    0x4(%eax),%edx
  8004f3:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f6:	8b 00                	mov    (%eax),%eax
  8004f8:	89 c2                	mov    %eax,%edx
  8004fa:	c1 fa 1f             	sar    $0x1f,%edx
  8004fd:	31 d0                	xor    %edx,%eax
  8004ff:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800501:	83 f8 06             	cmp    $0x6,%eax
  800504:	7f 0b                	jg     800511 <vprintfmt+0x131>
  800506:	8b 14 85 94 14 80 00 	mov    0x801494(,%eax,4),%edx
  80050d:	85 d2                	test   %edx,%edx
  80050f:	75 23                	jne    800534 <vprintfmt+0x154>
				printfmt(putch, putdat, "error %d", err);
  800511:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800515:	c7 44 24 08 41 12 80 	movl   $0x801241,0x8(%esp)
  80051c:	00 
  80051d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800521:	8b 45 08             	mov    0x8(%ebp),%eax
  800524:	89 04 24             	mov    %eax,(%esp)
  800527:	e8 22 04 00 00       	call   80094e <printfmt>
  80052c:	8b 5d cc             	mov    -0x34(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80052f:	e9 d6 fe ff ff       	jmp    80040a <vprintfmt+0x2a>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800534:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800538:	c7 44 24 08 4a 12 80 	movl   $0x80124a,0x8(%esp)
  80053f:	00 
  800540:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800544:	8b 55 08             	mov    0x8(%ebp),%edx
  800547:	89 14 24             	mov    %edx,(%esp)
  80054a:	e8 ff 03 00 00       	call   80094e <printfmt>
  80054f:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800552:	e9 b3 fe ff ff       	jmp    80040a <vprintfmt+0x2a>
  800557:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80055a:	89 c3                	mov    %eax,%ebx
  80055c:	89 f1                	mov    %esi,%ecx
  80055e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800561:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800564:	8b 45 14             	mov    0x14(%ebp),%eax
  800567:	8d 50 04             	lea    0x4(%eax),%edx
  80056a:	89 55 14             	mov    %edx,0x14(%ebp)
  80056d:	8b 00                	mov    (%eax),%eax
  80056f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800572:	85 c0                	test   %eax,%eax
  800574:	75 07                	jne    80057d <vprintfmt+0x19d>
  800576:	c7 45 d0 4d 12 80 00 	movl   $0x80124d,-0x30(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  80057d:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  800581:	7e 06                	jle    800589 <vprintfmt+0x1a9>
  800583:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  800587:	75 13                	jne    80059c <vprintfmt+0x1bc>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800589:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80058c:	0f be 02             	movsbl (%edx),%eax
  80058f:	85 c0                	test   %eax,%eax
  800591:	0f 85 a2 00 00 00    	jne    800639 <vprintfmt+0x259>
  800597:	e9 8f 00 00 00       	jmp    80062b <vprintfmt+0x24b>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80059c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005a0:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8005a3:	89 0c 24             	mov    %ecx,(%esp)
  8005a6:	e8 f0 03 00 00       	call   80099b <strnlen>
  8005ab:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8005ae:	29 c2                	sub    %eax,%edx
  8005b0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005b3:	85 d2                	test   %edx,%edx
  8005b5:	7e d2                	jle    800589 <vprintfmt+0x1a9>
					putch(padc, putdat);
  8005b7:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  8005bb:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  8005be:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  8005c1:	89 d3                	mov    %edx,%ebx
  8005c3:	89 ce                	mov    %ecx,%esi
  8005c5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005c9:	89 34 24             	mov    %esi,(%esp)
  8005cc:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005cf:	83 eb 01             	sub    $0x1,%ebx
  8005d2:	85 db                	test   %ebx,%ebx
  8005d4:	7f ef                	jg     8005c5 <vprintfmt+0x1e5>
  8005d6:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  8005d9:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  8005dc:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8005e3:	eb a4                	jmp    800589 <vprintfmt+0x1a9>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005e5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005e9:	74 1b                	je     800606 <vprintfmt+0x226>
  8005eb:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005ee:	83 fa 5e             	cmp    $0x5e,%edx
  8005f1:	76 13                	jbe    800606 <vprintfmt+0x226>
					putch('?', putdat);
  8005f3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005fa:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800601:	ff 55 08             	call   *0x8(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800604:	eb 0d                	jmp    800613 <vprintfmt+0x233>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800606:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800609:	89 54 24 04          	mov    %edx,0x4(%esp)
  80060d:	89 04 24             	mov    %eax,(%esp)
  800610:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800613:	83 ef 01             	sub    $0x1,%edi
  800616:	0f be 03             	movsbl (%ebx),%eax
  800619:	85 c0                	test   %eax,%eax
  80061b:	74 05                	je     800622 <vprintfmt+0x242>
  80061d:	83 c3 01             	add    $0x1,%ebx
  800620:	eb 28                	jmp    80064a <vprintfmt+0x26a>
  800622:	89 7d dc             	mov    %edi,-0x24(%ebp)
  800625:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800628:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80062b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80062f:	7f 2d                	jg     80065e <vprintfmt+0x27e>
  800631:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800634:	e9 d1 fd ff ff       	jmp    80040a <vprintfmt+0x2a>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800639:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80063c:	83 c1 01             	add    $0x1,%ecx
  80063f:	89 7d e0             	mov    %edi,-0x20(%ebp)
  800642:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800645:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  800648:	89 cb                	mov    %ecx,%ebx
  80064a:	85 f6                	test   %esi,%esi
  80064c:	78 97                	js     8005e5 <vprintfmt+0x205>
  80064e:	83 ee 01             	sub    $0x1,%esi
  800651:	79 92                	jns    8005e5 <vprintfmt+0x205>
  800653:	89 7d dc             	mov    %edi,-0x24(%ebp)
  800656:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800659:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  80065c:	eb cd                	jmp    80062b <vprintfmt+0x24b>
  80065e:	8b 75 08             	mov    0x8(%ebp),%esi
  800661:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800664:	8b 5d dc             	mov    -0x24(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800667:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80066b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800672:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800674:	83 eb 01             	sub    $0x1,%ebx
  800677:	85 db                	test   %ebx,%ebx
  800679:	7f ec                	jg     800667 <vprintfmt+0x287>
  80067b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80067e:	e9 87 fd ff ff       	jmp    80040a <vprintfmt+0x2a>
  800683:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800686:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
  80068a:	88 45 e4             	mov    %al,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80068d:	83 7d d0 01          	cmpl   $0x1,-0x30(%ebp)
  800691:	7e 16                	jle    8006a9 <vprintfmt+0x2c9>
		return va_arg(*ap, long long);
  800693:	8b 45 14             	mov    0x14(%ebp),%eax
  800696:	8d 50 08             	lea    0x8(%eax),%edx
  800699:	89 55 14             	mov    %edx,0x14(%ebp)
  80069c:	8b 10                	mov    (%eax),%edx
  80069e:	8b 48 04             	mov    0x4(%eax),%ecx
  8006a1:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8006a4:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8006a7:	eb 34                	jmp    8006dd <vprintfmt+0x2fd>
	else if (lflag)
  8006a9:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8006ad:	74 18                	je     8006c7 <vprintfmt+0x2e7>
		return va_arg(*ap, long);
  8006af:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b2:	8d 50 04             	lea    0x4(%eax),%edx
  8006b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b8:	8b 00                	mov    (%eax),%eax
  8006ba:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006bd:	89 c1                	mov    %eax,%ecx
  8006bf:	c1 f9 1f             	sar    $0x1f,%ecx
  8006c2:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8006c5:	eb 16                	jmp    8006dd <vprintfmt+0x2fd>
	else
		return va_arg(*ap, int);
  8006c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ca:	8d 50 04             	lea    0x4(%eax),%edx
  8006cd:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d0:	8b 00                	mov    (%eax),%eax
  8006d2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006d5:	89 c2                	mov    %eax,%edx
  8006d7:	c1 fa 1f             	sar    $0x1f,%edx
  8006da:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006dd:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8006e0:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if ((long long) num < 0) {
  8006e3:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8006e7:	79 2c                	jns    800715 <vprintfmt+0x335>
				putch('-', putdat);
  8006e9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006ed:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006f4:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006f7:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8006fa:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8006fd:	f7 db                	neg    %ebx
  8006ff:	83 d6 00             	adc    $0x0,%esi
  800702:	f7 de                	neg    %esi
  800704:	0f b6 4d e0          	movzbl -0x20(%ebp),%ecx
  800708:	88 4d e4             	mov    %cl,-0x1c(%ebp)
  80070b:	ba 0a 00 00 00       	mov    $0xa,%edx
  800710:	e9 db 00 00 00       	jmp    8007f0 <vprintfmt+0x410>
			}
			else if (padc == '+'){
  800715:	80 7d e4 2b          	cmpb   $0x2b,-0x1c(%ebp)
  800719:	74 11                	je     80072c <vprintfmt+0x34c>
  80071b:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
  80071f:	88 45 e4             	mov    %al,-0x1c(%ebp)
  800722:	ba 0a 00 00 00       	mov    $0xa,%edx
  800727:	e9 c4 00 00 00       	jmp    8007f0 <vprintfmt+0x410>
				putch('+', putdat);
  80072c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800730:	c7 04 24 2b 00 00 00 	movl   $0x2b,(%esp)
  800737:	ff 55 08             	call   *0x8(%ebp)
  80073a:	ba 0a 00 00 00       	mov    $0xa,%edx
  80073f:	e9 ac 00 00 00       	jmp    8007f0 <vprintfmt+0x410>
  800744:	89 45 cc             	mov    %eax,-0x34(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800747:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80074a:	8d 45 14             	lea    0x14(%ebp),%eax
  80074d:	e8 37 fc ff ff       	call   800389 <getuint>
  800752:	89 c3                	mov    %eax,%ebx
  800754:	89 d6                	mov    %edx,%esi
  800756:	0f b6 55 e0          	movzbl -0x20(%ebp),%edx
  80075a:	88 55 e4             	mov    %dl,-0x1c(%ebp)
  80075d:	ba 0a 00 00 00       	mov    $0xa,%edx
			base = 10;
			goto number;
  800762:	e9 89 00 00 00       	jmp    8007f0 <vprintfmt+0x410>
  800767:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) octal
		case 'o':
			putch('0', putdat);
  80076a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80076e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800775:	ff 55 08             	call   *0x8(%ebp)
			num = getuint(&ap, lflag);
  800778:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80077b:	8d 45 14             	lea    0x14(%ebp),%eax
  80077e:	e8 06 fc ff ff       	call   800389 <getuint>
  800783:	89 c3                	mov    %eax,%ebx
  800785:	89 d6                	mov    %edx,%esi
  800787:	0f b6 4d e0          	movzbl -0x20(%ebp),%ecx
  80078b:	88 4d e4             	mov    %cl,-0x1c(%ebp)
  80078e:	ba 08 00 00 00       	mov    $0x8,%edx
			base = 8;
			goto number;
  800793:	eb 5b                	jmp    8007f0 <vprintfmt+0x410>
  800795:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  800798:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80079c:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007a3:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007a6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007aa:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007b1:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  8007b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b7:	8d 50 04             	lea    0x4(%eax),%edx
  8007ba:	89 55 14             	mov    %edx,0x14(%ebp)
  8007bd:	8b 18                	mov    (%eax),%ebx
  8007bf:	be 00 00 00 00       	mov    $0x0,%esi
  8007c4:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
  8007c8:	88 45 e4             	mov    %al,-0x1c(%ebp)
  8007cb:	ba 10 00 00 00       	mov    $0x10,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007d0:	eb 1e                	jmp    8007f0 <vprintfmt+0x410>
  8007d2:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007d5:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8007d8:	8d 45 14             	lea    0x14(%ebp),%eax
  8007db:	e8 a9 fb ff ff       	call   800389 <getuint>
  8007e0:	89 c3                	mov    %eax,%ebx
  8007e2:	89 d6                	mov    %edx,%esi
  8007e4:	0f b6 55 e0          	movzbl -0x20(%ebp),%edx
  8007e8:	88 55 e4             	mov    %dl,-0x1c(%ebp)
  8007eb:	ba 10 00 00 00       	mov    $0x10,%edx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007f0:	0f be 45 e4          	movsbl -0x1c(%ebp),%eax
  8007f4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8007f8:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8007fb:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8007ff:	89 54 24 08          	mov    %edx,0x8(%esp)
  800803:	89 1c 24             	mov    %ebx,(%esp)
  800806:	89 74 24 04          	mov    %esi,0x4(%esp)
  80080a:	89 fa                	mov    %edi,%edx
  80080c:	8b 45 08             	mov    0x8(%ebp),%eax
  80080f:	e8 2d fa ff ff       	call   800241 <printnum>
  800814:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  800817:	e9 ee fb ff ff       	jmp    80040a <vprintfmt+0x2a>
  80081c:	89 45 cc             	mov    %eax,-0x34(%ebp)
            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
	    	uint32_t *num_now = putdat;
	    	char *ret_va = va_arg(ap, char *);
  80081f:	8b 45 14             	mov    0x14(%ebp),%eax
  800822:	8d 50 04             	lea    0x4(%eax),%edx
  800825:	89 55 14             	mov    %edx,0x14(%ebp)
  800828:	8b 00                	mov    (%eax),%eax
	    	if(ret_va == NULL){
  80082a:	85 c0                	test   %eax,%eax
  80082c:	75 27                	jne    800855 <vprintfmt+0x475>
				printfmt(putch, putdat, "%s", null_error);
  80082e:	c7 44 24 0c c0 12 80 	movl   $0x8012c0,0xc(%esp)
  800835:	00 
  800836:	c7 44 24 08 4a 12 80 	movl   $0x80124a,0x8(%esp)
  80083d:	00 
  80083e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800842:	8b 45 08             	mov    0x8(%ebp),%eax
  800845:	89 04 24             	mov    %eax,(%esp)
  800848:	e8 01 01 00 00       	call   80094e <printfmt>
  80084d:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800850:	e9 b5 fb ff ff       	jmp    80040a <vprintfmt+0x2a>
	    	}
	    	else if ((*num_now) >> 7 != 0 ){		//how to aurrately discribe overflow?
  800855:	8b 17                	mov    (%edi),%edx
  800857:	89 d1                	mov    %edx,%ecx
  800859:	c1 e9 07             	shr    $0x7,%ecx
  80085c:	85 c9                	test   %ecx,%ecx
  80085e:	74 29                	je     800889 <vprintfmt+0x4a9>
				*ret_va = *(num_now);	//get putdat at first as next print instruction will change ret_va as it's a pointer which means it's dynamic;
  800860:	88 10                	mov    %dl,(%eax)
				printfmt(putch, putdat, "%s", overflow_error);
  800862:	c7 44 24 0c f8 12 80 	movl   $0x8012f8,0xc(%esp)
  800869:	00 
  80086a:	c7 44 24 08 4a 12 80 	movl   $0x80124a,0x8(%esp)
  800871:	00 
  800872:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800876:	8b 55 08             	mov    0x8(%ebp),%edx
  800879:	89 14 24             	mov    %edx,(%esp)
  80087c:	e8 cd 00 00 00       	call   80094e <printfmt>
  800881:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800884:	e9 81 fb ff ff       	jmp    80040a <vprintfmt+0x2a>
	    	}
	    	else{
				*ret_va = *(num_now);
  800889:	88 10                	mov    %dl,(%eax)
  80088b:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  80088e:	e9 77 fb ff ff       	jmp    80040a <vprintfmt+0x2a>
  800893:	89 45 cc             	mov    %eax,-0x34(%ebp)
            	break;
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800896:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80089a:	89 14 24             	mov    %edx,(%esp)
  80089d:	ff 55 08             	call   *0x8(%ebp)
  8008a0:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  8008a3:	e9 62 fb ff ff       	jmp    80040a <vprintfmt+0x2a>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008a8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008ac:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8008b3:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008b6:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8008b9:	80 38 25             	cmpb   $0x25,(%eax)
  8008bc:	0f 84 48 fb ff ff    	je     80040a <vprintfmt+0x2a>
  8008c2:	89 c3                	mov    %eax,%ebx
  8008c4:	eb f0                	jmp    8008b6 <vprintfmt+0x4d6>
				/* do nothing */;
			break;
		}
	}
}
  8008c6:	83 c4 5c             	add    $0x5c,%esp
  8008c9:	5b                   	pop    %ebx
  8008ca:	5e                   	pop    %esi
  8008cb:	5f                   	pop    %edi
  8008cc:	5d                   	pop    %ebp
  8008cd:	c3                   	ret    

008008ce <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008ce:	55                   	push   %ebp
  8008cf:	89 e5                	mov    %esp,%ebp
  8008d1:	83 ec 28             	sub    $0x28,%esp
  8008d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  8008da:	85 c0                	test   %eax,%eax
  8008dc:	74 04                	je     8008e2 <vsnprintf+0x14>
  8008de:	85 d2                	test   %edx,%edx
  8008e0:	7f 07                	jg     8008e9 <vsnprintf+0x1b>
  8008e2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008e7:	eb 3b                	jmp    800924 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008e9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008ec:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  8008f0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8008f3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8008fd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800901:	8b 45 10             	mov    0x10(%ebp),%eax
  800904:	89 44 24 08          	mov    %eax,0x8(%esp)
  800908:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80090b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80090f:	c7 04 24 c3 03 80 00 	movl   $0x8003c3,(%esp)
  800916:	e8 c5 fa ff ff       	call   8003e0 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80091b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80091e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800921:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800924:	c9                   	leave  
  800925:	c3                   	ret    

00800926 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800926:	55                   	push   %ebp
  800927:	89 e5                	mov    %esp,%ebp
  800929:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  80092c:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  80092f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800933:	8b 45 10             	mov    0x10(%ebp),%eax
  800936:	89 44 24 08          	mov    %eax,0x8(%esp)
  80093a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80093d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800941:	8b 45 08             	mov    0x8(%ebp),%eax
  800944:	89 04 24             	mov    %eax,(%esp)
  800947:	e8 82 ff ff ff       	call   8008ce <vsnprintf>
	va_end(ap);

	return rc;
}
  80094c:	c9                   	leave  
  80094d:	c3                   	ret    

0080094e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80094e:	55                   	push   %ebp
  80094f:	89 e5                	mov    %esp,%ebp
  800951:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800954:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800957:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80095b:	8b 45 10             	mov    0x10(%ebp),%eax
  80095e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800962:	8b 45 0c             	mov    0xc(%ebp),%eax
  800965:	89 44 24 04          	mov    %eax,0x4(%esp)
  800969:	8b 45 08             	mov    0x8(%ebp),%eax
  80096c:	89 04 24             	mov    %eax,(%esp)
  80096f:	e8 6c fa ff ff       	call   8003e0 <vprintfmt>
	va_end(ap);
}
  800974:	c9                   	leave  
  800975:	c3                   	ret    
	...

00800980 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800980:	55                   	push   %ebp
  800981:	89 e5                	mov    %esp,%ebp
  800983:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800986:	b8 00 00 00 00       	mov    $0x0,%eax
  80098b:	80 3a 00             	cmpb   $0x0,(%edx)
  80098e:	74 09                	je     800999 <strlen+0x19>
		n++;
  800990:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800993:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800997:	75 f7                	jne    800990 <strlen+0x10>
		n++;
	return n;
}
  800999:	5d                   	pop    %ebp
  80099a:	c3                   	ret    

0080099b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80099b:	55                   	push   %ebp
  80099c:	89 e5                	mov    %esp,%ebp
  80099e:	53                   	push   %ebx
  80099f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009a5:	85 c9                	test   %ecx,%ecx
  8009a7:	74 19                	je     8009c2 <strnlen+0x27>
  8009a9:	80 3b 00             	cmpb   $0x0,(%ebx)
  8009ac:	74 14                	je     8009c2 <strnlen+0x27>
  8009ae:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8009b3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009b6:	39 c8                	cmp    %ecx,%eax
  8009b8:	74 0d                	je     8009c7 <strnlen+0x2c>
  8009ba:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  8009be:	75 f3                	jne    8009b3 <strnlen+0x18>
  8009c0:	eb 05                	jmp    8009c7 <strnlen+0x2c>
  8009c2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8009c7:	5b                   	pop    %ebx
  8009c8:	5d                   	pop    %ebp
  8009c9:	c3                   	ret    

008009ca <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009ca:	55                   	push   %ebp
  8009cb:	89 e5                	mov    %esp,%ebp
  8009cd:	53                   	push   %ebx
  8009ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009d4:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009d9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8009dd:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8009e0:	83 c2 01             	add    $0x1,%edx
  8009e3:	84 c9                	test   %cl,%cl
  8009e5:	75 f2                	jne    8009d9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8009e7:	5b                   	pop    %ebx
  8009e8:	5d                   	pop    %ebp
  8009e9:	c3                   	ret    

008009ea <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009ea:	55                   	push   %ebp
  8009eb:	89 e5                	mov    %esp,%ebp
  8009ed:	53                   	push   %ebx
  8009ee:	83 ec 08             	sub    $0x8,%esp
  8009f1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009f4:	89 1c 24             	mov    %ebx,(%esp)
  8009f7:	e8 84 ff ff ff       	call   800980 <strlen>
	strcpy(dst + len, src);
  8009fc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ff:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a03:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800a06:	89 04 24             	mov    %eax,(%esp)
  800a09:	e8 bc ff ff ff       	call   8009ca <strcpy>
	return dst;
}
  800a0e:	89 d8                	mov    %ebx,%eax
  800a10:	83 c4 08             	add    $0x8,%esp
  800a13:	5b                   	pop    %ebx
  800a14:	5d                   	pop    %ebp
  800a15:	c3                   	ret    

00800a16 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a16:	55                   	push   %ebp
  800a17:	89 e5                	mov    %esp,%ebp
  800a19:	56                   	push   %esi
  800a1a:	53                   	push   %ebx
  800a1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a21:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a24:	85 f6                	test   %esi,%esi
  800a26:	74 18                	je     800a40 <strncpy+0x2a>
  800a28:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800a2d:	0f b6 1a             	movzbl (%edx),%ebx
  800a30:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a33:	80 3a 01             	cmpb   $0x1,(%edx)
  800a36:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a39:	83 c1 01             	add    $0x1,%ecx
  800a3c:	39 ce                	cmp    %ecx,%esi
  800a3e:	77 ed                	ja     800a2d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a40:	5b                   	pop    %ebx
  800a41:	5e                   	pop    %esi
  800a42:	5d                   	pop    %ebp
  800a43:	c3                   	ret    

00800a44 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a44:	55                   	push   %ebp
  800a45:	89 e5                	mov    %esp,%ebp
  800a47:	56                   	push   %esi
  800a48:	53                   	push   %ebx
  800a49:	8b 75 08             	mov    0x8(%ebp),%esi
  800a4c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a4f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a52:	89 f0                	mov    %esi,%eax
  800a54:	85 c9                	test   %ecx,%ecx
  800a56:	74 27                	je     800a7f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800a58:	83 e9 01             	sub    $0x1,%ecx
  800a5b:	74 1d                	je     800a7a <strlcpy+0x36>
  800a5d:	0f b6 1a             	movzbl (%edx),%ebx
  800a60:	84 db                	test   %bl,%bl
  800a62:	74 16                	je     800a7a <strlcpy+0x36>
			*dst++ = *src++;
  800a64:	88 18                	mov    %bl,(%eax)
  800a66:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a69:	83 e9 01             	sub    $0x1,%ecx
  800a6c:	74 0e                	je     800a7c <strlcpy+0x38>
			*dst++ = *src++;
  800a6e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a71:	0f b6 1a             	movzbl (%edx),%ebx
  800a74:	84 db                	test   %bl,%bl
  800a76:	75 ec                	jne    800a64 <strlcpy+0x20>
  800a78:	eb 02                	jmp    800a7c <strlcpy+0x38>
  800a7a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a7c:	c6 00 00             	movb   $0x0,(%eax)
  800a7f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800a81:	5b                   	pop    %ebx
  800a82:	5e                   	pop    %esi
  800a83:	5d                   	pop    %ebp
  800a84:	c3                   	ret    

00800a85 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a85:	55                   	push   %ebp
  800a86:	89 e5                	mov    %esp,%ebp
  800a88:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a8b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a8e:	0f b6 01             	movzbl (%ecx),%eax
  800a91:	84 c0                	test   %al,%al
  800a93:	74 15                	je     800aaa <strcmp+0x25>
  800a95:	3a 02                	cmp    (%edx),%al
  800a97:	75 11                	jne    800aaa <strcmp+0x25>
		p++, q++;
  800a99:	83 c1 01             	add    $0x1,%ecx
  800a9c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a9f:	0f b6 01             	movzbl (%ecx),%eax
  800aa2:	84 c0                	test   %al,%al
  800aa4:	74 04                	je     800aaa <strcmp+0x25>
  800aa6:	3a 02                	cmp    (%edx),%al
  800aa8:	74 ef                	je     800a99 <strcmp+0x14>
  800aaa:	0f b6 c0             	movzbl %al,%eax
  800aad:	0f b6 12             	movzbl (%edx),%edx
  800ab0:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ab2:	5d                   	pop    %ebp
  800ab3:	c3                   	ret    

00800ab4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ab4:	55                   	push   %ebp
  800ab5:	89 e5                	mov    %esp,%ebp
  800ab7:	53                   	push   %ebx
  800ab8:	8b 55 08             	mov    0x8(%ebp),%edx
  800abb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800abe:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800ac1:	85 c0                	test   %eax,%eax
  800ac3:	74 23                	je     800ae8 <strncmp+0x34>
  800ac5:	0f b6 1a             	movzbl (%edx),%ebx
  800ac8:	84 db                	test   %bl,%bl
  800aca:	74 25                	je     800af1 <strncmp+0x3d>
  800acc:	3a 19                	cmp    (%ecx),%bl
  800ace:	75 21                	jne    800af1 <strncmp+0x3d>
  800ad0:	83 e8 01             	sub    $0x1,%eax
  800ad3:	74 13                	je     800ae8 <strncmp+0x34>
		n--, p++, q++;
  800ad5:	83 c2 01             	add    $0x1,%edx
  800ad8:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800adb:	0f b6 1a             	movzbl (%edx),%ebx
  800ade:	84 db                	test   %bl,%bl
  800ae0:	74 0f                	je     800af1 <strncmp+0x3d>
  800ae2:	3a 19                	cmp    (%ecx),%bl
  800ae4:	74 ea                	je     800ad0 <strncmp+0x1c>
  800ae6:	eb 09                	jmp    800af1 <strncmp+0x3d>
  800ae8:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800aed:	5b                   	pop    %ebx
  800aee:	5d                   	pop    %ebp
  800aef:	90                   	nop
  800af0:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800af1:	0f b6 02             	movzbl (%edx),%eax
  800af4:	0f b6 11             	movzbl (%ecx),%edx
  800af7:	29 d0                	sub    %edx,%eax
  800af9:	eb f2                	jmp    800aed <strncmp+0x39>

00800afb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800afb:	55                   	push   %ebp
  800afc:	89 e5                	mov    %esp,%ebp
  800afe:	8b 45 08             	mov    0x8(%ebp),%eax
  800b01:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b05:	0f b6 10             	movzbl (%eax),%edx
  800b08:	84 d2                	test   %dl,%dl
  800b0a:	74 18                	je     800b24 <strchr+0x29>
		if (*s == c)
  800b0c:	38 ca                	cmp    %cl,%dl
  800b0e:	75 0a                	jne    800b1a <strchr+0x1f>
  800b10:	eb 17                	jmp    800b29 <strchr+0x2e>
  800b12:	38 ca                	cmp    %cl,%dl
  800b14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800b18:	74 0f                	je     800b29 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b1a:	83 c0 01             	add    $0x1,%eax
  800b1d:	0f b6 10             	movzbl (%eax),%edx
  800b20:	84 d2                	test   %dl,%dl
  800b22:	75 ee                	jne    800b12 <strchr+0x17>
  800b24:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800b29:	5d                   	pop    %ebp
  800b2a:	c3                   	ret    

00800b2b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b2b:	55                   	push   %ebp
  800b2c:	89 e5                	mov    %esp,%ebp
  800b2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b31:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b35:	0f b6 10             	movzbl (%eax),%edx
  800b38:	84 d2                	test   %dl,%dl
  800b3a:	74 18                	je     800b54 <strfind+0x29>
		if (*s == c)
  800b3c:	38 ca                	cmp    %cl,%dl
  800b3e:	75 0a                	jne    800b4a <strfind+0x1f>
  800b40:	eb 12                	jmp    800b54 <strfind+0x29>
  800b42:	38 ca                	cmp    %cl,%dl
  800b44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800b48:	74 0a                	je     800b54 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b4a:	83 c0 01             	add    $0x1,%eax
  800b4d:	0f b6 10             	movzbl (%eax),%edx
  800b50:	84 d2                	test   %dl,%dl
  800b52:	75 ee                	jne    800b42 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800b54:	5d                   	pop    %ebp
  800b55:	c3                   	ret    

00800b56 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b56:	55                   	push   %ebp
  800b57:	89 e5                	mov    %esp,%ebp
  800b59:	83 ec 0c             	sub    $0xc,%esp
  800b5c:	89 1c 24             	mov    %ebx,(%esp)
  800b5f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b63:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800b67:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b6a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b6d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b70:	85 c9                	test   %ecx,%ecx
  800b72:	74 30                	je     800ba4 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b74:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b7a:	75 25                	jne    800ba1 <memset+0x4b>
  800b7c:	f6 c1 03             	test   $0x3,%cl
  800b7f:	75 20                	jne    800ba1 <memset+0x4b>
		c &= 0xFF;
  800b81:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b84:	89 d3                	mov    %edx,%ebx
  800b86:	c1 e3 08             	shl    $0x8,%ebx
  800b89:	89 d6                	mov    %edx,%esi
  800b8b:	c1 e6 18             	shl    $0x18,%esi
  800b8e:	89 d0                	mov    %edx,%eax
  800b90:	c1 e0 10             	shl    $0x10,%eax
  800b93:	09 f0                	or     %esi,%eax
  800b95:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800b97:	09 d8                	or     %ebx,%eax
  800b99:	c1 e9 02             	shr    $0x2,%ecx
  800b9c:	fc                   	cld    
  800b9d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b9f:	eb 03                	jmp    800ba4 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ba1:	fc                   	cld    
  800ba2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ba4:	89 f8                	mov    %edi,%eax
  800ba6:	8b 1c 24             	mov    (%esp),%ebx
  800ba9:	8b 74 24 04          	mov    0x4(%esp),%esi
  800bad:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800bb1:	89 ec                	mov    %ebp,%esp
  800bb3:	5d                   	pop    %ebp
  800bb4:	c3                   	ret    

00800bb5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bb5:	55                   	push   %ebp
  800bb6:	89 e5                	mov    %esp,%ebp
  800bb8:	83 ec 08             	sub    $0x8,%esp
  800bbb:	89 34 24             	mov    %esi,(%esp)
  800bbe:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800bc2:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800bc8:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800bcb:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800bcd:	39 c6                	cmp    %eax,%esi
  800bcf:	73 35                	jae    800c06 <memmove+0x51>
  800bd1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bd4:	39 d0                	cmp    %edx,%eax
  800bd6:	73 2e                	jae    800c06 <memmove+0x51>
		s += n;
		d += n;
  800bd8:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bda:	f6 c2 03             	test   $0x3,%dl
  800bdd:	75 1b                	jne    800bfa <memmove+0x45>
  800bdf:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800be5:	75 13                	jne    800bfa <memmove+0x45>
  800be7:	f6 c1 03             	test   $0x3,%cl
  800bea:	75 0e                	jne    800bfa <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800bec:	83 ef 04             	sub    $0x4,%edi
  800bef:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bf2:	c1 e9 02             	shr    $0x2,%ecx
  800bf5:	fd                   	std    
  800bf6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bf8:	eb 09                	jmp    800c03 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800bfa:	83 ef 01             	sub    $0x1,%edi
  800bfd:	8d 72 ff             	lea    -0x1(%edx),%esi
  800c00:	fd                   	std    
  800c01:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c03:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c04:	eb 20                	jmp    800c26 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c06:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c0c:	75 15                	jne    800c23 <memmove+0x6e>
  800c0e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c14:	75 0d                	jne    800c23 <memmove+0x6e>
  800c16:	f6 c1 03             	test   $0x3,%cl
  800c19:	75 08                	jne    800c23 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800c1b:	c1 e9 02             	shr    $0x2,%ecx
  800c1e:	fc                   	cld    
  800c1f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c21:	eb 03                	jmp    800c26 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c23:	fc                   	cld    
  800c24:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c26:	8b 34 24             	mov    (%esp),%esi
  800c29:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800c2d:	89 ec                	mov    %ebp,%esp
  800c2f:	5d                   	pop    %ebp
  800c30:	c3                   	ret    

00800c31 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800c31:	55                   	push   %ebp
  800c32:	89 e5                	mov    %esp,%ebp
  800c34:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c37:	8b 45 10             	mov    0x10(%ebp),%eax
  800c3a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c3e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c41:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c45:	8b 45 08             	mov    0x8(%ebp),%eax
  800c48:	89 04 24             	mov    %eax,(%esp)
  800c4b:	e8 65 ff ff ff       	call   800bb5 <memmove>
}
  800c50:	c9                   	leave  
  800c51:	c3                   	ret    

00800c52 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c52:	55                   	push   %ebp
  800c53:	89 e5                	mov    %esp,%ebp
  800c55:	57                   	push   %edi
  800c56:	56                   	push   %esi
  800c57:	53                   	push   %ebx
  800c58:	8b 75 08             	mov    0x8(%ebp),%esi
  800c5b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800c5e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c61:	85 c9                	test   %ecx,%ecx
  800c63:	74 36                	je     800c9b <memcmp+0x49>
		if (*s1 != *s2)
  800c65:	0f b6 06             	movzbl (%esi),%eax
  800c68:	0f b6 1f             	movzbl (%edi),%ebx
  800c6b:	38 d8                	cmp    %bl,%al
  800c6d:	74 20                	je     800c8f <memcmp+0x3d>
  800c6f:	eb 14                	jmp    800c85 <memcmp+0x33>
  800c71:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800c76:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800c7b:	83 c2 01             	add    $0x1,%edx
  800c7e:	83 e9 01             	sub    $0x1,%ecx
  800c81:	38 d8                	cmp    %bl,%al
  800c83:	74 12                	je     800c97 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800c85:	0f b6 c0             	movzbl %al,%eax
  800c88:	0f b6 db             	movzbl %bl,%ebx
  800c8b:	29 d8                	sub    %ebx,%eax
  800c8d:	eb 11                	jmp    800ca0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c8f:	83 e9 01             	sub    $0x1,%ecx
  800c92:	ba 00 00 00 00       	mov    $0x0,%edx
  800c97:	85 c9                	test   %ecx,%ecx
  800c99:	75 d6                	jne    800c71 <memcmp+0x1f>
  800c9b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800ca0:	5b                   	pop    %ebx
  800ca1:	5e                   	pop    %esi
  800ca2:	5f                   	pop    %edi
  800ca3:	5d                   	pop    %ebp
  800ca4:	c3                   	ret    

00800ca5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ca5:	55                   	push   %ebp
  800ca6:	89 e5                	mov    %esp,%ebp
  800ca8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800cab:	89 c2                	mov    %eax,%edx
  800cad:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800cb0:	39 d0                	cmp    %edx,%eax
  800cb2:	73 15                	jae    800cc9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cb4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800cb8:	38 08                	cmp    %cl,(%eax)
  800cba:	75 06                	jne    800cc2 <memfind+0x1d>
  800cbc:	eb 0b                	jmp    800cc9 <memfind+0x24>
  800cbe:	38 08                	cmp    %cl,(%eax)
  800cc0:	74 07                	je     800cc9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cc2:	83 c0 01             	add    $0x1,%eax
  800cc5:	39 c2                	cmp    %eax,%edx
  800cc7:	77 f5                	ja     800cbe <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800cc9:	5d                   	pop    %ebp
  800cca:	c3                   	ret    

00800ccb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ccb:	55                   	push   %ebp
  800ccc:	89 e5                	mov    %esp,%ebp
  800cce:	57                   	push   %edi
  800ccf:	56                   	push   %esi
  800cd0:	53                   	push   %ebx
  800cd1:	83 ec 04             	sub    $0x4,%esp
  800cd4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cda:	0f b6 02             	movzbl (%edx),%eax
  800cdd:	3c 20                	cmp    $0x20,%al
  800cdf:	74 04                	je     800ce5 <strtol+0x1a>
  800ce1:	3c 09                	cmp    $0x9,%al
  800ce3:	75 0e                	jne    800cf3 <strtol+0x28>
		s++;
  800ce5:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ce8:	0f b6 02             	movzbl (%edx),%eax
  800ceb:	3c 20                	cmp    $0x20,%al
  800ced:	74 f6                	je     800ce5 <strtol+0x1a>
  800cef:	3c 09                	cmp    $0x9,%al
  800cf1:	74 f2                	je     800ce5 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800cf3:	3c 2b                	cmp    $0x2b,%al
  800cf5:	75 0c                	jne    800d03 <strtol+0x38>
		s++;
  800cf7:	83 c2 01             	add    $0x1,%edx
  800cfa:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800d01:	eb 15                	jmp    800d18 <strtol+0x4d>
	else if (*s == '-')
  800d03:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800d0a:	3c 2d                	cmp    $0x2d,%al
  800d0c:	75 0a                	jne    800d18 <strtol+0x4d>
		s++, neg = 1;
  800d0e:	83 c2 01             	add    $0x1,%edx
  800d11:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d18:	85 db                	test   %ebx,%ebx
  800d1a:	0f 94 c0             	sete   %al
  800d1d:	74 05                	je     800d24 <strtol+0x59>
  800d1f:	83 fb 10             	cmp    $0x10,%ebx
  800d22:	75 18                	jne    800d3c <strtol+0x71>
  800d24:	80 3a 30             	cmpb   $0x30,(%edx)
  800d27:	75 13                	jne    800d3c <strtol+0x71>
  800d29:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d2d:	8d 76 00             	lea    0x0(%esi),%esi
  800d30:	75 0a                	jne    800d3c <strtol+0x71>
		s += 2, base = 16;
  800d32:	83 c2 02             	add    $0x2,%edx
  800d35:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d3a:	eb 15                	jmp    800d51 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d3c:	84 c0                	test   %al,%al
  800d3e:	66 90                	xchg   %ax,%ax
  800d40:	74 0f                	je     800d51 <strtol+0x86>
  800d42:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800d47:	80 3a 30             	cmpb   $0x30,(%edx)
  800d4a:	75 05                	jne    800d51 <strtol+0x86>
		s++, base = 8;
  800d4c:	83 c2 01             	add    $0x1,%edx
  800d4f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d51:	b8 00 00 00 00       	mov    $0x0,%eax
  800d56:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d58:	0f b6 0a             	movzbl (%edx),%ecx
  800d5b:	89 cf                	mov    %ecx,%edi
  800d5d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d60:	80 fb 09             	cmp    $0x9,%bl
  800d63:	77 08                	ja     800d6d <strtol+0xa2>
			dig = *s - '0';
  800d65:	0f be c9             	movsbl %cl,%ecx
  800d68:	83 e9 30             	sub    $0x30,%ecx
  800d6b:	eb 1e                	jmp    800d8b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800d6d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800d70:	80 fb 19             	cmp    $0x19,%bl
  800d73:	77 08                	ja     800d7d <strtol+0xb2>
			dig = *s - 'a' + 10;
  800d75:	0f be c9             	movsbl %cl,%ecx
  800d78:	83 e9 57             	sub    $0x57,%ecx
  800d7b:	eb 0e                	jmp    800d8b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800d7d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800d80:	80 fb 19             	cmp    $0x19,%bl
  800d83:	77 15                	ja     800d9a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800d85:	0f be c9             	movsbl %cl,%ecx
  800d88:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d8b:	39 f1                	cmp    %esi,%ecx
  800d8d:	7d 0b                	jge    800d9a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800d8f:	83 c2 01             	add    $0x1,%edx
  800d92:	0f af c6             	imul   %esi,%eax
  800d95:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800d98:	eb be                	jmp    800d58 <strtol+0x8d>
  800d9a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800d9c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800da0:	74 05                	je     800da7 <strtol+0xdc>
		*endptr = (char *) s;
  800da2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800da5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800da7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800dab:	74 04                	je     800db1 <strtol+0xe6>
  800dad:	89 c8                	mov    %ecx,%eax
  800daf:	f7 d8                	neg    %eax
}
  800db1:	83 c4 04             	add    $0x4,%esp
  800db4:	5b                   	pop    %ebx
  800db5:	5e                   	pop    %esi
  800db6:	5f                   	pop    %edi
  800db7:	5d                   	pop    %ebp
  800db8:	c3                   	ret    
  800db9:	00 00                	add    %al,(%eax)
	...

00800dbc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800dbc:	55                   	push   %ebp
  800dbd:	89 e5                	mov    %esp,%ebp
  800dbf:	83 ec 08             	sub    $0x8,%esp
  800dc2:	89 1c 24             	mov    %ebx,(%esp)
  800dc5:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800dc9:	b8 00 00 00 00       	mov    $0x0,%eax
  800dce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd1:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd4:	89 c3                	mov    %eax,%ebx
  800dd6:	89 c7                	mov    %eax,%edi
  800dd8:	51                   	push   %ecx
  800dd9:	52                   	push   %edx
  800dda:	53                   	push   %ebx
  800ddb:	54                   	push   %esp
  800ddc:	55                   	push   %ebp
  800ddd:	56                   	push   %esi
  800dde:	57                   	push   %edi
  800ddf:	5f                   	pop    %edi
  800de0:	5e                   	pop    %esi
  800de1:	5d                   	pop    %ebp
  800de2:	5c                   	pop    %esp
  800de3:	5b                   	pop    %ebx
  800de4:	5a                   	pop    %edx
  800de5:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800de6:	8b 1c 24             	mov    (%esp),%ebx
  800de9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ded:	89 ec                	mov    %ebp,%esp
  800def:	5d                   	pop    %ebp
  800df0:	c3                   	ret    

00800df1 <sys_cgetc>:

int
sys_cgetc(void)
{
  800df1:	55                   	push   %ebp
  800df2:	89 e5                	mov    %esp,%ebp
  800df4:	83 ec 08             	sub    $0x8,%esp
  800df7:	89 1c 24             	mov    %ebx,(%esp)
  800dfa:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800dfe:	ba 00 00 00 00       	mov    $0x0,%edx
  800e03:	b8 01 00 00 00       	mov    $0x1,%eax
  800e08:	89 d1                	mov    %edx,%ecx
  800e0a:	89 d3                	mov    %edx,%ebx
  800e0c:	89 d7                	mov    %edx,%edi
  800e0e:	51                   	push   %ecx
  800e0f:	52                   	push   %edx
  800e10:	53                   	push   %ebx
  800e11:	54                   	push   %esp
  800e12:	55                   	push   %ebp
  800e13:	56                   	push   %esi
  800e14:	57                   	push   %edi
  800e15:	5f                   	pop    %edi
  800e16:	5e                   	pop    %esi
  800e17:	5d                   	pop    %ebp
  800e18:	5c                   	pop    %esp
  800e19:	5b                   	pop    %ebx
  800e1a:	5a                   	pop    %edx
  800e1b:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e1c:	8b 1c 24             	mov    (%esp),%ebx
  800e1f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e23:	89 ec                	mov    %ebp,%esp
  800e25:	5d                   	pop    %ebp
  800e26:	c3                   	ret    

00800e27 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800e27:	55                   	push   %ebp
  800e28:	89 e5                	mov    %esp,%ebp
  800e2a:	83 ec 08             	sub    $0x8,%esp
  800e2d:	89 1c 24             	mov    %ebx,(%esp)
  800e30:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e34:	ba 00 00 00 00       	mov    $0x0,%edx
  800e39:	b8 02 00 00 00       	mov    $0x2,%eax
  800e3e:	89 d1                	mov    %edx,%ecx
  800e40:	89 d3                	mov    %edx,%ebx
  800e42:	89 d7                	mov    %edx,%edi
  800e44:	51                   	push   %ecx
  800e45:	52                   	push   %edx
  800e46:	53                   	push   %ebx
  800e47:	54                   	push   %esp
  800e48:	55                   	push   %ebp
  800e49:	56                   	push   %esi
  800e4a:	57                   	push   %edi
  800e4b:	5f                   	pop    %edi
  800e4c:	5e                   	pop    %esi
  800e4d:	5d                   	pop    %ebp
  800e4e:	5c                   	pop    %esp
  800e4f:	5b                   	pop    %ebx
  800e50:	5a                   	pop    %edx
  800e51:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e52:	8b 1c 24             	mov    (%esp),%ebx
  800e55:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e59:	89 ec                	mov    %ebp,%esp
  800e5b:	5d                   	pop    %ebp
  800e5c:	c3                   	ret    

00800e5d <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800e5d:	55                   	push   %ebp
  800e5e:	89 e5                	mov    %esp,%ebp
  800e60:	83 ec 08             	sub    $0x8,%esp
  800e63:	89 1c 24             	mov    %ebx,(%esp)
  800e66:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e6a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e6f:	b8 04 00 00 00       	mov    $0x4,%eax
  800e74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e77:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7a:	89 df                	mov    %ebx,%edi
  800e7c:	51                   	push   %ecx
  800e7d:	52                   	push   %edx
  800e7e:	53                   	push   %ebx
  800e7f:	54                   	push   %esp
  800e80:	55                   	push   %ebp
  800e81:	56                   	push   %esi
  800e82:	57                   	push   %edi
  800e83:	5f                   	pop    %edi
  800e84:	5e                   	pop    %esi
  800e85:	5d                   	pop    %ebp
  800e86:	5c                   	pop    %esp
  800e87:	5b                   	pop    %ebx
  800e88:	5a                   	pop    %edx
  800e89:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800e8a:	8b 1c 24             	mov    (%esp),%ebx
  800e8d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e91:	89 ec                	mov    %ebp,%esp
  800e93:	5d                   	pop    %ebp
  800e94:	c3                   	ret    

00800e95 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  800e95:	55                   	push   %ebp
  800e96:	89 e5                	mov    %esp,%ebp
  800e98:	83 ec 08             	sub    $0x8,%esp
  800e9b:	89 1c 24             	mov    %ebx,(%esp)
  800e9e:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800ea2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ea7:	b8 05 00 00 00       	mov    $0x5,%eax
  800eac:	8b 55 08             	mov    0x8(%ebp),%edx
  800eaf:	89 cb                	mov    %ecx,%ebx
  800eb1:	89 cf                	mov    %ecx,%edi
  800eb3:	51                   	push   %ecx
  800eb4:	52                   	push   %edx
  800eb5:	53                   	push   %ebx
  800eb6:	54                   	push   %esp
  800eb7:	55                   	push   %ebp
  800eb8:	56                   	push   %esi
  800eb9:	57                   	push   %edi
  800eba:	5f                   	pop    %edi
  800ebb:	5e                   	pop    %esi
  800ebc:	5d                   	pop    %ebp
  800ebd:	5c                   	pop    %esp
  800ebe:	5b                   	pop    %ebx
  800ebf:	5a                   	pop    %edx
  800ec0:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800ec1:	8b 1c 24             	mov    (%esp),%ebx
  800ec4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ec8:	89 ec                	mov    %ebp,%esp
  800eca:	5d                   	pop    %ebp
  800ecb:	c3                   	ret    

00800ecc <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800ecc:	55                   	push   %ebp
  800ecd:	89 e5                	mov    %esp,%ebp
  800ecf:	83 ec 28             	sub    $0x28,%esp
  800ed2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800ed5:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800ed8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800edd:	b8 03 00 00 00       	mov    $0x3,%eax
  800ee2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee5:	89 cb                	mov    %ecx,%ebx
  800ee7:	89 cf                	mov    %ecx,%edi
  800ee9:	51                   	push   %ecx
  800eea:	52                   	push   %edx
  800eeb:	53                   	push   %ebx
  800eec:	54                   	push   %esp
  800eed:	55                   	push   %ebp
  800eee:	56                   	push   %esi
  800eef:	57                   	push   %edi
  800ef0:	5f                   	pop    %edi
  800ef1:	5e                   	pop    %esi
  800ef2:	5d                   	pop    %ebp
  800ef3:	5c                   	pop    %esp
  800ef4:	5b                   	pop    %ebx
  800ef5:	5a                   	pop    %edx
  800ef6:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800ef7:	85 c0                	test   %eax,%eax
  800ef9:	7e 28                	jle    800f23 <sys_env_destroy+0x57>
		panic("syscall %d returned %d (> 0)", num, ret);
  800efb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eff:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800f06:	00 
  800f07:	c7 44 24 08 b0 14 80 	movl   $0x8014b0,0x8(%esp)
  800f0e:	00 
  800f0f:	c7 44 24 04 26 00 00 	movl   $0x26,0x4(%esp)
  800f16:	00 
  800f17:	c7 04 24 cd 14 80 00 	movl   $0x8014cd,(%esp)
  800f1e:	e8 0d 00 00 00       	call   800f30 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800f23:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800f26:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f29:	89 ec                	mov    %ebp,%esp
  800f2b:	5d                   	pop    %ebp
  800f2c:	c3                   	ret    
  800f2d:	00 00                	add    %al,(%eax)
	...

00800f30 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800f30:	55                   	push   %ebp
  800f31:	89 e5                	mov    %esp,%ebp
  800f33:	56                   	push   %esi
  800f34:	53                   	push   %ebx
  800f35:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  800f38:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  800f3b:	a1 08 20 80 00       	mov    0x802008,%eax
  800f40:	85 c0                	test   %eax,%eax
  800f42:	74 10                	je     800f54 <_panic+0x24>
		cprintf("%s: ", argv0);
  800f44:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f48:	c7 04 24 db 14 80 00 	movl   $0x8014db,(%esp)
  800f4f:	e8 ad f1 ff ff       	call   800101 <cprintf>
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800f54:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800f5a:	e8 c8 fe ff ff       	call   800e27 <sys_getenvid>
  800f5f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f62:	89 54 24 10          	mov    %edx,0x10(%esp)
  800f66:	8b 55 08             	mov    0x8(%ebp),%edx
  800f69:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f6d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f71:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f75:	c7 04 24 e0 14 80 00 	movl   $0x8014e0,(%esp)
  800f7c:	e8 80 f1 ff ff       	call   800101 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800f81:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f85:	8b 45 10             	mov    0x10(%ebp),%eax
  800f88:	89 04 24             	mov    %eax,(%esp)
  800f8b:	e8 10 f1 ff ff       	call   8000a0 <vcprintf>
	cprintf("\n");
  800f90:	c7 04 24 24 12 80 00 	movl   $0x801224,(%esp)
  800f97:	e8 65 f1 ff ff       	call   800101 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800f9c:	cc                   	int3   
  800f9d:	eb fd                	jmp    800f9c <_panic+0x6c>
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
