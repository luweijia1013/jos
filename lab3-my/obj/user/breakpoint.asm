
obj/user/breakpoint:     file format elf32-i386


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
  80002c:	e8 57 00 00 00       	call   800088 <libmain>
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
  800037:	83 ec 28             	sub    $0x28,%esp
	int a;
	a=10;
  80003a:	c7 45 f4 0a 00 00 00 	movl   $0xa,-0xc(%ebp)
	cprintf("At first , a equals %d\n",a);
  800041:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
  800048:	00 
  800049:	c7 04 24 48 12 80 00 	movl   $0x801248,(%esp)
  800050:	e8 e0 00 00 00       	call   800135 <cprintf>
	cprintf("&a equals 0x%x\n",&a);
  800055:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800058:	89 44 24 04          	mov    %eax,0x4(%esp)
  80005c:	c7 04 24 60 12 80 00 	movl   $0x801260,(%esp)
  800063:	e8 cd 00 00 00       	call   800135 <cprintf>
	asm volatile("int $3");
  800068:	cc                   	int3   
	// Try single-step here
	a=20;
  800069:	c7 45 f4 14 00 00 00 	movl   $0x14,-0xc(%ebp)
	cprintf("Finally , a equals %d\n",a);
  800070:	c7 44 24 04 14 00 00 	movl   $0x14,0x4(%esp)
  800077:	00 
  800078:	c7 04 24 70 12 80 00 	movl   $0x801270,(%esp)
  80007f:	e8 b1 00 00 00       	call   800135 <cprintf>
}
  800084:	c9                   	leave  
  800085:	c3                   	ret    
	...

00800088 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800088:	55                   	push   %ebp
  800089:	89 e5                	mov    %esp,%ebp
  80008b:	83 ec 18             	sub    $0x18,%esp
  80008e:	8b 45 08             	mov    0x8(%ebp),%eax
  800091:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800094:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  80009b:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80009e:	85 c0                	test   %eax,%eax
  8000a0:	7e 08                	jle    8000aa <libmain+0x22>
		binaryname = argv[0];
  8000a2:	8b 0a                	mov    (%edx),%ecx
  8000a4:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  8000aa:	89 54 24 04          	mov    %edx,0x4(%esp)
  8000ae:	89 04 24             	mov    %eax,(%esp)
  8000b1:	e8 7e ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000b6:	e8 05 00 00 00       	call   8000c0 <exit>
}
  8000bb:	c9                   	leave  
  8000bc:	c3                   	ret    
  8000bd:	00 00                	add    %al,(%eax)
	...

008000c0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000c6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000cd:	e8 3a 0e 00 00       	call   800f0c <sys_env_destroy>
}
  8000d2:	c9                   	leave  
  8000d3:	c3                   	ret    

008000d4 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8000d4:	55                   	push   %ebp
  8000d5:	89 e5                	mov    %esp,%ebp
  8000d7:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8000dd:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8000e4:	00 00 00 
	b.cnt = 0;
  8000e7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8000ee:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8000f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000f4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8000fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000ff:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800105:	89 44 24 04          	mov    %eax,0x4(%esp)
  800109:	c7 04 24 4f 01 80 00 	movl   $0x80014f,(%esp)
  800110:	e8 0b 03 00 00       	call   800420 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800115:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80011b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80011f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800125:	89 04 24             	mov    %eax,(%esp)
  800128:	e8 cf 0c 00 00       	call   800dfc <sys_cputs>

	return b.cnt;
}
  80012d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800133:	c9                   	leave  
  800134:	c3                   	ret    

00800135 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800135:	55                   	push   %ebp
  800136:	89 e5                	mov    %esp,%ebp
  800138:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  80013b:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  80013e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800142:	8b 45 08             	mov    0x8(%ebp),%eax
  800145:	89 04 24             	mov    %eax,(%esp)
  800148:	e8 87 ff ff ff       	call   8000d4 <vcprintf>
	va_end(ap);

	return cnt;
}
  80014d:	c9                   	leave  
  80014e:	c3                   	ret    

0080014f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80014f:	55                   	push   %ebp
  800150:	89 e5                	mov    %esp,%ebp
  800152:	53                   	push   %ebx
  800153:	83 ec 14             	sub    $0x14,%esp
  800156:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800159:	8b 03                	mov    (%ebx),%eax
  80015b:	8b 55 08             	mov    0x8(%ebp),%edx
  80015e:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800162:	83 c0 01             	add    $0x1,%eax
  800165:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800167:	3d ff 00 00 00       	cmp    $0xff,%eax
  80016c:	75 19                	jne    800187 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80016e:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800175:	00 
  800176:	8d 43 08             	lea    0x8(%ebx),%eax
  800179:	89 04 24             	mov    %eax,(%esp)
  80017c:	e8 7b 0c 00 00       	call   800dfc <sys_cputs>
		b->idx = 0;
  800181:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800187:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80018b:	83 c4 14             	add    $0x14,%esp
  80018e:	5b                   	pop    %ebx
  80018f:	5d                   	pop    %ebp
  800190:	c3                   	ret    
	...

008001a0 <printnum_nopad>:

/*
* help function added by Lu to print only the num;
*/
static void printnum_nopad(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int *num_len){
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	83 ec 48             	sub    $0x48,%esp
  8001a6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8001a9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8001ac:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8001af:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8001b2:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8001b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001bb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8001be:	8b 45 10             	mov    0x10(%ebp),%eax
  8001c1:	8b 7d 14             	mov    0x14(%ebp),%edi
	if(num >= base){
  8001c4:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8001cc:	39 f2                	cmp    %esi,%edx
  8001ce:	72 07                	jb     8001d7 <printnum_nopad+0x37>
  8001d0:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8001d3:	39 c8                	cmp    %ecx,%eax
  8001d5:	77 54                	ja     80022b <printnum_nopad+0x8b>
		printnum_nopad(putch, putdat, num / base, base, num_len);
  8001d7:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8001db:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001df:	8b 44 24 08          	mov    0x8(%esp),%eax
  8001e3:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8001e7:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8001ea:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8001ed:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8001f0:	89 54 24 08          	mov    %edx,0x8(%esp)
  8001f4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001fb:	00 
  8001fc:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8001ff:	89 0c 24             	mov    %ecx,(%esp)
  800202:	89 74 24 04          	mov    %esi,0x4(%esp)
  800206:	e8 d5 0d 00 00       	call   800fe0 <__udivdi3>
  80020b:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80020e:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800211:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800215:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800219:	89 04 24             	mov    %eax,(%esp)
  80021c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800220:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800223:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800226:	e8 75 ff ff ff       	call   8001a0 <printnum_nopad>
	}
	*num_len += 1 ;
  80022b:	83 07 01             	addl   $0x1,(%edi)
	putch("0123456789abcdef"[num % base], putdat);
  80022e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800231:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800235:	8b 04 24             	mov    (%esp),%eax
  800238:	8b 54 24 04          	mov    0x4(%esp),%edx
  80023c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80023f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800242:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800245:	89 54 24 08          	mov    %edx,0x8(%esp)
  800249:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800250:	00 
  800251:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800254:	89 0c 24             	mov    %ecx,(%esp)
  800257:	89 74 24 04          	mov    %esi,0x4(%esp)
  80025b:	e8 b0 0e 00 00       	call   801110 <__umoddi3>
  800260:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800263:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800267:	0f be 80 91 12 80 00 	movsbl 0x801291(%eax),%eax
  80026e:	89 04 24             	mov    %eax,(%esp)
  800271:	ff 55 d4             	call   *-0x2c(%ebp)
}
  800274:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800277:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80027a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80027d:	89 ec                	mov    %ebp,%esp
  80027f:	5d                   	pop    %ebp
  800280:	c3                   	ret    

00800281 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800281:	55                   	push   %ebp
  800282:	89 e5                	mov    %esp,%ebp
  800284:	57                   	push   %edi
  800285:	56                   	push   %esi
  800286:	53                   	push   %ebx
  800287:	83 ec 5c             	sub    $0x5c,%esp
  80028a:	89 c7                	mov    %eax,%edi
  80028c:	89 d6                	mov    %edx,%esi
  80028e:	8b 45 08             	mov    0x8(%ebp),%eax
  800291:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800294:	8b 55 0c             	mov    0xc(%ebp),%edx
  800297:	89 55 cc             	mov    %edx,-0x34(%ebp)
  80029a:	8b 45 10             	mov    0x10(%ebp),%eax
  80029d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	if(padc == '-'){
  8002a0:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  8002a4:	75 4c                	jne    8002f2 <printnum+0x71>
		int num_len = 0;
  8002a6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		printnum_nopad(putch, putdat, num, base, &num_len);
  8002ad:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8002b0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002b4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b8:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8002bb:	89 0c 24             	mov    %ecx,(%esp)
  8002be:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8002c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c5:	89 f2                	mov    %esi,%edx
  8002c7:	89 f8                	mov    %edi,%eax
  8002c9:	e8 d2 fe ff ff       	call   8001a0 <printnum_nopad>
		width -= num_len;
  8002ce:	2b 5d e4             	sub    -0x1c(%ebp),%ebx
		while (width-- > 0)
  8002d1:	85 db                	test   %ebx,%ebx
  8002d3:	0f 8e e8 00 00 00    	jle    8003c1 <printnum+0x140>
			putch(' ', putdat);
  8002d9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002dd:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8002e4:	ff d7                	call   *%edi
  8002e6:	83 eb 01             	sub    $0x1,%ebx
	// your code here:
	if(padc == '-'){
		int num_len = 0;
		printnum_nopad(putch, putdat, num, base, &num_len);
		width -= num_len;
		while (width-- > 0)
  8002e9:	85 db                	test   %ebx,%ebx
  8002eb:	7f ec                	jg     8002d9 <printnum+0x58>
  8002ed:	e9 cf 00 00 00       	jmp    8003c1 <printnum+0x140>
			putch(' ', putdat);
	}
	else{
		// first recursively print all preceding (more significant) digits
		if (num >= base) {
  8002f2:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8002f5:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8002f9:	77 19                	ja     800314 <printnum+0x93>
  8002fb:	90                   	nop
  8002fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800300:	72 05                	jb     800307 <printnum+0x86>
  800302:	39 45 c8             	cmp    %eax,-0x38(%ebp)
  800305:	73 0d                	jae    800314 <printnum+0x93>
			printnum(putch, putdat, num / base, base, width - 1, padc);
		} else {
			// print any needed pad characters before first digit
			while (--width > 0)
  800307:	83 eb 01             	sub    $0x1,%ebx
  80030a:	85 db                	test   %ebx,%ebx
  80030c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800310:	7f 63                	jg     800375 <printnum+0xf4>
  800312:	eb 74                	jmp    800388 <printnum+0x107>
			putch(' ', putdat);
	}
	else{
		// first recursively print all preceding (more significant) digits
		if (num >= base) {
			printnum(putch, putdat, num / base, base, width - 1, padc);
  800314:	8b 55 18             	mov    0x18(%ebp),%edx
  800317:	89 54 24 10          	mov    %edx,0x10(%esp)
  80031b:	83 eb 01             	sub    $0x1,%ebx
  80031e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800322:	89 44 24 08          	mov    %eax,0x8(%esp)
  800326:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  80032a:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80032e:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800331:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800334:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  800337:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80033b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800342:	00 
  800343:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800346:	89 04 24             	mov    %eax,(%esp)
  800349:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80034c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800350:	e8 8b 0c 00 00       	call   800fe0 <__udivdi3>
  800355:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800358:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80035b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80035f:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800363:	89 04 24             	mov    %eax,(%esp)
  800366:	89 54 24 04          	mov    %edx,0x4(%esp)
  80036a:	89 f2                	mov    %esi,%edx
  80036c:	89 f8                	mov    %edi,%eax
  80036e:	e8 0e ff ff ff       	call   800281 <printnum>
  800373:	eb 13                	jmp    800388 <printnum+0x107>
		} else {
			// print any needed pad characters before first digit
			while (--width > 0)
				putch(padc, putdat);
  800375:	89 74 24 04          	mov    %esi,0x4(%esp)
  800379:	8b 45 18             	mov    0x18(%ebp),%eax
  80037c:	89 04 24             	mov    %eax,(%esp)
  80037f:	ff d7                	call   *%edi
		// first recursively print all preceding (more significant) digits
		if (num >= base) {
			printnum(putch, putdat, num / base, base, width - 1, padc);
		} else {
			// print any needed pad characters before first digit
			while (--width > 0)
  800381:	83 eb 01             	sub    $0x1,%ebx
  800384:	85 db                	test   %ebx,%ebx
  800386:	7f ed                	jg     800375 <printnum+0xf4>
				putch(padc, putdat);
		}

		// then print this (the least significant) digit
		putch("0123456789abcdef"[num % base], putdat);
  800388:	89 74 24 04          	mov    %esi,0x4(%esp)
  80038c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800390:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800393:	89 54 24 08          	mov    %edx,0x8(%esp)
  800397:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80039e:	00 
  80039f:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8003a2:	89 0c 24             	mov    %ecx,(%esp)
  8003a5:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8003a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003ac:	e8 5f 0d 00 00       	call   801110 <__umoddi3>
  8003b1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003b5:	0f be 80 91 12 80 00 	movsbl 0x801291(%eax),%eax
  8003bc:	89 04 24             	mov    %eax,(%esp)
  8003bf:	ff d7                	call   *%edi
	}
	
}
  8003c1:	83 c4 5c             	add    $0x5c,%esp
  8003c4:	5b                   	pop    %ebx
  8003c5:	5e                   	pop    %esi
  8003c6:	5f                   	pop    %edi
  8003c7:	5d                   	pop    %ebp
  8003c8:	c3                   	ret    

008003c9 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003c9:	55                   	push   %ebp
  8003ca:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003cc:	83 fa 01             	cmp    $0x1,%edx
  8003cf:	7e 0e                	jle    8003df <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003d1:	8b 10                	mov    (%eax),%edx
  8003d3:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003d6:	89 08                	mov    %ecx,(%eax)
  8003d8:	8b 02                	mov    (%edx),%eax
  8003da:	8b 52 04             	mov    0x4(%edx),%edx
  8003dd:	eb 22                	jmp    800401 <getuint+0x38>
	else if (lflag)
  8003df:	85 d2                	test   %edx,%edx
  8003e1:	74 10                	je     8003f3 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003e3:	8b 10                	mov    (%eax),%edx
  8003e5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003e8:	89 08                	mov    %ecx,(%eax)
  8003ea:	8b 02                	mov    (%edx),%eax
  8003ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8003f1:	eb 0e                	jmp    800401 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003f3:	8b 10                	mov    (%eax),%edx
  8003f5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003f8:	89 08                	mov    %ecx,(%eax)
  8003fa:	8b 02                	mov    (%edx),%eax
  8003fc:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800401:	5d                   	pop    %ebp
  800402:	c3                   	ret    

00800403 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800403:	55                   	push   %ebp
  800404:	89 e5                	mov    %esp,%ebp
  800406:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800409:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80040d:	8b 10                	mov    (%eax),%edx
  80040f:	3b 50 04             	cmp    0x4(%eax),%edx
  800412:	73 0a                	jae    80041e <sprintputch+0x1b>
		*b->buf++ = ch;
  800414:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800417:	88 0a                	mov    %cl,(%edx)
  800419:	83 c2 01             	add    $0x1,%edx
  80041c:	89 10                	mov    %edx,(%eax)
}
  80041e:	5d                   	pop    %ebp
  80041f:	c3                   	ret    

00800420 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800420:	55                   	push   %ebp
  800421:	89 e5                	mov    %esp,%ebp
  800423:	57                   	push   %edi
  800424:	56                   	push   %esi
  800425:	53                   	push   %ebx
  800426:	83 ec 5c             	sub    $0x5c,%esp
  800429:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80042c:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80042f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800436:	eb 12                	jmp    80044a <vprintfmt+0x2a>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800438:	85 c0                	test   %eax,%eax
  80043a:	0f 84 c6 04 00 00    	je     800906 <vprintfmt+0x4e6>
				return;
			putch(ch, putdat);
  800440:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800444:	89 04 24             	mov    %eax,(%esp)
  800447:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80044a:	0f b6 03             	movzbl (%ebx),%eax
  80044d:	83 c3 01             	add    $0x1,%ebx
  800450:	83 f8 25             	cmp    $0x25,%eax
  800453:	75 e3                	jne    800438 <vprintfmt+0x18>
  800455:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  800459:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800460:	be ff ff ff ff       	mov    $0xffffffff,%esi
  800465:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  80046c:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800473:	eb 06                	jmp    80047b <vprintfmt+0x5b>
  800475:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  800479:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047b:	0f b6 0b             	movzbl (%ebx),%ecx
  80047e:	0f b6 d1             	movzbl %cl,%edx
  800481:	8d 43 01             	lea    0x1(%ebx),%eax
  800484:	83 e9 23             	sub    $0x23,%ecx
  800487:	80 f9 55             	cmp    $0x55,%cl
  80048a:	0f 87 58 04 00 00    	ja     8008e8 <vprintfmt+0x4c8>
  800490:	0f b6 c9             	movzbl %cl,%ecx
  800493:	ff 24 8d 9c 13 80 00 	jmp    *0x80139c(,%ecx,4)
  80049a:	c6 45 e0 2b          	movb   $0x2b,-0x20(%ebp)
  80049e:	eb d9                	jmp    800479 <vprintfmt+0x59>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004a0:	8d 72 d0             	lea    -0x30(%edx),%esi
				ch = *fmt;
  8004a3:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8004a6:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8004a9:	83 f9 09             	cmp    $0x9,%ecx
  8004ac:	76 08                	jbe    8004b6 <vprintfmt+0x96>
  8004ae:	eb 40                	jmp    8004f0 <vprintfmt+0xd0>
  8004b0:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
			goto reswitch;
  8004b4:	eb c3                	jmp    800479 <vprintfmt+0x59>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004b6:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  8004b9:	8d 0c b6             	lea    (%esi,%esi,4),%ecx
  8004bc:	8d 74 4a d0          	lea    -0x30(%edx,%ecx,2),%esi
				ch = *fmt;
  8004c0:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8004c3:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8004c6:	83 f9 09             	cmp    $0x9,%ecx
  8004c9:	76 eb                	jbe    8004b6 <vprintfmt+0x96>
  8004cb:	eb 23                	jmp    8004f0 <vprintfmt+0xd0>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004cd:	8b 55 14             	mov    0x14(%ebp),%edx
  8004d0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004d3:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004d6:	8b 32                	mov    (%edx),%esi
			goto process_precision;
  8004d8:	eb 16                	jmp    8004f0 <vprintfmt+0xd0>

		case '.':
			if (width < 0)
  8004da:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8004dd:	c1 fa 1f             	sar    $0x1f,%edx
  8004e0:	f7 d2                	not    %edx
  8004e2:	21 55 dc             	and    %edx,-0x24(%ebp)
  8004e5:	eb 92                	jmp    800479 <vprintfmt+0x59>
  8004e7:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8004ee:	eb 89                	jmp    800479 <vprintfmt+0x59>

		process_precision:
			if (width < 0)
  8004f0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004f4:	79 83                	jns    800479 <vprintfmt+0x59>
  8004f6:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8004f9:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8004fc:	e9 78 ff ff ff       	jmp    800479 <vprintfmt+0x59>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800501:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
			goto reswitch;
  800505:	e9 6f ff ff ff       	jmp    800479 <vprintfmt+0x59>
  80050a:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80050d:	8b 45 14             	mov    0x14(%ebp),%eax
  800510:	8d 50 04             	lea    0x4(%eax),%edx
  800513:	89 55 14             	mov    %edx,0x14(%ebp)
  800516:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80051a:	8b 00                	mov    (%eax),%eax
  80051c:	89 04 24             	mov    %eax,(%esp)
  80051f:	ff 55 08             	call   *0x8(%ebp)
  800522:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  800525:	e9 20 ff ff ff       	jmp    80044a <vprintfmt+0x2a>
  80052a:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80052d:	8b 45 14             	mov    0x14(%ebp),%eax
  800530:	8d 50 04             	lea    0x4(%eax),%edx
  800533:	89 55 14             	mov    %edx,0x14(%ebp)
  800536:	8b 00                	mov    (%eax),%eax
  800538:	89 c2                	mov    %eax,%edx
  80053a:	c1 fa 1f             	sar    $0x1f,%edx
  80053d:	31 d0                	xor    %edx,%eax
  80053f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800541:	83 f8 06             	cmp    $0x6,%eax
  800544:	7f 0b                	jg     800551 <vprintfmt+0x131>
  800546:	8b 14 85 f4 14 80 00 	mov    0x8014f4(,%eax,4),%edx
  80054d:	85 d2                	test   %edx,%edx
  80054f:	75 23                	jne    800574 <vprintfmt+0x154>
				printfmt(putch, putdat, "error %d", err);
  800551:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800555:	c7 44 24 08 a2 12 80 	movl   $0x8012a2,0x8(%esp)
  80055c:	00 
  80055d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800561:	8b 45 08             	mov    0x8(%ebp),%eax
  800564:	89 04 24             	mov    %eax,(%esp)
  800567:	e8 22 04 00 00       	call   80098e <printfmt>
  80056c:	8b 5d cc             	mov    -0x34(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80056f:	e9 d6 fe ff ff       	jmp    80044a <vprintfmt+0x2a>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800574:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800578:	c7 44 24 08 ab 12 80 	movl   $0x8012ab,0x8(%esp)
  80057f:	00 
  800580:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800584:	8b 55 08             	mov    0x8(%ebp),%edx
  800587:	89 14 24             	mov    %edx,(%esp)
  80058a:	e8 ff 03 00 00       	call   80098e <printfmt>
  80058f:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800592:	e9 b3 fe ff ff       	jmp    80044a <vprintfmt+0x2a>
  800597:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80059a:	89 c3                	mov    %eax,%ebx
  80059c:	89 f1                	mov    %esi,%ecx
  80059e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005a1:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a7:	8d 50 04             	lea    0x4(%eax),%edx
  8005aa:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ad:	8b 00                	mov    (%eax),%eax
  8005af:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005b2:	85 c0                	test   %eax,%eax
  8005b4:	75 07                	jne    8005bd <vprintfmt+0x19d>
  8005b6:	c7 45 d0 ae 12 80 00 	movl   $0x8012ae,-0x30(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  8005bd:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8005c1:	7e 06                	jle    8005c9 <vprintfmt+0x1a9>
  8005c3:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  8005c7:	75 13                	jne    8005dc <vprintfmt+0x1bc>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005c9:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005cc:	0f be 02             	movsbl (%edx),%eax
  8005cf:	85 c0                	test   %eax,%eax
  8005d1:	0f 85 a2 00 00 00    	jne    800679 <vprintfmt+0x259>
  8005d7:	e9 8f 00 00 00       	jmp    80066b <vprintfmt+0x24b>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005dc:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005e0:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8005e3:	89 0c 24             	mov    %ecx,(%esp)
  8005e6:	e8 f0 03 00 00       	call   8009db <strnlen>
  8005eb:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8005ee:	29 c2                	sub    %eax,%edx
  8005f0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005f3:	85 d2                	test   %edx,%edx
  8005f5:	7e d2                	jle    8005c9 <vprintfmt+0x1a9>
					putch(padc, putdat);
  8005f7:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  8005fb:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  8005fe:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  800601:	89 d3                	mov    %edx,%ebx
  800603:	89 ce                	mov    %ecx,%esi
  800605:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800609:	89 34 24             	mov    %esi,(%esp)
  80060c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80060f:	83 eb 01             	sub    $0x1,%ebx
  800612:	85 db                	test   %ebx,%ebx
  800614:	7f ef                	jg     800605 <vprintfmt+0x1e5>
  800616:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  800619:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  80061c:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800623:	eb a4                	jmp    8005c9 <vprintfmt+0x1a9>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800625:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800629:	74 1b                	je     800646 <vprintfmt+0x226>
  80062b:	8d 50 e0             	lea    -0x20(%eax),%edx
  80062e:	83 fa 5e             	cmp    $0x5e,%edx
  800631:	76 13                	jbe    800646 <vprintfmt+0x226>
					putch('?', putdat);
  800633:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800636:	89 44 24 04          	mov    %eax,0x4(%esp)
  80063a:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800641:	ff 55 08             	call   *0x8(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800644:	eb 0d                	jmp    800653 <vprintfmt+0x233>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800646:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800649:	89 54 24 04          	mov    %edx,0x4(%esp)
  80064d:	89 04 24             	mov    %eax,(%esp)
  800650:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800653:	83 ef 01             	sub    $0x1,%edi
  800656:	0f be 03             	movsbl (%ebx),%eax
  800659:	85 c0                	test   %eax,%eax
  80065b:	74 05                	je     800662 <vprintfmt+0x242>
  80065d:	83 c3 01             	add    $0x1,%ebx
  800660:	eb 28                	jmp    80068a <vprintfmt+0x26a>
  800662:	89 7d dc             	mov    %edi,-0x24(%ebp)
  800665:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800668:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80066b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80066f:	7f 2d                	jg     80069e <vprintfmt+0x27e>
  800671:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800674:	e9 d1 fd ff ff       	jmp    80044a <vprintfmt+0x2a>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800679:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80067c:	83 c1 01             	add    $0x1,%ecx
  80067f:	89 7d e0             	mov    %edi,-0x20(%ebp)
  800682:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800685:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  800688:	89 cb                	mov    %ecx,%ebx
  80068a:	85 f6                	test   %esi,%esi
  80068c:	78 97                	js     800625 <vprintfmt+0x205>
  80068e:	83 ee 01             	sub    $0x1,%esi
  800691:	79 92                	jns    800625 <vprintfmt+0x205>
  800693:	89 7d dc             	mov    %edi,-0x24(%ebp)
  800696:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800699:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  80069c:	eb cd                	jmp    80066b <vprintfmt+0x24b>
  80069e:	8b 75 08             	mov    0x8(%ebp),%esi
  8006a1:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8006a4:	8b 5d dc             	mov    -0x24(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006a7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006ab:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006b2:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006b4:	83 eb 01             	sub    $0x1,%ebx
  8006b7:	85 db                	test   %ebx,%ebx
  8006b9:	7f ec                	jg     8006a7 <vprintfmt+0x287>
  8006bb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8006be:	e9 87 fd ff ff       	jmp    80044a <vprintfmt+0x2a>
  8006c3:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8006c6:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
  8006ca:	88 45 e4             	mov    %al,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006cd:	83 7d d0 01          	cmpl   $0x1,-0x30(%ebp)
  8006d1:	7e 16                	jle    8006e9 <vprintfmt+0x2c9>
		return va_arg(*ap, long long);
  8006d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d6:	8d 50 08             	lea    0x8(%eax),%edx
  8006d9:	89 55 14             	mov    %edx,0x14(%ebp)
  8006dc:	8b 10                	mov    (%eax),%edx
  8006de:	8b 48 04             	mov    0x4(%eax),%ecx
  8006e1:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8006e4:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8006e7:	eb 34                	jmp    80071d <vprintfmt+0x2fd>
	else if (lflag)
  8006e9:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8006ed:	74 18                	je     800707 <vprintfmt+0x2e7>
		return va_arg(*ap, long);
  8006ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f2:	8d 50 04             	lea    0x4(%eax),%edx
  8006f5:	89 55 14             	mov    %edx,0x14(%ebp)
  8006f8:	8b 00                	mov    (%eax),%eax
  8006fa:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006fd:	89 c1                	mov    %eax,%ecx
  8006ff:	c1 f9 1f             	sar    $0x1f,%ecx
  800702:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800705:	eb 16                	jmp    80071d <vprintfmt+0x2fd>
	else
		return va_arg(*ap, int);
  800707:	8b 45 14             	mov    0x14(%ebp),%eax
  80070a:	8d 50 04             	lea    0x4(%eax),%edx
  80070d:	89 55 14             	mov    %edx,0x14(%ebp)
  800710:	8b 00                	mov    (%eax),%eax
  800712:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800715:	89 c2                	mov    %eax,%edx
  800717:	c1 fa 1f             	sar    $0x1f,%edx
  80071a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80071d:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800720:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if ((long long) num < 0) {
  800723:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800727:	79 2c                	jns    800755 <vprintfmt+0x335>
				putch('-', putdat);
  800729:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80072d:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800734:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800737:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80073a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80073d:	f7 db                	neg    %ebx
  80073f:	83 d6 00             	adc    $0x0,%esi
  800742:	f7 de                	neg    %esi
  800744:	0f b6 4d e0          	movzbl -0x20(%ebp),%ecx
  800748:	88 4d e4             	mov    %cl,-0x1c(%ebp)
  80074b:	ba 0a 00 00 00       	mov    $0xa,%edx
  800750:	e9 db 00 00 00       	jmp    800830 <vprintfmt+0x410>
			}
			else if (padc == '+'){
  800755:	80 7d e4 2b          	cmpb   $0x2b,-0x1c(%ebp)
  800759:	74 11                	je     80076c <vprintfmt+0x34c>
  80075b:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
  80075f:	88 45 e4             	mov    %al,-0x1c(%ebp)
  800762:	ba 0a 00 00 00       	mov    $0xa,%edx
  800767:	e9 c4 00 00 00       	jmp    800830 <vprintfmt+0x410>
				putch('+', putdat);
  80076c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800770:	c7 04 24 2b 00 00 00 	movl   $0x2b,(%esp)
  800777:	ff 55 08             	call   *0x8(%ebp)
  80077a:	ba 0a 00 00 00       	mov    $0xa,%edx
  80077f:	e9 ac 00 00 00       	jmp    800830 <vprintfmt+0x410>
  800784:	89 45 cc             	mov    %eax,-0x34(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800787:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80078a:	8d 45 14             	lea    0x14(%ebp),%eax
  80078d:	e8 37 fc ff ff       	call   8003c9 <getuint>
  800792:	89 c3                	mov    %eax,%ebx
  800794:	89 d6                	mov    %edx,%esi
  800796:	0f b6 55 e0          	movzbl -0x20(%ebp),%edx
  80079a:	88 55 e4             	mov    %dl,-0x1c(%ebp)
  80079d:	ba 0a 00 00 00       	mov    $0xa,%edx
			base = 10;
			goto number;
  8007a2:	e9 89 00 00 00       	jmp    800830 <vprintfmt+0x410>
  8007a7:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) octal
		case 'o':
			putch('0', putdat);
  8007aa:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007ae:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007b5:	ff 55 08             	call   *0x8(%ebp)
			num = getuint(&ap, lflag);
  8007b8:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8007bb:	8d 45 14             	lea    0x14(%ebp),%eax
  8007be:	e8 06 fc ff ff       	call   8003c9 <getuint>
  8007c3:	89 c3                	mov    %eax,%ebx
  8007c5:	89 d6                	mov    %edx,%esi
  8007c7:	0f b6 4d e0          	movzbl -0x20(%ebp),%ecx
  8007cb:	88 4d e4             	mov    %cl,-0x1c(%ebp)
  8007ce:	ba 08 00 00 00       	mov    $0x8,%edx
			base = 8;
			goto number;
  8007d3:	eb 5b                	jmp    800830 <vprintfmt+0x410>
  8007d5:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  8007d8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007dc:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007e3:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007e6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007ea:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007f1:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  8007f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f7:	8d 50 04             	lea    0x4(%eax),%edx
  8007fa:	89 55 14             	mov    %edx,0x14(%ebp)
  8007fd:	8b 18                	mov    (%eax),%ebx
  8007ff:	be 00 00 00 00       	mov    $0x0,%esi
  800804:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
  800808:	88 45 e4             	mov    %al,-0x1c(%ebp)
  80080b:	ba 10 00 00 00       	mov    $0x10,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800810:	eb 1e                	jmp    800830 <vprintfmt+0x410>
  800812:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800815:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800818:	8d 45 14             	lea    0x14(%ebp),%eax
  80081b:	e8 a9 fb ff ff       	call   8003c9 <getuint>
  800820:	89 c3                	mov    %eax,%ebx
  800822:	89 d6                	mov    %edx,%esi
  800824:	0f b6 55 e0          	movzbl -0x20(%ebp),%edx
  800828:	88 55 e4             	mov    %dl,-0x1c(%ebp)
  80082b:	ba 10 00 00 00       	mov    $0x10,%edx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800830:	0f be 45 e4          	movsbl -0x1c(%ebp),%eax
  800834:	89 44 24 10          	mov    %eax,0x10(%esp)
  800838:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80083b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80083f:	89 54 24 08          	mov    %edx,0x8(%esp)
  800843:	89 1c 24             	mov    %ebx,(%esp)
  800846:	89 74 24 04          	mov    %esi,0x4(%esp)
  80084a:	89 fa                	mov    %edi,%edx
  80084c:	8b 45 08             	mov    0x8(%ebp),%eax
  80084f:	e8 2d fa ff ff       	call   800281 <printnum>
  800854:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  800857:	e9 ee fb ff ff       	jmp    80044a <vprintfmt+0x2a>
  80085c:	89 45 cc             	mov    %eax,-0x34(%ebp)
            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
	    	uint32_t *num_now = putdat;
	    	char *ret_va = va_arg(ap, char *);
  80085f:	8b 45 14             	mov    0x14(%ebp),%eax
  800862:	8d 50 04             	lea    0x4(%eax),%edx
  800865:	89 55 14             	mov    %edx,0x14(%ebp)
  800868:	8b 00                	mov    (%eax),%eax
	    	if(ret_va == NULL){
  80086a:	85 c0                	test   %eax,%eax
  80086c:	75 27                	jne    800895 <vprintfmt+0x475>
				printfmt(putch, putdat, "%s", null_error);
  80086e:	c7 44 24 0c 20 13 80 	movl   $0x801320,0xc(%esp)
  800875:	00 
  800876:	c7 44 24 08 ab 12 80 	movl   $0x8012ab,0x8(%esp)
  80087d:	00 
  80087e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800882:	8b 45 08             	mov    0x8(%ebp),%eax
  800885:	89 04 24             	mov    %eax,(%esp)
  800888:	e8 01 01 00 00       	call   80098e <printfmt>
  80088d:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800890:	e9 b5 fb ff ff       	jmp    80044a <vprintfmt+0x2a>
	    	}
	    	else if ((*num_now) >> 7 != 0 ){		//how to aurrately discribe overflow?
  800895:	8b 17                	mov    (%edi),%edx
  800897:	89 d1                	mov    %edx,%ecx
  800899:	c1 e9 07             	shr    $0x7,%ecx
  80089c:	85 c9                	test   %ecx,%ecx
  80089e:	74 29                	je     8008c9 <vprintfmt+0x4a9>
				*ret_va = *(num_now);	//get putdat at first as next print instruction will change ret_va as it's a pointer which means it's dynamic;
  8008a0:	88 10                	mov    %dl,(%eax)
				printfmt(putch, putdat, "%s", overflow_error);
  8008a2:	c7 44 24 0c 58 13 80 	movl   $0x801358,0xc(%esp)
  8008a9:	00 
  8008aa:	c7 44 24 08 ab 12 80 	movl   $0x8012ab,0x8(%esp)
  8008b1:	00 
  8008b2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8008b9:	89 14 24             	mov    %edx,(%esp)
  8008bc:	e8 cd 00 00 00       	call   80098e <printfmt>
  8008c1:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  8008c4:	e9 81 fb ff ff       	jmp    80044a <vprintfmt+0x2a>
	    	}
	    	else{
				*ret_va = *(num_now);
  8008c9:	88 10                	mov    %dl,(%eax)
  8008cb:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  8008ce:	e9 77 fb ff ff       	jmp    80044a <vprintfmt+0x2a>
  8008d3:	89 45 cc             	mov    %eax,-0x34(%ebp)
            	break;
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008d6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008da:	89 14 24             	mov    %edx,(%esp)
  8008dd:	ff 55 08             	call   *0x8(%ebp)
  8008e0:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  8008e3:	e9 62 fb ff ff       	jmp    80044a <vprintfmt+0x2a>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008e8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008ec:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8008f3:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008f6:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8008f9:	80 38 25             	cmpb   $0x25,(%eax)
  8008fc:	0f 84 48 fb ff ff    	je     80044a <vprintfmt+0x2a>
  800902:	89 c3                	mov    %eax,%ebx
  800904:	eb f0                	jmp    8008f6 <vprintfmt+0x4d6>
				/* do nothing */;
			break;
		}
	}
}
  800906:	83 c4 5c             	add    $0x5c,%esp
  800909:	5b                   	pop    %ebx
  80090a:	5e                   	pop    %esi
  80090b:	5f                   	pop    %edi
  80090c:	5d                   	pop    %ebp
  80090d:	c3                   	ret    

0080090e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80090e:	55                   	push   %ebp
  80090f:	89 e5                	mov    %esp,%ebp
  800911:	83 ec 28             	sub    $0x28,%esp
  800914:	8b 45 08             	mov    0x8(%ebp),%eax
  800917:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  80091a:	85 c0                	test   %eax,%eax
  80091c:	74 04                	je     800922 <vsnprintf+0x14>
  80091e:	85 d2                	test   %edx,%edx
  800920:	7f 07                	jg     800929 <vsnprintf+0x1b>
  800922:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800927:	eb 3b                	jmp    800964 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800929:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80092c:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800930:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800933:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80093a:	8b 45 14             	mov    0x14(%ebp),%eax
  80093d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800941:	8b 45 10             	mov    0x10(%ebp),%eax
  800944:	89 44 24 08          	mov    %eax,0x8(%esp)
  800948:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80094b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80094f:	c7 04 24 03 04 80 00 	movl   $0x800403,(%esp)
  800956:	e8 c5 fa ff ff       	call   800420 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80095b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80095e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800961:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800964:	c9                   	leave  
  800965:	c3                   	ret    

00800966 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800966:	55                   	push   %ebp
  800967:	89 e5                	mov    %esp,%ebp
  800969:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  80096c:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  80096f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800973:	8b 45 10             	mov    0x10(%ebp),%eax
  800976:	89 44 24 08          	mov    %eax,0x8(%esp)
  80097a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80097d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800981:	8b 45 08             	mov    0x8(%ebp),%eax
  800984:	89 04 24             	mov    %eax,(%esp)
  800987:	e8 82 ff ff ff       	call   80090e <vsnprintf>
	va_end(ap);

	return rc;
}
  80098c:	c9                   	leave  
  80098d:	c3                   	ret    

0080098e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80098e:	55                   	push   %ebp
  80098f:	89 e5                	mov    %esp,%ebp
  800991:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800994:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800997:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80099b:	8b 45 10             	mov    0x10(%ebp),%eax
  80099e:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009a2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ac:	89 04 24             	mov    %eax,(%esp)
  8009af:	e8 6c fa ff ff       	call   800420 <vprintfmt>
	va_end(ap);
}
  8009b4:	c9                   	leave  
  8009b5:	c3                   	ret    
	...

008009c0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009c0:	55                   	push   %ebp
  8009c1:	89 e5                	mov    %esp,%ebp
  8009c3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8009cb:	80 3a 00             	cmpb   $0x0,(%edx)
  8009ce:	74 09                	je     8009d9 <strlen+0x19>
		n++;
  8009d0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009d3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009d7:	75 f7                	jne    8009d0 <strlen+0x10>
		n++;
	return n;
}
  8009d9:	5d                   	pop    %ebp
  8009da:	c3                   	ret    

008009db <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009db:	55                   	push   %ebp
  8009dc:	89 e5                	mov    %esp,%ebp
  8009de:	53                   	push   %ebx
  8009df:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009e5:	85 c9                	test   %ecx,%ecx
  8009e7:	74 19                	je     800a02 <strnlen+0x27>
  8009e9:	80 3b 00             	cmpb   $0x0,(%ebx)
  8009ec:	74 14                	je     800a02 <strnlen+0x27>
  8009ee:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8009f3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009f6:	39 c8                	cmp    %ecx,%eax
  8009f8:	74 0d                	je     800a07 <strnlen+0x2c>
  8009fa:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  8009fe:	75 f3                	jne    8009f3 <strnlen+0x18>
  800a00:	eb 05                	jmp    800a07 <strnlen+0x2c>
  800a02:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800a07:	5b                   	pop    %ebx
  800a08:	5d                   	pop    %ebp
  800a09:	c3                   	ret    

00800a0a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a0a:	55                   	push   %ebp
  800a0b:	89 e5                	mov    %esp,%ebp
  800a0d:	53                   	push   %ebx
  800a0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a11:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a14:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a19:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800a1d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a20:	83 c2 01             	add    $0x1,%edx
  800a23:	84 c9                	test   %cl,%cl
  800a25:	75 f2                	jne    800a19 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800a27:	5b                   	pop    %ebx
  800a28:	5d                   	pop    %ebp
  800a29:	c3                   	ret    

00800a2a <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a2a:	55                   	push   %ebp
  800a2b:	89 e5                	mov    %esp,%ebp
  800a2d:	53                   	push   %ebx
  800a2e:	83 ec 08             	sub    $0x8,%esp
  800a31:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a34:	89 1c 24             	mov    %ebx,(%esp)
  800a37:	e8 84 ff ff ff       	call   8009c0 <strlen>
	strcpy(dst + len, src);
  800a3c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a3f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a43:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800a46:	89 04 24             	mov    %eax,(%esp)
  800a49:	e8 bc ff ff ff       	call   800a0a <strcpy>
	return dst;
}
  800a4e:	89 d8                	mov    %ebx,%eax
  800a50:	83 c4 08             	add    $0x8,%esp
  800a53:	5b                   	pop    %ebx
  800a54:	5d                   	pop    %ebp
  800a55:	c3                   	ret    

00800a56 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a56:	55                   	push   %ebp
  800a57:	89 e5                	mov    %esp,%ebp
  800a59:	56                   	push   %esi
  800a5a:	53                   	push   %ebx
  800a5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a61:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a64:	85 f6                	test   %esi,%esi
  800a66:	74 18                	je     800a80 <strncpy+0x2a>
  800a68:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800a6d:	0f b6 1a             	movzbl (%edx),%ebx
  800a70:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a73:	80 3a 01             	cmpb   $0x1,(%edx)
  800a76:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a79:	83 c1 01             	add    $0x1,%ecx
  800a7c:	39 ce                	cmp    %ecx,%esi
  800a7e:	77 ed                	ja     800a6d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a80:	5b                   	pop    %ebx
  800a81:	5e                   	pop    %esi
  800a82:	5d                   	pop    %ebp
  800a83:	c3                   	ret    

00800a84 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a84:	55                   	push   %ebp
  800a85:	89 e5                	mov    %esp,%ebp
  800a87:	56                   	push   %esi
  800a88:	53                   	push   %ebx
  800a89:	8b 75 08             	mov    0x8(%ebp),%esi
  800a8c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a8f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a92:	89 f0                	mov    %esi,%eax
  800a94:	85 c9                	test   %ecx,%ecx
  800a96:	74 27                	je     800abf <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800a98:	83 e9 01             	sub    $0x1,%ecx
  800a9b:	74 1d                	je     800aba <strlcpy+0x36>
  800a9d:	0f b6 1a             	movzbl (%edx),%ebx
  800aa0:	84 db                	test   %bl,%bl
  800aa2:	74 16                	je     800aba <strlcpy+0x36>
			*dst++ = *src++;
  800aa4:	88 18                	mov    %bl,(%eax)
  800aa6:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800aa9:	83 e9 01             	sub    $0x1,%ecx
  800aac:	74 0e                	je     800abc <strlcpy+0x38>
			*dst++ = *src++;
  800aae:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ab1:	0f b6 1a             	movzbl (%edx),%ebx
  800ab4:	84 db                	test   %bl,%bl
  800ab6:	75 ec                	jne    800aa4 <strlcpy+0x20>
  800ab8:	eb 02                	jmp    800abc <strlcpy+0x38>
  800aba:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800abc:	c6 00 00             	movb   $0x0,(%eax)
  800abf:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800ac1:	5b                   	pop    %ebx
  800ac2:	5e                   	pop    %esi
  800ac3:	5d                   	pop    %ebp
  800ac4:	c3                   	ret    

00800ac5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ac5:	55                   	push   %ebp
  800ac6:	89 e5                	mov    %esp,%ebp
  800ac8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800acb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ace:	0f b6 01             	movzbl (%ecx),%eax
  800ad1:	84 c0                	test   %al,%al
  800ad3:	74 15                	je     800aea <strcmp+0x25>
  800ad5:	3a 02                	cmp    (%edx),%al
  800ad7:	75 11                	jne    800aea <strcmp+0x25>
		p++, q++;
  800ad9:	83 c1 01             	add    $0x1,%ecx
  800adc:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800adf:	0f b6 01             	movzbl (%ecx),%eax
  800ae2:	84 c0                	test   %al,%al
  800ae4:	74 04                	je     800aea <strcmp+0x25>
  800ae6:	3a 02                	cmp    (%edx),%al
  800ae8:	74 ef                	je     800ad9 <strcmp+0x14>
  800aea:	0f b6 c0             	movzbl %al,%eax
  800aed:	0f b6 12             	movzbl (%edx),%edx
  800af0:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800af2:	5d                   	pop    %ebp
  800af3:	c3                   	ret    

00800af4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800af4:	55                   	push   %ebp
  800af5:	89 e5                	mov    %esp,%ebp
  800af7:	53                   	push   %ebx
  800af8:	8b 55 08             	mov    0x8(%ebp),%edx
  800afb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800afe:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800b01:	85 c0                	test   %eax,%eax
  800b03:	74 23                	je     800b28 <strncmp+0x34>
  800b05:	0f b6 1a             	movzbl (%edx),%ebx
  800b08:	84 db                	test   %bl,%bl
  800b0a:	74 25                	je     800b31 <strncmp+0x3d>
  800b0c:	3a 19                	cmp    (%ecx),%bl
  800b0e:	75 21                	jne    800b31 <strncmp+0x3d>
  800b10:	83 e8 01             	sub    $0x1,%eax
  800b13:	74 13                	je     800b28 <strncmp+0x34>
		n--, p++, q++;
  800b15:	83 c2 01             	add    $0x1,%edx
  800b18:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b1b:	0f b6 1a             	movzbl (%edx),%ebx
  800b1e:	84 db                	test   %bl,%bl
  800b20:	74 0f                	je     800b31 <strncmp+0x3d>
  800b22:	3a 19                	cmp    (%ecx),%bl
  800b24:	74 ea                	je     800b10 <strncmp+0x1c>
  800b26:	eb 09                	jmp    800b31 <strncmp+0x3d>
  800b28:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b2d:	5b                   	pop    %ebx
  800b2e:	5d                   	pop    %ebp
  800b2f:	90                   	nop
  800b30:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b31:	0f b6 02             	movzbl (%edx),%eax
  800b34:	0f b6 11             	movzbl (%ecx),%edx
  800b37:	29 d0                	sub    %edx,%eax
  800b39:	eb f2                	jmp    800b2d <strncmp+0x39>

00800b3b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b3b:	55                   	push   %ebp
  800b3c:	89 e5                	mov    %esp,%ebp
  800b3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b41:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b45:	0f b6 10             	movzbl (%eax),%edx
  800b48:	84 d2                	test   %dl,%dl
  800b4a:	74 18                	je     800b64 <strchr+0x29>
		if (*s == c)
  800b4c:	38 ca                	cmp    %cl,%dl
  800b4e:	75 0a                	jne    800b5a <strchr+0x1f>
  800b50:	eb 17                	jmp    800b69 <strchr+0x2e>
  800b52:	38 ca                	cmp    %cl,%dl
  800b54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800b58:	74 0f                	je     800b69 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b5a:	83 c0 01             	add    $0x1,%eax
  800b5d:	0f b6 10             	movzbl (%eax),%edx
  800b60:	84 d2                	test   %dl,%dl
  800b62:	75 ee                	jne    800b52 <strchr+0x17>
  800b64:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800b69:	5d                   	pop    %ebp
  800b6a:	c3                   	ret    

00800b6b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b6b:	55                   	push   %ebp
  800b6c:	89 e5                	mov    %esp,%ebp
  800b6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b71:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b75:	0f b6 10             	movzbl (%eax),%edx
  800b78:	84 d2                	test   %dl,%dl
  800b7a:	74 18                	je     800b94 <strfind+0x29>
		if (*s == c)
  800b7c:	38 ca                	cmp    %cl,%dl
  800b7e:	75 0a                	jne    800b8a <strfind+0x1f>
  800b80:	eb 12                	jmp    800b94 <strfind+0x29>
  800b82:	38 ca                	cmp    %cl,%dl
  800b84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800b88:	74 0a                	je     800b94 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b8a:	83 c0 01             	add    $0x1,%eax
  800b8d:	0f b6 10             	movzbl (%eax),%edx
  800b90:	84 d2                	test   %dl,%dl
  800b92:	75 ee                	jne    800b82 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800b94:	5d                   	pop    %ebp
  800b95:	c3                   	ret    

00800b96 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b96:	55                   	push   %ebp
  800b97:	89 e5                	mov    %esp,%ebp
  800b99:	83 ec 0c             	sub    $0xc,%esp
  800b9c:	89 1c 24             	mov    %ebx,(%esp)
  800b9f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ba3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800ba7:	8b 7d 08             	mov    0x8(%ebp),%edi
  800baa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bad:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bb0:	85 c9                	test   %ecx,%ecx
  800bb2:	74 30                	je     800be4 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bb4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bba:	75 25                	jne    800be1 <memset+0x4b>
  800bbc:	f6 c1 03             	test   $0x3,%cl
  800bbf:	75 20                	jne    800be1 <memset+0x4b>
		c &= 0xFF;
  800bc1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bc4:	89 d3                	mov    %edx,%ebx
  800bc6:	c1 e3 08             	shl    $0x8,%ebx
  800bc9:	89 d6                	mov    %edx,%esi
  800bcb:	c1 e6 18             	shl    $0x18,%esi
  800bce:	89 d0                	mov    %edx,%eax
  800bd0:	c1 e0 10             	shl    $0x10,%eax
  800bd3:	09 f0                	or     %esi,%eax
  800bd5:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800bd7:	09 d8                	or     %ebx,%eax
  800bd9:	c1 e9 02             	shr    $0x2,%ecx
  800bdc:	fc                   	cld    
  800bdd:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bdf:	eb 03                	jmp    800be4 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800be1:	fc                   	cld    
  800be2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800be4:	89 f8                	mov    %edi,%eax
  800be6:	8b 1c 24             	mov    (%esp),%ebx
  800be9:	8b 74 24 04          	mov    0x4(%esp),%esi
  800bed:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800bf1:	89 ec                	mov    %ebp,%esp
  800bf3:	5d                   	pop    %ebp
  800bf4:	c3                   	ret    

00800bf5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	83 ec 08             	sub    $0x8,%esp
  800bfb:	89 34 24             	mov    %esi,(%esp)
  800bfe:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800c02:	8b 45 08             	mov    0x8(%ebp),%eax
  800c05:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800c08:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800c0b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800c0d:	39 c6                	cmp    %eax,%esi
  800c0f:	73 35                	jae    800c46 <memmove+0x51>
  800c11:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c14:	39 d0                	cmp    %edx,%eax
  800c16:	73 2e                	jae    800c46 <memmove+0x51>
		s += n;
		d += n;
  800c18:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c1a:	f6 c2 03             	test   $0x3,%dl
  800c1d:	75 1b                	jne    800c3a <memmove+0x45>
  800c1f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c25:	75 13                	jne    800c3a <memmove+0x45>
  800c27:	f6 c1 03             	test   $0x3,%cl
  800c2a:	75 0e                	jne    800c3a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800c2c:	83 ef 04             	sub    $0x4,%edi
  800c2f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c32:	c1 e9 02             	shr    $0x2,%ecx
  800c35:	fd                   	std    
  800c36:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c38:	eb 09                	jmp    800c43 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c3a:	83 ef 01             	sub    $0x1,%edi
  800c3d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800c40:	fd                   	std    
  800c41:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c43:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c44:	eb 20                	jmp    800c66 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c46:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c4c:	75 15                	jne    800c63 <memmove+0x6e>
  800c4e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c54:	75 0d                	jne    800c63 <memmove+0x6e>
  800c56:	f6 c1 03             	test   $0x3,%cl
  800c59:	75 08                	jne    800c63 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800c5b:	c1 e9 02             	shr    $0x2,%ecx
  800c5e:	fc                   	cld    
  800c5f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c61:	eb 03                	jmp    800c66 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c63:	fc                   	cld    
  800c64:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c66:	8b 34 24             	mov    (%esp),%esi
  800c69:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800c6d:	89 ec                	mov    %ebp,%esp
  800c6f:	5d                   	pop    %ebp
  800c70:	c3                   	ret    

00800c71 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800c71:	55                   	push   %ebp
  800c72:	89 e5                	mov    %esp,%ebp
  800c74:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c77:	8b 45 10             	mov    0x10(%ebp),%eax
  800c7a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c7e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c81:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c85:	8b 45 08             	mov    0x8(%ebp),%eax
  800c88:	89 04 24             	mov    %eax,(%esp)
  800c8b:	e8 65 ff ff ff       	call   800bf5 <memmove>
}
  800c90:	c9                   	leave  
  800c91:	c3                   	ret    

00800c92 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c92:	55                   	push   %ebp
  800c93:	89 e5                	mov    %esp,%ebp
  800c95:	57                   	push   %edi
  800c96:	56                   	push   %esi
  800c97:	53                   	push   %ebx
  800c98:	8b 75 08             	mov    0x8(%ebp),%esi
  800c9b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800c9e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ca1:	85 c9                	test   %ecx,%ecx
  800ca3:	74 36                	je     800cdb <memcmp+0x49>
		if (*s1 != *s2)
  800ca5:	0f b6 06             	movzbl (%esi),%eax
  800ca8:	0f b6 1f             	movzbl (%edi),%ebx
  800cab:	38 d8                	cmp    %bl,%al
  800cad:	74 20                	je     800ccf <memcmp+0x3d>
  800caf:	eb 14                	jmp    800cc5 <memcmp+0x33>
  800cb1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800cb6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800cbb:	83 c2 01             	add    $0x1,%edx
  800cbe:	83 e9 01             	sub    $0x1,%ecx
  800cc1:	38 d8                	cmp    %bl,%al
  800cc3:	74 12                	je     800cd7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800cc5:	0f b6 c0             	movzbl %al,%eax
  800cc8:	0f b6 db             	movzbl %bl,%ebx
  800ccb:	29 d8                	sub    %ebx,%eax
  800ccd:	eb 11                	jmp    800ce0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ccf:	83 e9 01             	sub    $0x1,%ecx
  800cd2:	ba 00 00 00 00       	mov    $0x0,%edx
  800cd7:	85 c9                	test   %ecx,%ecx
  800cd9:	75 d6                	jne    800cb1 <memcmp+0x1f>
  800cdb:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800ce0:	5b                   	pop    %ebx
  800ce1:	5e                   	pop    %esi
  800ce2:	5f                   	pop    %edi
  800ce3:	5d                   	pop    %ebp
  800ce4:	c3                   	ret    

00800ce5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ce5:	55                   	push   %ebp
  800ce6:	89 e5                	mov    %esp,%ebp
  800ce8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ceb:	89 c2                	mov    %eax,%edx
  800ced:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800cf0:	39 d0                	cmp    %edx,%eax
  800cf2:	73 15                	jae    800d09 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cf4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800cf8:	38 08                	cmp    %cl,(%eax)
  800cfa:	75 06                	jne    800d02 <memfind+0x1d>
  800cfc:	eb 0b                	jmp    800d09 <memfind+0x24>
  800cfe:	38 08                	cmp    %cl,(%eax)
  800d00:	74 07                	je     800d09 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d02:	83 c0 01             	add    $0x1,%eax
  800d05:	39 c2                	cmp    %eax,%edx
  800d07:	77 f5                	ja     800cfe <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d09:	5d                   	pop    %ebp
  800d0a:	c3                   	ret    

00800d0b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d0b:	55                   	push   %ebp
  800d0c:	89 e5                	mov    %esp,%ebp
  800d0e:	57                   	push   %edi
  800d0f:	56                   	push   %esi
  800d10:	53                   	push   %ebx
  800d11:	83 ec 04             	sub    $0x4,%esp
  800d14:	8b 55 08             	mov    0x8(%ebp),%edx
  800d17:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d1a:	0f b6 02             	movzbl (%edx),%eax
  800d1d:	3c 20                	cmp    $0x20,%al
  800d1f:	74 04                	je     800d25 <strtol+0x1a>
  800d21:	3c 09                	cmp    $0x9,%al
  800d23:	75 0e                	jne    800d33 <strtol+0x28>
		s++;
  800d25:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d28:	0f b6 02             	movzbl (%edx),%eax
  800d2b:	3c 20                	cmp    $0x20,%al
  800d2d:	74 f6                	je     800d25 <strtol+0x1a>
  800d2f:	3c 09                	cmp    $0x9,%al
  800d31:	74 f2                	je     800d25 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d33:	3c 2b                	cmp    $0x2b,%al
  800d35:	75 0c                	jne    800d43 <strtol+0x38>
		s++;
  800d37:	83 c2 01             	add    $0x1,%edx
  800d3a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800d41:	eb 15                	jmp    800d58 <strtol+0x4d>
	else if (*s == '-')
  800d43:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800d4a:	3c 2d                	cmp    $0x2d,%al
  800d4c:	75 0a                	jne    800d58 <strtol+0x4d>
		s++, neg = 1;
  800d4e:	83 c2 01             	add    $0x1,%edx
  800d51:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d58:	85 db                	test   %ebx,%ebx
  800d5a:	0f 94 c0             	sete   %al
  800d5d:	74 05                	je     800d64 <strtol+0x59>
  800d5f:	83 fb 10             	cmp    $0x10,%ebx
  800d62:	75 18                	jne    800d7c <strtol+0x71>
  800d64:	80 3a 30             	cmpb   $0x30,(%edx)
  800d67:	75 13                	jne    800d7c <strtol+0x71>
  800d69:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d6d:	8d 76 00             	lea    0x0(%esi),%esi
  800d70:	75 0a                	jne    800d7c <strtol+0x71>
		s += 2, base = 16;
  800d72:	83 c2 02             	add    $0x2,%edx
  800d75:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d7a:	eb 15                	jmp    800d91 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d7c:	84 c0                	test   %al,%al
  800d7e:	66 90                	xchg   %ax,%ax
  800d80:	74 0f                	je     800d91 <strtol+0x86>
  800d82:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800d87:	80 3a 30             	cmpb   $0x30,(%edx)
  800d8a:	75 05                	jne    800d91 <strtol+0x86>
		s++, base = 8;
  800d8c:	83 c2 01             	add    $0x1,%edx
  800d8f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d91:	b8 00 00 00 00       	mov    $0x0,%eax
  800d96:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d98:	0f b6 0a             	movzbl (%edx),%ecx
  800d9b:	89 cf                	mov    %ecx,%edi
  800d9d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800da0:	80 fb 09             	cmp    $0x9,%bl
  800da3:	77 08                	ja     800dad <strtol+0xa2>
			dig = *s - '0';
  800da5:	0f be c9             	movsbl %cl,%ecx
  800da8:	83 e9 30             	sub    $0x30,%ecx
  800dab:	eb 1e                	jmp    800dcb <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800dad:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800db0:	80 fb 19             	cmp    $0x19,%bl
  800db3:	77 08                	ja     800dbd <strtol+0xb2>
			dig = *s - 'a' + 10;
  800db5:	0f be c9             	movsbl %cl,%ecx
  800db8:	83 e9 57             	sub    $0x57,%ecx
  800dbb:	eb 0e                	jmp    800dcb <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800dbd:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800dc0:	80 fb 19             	cmp    $0x19,%bl
  800dc3:	77 15                	ja     800dda <strtol+0xcf>
			dig = *s - 'A' + 10;
  800dc5:	0f be c9             	movsbl %cl,%ecx
  800dc8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800dcb:	39 f1                	cmp    %esi,%ecx
  800dcd:	7d 0b                	jge    800dda <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800dcf:	83 c2 01             	add    $0x1,%edx
  800dd2:	0f af c6             	imul   %esi,%eax
  800dd5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800dd8:	eb be                	jmp    800d98 <strtol+0x8d>
  800dda:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800ddc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800de0:	74 05                	je     800de7 <strtol+0xdc>
		*endptr = (char *) s;
  800de2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800de5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800de7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800deb:	74 04                	je     800df1 <strtol+0xe6>
  800ded:	89 c8                	mov    %ecx,%eax
  800def:	f7 d8                	neg    %eax
}
  800df1:	83 c4 04             	add    $0x4,%esp
  800df4:	5b                   	pop    %ebx
  800df5:	5e                   	pop    %esi
  800df6:	5f                   	pop    %edi
  800df7:	5d                   	pop    %ebp
  800df8:	c3                   	ret    
  800df9:	00 00                	add    %al,(%eax)
	...

00800dfc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800dfc:	55                   	push   %ebp
  800dfd:	89 e5                	mov    %esp,%ebp
  800dff:	83 ec 08             	sub    $0x8,%esp
  800e02:	89 1c 24             	mov    %ebx,(%esp)
  800e05:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e09:	b8 00 00 00 00       	mov    $0x0,%eax
  800e0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e11:	8b 55 08             	mov    0x8(%ebp),%edx
  800e14:	89 c3                	mov    %eax,%ebx
  800e16:	89 c7                	mov    %eax,%edi
  800e18:	51                   	push   %ecx
  800e19:	52                   	push   %edx
  800e1a:	53                   	push   %ebx
  800e1b:	54                   	push   %esp
  800e1c:	55                   	push   %ebp
  800e1d:	56                   	push   %esi
  800e1e:	57                   	push   %edi
  800e1f:	5f                   	pop    %edi
  800e20:	5e                   	pop    %esi
  800e21:	5d                   	pop    %ebp
  800e22:	5c                   	pop    %esp
  800e23:	5b                   	pop    %ebx
  800e24:	5a                   	pop    %edx
  800e25:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800e26:	8b 1c 24             	mov    (%esp),%ebx
  800e29:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e2d:	89 ec                	mov    %ebp,%esp
  800e2f:	5d                   	pop    %ebp
  800e30:	c3                   	ret    

00800e31 <sys_cgetc>:

int
sys_cgetc(void)
{
  800e31:	55                   	push   %ebp
  800e32:	89 e5                	mov    %esp,%ebp
  800e34:	83 ec 08             	sub    $0x8,%esp
  800e37:	89 1c 24             	mov    %ebx,(%esp)
  800e3a:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e3e:	ba 00 00 00 00       	mov    $0x0,%edx
  800e43:	b8 01 00 00 00       	mov    $0x1,%eax
  800e48:	89 d1                	mov    %edx,%ecx
  800e4a:	89 d3                	mov    %edx,%ebx
  800e4c:	89 d7                	mov    %edx,%edi
  800e4e:	51                   	push   %ecx
  800e4f:	52                   	push   %edx
  800e50:	53                   	push   %ebx
  800e51:	54                   	push   %esp
  800e52:	55                   	push   %ebp
  800e53:	56                   	push   %esi
  800e54:	57                   	push   %edi
  800e55:	5f                   	pop    %edi
  800e56:	5e                   	pop    %esi
  800e57:	5d                   	pop    %ebp
  800e58:	5c                   	pop    %esp
  800e59:	5b                   	pop    %ebx
  800e5a:	5a                   	pop    %edx
  800e5b:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e5c:	8b 1c 24             	mov    (%esp),%ebx
  800e5f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e63:	89 ec                	mov    %ebp,%esp
  800e65:	5d                   	pop    %ebp
  800e66:	c3                   	ret    

00800e67 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800e67:	55                   	push   %ebp
  800e68:	89 e5                	mov    %esp,%ebp
  800e6a:	83 ec 08             	sub    $0x8,%esp
  800e6d:	89 1c 24             	mov    %ebx,(%esp)
  800e70:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e74:	ba 00 00 00 00       	mov    $0x0,%edx
  800e79:	b8 02 00 00 00       	mov    $0x2,%eax
  800e7e:	89 d1                	mov    %edx,%ecx
  800e80:	89 d3                	mov    %edx,%ebx
  800e82:	89 d7                	mov    %edx,%edi
  800e84:	51                   	push   %ecx
  800e85:	52                   	push   %edx
  800e86:	53                   	push   %ebx
  800e87:	54                   	push   %esp
  800e88:	55                   	push   %ebp
  800e89:	56                   	push   %esi
  800e8a:	57                   	push   %edi
  800e8b:	5f                   	pop    %edi
  800e8c:	5e                   	pop    %esi
  800e8d:	5d                   	pop    %ebp
  800e8e:	5c                   	pop    %esp
  800e8f:	5b                   	pop    %ebx
  800e90:	5a                   	pop    %edx
  800e91:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e92:	8b 1c 24             	mov    (%esp),%ebx
  800e95:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e99:	89 ec                	mov    %ebp,%esp
  800e9b:	5d                   	pop    %ebp
  800e9c:	c3                   	ret    

00800e9d <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800e9d:	55                   	push   %ebp
  800e9e:	89 e5                	mov    %esp,%ebp
  800ea0:	83 ec 08             	sub    $0x8,%esp
  800ea3:	89 1c 24             	mov    %ebx,(%esp)
  800ea6:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800eaa:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eaf:	b8 04 00 00 00       	mov    $0x4,%eax
  800eb4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb7:	8b 55 08             	mov    0x8(%ebp),%edx
  800eba:	89 df                	mov    %ebx,%edi
  800ebc:	51                   	push   %ecx
  800ebd:	52                   	push   %edx
  800ebe:	53                   	push   %ebx
  800ebf:	54                   	push   %esp
  800ec0:	55                   	push   %ebp
  800ec1:	56                   	push   %esi
  800ec2:	57                   	push   %edi
  800ec3:	5f                   	pop    %edi
  800ec4:	5e                   	pop    %esi
  800ec5:	5d                   	pop    %ebp
  800ec6:	5c                   	pop    %esp
  800ec7:	5b                   	pop    %ebx
  800ec8:	5a                   	pop    %edx
  800ec9:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800eca:	8b 1c 24             	mov    (%esp),%ebx
  800ecd:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ed1:	89 ec                	mov    %ebp,%esp
  800ed3:	5d                   	pop    %ebp
  800ed4:	c3                   	ret    

00800ed5 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  800ed5:	55                   	push   %ebp
  800ed6:	89 e5                	mov    %esp,%ebp
  800ed8:	83 ec 08             	sub    $0x8,%esp
  800edb:	89 1c 24             	mov    %ebx,(%esp)
  800ede:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800ee2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ee7:	b8 05 00 00 00       	mov    $0x5,%eax
  800eec:	8b 55 08             	mov    0x8(%ebp),%edx
  800eef:	89 cb                	mov    %ecx,%ebx
  800ef1:	89 cf                	mov    %ecx,%edi
  800ef3:	51                   	push   %ecx
  800ef4:	52                   	push   %edx
  800ef5:	53                   	push   %ebx
  800ef6:	54                   	push   %esp
  800ef7:	55                   	push   %ebp
  800ef8:	56                   	push   %esi
  800ef9:	57                   	push   %edi
  800efa:	5f                   	pop    %edi
  800efb:	5e                   	pop    %esi
  800efc:	5d                   	pop    %ebp
  800efd:	5c                   	pop    %esp
  800efe:	5b                   	pop    %ebx
  800eff:	5a                   	pop    %edx
  800f00:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800f01:	8b 1c 24             	mov    (%esp),%ebx
  800f04:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f08:	89 ec                	mov    %ebp,%esp
  800f0a:	5d                   	pop    %ebp
  800f0b:	c3                   	ret    

00800f0c <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800f0c:	55                   	push   %ebp
  800f0d:	89 e5                	mov    %esp,%ebp
  800f0f:	83 ec 28             	sub    $0x28,%esp
  800f12:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800f15:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f18:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f1d:	b8 03 00 00 00       	mov    $0x3,%eax
  800f22:	8b 55 08             	mov    0x8(%ebp),%edx
  800f25:	89 cb                	mov    %ecx,%ebx
  800f27:	89 cf                	mov    %ecx,%edi
  800f29:	51                   	push   %ecx
  800f2a:	52                   	push   %edx
  800f2b:	53                   	push   %ebx
  800f2c:	54                   	push   %esp
  800f2d:	55                   	push   %ebp
  800f2e:	56                   	push   %esi
  800f2f:	57                   	push   %edi
  800f30:	5f                   	pop    %edi
  800f31:	5e                   	pop    %esi
  800f32:	5d                   	pop    %ebp
  800f33:	5c                   	pop    %esp
  800f34:	5b                   	pop    %ebx
  800f35:	5a                   	pop    %edx
  800f36:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800f37:	85 c0                	test   %eax,%eax
  800f39:	7e 28                	jle    800f63 <sys_env_destroy+0x57>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f3b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f3f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800f46:	00 
  800f47:	c7 44 24 08 10 15 80 	movl   $0x801510,0x8(%esp)
  800f4e:	00 
  800f4f:	c7 44 24 04 26 00 00 	movl   $0x26,0x4(%esp)
  800f56:	00 
  800f57:	c7 04 24 2d 15 80 00 	movl   $0x80152d,(%esp)
  800f5e:	e8 0d 00 00 00       	call   800f70 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800f63:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800f66:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f69:	89 ec                	mov    %ebp,%esp
  800f6b:	5d                   	pop    %ebp
  800f6c:	c3                   	ret    
  800f6d:	00 00                	add    %al,(%eax)
	...

00800f70 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800f70:	55                   	push   %ebp
  800f71:	89 e5                	mov    %esp,%ebp
  800f73:	56                   	push   %esi
  800f74:	53                   	push   %ebx
  800f75:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  800f78:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  800f7b:	a1 08 20 80 00       	mov    0x802008,%eax
  800f80:	85 c0                	test   %eax,%eax
  800f82:	74 10                	je     800f94 <_panic+0x24>
		cprintf("%s: ", argv0);
  800f84:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f88:	c7 04 24 3b 15 80 00 	movl   $0x80153b,(%esp)
  800f8f:	e8 a1 f1 ff ff       	call   800135 <cprintf>
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800f94:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800f9a:	e8 c8 fe ff ff       	call   800e67 <sys_getenvid>
  800f9f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fa2:	89 54 24 10          	mov    %edx,0x10(%esp)
  800fa6:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800fad:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800fb1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fb5:	c7 04 24 40 15 80 00 	movl   $0x801540,(%esp)
  800fbc:	e8 74 f1 ff ff       	call   800135 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800fc1:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fc5:	8b 45 10             	mov    0x10(%ebp),%eax
  800fc8:	89 04 24             	mov    %eax,(%esp)
  800fcb:	e8 04 f1 ff ff       	call   8000d4 <vcprintf>
	cprintf("\n");
  800fd0:	c7 04 24 5e 12 80 00 	movl   $0x80125e,(%esp)
  800fd7:	e8 59 f1 ff ff       	call   800135 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800fdc:	cc                   	int3   
  800fdd:	eb fd                	jmp    800fdc <_panic+0x6c>
	...

00800fe0 <__udivdi3>:
  800fe0:	55                   	push   %ebp
  800fe1:	89 e5                	mov    %esp,%ebp
  800fe3:	57                   	push   %edi
  800fe4:	56                   	push   %esi
  800fe5:	83 ec 10             	sub    $0x10,%esp
  800fe8:	8b 45 14             	mov    0x14(%ebp),%eax
  800feb:	8b 55 08             	mov    0x8(%ebp),%edx
  800fee:	8b 75 10             	mov    0x10(%ebp),%esi
  800ff1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800ff4:	85 c0                	test   %eax,%eax
  800ff6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  800ff9:	75 35                	jne    801030 <__udivdi3+0x50>
  800ffb:	39 fe                	cmp    %edi,%esi
  800ffd:	77 61                	ja     801060 <__udivdi3+0x80>
  800fff:	85 f6                	test   %esi,%esi
  801001:	75 0b                	jne    80100e <__udivdi3+0x2e>
  801003:	b8 01 00 00 00       	mov    $0x1,%eax
  801008:	31 d2                	xor    %edx,%edx
  80100a:	f7 f6                	div    %esi
  80100c:	89 c6                	mov    %eax,%esi
  80100e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801011:	31 d2                	xor    %edx,%edx
  801013:	89 f8                	mov    %edi,%eax
  801015:	f7 f6                	div    %esi
  801017:	89 c7                	mov    %eax,%edi
  801019:	89 c8                	mov    %ecx,%eax
  80101b:	f7 f6                	div    %esi
  80101d:	89 c1                	mov    %eax,%ecx
  80101f:	89 fa                	mov    %edi,%edx
  801021:	89 c8                	mov    %ecx,%eax
  801023:	83 c4 10             	add    $0x10,%esp
  801026:	5e                   	pop    %esi
  801027:	5f                   	pop    %edi
  801028:	5d                   	pop    %ebp
  801029:	c3                   	ret    
  80102a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801030:	39 f8                	cmp    %edi,%eax
  801032:	77 1c                	ja     801050 <__udivdi3+0x70>
  801034:	0f bd d0             	bsr    %eax,%edx
  801037:	83 f2 1f             	xor    $0x1f,%edx
  80103a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80103d:	75 39                	jne    801078 <__udivdi3+0x98>
  80103f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801042:	0f 86 a0 00 00 00    	jbe    8010e8 <__udivdi3+0x108>
  801048:	39 f8                	cmp    %edi,%eax
  80104a:	0f 82 98 00 00 00    	jb     8010e8 <__udivdi3+0x108>
  801050:	31 ff                	xor    %edi,%edi
  801052:	31 c9                	xor    %ecx,%ecx
  801054:	89 c8                	mov    %ecx,%eax
  801056:	89 fa                	mov    %edi,%edx
  801058:	83 c4 10             	add    $0x10,%esp
  80105b:	5e                   	pop    %esi
  80105c:	5f                   	pop    %edi
  80105d:	5d                   	pop    %ebp
  80105e:	c3                   	ret    
  80105f:	90                   	nop
  801060:	89 d1                	mov    %edx,%ecx
  801062:	89 fa                	mov    %edi,%edx
  801064:	89 c8                	mov    %ecx,%eax
  801066:	31 ff                	xor    %edi,%edi
  801068:	f7 f6                	div    %esi
  80106a:	89 c1                	mov    %eax,%ecx
  80106c:	89 fa                	mov    %edi,%edx
  80106e:	89 c8                	mov    %ecx,%eax
  801070:	83 c4 10             	add    $0x10,%esp
  801073:	5e                   	pop    %esi
  801074:	5f                   	pop    %edi
  801075:	5d                   	pop    %ebp
  801076:	c3                   	ret    
  801077:	90                   	nop
  801078:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80107c:	89 f2                	mov    %esi,%edx
  80107e:	d3 e0                	shl    %cl,%eax
  801080:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801083:	b8 20 00 00 00       	mov    $0x20,%eax
  801088:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80108b:	89 c1                	mov    %eax,%ecx
  80108d:	d3 ea                	shr    %cl,%edx
  80108f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801093:	0b 55 ec             	or     -0x14(%ebp),%edx
  801096:	d3 e6                	shl    %cl,%esi
  801098:	89 c1                	mov    %eax,%ecx
  80109a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80109d:	89 fe                	mov    %edi,%esi
  80109f:	d3 ee                	shr    %cl,%esi
  8010a1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8010a5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8010a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010ab:	d3 e7                	shl    %cl,%edi
  8010ad:	89 c1                	mov    %eax,%ecx
  8010af:	d3 ea                	shr    %cl,%edx
  8010b1:	09 d7                	or     %edx,%edi
  8010b3:	89 f2                	mov    %esi,%edx
  8010b5:	89 f8                	mov    %edi,%eax
  8010b7:	f7 75 ec             	divl   -0x14(%ebp)
  8010ba:	89 d6                	mov    %edx,%esi
  8010bc:	89 c7                	mov    %eax,%edi
  8010be:	f7 65 e8             	mull   -0x18(%ebp)
  8010c1:	39 d6                	cmp    %edx,%esi
  8010c3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8010c6:	72 30                	jb     8010f8 <__udivdi3+0x118>
  8010c8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010cb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8010cf:	d3 e2                	shl    %cl,%edx
  8010d1:	39 c2                	cmp    %eax,%edx
  8010d3:	73 05                	jae    8010da <__udivdi3+0xfa>
  8010d5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  8010d8:	74 1e                	je     8010f8 <__udivdi3+0x118>
  8010da:	89 f9                	mov    %edi,%ecx
  8010dc:	31 ff                	xor    %edi,%edi
  8010de:	e9 71 ff ff ff       	jmp    801054 <__udivdi3+0x74>
  8010e3:	90                   	nop
  8010e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010e8:	31 ff                	xor    %edi,%edi
  8010ea:	b9 01 00 00 00       	mov    $0x1,%ecx
  8010ef:	e9 60 ff ff ff       	jmp    801054 <__udivdi3+0x74>
  8010f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010f8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  8010fb:	31 ff                	xor    %edi,%edi
  8010fd:	89 c8                	mov    %ecx,%eax
  8010ff:	89 fa                	mov    %edi,%edx
  801101:	83 c4 10             	add    $0x10,%esp
  801104:	5e                   	pop    %esi
  801105:	5f                   	pop    %edi
  801106:	5d                   	pop    %ebp
  801107:	c3                   	ret    
	...

00801110 <__umoddi3>:
  801110:	55                   	push   %ebp
  801111:	89 e5                	mov    %esp,%ebp
  801113:	57                   	push   %edi
  801114:	56                   	push   %esi
  801115:	83 ec 20             	sub    $0x20,%esp
  801118:	8b 55 14             	mov    0x14(%ebp),%edx
  80111b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80111e:	8b 7d 10             	mov    0x10(%ebp),%edi
  801121:	8b 75 0c             	mov    0xc(%ebp),%esi
  801124:	85 d2                	test   %edx,%edx
  801126:	89 c8                	mov    %ecx,%eax
  801128:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80112b:	75 13                	jne    801140 <__umoddi3+0x30>
  80112d:	39 f7                	cmp    %esi,%edi
  80112f:	76 3f                	jbe    801170 <__umoddi3+0x60>
  801131:	89 f2                	mov    %esi,%edx
  801133:	f7 f7                	div    %edi
  801135:	89 d0                	mov    %edx,%eax
  801137:	31 d2                	xor    %edx,%edx
  801139:	83 c4 20             	add    $0x20,%esp
  80113c:	5e                   	pop    %esi
  80113d:	5f                   	pop    %edi
  80113e:	5d                   	pop    %ebp
  80113f:	c3                   	ret    
  801140:	39 f2                	cmp    %esi,%edx
  801142:	77 4c                	ja     801190 <__umoddi3+0x80>
  801144:	0f bd ca             	bsr    %edx,%ecx
  801147:	83 f1 1f             	xor    $0x1f,%ecx
  80114a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80114d:	75 51                	jne    8011a0 <__umoddi3+0x90>
  80114f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801152:	0f 87 e0 00 00 00    	ja     801238 <__umoddi3+0x128>
  801158:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80115b:	29 f8                	sub    %edi,%eax
  80115d:	19 d6                	sbb    %edx,%esi
  80115f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801162:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801165:	89 f2                	mov    %esi,%edx
  801167:	83 c4 20             	add    $0x20,%esp
  80116a:	5e                   	pop    %esi
  80116b:	5f                   	pop    %edi
  80116c:	5d                   	pop    %ebp
  80116d:	c3                   	ret    
  80116e:	66 90                	xchg   %ax,%ax
  801170:	85 ff                	test   %edi,%edi
  801172:	75 0b                	jne    80117f <__umoddi3+0x6f>
  801174:	b8 01 00 00 00       	mov    $0x1,%eax
  801179:	31 d2                	xor    %edx,%edx
  80117b:	f7 f7                	div    %edi
  80117d:	89 c7                	mov    %eax,%edi
  80117f:	89 f0                	mov    %esi,%eax
  801181:	31 d2                	xor    %edx,%edx
  801183:	f7 f7                	div    %edi
  801185:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801188:	f7 f7                	div    %edi
  80118a:	eb a9                	jmp    801135 <__umoddi3+0x25>
  80118c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801190:	89 c8                	mov    %ecx,%eax
  801192:	89 f2                	mov    %esi,%edx
  801194:	83 c4 20             	add    $0x20,%esp
  801197:	5e                   	pop    %esi
  801198:	5f                   	pop    %edi
  801199:	5d                   	pop    %ebp
  80119a:	c3                   	ret    
  80119b:	90                   	nop
  80119c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011a0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011a4:	d3 e2                	shl    %cl,%edx
  8011a6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8011a9:	ba 20 00 00 00       	mov    $0x20,%edx
  8011ae:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8011b1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8011b4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8011b8:	89 fa                	mov    %edi,%edx
  8011ba:	d3 ea                	shr    %cl,%edx
  8011bc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011c0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8011c3:	d3 e7                	shl    %cl,%edi
  8011c5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8011c9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8011cc:	89 f2                	mov    %esi,%edx
  8011ce:	89 7d e8             	mov    %edi,-0x18(%ebp)
  8011d1:	89 c7                	mov    %eax,%edi
  8011d3:	d3 ea                	shr    %cl,%edx
  8011d5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011d9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8011dc:	89 c2                	mov    %eax,%edx
  8011de:	d3 e6                	shl    %cl,%esi
  8011e0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8011e4:	d3 ea                	shr    %cl,%edx
  8011e6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011ea:	09 d6                	or     %edx,%esi
  8011ec:	89 f0                	mov    %esi,%eax
  8011ee:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8011f1:	d3 e7                	shl    %cl,%edi
  8011f3:	89 f2                	mov    %esi,%edx
  8011f5:	f7 75 f4             	divl   -0xc(%ebp)
  8011f8:	89 d6                	mov    %edx,%esi
  8011fa:	f7 65 e8             	mull   -0x18(%ebp)
  8011fd:	39 d6                	cmp    %edx,%esi
  8011ff:	72 2b                	jb     80122c <__umoddi3+0x11c>
  801201:	39 c7                	cmp    %eax,%edi
  801203:	72 23                	jb     801228 <__umoddi3+0x118>
  801205:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801209:	29 c7                	sub    %eax,%edi
  80120b:	19 d6                	sbb    %edx,%esi
  80120d:	89 f0                	mov    %esi,%eax
  80120f:	89 f2                	mov    %esi,%edx
  801211:	d3 ef                	shr    %cl,%edi
  801213:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801217:	d3 e0                	shl    %cl,%eax
  801219:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80121d:	09 f8                	or     %edi,%eax
  80121f:	d3 ea                	shr    %cl,%edx
  801221:	83 c4 20             	add    $0x20,%esp
  801224:	5e                   	pop    %esi
  801225:	5f                   	pop    %edi
  801226:	5d                   	pop    %ebp
  801227:	c3                   	ret    
  801228:	39 d6                	cmp    %edx,%esi
  80122a:	75 d9                	jne    801205 <__umoddi3+0xf5>
  80122c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80122f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801232:	eb d1                	jmp    801205 <__umoddi3+0xf5>
  801234:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801238:	39 f2                	cmp    %esi,%edx
  80123a:	0f 82 18 ff ff ff    	jb     801158 <__umoddi3+0x48>
  801240:	e9 1d ff ff ff       	jmp    801162 <__umoddi3+0x52>
