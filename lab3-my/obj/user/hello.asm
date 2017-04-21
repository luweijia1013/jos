
obj/user/hello:     file format elf32-i386


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
  80002c:	e8 2f 00 00 00       	call   800060 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	cprintf("hello, world\n");
  80003a:	c7 04 24 18 12 80 00 	movl   $0x801218,(%esp)
  800041:	e8 c7 00 00 00       	call   80010d <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800046:	a1 04 20 80 00       	mov    0x802004,%eax
  80004b:	8b 40 48             	mov    0x48(%eax),%eax
  80004e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800052:	c7 04 24 26 12 80 00 	movl   $0x801226,(%esp)
  800059:	e8 af 00 00 00       	call   80010d <cprintf>
}
  80005e:	c9                   	leave  
  80005f:	c3                   	ret    

00800060 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800060:	55                   	push   %ebp
  800061:	89 e5                	mov    %esp,%ebp
  800063:	83 ec 18             	sub    $0x18,%esp
  800066:	8b 45 08             	mov    0x8(%ebp),%eax
  800069:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80006c:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800073:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800076:	85 c0                	test   %eax,%eax
  800078:	7e 08                	jle    800082 <libmain+0x22>
		binaryname = argv[0];
  80007a:	8b 0a                	mov    (%edx),%ecx
  80007c:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  800082:	89 54 24 04          	mov    %edx,0x4(%esp)
  800086:	89 04 24             	mov    %eax,(%esp)
  800089:	e8 a6 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80008e:	e8 05 00 00 00       	call   800098 <exit>
}
  800093:	c9                   	leave  
  800094:	c3                   	ret    
  800095:	00 00                	add    %al,(%eax)
	...

00800098 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800098:	55                   	push   %ebp
  800099:	89 e5                	mov    %esp,%ebp
  80009b:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80009e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000a5:	e8 32 0e 00 00       	call   800edc <sys_env_destroy>
}
  8000aa:	c9                   	leave  
  8000ab:	c3                   	ret    

008000ac <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8000b5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8000bc:	00 00 00 
	b.cnt = 0;
  8000bf:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8000c6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8000c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000cc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8000d3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000d7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8000dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000e1:	c7 04 24 27 01 80 00 	movl   $0x800127,(%esp)
  8000e8:	e8 03 03 00 00       	call   8003f0 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8000ed:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8000f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000f7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8000fd:	89 04 24             	mov    %eax,(%esp)
  800100:	e8 c7 0c 00 00       	call   800dcc <sys_cputs>

	return b.cnt;
}
  800105:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80010b:	c9                   	leave  
  80010c:	c3                   	ret    

0080010d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80010d:	55                   	push   %ebp
  80010e:	89 e5                	mov    %esp,%ebp
  800110:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  800113:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800116:	89 44 24 04          	mov    %eax,0x4(%esp)
  80011a:	8b 45 08             	mov    0x8(%ebp),%eax
  80011d:	89 04 24             	mov    %eax,(%esp)
  800120:	e8 87 ff ff ff       	call   8000ac <vcprintf>
	va_end(ap);

	return cnt;
}
  800125:	c9                   	leave  
  800126:	c3                   	ret    

00800127 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800127:	55                   	push   %ebp
  800128:	89 e5                	mov    %esp,%ebp
  80012a:	53                   	push   %ebx
  80012b:	83 ec 14             	sub    $0x14,%esp
  80012e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800131:	8b 03                	mov    (%ebx),%eax
  800133:	8b 55 08             	mov    0x8(%ebp),%edx
  800136:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80013a:	83 c0 01             	add    $0x1,%eax
  80013d:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80013f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800144:	75 19                	jne    80015f <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800146:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80014d:	00 
  80014e:	8d 43 08             	lea    0x8(%ebx),%eax
  800151:	89 04 24             	mov    %eax,(%esp)
  800154:	e8 73 0c 00 00       	call   800dcc <sys_cputs>
		b->idx = 0;
  800159:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80015f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800163:	83 c4 14             	add    $0x14,%esp
  800166:	5b                   	pop    %ebx
  800167:	5d                   	pop    %ebp
  800168:	c3                   	ret    
  800169:	00 00                	add    %al,(%eax)
  80016b:	00 00                	add    %al,(%eax)
  80016d:	00 00                	add    %al,(%eax)
	...

00800170 <printnum_nopad>:

/*
* help function added by Lu to print only the num;
*/
static void printnum_nopad(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int *num_len){
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	83 ec 48             	sub    $0x48,%esp
  800176:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800179:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80017c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80017f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800182:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800185:	8b 45 08             	mov    0x8(%ebp),%eax
  800188:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80018b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80018e:	8b 45 10             	mov    0x10(%ebp),%eax
  800191:	8b 7d 14             	mov    0x14(%ebp),%edi
	if(num >= base){
  800194:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800197:	ba 00 00 00 00       	mov    $0x0,%edx
  80019c:	39 f2                	cmp    %esi,%edx
  80019e:	72 07                	jb     8001a7 <printnum_nopad+0x37>
  8001a0:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8001a3:	39 c8                	cmp    %ecx,%eax
  8001a5:	77 54                	ja     8001fb <printnum_nopad+0x8b>
		printnum_nopad(putch, putdat, num / base, base, num_len);
  8001a7:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8001ab:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001af:	8b 44 24 08          	mov    0x8(%esp),%eax
  8001b3:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8001b7:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8001ba:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8001bd:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8001c0:	89 54 24 08          	mov    %edx,0x8(%esp)
  8001c4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001cb:	00 
  8001cc:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8001cf:	89 0c 24             	mov    %ecx,(%esp)
  8001d2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001d6:	e8 d5 0d 00 00       	call   800fb0 <__udivdi3>
  8001db:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8001de:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  8001e1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8001e5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001e9:	89 04 24             	mov    %eax,(%esp)
  8001ec:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001f0:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8001f3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8001f6:	e8 75 ff ff ff       	call   800170 <printnum_nopad>
	}
	*num_len += 1 ;
  8001fb:	83 07 01             	addl   $0x1,(%edi)
	putch("0123456789abcdef"[num % base], putdat);
  8001fe:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800201:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800205:	8b 04 24             	mov    (%esp),%eax
  800208:	8b 54 24 04          	mov    0x4(%esp),%edx
  80020c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80020f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800212:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800215:	89 54 24 08          	mov    %edx,0x8(%esp)
  800219:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800220:	00 
  800221:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800224:	89 0c 24             	mov    %ecx,(%esp)
  800227:	89 74 24 04          	mov    %esi,0x4(%esp)
  80022b:	e8 b0 0e 00 00       	call   8010e0 <__umoddi3>
  800230:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800233:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800237:	0f be 80 47 12 80 00 	movsbl 0x801247(%eax),%eax
  80023e:	89 04 24             	mov    %eax,(%esp)
  800241:	ff 55 d4             	call   *-0x2c(%ebp)
}
  800244:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800247:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80024a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80024d:	89 ec                	mov    %ebp,%esp
  80024f:	5d                   	pop    %ebp
  800250:	c3                   	ret    

00800251 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800251:	55                   	push   %ebp
  800252:	89 e5                	mov    %esp,%ebp
  800254:	57                   	push   %edi
  800255:	56                   	push   %esi
  800256:	53                   	push   %ebx
  800257:	83 ec 5c             	sub    $0x5c,%esp
  80025a:	89 c7                	mov    %eax,%edi
  80025c:	89 d6                	mov    %edx,%esi
  80025e:	8b 45 08             	mov    0x8(%ebp),%eax
  800261:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800264:	8b 55 0c             	mov    0xc(%ebp),%edx
  800267:	89 55 cc             	mov    %edx,-0x34(%ebp)
  80026a:	8b 45 10             	mov    0x10(%ebp),%eax
  80026d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	if(padc == '-'){
  800270:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  800274:	75 4c                	jne    8002c2 <printnum+0x71>
		int num_len = 0;
  800276:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		printnum_nopad(putch, putdat, num, base, &num_len);
  80027d:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800280:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800284:	89 44 24 08          	mov    %eax,0x8(%esp)
  800288:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80028b:	89 0c 24             	mov    %ecx,(%esp)
  80028e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800291:	89 44 24 04          	mov    %eax,0x4(%esp)
  800295:	89 f2                	mov    %esi,%edx
  800297:	89 f8                	mov    %edi,%eax
  800299:	e8 d2 fe ff ff       	call   800170 <printnum_nopad>
		width -= num_len;
  80029e:	2b 5d e4             	sub    -0x1c(%ebp),%ebx
		while (width-- > 0)
  8002a1:	85 db                	test   %ebx,%ebx
  8002a3:	0f 8e e8 00 00 00    	jle    800391 <printnum+0x140>
			putch(' ', putdat);
  8002a9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002ad:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8002b4:	ff d7                	call   *%edi
  8002b6:	83 eb 01             	sub    $0x1,%ebx
	// your code here:
	if(padc == '-'){
		int num_len = 0;
		printnum_nopad(putch, putdat, num, base, &num_len);
		width -= num_len;
		while (width-- > 0)
  8002b9:	85 db                	test   %ebx,%ebx
  8002bb:	7f ec                	jg     8002a9 <printnum+0x58>
  8002bd:	e9 cf 00 00 00       	jmp    800391 <printnum+0x140>
			putch(' ', putdat);
	}
	else{
		// first recursively print all preceding (more significant) digits
		if (num >= base) {
  8002c2:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8002c5:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8002c9:	77 19                	ja     8002e4 <printnum+0x93>
  8002cb:	90                   	nop
  8002cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8002d0:	72 05                	jb     8002d7 <printnum+0x86>
  8002d2:	39 45 c8             	cmp    %eax,-0x38(%ebp)
  8002d5:	73 0d                	jae    8002e4 <printnum+0x93>
			printnum(putch, putdat, num / base, base, width - 1, padc);
		} else {
			// print any needed pad characters before first digit
			while (--width > 0)
  8002d7:	83 eb 01             	sub    $0x1,%ebx
  8002da:	85 db                	test   %ebx,%ebx
  8002dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8002e0:	7f 63                	jg     800345 <printnum+0xf4>
  8002e2:	eb 74                	jmp    800358 <printnum+0x107>
			putch(' ', putdat);
	}
	else{
		// first recursively print all preceding (more significant) digits
		if (num >= base) {
			printnum(putch, putdat, num / base, base, width - 1, padc);
  8002e4:	8b 55 18             	mov    0x18(%ebp),%edx
  8002e7:	89 54 24 10          	mov    %edx,0x10(%esp)
  8002eb:	83 eb 01             	sub    $0x1,%ebx
  8002ee:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002f2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002f6:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8002fa:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8002fe:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800301:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800304:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  800307:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80030b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800312:	00 
  800313:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800316:	89 04 24             	mov    %eax,(%esp)
  800319:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80031c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800320:	e8 8b 0c 00 00       	call   800fb0 <__udivdi3>
  800325:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800328:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80032b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80032f:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800333:	89 04 24             	mov    %eax,(%esp)
  800336:	89 54 24 04          	mov    %edx,0x4(%esp)
  80033a:	89 f2                	mov    %esi,%edx
  80033c:	89 f8                	mov    %edi,%eax
  80033e:	e8 0e ff ff ff       	call   800251 <printnum>
  800343:	eb 13                	jmp    800358 <printnum+0x107>
		} else {
			// print any needed pad characters before first digit
			while (--width > 0)
				putch(padc, putdat);
  800345:	89 74 24 04          	mov    %esi,0x4(%esp)
  800349:	8b 45 18             	mov    0x18(%ebp),%eax
  80034c:	89 04 24             	mov    %eax,(%esp)
  80034f:	ff d7                	call   *%edi
		// first recursively print all preceding (more significant) digits
		if (num >= base) {
			printnum(putch, putdat, num / base, base, width - 1, padc);
		} else {
			// print any needed pad characters before first digit
			while (--width > 0)
  800351:	83 eb 01             	sub    $0x1,%ebx
  800354:	85 db                	test   %ebx,%ebx
  800356:	7f ed                	jg     800345 <printnum+0xf4>
				putch(padc, putdat);
		}

		// then print this (the least significant) digit
		putch("0123456789abcdef"[num % base], putdat);
  800358:	89 74 24 04          	mov    %esi,0x4(%esp)
  80035c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800360:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800363:	89 54 24 08          	mov    %edx,0x8(%esp)
  800367:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80036e:	00 
  80036f:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800372:	89 0c 24             	mov    %ecx,(%esp)
  800375:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800378:	89 44 24 04          	mov    %eax,0x4(%esp)
  80037c:	e8 5f 0d 00 00       	call   8010e0 <__umoddi3>
  800381:	89 74 24 04          	mov    %esi,0x4(%esp)
  800385:	0f be 80 47 12 80 00 	movsbl 0x801247(%eax),%eax
  80038c:	89 04 24             	mov    %eax,(%esp)
  80038f:	ff d7                	call   *%edi
	}
	
}
  800391:	83 c4 5c             	add    $0x5c,%esp
  800394:	5b                   	pop    %ebx
  800395:	5e                   	pop    %esi
  800396:	5f                   	pop    %edi
  800397:	5d                   	pop    %ebp
  800398:	c3                   	ret    

00800399 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800399:	55                   	push   %ebp
  80039a:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80039c:	83 fa 01             	cmp    $0x1,%edx
  80039f:	7e 0e                	jle    8003af <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003a1:	8b 10                	mov    (%eax),%edx
  8003a3:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003a6:	89 08                	mov    %ecx,(%eax)
  8003a8:	8b 02                	mov    (%edx),%eax
  8003aa:	8b 52 04             	mov    0x4(%edx),%edx
  8003ad:	eb 22                	jmp    8003d1 <getuint+0x38>
	else if (lflag)
  8003af:	85 d2                	test   %edx,%edx
  8003b1:	74 10                	je     8003c3 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003b3:	8b 10                	mov    (%eax),%edx
  8003b5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003b8:	89 08                	mov    %ecx,(%eax)
  8003ba:	8b 02                	mov    (%edx),%eax
  8003bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8003c1:	eb 0e                	jmp    8003d1 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003c3:	8b 10                	mov    (%eax),%edx
  8003c5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003c8:	89 08                	mov    %ecx,(%eax)
  8003ca:	8b 02                	mov    (%edx),%eax
  8003cc:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003d1:	5d                   	pop    %ebp
  8003d2:	c3                   	ret    

008003d3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003d3:	55                   	push   %ebp
  8003d4:	89 e5                	mov    %esp,%ebp
  8003d6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003d9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003dd:	8b 10                	mov    (%eax),%edx
  8003df:	3b 50 04             	cmp    0x4(%eax),%edx
  8003e2:	73 0a                	jae    8003ee <sprintputch+0x1b>
		*b->buf++ = ch;
  8003e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003e7:	88 0a                	mov    %cl,(%edx)
  8003e9:	83 c2 01             	add    $0x1,%edx
  8003ec:	89 10                	mov    %edx,(%eax)
}
  8003ee:	5d                   	pop    %ebp
  8003ef:	c3                   	ret    

008003f0 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003f0:	55                   	push   %ebp
  8003f1:	89 e5                	mov    %esp,%ebp
  8003f3:	57                   	push   %edi
  8003f4:	56                   	push   %esi
  8003f5:	53                   	push   %ebx
  8003f6:	83 ec 5c             	sub    $0x5c,%esp
  8003f9:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8003fc:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8003ff:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800406:	eb 12                	jmp    80041a <vprintfmt+0x2a>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800408:	85 c0                	test   %eax,%eax
  80040a:	0f 84 c6 04 00 00    	je     8008d6 <vprintfmt+0x4e6>
				return;
			putch(ch, putdat);
  800410:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800414:	89 04 24             	mov    %eax,(%esp)
  800417:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80041a:	0f b6 03             	movzbl (%ebx),%eax
  80041d:	83 c3 01             	add    $0x1,%ebx
  800420:	83 f8 25             	cmp    $0x25,%eax
  800423:	75 e3                	jne    800408 <vprintfmt+0x18>
  800425:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  800429:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800430:	be ff ff ff ff       	mov    $0xffffffff,%esi
  800435:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  80043c:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800443:	eb 06                	jmp    80044b <vprintfmt+0x5b>
  800445:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  800449:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044b:	0f b6 0b             	movzbl (%ebx),%ecx
  80044e:	0f b6 d1             	movzbl %cl,%edx
  800451:	8d 43 01             	lea    0x1(%ebx),%eax
  800454:	83 e9 23             	sub    $0x23,%ecx
  800457:	80 f9 55             	cmp    $0x55,%cl
  80045a:	0f 87 58 04 00 00    	ja     8008b8 <vprintfmt+0x4c8>
  800460:	0f b6 c9             	movzbl %cl,%ecx
  800463:	ff 24 8d 50 13 80 00 	jmp    *0x801350(,%ecx,4)
  80046a:	c6 45 e0 2b          	movb   $0x2b,-0x20(%ebp)
  80046e:	eb d9                	jmp    800449 <vprintfmt+0x59>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800470:	8d 72 d0             	lea    -0x30(%edx),%esi
				ch = *fmt;
  800473:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800476:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800479:	83 f9 09             	cmp    $0x9,%ecx
  80047c:	76 08                	jbe    800486 <vprintfmt+0x96>
  80047e:	eb 40                	jmp    8004c0 <vprintfmt+0xd0>
  800480:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
			goto reswitch;
  800484:	eb c3                	jmp    800449 <vprintfmt+0x59>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800486:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  800489:	8d 0c b6             	lea    (%esi,%esi,4),%ecx
  80048c:	8d 74 4a d0          	lea    -0x30(%edx,%ecx,2),%esi
				ch = *fmt;
  800490:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800493:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800496:	83 f9 09             	cmp    $0x9,%ecx
  800499:	76 eb                	jbe    800486 <vprintfmt+0x96>
  80049b:	eb 23                	jmp    8004c0 <vprintfmt+0xd0>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80049d:	8b 55 14             	mov    0x14(%ebp),%edx
  8004a0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004a3:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004a6:	8b 32                	mov    (%edx),%esi
			goto process_precision;
  8004a8:	eb 16                	jmp    8004c0 <vprintfmt+0xd0>

		case '.':
			if (width < 0)
  8004aa:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8004ad:	c1 fa 1f             	sar    $0x1f,%edx
  8004b0:	f7 d2                	not    %edx
  8004b2:	21 55 dc             	and    %edx,-0x24(%ebp)
  8004b5:	eb 92                	jmp    800449 <vprintfmt+0x59>
  8004b7:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8004be:	eb 89                	jmp    800449 <vprintfmt+0x59>

		process_precision:
			if (width < 0)
  8004c0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004c4:	79 83                	jns    800449 <vprintfmt+0x59>
  8004c6:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8004c9:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8004cc:	e9 78 ff ff ff       	jmp    800449 <vprintfmt+0x59>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004d1:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
			goto reswitch;
  8004d5:	e9 6f ff ff ff       	jmp    800449 <vprintfmt+0x59>
  8004da:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e0:	8d 50 04             	lea    0x4(%eax),%edx
  8004e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004ea:	8b 00                	mov    (%eax),%eax
  8004ec:	89 04 24             	mov    %eax,(%esp)
  8004ef:	ff 55 08             	call   *0x8(%ebp)
  8004f2:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  8004f5:	e9 20 ff ff ff       	jmp    80041a <vprintfmt+0x2a>
  8004fa:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800500:	8d 50 04             	lea    0x4(%eax),%edx
  800503:	89 55 14             	mov    %edx,0x14(%ebp)
  800506:	8b 00                	mov    (%eax),%eax
  800508:	89 c2                	mov    %eax,%edx
  80050a:	c1 fa 1f             	sar    $0x1f,%edx
  80050d:	31 d0                	xor    %edx,%eax
  80050f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800511:	83 f8 06             	cmp    $0x6,%eax
  800514:	7f 0b                	jg     800521 <vprintfmt+0x131>
  800516:	8b 14 85 a8 14 80 00 	mov    0x8014a8(,%eax,4),%edx
  80051d:	85 d2                	test   %edx,%edx
  80051f:	75 23                	jne    800544 <vprintfmt+0x154>
				printfmt(putch, putdat, "error %d", err);
  800521:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800525:	c7 44 24 08 58 12 80 	movl   $0x801258,0x8(%esp)
  80052c:	00 
  80052d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800531:	8b 45 08             	mov    0x8(%ebp),%eax
  800534:	89 04 24             	mov    %eax,(%esp)
  800537:	e8 22 04 00 00       	call   80095e <printfmt>
  80053c:	8b 5d cc             	mov    -0x34(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80053f:	e9 d6 fe ff ff       	jmp    80041a <vprintfmt+0x2a>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800544:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800548:	c7 44 24 08 61 12 80 	movl   $0x801261,0x8(%esp)
  80054f:	00 
  800550:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800554:	8b 55 08             	mov    0x8(%ebp),%edx
  800557:	89 14 24             	mov    %edx,(%esp)
  80055a:	e8 ff 03 00 00       	call   80095e <printfmt>
  80055f:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800562:	e9 b3 fe ff ff       	jmp    80041a <vprintfmt+0x2a>
  800567:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80056a:	89 c3                	mov    %eax,%ebx
  80056c:	89 f1                	mov    %esi,%ecx
  80056e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800571:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800574:	8b 45 14             	mov    0x14(%ebp),%eax
  800577:	8d 50 04             	lea    0x4(%eax),%edx
  80057a:	89 55 14             	mov    %edx,0x14(%ebp)
  80057d:	8b 00                	mov    (%eax),%eax
  80057f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800582:	85 c0                	test   %eax,%eax
  800584:	75 07                	jne    80058d <vprintfmt+0x19d>
  800586:	c7 45 d0 64 12 80 00 	movl   $0x801264,-0x30(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  80058d:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  800591:	7e 06                	jle    800599 <vprintfmt+0x1a9>
  800593:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  800597:	75 13                	jne    8005ac <vprintfmt+0x1bc>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800599:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80059c:	0f be 02             	movsbl (%edx),%eax
  80059f:	85 c0                	test   %eax,%eax
  8005a1:	0f 85 a2 00 00 00    	jne    800649 <vprintfmt+0x259>
  8005a7:	e9 8f 00 00 00       	jmp    80063b <vprintfmt+0x24b>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005ac:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005b0:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8005b3:	89 0c 24             	mov    %ecx,(%esp)
  8005b6:	e8 f0 03 00 00       	call   8009ab <strnlen>
  8005bb:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8005be:	29 c2                	sub    %eax,%edx
  8005c0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005c3:	85 d2                	test   %edx,%edx
  8005c5:	7e d2                	jle    800599 <vprintfmt+0x1a9>
					putch(padc, putdat);
  8005c7:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  8005cb:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  8005ce:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  8005d1:	89 d3                	mov    %edx,%ebx
  8005d3:	89 ce                	mov    %ecx,%esi
  8005d5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005d9:	89 34 24             	mov    %esi,(%esp)
  8005dc:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005df:	83 eb 01             	sub    $0x1,%ebx
  8005e2:	85 db                	test   %ebx,%ebx
  8005e4:	7f ef                	jg     8005d5 <vprintfmt+0x1e5>
  8005e6:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  8005e9:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  8005ec:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8005f3:	eb a4                	jmp    800599 <vprintfmt+0x1a9>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005f5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005f9:	74 1b                	je     800616 <vprintfmt+0x226>
  8005fb:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005fe:	83 fa 5e             	cmp    $0x5e,%edx
  800601:	76 13                	jbe    800616 <vprintfmt+0x226>
					putch('?', putdat);
  800603:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800606:	89 44 24 04          	mov    %eax,0x4(%esp)
  80060a:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800611:	ff 55 08             	call   *0x8(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800614:	eb 0d                	jmp    800623 <vprintfmt+0x233>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800616:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800619:	89 54 24 04          	mov    %edx,0x4(%esp)
  80061d:	89 04 24             	mov    %eax,(%esp)
  800620:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800623:	83 ef 01             	sub    $0x1,%edi
  800626:	0f be 03             	movsbl (%ebx),%eax
  800629:	85 c0                	test   %eax,%eax
  80062b:	74 05                	je     800632 <vprintfmt+0x242>
  80062d:	83 c3 01             	add    $0x1,%ebx
  800630:	eb 28                	jmp    80065a <vprintfmt+0x26a>
  800632:	89 7d dc             	mov    %edi,-0x24(%ebp)
  800635:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800638:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80063b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80063f:	7f 2d                	jg     80066e <vprintfmt+0x27e>
  800641:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800644:	e9 d1 fd ff ff       	jmp    80041a <vprintfmt+0x2a>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800649:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80064c:	83 c1 01             	add    $0x1,%ecx
  80064f:	89 7d e0             	mov    %edi,-0x20(%ebp)
  800652:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800655:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  800658:	89 cb                	mov    %ecx,%ebx
  80065a:	85 f6                	test   %esi,%esi
  80065c:	78 97                	js     8005f5 <vprintfmt+0x205>
  80065e:	83 ee 01             	sub    $0x1,%esi
  800661:	79 92                	jns    8005f5 <vprintfmt+0x205>
  800663:	89 7d dc             	mov    %edi,-0x24(%ebp)
  800666:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800669:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  80066c:	eb cd                	jmp    80063b <vprintfmt+0x24b>
  80066e:	8b 75 08             	mov    0x8(%ebp),%esi
  800671:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800674:	8b 5d dc             	mov    -0x24(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800677:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80067b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800682:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800684:	83 eb 01             	sub    $0x1,%ebx
  800687:	85 db                	test   %ebx,%ebx
  800689:	7f ec                	jg     800677 <vprintfmt+0x287>
  80068b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80068e:	e9 87 fd ff ff       	jmp    80041a <vprintfmt+0x2a>
  800693:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800696:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
  80069a:	88 45 e4             	mov    %al,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80069d:	83 7d d0 01          	cmpl   $0x1,-0x30(%ebp)
  8006a1:	7e 16                	jle    8006b9 <vprintfmt+0x2c9>
		return va_arg(*ap, long long);
  8006a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a6:	8d 50 08             	lea    0x8(%eax),%edx
  8006a9:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ac:	8b 10                	mov    (%eax),%edx
  8006ae:	8b 48 04             	mov    0x4(%eax),%ecx
  8006b1:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8006b4:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8006b7:	eb 34                	jmp    8006ed <vprintfmt+0x2fd>
	else if (lflag)
  8006b9:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8006bd:	74 18                	je     8006d7 <vprintfmt+0x2e7>
		return va_arg(*ap, long);
  8006bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c2:	8d 50 04             	lea    0x4(%eax),%edx
  8006c5:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c8:	8b 00                	mov    (%eax),%eax
  8006ca:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006cd:	89 c1                	mov    %eax,%ecx
  8006cf:	c1 f9 1f             	sar    $0x1f,%ecx
  8006d2:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8006d5:	eb 16                	jmp    8006ed <vprintfmt+0x2fd>
	else
		return va_arg(*ap, int);
  8006d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006da:	8d 50 04             	lea    0x4(%eax),%edx
  8006dd:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e0:	8b 00                	mov    (%eax),%eax
  8006e2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006e5:	89 c2                	mov    %eax,%edx
  8006e7:	c1 fa 1f             	sar    $0x1f,%edx
  8006ea:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006ed:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8006f0:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if ((long long) num < 0) {
  8006f3:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8006f7:	79 2c                	jns    800725 <vprintfmt+0x335>
				putch('-', putdat);
  8006f9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006fd:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800704:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800707:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80070a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80070d:	f7 db                	neg    %ebx
  80070f:	83 d6 00             	adc    $0x0,%esi
  800712:	f7 de                	neg    %esi
  800714:	0f b6 4d e0          	movzbl -0x20(%ebp),%ecx
  800718:	88 4d e4             	mov    %cl,-0x1c(%ebp)
  80071b:	ba 0a 00 00 00       	mov    $0xa,%edx
  800720:	e9 db 00 00 00       	jmp    800800 <vprintfmt+0x410>
			}
			else if (padc == '+'){
  800725:	80 7d e4 2b          	cmpb   $0x2b,-0x1c(%ebp)
  800729:	74 11                	je     80073c <vprintfmt+0x34c>
  80072b:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
  80072f:	88 45 e4             	mov    %al,-0x1c(%ebp)
  800732:	ba 0a 00 00 00       	mov    $0xa,%edx
  800737:	e9 c4 00 00 00       	jmp    800800 <vprintfmt+0x410>
				putch('+', putdat);
  80073c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800740:	c7 04 24 2b 00 00 00 	movl   $0x2b,(%esp)
  800747:	ff 55 08             	call   *0x8(%ebp)
  80074a:	ba 0a 00 00 00       	mov    $0xa,%edx
  80074f:	e9 ac 00 00 00       	jmp    800800 <vprintfmt+0x410>
  800754:	89 45 cc             	mov    %eax,-0x34(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800757:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80075a:	8d 45 14             	lea    0x14(%ebp),%eax
  80075d:	e8 37 fc ff ff       	call   800399 <getuint>
  800762:	89 c3                	mov    %eax,%ebx
  800764:	89 d6                	mov    %edx,%esi
  800766:	0f b6 55 e0          	movzbl -0x20(%ebp),%edx
  80076a:	88 55 e4             	mov    %dl,-0x1c(%ebp)
  80076d:	ba 0a 00 00 00       	mov    $0xa,%edx
			base = 10;
			goto number;
  800772:	e9 89 00 00 00       	jmp    800800 <vprintfmt+0x410>
  800777:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) octal
		case 'o':
			putch('0', putdat);
  80077a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80077e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800785:	ff 55 08             	call   *0x8(%ebp)
			num = getuint(&ap, lflag);
  800788:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80078b:	8d 45 14             	lea    0x14(%ebp),%eax
  80078e:	e8 06 fc ff ff       	call   800399 <getuint>
  800793:	89 c3                	mov    %eax,%ebx
  800795:	89 d6                	mov    %edx,%esi
  800797:	0f b6 4d e0          	movzbl -0x20(%ebp),%ecx
  80079b:	88 4d e4             	mov    %cl,-0x1c(%ebp)
  80079e:	ba 08 00 00 00       	mov    $0x8,%edx
			base = 8;
			goto number;
  8007a3:	eb 5b                	jmp    800800 <vprintfmt+0x410>
  8007a5:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  8007a8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007ac:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007b3:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007b6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007ba:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007c1:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  8007c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c7:	8d 50 04             	lea    0x4(%eax),%edx
  8007ca:	89 55 14             	mov    %edx,0x14(%ebp)
  8007cd:	8b 18                	mov    (%eax),%ebx
  8007cf:	be 00 00 00 00       	mov    $0x0,%esi
  8007d4:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
  8007d8:	88 45 e4             	mov    %al,-0x1c(%ebp)
  8007db:	ba 10 00 00 00       	mov    $0x10,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007e0:	eb 1e                	jmp    800800 <vprintfmt+0x410>
  8007e2:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007e5:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8007e8:	8d 45 14             	lea    0x14(%ebp),%eax
  8007eb:	e8 a9 fb ff ff       	call   800399 <getuint>
  8007f0:	89 c3                	mov    %eax,%ebx
  8007f2:	89 d6                	mov    %edx,%esi
  8007f4:	0f b6 55 e0          	movzbl -0x20(%ebp),%edx
  8007f8:	88 55 e4             	mov    %dl,-0x1c(%ebp)
  8007fb:	ba 10 00 00 00       	mov    $0x10,%edx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800800:	0f be 45 e4          	movsbl -0x1c(%ebp),%eax
  800804:	89 44 24 10          	mov    %eax,0x10(%esp)
  800808:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80080b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80080f:	89 54 24 08          	mov    %edx,0x8(%esp)
  800813:	89 1c 24             	mov    %ebx,(%esp)
  800816:	89 74 24 04          	mov    %esi,0x4(%esp)
  80081a:	89 fa                	mov    %edi,%edx
  80081c:	8b 45 08             	mov    0x8(%ebp),%eax
  80081f:	e8 2d fa ff ff       	call   800251 <printnum>
  800824:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  800827:	e9 ee fb ff ff       	jmp    80041a <vprintfmt+0x2a>
  80082c:	89 45 cc             	mov    %eax,-0x34(%ebp)
            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
	    	uint32_t *num_now = putdat;
	    	char *ret_va = va_arg(ap, char *);
  80082f:	8b 45 14             	mov    0x14(%ebp),%eax
  800832:	8d 50 04             	lea    0x4(%eax),%edx
  800835:	89 55 14             	mov    %edx,0x14(%ebp)
  800838:	8b 00                	mov    (%eax),%eax
	    	if(ret_va == NULL){
  80083a:	85 c0                	test   %eax,%eax
  80083c:	75 27                	jne    800865 <vprintfmt+0x475>
				printfmt(putch, putdat, "%s", null_error);
  80083e:	c7 44 24 0c d4 12 80 	movl   $0x8012d4,0xc(%esp)
  800845:	00 
  800846:	c7 44 24 08 61 12 80 	movl   $0x801261,0x8(%esp)
  80084d:	00 
  80084e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800852:	8b 45 08             	mov    0x8(%ebp),%eax
  800855:	89 04 24             	mov    %eax,(%esp)
  800858:	e8 01 01 00 00       	call   80095e <printfmt>
  80085d:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800860:	e9 b5 fb ff ff       	jmp    80041a <vprintfmt+0x2a>
	    	}
	    	else if ((*num_now) >> 7 != 0 ){		//how to aurrately discribe overflow?
  800865:	8b 17                	mov    (%edi),%edx
  800867:	89 d1                	mov    %edx,%ecx
  800869:	c1 e9 07             	shr    $0x7,%ecx
  80086c:	85 c9                	test   %ecx,%ecx
  80086e:	74 29                	je     800899 <vprintfmt+0x4a9>
				*ret_va = *(num_now);	//get putdat at first as next print instruction will change ret_va as it's a pointer which means it's dynamic;
  800870:	88 10                	mov    %dl,(%eax)
				printfmt(putch, putdat, "%s", overflow_error);
  800872:	c7 44 24 0c 0c 13 80 	movl   $0x80130c,0xc(%esp)
  800879:	00 
  80087a:	c7 44 24 08 61 12 80 	movl   $0x801261,0x8(%esp)
  800881:	00 
  800882:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800886:	8b 55 08             	mov    0x8(%ebp),%edx
  800889:	89 14 24             	mov    %edx,(%esp)
  80088c:	e8 cd 00 00 00       	call   80095e <printfmt>
  800891:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800894:	e9 81 fb ff ff       	jmp    80041a <vprintfmt+0x2a>
	    	}
	    	else{
				*ret_va = *(num_now);
  800899:	88 10                	mov    %dl,(%eax)
  80089b:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  80089e:	e9 77 fb ff ff       	jmp    80041a <vprintfmt+0x2a>
  8008a3:	89 45 cc             	mov    %eax,-0x34(%ebp)
            	break;
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008a6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008aa:	89 14 24             	mov    %edx,(%esp)
  8008ad:	ff 55 08             	call   *0x8(%ebp)
  8008b0:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  8008b3:	e9 62 fb ff ff       	jmp    80041a <vprintfmt+0x2a>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008b8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008bc:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8008c3:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008c6:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8008c9:	80 38 25             	cmpb   $0x25,(%eax)
  8008cc:	0f 84 48 fb ff ff    	je     80041a <vprintfmt+0x2a>
  8008d2:	89 c3                	mov    %eax,%ebx
  8008d4:	eb f0                	jmp    8008c6 <vprintfmt+0x4d6>
				/* do nothing */;
			break;
		}
	}
}
  8008d6:	83 c4 5c             	add    $0x5c,%esp
  8008d9:	5b                   	pop    %ebx
  8008da:	5e                   	pop    %esi
  8008db:	5f                   	pop    %edi
  8008dc:	5d                   	pop    %ebp
  8008dd:	c3                   	ret    

008008de <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008de:	55                   	push   %ebp
  8008df:	89 e5                	mov    %esp,%ebp
  8008e1:	83 ec 28             	sub    $0x28,%esp
  8008e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  8008ea:	85 c0                	test   %eax,%eax
  8008ec:	74 04                	je     8008f2 <vsnprintf+0x14>
  8008ee:	85 d2                	test   %edx,%edx
  8008f0:	7f 07                	jg     8008f9 <vsnprintf+0x1b>
  8008f2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008f7:	eb 3b                	jmp    800934 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008f9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008fc:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800900:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800903:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80090a:	8b 45 14             	mov    0x14(%ebp),%eax
  80090d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800911:	8b 45 10             	mov    0x10(%ebp),%eax
  800914:	89 44 24 08          	mov    %eax,0x8(%esp)
  800918:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80091b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80091f:	c7 04 24 d3 03 80 00 	movl   $0x8003d3,(%esp)
  800926:	e8 c5 fa ff ff       	call   8003f0 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80092b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80092e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800931:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800934:	c9                   	leave  
  800935:	c3                   	ret    

00800936 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800936:	55                   	push   %ebp
  800937:	89 e5                	mov    %esp,%ebp
  800939:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  80093c:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  80093f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800943:	8b 45 10             	mov    0x10(%ebp),%eax
  800946:	89 44 24 08          	mov    %eax,0x8(%esp)
  80094a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80094d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800951:	8b 45 08             	mov    0x8(%ebp),%eax
  800954:	89 04 24             	mov    %eax,(%esp)
  800957:	e8 82 ff ff ff       	call   8008de <vsnprintf>
	va_end(ap);

	return rc;
}
  80095c:	c9                   	leave  
  80095d:	c3                   	ret    

0080095e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80095e:	55                   	push   %ebp
  80095f:	89 e5                	mov    %esp,%ebp
  800961:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800964:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800967:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80096b:	8b 45 10             	mov    0x10(%ebp),%eax
  80096e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800972:	8b 45 0c             	mov    0xc(%ebp),%eax
  800975:	89 44 24 04          	mov    %eax,0x4(%esp)
  800979:	8b 45 08             	mov    0x8(%ebp),%eax
  80097c:	89 04 24             	mov    %eax,(%esp)
  80097f:	e8 6c fa ff ff       	call   8003f0 <vprintfmt>
	va_end(ap);
}
  800984:	c9                   	leave  
  800985:	c3                   	ret    
	...

00800990 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800990:	55                   	push   %ebp
  800991:	89 e5                	mov    %esp,%ebp
  800993:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800996:	b8 00 00 00 00       	mov    $0x0,%eax
  80099b:	80 3a 00             	cmpb   $0x0,(%edx)
  80099e:	74 09                	je     8009a9 <strlen+0x19>
		n++;
  8009a0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009a3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009a7:	75 f7                	jne    8009a0 <strlen+0x10>
		n++;
	return n;
}
  8009a9:	5d                   	pop    %ebp
  8009aa:	c3                   	ret    

008009ab <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	53                   	push   %ebx
  8009af:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009b5:	85 c9                	test   %ecx,%ecx
  8009b7:	74 19                	je     8009d2 <strnlen+0x27>
  8009b9:	80 3b 00             	cmpb   $0x0,(%ebx)
  8009bc:	74 14                	je     8009d2 <strnlen+0x27>
  8009be:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8009c3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009c6:	39 c8                	cmp    %ecx,%eax
  8009c8:	74 0d                	je     8009d7 <strnlen+0x2c>
  8009ca:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  8009ce:	75 f3                	jne    8009c3 <strnlen+0x18>
  8009d0:	eb 05                	jmp    8009d7 <strnlen+0x2c>
  8009d2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8009d7:	5b                   	pop    %ebx
  8009d8:	5d                   	pop    %ebp
  8009d9:	c3                   	ret    

008009da <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009da:	55                   	push   %ebp
  8009db:	89 e5                	mov    %esp,%ebp
  8009dd:	53                   	push   %ebx
  8009de:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009e4:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009e9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8009ed:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8009f0:	83 c2 01             	add    $0x1,%edx
  8009f3:	84 c9                	test   %cl,%cl
  8009f5:	75 f2                	jne    8009e9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8009f7:	5b                   	pop    %ebx
  8009f8:	5d                   	pop    %ebp
  8009f9:	c3                   	ret    

008009fa <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009fa:	55                   	push   %ebp
  8009fb:	89 e5                	mov    %esp,%ebp
  8009fd:	53                   	push   %ebx
  8009fe:	83 ec 08             	sub    $0x8,%esp
  800a01:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a04:	89 1c 24             	mov    %ebx,(%esp)
  800a07:	e8 84 ff ff ff       	call   800990 <strlen>
	strcpy(dst + len, src);
  800a0c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a0f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a13:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800a16:	89 04 24             	mov    %eax,(%esp)
  800a19:	e8 bc ff ff ff       	call   8009da <strcpy>
	return dst;
}
  800a1e:	89 d8                	mov    %ebx,%eax
  800a20:	83 c4 08             	add    $0x8,%esp
  800a23:	5b                   	pop    %ebx
  800a24:	5d                   	pop    %ebp
  800a25:	c3                   	ret    

00800a26 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a26:	55                   	push   %ebp
  800a27:	89 e5                	mov    %esp,%ebp
  800a29:	56                   	push   %esi
  800a2a:	53                   	push   %ebx
  800a2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a31:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a34:	85 f6                	test   %esi,%esi
  800a36:	74 18                	je     800a50 <strncpy+0x2a>
  800a38:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800a3d:	0f b6 1a             	movzbl (%edx),%ebx
  800a40:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a43:	80 3a 01             	cmpb   $0x1,(%edx)
  800a46:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a49:	83 c1 01             	add    $0x1,%ecx
  800a4c:	39 ce                	cmp    %ecx,%esi
  800a4e:	77 ed                	ja     800a3d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a50:	5b                   	pop    %ebx
  800a51:	5e                   	pop    %esi
  800a52:	5d                   	pop    %ebp
  800a53:	c3                   	ret    

00800a54 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a54:	55                   	push   %ebp
  800a55:	89 e5                	mov    %esp,%ebp
  800a57:	56                   	push   %esi
  800a58:	53                   	push   %ebx
  800a59:	8b 75 08             	mov    0x8(%ebp),%esi
  800a5c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a5f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a62:	89 f0                	mov    %esi,%eax
  800a64:	85 c9                	test   %ecx,%ecx
  800a66:	74 27                	je     800a8f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800a68:	83 e9 01             	sub    $0x1,%ecx
  800a6b:	74 1d                	je     800a8a <strlcpy+0x36>
  800a6d:	0f b6 1a             	movzbl (%edx),%ebx
  800a70:	84 db                	test   %bl,%bl
  800a72:	74 16                	je     800a8a <strlcpy+0x36>
			*dst++ = *src++;
  800a74:	88 18                	mov    %bl,(%eax)
  800a76:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a79:	83 e9 01             	sub    $0x1,%ecx
  800a7c:	74 0e                	je     800a8c <strlcpy+0x38>
			*dst++ = *src++;
  800a7e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a81:	0f b6 1a             	movzbl (%edx),%ebx
  800a84:	84 db                	test   %bl,%bl
  800a86:	75 ec                	jne    800a74 <strlcpy+0x20>
  800a88:	eb 02                	jmp    800a8c <strlcpy+0x38>
  800a8a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a8c:	c6 00 00             	movb   $0x0,(%eax)
  800a8f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800a91:	5b                   	pop    %ebx
  800a92:	5e                   	pop    %esi
  800a93:	5d                   	pop    %ebp
  800a94:	c3                   	ret    

00800a95 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a95:	55                   	push   %ebp
  800a96:	89 e5                	mov    %esp,%ebp
  800a98:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a9b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a9e:	0f b6 01             	movzbl (%ecx),%eax
  800aa1:	84 c0                	test   %al,%al
  800aa3:	74 15                	je     800aba <strcmp+0x25>
  800aa5:	3a 02                	cmp    (%edx),%al
  800aa7:	75 11                	jne    800aba <strcmp+0x25>
		p++, q++;
  800aa9:	83 c1 01             	add    $0x1,%ecx
  800aac:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800aaf:	0f b6 01             	movzbl (%ecx),%eax
  800ab2:	84 c0                	test   %al,%al
  800ab4:	74 04                	je     800aba <strcmp+0x25>
  800ab6:	3a 02                	cmp    (%edx),%al
  800ab8:	74 ef                	je     800aa9 <strcmp+0x14>
  800aba:	0f b6 c0             	movzbl %al,%eax
  800abd:	0f b6 12             	movzbl (%edx),%edx
  800ac0:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ac2:	5d                   	pop    %ebp
  800ac3:	c3                   	ret    

00800ac4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ac4:	55                   	push   %ebp
  800ac5:	89 e5                	mov    %esp,%ebp
  800ac7:	53                   	push   %ebx
  800ac8:	8b 55 08             	mov    0x8(%ebp),%edx
  800acb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ace:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800ad1:	85 c0                	test   %eax,%eax
  800ad3:	74 23                	je     800af8 <strncmp+0x34>
  800ad5:	0f b6 1a             	movzbl (%edx),%ebx
  800ad8:	84 db                	test   %bl,%bl
  800ada:	74 25                	je     800b01 <strncmp+0x3d>
  800adc:	3a 19                	cmp    (%ecx),%bl
  800ade:	75 21                	jne    800b01 <strncmp+0x3d>
  800ae0:	83 e8 01             	sub    $0x1,%eax
  800ae3:	74 13                	je     800af8 <strncmp+0x34>
		n--, p++, q++;
  800ae5:	83 c2 01             	add    $0x1,%edx
  800ae8:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800aeb:	0f b6 1a             	movzbl (%edx),%ebx
  800aee:	84 db                	test   %bl,%bl
  800af0:	74 0f                	je     800b01 <strncmp+0x3d>
  800af2:	3a 19                	cmp    (%ecx),%bl
  800af4:	74 ea                	je     800ae0 <strncmp+0x1c>
  800af6:	eb 09                	jmp    800b01 <strncmp+0x3d>
  800af8:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800afd:	5b                   	pop    %ebx
  800afe:	5d                   	pop    %ebp
  800aff:	90                   	nop
  800b00:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b01:	0f b6 02             	movzbl (%edx),%eax
  800b04:	0f b6 11             	movzbl (%ecx),%edx
  800b07:	29 d0                	sub    %edx,%eax
  800b09:	eb f2                	jmp    800afd <strncmp+0x39>

00800b0b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b0b:	55                   	push   %ebp
  800b0c:	89 e5                	mov    %esp,%ebp
  800b0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b11:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b15:	0f b6 10             	movzbl (%eax),%edx
  800b18:	84 d2                	test   %dl,%dl
  800b1a:	74 18                	je     800b34 <strchr+0x29>
		if (*s == c)
  800b1c:	38 ca                	cmp    %cl,%dl
  800b1e:	75 0a                	jne    800b2a <strchr+0x1f>
  800b20:	eb 17                	jmp    800b39 <strchr+0x2e>
  800b22:	38 ca                	cmp    %cl,%dl
  800b24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800b28:	74 0f                	je     800b39 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b2a:	83 c0 01             	add    $0x1,%eax
  800b2d:	0f b6 10             	movzbl (%eax),%edx
  800b30:	84 d2                	test   %dl,%dl
  800b32:	75 ee                	jne    800b22 <strchr+0x17>
  800b34:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800b39:	5d                   	pop    %ebp
  800b3a:	c3                   	ret    

00800b3b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b3b:	55                   	push   %ebp
  800b3c:	89 e5                	mov    %esp,%ebp
  800b3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b41:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b45:	0f b6 10             	movzbl (%eax),%edx
  800b48:	84 d2                	test   %dl,%dl
  800b4a:	74 18                	je     800b64 <strfind+0x29>
		if (*s == c)
  800b4c:	38 ca                	cmp    %cl,%dl
  800b4e:	75 0a                	jne    800b5a <strfind+0x1f>
  800b50:	eb 12                	jmp    800b64 <strfind+0x29>
  800b52:	38 ca                	cmp    %cl,%dl
  800b54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800b58:	74 0a                	je     800b64 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b5a:	83 c0 01             	add    $0x1,%eax
  800b5d:	0f b6 10             	movzbl (%eax),%edx
  800b60:	84 d2                	test   %dl,%dl
  800b62:	75 ee                	jne    800b52 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800b64:	5d                   	pop    %ebp
  800b65:	c3                   	ret    

00800b66 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b66:	55                   	push   %ebp
  800b67:	89 e5                	mov    %esp,%ebp
  800b69:	83 ec 0c             	sub    $0xc,%esp
  800b6c:	89 1c 24             	mov    %ebx,(%esp)
  800b6f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b73:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800b77:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b7d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b80:	85 c9                	test   %ecx,%ecx
  800b82:	74 30                	je     800bb4 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b84:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b8a:	75 25                	jne    800bb1 <memset+0x4b>
  800b8c:	f6 c1 03             	test   $0x3,%cl
  800b8f:	75 20                	jne    800bb1 <memset+0x4b>
		c &= 0xFF;
  800b91:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b94:	89 d3                	mov    %edx,%ebx
  800b96:	c1 e3 08             	shl    $0x8,%ebx
  800b99:	89 d6                	mov    %edx,%esi
  800b9b:	c1 e6 18             	shl    $0x18,%esi
  800b9e:	89 d0                	mov    %edx,%eax
  800ba0:	c1 e0 10             	shl    $0x10,%eax
  800ba3:	09 f0                	or     %esi,%eax
  800ba5:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800ba7:	09 d8                	or     %ebx,%eax
  800ba9:	c1 e9 02             	shr    $0x2,%ecx
  800bac:	fc                   	cld    
  800bad:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800baf:	eb 03                	jmp    800bb4 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bb1:	fc                   	cld    
  800bb2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bb4:	89 f8                	mov    %edi,%eax
  800bb6:	8b 1c 24             	mov    (%esp),%ebx
  800bb9:	8b 74 24 04          	mov    0x4(%esp),%esi
  800bbd:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800bc1:	89 ec                	mov    %ebp,%esp
  800bc3:	5d                   	pop    %ebp
  800bc4:	c3                   	ret    

00800bc5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bc5:	55                   	push   %ebp
  800bc6:	89 e5                	mov    %esp,%ebp
  800bc8:	83 ec 08             	sub    $0x8,%esp
  800bcb:	89 34 24             	mov    %esi,(%esp)
  800bce:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800bd2:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800bd8:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800bdb:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800bdd:	39 c6                	cmp    %eax,%esi
  800bdf:	73 35                	jae    800c16 <memmove+0x51>
  800be1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800be4:	39 d0                	cmp    %edx,%eax
  800be6:	73 2e                	jae    800c16 <memmove+0x51>
		s += n;
		d += n;
  800be8:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bea:	f6 c2 03             	test   $0x3,%dl
  800bed:	75 1b                	jne    800c0a <memmove+0x45>
  800bef:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bf5:	75 13                	jne    800c0a <memmove+0x45>
  800bf7:	f6 c1 03             	test   $0x3,%cl
  800bfa:	75 0e                	jne    800c0a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800bfc:	83 ef 04             	sub    $0x4,%edi
  800bff:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c02:	c1 e9 02             	shr    $0x2,%ecx
  800c05:	fd                   	std    
  800c06:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c08:	eb 09                	jmp    800c13 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c0a:	83 ef 01             	sub    $0x1,%edi
  800c0d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800c10:	fd                   	std    
  800c11:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c13:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c14:	eb 20                	jmp    800c36 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c16:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c1c:	75 15                	jne    800c33 <memmove+0x6e>
  800c1e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c24:	75 0d                	jne    800c33 <memmove+0x6e>
  800c26:	f6 c1 03             	test   $0x3,%cl
  800c29:	75 08                	jne    800c33 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800c2b:	c1 e9 02             	shr    $0x2,%ecx
  800c2e:	fc                   	cld    
  800c2f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c31:	eb 03                	jmp    800c36 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c33:	fc                   	cld    
  800c34:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c36:	8b 34 24             	mov    (%esp),%esi
  800c39:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800c3d:	89 ec                	mov    %ebp,%esp
  800c3f:	5d                   	pop    %ebp
  800c40:	c3                   	ret    

00800c41 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800c41:	55                   	push   %ebp
  800c42:	89 e5                	mov    %esp,%ebp
  800c44:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c47:	8b 45 10             	mov    0x10(%ebp),%eax
  800c4a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c4e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c51:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c55:	8b 45 08             	mov    0x8(%ebp),%eax
  800c58:	89 04 24             	mov    %eax,(%esp)
  800c5b:	e8 65 ff ff ff       	call   800bc5 <memmove>
}
  800c60:	c9                   	leave  
  800c61:	c3                   	ret    

00800c62 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c62:	55                   	push   %ebp
  800c63:	89 e5                	mov    %esp,%ebp
  800c65:	57                   	push   %edi
  800c66:	56                   	push   %esi
  800c67:	53                   	push   %ebx
  800c68:	8b 75 08             	mov    0x8(%ebp),%esi
  800c6b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800c6e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c71:	85 c9                	test   %ecx,%ecx
  800c73:	74 36                	je     800cab <memcmp+0x49>
		if (*s1 != *s2)
  800c75:	0f b6 06             	movzbl (%esi),%eax
  800c78:	0f b6 1f             	movzbl (%edi),%ebx
  800c7b:	38 d8                	cmp    %bl,%al
  800c7d:	74 20                	je     800c9f <memcmp+0x3d>
  800c7f:	eb 14                	jmp    800c95 <memcmp+0x33>
  800c81:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800c86:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800c8b:	83 c2 01             	add    $0x1,%edx
  800c8e:	83 e9 01             	sub    $0x1,%ecx
  800c91:	38 d8                	cmp    %bl,%al
  800c93:	74 12                	je     800ca7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800c95:	0f b6 c0             	movzbl %al,%eax
  800c98:	0f b6 db             	movzbl %bl,%ebx
  800c9b:	29 d8                	sub    %ebx,%eax
  800c9d:	eb 11                	jmp    800cb0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c9f:	83 e9 01             	sub    $0x1,%ecx
  800ca2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ca7:	85 c9                	test   %ecx,%ecx
  800ca9:	75 d6                	jne    800c81 <memcmp+0x1f>
  800cab:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800cb0:	5b                   	pop    %ebx
  800cb1:	5e                   	pop    %esi
  800cb2:	5f                   	pop    %edi
  800cb3:	5d                   	pop    %ebp
  800cb4:	c3                   	ret    

00800cb5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cb5:	55                   	push   %ebp
  800cb6:	89 e5                	mov    %esp,%ebp
  800cb8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800cbb:	89 c2                	mov    %eax,%edx
  800cbd:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800cc0:	39 d0                	cmp    %edx,%eax
  800cc2:	73 15                	jae    800cd9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cc4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800cc8:	38 08                	cmp    %cl,(%eax)
  800cca:	75 06                	jne    800cd2 <memfind+0x1d>
  800ccc:	eb 0b                	jmp    800cd9 <memfind+0x24>
  800cce:	38 08                	cmp    %cl,(%eax)
  800cd0:	74 07                	je     800cd9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cd2:	83 c0 01             	add    $0x1,%eax
  800cd5:	39 c2                	cmp    %eax,%edx
  800cd7:	77 f5                	ja     800cce <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800cd9:	5d                   	pop    %ebp
  800cda:	c3                   	ret    

00800cdb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cdb:	55                   	push   %ebp
  800cdc:	89 e5                	mov    %esp,%ebp
  800cde:	57                   	push   %edi
  800cdf:	56                   	push   %esi
  800ce0:	53                   	push   %ebx
  800ce1:	83 ec 04             	sub    $0x4,%esp
  800ce4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cea:	0f b6 02             	movzbl (%edx),%eax
  800ced:	3c 20                	cmp    $0x20,%al
  800cef:	74 04                	je     800cf5 <strtol+0x1a>
  800cf1:	3c 09                	cmp    $0x9,%al
  800cf3:	75 0e                	jne    800d03 <strtol+0x28>
		s++;
  800cf5:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cf8:	0f b6 02             	movzbl (%edx),%eax
  800cfb:	3c 20                	cmp    $0x20,%al
  800cfd:	74 f6                	je     800cf5 <strtol+0x1a>
  800cff:	3c 09                	cmp    $0x9,%al
  800d01:	74 f2                	je     800cf5 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d03:	3c 2b                	cmp    $0x2b,%al
  800d05:	75 0c                	jne    800d13 <strtol+0x38>
		s++;
  800d07:	83 c2 01             	add    $0x1,%edx
  800d0a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800d11:	eb 15                	jmp    800d28 <strtol+0x4d>
	else if (*s == '-')
  800d13:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800d1a:	3c 2d                	cmp    $0x2d,%al
  800d1c:	75 0a                	jne    800d28 <strtol+0x4d>
		s++, neg = 1;
  800d1e:	83 c2 01             	add    $0x1,%edx
  800d21:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d28:	85 db                	test   %ebx,%ebx
  800d2a:	0f 94 c0             	sete   %al
  800d2d:	74 05                	je     800d34 <strtol+0x59>
  800d2f:	83 fb 10             	cmp    $0x10,%ebx
  800d32:	75 18                	jne    800d4c <strtol+0x71>
  800d34:	80 3a 30             	cmpb   $0x30,(%edx)
  800d37:	75 13                	jne    800d4c <strtol+0x71>
  800d39:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d3d:	8d 76 00             	lea    0x0(%esi),%esi
  800d40:	75 0a                	jne    800d4c <strtol+0x71>
		s += 2, base = 16;
  800d42:	83 c2 02             	add    $0x2,%edx
  800d45:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d4a:	eb 15                	jmp    800d61 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d4c:	84 c0                	test   %al,%al
  800d4e:	66 90                	xchg   %ax,%ax
  800d50:	74 0f                	je     800d61 <strtol+0x86>
  800d52:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800d57:	80 3a 30             	cmpb   $0x30,(%edx)
  800d5a:	75 05                	jne    800d61 <strtol+0x86>
		s++, base = 8;
  800d5c:	83 c2 01             	add    $0x1,%edx
  800d5f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d61:	b8 00 00 00 00       	mov    $0x0,%eax
  800d66:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d68:	0f b6 0a             	movzbl (%edx),%ecx
  800d6b:	89 cf                	mov    %ecx,%edi
  800d6d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d70:	80 fb 09             	cmp    $0x9,%bl
  800d73:	77 08                	ja     800d7d <strtol+0xa2>
			dig = *s - '0';
  800d75:	0f be c9             	movsbl %cl,%ecx
  800d78:	83 e9 30             	sub    $0x30,%ecx
  800d7b:	eb 1e                	jmp    800d9b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800d7d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800d80:	80 fb 19             	cmp    $0x19,%bl
  800d83:	77 08                	ja     800d8d <strtol+0xb2>
			dig = *s - 'a' + 10;
  800d85:	0f be c9             	movsbl %cl,%ecx
  800d88:	83 e9 57             	sub    $0x57,%ecx
  800d8b:	eb 0e                	jmp    800d9b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800d8d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800d90:	80 fb 19             	cmp    $0x19,%bl
  800d93:	77 15                	ja     800daa <strtol+0xcf>
			dig = *s - 'A' + 10;
  800d95:	0f be c9             	movsbl %cl,%ecx
  800d98:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d9b:	39 f1                	cmp    %esi,%ecx
  800d9d:	7d 0b                	jge    800daa <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800d9f:	83 c2 01             	add    $0x1,%edx
  800da2:	0f af c6             	imul   %esi,%eax
  800da5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800da8:	eb be                	jmp    800d68 <strtol+0x8d>
  800daa:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800dac:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800db0:	74 05                	je     800db7 <strtol+0xdc>
		*endptr = (char *) s;
  800db2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800db5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800db7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800dbb:	74 04                	je     800dc1 <strtol+0xe6>
  800dbd:	89 c8                	mov    %ecx,%eax
  800dbf:	f7 d8                	neg    %eax
}
  800dc1:	83 c4 04             	add    $0x4,%esp
  800dc4:	5b                   	pop    %ebx
  800dc5:	5e                   	pop    %esi
  800dc6:	5f                   	pop    %edi
  800dc7:	5d                   	pop    %ebp
  800dc8:	c3                   	ret    
  800dc9:	00 00                	add    %al,(%eax)
	...

00800dcc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800dcc:	55                   	push   %ebp
  800dcd:	89 e5                	mov    %esp,%ebp
  800dcf:	83 ec 08             	sub    $0x8,%esp
  800dd2:	89 1c 24             	mov    %ebx,(%esp)
  800dd5:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800dd9:	b8 00 00 00 00       	mov    $0x0,%eax
  800dde:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de1:	8b 55 08             	mov    0x8(%ebp),%edx
  800de4:	89 c3                	mov    %eax,%ebx
  800de6:	89 c7                	mov    %eax,%edi
  800de8:	51                   	push   %ecx
  800de9:	52                   	push   %edx
  800dea:	53                   	push   %ebx
  800deb:	54                   	push   %esp
  800dec:	55                   	push   %ebp
  800ded:	56                   	push   %esi
  800dee:	57                   	push   %edi
  800def:	5f                   	pop    %edi
  800df0:	5e                   	pop    %esi
  800df1:	5d                   	pop    %ebp
  800df2:	5c                   	pop    %esp
  800df3:	5b                   	pop    %ebx
  800df4:	5a                   	pop    %edx
  800df5:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800df6:	8b 1c 24             	mov    (%esp),%ebx
  800df9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800dfd:	89 ec                	mov    %ebp,%esp
  800dff:	5d                   	pop    %ebp
  800e00:	c3                   	ret    

00800e01 <sys_cgetc>:

int
sys_cgetc(void)
{
  800e01:	55                   	push   %ebp
  800e02:	89 e5                	mov    %esp,%ebp
  800e04:	83 ec 08             	sub    $0x8,%esp
  800e07:	89 1c 24             	mov    %ebx,(%esp)
  800e0a:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e0e:	ba 00 00 00 00       	mov    $0x0,%edx
  800e13:	b8 01 00 00 00       	mov    $0x1,%eax
  800e18:	89 d1                	mov    %edx,%ecx
  800e1a:	89 d3                	mov    %edx,%ebx
  800e1c:	89 d7                	mov    %edx,%edi
  800e1e:	51                   	push   %ecx
  800e1f:	52                   	push   %edx
  800e20:	53                   	push   %ebx
  800e21:	54                   	push   %esp
  800e22:	55                   	push   %ebp
  800e23:	56                   	push   %esi
  800e24:	57                   	push   %edi
  800e25:	5f                   	pop    %edi
  800e26:	5e                   	pop    %esi
  800e27:	5d                   	pop    %ebp
  800e28:	5c                   	pop    %esp
  800e29:	5b                   	pop    %ebx
  800e2a:	5a                   	pop    %edx
  800e2b:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e2c:	8b 1c 24             	mov    (%esp),%ebx
  800e2f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e33:	89 ec                	mov    %ebp,%esp
  800e35:	5d                   	pop    %ebp
  800e36:	c3                   	ret    

00800e37 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800e37:	55                   	push   %ebp
  800e38:	89 e5                	mov    %esp,%ebp
  800e3a:	83 ec 08             	sub    $0x8,%esp
  800e3d:	89 1c 24             	mov    %ebx,(%esp)
  800e40:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e44:	ba 00 00 00 00       	mov    $0x0,%edx
  800e49:	b8 02 00 00 00       	mov    $0x2,%eax
  800e4e:	89 d1                	mov    %edx,%ecx
  800e50:	89 d3                	mov    %edx,%ebx
  800e52:	89 d7                	mov    %edx,%edi
  800e54:	51                   	push   %ecx
  800e55:	52                   	push   %edx
  800e56:	53                   	push   %ebx
  800e57:	54                   	push   %esp
  800e58:	55                   	push   %ebp
  800e59:	56                   	push   %esi
  800e5a:	57                   	push   %edi
  800e5b:	5f                   	pop    %edi
  800e5c:	5e                   	pop    %esi
  800e5d:	5d                   	pop    %ebp
  800e5e:	5c                   	pop    %esp
  800e5f:	5b                   	pop    %ebx
  800e60:	5a                   	pop    %edx
  800e61:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e62:	8b 1c 24             	mov    (%esp),%ebx
  800e65:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e69:	89 ec                	mov    %ebp,%esp
  800e6b:	5d                   	pop    %ebp
  800e6c:	c3                   	ret    

00800e6d <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800e6d:	55                   	push   %ebp
  800e6e:	89 e5                	mov    %esp,%ebp
  800e70:	83 ec 08             	sub    $0x8,%esp
  800e73:	89 1c 24             	mov    %ebx,(%esp)
  800e76:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e7a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e7f:	b8 04 00 00 00       	mov    $0x4,%eax
  800e84:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e87:	8b 55 08             	mov    0x8(%ebp),%edx
  800e8a:	89 df                	mov    %ebx,%edi
  800e8c:	51                   	push   %ecx
  800e8d:	52                   	push   %edx
  800e8e:	53                   	push   %ebx
  800e8f:	54                   	push   %esp
  800e90:	55                   	push   %ebp
  800e91:	56                   	push   %esi
  800e92:	57                   	push   %edi
  800e93:	5f                   	pop    %edi
  800e94:	5e                   	pop    %esi
  800e95:	5d                   	pop    %ebp
  800e96:	5c                   	pop    %esp
  800e97:	5b                   	pop    %ebx
  800e98:	5a                   	pop    %edx
  800e99:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800e9a:	8b 1c 24             	mov    (%esp),%ebx
  800e9d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ea1:	89 ec                	mov    %ebp,%esp
  800ea3:	5d                   	pop    %ebp
  800ea4:	c3                   	ret    

00800ea5 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  800ea5:	55                   	push   %ebp
  800ea6:	89 e5                	mov    %esp,%ebp
  800ea8:	83 ec 08             	sub    $0x8,%esp
  800eab:	89 1c 24             	mov    %ebx,(%esp)
  800eae:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800eb2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800eb7:	b8 05 00 00 00       	mov    $0x5,%eax
  800ebc:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebf:	89 cb                	mov    %ecx,%ebx
  800ec1:	89 cf                	mov    %ecx,%edi
  800ec3:	51                   	push   %ecx
  800ec4:	52                   	push   %edx
  800ec5:	53                   	push   %ebx
  800ec6:	54                   	push   %esp
  800ec7:	55                   	push   %ebp
  800ec8:	56                   	push   %esi
  800ec9:	57                   	push   %edi
  800eca:	5f                   	pop    %edi
  800ecb:	5e                   	pop    %esi
  800ecc:	5d                   	pop    %ebp
  800ecd:	5c                   	pop    %esp
  800ece:	5b                   	pop    %ebx
  800ecf:	5a                   	pop    %edx
  800ed0:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800ed1:	8b 1c 24             	mov    (%esp),%ebx
  800ed4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ed8:	89 ec                	mov    %ebp,%esp
  800eda:	5d                   	pop    %ebp
  800edb:	c3                   	ret    

00800edc <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800edc:	55                   	push   %ebp
  800edd:	89 e5                	mov    %esp,%ebp
  800edf:	83 ec 28             	sub    $0x28,%esp
  800ee2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800ee5:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800ee8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800eed:	b8 03 00 00 00       	mov    $0x3,%eax
  800ef2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef5:	89 cb                	mov    %ecx,%ebx
  800ef7:	89 cf                	mov    %ecx,%edi
  800ef9:	51                   	push   %ecx
  800efa:	52                   	push   %edx
  800efb:	53                   	push   %ebx
  800efc:	54                   	push   %esp
  800efd:	55                   	push   %ebp
  800efe:	56                   	push   %esi
  800eff:	57                   	push   %edi
  800f00:	5f                   	pop    %edi
  800f01:	5e                   	pop    %esi
  800f02:	5d                   	pop    %ebp
  800f03:	5c                   	pop    %esp
  800f04:	5b                   	pop    %ebx
  800f05:	5a                   	pop    %edx
  800f06:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800f07:	85 c0                	test   %eax,%eax
  800f09:	7e 28                	jle    800f33 <sys_env_destroy+0x57>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f0b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f0f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800f16:	00 
  800f17:	c7 44 24 08 c4 14 80 	movl   $0x8014c4,0x8(%esp)
  800f1e:	00 
  800f1f:	c7 44 24 04 26 00 00 	movl   $0x26,0x4(%esp)
  800f26:	00 
  800f27:	c7 04 24 e1 14 80 00 	movl   $0x8014e1,(%esp)
  800f2e:	e8 0d 00 00 00       	call   800f40 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800f33:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800f36:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f39:	89 ec                	mov    %ebp,%esp
  800f3b:	5d                   	pop    %ebp
  800f3c:	c3                   	ret    
  800f3d:	00 00                	add    %al,(%eax)
	...

00800f40 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800f40:	55                   	push   %ebp
  800f41:	89 e5                	mov    %esp,%ebp
  800f43:	56                   	push   %esi
  800f44:	53                   	push   %ebx
  800f45:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  800f48:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  800f4b:	a1 08 20 80 00       	mov    0x802008,%eax
  800f50:	85 c0                	test   %eax,%eax
  800f52:	74 10                	je     800f64 <_panic+0x24>
		cprintf("%s: ", argv0);
  800f54:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f58:	c7 04 24 ef 14 80 00 	movl   $0x8014ef,(%esp)
  800f5f:	e8 a9 f1 ff ff       	call   80010d <cprintf>
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800f64:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800f6a:	e8 c8 fe ff ff       	call   800e37 <sys_getenvid>
  800f6f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f72:	89 54 24 10          	mov    %edx,0x10(%esp)
  800f76:	8b 55 08             	mov    0x8(%ebp),%edx
  800f79:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f7d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f81:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f85:	c7 04 24 f4 14 80 00 	movl   $0x8014f4,(%esp)
  800f8c:	e8 7c f1 ff ff       	call   80010d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800f91:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f95:	8b 45 10             	mov    0x10(%ebp),%eax
  800f98:	89 04 24             	mov    %eax,(%esp)
  800f9b:	e8 0c f1 ff ff       	call   8000ac <vcprintf>
	cprintf("\n");
  800fa0:	c7 04 24 24 12 80 00 	movl   $0x801224,(%esp)
  800fa7:	e8 61 f1 ff ff       	call   80010d <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800fac:	cc                   	int3   
  800fad:	eb fd                	jmp    800fac <_panic+0x6c>
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
