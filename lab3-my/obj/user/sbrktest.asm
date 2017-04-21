
obj/user/sbrktest:     file format elf32-i386


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
  80002c:	e8 8b 00 00 00       	call   8000bc <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
#define ALLOCATE_SIZE 4096
#define STRING_SIZE	  64

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 1c             	sub    $0x1c,%esp
	int i;
	uint32_t start, end;
	char *s;

	start = sys_sbrk(0);
  80003d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800044:	e8 bc 0e 00 00       	call   800f05 <sys_sbrk>
  800049:	89 c6                	mov    %eax,%esi
	end = sys_sbrk(ALLOCATE_SIZE);
  80004b:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
  800052:	e8 ae 0e 00 00       	call   800f05 <sys_sbrk>

	if (end - start < ALLOCATE_SIZE) {
  800057:	29 f0                	sub    %esi,%eax
  800059:	3d ff 0f 00 00       	cmp    $0xfff,%eax
  80005e:	77 0c                	ja     80006c <umain+0x38>
		cprintf("sbrk not correctly implemented\n");
  800060:	c7 04 24 78 12 80 00 	movl   $0x801278,(%esp)
  800067:	e8 fd 00 00 00       	call   800169 <cprintf>
	}

	s = (char *) start;
  80006c:	89 f7                	mov    %esi,%edi
  80006e:	b9 00 00 00 00       	mov    $0x0,%ecx
	for ( i = 0; i < STRING_SIZE; i++) {
		s[i] = 'A' + (i % 26);
  800073:	bb 4f ec c4 4e       	mov    $0x4ec4ec4f,%ebx
  800078:	89 c8                	mov    %ecx,%eax
  80007a:	f7 eb                	imul   %ebx
  80007c:	c1 fa 03             	sar    $0x3,%edx
  80007f:	89 c8                	mov    %ecx,%eax
  800081:	c1 f8 1f             	sar    $0x1f,%eax
  800084:	29 c2                	sub    %eax,%edx
  800086:	6b c2 1a             	imul   $0x1a,%edx,%eax
  800089:	89 ca                	mov    %ecx,%edx
  80008b:	29 c2                	sub    %eax,%edx
  80008d:	89 d0                	mov    %edx,%eax
  80008f:	83 c0 41             	add    $0x41,%eax
  800092:	88 04 31             	mov    %al,(%ecx,%esi,1)
	if (end - start < ALLOCATE_SIZE) {
		cprintf("sbrk not correctly implemented\n");
	}

	s = (char *) start;
	for ( i = 0; i < STRING_SIZE; i++) {
  800095:	83 c1 01             	add    $0x1,%ecx
  800098:	83 f9 40             	cmp    $0x40,%ecx
  80009b:	75 db                	jne    800078 <umain+0x44>
		s[i] = 'A' + (i % 26);
	}
	s[STRING_SIZE] = '\0';
  80009d:	c6 47 40 00          	movb   $0x0,0x40(%edi)

	cprintf("SBRK_TEST(%s)\n", s);
  8000a1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8000a5:	c7 04 24 98 12 80 00 	movl   $0x801298,(%esp)
  8000ac:	e8 b8 00 00 00       	call   800169 <cprintf>
}
  8000b1:	83 c4 1c             	add    $0x1c,%esp
  8000b4:	5b                   	pop    %ebx
  8000b5:	5e                   	pop    %esi
  8000b6:	5f                   	pop    %edi
  8000b7:	5d                   	pop    %ebp
  8000b8:	c3                   	ret    
  8000b9:	00 00                	add    %al,(%eax)
	...

008000bc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000bc:	55                   	push   %ebp
  8000bd:	89 e5                	mov    %esp,%ebp
  8000bf:	83 ec 18             	sub    $0x18,%esp
  8000c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8000c5:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8000c8:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  8000cf:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000d2:	85 c0                	test   %eax,%eax
  8000d4:	7e 08                	jle    8000de <libmain+0x22>
		binaryname = argv[0];
  8000d6:	8b 0a                	mov    (%edx),%ecx
  8000d8:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  8000de:	89 54 24 04          	mov    %edx,0x4(%esp)
  8000e2:	89 04 24             	mov    %eax,(%esp)
  8000e5:	e8 4a ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000ea:	e8 05 00 00 00       	call   8000f4 <exit>
}
  8000ef:	c9                   	leave  
  8000f0:	c3                   	ret    
  8000f1:	00 00                	add    %al,(%eax)
	...

008000f4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000f4:	55                   	push   %ebp
  8000f5:	89 e5                	mov    %esp,%ebp
  8000f7:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000fa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800101:	e8 36 0e 00 00       	call   800f3c <sys_env_destroy>
}
  800106:	c9                   	leave  
  800107:	c3                   	ret    

00800108 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800108:	55                   	push   %ebp
  800109:	89 e5                	mov    %esp,%ebp
  80010b:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800111:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800118:	00 00 00 
	b.cnt = 0;
  80011b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800122:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800125:	8b 45 0c             	mov    0xc(%ebp),%eax
  800128:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80012c:	8b 45 08             	mov    0x8(%ebp),%eax
  80012f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800133:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800139:	89 44 24 04          	mov    %eax,0x4(%esp)
  80013d:	c7 04 24 83 01 80 00 	movl   $0x800183,(%esp)
  800144:	e8 07 03 00 00       	call   800450 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800149:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80014f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800153:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800159:	89 04 24             	mov    %eax,(%esp)
  80015c:	e8 cb 0c 00 00       	call   800e2c <sys_cputs>

	return b.cnt;
}
  800161:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800167:	c9                   	leave  
  800168:	c3                   	ret    

00800169 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800169:	55                   	push   %ebp
  80016a:	89 e5                	mov    %esp,%ebp
  80016c:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  80016f:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800172:	89 44 24 04          	mov    %eax,0x4(%esp)
  800176:	8b 45 08             	mov    0x8(%ebp),%eax
  800179:	89 04 24             	mov    %eax,(%esp)
  80017c:	e8 87 ff ff ff       	call   800108 <vcprintf>
	va_end(ap);

	return cnt;
}
  800181:	c9                   	leave  
  800182:	c3                   	ret    

00800183 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800183:	55                   	push   %ebp
  800184:	89 e5                	mov    %esp,%ebp
  800186:	53                   	push   %ebx
  800187:	83 ec 14             	sub    $0x14,%esp
  80018a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80018d:	8b 03                	mov    (%ebx),%eax
  80018f:	8b 55 08             	mov    0x8(%ebp),%edx
  800192:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800196:	83 c0 01             	add    $0x1,%eax
  800199:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80019b:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001a0:	75 19                	jne    8001bb <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001a2:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001a9:	00 
  8001aa:	8d 43 08             	lea    0x8(%ebx),%eax
  8001ad:	89 04 24             	mov    %eax,(%esp)
  8001b0:	e8 77 0c 00 00       	call   800e2c <sys_cputs>
		b->idx = 0;
  8001b5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001bb:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001bf:	83 c4 14             	add    $0x14,%esp
  8001c2:	5b                   	pop    %ebx
  8001c3:	5d                   	pop    %ebp
  8001c4:	c3                   	ret    
	...

008001d0 <printnum_nopad>:

/*
* help function added by Lu to print only the num;
*/
static void printnum_nopad(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int *num_len){
  8001d0:	55                   	push   %ebp
  8001d1:	89 e5                	mov    %esp,%ebp
  8001d3:	83 ec 48             	sub    $0x48,%esp
  8001d6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8001d9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8001dc:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8001df:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8001e2:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8001e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001e8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001eb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8001ee:	8b 45 10             	mov    0x10(%ebp),%eax
  8001f1:	8b 7d 14             	mov    0x14(%ebp),%edi
	if(num >= base){
  8001f4:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8001fc:	39 f2                	cmp    %esi,%edx
  8001fe:	72 07                	jb     800207 <printnum_nopad+0x37>
  800200:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800203:	39 c8                	cmp    %ecx,%eax
  800205:	77 54                	ja     80025b <printnum_nopad+0x8b>
		printnum_nopad(putch, putdat, num / base, base, num_len);
  800207:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80020b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80020f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800213:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800217:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80021a:	89 55 cc             	mov    %edx,-0x34(%ebp)
  80021d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800220:	89 54 24 08          	mov    %edx,0x8(%esp)
  800224:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80022b:	00 
  80022c:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80022f:	89 0c 24             	mov    %ecx,(%esp)
  800232:	89 74 24 04          	mov    %esi,0x4(%esp)
  800236:	e8 d5 0d 00 00       	call   801010 <__udivdi3>
  80023b:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80023e:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800241:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800245:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800249:	89 04 24             	mov    %eax,(%esp)
  80024c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800250:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800253:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800256:	e8 75 ff ff ff       	call   8001d0 <printnum_nopad>
	}
	*num_len += 1 ;
  80025b:	83 07 01             	addl   $0x1,(%edi)
	putch("0123456789abcdef"[num % base], putdat);
  80025e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800261:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800265:	8b 04 24             	mov    (%esp),%eax
  800268:	8b 54 24 04          	mov    0x4(%esp),%edx
  80026c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80026f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800272:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800275:	89 54 24 08          	mov    %edx,0x8(%esp)
  800279:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800280:	00 
  800281:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800284:	89 0c 24             	mov    %ecx,(%esp)
  800287:	89 74 24 04          	mov    %esi,0x4(%esp)
  80028b:	e8 b0 0e 00 00       	call   801140 <__umoddi3>
  800290:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800293:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800297:	0f be 80 b1 12 80 00 	movsbl 0x8012b1(%eax),%eax
  80029e:	89 04 24             	mov    %eax,(%esp)
  8002a1:	ff 55 d4             	call   *-0x2c(%ebp)
}
  8002a4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8002a7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8002aa:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8002ad:	89 ec                	mov    %ebp,%esp
  8002af:	5d                   	pop    %ebp
  8002b0:	c3                   	ret    

008002b1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
  8002b4:	57                   	push   %edi
  8002b5:	56                   	push   %esi
  8002b6:	53                   	push   %ebx
  8002b7:	83 ec 5c             	sub    $0x5c,%esp
  8002ba:	89 c7                	mov    %eax,%edi
  8002bc:	89 d6                	mov    %edx,%esi
  8002be:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c1:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8002c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002c7:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8002ca:	8b 45 10             	mov    0x10(%ebp),%eax
  8002cd:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	if(padc == '-'){
  8002d0:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  8002d4:	75 4c                	jne    800322 <printnum+0x71>
		int num_len = 0;
  8002d6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		printnum_nopad(putch, putdat, num, base, &num_len);
  8002dd:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8002e0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002e4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002e8:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8002eb:	89 0c 24             	mov    %ecx,(%esp)
  8002ee:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8002f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002f5:	89 f2                	mov    %esi,%edx
  8002f7:	89 f8                	mov    %edi,%eax
  8002f9:	e8 d2 fe ff ff       	call   8001d0 <printnum_nopad>
		width -= num_len;
  8002fe:	2b 5d e4             	sub    -0x1c(%ebp),%ebx
		while (width-- > 0)
  800301:	85 db                	test   %ebx,%ebx
  800303:	0f 8e e8 00 00 00    	jle    8003f1 <printnum+0x140>
			putch(' ', putdat);
  800309:	89 74 24 04          	mov    %esi,0x4(%esp)
  80030d:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800314:	ff d7                	call   *%edi
  800316:	83 eb 01             	sub    $0x1,%ebx
	// your code here:
	if(padc == '-'){
		int num_len = 0;
		printnum_nopad(putch, putdat, num, base, &num_len);
		width -= num_len;
		while (width-- > 0)
  800319:	85 db                	test   %ebx,%ebx
  80031b:	7f ec                	jg     800309 <printnum+0x58>
  80031d:	e9 cf 00 00 00       	jmp    8003f1 <printnum+0x140>
			putch(' ', putdat);
	}
	else{
		// first recursively print all preceding (more significant) digits
		if (num >= base) {
  800322:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  800325:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800329:	77 19                	ja     800344 <printnum+0x93>
  80032b:	90                   	nop
  80032c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800330:	72 05                	jb     800337 <printnum+0x86>
  800332:	39 45 c8             	cmp    %eax,-0x38(%ebp)
  800335:	73 0d                	jae    800344 <printnum+0x93>
			printnum(putch, putdat, num / base, base, width - 1, padc);
		} else {
			// print any needed pad characters before first digit
			while (--width > 0)
  800337:	83 eb 01             	sub    $0x1,%ebx
  80033a:	85 db                	test   %ebx,%ebx
  80033c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800340:	7f 63                	jg     8003a5 <printnum+0xf4>
  800342:	eb 74                	jmp    8003b8 <printnum+0x107>
			putch(' ', putdat);
	}
	else{
		// first recursively print all preceding (more significant) digits
		if (num >= base) {
			printnum(putch, putdat, num / base, base, width - 1, padc);
  800344:	8b 55 18             	mov    0x18(%ebp),%edx
  800347:	89 54 24 10          	mov    %edx,0x10(%esp)
  80034b:	83 eb 01             	sub    $0x1,%ebx
  80034e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800352:	89 44 24 08          	mov    %eax,0x8(%esp)
  800356:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  80035a:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80035e:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800361:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800364:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  800367:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80036b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800372:	00 
  800373:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800376:	89 04 24             	mov    %eax,(%esp)
  800379:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80037c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800380:	e8 8b 0c 00 00       	call   801010 <__udivdi3>
  800385:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800388:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80038b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80038f:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800393:	89 04 24             	mov    %eax,(%esp)
  800396:	89 54 24 04          	mov    %edx,0x4(%esp)
  80039a:	89 f2                	mov    %esi,%edx
  80039c:	89 f8                	mov    %edi,%eax
  80039e:	e8 0e ff ff ff       	call   8002b1 <printnum>
  8003a3:	eb 13                	jmp    8003b8 <printnum+0x107>
		} else {
			// print any needed pad characters before first digit
			while (--width > 0)
				putch(padc, putdat);
  8003a5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003a9:	8b 45 18             	mov    0x18(%ebp),%eax
  8003ac:	89 04 24             	mov    %eax,(%esp)
  8003af:	ff d7                	call   *%edi
		// first recursively print all preceding (more significant) digits
		if (num >= base) {
			printnum(putch, putdat, num / base, base, width - 1, padc);
		} else {
			// print any needed pad characters before first digit
			while (--width > 0)
  8003b1:	83 eb 01             	sub    $0x1,%ebx
  8003b4:	85 db                	test   %ebx,%ebx
  8003b6:	7f ed                	jg     8003a5 <printnum+0xf4>
				putch(padc, putdat);
		}

		// then print this (the least significant) digit
		putch("0123456789abcdef"[num % base], putdat);
  8003b8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003bc:	8b 74 24 04          	mov    0x4(%esp),%esi
  8003c0:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8003c3:	89 54 24 08          	mov    %edx,0x8(%esp)
  8003c7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003ce:	00 
  8003cf:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8003d2:	89 0c 24             	mov    %ecx,(%esp)
  8003d5:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8003d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003dc:	e8 5f 0d 00 00       	call   801140 <__umoddi3>
  8003e1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003e5:	0f be 80 b1 12 80 00 	movsbl 0x8012b1(%eax),%eax
  8003ec:	89 04 24             	mov    %eax,(%esp)
  8003ef:	ff d7                	call   *%edi
	}
	
}
  8003f1:	83 c4 5c             	add    $0x5c,%esp
  8003f4:	5b                   	pop    %ebx
  8003f5:	5e                   	pop    %esi
  8003f6:	5f                   	pop    %edi
  8003f7:	5d                   	pop    %ebp
  8003f8:	c3                   	ret    

008003f9 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003f9:	55                   	push   %ebp
  8003fa:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003fc:	83 fa 01             	cmp    $0x1,%edx
  8003ff:	7e 0e                	jle    80040f <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800401:	8b 10                	mov    (%eax),%edx
  800403:	8d 4a 08             	lea    0x8(%edx),%ecx
  800406:	89 08                	mov    %ecx,(%eax)
  800408:	8b 02                	mov    (%edx),%eax
  80040a:	8b 52 04             	mov    0x4(%edx),%edx
  80040d:	eb 22                	jmp    800431 <getuint+0x38>
	else if (lflag)
  80040f:	85 d2                	test   %edx,%edx
  800411:	74 10                	je     800423 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800413:	8b 10                	mov    (%eax),%edx
  800415:	8d 4a 04             	lea    0x4(%edx),%ecx
  800418:	89 08                	mov    %ecx,(%eax)
  80041a:	8b 02                	mov    (%edx),%eax
  80041c:	ba 00 00 00 00       	mov    $0x0,%edx
  800421:	eb 0e                	jmp    800431 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800423:	8b 10                	mov    (%eax),%edx
  800425:	8d 4a 04             	lea    0x4(%edx),%ecx
  800428:	89 08                	mov    %ecx,(%eax)
  80042a:	8b 02                	mov    (%edx),%eax
  80042c:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800431:	5d                   	pop    %ebp
  800432:	c3                   	ret    

00800433 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800433:	55                   	push   %ebp
  800434:	89 e5                	mov    %esp,%ebp
  800436:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800439:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80043d:	8b 10                	mov    (%eax),%edx
  80043f:	3b 50 04             	cmp    0x4(%eax),%edx
  800442:	73 0a                	jae    80044e <sprintputch+0x1b>
		*b->buf++ = ch;
  800444:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800447:	88 0a                	mov    %cl,(%edx)
  800449:	83 c2 01             	add    $0x1,%edx
  80044c:	89 10                	mov    %edx,(%eax)
}
  80044e:	5d                   	pop    %ebp
  80044f:	c3                   	ret    

00800450 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800450:	55                   	push   %ebp
  800451:	89 e5                	mov    %esp,%ebp
  800453:	57                   	push   %edi
  800454:	56                   	push   %esi
  800455:	53                   	push   %ebx
  800456:	83 ec 5c             	sub    $0x5c,%esp
  800459:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80045c:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80045f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800466:	eb 12                	jmp    80047a <vprintfmt+0x2a>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800468:	85 c0                	test   %eax,%eax
  80046a:	0f 84 c6 04 00 00    	je     800936 <vprintfmt+0x4e6>
				return;
			putch(ch, putdat);
  800470:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800474:	89 04 24             	mov    %eax,(%esp)
  800477:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80047a:	0f b6 03             	movzbl (%ebx),%eax
  80047d:	83 c3 01             	add    $0x1,%ebx
  800480:	83 f8 25             	cmp    $0x25,%eax
  800483:	75 e3                	jne    800468 <vprintfmt+0x18>
  800485:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  800489:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800490:	be ff ff ff ff       	mov    $0xffffffff,%esi
  800495:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  80049c:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  8004a3:	eb 06                	jmp    8004ab <vprintfmt+0x5b>
  8004a5:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  8004a9:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ab:	0f b6 0b             	movzbl (%ebx),%ecx
  8004ae:	0f b6 d1             	movzbl %cl,%edx
  8004b1:	8d 43 01             	lea    0x1(%ebx),%eax
  8004b4:	83 e9 23             	sub    $0x23,%ecx
  8004b7:	80 f9 55             	cmp    $0x55,%cl
  8004ba:	0f 87 58 04 00 00    	ja     800918 <vprintfmt+0x4c8>
  8004c0:	0f b6 c9             	movzbl %cl,%ecx
  8004c3:	ff 24 8d bc 13 80 00 	jmp    *0x8013bc(,%ecx,4)
  8004ca:	c6 45 e0 2b          	movb   $0x2b,-0x20(%ebp)
  8004ce:	eb d9                	jmp    8004a9 <vprintfmt+0x59>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004d0:	8d 72 d0             	lea    -0x30(%edx),%esi
				ch = *fmt;
  8004d3:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8004d6:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8004d9:	83 f9 09             	cmp    $0x9,%ecx
  8004dc:	76 08                	jbe    8004e6 <vprintfmt+0x96>
  8004de:	eb 40                	jmp    800520 <vprintfmt+0xd0>
  8004e0:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
			goto reswitch;
  8004e4:	eb c3                	jmp    8004a9 <vprintfmt+0x59>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004e6:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  8004e9:	8d 0c b6             	lea    (%esi,%esi,4),%ecx
  8004ec:	8d 74 4a d0          	lea    -0x30(%edx,%ecx,2),%esi
				ch = *fmt;
  8004f0:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8004f3:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8004f6:	83 f9 09             	cmp    $0x9,%ecx
  8004f9:	76 eb                	jbe    8004e6 <vprintfmt+0x96>
  8004fb:	eb 23                	jmp    800520 <vprintfmt+0xd0>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004fd:	8b 55 14             	mov    0x14(%ebp),%edx
  800500:	8d 4a 04             	lea    0x4(%edx),%ecx
  800503:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800506:	8b 32                	mov    (%edx),%esi
			goto process_precision;
  800508:	eb 16                	jmp    800520 <vprintfmt+0xd0>

		case '.':
			if (width < 0)
  80050a:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80050d:	c1 fa 1f             	sar    $0x1f,%edx
  800510:	f7 d2                	not    %edx
  800512:	21 55 dc             	and    %edx,-0x24(%ebp)
  800515:	eb 92                	jmp    8004a9 <vprintfmt+0x59>
  800517:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  80051e:	eb 89                	jmp    8004a9 <vprintfmt+0x59>

		process_precision:
			if (width < 0)
  800520:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800524:	79 83                	jns    8004a9 <vprintfmt+0x59>
  800526:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800529:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80052c:	e9 78 ff ff ff       	jmp    8004a9 <vprintfmt+0x59>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800531:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
			goto reswitch;
  800535:	e9 6f ff ff ff       	jmp    8004a9 <vprintfmt+0x59>
  80053a:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80053d:	8b 45 14             	mov    0x14(%ebp),%eax
  800540:	8d 50 04             	lea    0x4(%eax),%edx
  800543:	89 55 14             	mov    %edx,0x14(%ebp)
  800546:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80054a:	8b 00                	mov    (%eax),%eax
  80054c:	89 04 24             	mov    %eax,(%esp)
  80054f:	ff 55 08             	call   *0x8(%ebp)
  800552:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  800555:	e9 20 ff ff ff       	jmp    80047a <vprintfmt+0x2a>
  80055a:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80055d:	8b 45 14             	mov    0x14(%ebp),%eax
  800560:	8d 50 04             	lea    0x4(%eax),%edx
  800563:	89 55 14             	mov    %edx,0x14(%ebp)
  800566:	8b 00                	mov    (%eax),%eax
  800568:	89 c2                	mov    %eax,%edx
  80056a:	c1 fa 1f             	sar    $0x1f,%edx
  80056d:	31 d0                	xor    %edx,%eax
  80056f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800571:	83 f8 06             	cmp    $0x6,%eax
  800574:	7f 0b                	jg     800581 <vprintfmt+0x131>
  800576:	8b 14 85 14 15 80 00 	mov    0x801514(,%eax,4),%edx
  80057d:	85 d2                	test   %edx,%edx
  80057f:	75 23                	jne    8005a4 <vprintfmt+0x154>
				printfmt(putch, putdat, "error %d", err);
  800581:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800585:	c7 44 24 08 c2 12 80 	movl   $0x8012c2,0x8(%esp)
  80058c:	00 
  80058d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800591:	8b 45 08             	mov    0x8(%ebp),%eax
  800594:	89 04 24             	mov    %eax,(%esp)
  800597:	e8 22 04 00 00       	call   8009be <printfmt>
  80059c:	8b 5d cc             	mov    -0x34(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80059f:	e9 d6 fe ff ff       	jmp    80047a <vprintfmt+0x2a>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8005a4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005a8:	c7 44 24 08 cb 12 80 	movl   $0x8012cb,0x8(%esp)
  8005af:	00 
  8005b0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8005b7:	89 14 24             	mov    %edx,(%esp)
  8005ba:	e8 ff 03 00 00       	call   8009be <printfmt>
  8005bf:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  8005c2:	e9 b3 fe ff ff       	jmp    80047a <vprintfmt+0x2a>
  8005c7:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8005ca:	89 c3                	mov    %eax,%ebx
  8005cc:	89 f1                	mov    %esi,%ecx
  8005ce:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005d1:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d7:	8d 50 04             	lea    0x4(%eax),%edx
  8005da:	89 55 14             	mov    %edx,0x14(%ebp)
  8005dd:	8b 00                	mov    (%eax),%eax
  8005df:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005e2:	85 c0                	test   %eax,%eax
  8005e4:	75 07                	jne    8005ed <vprintfmt+0x19d>
  8005e6:	c7 45 d0 ce 12 80 00 	movl   $0x8012ce,-0x30(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  8005ed:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8005f1:	7e 06                	jle    8005f9 <vprintfmt+0x1a9>
  8005f3:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  8005f7:	75 13                	jne    80060c <vprintfmt+0x1bc>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005f9:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005fc:	0f be 02             	movsbl (%edx),%eax
  8005ff:	85 c0                	test   %eax,%eax
  800601:	0f 85 a2 00 00 00    	jne    8006a9 <vprintfmt+0x259>
  800607:	e9 8f 00 00 00       	jmp    80069b <vprintfmt+0x24b>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80060c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800610:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800613:	89 0c 24             	mov    %ecx,(%esp)
  800616:	e8 f0 03 00 00       	call   800a0b <strnlen>
  80061b:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80061e:	29 c2                	sub    %eax,%edx
  800620:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800623:	85 d2                	test   %edx,%edx
  800625:	7e d2                	jle    8005f9 <vprintfmt+0x1a9>
					putch(padc, putdat);
  800627:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  80062b:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  80062e:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  800631:	89 d3                	mov    %edx,%ebx
  800633:	89 ce                	mov    %ecx,%esi
  800635:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800639:	89 34 24             	mov    %esi,(%esp)
  80063c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80063f:	83 eb 01             	sub    $0x1,%ebx
  800642:	85 db                	test   %ebx,%ebx
  800644:	7f ef                	jg     800635 <vprintfmt+0x1e5>
  800646:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  800649:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  80064c:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800653:	eb a4                	jmp    8005f9 <vprintfmt+0x1a9>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800655:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800659:	74 1b                	je     800676 <vprintfmt+0x226>
  80065b:	8d 50 e0             	lea    -0x20(%eax),%edx
  80065e:	83 fa 5e             	cmp    $0x5e,%edx
  800661:	76 13                	jbe    800676 <vprintfmt+0x226>
					putch('?', putdat);
  800663:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800666:	89 44 24 04          	mov    %eax,0x4(%esp)
  80066a:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800671:	ff 55 08             	call   *0x8(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800674:	eb 0d                	jmp    800683 <vprintfmt+0x233>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800676:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800679:	89 54 24 04          	mov    %edx,0x4(%esp)
  80067d:	89 04 24             	mov    %eax,(%esp)
  800680:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800683:	83 ef 01             	sub    $0x1,%edi
  800686:	0f be 03             	movsbl (%ebx),%eax
  800689:	85 c0                	test   %eax,%eax
  80068b:	74 05                	je     800692 <vprintfmt+0x242>
  80068d:	83 c3 01             	add    $0x1,%ebx
  800690:	eb 28                	jmp    8006ba <vprintfmt+0x26a>
  800692:	89 7d dc             	mov    %edi,-0x24(%ebp)
  800695:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800698:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80069b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80069f:	7f 2d                	jg     8006ce <vprintfmt+0x27e>
  8006a1:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  8006a4:	e9 d1 fd ff ff       	jmp    80047a <vprintfmt+0x2a>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006a9:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8006ac:	83 c1 01             	add    $0x1,%ecx
  8006af:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8006b2:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8006b5:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  8006b8:	89 cb                	mov    %ecx,%ebx
  8006ba:	85 f6                	test   %esi,%esi
  8006bc:	78 97                	js     800655 <vprintfmt+0x205>
  8006be:	83 ee 01             	sub    $0x1,%esi
  8006c1:	79 92                	jns    800655 <vprintfmt+0x205>
  8006c3:	89 7d dc             	mov    %edi,-0x24(%ebp)
  8006c6:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8006c9:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  8006cc:	eb cd                	jmp    80069b <vprintfmt+0x24b>
  8006ce:	8b 75 08             	mov    0x8(%ebp),%esi
  8006d1:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8006d4:	8b 5d dc             	mov    -0x24(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006d7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006db:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006e2:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006e4:	83 eb 01             	sub    $0x1,%ebx
  8006e7:	85 db                	test   %ebx,%ebx
  8006e9:	7f ec                	jg     8006d7 <vprintfmt+0x287>
  8006eb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8006ee:	e9 87 fd ff ff       	jmp    80047a <vprintfmt+0x2a>
  8006f3:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8006f6:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
  8006fa:	88 45 e4             	mov    %al,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006fd:	83 7d d0 01          	cmpl   $0x1,-0x30(%ebp)
  800701:	7e 16                	jle    800719 <vprintfmt+0x2c9>
		return va_arg(*ap, long long);
  800703:	8b 45 14             	mov    0x14(%ebp),%eax
  800706:	8d 50 08             	lea    0x8(%eax),%edx
  800709:	89 55 14             	mov    %edx,0x14(%ebp)
  80070c:	8b 10                	mov    (%eax),%edx
  80070e:	8b 48 04             	mov    0x4(%eax),%ecx
  800711:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800714:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800717:	eb 34                	jmp    80074d <vprintfmt+0x2fd>
	else if (lflag)
  800719:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80071d:	74 18                	je     800737 <vprintfmt+0x2e7>
		return va_arg(*ap, long);
  80071f:	8b 45 14             	mov    0x14(%ebp),%eax
  800722:	8d 50 04             	lea    0x4(%eax),%edx
  800725:	89 55 14             	mov    %edx,0x14(%ebp)
  800728:	8b 00                	mov    (%eax),%eax
  80072a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80072d:	89 c1                	mov    %eax,%ecx
  80072f:	c1 f9 1f             	sar    $0x1f,%ecx
  800732:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800735:	eb 16                	jmp    80074d <vprintfmt+0x2fd>
	else
		return va_arg(*ap, int);
  800737:	8b 45 14             	mov    0x14(%ebp),%eax
  80073a:	8d 50 04             	lea    0x4(%eax),%edx
  80073d:	89 55 14             	mov    %edx,0x14(%ebp)
  800740:	8b 00                	mov    (%eax),%eax
  800742:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800745:	89 c2                	mov    %eax,%edx
  800747:	c1 fa 1f             	sar    $0x1f,%edx
  80074a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80074d:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800750:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if ((long long) num < 0) {
  800753:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800757:	79 2c                	jns    800785 <vprintfmt+0x335>
				putch('-', putdat);
  800759:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80075d:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800764:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800767:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80076a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80076d:	f7 db                	neg    %ebx
  80076f:	83 d6 00             	adc    $0x0,%esi
  800772:	f7 de                	neg    %esi
  800774:	0f b6 4d e0          	movzbl -0x20(%ebp),%ecx
  800778:	88 4d e4             	mov    %cl,-0x1c(%ebp)
  80077b:	ba 0a 00 00 00       	mov    $0xa,%edx
  800780:	e9 db 00 00 00       	jmp    800860 <vprintfmt+0x410>
			}
			else if (padc == '+'){
  800785:	80 7d e4 2b          	cmpb   $0x2b,-0x1c(%ebp)
  800789:	74 11                	je     80079c <vprintfmt+0x34c>
  80078b:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
  80078f:	88 45 e4             	mov    %al,-0x1c(%ebp)
  800792:	ba 0a 00 00 00       	mov    $0xa,%edx
  800797:	e9 c4 00 00 00       	jmp    800860 <vprintfmt+0x410>
				putch('+', putdat);
  80079c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007a0:	c7 04 24 2b 00 00 00 	movl   $0x2b,(%esp)
  8007a7:	ff 55 08             	call   *0x8(%ebp)
  8007aa:	ba 0a 00 00 00       	mov    $0xa,%edx
  8007af:	e9 ac 00 00 00       	jmp    800860 <vprintfmt+0x410>
  8007b4:	89 45 cc             	mov    %eax,-0x34(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007b7:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8007ba:	8d 45 14             	lea    0x14(%ebp),%eax
  8007bd:	e8 37 fc ff ff       	call   8003f9 <getuint>
  8007c2:	89 c3                	mov    %eax,%ebx
  8007c4:	89 d6                	mov    %edx,%esi
  8007c6:	0f b6 55 e0          	movzbl -0x20(%ebp),%edx
  8007ca:	88 55 e4             	mov    %dl,-0x1c(%ebp)
  8007cd:	ba 0a 00 00 00       	mov    $0xa,%edx
			base = 10;
			goto number;
  8007d2:	e9 89 00 00 00       	jmp    800860 <vprintfmt+0x410>
  8007d7:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) octal
		case 'o':
			putch('0', putdat);
  8007da:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007de:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007e5:	ff 55 08             	call   *0x8(%ebp)
			num = getuint(&ap, lflag);
  8007e8:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8007eb:	8d 45 14             	lea    0x14(%ebp),%eax
  8007ee:	e8 06 fc ff ff       	call   8003f9 <getuint>
  8007f3:	89 c3                	mov    %eax,%ebx
  8007f5:	89 d6                	mov    %edx,%esi
  8007f7:	0f b6 4d e0          	movzbl -0x20(%ebp),%ecx
  8007fb:	88 4d e4             	mov    %cl,-0x1c(%ebp)
  8007fe:	ba 08 00 00 00       	mov    $0x8,%edx
			base = 8;
			goto number;
  800803:	eb 5b                	jmp    800860 <vprintfmt+0x410>
  800805:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  800808:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80080c:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800813:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800816:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80081a:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800821:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  800824:	8b 45 14             	mov    0x14(%ebp),%eax
  800827:	8d 50 04             	lea    0x4(%eax),%edx
  80082a:	89 55 14             	mov    %edx,0x14(%ebp)
  80082d:	8b 18                	mov    (%eax),%ebx
  80082f:	be 00 00 00 00       	mov    $0x0,%esi
  800834:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
  800838:	88 45 e4             	mov    %al,-0x1c(%ebp)
  80083b:	ba 10 00 00 00       	mov    $0x10,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800840:	eb 1e                	jmp    800860 <vprintfmt+0x410>
  800842:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800845:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800848:	8d 45 14             	lea    0x14(%ebp),%eax
  80084b:	e8 a9 fb ff ff       	call   8003f9 <getuint>
  800850:	89 c3                	mov    %eax,%ebx
  800852:	89 d6                	mov    %edx,%esi
  800854:	0f b6 55 e0          	movzbl -0x20(%ebp),%edx
  800858:	88 55 e4             	mov    %dl,-0x1c(%ebp)
  80085b:	ba 10 00 00 00       	mov    $0x10,%edx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800860:	0f be 45 e4          	movsbl -0x1c(%ebp),%eax
  800864:	89 44 24 10          	mov    %eax,0x10(%esp)
  800868:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80086b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80086f:	89 54 24 08          	mov    %edx,0x8(%esp)
  800873:	89 1c 24             	mov    %ebx,(%esp)
  800876:	89 74 24 04          	mov    %esi,0x4(%esp)
  80087a:	89 fa                	mov    %edi,%edx
  80087c:	8b 45 08             	mov    0x8(%ebp),%eax
  80087f:	e8 2d fa ff ff       	call   8002b1 <printnum>
  800884:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  800887:	e9 ee fb ff ff       	jmp    80047a <vprintfmt+0x2a>
  80088c:	89 45 cc             	mov    %eax,-0x34(%ebp)
            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
	    	uint32_t *num_now = putdat;
	    	char *ret_va = va_arg(ap, char *);
  80088f:	8b 45 14             	mov    0x14(%ebp),%eax
  800892:	8d 50 04             	lea    0x4(%eax),%edx
  800895:	89 55 14             	mov    %edx,0x14(%ebp)
  800898:	8b 00                	mov    (%eax),%eax
	    	if(ret_va == NULL){
  80089a:	85 c0                	test   %eax,%eax
  80089c:	75 27                	jne    8008c5 <vprintfmt+0x475>
				printfmt(putch, putdat, "%s", null_error);
  80089e:	c7 44 24 0c 40 13 80 	movl   $0x801340,0xc(%esp)
  8008a5:	00 
  8008a6:	c7 44 24 08 cb 12 80 	movl   $0x8012cb,0x8(%esp)
  8008ad:	00 
  8008ae:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b5:	89 04 24             	mov    %eax,(%esp)
  8008b8:	e8 01 01 00 00       	call   8009be <printfmt>
  8008bd:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  8008c0:	e9 b5 fb ff ff       	jmp    80047a <vprintfmt+0x2a>
	    	}
	    	else if ((*num_now) >> 7 != 0 ){		//how to aurrately discribe overflow?
  8008c5:	8b 17                	mov    (%edi),%edx
  8008c7:	89 d1                	mov    %edx,%ecx
  8008c9:	c1 e9 07             	shr    $0x7,%ecx
  8008cc:	85 c9                	test   %ecx,%ecx
  8008ce:	74 29                	je     8008f9 <vprintfmt+0x4a9>
				*ret_va = *(num_now);	//get putdat at first as next print instruction will change ret_va as it's a pointer which means it's dynamic;
  8008d0:	88 10                	mov    %dl,(%eax)
				printfmt(putch, putdat, "%s", overflow_error);
  8008d2:	c7 44 24 0c 78 13 80 	movl   $0x801378,0xc(%esp)
  8008d9:	00 
  8008da:	c7 44 24 08 cb 12 80 	movl   $0x8012cb,0x8(%esp)
  8008e1:	00 
  8008e2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008e6:	8b 55 08             	mov    0x8(%ebp),%edx
  8008e9:	89 14 24             	mov    %edx,(%esp)
  8008ec:	e8 cd 00 00 00       	call   8009be <printfmt>
  8008f1:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  8008f4:	e9 81 fb ff ff       	jmp    80047a <vprintfmt+0x2a>
	    	}
	    	else{
				*ret_va = *(num_now);
  8008f9:	88 10                	mov    %dl,(%eax)
  8008fb:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  8008fe:	e9 77 fb ff ff       	jmp    80047a <vprintfmt+0x2a>
  800903:	89 45 cc             	mov    %eax,-0x34(%ebp)
            	break;
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800906:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80090a:	89 14 24             	mov    %edx,(%esp)
  80090d:	ff 55 08             	call   *0x8(%ebp)
  800910:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  800913:	e9 62 fb ff ff       	jmp    80047a <vprintfmt+0x2a>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800918:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80091c:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800923:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800926:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800929:	80 38 25             	cmpb   $0x25,(%eax)
  80092c:	0f 84 48 fb ff ff    	je     80047a <vprintfmt+0x2a>
  800932:	89 c3                	mov    %eax,%ebx
  800934:	eb f0                	jmp    800926 <vprintfmt+0x4d6>
				/* do nothing */;
			break;
		}
	}
}
  800936:	83 c4 5c             	add    $0x5c,%esp
  800939:	5b                   	pop    %ebx
  80093a:	5e                   	pop    %esi
  80093b:	5f                   	pop    %edi
  80093c:	5d                   	pop    %ebp
  80093d:	c3                   	ret    

0080093e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
  800941:	83 ec 28             	sub    $0x28,%esp
  800944:	8b 45 08             	mov    0x8(%ebp),%eax
  800947:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  80094a:	85 c0                	test   %eax,%eax
  80094c:	74 04                	je     800952 <vsnprintf+0x14>
  80094e:	85 d2                	test   %edx,%edx
  800950:	7f 07                	jg     800959 <vsnprintf+0x1b>
  800952:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800957:	eb 3b                	jmp    800994 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800959:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80095c:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800960:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800963:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80096a:	8b 45 14             	mov    0x14(%ebp),%eax
  80096d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800971:	8b 45 10             	mov    0x10(%ebp),%eax
  800974:	89 44 24 08          	mov    %eax,0x8(%esp)
  800978:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80097b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80097f:	c7 04 24 33 04 80 00 	movl   $0x800433,(%esp)
  800986:	e8 c5 fa ff ff       	call   800450 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80098b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80098e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800991:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800994:	c9                   	leave  
  800995:	c3                   	ret    

00800996 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800996:	55                   	push   %ebp
  800997:	89 e5                	mov    %esp,%ebp
  800999:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  80099c:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  80099f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009a3:	8b 45 10             	mov    0x10(%ebp),%eax
  8009a6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b4:	89 04 24             	mov    %eax,(%esp)
  8009b7:	e8 82 ff ff ff       	call   80093e <vsnprintf>
	va_end(ap);

	return rc;
}
  8009bc:	c9                   	leave  
  8009bd:	c3                   	ret    

008009be <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8009be:	55                   	push   %ebp
  8009bf:	89 e5                	mov    %esp,%ebp
  8009c1:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  8009c4:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  8009c7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009cb:	8b 45 10             	mov    0x10(%ebp),%eax
  8009ce:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009dc:	89 04 24             	mov    %eax,(%esp)
  8009df:	e8 6c fa ff ff       	call   800450 <vprintfmt>
	va_end(ap);
}
  8009e4:	c9                   	leave  
  8009e5:	c3                   	ret    
	...

008009f0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009f0:	55                   	push   %ebp
  8009f1:	89 e5                	mov    %esp,%ebp
  8009f3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8009fb:	80 3a 00             	cmpb   $0x0,(%edx)
  8009fe:	74 09                	je     800a09 <strlen+0x19>
		n++;
  800a00:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a03:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a07:	75 f7                	jne    800a00 <strlen+0x10>
		n++;
	return n;
}
  800a09:	5d                   	pop    %ebp
  800a0a:	c3                   	ret    

00800a0b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a0b:	55                   	push   %ebp
  800a0c:	89 e5                	mov    %esp,%ebp
  800a0e:	53                   	push   %ebx
  800a0f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a15:	85 c9                	test   %ecx,%ecx
  800a17:	74 19                	je     800a32 <strnlen+0x27>
  800a19:	80 3b 00             	cmpb   $0x0,(%ebx)
  800a1c:	74 14                	je     800a32 <strnlen+0x27>
  800a1e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800a23:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a26:	39 c8                	cmp    %ecx,%eax
  800a28:	74 0d                	je     800a37 <strnlen+0x2c>
  800a2a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800a2e:	75 f3                	jne    800a23 <strnlen+0x18>
  800a30:	eb 05                	jmp    800a37 <strnlen+0x2c>
  800a32:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800a37:	5b                   	pop    %ebx
  800a38:	5d                   	pop    %ebp
  800a39:	c3                   	ret    

00800a3a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a3a:	55                   	push   %ebp
  800a3b:	89 e5                	mov    %esp,%ebp
  800a3d:	53                   	push   %ebx
  800a3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a41:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a44:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a49:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800a4d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a50:	83 c2 01             	add    $0x1,%edx
  800a53:	84 c9                	test   %cl,%cl
  800a55:	75 f2                	jne    800a49 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800a57:	5b                   	pop    %ebx
  800a58:	5d                   	pop    %ebp
  800a59:	c3                   	ret    

00800a5a <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a5a:	55                   	push   %ebp
  800a5b:	89 e5                	mov    %esp,%ebp
  800a5d:	53                   	push   %ebx
  800a5e:	83 ec 08             	sub    $0x8,%esp
  800a61:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a64:	89 1c 24             	mov    %ebx,(%esp)
  800a67:	e8 84 ff ff ff       	call   8009f0 <strlen>
	strcpy(dst + len, src);
  800a6c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a6f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a73:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800a76:	89 04 24             	mov    %eax,(%esp)
  800a79:	e8 bc ff ff ff       	call   800a3a <strcpy>
	return dst;
}
  800a7e:	89 d8                	mov    %ebx,%eax
  800a80:	83 c4 08             	add    $0x8,%esp
  800a83:	5b                   	pop    %ebx
  800a84:	5d                   	pop    %ebp
  800a85:	c3                   	ret    

00800a86 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a86:	55                   	push   %ebp
  800a87:	89 e5                	mov    %esp,%ebp
  800a89:	56                   	push   %esi
  800a8a:	53                   	push   %ebx
  800a8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a91:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a94:	85 f6                	test   %esi,%esi
  800a96:	74 18                	je     800ab0 <strncpy+0x2a>
  800a98:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800a9d:	0f b6 1a             	movzbl (%edx),%ebx
  800aa0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800aa3:	80 3a 01             	cmpb   $0x1,(%edx)
  800aa6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800aa9:	83 c1 01             	add    $0x1,%ecx
  800aac:	39 ce                	cmp    %ecx,%esi
  800aae:	77 ed                	ja     800a9d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800ab0:	5b                   	pop    %ebx
  800ab1:	5e                   	pop    %esi
  800ab2:	5d                   	pop    %ebp
  800ab3:	c3                   	ret    

00800ab4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ab4:	55                   	push   %ebp
  800ab5:	89 e5                	mov    %esp,%ebp
  800ab7:	56                   	push   %esi
  800ab8:	53                   	push   %ebx
  800ab9:	8b 75 08             	mov    0x8(%ebp),%esi
  800abc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800abf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ac2:	89 f0                	mov    %esi,%eax
  800ac4:	85 c9                	test   %ecx,%ecx
  800ac6:	74 27                	je     800aef <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800ac8:	83 e9 01             	sub    $0x1,%ecx
  800acb:	74 1d                	je     800aea <strlcpy+0x36>
  800acd:	0f b6 1a             	movzbl (%edx),%ebx
  800ad0:	84 db                	test   %bl,%bl
  800ad2:	74 16                	je     800aea <strlcpy+0x36>
			*dst++ = *src++;
  800ad4:	88 18                	mov    %bl,(%eax)
  800ad6:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ad9:	83 e9 01             	sub    $0x1,%ecx
  800adc:	74 0e                	je     800aec <strlcpy+0x38>
			*dst++ = *src++;
  800ade:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ae1:	0f b6 1a             	movzbl (%edx),%ebx
  800ae4:	84 db                	test   %bl,%bl
  800ae6:	75 ec                	jne    800ad4 <strlcpy+0x20>
  800ae8:	eb 02                	jmp    800aec <strlcpy+0x38>
  800aea:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800aec:	c6 00 00             	movb   $0x0,(%eax)
  800aef:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800af1:	5b                   	pop    %ebx
  800af2:	5e                   	pop    %esi
  800af3:	5d                   	pop    %ebp
  800af4:	c3                   	ret    

00800af5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800af5:	55                   	push   %ebp
  800af6:	89 e5                	mov    %esp,%ebp
  800af8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800afb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800afe:	0f b6 01             	movzbl (%ecx),%eax
  800b01:	84 c0                	test   %al,%al
  800b03:	74 15                	je     800b1a <strcmp+0x25>
  800b05:	3a 02                	cmp    (%edx),%al
  800b07:	75 11                	jne    800b1a <strcmp+0x25>
		p++, q++;
  800b09:	83 c1 01             	add    $0x1,%ecx
  800b0c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b0f:	0f b6 01             	movzbl (%ecx),%eax
  800b12:	84 c0                	test   %al,%al
  800b14:	74 04                	je     800b1a <strcmp+0x25>
  800b16:	3a 02                	cmp    (%edx),%al
  800b18:	74 ef                	je     800b09 <strcmp+0x14>
  800b1a:	0f b6 c0             	movzbl %al,%eax
  800b1d:	0f b6 12             	movzbl (%edx),%edx
  800b20:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b22:	5d                   	pop    %ebp
  800b23:	c3                   	ret    

00800b24 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b24:	55                   	push   %ebp
  800b25:	89 e5                	mov    %esp,%ebp
  800b27:	53                   	push   %ebx
  800b28:	8b 55 08             	mov    0x8(%ebp),%edx
  800b2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b2e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800b31:	85 c0                	test   %eax,%eax
  800b33:	74 23                	je     800b58 <strncmp+0x34>
  800b35:	0f b6 1a             	movzbl (%edx),%ebx
  800b38:	84 db                	test   %bl,%bl
  800b3a:	74 25                	je     800b61 <strncmp+0x3d>
  800b3c:	3a 19                	cmp    (%ecx),%bl
  800b3e:	75 21                	jne    800b61 <strncmp+0x3d>
  800b40:	83 e8 01             	sub    $0x1,%eax
  800b43:	74 13                	je     800b58 <strncmp+0x34>
		n--, p++, q++;
  800b45:	83 c2 01             	add    $0x1,%edx
  800b48:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b4b:	0f b6 1a             	movzbl (%edx),%ebx
  800b4e:	84 db                	test   %bl,%bl
  800b50:	74 0f                	je     800b61 <strncmp+0x3d>
  800b52:	3a 19                	cmp    (%ecx),%bl
  800b54:	74 ea                	je     800b40 <strncmp+0x1c>
  800b56:	eb 09                	jmp    800b61 <strncmp+0x3d>
  800b58:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b5d:	5b                   	pop    %ebx
  800b5e:	5d                   	pop    %ebp
  800b5f:	90                   	nop
  800b60:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b61:	0f b6 02             	movzbl (%edx),%eax
  800b64:	0f b6 11             	movzbl (%ecx),%edx
  800b67:	29 d0                	sub    %edx,%eax
  800b69:	eb f2                	jmp    800b5d <strncmp+0x39>

00800b6b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b6b:	55                   	push   %ebp
  800b6c:	89 e5                	mov    %esp,%ebp
  800b6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b71:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b75:	0f b6 10             	movzbl (%eax),%edx
  800b78:	84 d2                	test   %dl,%dl
  800b7a:	74 18                	je     800b94 <strchr+0x29>
		if (*s == c)
  800b7c:	38 ca                	cmp    %cl,%dl
  800b7e:	75 0a                	jne    800b8a <strchr+0x1f>
  800b80:	eb 17                	jmp    800b99 <strchr+0x2e>
  800b82:	38 ca                	cmp    %cl,%dl
  800b84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800b88:	74 0f                	je     800b99 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b8a:	83 c0 01             	add    $0x1,%eax
  800b8d:	0f b6 10             	movzbl (%eax),%edx
  800b90:	84 d2                	test   %dl,%dl
  800b92:	75 ee                	jne    800b82 <strchr+0x17>
  800b94:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800b99:	5d                   	pop    %ebp
  800b9a:	c3                   	ret    

00800b9b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b9b:	55                   	push   %ebp
  800b9c:	89 e5                	mov    %esp,%ebp
  800b9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ba5:	0f b6 10             	movzbl (%eax),%edx
  800ba8:	84 d2                	test   %dl,%dl
  800baa:	74 18                	je     800bc4 <strfind+0x29>
		if (*s == c)
  800bac:	38 ca                	cmp    %cl,%dl
  800bae:	75 0a                	jne    800bba <strfind+0x1f>
  800bb0:	eb 12                	jmp    800bc4 <strfind+0x29>
  800bb2:	38 ca                	cmp    %cl,%dl
  800bb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800bb8:	74 0a                	je     800bc4 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800bba:	83 c0 01             	add    $0x1,%eax
  800bbd:	0f b6 10             	movzbl (%eax),%edx
  800bc0:	84 d2                	test   %dl,%dl
  800bc2:	75 ee                	jne    800bb2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800bc4:	5d                   	pop    %ebp
  800bc5:	c3                   	ret    

00800bc6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bc6:	55                   	push   %ebp
  800bc7:	89 e5                	mov    %esp,%ebp
  800bc9:	83 ec 0c             	sub    $0xc,%esp
  800bcc:	89 1c 24             	mov    %ebx,(%esp)
  800bcf:	89 74 24 04          	mov    %esi,0x4(%esp)
  800bd3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800bd7:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bda:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bdd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800be0:	85 c9                	test   %ecx,%ecx
  800be2:	74 30                	je     800c14 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800be4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bea:	75 25                	jne    800c11 <memset+0x4b>
  800bec:	f6 c1 03             	test   $0x3,%cl
  800bef:	75 20                	jne    800c11 <memset+0x4b>
		c &= 0xFF;
  800bf1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bf4:	89 d3                	mov    %edx,%ebx
  800bf6:	c1 e3 08             	shl    $0x8,%ebx
  800bf9:	89 d6                	mov    %edx,%esi
  800bfb:	c1 e6 18             	shl    $0x18,%esi
  800bfe:	89 d0                	mov    %edx,%eax
  800c00:	c1 e0 10             	shl    $0x10,%eax
  800c03:	09 f0                	or     %esi,%eax
  800c05:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800c07:	09 d8                	or     %ebx,%eax
  800c09:	c1 e9 02             	shr    $0x2,%ecx
  800c0c:	fc                   	cld    
  800c0d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c0f:	eb 03                	jmp    800c14 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c11:	fc                   	cld    
  800c12:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c14:	89 f8                	mov    %edi,%eax
  800c16:	8b 1c 24             	mov    (%esp),%ebx
  800c19:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c1d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c21:	89 ec                	mov    %ebp,%esp
  800c23:	5d                   	pop    %ebp
  800c24:	c3                   	ret    

00800c25 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c25:	55                   	push   %ebp
  800c26:	89 e5                	mov    %esp,%ebp
  800c28:	83 ec 08             	sub    $0x8,%esp
  800c2b:	89 34 24             	mov    %esi,(%esp)
  800c2e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800c32:	8b 45 08             	mov    0x8(%ebp),%eax
  800c35:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800c38:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800c3b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800c3d:	39 c6                	cmp    %eax,%esi
  800c3f:	73 35                	jae    800c76 <memmove+0x51>
  800c41:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c44:	39 d0                	cmp    %edx,%eax
  800c46:	73 2e                	jae    800c76 <memmove+0x51>
		s += n;
		d += n;
  800c48:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c4a:	f6 c2 03             	test   $0x3,%dl
  800c4d:	75 1b                	jne    800c6a <memmove+0x45>
  800c4f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c55:	75 13                	jne    800c6a <memmove+0x45>
  800c57:	f6 c1 03             	test   $0x3,%cl
  800c5a:	75 0e                	jne    800c6a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800c5c:	83 ef 04             	sub    $0x4,%edi
  800c5f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c62:	c1 e9 02             	shr    $0x2,%ecx
  800c65:	fd                   	std    
  800c66:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c68:	eb 09                	jmp    800c73 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c6a:	83 ef 01             	sub    $0x1,%edi
  800c6d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800c70:	fd                   	std    
  800c71:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c73:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c74:	eb 20                	jmp    800c96 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c76:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c7c:	75 15                	jne    800c93 <memmove+0x6e>
  800c7e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c84:	75 0d                	jne    800c93 <memmove+0x6e>
  800c86:	f6 c1 03             	test   $0x3,%cl
  800c89:	75 08                	jne    800c93 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800c8b:	c1 e9 02             	shr    $0x2,%ecx
  800c8e:	fc                   	cld    
  800c8f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c91:	eb 03                	jmp    800c96 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c93:	fc                   	cld    
  800c94:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c96:	8b 34 24             	mov    (%esp),%esi
  800c99:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800c9d:	89 ec                	mov    %ebp,%esp
  800c9f:	5d                   	pop    %ebp
  800ca0:	c3                   	ret    

00800ca1 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800ca1:	55                   	push   %ebp
  800ca2:	89 e5                	mov    %esp,%ebp
  800ca4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ca7:	8b 45 10             	mov    0x10(%ebp),%eax
  800caa:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cae:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cb1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cb5:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb8:	89 04 24             	mov    %eax,(%esp)
  800cbb:	e8 65 ff ff ff       	call   800c25 <memmove>
}
  800cc0:	c9                   	leave  
  800cc1:	c3                   	ret    

00800cc2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800cc2:	55                   	push   %ebp
  800cc3:	89 e5                	mov    %esp,%ebp
  800cc5:	57                   	push   %edi
  800cc6:	56                   	push   %esi
  800cc7:	53                   	push   %ebx
  800cc8:	8b 75 08             	mov    0x8(%ebp),%esi
  800ccb:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800cce:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cd1:	85 c9                	test   %ecx,%ecx
  800cd3:	74 36                	je     800d0b <memcmp+0x49>
		if (*s1 != *s2)
  800cd5:	0f b6 06             	movzbl (%esi),%eax
  800cd8:	0f b6 1f             	movzbl (%edi),%ebx
  800cdb:	38 d8                	cmp    %bl,%al
  800cdd:	74 20                	je     800cff <memcmp+0x3d>
  800cdf:	eb 14                	jmp    800cf5 <memcmp+0x33>
  800ce1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800ce6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800ceb:	83 c2 01             	add    $0x1,%edx
  800cee:	83 e9 01             	sub    $0x1,%ecx
  800cf1:	38 d8                	cmp    %bl,%al
  800cf3:	74 12                	je     800d07 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800cf5:	0f b6 c0             	movzbl %al,%eax
  800cf8:	0f b6 db             	movzbl %bl,%ebx
  800cfb:	29 d8                	sub    %ebx,%eax
  800cfd:	eb 11                	jmp    800d10 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cff:	83 e9 01             	sub    $0x1,%ecx
  800d02:	ba 00 00 00 00       	mov    $0x0,%edx
  800d07:	85 c9                	test   %ecx,%ecx
  800d09:	75 d6                	jne    800ce1 <memcmp+0x1f>
  800d0b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800d10:	5b                   	pop    %ebx
  800d11:	5e                   	pop    %esi
  800d12:	5f                   	pop    %edi
  800d13:	5d                   	pop    %ebp
  800d14:	c3                   	ret    

00800d15 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d15:	55                   	push   %ebp
  800d16:	89 e5                	mov    %esp,%ebp
  800d18:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800d1b:	89 c2                	mov    %eax,%edx
  800d1d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d20:	39 d0                	cmp    %edx,%eax
  800d22:	73 15                	jae    800d39 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d24:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800d28:	38 08                	cmp    %cl,(%eax)
  800d2a:	75 06                	jne    800d32 <memfind+0x1d>
  800d2c:	eb 0b                	jmp    800d39 <memfind+0x24>
  800d2e:	38 08                	cmp    %cl,(%eax)
  800d30:	74 07                	je     800d39 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d32:	83 c0 01             	add    $0x1,%eax
  800d35:	39 c2                	cmp    %eax,%edx
  800d37:	77 f5                	ja     800d2e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d39:	5d                   	pop    %ebp
  800d3a:	c3                   	ret    

00800d3b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d3b:	55                   	push   %ebp
  800d3c:	89 e5                	mov    %esp,%ebp
  800d3e:	57                   	push   %edi
  800d3f:	56                   	push   %esi
  800d40:	53                   	push   %ebx
  800d41:	83 ec 04             	sub    $0x4,%esp
  800d44:	8b 55 08             	mov    0x8(%ebp),%edx
  800d47:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d4a:	0f b6 02             	movzbl (%edx),%eax
  800d4d:	3c 20                	cmp    $0x20,%al
  800d4f:	74 04                	je     800d55 <strtol+0x1a>
  800d51:	3c 09                	cmp    $0x9,%al
  800d53:	75 0e                	jne    800d63 <strtol+0x28>
		s++;
  800d55:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d58:	0f b6 02             	movzbl (%edx),%eax
  800d5b:	3c 20                	cmp    $0x20,%al
  800d5d:	74 f6                	je     800d55 <strtol+0x1a>
  800d5f:	3c 09                	cmp    $0x9,%al
  800d61:	74 f2                	je     800d55 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d63:	3c 2b                	cmp    $0x2b,%al
  800d65:	75 0c                	jne    800d73 <strtol+0x38>
		s++;
  800d67:	83 c2 01             	add    $0x1,%edx
  800d6a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800d71:	eb 15                	jmp    800d88 <strtol+0x4d>
	else if (*s == '-')
  800d73:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800d7a:	3c 2d                	cmp    $0x2d,%al
  800d7c:	75 0a                	jne    800d88 <strtol+0x4d>
		s++, neg = 1;
  800d7e:	83 c2 01             	add    $0x1,%edx
  800d81:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d88:	85 db                	test   %ebx,%ebx
  800d8a:	0f 94 c0             	sete   %al
  800d8d:	74 05                	je     800d94 <strtol+0x59>
  800d8f:	83 fb 10             	cmp    $0x10,%ebx
  800d92:	75 18                	jne    800dac <strtol+0x71>
  800d94:	80 3a 30             	cmpb   $0x30,(%edx)
  800d97:	75 13                	jne    800dac <strtol+0x71>
  800d99:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d9d:	8d 76 00             	lea    0x0(%esi),%esi
  800da0:	75 0a                	jne    800dac <strtol+0x71>
		s += 2, base = 16;
  800da2:	83 c2 02             	add    $0x2,%edx
  800da5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800daa:	eb 15                	jmp    800dc1 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800dac:	84 c0                	test   %al,%al
  800dae:	66 90                	xchg   %ax,%ax
  800db0:	74 0f                	je     800dc1 <strtol+0x86>
  800db2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800db7:	80 3a 30             	cmpb   $0x30,(%edx)
  800dba:	75 05                	jne    800dc1 <strtol+0x86>
		s++, base = 8;
  800dbc:	83 c2 01             	add    $0x1,%edx
  800dbf:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800dc1:	b8 00 00 00 00       	mov    $0x0,%eax
  800dc6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800dc8:	0f b6 0a             	movzbl (%edx),%ecx
  800dcb:	89 cf                	mov    %ecx,%edi
  800dcd:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800dd0:	80 fb 09             	cmp    $0x9,%bl
  800dd3:	77 08                	ja     800ddd <strtol+0xa2>
			dig = *s - '0';
  800dd5:	0f be c9             	movsbl %cl,%ecx
  800dd8:	83 e9 30             	sub    $0x30,%ecx
  800ddb:	eb 1e                	jmp    800dfb <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800ddd:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800de0:	80 fb 19             	cmp    $0x19,%bl
  800de3:	77 08                	ja     800ded <strtol+0xb2>
			dig = *s - 'a' + 10;
  800de5:	0f be c9             	movsbl %cl,%ecx
  800de8:	83 e9 57             	sub    $0x57,%ecx
  800deb:	eb 0e                	jmp    800dfb <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800ded:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800df0:	80 fb 19             	cmp    $0x19,%bl
  800df3:	77 15                	ja     800e0a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800df5:	0f be c9             	movsbl %cl,%ecx
  800df8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800dfb:	39 f1                	cmp    %esi,%ecx
  800dfd:	7d 0b                	jge    800e0a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800dff:	83 c2 01             	add    $0x1,%edx
  800e02:	0f af c6             	imul   %esi,%eax
  800e05:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800e08:	eb be                	jmp    800dc8 <strtol+0x8d>
  800e0a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800e0c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e10:	74 05                	je     800e17 <strtol+0xdc>
		*endptr = (char *) s;
  800e12:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e15:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800e17:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800e1b:	74 04                	je     800e21 <strtol+0xe6>
  800e1d:	89 c8                	mov    %ecx,%eax
  800e1f:	f7 d8                	neg    %eax
}
  800e21:	83 c4 04             	add    $0x4,%esp
  800e24:	5b                   	pop    %ebx
  800e25:	5e                   	pop    %esi
  800e26:	5f                   	pop    %edi
  800e27:	5d                   	pop    %ebp
  800e28:	c3                   	ret    
  800e29:	00 00                	add    %al,(%eax)
	...

00800e2c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800e2c:	55                   	push   %ebp
  800e2d:	89 e5                	mov    %esp,%ebp
  800e2f:	83 ec 08             	sub    $0x8,%esp
  800e32:	89 1c 24             	mov    %ebx,(%esp)
  800e35:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e39:	b8 00 00 00 00       	mov    $0x0,%eax
  800e3e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e41:	8b 55 08             	mov    0x8(%ebp),%edx
  800e44:	89 c3                	mov    %eax,%ebx
  800e46:	89 c7                	mov    %eax,%edi
  800e48:	51                   	push   %ecx
  800e49:	52                   	push   %edx
  800e4a:	53                   	push   %ebx
  800e4b:	54                   	push   %esp
  800e4c:	55                   	push   %ebp
  800e4d:	56                   	push   %esi
  800e4e:	57                   	push   %edi
  800e4f:	5f                   	pop    %edi
  800e50:	5e                   	pop    %esi
  800e51:	5d                   	pop    %ebp
  800e52:	5c                   	pop    %esp
  800e53:	5b                   	pop    %ebx
  800e54:	5a                   	pop    %edx
  800e55:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800e56:	8b 1c 24             	mov    (%esp),%ebx
  800e59:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e5d:	89 ec                	mov    %ebp,%esp
  800e5f:	5d                   	pop    %ebp
  800e60:	c3                   	ret    

00800e61 <sys_cgetc>:

int
sys_cgetc(void)
{
  800e61:	55                   	push   %ebp
  800e62:	89 e5                	mov    %esp,%ebp
  800e64:	83 ec 08             	sub    $0x8,%esp
  800e67:	89 1c 24             	mov    %ebx,(%esp)
  800e6a:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e6e:	ba 00 00 00 00       	mov    $0x0,%edx
  800e73:	b8 01 00 00 00       	mov    $0x1,%eax
  800e78:	89 d1                	mov    %edx,%ecx
  800e7a:	89 d3                	mov    %edx,%ebx
  800e7c:	89 d7                	mov    %edx,%edi
  800e7e:	51                   	push   %ecx
  800e7f:	52                   	push   %edx
  800e80:	53                   	push   %ebx
  800e81:	54                   	push   %esp
  800e82:	55                   	push   %ebp
  800e83:	56                   	push   %esi
  800e84:	57                   	push   %edi
  800e85:	5f                   	pop    %edi
  800e86:	5e                   	pop    %esi
  800e87:	5d                   	pop    %ebp
  800e88:	5c                   	pop    %esp
  800e89:	5b                   	pop    %ebx
  800e8a:	5a                   	pop    %edx
  800e8b:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e8c:	8b 1c 24             	mov    (%esp),%ebx
  800e8f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e93:	89 ec                	mov    %ebp,%esp
  800e95:	5d                   	pop    %ebp
  800e96:	c3                   	ret    

00800e97 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800e97:	55                   	push   %ebp
  800e98:	89 e5                	mov    %esp,%ebp
  800e9a:	83 ec 08             	sub    $0x8,%esp
  800e9d:	89 1c 24             	mov    %ebx,(%esp)
  800ea0:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800ea4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ea9:	b8 02 00 00 00       	mov    $0x2,%eax
  800eae:	89 d1                	mov    %edx,%ecx
  800eb0:	89 d3                	mov    %edx,%ebx
  800eb2:	89 d7                	mov    %edx,%edi
  800eb4:	51                   	push   %ecx
  800eb5:	52                   	push   %edx
  800eb6:	53                   	push   %ebx
  800eb7:	54                   	push   %esp
  800eb8:	55                   	push   %ebp
  800eb9:	56                   	push   %esi
  800eba:	57                   	push   %edi
  800ebb:	5f                   	pop    %edi
  800ebc:	5e                   	pop    %esi
  800ebd:	5d                   	pop    %ebp
  800ebe:	5c                   	pop    %esp
  800ebf:	5b                   	pop    %ebx
  800ec0:	5a                   	pop    %edx
  800ec1:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ec2:	8b 1c 24             	mov    (%esp),%ebx
  800ec5:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ec9:	89 ec                	mov    %ebp,%esp
  800ecb:	5d                   	pop    %ebp
  800ecc:	c3                   	ret    

00800ecd <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800ecd:	55                   	push   %ebp
  800ece:	89 e5                	mov    %esp,%ebp
  800ed0:	83 ec 08             	sub    $0x8,%esp
  800ed3:	89 1c 24             	mov    %ebx,(%esp)
  800ed6:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800eda:	bb 00 00 00 00       	mov    $0x0,%ebx
  800edf:	b8 04 00 00 00       	mov    $0x4,%eax
  800ee4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee7:	8b 55 08             	mov    0x8(%ebp),%edx
  800eea:	89 df                	mov    %ebx,%edi
  800eec:	51                   	push   %ecx
  800eed:	52                   	push   %edx
  800eee:	53                   	push   %ebx
  800eef:	54                   	push   %esp
  800ef0:	55                   	push   %ebp
  800ef1:	56                   	push   %esi
  800ef2:	57                   	push   %edi
  800ef3:	5f                   	pop    %edi
  800ef4:	5e                   	pop    %esi
  800ef5:	5d                   	pop    %ebp
  800ef6:	5c                   	pop    %esp
  800ef7:	5b                   	pop    %ebx
  800ef8:	5a                   	pop    %edx
  800ef9:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800efa:	8b 1c 24             	mov    (%esp),%ebx
  800efd:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f01:	89 ec                	mov    %ebp,%esp
  800f03:	5d                   	pop    %ebp
  800f04:	c3                   	ret    

00800f05 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  800f05:	55                   	push   %ebp
  800f06:	89 e5                	mov    %esp,%ebp
  800f08:	83 ec 08             	sub    $0x8,%esp
  800f0b:	89 1c 24             	mov    %ebx,(%esp)
  800f0e:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f12:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f17:	b8 05 00 00 00       	mov    $0x5,%eax
  800f1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800f1f:	89 cb                	mov    %ecx,%ebx
  800f21:	89 cf                	mov    %ecx,%edi
  800f23:	51                   	push   %ecx
  800f24:	52                   	push   %edx
  800f25:	53                   	push   %ebx
  800f26:	54                   	push   %esp
  800f27:	55                   	push   %ebp
  800f28:	56                   	push   %esi
  800f29:	57                   	push   %edi
  800f2a:	5f                   	pop    %edi
  800f2b:	5e                   	pop    %esi
  800f2c:	5d                   	pop    %ebp
  800f2d:	5c                   	pop    %esp
  800f2e:	5b                   	pop    %ebx
  800f2f:	5a                   	pop    %edx
  800f30:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800f31:	8b 1c 24             	mov    (%esp),%ebx
  800f34:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f38:	89 ec                	mov    %ebp,%esp
  800f3a:	5d                   	pop    %ebp
  800f3b:	c3                   	ret    

00800f3c <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800f3c:	55                   	push   %ebp
  800f3d:	89 e5                	mov    %esp,%ebp
  800f3f:	83 ec 28             	sub    $0x28,%esp
  800f42:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800f45:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f48:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f4d:	b8 03 00 00 00       	mov    $0x3,%eax
  800f52:	8b 55 08             	mov    0x8(%ebp),%edx
  800f55:	89 cb                	mov    %ecx,%ebx
  800f57:	89 cf                	mov    %ecx,%edi
  800f59:	51                   	push   %ecx
  800f5a:	52                   	push   %edx
  800f5b:	53                   	push   %ebx
  800f5c:	54                   	push   %esp
  800f5d:	55                   	push   %ebp
  800f5e:	56                   	push   %esi
  800f5f:	57                   	push   %edi
  800f60:	5f                   	pop    %edi
  800f61:	5e                   	pop    %esi
  800f62:	5d                   	pop    %ebp
  800f63:	5c                   	pop    %esp
  800f64:	5b                   	pop    %ebx
  800f65:	5a                   	pop    %edx
  800f66:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800f67:	85 c0                	test   %eax,%eax
  800f69:	7e 28                	jle    800f93 <sys_env_destroy+0x57>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f6b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f6f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800f76:	00 
  800f77:	c7 44 24 08 30 15 80 	movl   $0x801530,0x8(%esp)
  800f7e:	00 
  800f7f:	c7 44 24 04 26 00 00 	movl   $0x26,0x4(%esp)
  800f86:	00 
  800f87:	c7 04 24 4d 15 80 00 	movl   $0x80154d,(%esp)
  800f8e:	e8 0d 00 00 00       	call   800fa0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800f93:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800f96:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f99:	89 ec                	mov    %ebp,%esp
  800f9b:	5d                   	pop    %ebp
  800f9c:	c3                   	ret    
  800f9d:	00 00                	add    %al,(%eax)
	...

00800fa0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800fa0:	55                   	push   %ebp
  800fa1:	89 e5                	mov    %esp,%ebp
  800fa3:	56                   	push   %esi
  800fa4:	53                   	push   %ebx
  800fa5:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  800fa8:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  800fab:	a1 08 20 80 00       	mov    0x802008,%eax
  800fb0:	85 c0                	test   %eax,%eax
  800fb2:	74 10                	je     800fc4 <_panic+0x24>
		cprintf("%s: ", argv0);
  800fb4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fb8:	c7 04 24 5b 15 80 00 	movl   $0x80155b,(%esp)
  800fbf:	e8 a5 f1 ff ff       	call   800169 <cprintf>
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800fc4:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800fca:	e8 c8 fe ff ff       	call   800e97 <sys_getenvid>
  800fcf:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fd2:	89 54 24 10          	mov    %edx,0x10(%esp)
  800fd6:	8b 55 08             	mov    0x8(%ebp),%edx
  800fd9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800fdd:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800fe1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fe5:	c7 04 24 60 15 80 00 	movl   $0x801560,(%esp)
  800fec:	e8 78 f1 ff ff       	call   800169 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800ff1:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ff5:	8b 45 10             	mov    0x10(%ebp),%eax
  800ff8:	89 04 24             	mov    %eax,(%esp)
  800ffb:	e8 08 f1 ff ff       	call   800108 <vcprintf>
	cprintf("\n");
  801000:	c7 04 24 a5 12 80 00 	movl   $0x8012a5,(%esp)
  801007:	e8 5d f1 ff ff       	call   800169 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80100c:	cc                   	int3   
  80100d:	eb fd                	jmp    80100c <_panic+0x6c>
	...

00801010 <__udivdi3>:
  801010:	55                   	push   %ebp
  801011:	89 e5                	mov    %esp,%ebp
  801013:	57                   	push   %edi
  801014:	56                   	push   %esi
  801015:	83 ec 10             	sub    $0x10,%esp
  801018:	8b 45 14             	mov    0x14(%ebp),%eax
  80101b:	8b 55 08             	mov    0x8(%ebp),%edx
  80101e:	8b 75 10             	mov    0x10(%ebp),%esi
  801021:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801024:	85 c0                	test   %eax,%eax
  801026:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801029:	75 35                	jne    801060 <__udivdi3+0x50>
  80102b:	39 fe                	cmp    %edi,%esi
  80102d:	77 61                	ja     801090 <__udivdi3+0x80>
  80102f:	85 f6                	test   %esi,%esi
  801031:	75 0b                	jne    80103e <__udivdi3+0x2e>
  801033:	b8 01 00 00 00       	mov    $0x1,%eax
  801038:	31 d2                	xor    %edx,%edx
  80103a:	f7 f6                	div    %esi
  80103c:	89 c6                	mov    %eax,%esi
  80103e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801041:	31 d2                	xor    %edx,%edx
  801043:	89 f8                	mov    %edi,%eax
  801045:	f7 f6                	div    %esi
  801047:	89 c7                	mov    %eax,%edi
  801049:	89 c8                	mov    %ecx,%eax
  80104b:	f7 f6                	div    %esi
  80104d:	89 c1                	mov    %eax,%ecx
  80104f:	89 fa                	mov    %edi,%edx
  801051:	89 c8                	mov    %ecx,%eax
  801053:	83 c4 10             	add    $0x10,%esp
  801056:	5e                   	pop    %esi
  801057:	5f                   	pop    %edi
  801058:	5d                   	pop    %ebp
  801059:	c3                   	ret    
  80105a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801060:	39 f8                	cmp    %edi,%eax
  801062:	77 1c                	ja     801080 <__udivdi3+0x70>
  801064:	0f bd d0             	bsr    %eax,%edx
  801067:	83 f2 1f             	xor    $0x1f,%edx
  80106a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80106d:	75 39                	jne    8010a8 <__udivdi3+0x98>
  80106f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801072:	0f 86 a0 00 00 00    	jbe    801118 <__udivdi3+0x108>
  801078:	39 f8                	cmp    %edi,%eax
  80107a:	0f 82 98 00 00 00    	jb     801118 <__udivdi3+0x108>
  801080:	31 ff                	xor    %edi,%edi
  801082:	31 c9                	xor    %ecx,%ecx
  801084:	89 c8                	mov    %ecx,%eax
  801086:	89 fa                	mov    %edi,%edx
  801088:	83 c4 10             	add    $0x10,%esp
  80108b:	5e                   	pop    %esi
  80108c:	5f                   	pop    %edi
  80108d:	5d                   	pop    %ebp
  80108e:	c3                   	ret    
  80108f:	90                   	nop
  801090:	89 d1                	mov    %edx,%ecx
  801092:	89 fa                	mov    %edi,%edx
  801094:	89 c8                	mov    %ecx,%eax
  801096:	31 ff                	xor    %edi,%edi
  801098:	f7 f6                	div    %esi
  80109a:	89 c1                	mov    %eax,%ecx
  80109c:	89 fa                	mov    %edi,%edx
  80109e:	89 c8                	mov    %ecx,%eax
  8010a0:	83 c4 10             	add    $0x10,%esp
  8010a3:	5e                   	pop    %esi
  8010a4:	5f                   	pop    %edi
  8010a5:	5d                   	pop    %ebp
  8010a6:	c3                   	ret    
  8010a7:	90                   	nop
  8010a8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8010ac:	89 f2                	mov    %esi,%edx
  8010ae:	d3 e0                	shl    %cl,%eax
  8010b0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8010b3:	b8 20 00 00 00       	mov    $0x20,%eax
  8010b8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  8010bb:	89 c1                	mov    %eax,%ecx
  8010bd:	d3 ea                	shr    %cl,%edx
  8010bf:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8010c3:	0b 55 ec             	or     -0x14(%ebp),%edx
  8010c6:	d3 e6                	shl    %cl,%esi
  8010c8:	89 c1                	mov    %eax,%ecx
  8010ca:	89 75 e8             	mov    %esi,-0x18(%ebp)
  8010cd:	89 fe                	mov    %edi,%esi
  8010cf:	d3 ee                	shr    %cl,%esi
  8010d1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8010d5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8010d8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010db:	d3 e7                	shl    %cl,%edi
  8010dd:	89 c1                	mov    %eax,%ecx
  8010df:	d3 ea                	shr    %cl,%edx
  8010e1:	09 d7                	or     %edx,%edi
  8010e3:	89 f2                	mov    %esi,%edx
  8010e5:	89 f8                	mov    %edi,%eax
  8010e7:	f7 75 ec             	divl   -0x14(%ebp)
  8010ea:	89 d6                	mov    %edx,%esi
  8010ec:	89 c7                	mov    %eax,%edi
  8010ee:	f7 65 e8             	mull   -0x18(%ebp)
  8010f1:	39 d6                	cmp    %edx,%esi
  8010f3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8010f6:	72 30                	jb     801128 <__udivdi3+0x118>
  8010f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010fb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8010ff:	d3 e2                	shl    %cl,%edx
  801101:	39 c2                	cmp    %eax,%edx
  801103:	73 05                	jae    80110a <__udivdi3+0xfa>
  801105:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801108:	74 1e                	je     801128 <__udivdi3+0x118>
  80110a:	89 f9                	mov    %edi,%ecx
  80110c:	31 ff                	xor    %edi,%edi
  80110e:	e9 71 ff ff ff       	jmp    801084 <__udivdi3+0x74>
  801113:	90                   	nop
  801114:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801118:	31 ff                	xor    %edi,%edi
  80111a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80111f:	e9 60 ff ff ff       	jmp    801084 <__udivdi3+0x74>
  801124:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801128:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80112b:	31 ff                	xor    %edi,%edi
  80112d:	89 c8                	mov    %ecx,%eax
  80112f:	89 fa                	mov    %edi,%edx
  801131:	83 c4 10             	add    $0x10,%esp
  801134:	5e                   	pop    %esi
  801135:	5f                   	pop    %edi
  801136:	5d                   	pop    %ebp
  801137:	c3                   	ret    
	...

00801140 <__umoddi3>:
  801140:	55                   	push   %ebp
  801141:	89 e5                	mov    %esp,%ebp
  801143:	57                   	push   %edi
  801144:	56                   	push   %esi
  801145:	83 ec 20             	sub    $0x20,%esp
  801148:	8b 55 14             	mov    0x14(%ebp),%edx
  80114b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80114e:	8b 7d 10             	mov    0x10(%ebp),%edi
  801151:	8b 75 0c             	mov    0xc(%ebp),%esi
  801154:	85 d2                	test   %edx,%edx
  801156:	89 c8                	mov    %ecx,%eax
  801158:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80115b:	75 13                	jne    801170 <__umoddi3+0x30>
  80115d:	39 f7                	cmp    %esi,%edi
  80115f:	76 3f                	jbe    8011a0 <__umoddi3+0x60>
  801161:	89 f2                	mov    %esi,%edx
  801163:	f7 f7                	div    %edi
  801165:	89 d0                	mov    %edx,%eax
  801167:	31 d2                	xor    %edx,%edx
  801169:	83 c4 20             	add    $0x20,%esp
  80116c:	5e                   	pop    %esi
  80116d:	5f                   	pop    %edi
  80116e:	5d                   	pop    %ebp
  80116f:	c3                   	ret    
  801170:	39 f2                	cmp    %esi,%edx
  801172:	77 4c                	ja     8011c0 <__umoddi3+0x80>
  801174:	0f bd ca             	bsr    %edx,%ecx
  801177:	83 f1 1f             	xor    $0x1f,%ecx
  80117a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80117d:	75 51                	jne    8011d0 <__umoddi3+0x90>
  80117f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801182:	0f 87 e0 00 00 00    	ja     801268 <__umoddi3+0x128>
  801188:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80118b:	29 f8                	sub    %edi,%eax
  80118d:	19 d6                	sbb    %edx,%esi
  80118f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801192:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801195:	89 f2                	mov    %esi,%edx
  801197:	83 c4 20             	add    $0x20,%esp
  80119a:	5e                   	pop    %esi
  80119b:	5f                   	pop    %edi
  80119c:	5d                   	pop    %ebp
  80119d:	c3                   	ret    
  80119e:	66 90                	xchg   %ax,%ax
  8011a0:	85 ff                	test   %edi,%edi
  8011a2:	75 0b                	jne    8011af <__umoddi3+0x6f>
  8011a4:	b8 01 00 00 00       	mov    $0x1,%eax
  8011a9:	31 d2                	xor    %edx,%edx
  8011ab:	f7 f7                	div    %edi
  8011ad:	89 c7                	mov    %eax,%edi
  8011af:	89 f0                	mov    %esi,%eax
  8011b1:	31 d2                	xor    %edx,%edx
  8011b3:	f7 f7                	div    %edi
  8011b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011b8:	f7 f7                	div    %edi
  8011ba:	eb a9                	jmp    801165 <__umoddi3+0x25>
  8011bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011c0:	89 c8                	mov    %ecx,%eax
  8011c2:	89 f2                	mov    %esi,%edx
  8011c4:	83 c4 20             	add    $0x20,%esp
  8011c7:	5e                   	pop    %esi
  8011c8:	5f                   	pop    %edi
  8011c9:	5d                   	pop    %ebp
  8011ca:	c3                   	ret    
  8011cb:	90                   	nop
  8011cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011d0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011d4:	d3 e2                	shl    %cl,%edx
  8011d6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8011d9:	ba 20 00 00 00       	mov    $0x20,%edx
  8011de:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8011e1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8011e4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8011e8:	89 fa                	mov    %edi,%edx
  8011ea:	d3 ea                	shr    %cl,%edx
  8011ec:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011f0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8011f3:	d3 e7                	shl    %cl,%edi
  8011f5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8011f9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8011fc:	89 f2                	mov    %esi,%edx
  8011fe:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801201:	89 c7                	mov    %eax,%edi
  801203:	d3 ea                	shr    %cl,%edx
  801205:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801209:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80120c:	89 c2                	mov    %eax,%edx
  80120e:	d3 e6                	shl    %cl,%esi
  801210:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801214:	d3 ea                	shr    %cl,%edx
  801216:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80121a:	09 d6                	or     %edx,%esi
  80121c:	89 f0                	mov    %esi,%eax
  80121e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801221:	d3 e7                	shl    %cl,%edi
  801223:	89 f2                	mov    %esi,%edx
  801225:	f7 75 f4             	divl   -0xc(%ebp)
  801228:	89 d6                	mov    %edx,%esi
  80122a:	f7 65 e8             	mull   -0x18(%ebp)
  80122d:	39 d6                	cmp    %edx,%esi
  80122f:	72 2b                	jb     80125c <__umoddi3+0x11c>
  801231:	39 c7                	cmp    %eax,%edi
  801233:	72 23                	jb     801258 <__umoddi3+0x118>
  801235:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801239:	29 c7                	sub    %eax,%edi
  80123b:	19 d6                	sbb    %edx,%esi
  80123d:	89 f0                	mov    %esi,%eax
  80123f:	89 f2                	mov    %esi,%edx
  801241:	d3 ef                	shr    %cl,%edi
  801243:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801247:	d3 e0                	shl    %cl,%eax
  801249:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80124d:	09 f8                	or     %edi,%eax
  80124f:	d3 ea                	shr    %cl,%edx
  801251:	83 c4 20             	add    $0x20,%esp
  801254:	5e                   	pop    %esi
  801255:	5f                   	pop    %edi
  801256:	5d                   	pop    %ebp
  801257:	c3                   	ret    
  801258:	39 d6                	cmp    %edx,%esi
  80125a:	75 d9                	jne    801235 <__umoddi3+0xf5>
  80125c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80125f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801262:	eb d1                	jmp    801235 <__umoddi3+0xf5>
  801264:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801268:	39 f2                	cmp    %esi,%edx
  80126a:	0f 82 18 ff ff ff    	jb     801188 <__umoddi3+0x48>
  801270:	e9 1d ff ff ff       	jmp    801192 <__umoddi3+0x52>
