
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4 66                	in     $0x66,%al

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# physical addresses [0, 4MB).  This 4MB region will be suffice
	# until we set up our real page table in mem_init in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 a0 11 00       	mov    $0x11a000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 a0 11 f0       	mov    $0xf011a000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 a6 00 00 00       	call   f01000e4 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 14             	sub    $0x14,%esp
		monitor(NULL);
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
f0100047:	8d 5d 14             	lea    0x14(%ebp),%ebx
{
	va_list ap;

	va_start(ap, fmt);
	cprintf("kernel warning at %s:%d: ", file, line);
f010004a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010004d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100051:	8b 45 08             	mov    0x8(%ebp),%eax
f0100054:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100058:	c7 04 24 40 53 10 f0 	movl   $0xf0105340,(%esp)
f010005f:	e8 b7 3b 00 00       	call   f0103c1b <cprintf>
	vcprintf(fmt, ap);
f0100064:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100068:	8b 45 10             	mov    0x10(%ebp),%eax
f010006b:	89 04 24             	mov    %eax,(%esp)
f010006e:	e8 75 3b 00 00       	call   f0103be8 <vcprintf>
	cprintf("\n");
f0100073:	c7 04 24 85 62 10 f0 	movl   $0xf0106285,(%esp)
f010007a:	e8 9c 3b 00 00       	call   f0103c1b <cprintf>
	va_end(ap);
}
f010007f:	83 c4 14             	add    $0x14,%esp
f0100082:	5b                   	pop    %ebx
f0100083:	5d                   	pop    %ebp
f0100084:	c3                   	ret    

f0100085 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100085:	55                   	push   %ebp
f0100086:	89 e5                	mov    %esp,%ebp
f0100088:	56                   	push   %esi
f0100089:	53                   	push   %ebx
f010008a:	83 ec 10             	sub    $0x10,%esp
f010008d:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100090:	83 3d 00 d3 19 f0 00 	cmpl   $0x0,0xf019d300
f0100097:	75 3d                	jne    f01000d6 <_panic+0x51>
		goto dead;
	panicstr = fmt;
f0100099:	89 35 00 d3 19 f0    	mov    %esi,0xf019d300

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f010009f:	fa                   	cli    
f01000a0:	fc                   	cld    
/*
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
f01000a1:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");

	va_start(ap, fmt);
	cprintf("kernel panic at %s:%d: ", file, line);
f01000a4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01000a7:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000ab:	8b 45 08             	mov    0x8(%ebp),%eax
f01000ae:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000b2:	c7 04 24 5a 53 10 f0 	movl   $0xf010535a,(%esp)
f01000b9:	e8 5d 3b 00 00       	call   f0103c1b <cprintf>
	vcprintf(fmt, ap);
f01000be:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01000c2:	89 34 24             	mov    %esi,(%esp)
f01000c5:	e8 1e 3b 00 00       	call   f0103be8 <vcprintf>
	cprintf("\n");
f01000ca:	c7 04 24 85 62 10 f0 	movl   $0xf0106285,(%esp)
f01000d1:	e8 45 3b 00 00       	call   f0103c1b <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000d6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000dd:	e8 e0 07 00 00       	call   f01008c2 <monitor>
f01000e2:	eb f2                	jmp    f01000d6 <_panic+0x51>

f01000e4 <i386_init>:
#include <kern/trap.h>


void
i386_init(void)
{
f01000e4:	55                   	push   %ebp
f01000e5:	89 e5                	mov    %esp,%ebp
f01000e7:	83 ec 18             	sub    $0x18,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000ea:	b8 10 d3 19 f0       	mov    $0xf019d310,%eax
f01000ef:	2d 13 c4 19 f0       	sub    $0xf019c413,%eax
f01000f4:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000f8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01000ff:	00 
f0100100:	c7 04 24 13 c4 19 f0 	movl   $0xf019c413,(%esp)
f0100107:	e8 4a 4d 00 00       	call   f0104e56 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f010010c:	e8 59 03 00 00       	call   f010046a <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100111:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100118:	00 
f0100119:	c7 04 24 72 53 10 f0 	movl   $0xf0105372,(%esp)
f0100120:	e8 f6 3a 00 00       	call   f0103c1b <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100125:	e8 b3 24 00 00       	call   f01025dd <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f010012a:	e8 f1 36 00 00       	call   f0103820 <env_init>
	trap_init();
f010012f:	90                   	nop
f0100130:	e8 7c 3b 00 00       	call   f0103cb1 <trap_init>

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f0100135:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010013c:	00 
f010013d:	c7 44 24 04 a1 88 00 	movl   $0x88a1,0x4(%esp)
f0100144:	00 
f0100145:	c7 04 24 f5 f6 14 f0 	movl   $0xf014f6f5,(%esp)
f010014c:	e8 d9 36 00 00       	call   f010382a <env_create>
	// Touch all you want.
	ENV_CREATE(user_hello, ENV_TYPE_USER);
#endif // TEST*

	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f0100151:	a1 58 c6 19 f0       	mov    0xf019c658,%eax
f0100156:	89 04 24             	mov    %eax,(%esp)
f0100159:	e8 d1 36 00 00       	call   f010382f <env_run>
	...

f0100160 <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f0100160:	55                   	push   %ebp
f0100161:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100163:	ba 84 00 00 00       	mov    $0x84,%edx
f0100168:	ec                   	in     (%dx),%al
f0100169:	ec                   	in     (%dx),%al
f010016a:	ec                   	in     (%dx),%al
f010016b:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f010016c:	5d                   	pop    %ebp
f010016d:	c3                   	ret    

f010016e <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010016e:	55                   	push   %ebp
f010016f:	89 e5                	mov    %esp,%ebp
f0100171:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100176:	ec                   	in     (%dx),%al
f0100177:	89 c2                	mov    %eax,%edx
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100179:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010017e:	f6 c2 01             	test   $0x1,%dl
f0100181:	74 09                	je     f010018c <serial_proc_data+0x1e>
f0100183:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100188:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100189:	0f b6 c0             	movzbl %al,%eax
}
f010018c:	5d                   	pop    %ebp
f010018d:	c3                   	ret    

f010018e <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010018e:	55                   	push   %ebp
f010018f:	89 e5                	mov    %esp,%ebp
f0100191:	57                   	push   %edi
f0100192:	56                   	push   %esi
f0100193:	53                   	push   %ebx
f0100194:	83 ec 0c             	sub    $0xc,%esp
f0100197:	89 c6                	mov    %eax,%esi
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
f0100199:	bb 44 c6 19 f0       	mov    $0xf019c644,%ebx
f010019e:	bf 40 c4 19 f0       	mov    $0xf019c440,%edi
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01001a3:	eb 1e                	jmp    f01001c3 <cons_intr+0x35>
		if (c == 0)
f01001a5:	85 c0                	test   %eax,%eax
f01001a7:	74 1a                	je     f01001c3 <cons_intr+0x35>
			continue;
		cons.buf[cons.wpos++] = c;
f01001a9:	8b 13                	mov    (%ebx),%edx
f01001ab:	88 04 17             	mov    %al,(%edi,%edx,1)
f01001ae:	8d 42 01             	lea    0x1(%edx),%eax
		if (cons.wpos == CONSBUFSIZE)
f01001b1:	3d 00 02 00 00       	cmp    $0x200,%eax
			cons.wpos = 0;
f01001b6:	0f 94 c2             	sete   %dl
f01001b9:	0f b6 d2             	movzbl %dl,%edx
f01001bc:	83 ea 01             	sub    $0x1,%edx
f01001bf:	21 d0                	and    %edx,%eax
f01001c1:	89 03                	mov    %eax,(%ebx)
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01001c3:	ff d6                	call   *%esi
f01001c5:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001c8:	75 db                	jne    f01001a5 <cons_intr+0x17>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01001ca:	83 c4 0c             	add    $0xc,%esp
f01001cd:	5b                   	pop    %ebx
f01001ce:	5e                   	pop    %esi
f01001cf:	5f                   	pop    %edi
f01001d0:	5d                   	pop    %ebp
f01001d1:	c3                   	ret    

f01001d2 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01001d2:	55                   	push   %ebp
f01001d3:	89 e5                	mov    %esp,%ebp
f01001d5:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01001d8:	b8 5a 05 10 f0       	mov    $0xf010055a,%eax
f01001dd:	e8 ac ff ff ff       	call   f010018e <cons_intr>
}
f01001e2:	c9                   	leave  
f01001e3:	c3                   	ret    

f01001e4 <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01001e4:	55                   	push   %ebp
f01001e5:	89 e5                	mov    %esp,%ebp
f01001e7:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f01001ea:	83 3d 24 c4 19 f0 00 	cmpl   $0x0,0xf019c424
f01001f1:	74 0a                	je     f01001fd <serial_intr+0x19>
		cons_intr(serial_proc_data);
f01001f3:	b8 6e 01 10 f0       	mov    $0xf010016e,%eax
f01001f8:	e8 91 ff ff ff       	call   f010018e <cons_intr>
}
f01001fd:	c9                   	leave  
f01001fe:	c3                   	ret    

f01001ff <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01001ff:	55                   	push   %ebp
f0100200:	89 e5                	mov    %esp,%ebp
f0100202:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f0100205:	e8 da ff ff ff       	call   f01001e4 <serial_intr>
	kbd_intr();
f010020a:	e8 c3 ff ff ff       	call   f01001d2 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f010020f:	8b 15 40 c6 19 f0    	mov    0xf019c640,%edx
f0100215:	b8 00 00 00 00       	mov    $0x0,%eax
f010021a:	3b 15 44 c6 19 f0    	cmp    0xf019c644,%edx
f0100220:	74 21                	je     f0100243 <cons_getc+0x44>
		c = cons.buf[cons.rpos++];
f0100222:	0f b6 82 40 c4 19 f0 	movzbl -0xfe63bc0(%edx),%eax
f0100229:	83 c2 01             	add    $0x1,%edx
		if (cons.rpos == CONSBUFSIZE)
f010022c:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.rpos = 0;
f0100232:	0f 94 c1             	sete   %cl
f0100235:	0f b6 c9             	movzbl %cl,%ecx
f0100238:	83 e9 01             	sub    $0x1,%ecx
f010023b:	21 ca                	and    %ecx,%edx
f010023d:	89 15 40 c6 19 f0    	mov    %edx,0xf019c640
		return c;
	}
	return 0;
}
f0100243:	c9                   	leave  
f0100244:	c3                   	ret    

f0100245 <getchar>:
	cons_putc(c);
}

int
getchar(void)
{
f0100245:	55                   	push   %ebp
f0100246:	89 e5                	mov    %esp,%ebp
f0100248:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010024b:	e8 af ff ff ff       	call   f01001ff <cons_getc>
f0100250:	85 c0                	test   %eax,%eax
f0100252:	74 f7                	je     f010024b <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100254:	c9                   	leave  
f0100255:	c3                   	ret    

f0100256 <iscons>:

int
iscons(int fdnum)
{
f0100256:	55                   	push   %ebp
f0100257:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100259:	b8 01 00 00 00       	mov    $0x1,%eax
f010025e:	5d                   	pop    %ebp
f010025f:	c3                   	ret    

f0100260 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100260:	55                   	push   %ebp
f0100261:	89 e5                	mov    %esp,%ebp
f0100263:	57                   	push   %edi
f0100264:	56                   	push   %esi
f0100265:	53                   	push   %ebx
f0100266:	83 ec 2c             	sub    $0x2c,%esp
f0100269:	89 c7                	mov    %eax,%edi
f010026b:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100270:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;
	
	for (i = 0;
f0100271:	a8 20                	test   $0x20,%al
f0100273:	75 21                	jne    f0100296 <cons_putc+0x36>
f0100275:	bb 00 00 00 00       	mov    $0x0,%ebx
f010027a:	be fd 03 00 00       	mov    $0x3fd,%esi
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f010027f:	e8 dc fe ff ff       	call   f0100160 <delay>
f0100284:	89 f2                	mov    %esi,%edx
f0100286:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;
	
	for (i = 0;
f0100287:	a8 20                	test   $0x20,%al
f0100289:	75 0b                	jne    f0100296 <cons_putc+0x36>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f010028b:	83 c3 01             	add    $0x1,%ebx
static void
serial_putc(int c)
{
	int i;
	
	for (i = 0;
f010028e:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f0100294:	75 e9                	jne    f010027f <cons_putc+0x1f>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
	
	outb(COM1 + COM_TX, c);
f0100296:	89 fa                	mov    %edi,%edx
f0100298:	89 f8                	mov    %edi,%eax
f010029a:	88 55 e7             	mov    %dl,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010029d:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01002a2:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002a3:	b2 79                	mov    $0x79,%dl
f01002a5:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01002a6:	84 c0                	test   %al,%al
f01002a8:	78 21                	js     f01002cb <cons_putc+0x6b>
f01002aa:	bb 00 00 00 00       	mov    $0x0,%ebx
f01002af:	be 79 03 00 00       	mov    $0x379,%esi
		delay();
f01002b4:	e8 a7 fe ff ff       	call   f0100160 <delay>
f01002b9:	89 f2                	mov    %esi,%edx
f01002bb:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01002bc:	84 c0                	test   %al,%al
f01002be:	78 0b                	js     f01002cb <cons_putc+0x6b>
f01002c0:	83 c3 01             	add    $0x1,%ebx
f01002c3:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f01002c9:	75 e9                	jne    f01002b4 <cons_putc+0x54>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002cb:	ba 78 03 00 00       	mov    $0x378,%edx
f01002d0:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f01002d4:	ee                   	out    %al,(%dx)
f01002d5:	b2 7a                	mov    $0x7a,%dl
f01002d7:	b8 0d 00 00 00       	mov    $0xd,%eax
f01002dc:	ee                   	out    %al,(%dx)
f01002dd:	b8 08 00 00 00       	mov    $0x8,%eax
f01002e2:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f01002e3:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f01002e9:	75 06                	jne    f01002f1 <cons_putc+0x91>
		c |= 0x0700;
f01002eb:	81 cf 00 07 00 00    	or     $0x700,%edi

	switch (c & 0xff) {
f01002f1:	89 f8                	mov    %edi,%eax
f01002f3:	25 ff 00 00 00       	and    $0xff,%eax
f01002f8:	83 f8 09             	cmp    $0x9,%eax
f01002fb:	0f 84 83 00 00 00    	je     f0100384 <cons_putc+0x124>
f0100301:	83 f8 09             	cmp    $0x9,%eax
f0100304:	7f 0c                	jg     f0100312 <cons_putc+0xb2>
f0100306:	83 f8 08             	cmp    $0x8,%eax
f0100309:	0f 85 a9 00 00 00    	jne    f01003b8 <cons_putc+0x158>
f010030f:	90                   	nop
f0100310:	eb 18                	jmp    f010032a <cons_putc+0xca>
f0100312:	83 f8 0a             	cmp    $0xa,%eax
f0100315:	8d 76 00             	lea    0x0(%esi),%esi
f0100318:	74 40                	je     f010035a <cons_putc+0xfa>
f010031a:	83 f8 0d             	cmp    $0xd,%eax
f010031d:	8d 76 00             	lea    0x0(%esi),%esi
f0100320:	0f 85 92 00 00 00    	jne    f01003b8 <cons_putc+0x158>
f0100326:	66 90                	xchg   %ax,%ax
f0100328:	eb 38                	jmp    f0100362 <cons_putc+0x102>
	case '\b':
		if (crt_pos > 0) {
f010032a:	0f b7 05 30 c4 19 f0 	movzwl 0xf019c430,%eax
f0100331:	66 85 c0             	test   %ax,%ax
f0100334:	0f 84 e8 00 00 00    	je     f0100422 <cons_putc+0x1c2>
			crt_pos--;
f010033a:	83 e8 01             	sub    $0x1,%eax
f010033d:	66 a3 30 c4 19 f0    	mov    %ax,0xf019c430
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100343:	0f b7 c0             	movzwl %ax,%eax
f0100346:	66 81 e7 00 ff       	and    $0xff00,%di
f010034b:	83 cf 20             	or     $0x20,%edi
f010034e:	8b 15 2c c4 19 f0    	mov    0xf019c42c,%edx
f0100354:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100358:	eb 7b                	jmp    f01003d5 <cons_putc+0x175>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f010035a:	66 83 05 30 c4 19 f0 	addw   $0x50,0xf019c430
f0100361:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100362:	0f b7 05 30 c4 19 f0 	movzwl 0xf019c430,%eax
f0100369:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f010036f:	c1 e8 10             	shr    $0x10,%eax
f0100372:	66 c1 e8 06          	shr    $0x6,%ax
f0100376:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100379:	c1 e0 04             	shl    $0x4,%eax
f010037c:	66 a3 30 c4 19 f0    	mov    %ax,0xf019c430
f0100382:	eb 51                	jmp    f01003d5 <cons_putc+0x175>
		break;
	case '\t':
		cons_putc(' ');
f0100384:	b8 20 00 00 00       	mov    $0x20,%eax
f0100389:	e8 d2 fe ff ff       	call   f0100260 <cons_putc>
		cons_putc(' ');
f010038e:	b8 20 00 00 00       	mov    $0x20,%eax
f0100393:	e8 c8 fe ff ff       	call   f0100260 <cons_putc>
		cons_putc(' ');
f0100398:	b8 20 00 00 00       	mov    $0x20,%eax
f010039d:	e8 be fe ff ff       	call   f0100260 <cons_putc>
		cons_putc(' ');
f01003a2:	b8 20 00 00 00       	mov    $0x20,%eax
f01003a7:	e8 b4 fe ff ff       	call   f0100260 <cons_putc>
		cons_putc(' ');
f01003ac:	b8 20 00 00 00       	mov    $0x20,%eax
f01003b1:	e8 aa fe ff ff       	call   f0100260 <cons_putc>
f01003b6:	eb 1d                	jmp    f01003d5 <cons_putc+0x175>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f01003b8:	0f b7 05 30 c4 19 f0 	movzwl 0xf019c430,%eax
f01003bf:	0f b7 c8             	movzwl %ax,%ecx
f01003c2:	8b 15 2c c4 19 f0    	mov    0xf019c42c,%edx
f01003c8:	66 89 3c 4a          	mov    %di,(%edx,%ecx,2)
f01003cc:	83 c0 01             	add    $0x1,%eax
f01003cf:	66 a3 30 c4 19 f0    	mov    %ax,0xf019c430
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f01003d5:	66 81 3d 30 c4 19 f0 	cmpw   $0x7cf,0xf019c430
f01003dc:	cf 07 
f01003de:	76 42                	jbe    f0100422 <cons_putc+0x1c2>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01003e0:	a1 2c c4 19 f0       	mov    0xf019c42c,%eax
f01003e5:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f01003ec:	00 
f01003ed:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01003f3:	89 54 24 04          	mov    %edx,0x4(%esp)
f01003f7:	89 04 24             	mov    %eax,(%esp)
f01003fa:	e8 b6 4a 00 00       	call   f0104eb5 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f01003ff:	8b 15 2c c4 19 f0    	mov    0xf019c42c,%edx
f0100405:	b8 80 07 00 00       	mov    $0x780,%eax
f010040a:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100410:	83 c0 01             	add    $0x1,%eax
f0100413:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f0100418:	75 f0                	jne    f010040a <cons_putc+0x1aa>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f010041a:	66 83 2d 30 c4 19 f0 	subw   $0x50,0xf019c430
f0100421:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100422:	8b 0d 28 c4 19 f0    	mov    0xf019c428,%ecx
f0100428:	89 cb                	mov    %ecx,%ebx
f010042a:	b8 0e 00 00 00       	mov    $0xe,%eax
f010042f:	89 ca                	mov    %ecx,%edx
f0100431:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100432:	0f b7 35 30 c4 19 f0 	movzwl 0xf019c430,%esi
f0100439:	83 c1 01             	add    $0x1,%ecx
f010043c:	89 f0                	mov    %esi,%eax
f010043e:	66 c1 e8 08          	shr    $0x8,%ax
f0100442:	89 ca                	mov    %ecx,%edx
f0100444:	ee                   	out    %al,(%dx)
f0100445:	b8 0f 00 00 00       	mov    $0xf,%eax
f010044a:	89 da                	mov    %ebx,%edx
f010044c:	ee                   	out    %al,(%dx)
f010044d:	89 f0                	mov    %esi,%eax
f010044f:	89 ca                	mov    %ecx,%edx
f0100451:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100452:	83 c4 2c             	add    $0x2c,%esp
f0100455:	5b                   	pop    %ebx
f0100456:	5e                   	pop    %esi
f0100457:	5f                   	pop    %edi
f0100458:	5d                   	pop    %ebp
f0100459:	c3                   	ret    

f010045a <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010045a:	55                   	push   %ebp
f010045b:	89 e5                	mov    %esp,%ebp
f010045d:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100460:	8b 45 08             	mov    0x8(%ebp),%eax
f0100463:	e8 f8 fd ff ff       	call   f0100260 <cons_putc>
}
f0100468:	c9                   	leave  
f0100469:	c3                   	ret    

f010046a <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010046a:	55                   	push   %ebp
f010046b:	89 e5                	mov    %esp,%ebp
f010046d:	57                   	push   %edi
f010046e:	56                   	push   %esi
f010046f:	53                   	push   %ebx
f0100470:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100473:	b8 00 80 0b f0       	mov    $0xf00b8000,%eax
f0100478:	0f b7 10             	movzwl (%eax),%edx
	*cp = (uint16_t) 0xA55A;
f010047b:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
	if (*cp != 0xA55A) {
f0100480:	0f b7 00             	movzwl (%eax),%eax
f0100483:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100487:	74 11                	je     f010049a <cons_init+0x30>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100489:	c7 05 28 c4 19 f0 b4 	movl   $0x3b4,0xf019c428
f0100490:	03 00 00 
f0100493:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100498:	eb 16                	jmp    f01004b0 <cons_init+0x46>
	} else {
		*cp = was;
f010049a:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01004a1:	c7 05 28 c4 19 f0 d4 	movl   $0x3d4,0xf019c428
f01004a8:	03 00 00 
f01004ab:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
	}
	
	/* Extract cursor location */
	outb(addr_6845, 14);
f01004b0:	8b 0d 28 c4 19 f0    	mov    0xf019c428,%ecx
f01004b6:	89 cb                	mov    %ecx,%ebx
f01004b8:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004bd:	89 ca                	mov    %ecx,%edx
f01004bf:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01004c0:	83 c1 01             	add    $0x1,%ecx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01004c3:	89 ca                	mov    %ecx,%edx
f01004c5:	ec                   	in     (%dx),%al
f01004c6:	0f b6 f8             	movzbl %al,%edi
f01004c9:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01004cc:	b8 0f 00 00 00       	mov    $0xf,%eax
f01004d1:	89 da                	mov    %ebx,%edx
f01004d3:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01004d4:	89 ca                	mov    %ecx,%edx
f01004d6:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01004d7:	89 35 2c c4 19 f0    	mov    %esi,0xf019c42c
	crt_pos = pos;
f01004dd:	0f b6 c8             	movzbl %al,%ecx
f01004e0:	09 cf                	or     %ecx,%edi
f01004e2:	66 89 3d 30 c4 19 f0 	mov    %di,0xf019c430
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01004e9:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f01004ee:	b8 00 00 00 00       	mov    $0x0,%eax
f01004f3:	89 da                	mov    %ebx,%edx
f01004f5:	ee                   	out    %al,(%dx)
f01004f6:	b2 fb                	mov    $0xfb,%dl
f01004f8:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01004fd:	ee                   	out    %al,(%dx)
f01004fe:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f0100503:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100508:	89 ca                	mov    %ecx,%edx
f010050a:	ee                   	out    %al,(%dx)
f010050b:	b2 f9                	mov    $0xf9,%dl
f010050d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100512:	ee                   	out    %al,(%dx)
f0100513:	b2 fb                	mov    $0xfb,%dl
f0100515:	b8 03 00 00 00       	mov    $0x3,%eax
f010051a:	ee                   	out    %al,(%dx)
f010051b:	b2 fc                	mov    $0xfc,%dl
f010051d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100522:	ee                   	out    %al,(%dx)
f0100523:	b2 f9                	mov    $0xf9,%dl
f0100525:	b8 01 00 00 00       	mov    $0x1,%eax
f010052a:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010052b:	b2 fd                	mov    $0xfd,%dl
f010052d:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010052e:	3c ff                	cmp    $0xff,%al
f0100530:	0f 95 c0             	setne  %al
f0100533:	0f b6 f0             	movzbl %al,%esi
f0100536:	89 35 24 c4 19 f0    	mov    %esi,0xf019c424
f010053c:	89 da                	mov    %ebx,%edx
f010053e:	ec                   	in     (%dx),%al
f010053f:	89 ca                	mov    %ecx,%edx
f0100541:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100542:	85 f6                	test   %esi,%esi
f0100544:	75 0c                	jne    f0100552 <cons_init+0xe8>
		cprintf("Serial port does not exist!\n");
f0100546:	c7 04 24 8d 53 10 f0 	movl   $0xf010538d,(%esp)
f010054d:	e8 c9 36 00 00       	call   f0103c1b <cprintf>
}
f0100552:	83 c4 1c             	add    $0x1c,%esp
f0100555:	5b                   	pop    %ebx
f0100556:	5e                   	pop    %esi
f0100557:	5f                   	pop    %edi
f0100558:	5d                   	pop    %ebp
f0100559:	c3                   	ret    

f010055a <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f010055a:	55                   	push   %ebp
f010055b:	89 e5                	mov    %esp,%ebp
f010055d:	53                   	push   %ebx
f010055e:	83 ec 14             	sub    $0x14,%esp
f0100561:	ba 64 00 00 00       	mov    $0x64,%edx
f0100566:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f0100567:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f010056c:	a8 01                	test   $0x1,%al
f010056e:	0f 84 d9 00 00 00    	je     f010064d <kbd_proc_data+0xf3>
f0100574:	b2 60                	mov    $0x60,%dl
f0100576:	ec                   	in     (%dx),%al
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f0100577:	3c e0                	cmp    $0xe0,%al
f0100579:	75 11                	jne    f010058c <kbd_proc_data+0x32>
		// E0 escape character
		shift |= E0ESC;
f010057b:	83 0d 20 c4 19 f0 40 	orl    $0x40,0xf019c420
f0100582:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
f0100587:	e9 c1 00 00 00       	jmp    f010064d <kbd_proc_data+0xf3>
	} else if (data & 0x80) {
f010058c:	84 c0                	test   %al,%al
f010058e:	79 32                	jns    f01005c2 <kbd_proc_data+0x68>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100590:	8b 15 20 c4 19 f0    	mov    0xf019c420,%edx
f0100596:	f6 c2 40             	test   $0x40,%dl
f0100599:	75 03                	jne    f010059e <kbd_proc_data+0x44>
f010059b:	83 e0 7f             	and    $0x7f,%eax
		shift &= ~(shiftcode[data] | E0ESC);
f010059e:	0f b6 c0             	movzbl %al,%eax
f01005a1:	0f b6 80 c0 53 10 f0 	movzbl -0xfefac40(%eax),%eax
f01005a8:	83 c8 40             	or     $0x40,%eax
f01005ab:	0f b6 c0             	movzbl %al,%eax
f01005ae:	f7 d0                	not    %eax
f01005b0:	21 c2                	and    %eax,%edx
f01005b2:	89 15 20 c4 19 f0    	mov    %edx,0xf019c420
f01005b8:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
f01005bd:	e9 8b 00 00 00       	jmp    f010064d <kbd_proc_data+0xf3>
	} else if (shift & E0ESC) {
f01005c2:	8b 15 20 c4 19 f0    	mov    0xf019c420,%edx
f01005c8:	f6 c2 40             	test   $0x40,%dl
f01005cb:	74 0c                	je     f01005d9 <kbd_proc_data+0x7f>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01005cd:	83 c8 80             	or     $0xffffff80,%eax
		shift &= ~E0ESC;
f01005d0:	83 e2 bf             	and    $0xffffffbf,%edx
f01005d3:	89 15 20 c4 19 f0    	mov    %edx,0xf019c420
	}

	shift |= shiftcode[data];
f01005d9:	0f b6 c0             	movzbl %al,%eax
	shift ^= togglecode[data];
f01005dc:	0f b6 90 c0 53 10 f0 	movzbl -0xfefac40(%eax),%edx
f01005e3:	0b 15 20 c4 19 f0    	or     0xf019c420,%edx
f01005e9:	0f b6 88 c0 54 10 f0 	movzbl -0xfefab40(%eax),%ecx
f01005f0:	31 ca                	xor    %ecx,%edx
f01005f2:	89 15 20 c4 19 f0    	mov    %edx,0xf019c420

	c = charcode[shift & (CTL | SHIFT)][data];
f01005f8:	89 d1                	mov    %edx,%ecx
f01005fa:	83 e1 03             	and    $0x3,%ecx
f01005fd:	8b 0c 8d c0 55 10 f0 	mov    -0xfefaa40(,%ecx,4),%ecx
f0100604:	0f b6 1c 01          	movzbl (%ecx,%eax,1),%ebx
	if (shift & CAPSLOCK) {
f0100608:	f6 c2 08             	test   $0x8,%dl
f010060b:	74 1a                	je     f0100627 <kbd_proc_data+0xcd>
		if ('a' <= c && c <= 'z')
f010060d:	89 d9                	mov    %ebx,%ecx
f010060f:	8d 43 9f             	lea    -0x61(%ebx),%eax
f0100612:	83 f8 19             	cmp    $0x19,%eax
f0100615:	77 05                	ja     f010061c <kbd_proc_data+0xc2>
			c += 'A' - 'a';
f0100617:	83 eb 20             	sub    $0x20,%ebx
f010061a:	eb 0b                	jmp    f0100627 <kbd_proc_data+0xcd>
		else if ('A' <= c && c <= 'Z')
f010061c:	83 e9 41             	sub    $0x41,%ecx
f010061f:	83 f9 19             	cmp    $0x19,%ecx
f0100622:	77 03                	ja     f0100627 <kbd_proc_data+0xcd>
			c += 'a' - 'A';
f0100624:	83 c3 20             	add    $0x20,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100627:	f7 d2                	not    %edx
f0100629:	f6 c2 06             	test   $0x6,%dl
f010062c:	75 1f                	jne    f010064d <kbd_proc_data+0xf3>
f010062e:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100634:	75 17                	jne    f010064d <kbd_proc_data+0xf3>
		cprintf("Rebooting!\n");
f0100636:	c7 04 24 aa 53 10 f0 	movl   $0xf01053aa,(%esp)
f010063d:	e8 d9 35 00 00       	call   f0103c1b <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100642:	ba 92 00 00 00       	mov    $0x92,%edx
f0100647:	b8 03 00 00 00       	mov    $0x3,%eax
f010064c:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f010064d:	89 d8                	mov    %ebx,%eax
f010064f:	83 c4 14             	add    $0x14,%esp
f0100652:	5b                   	pop    %ebx
f0100653:	5d                   	pop    %ebp
f0100654:	c3                   	ret    
	...

f0100660 <read_eip>:
// return EIP of caller.
// does not work if inlined.
// putting at the end of the file seems to prevent inlining.
unsigned
read_eip()
{
f0100660:	55                   	push   %ebp
f0100661:	89 e5                	mov    %esp,%ebp
	uint32_t callerpc;
	__asm __volatile("movl 4(%%ebp), %0" : "=r" (callerpc));
f0100663:	8b 45 04             	mov    0x4(%ebp),%eax
	return callerpc;
}
f0100666:	5d                   	pop    %ebp
f0100667:	c3                   	ret    

f0100668 <start_overflow>:
    cprintf("Overflow success\n");
}

void
start_overflow(void)
{
f0100668:	55                   	push   %ebp
f0100669:	89 e5                	mov    %esp,%ebp
f010066b:	57                   	push   %edi
f010066c:	56                   	push   %esi
f010066d:	53                   	push   %ebx
f010066e:	81 ec 3c 01 00 00    	sub    $0x13c,%esp
    int nstr = 0;
    char *pret_addr;

	// Your code here.
    	uint32_t funcaddr = (uint32_t)do_overflow;
	uint32_t jumpaddr = funcaddr + 3;
f0100674:	bb 99 07 10 f0       	mov    $0xf0100799,%ebx
// Lab1 only
// read the pointer to the retaddr on the stack
static uint32_t
read_pretaddr() {
    uint32_t pretaddr;
    __asm __volatile("leal 4(%%ebp), %0" : "=r" (pretaddr)); 
f0100679:	8d 45 04             	lea    0x4(%ebp),%eax
f010067c:	89 85 d4 fe ff ff    	mov    %eax,-0x12c(%ebp)
f0100682:	b8 00 00 00 00       	mov    $0x0,%eax
	uint32_t jumpaddr = funcaddr + 3;
	pret_addr = (char*) read_pretaddr();
	uint32_t i,j;
	uint32_t jpaddr[4];
	for(i=0;i<4;i++){
		jpaddr[i]=(jumpaddr>>(8*i)&0xff);
f0100687:	8d 95 d8 fe ff ff    	lea    -0x128(%ebp),%edx
f010068d:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
f0100694:	89 de                	mov    %ebx,%esi
f0100696:	d3 ee                	shr    %cl,%esi
f0100698:	89 f1                	mov    %esi,%ecx
f010069a:	81 e1 ff 00 00 00    	and    $0xff,%ecx
f01006a0:	89 0c 82             	mov    %ecx,(%edx,%eax,4)
    	uint32_t funcaddr = (uint32_t)do_overflow;
	uint32_t jumpaddr = funcaddr + 3;
	pret_addr = (char*) read_pretaddr();
	uint32_t i,j;
	uint32_t jpaddr[4];
	for(i=0;i<4;i++){
f01006a3:	83 c0 01             	add    $0x1,%eax
f01006a6:	83 f8 04             	cmp    $0x4,%eax
f01006a9:	75 e2                	jne    f010068d <start_overflow+0x25>
    // you augmented in the "Exercise 9" to do this job.

    // hint: You can use the read_pretaddr function to retrieve 
    //       the pointer to the function call return address;

    char str[256] = {};
f01006ab:	8d bd e8 fe ff ff    	lea    -0x118(%ebp),%edi
f01006b1:	b9 40 00 00 00       	mov    $0x40,%ecx
f01006b6:	b0 00                	mov    $0x0,%al
f01006b8:	f3 ab                	rep stos %eax,%es:(%edi)
f01006ba:	b0 01                	mov    $0x1,%al
		jpaddr[i]=(jumpaddr>>(8*i)&0xff);
	}
	for(i=0;i<256;i++){
		if(i==128)
			str[i]='\0';
		str[i]='6';
f01006bc:	8d 95 e8 fe ff ff    	lea    -0x118(%ebp),%edx
f01006c2:	eb 03                	jmp    f01006c7 <start_overflow+0x5f>
    // you augmented in the "Exercise 9" to do this job.

    // hint: You can use the read_pretaddr function to retrieve 
    //       the pointer to the function call return address;

    char str[256] = {};
f01006c4:	83 c0 01             	add    $0x1,%eax
	uint32_t jpaddr[4];
	for(i=0;i<4;i++){
		jpaddr[i]=(jumpaddr>>(8*i)&0xff);
	}
	for(i=0;i<256;i++){
		if(i==128)
f01006c7:	3d 81 00 00 00       	cmp    $0x81,%eax
f01006cc:	75 0e                	jne    f01006dc <start_overflow+0x74>
			str[i]='\0';
f01006ce:	c6 85 68 ff ff ff 00 	movb   $0x0,-0x98(%ebp)
		str[i]='6';
f01006d5:	c6 44 02 ff 36       	movb   $0x36,-0x1(%edx,%eax,1)
f01006da:	eb e8                	jmp    f01006c4 <start_overflow+0x5c>
f01006dc:	c6 44 02 ff 36       	movb   $0x36,-0x1(%edx,%eax,1)
	uint32_t i,j;
	uint32_t jpaddr[4];
	for(i=0;i<4;i++){
		jpaddr[i]=(jumpaddr>>(8*i)&0xff);
	}
	for(i=0;i<256;i++){
f01006e1:	3d ff 00 00 00       	cmp    $0xff,%eax
f01006e6:	76 dc                	jbe    f01006c4 <start_overflow+0x5c>
f01006e8:	bf 01 00 00 00       	mov    $0x1,%edi
f01006ed:	be 00 00 00 00       	mov    $0x0,%esi
			str[i]='\0';
		str[i]='6';
	}
	for(i=0;i<4;i++){
		for(j=0;j<i;j++){
			str[jpaddr[j]]='6';
f01006f2:	8d 9d d8 fe ff ff    	lea    -0x128(%ebp),%ebx
f01006f8:	eb 4f                	jmp    f0100749 <start_overflow+0xe1>
f01006fa:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f01006fd:	c6 84 15 e8 fe ff ff 	movb   $0x36,-0x118(%ebp,%edx,1)
f0100704:	36 
		if(i==128)
			str[i]='\0';
		str[i]='6';
	}
	for(i=0;i<4;i++){
		for(j=0;j<i;j++){
f0100705:	83 c0 01             	add    $0x1,%eax
f0100708:	39 f0                	cmp    %esi,%eax
f010070a:	75 ee                	jne    f01006fa <start_overflow+0x92>
			str[jpaddr[j]]='6';
		}
		str[jpaddr[i]]='\0';
f010070c:	8b 04 b3             	mov    (%ebx,%esi,4),%eax
f010070f:	c6 84 05 e8 fe ff ff 	movb   $0x0,-0x118(%ebp,%eax,1)
f0100716:	00 
		uint32_t* first,second;
		cprintf("%s%n",str,pret_addr+i);	//little endian
f0100717:	8b 85 d4 fe ff ff    	mov    -0x12c(%ebp),%eax
f010071d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100721:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
f0100727:	89 44 24 04          	mov    %eax,0x4(%esp)
f010072b:	c7 04 24 d0 55 10 f0 	movl   $0xf01055d0,(%esp)
f0100732:	e8 e4 34 00 00       	call   f0103c1b <cprintf>
	for(i=0;i<256;i++){
		if(i==128)
			str[i]='\0';
		str[i]='6';
	}
	for(i=0;i<4;i++){
f0100737:	83 ff 03             	cmp    $0x3,%edi
f010073a:	77 42                	ja     f010077e <start_overflow+0x116>
f010073c:	83 c6 01             	add    $0x1,%esi
f010073f:	83 c7 01             	add    $0x1,%edi
f0100742:	83 85 d4 fe ff ff 01 	addl   $0x1,-0x12c(%ebp)
	uint32_t i,j;
	uint32_t jpaddr[4];
	for(i=0;i<4;i++){
		jpaddr[i]=(jumpaddr>>(8*i)&0xff);
	}
	for(i=0;i<256;i++){
f0100749:	b8 00 00 00 00       	mov    $0x0,%eax
		if(i==128)
			str[i]='\0';
		str[i]='6';
	}
	for(i=0;i<4;i++){
		for(j=0;j<i;j++){
f010074e:	85 f6                	test   %esi,%esi
f0100750:	75 a8                	jne    f01006fa <start_overflow+0x92>
			str[jpaddr[j]]='6';
		}
		str[jpaddr[i]]='\0';
f0100752:	8b 03                	mov    (%ebx),%eax
f0100754:	c6 84 05 e8 fe ff ff 	movb   $0x0,-0x118(%ebp,%eax,1)
f010075b:	00 
		uint32_t* first,second;
		cprintf("%s%n",str,pret_addr+i);	//little endian
f010075c:	8b 85 d4 fe ff ff    	mov    -0x12c(%ebp),%eax
f0100762:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100766:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
f010076c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100770:	c7 04 24 d0 55 10 f0 	movl   $0xf01055d0,(%esp)
f0100777:	e8 9f 34 00 00       	call   f0103c1b <cprintf>
f010077c:	eb be                	jmp    f010073c <start_overflow+0xd4>
		//cprintf("%s%n",str,second);
		//*(pret_addr+i) = *first==127?*first+*second:*first;
	}
	//do_overflow();

}
f010077e:	81 c4 3c 01 00 00    	add    $0x13c,%esp
f0100784:	5b                   	pop    %ebx
f0100785:	5e                   	pop    %esi
f0100786:	5f                   	pop    %edi
f0100787:	5d                   	pop    %ebp
f0100788:	c3                   	ret    

f0100789 <overflow_me>:
 
void
overflow_me(void)
{
f0100789:	55                   	push   %ebp
f010078a:	89 e5                	mov    %esp,%ebp
f010078c:	83 ec 08             	sub    $0x8,%esp
        start_overflow();
f010078f:	e8 d4 fe ff ff       	call   f0100668 <start_overflow>
}
f0100794:	c9                   	leave  
f0100795:	c3                   	ret    

f0100796 <do_overflow>:
    return pretaddr;
}

void
do_overflow(void)
{
f0100796:	55                   	push   %ebp
f0100797:	89 e5                	mov    %esp,%ebp
f0100799:	83 ec 18             	sub    $0x18,%esp
    cprintf("Overflow success\n");
f010079c:	c7 04 24 d5 55 10 f0 	movl   $0xf01055d5,(%esp)
f01007a3:	e8 73 34 00 00       	call   f0103c1b <cprintf>
}
f01007a8:	c9                   	leave  
f01007a9:	c3                   	ret    

f01007aa <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007aa:	55                   	push   %ebp
f01007ab:	89 e5                	mov    %esp,%ebp
f01007ad:	83 ec 18             	sub    $0x18,%esp
	extern char entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007b0:	c7 04 24 e7 55 10 f0 	movl   $0xf01055e7,(%esp)
f01007b7:	e8 5f 34 00 00       	call   f0103c1b <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007bc:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f01007c3:	00 
f01007c4:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f01007cb:	f0 
f01007cc:	c7 04 24 e0 56 10 f0 	movl   $0xf01056e0,(%esp)
f01007d3:	e8 43 34 00 00       	call   f0103c1b <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01007d8:	c7 44 24 08 25 53 10 	movl   $0x105325,0x8(%esp)
f01007df:	00 
f01007e0:	c7 44 24 04 25 53 10 	movl   $0xf0105325,0x4(%esp)
f01007e7:	f0 
f01007e8:	c7 04 24 04 57 10 f0 	movl   $0xf0105704,(%esp)
f01007ef:	e8 27 34 00 00       	call   f0103c1b <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01007f4:	c7 44 24 08 13 c4 19 	movl   $0x19c413,0x8(%esp)
f01007fb:	00 
f01007fc:	c7 44 24 04 13 c4 19 	movl   $0xf019c413,0x4(%esp)
f0100803:	f0 
f0100804:	c7 04 24 28 57 10 f0 	movl   $0xf0105728,(%esp)
f010080b:	e8 0b 34 00 00       	call   f0103c1b <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100810:	c7 44 24 08 10 d3 19 	movl   $0x19d310,0x8(%esp)
f0100817:	00 
f0100818:	c7 44 24 04 10 d3 19 	movl   $0xf019d310,0x4(%esp)
f010081f:	f0 
f0100820:	c7 04 24 4c 57 10 f0 	movl   $0xf010574c,(%esp)
f0100827:	e8 ef 33 00 00       	call   f0103c1b <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f010082c:	b8 0f d7 19 f0       	mov    $0xf019d70f,%eax
f0100831:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f0100836:	89 c2                	mov    %eax,%edx
f0100838:	c1 fa 1f             	sar    $0x1f,%edx
f010083b:	c1 ea 16             	shr    $0x16,%edx
f010083e:	8d 04 02             	lea    (%edx,%eax,1),%eax
f0100841:	c1 f8 0a             	sar    $0xa,%eax
f0100844:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100848:	c7 04 24 70 57 10 f0 	movl   $0xf0105770,(%esp)
f010084f:	e8 c7 33 00 00       	call   f0103c1b <cprintf>
		(end-entry+1023)/1024);
	return 0;
}
f0100854:	b8 00 00 00 00       	mov    $0x0,%eax
f0100859:	c9                   	leave  
f010085a:	c3                   	ret    

f010085b <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f010085b:	55                   	push   %ebp
f010085c:	89 e5                	mov    %esp,%ebp
f010085e:	83 ec 18             	sub    $0x18,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100861:	a1 24 58 10 f0       	mov    0xf0105824,%eax
f0100866:	89 44 24 08          	mov    %eax,0x8(%esp)
f010086a:	a1 20 58 10 f0       	mov    0xf0105820,%eax
f010086f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100873:	c7 04 24 00 56 10 f0 	movl   $0xf0105600,(%esp)
f010087a:	e8 9c 33 00 00       	call   f0103c1b <cprintf>
f010087f:	a1 30 58 10 f0       	mov    0xf0105830,%eax
f0100884:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100888:	a1 2c 58 10 f0       	mov    0xf010582c,%eax
f010088d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100891:	c7 04 24 00 56 10 f0 	movl   $0xf0105600,(%esp)
f0100898:	e8 7e 33 00 00       	call   f0103c1b <cprintf>
f010089d:	a1 3c 58 10 f0       	mov    0xf010583c,%eax
f01008a2:	89 44 24 08          	mov    %eax,0x8(%esp)
f01008a6:	a1 38 58 10 f0       	mov    0xf0105838,%eax
f01008ab:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008af:	c7 04 24 00 56 10 f0 	movl   $0xf0105600,(%esp)
f01008b6:	e8 60 33 00 00       	call   f0103c1b <cprintf>
	return 0;
}
f01008bb:	b8 00 00 00 00       	mov    $0x0,%eax
f01008c0:	c9                   	leave  
f01008c1:	c3                   	ret    

f01008c2 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01008c2:	55                   	push   %ebp
f01008c3:	89 e5                	mov    %esp,%ebp
f01008c5:	57                   	push   %edi
f01008c6:	56                   	push   %esi
f01008c7:	53                   	push   %ebx
f01008c8:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01008cb:	c7 04 24 9c 57 10 f0 	movl   $0xf010579c,(%esp)
f01008d2:	e8 44 33 00 00       	call   f0103c1b <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01008d7:	c7 04 24 c0 57 10 f0 	movl   $0xf01057c0,(%esp)
f01008de:	e8 38 33 00 00       	call   f0103c1b <cprintf>

	if (tf != NULL)
f01008e3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f01008e7:	74 0b                	je     f01008f4 <monitor+0x32>
		print_trapframe(tf);
f01008e9:	8b 45 08             	mov    0x8(%ebp),%eax
f01008ec:	89 04 24             	mov    %eax,(%esp)
f01008ef:	e8 6e 34 00 00       	call   f0103d62 <print_trapframe>

	while (1) {
		buf = readline("K> ");
f01008f4:	c7 04 24 09 56 10 f0 	movl   $0xf0105609,(%esp)
f01008fb:	e8 a0 42 00 00       	call   f0104ba0 <readline>
f0100900:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100902:	85 c0                	test   %eax,%eax
f0100904:	74 ee                	je     f01008f4 <monitor+0x32>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100906:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
f010090d:	be 00 00 00 00       	mov    $0x0,%esi
f0100912:	eb 06                	jmp    f010091a <monitor+0x58>
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100914:	c6 03 00             	movb   $0x0,(%ebx)
f0100917:	83 c3 01             	add    $0x1,%ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f010091a:	0f b6 03             	movzbl (%ebx),%eax
f010091d:	84 c0                	test   %al,%al
f010091f:	74 6a                	je     f010098b <monitor+0xc9>
f0100921:	0f be c0             	movsbl %al,%eax
f0100924:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100928:	c7 04 24 0d 56 10 f0 	movl   $0xf010560d,(%esp)
f010092f:	e8 c7 44 00 00       	call   f0104dfb <strchr>
f0100934:	85 c0                	test   %eax,%eax
f0100936:	75 dc                	jne    f0100914 <monitor+0x52>
			*buf++ = 0;
		if (*buf == 0)
f0100938:	80 3b 00             	cmpb   $0x0,(%ebx)
f010093b:	74 4e                	je     f010098b <monitor+0xc9>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f010093d:	83 fe 0f             	cmp    $0xf,%esi
f0100940:	75 16                	jne    f0100958 <monitor+0x96>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100942:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100949:	00 
f010094a:	c7 04 24 12 56 10 f0 	movl   $0xf0105612,(%esp)
f0100951:	e8 c5 32 00 00       	call   f0103c1b <cprintf>
f0100956:	eb 9c                	jmp    f01008f4 <monitor+0x32>
			return 0;
		}
		argv[argc++] = buf;
f0100958:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f010095c:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f010095f:	0f b6 03             	movzbl (%ebx),%eax
f0100962:	84 c0                	test   %al,%al
f0100964:	75 0c                	jne    f0100972 <monitor+0xb0>
f0100966:	eb b2                	jmp    f010091a <monitor+0x58>
			buf++;
f0100968:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f010096b:	0f b6 03             	movzbl (%ebx),%eax
f010096e:	84 c0                	test   %al,%al
f0100970:	74 a8                	je     f010091a <monitor+0x58>
f0100972:	0f be c0             	movsbl %al,%eax
f0100975:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100979:	c7 04 24 0d 56 10 f0 	movl   $0xf010560d,(%esp)
f0100980:	e8 76 44 00 00       	call   f0104dfb <strchr>
f0100985:	85 c0                	test   %eax,%eax
f0100987:	74 df                	je     f0100968 <monitor+0xa6>
f0100989:	eb 8f                	jmp    f010091a <monitor+0x58>
			buf++;
	}
	argv[argc] = 0;
f010098b:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100992:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100993:	85 f6                	test   %esi,%esi
f0100995:	0f 84 59 ff ff ff    	je     f01008f4 <monitor+0x32>
f010099b:	bb 20 58 10 f0       	mov    $0xf0105820,%ebx
f01009a0:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01009a5:	8b 03                	mov    (%ebx),%eax
f01009a7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009ab:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01009ae:	89 04 24             	mov    %eax,(%esp)
f01009b1:	e8 cf 43 00 00       	call   f0104d85 <strcmp>
f01009b6:	85 c0                	test   %eax,%eax
f01009b8:	75 23                	jne    f01009dd <monitor+0x11b>
			return commands[i].func(argc, argv, tf);
f01009ba:	6b ff 0c             	imul   $0xc,%edi,%edi
f01009bd:	8b 45 08             	mov    0x8(%ebp),%eax
f01009c0:	89 44 24 08          	mov    %eax,0x8(%esp)
f01009c4:	8d 45 a8             	lea    -0x58(%ebp),%eax
f01009c7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009cb:	89 34 24             	mov    %esi,(%esp)
f01009ce:	ff 97 28 58 10 f0    	call   *-0xfefa7d8(%edi)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f01009d4:	85 c0                	test   %eax,%eax
f01009d6:	78 28                	js     f0100a00 <monitor+0x13e>
f01009d8:	e9 17 ff ff ff       	jmp    f01008f4 <monitor+0x32>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f01009dd:	83 c7 01             	add    $0x1,%edi
f01009e0:	83 c3 0c             	add    $0xc,%ebx
f01009e3:	83 ff 03             	cmp    $0x3,%edi
f01009e6:	75 bd                	jne    f01009a5 <monitor+0xe3>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f01009e8:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01009eb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009ef:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f01009f6:	e8 20 32 00 00       	call   f0103c1b <cprintf>
f01009fb:	e9 f4 fe ff ff       	jmp    f01008f4 <monitor+0x32>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100a00:	83 c4 5c             	add    $0x5c,%esp
f0100a03:	5b                   	pop    %ebx
f0100a04:	5e                   	pop    %esi
f0100a05:	5f                   	pop    %edi
f0100a06:	5d                   	pop    %ebp
f0100a07:	c3                   	ret    

f0100a08 <mon_backtrace>:
        start_overflow();
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100a08:	55                   	push   %ebp
f0100a09:	89 e5                	mov    %esp,%ebp
f0100a0b:	57                   	push   %edi
f0100a0c:	56                   	push   %esi
f0100a0d:	53                   	push   %ebx
f0100a0e:	83 ec 5c             	sub    $0x5c,%esp
	// Your code here.
	
	uint32_t eip_value=read_eip();
f0100a11:	e8 4a fc ff ff       	call   f0100660 <read_eip>
f0100a16:	89 c7                	mov    %eax,%edi

static __inline uint32_t
read_ebp(void)
{
        uint32_t ebp;
        __asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0100a18:	89 ee                	mov    %ebp,%esi
	uint32_t ebp_value=read_ebp();

	while(ebp_value){
f0100a1a:	85 f6                	test   %esi,%esi
f0100a1c:	0f 84 9e 00 00 00    	je     f0100ac0 <mon_backtrace+0xb8>
		cprintf("eip %x  ebp %x  args", eip_value, ebp_value);
f0100a22:	89 74 24 08          	mov    %esi,0x8(%esp)
f0100a26:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100a2a:	c7 04 24 45 56 10 f0 	movl   $0xf0105645,(%esp)
f0100a31:	e8 e5 31 00 00       	call   f0103c1b <cprintf>
		uint32_t  old_ebp = *(uint32_t *)ebp_value;
f0100a36:	8b 06                	mov    (%esi),%eax
f0100a38:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		eip_value = *((uint32_t *)ebp_value+1); 
f0100a3b:	8b 7e 04             	mov    0x4(%esi),%edi
		struct Eipdebuginfo debug_info;
		if(debuginfo_eip(eip_value,&debug_info)<0){
f0100a3e:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100a41:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a45:	89 3c 24             	mov    %edi,(%esp)
f0100a48:	e8 41 37 00 00       	call   f010418e <debuginfo_eip>
f0100a4d:	85 c0                	test   %eax,%eax
f0100a4f:	79 0c                	jns    f0100a5d <mon_backtrace+0x55>
			cprintf(" something wrong!--F\n");
f0100a51:	c7 04 24 5a 56 10 f0 	movl   $0xf010565a,(%esp)
f0100a58:	e8 be 31 00 00       	call   f0103c1b <cprintf>
f0100a5d:	bb 00 00 00 00       	mov    $0x0,%ebx
		}
		int i;
		for( i=0;i<5;i++){
			cprintf(" %08x",*((uint32_t *)ebp_value + 1*(i+2) ) );
f0100a62:	8b 44 9e 08          	mov    0x8(%esi,%ebx,4),%eax
f0100a66:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a6a:	c7 04 24 70 56 10 f0 	movl   $0xf0105670,(%esp)
f0100a71:	e8 a5 31 00 00       	call   f0103c1b <cprintf>
		struct Eipdebuginfo debug_info;
		if(debuginfo_eip(eip_value,&debug_info)<0){
			cprintf(" something wrong!--F\n");
		}
		int i;
		for( i=0;i<5;i++){
f0100a76:	83 c3 01             	add    $0x1,%ebx
f0100a79:	83 fb 05             	cmp    $0x5,%ebx
f0100a7c:	75 e4                	jne    f0100a62 <mon_backtrace+0x5a>
			cprintf(" %08x",*((uint32_t *)ebp_value + 1*(i+2) ) );
		}
		cprintf("\n");
f0100a7e:	c7 04 24 85 62 10 f0 	movl   $0xf0106285,(%esp)
f0100a85:	e8 91 31 00 00       	call   f0103c1b <cprintf>
		cprintf("\t%s:%d: %s+%x\n",debug_info.eip_file,
f0100a8a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100a8d:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100a91:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100a94:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100a98:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100a9b:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100a9f:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100aa2:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100aa6:	c7 04 24 76 56 10 f0 	movl   $0xf0105676,(%esp)
f0100aad:	e8 69 31 00 00       	call   f0103c1b <cprintf>
	// Your code here.
	
	uint32_t eip_value=read_eip();
	uint32_t ebp_value=read_ebp();

	while(ebp_value){
f0100ab2:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
f0100ab6:	74 08                	je     f0100ac0 <mon_backtrace+0xb8>
f0100ab8:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0100abb:	e9 62 ff ff ff       	jmp    f0100a22 <mon_backtrace+0x1a>
		cprintf("\n");
		cprintf("\t%s:%d: %s+%x\n",debug_info.eip_file,
			debug_info.eip_line,debug_info.eip_fn_name,debug_info.eip_fn_addr);
		ebp_value = old_ebp;
	}
    overflow_me();
f0100ac0:	e8 c4 fc ff ff       	call   f0100789 <overflow_me>
    cprintf("Backtrace success\n");
f0100ac5:	c7 04 24 85 56 10 f0 	movl   $0xf0105685,(%esp)
f0100acc:	e8 4a 31 00 00       	call   f0103c1b <cprintf>
	return 0;
}
f0100ad1:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ad6:	83 c4 5c             	add    $0x5c,%esp
f0100ad9:	5b                   	pop    %ebx
f0100ada:	5e                   	pop    %esi
f0100adb:	5f                   	pop    %edi
f0100adc:	5d                   	pop    %ebp
f0100add:	c3                   	ret    
	...

f0100ae0 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100ae0:	55                   	push   %ebp
f0100ae1:	89 e5                	mov    %esp,%ebp
f0100ae3:	89 c2                	mov    %eax,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100ae5:	83 3d 48 c6 19 f0 00 	cmpl   $0x0,0xf019c648
f0100aec:	75 0f                	jne    f0100afd <boot_alloc+0x1d>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100aee:	b8 0f e3 19 f0       	mov    $0xf019e30f,%eax
f0100af3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100af8:	a3 48 c6 19 f0       	mov    %eax,0xf019c648
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	result = nextfree;
f0100afd:	a1 48 c6 19 f0       	mov    0xf019c648,%eax
	nextfree = ROUNDUP(result + n, PGSIZE);
f0100b02:	8d 94 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%edx
f0100b09:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100b0f:	89 15 48 c6 19 f0    	mov    %edx,0xf019c648

	return result;
}
f0100b15:	5d                   	pop    %ebp
f0100b16:	c3                   	ret    

f0100b17 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100b17:	55                   	push   %ebp
f0100b18:	89 e5                	mov    %esp,%ebp
f0100b1a:	53                   	push   %ebx
f0100b1b:	b8 08 00 00 00       	mov    $0x8,%eax
f0100b20:	ba 00 00 00 00       	mov    $0x0,%edx
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	page_free_list=0;
	size_t i;
	for (i = 1; i < IOPHYSMEM/PGSIZE; i++) {
		pages[i].pp_ref = 0;
f0100b25:	8b 0d 0c d3 19 f0    	mov    0xf019d30c,%ecx
f0100b2b:	66 c7 44 01 04 00 00 	movw   $0x0,0x4(%ecx,%eax,1)
		pages[i].pp_link = page_free_list;
f0100b32:	8b 0d 0c d3 19 f0    	mov    0xf019d30c,%ecx
f0100b38:	89 14 01             	mov    %edx,(%ecx,%eax,1)
		page_free_list = &pages[i];
f0100b3b:	89 c2                	mov    %eax,%edx
f0100b3d:	03 15 0c d3 19 f0    	add    0xf019d30c,%edx
f0100b43:	83 c0 08             	add    $0x8,%eax
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	page_free_list=0;
	size_t i;
	for (i = 1; i < IOPHYSMEM/PGSIZE; i++) {
f0100b46:	3d 00 05 00 00       	cmp    $0x500,%eax
f0100b4b:	75 d8                	jne    f0100b25 <page_init+0xe>
f0100b4d:	89 15 50 c6 19 f0    	mov    %edx,0xf019c650
		page_free_list = &pages[i];
	}
	extern char end[];
	//cprintf("Frank test: %08lx - %08lx = %d ?\n",ROUNDUP((char*)end,PGSIZE),KERNBASE,(ROUNDUP((char*)end,PGSIZE)-KERNBASE));
	//first use EXTPHYSMEM/PGSIZE+PGSIZE+npages*sizeof(), it's wrong because it forgets the part from EXTPHYSMEM to end (refers to the memory of kernel itself)
	for(i=ROUNDUP((int)(ROUNDUP((char*)end,PGSIZE)-KERNBASE)+PGSIZE+npages*sizeof(struct Page),PGSIZE)/PGSIZE;i<npages;i++){
f0100b53:	a1 04 d3 19 f0       	mov    0xf019d304,%eax
f0100b58:	b9 0f e3 19 f0       	mov    $0xf019e30f,%ecx
f0100b5d:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0100b63:	8d 8c c1 ff 1f 00 10 	lea    0x10001fff(%ecx,%eax,8),%ecx
f0100b6a:	c1 e9 0c             	shr    $0xc,%ecx
f0100b6d:	39 c8                	cmp    %ecx,%eax
f0100b6f:	76 39                	jbe    f0100baa <page_init+0x93>
f0100b71:	8d 04 cd 00 00 00 00 	lea    0x0(,%ecx,8),%eax
		pages[i].pp_ref = 0;
f0100b78:	8b 1d 0c d3 19 f0    	mov    0xf019d30c,%ebx
f0100b7e:	66 c7 44 03 04 00 00 	movw   $0x0,0x4(%ebx,%eax,1)
		pages[i].pp_link = page_free_list;
f0100b85:	8b 1d 0c d3 19 f0    	mov    0xf019d30c,%ebx
f0100b8b:	89 14 03             	mov    %edx,(%ebx,%eax,1)
		page_free_list = &pages[i];
f0100b8e:	89 c2                	mov    %eax,%edx
f0100b90:	03 15 0c d3 19 f0    	add    0xf019d30c,%edx
		page_free_list = &pages[i];
	}
	extern char end[];
	//cprintf("Frank test: %08lx - %08lx = %d ?\n",ROUNDUP((char*)end,PGSIZE),KERNBASE,(ROUNDUP((char*)end,PGSIZE)-KERNBASE));
	//first use EXTPHYSMEM/PGSIZE+PGSIZE+npages*sizeof(), it's wrong because it forgets the part from EXTPHYSMEM to end (refers to the memory of kernel itself)
	for(i=ROUNDUP((int)(ROUNDUP((char*)end,PGSIZE)-KERNBASE)+PGSIZE+npages*sizeof(struct Page),PGSIZE)/PGSIZE;i<npages;i++){
f0100b96:	83 c1 01             	add    $0x1,%ecx
f0100b99:	83 c0 08             	add    $0x8,%eax
f0100b9c:	39 0d 04 d3 19 f0    	cmp    %ecx,0xf019d304
f0100ba2:	77 d4                	ja     f0100b78 <page_init+0x61>
f0100ba4:	89 15 50 c6 19 f0    	mov    %edx,0xf019c650
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
	chunk_list = NULL;//Frank what's that?
f0100baa:	c7 05 54 c6 19 f0 00 	movl   $0x0,0xf019c654
f0100bb1:	00 00 00 

}
f0100bb4:	5b                   	pop    %ebx
f0100bb5:	5d                   	pop    %ebp
f0100bb6:	c3                   	ret    

f0100bb7 <page_alloc_npages>:
// Try to reuse the pages cached in the chuck list
//
// Hint: use page2kva and memset
struct Page *
page_alloc_npages(int alloc_flags, int n)
{
f0100bb7:	55                   	push   %ebp
f0100bb8:	89 e5                	mov    %esp,%ebp
	// Fill this function
	return NULL;
}
f0100bba:	b8 00 00 00 00       	mov    $0x0,%eax
f0100bbf:	5d                   	pop    %ebp
f0100bc0:	c3                   	ret    

f0100bc1 <page_free_npages>:
//	2. Add the pages to the chunk list
//	
//	Return 0 if everything ok
int
page_free_npages(struct Page *pp, int n)
{
f0100bc1:	55                   	push   %ebp
f0100bc2:	89 e5                	mov    %esp,%ebp
	// Fill this function
	return -1;
}
f0100bc4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100bc9:	5d                   	pop    %ebp
f0100bca:	c3                   	ret    

f0100bcb <page_realloc_npages>:
// You can man realloc for better understanding.
// (Try to reuse the allocated pages as many as possible.)
//
struct Page *
page_realloc_npages(struct Page *pp, int old_n, int new_n)
{
f0100bcb:	55                   	push   %ebp
f0100bcc:	89 e5                	mov    %esp,%ebp
	// Fill this function
	return NULL;
}
f0100bce:	b8 00 00 00 00       	mov    $0x0,%eax
f0100bd3:	5d                   	pop    %ebp
f0100bd4:	c3                   	ret    

f0100bd5 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0100bd5:	55                   	push   %ebp
f0100bd6:	89 e5                	mov    %esp,%ebp
}

static __inline void 
invlpg(void *addr)
{ 
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0100bd8:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100bdb:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f0100bde:	5d                   	pop    %ebp
f0100bdf:	c3                   	ret    

f0100be0 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0100be0:	55                   	push   %ebp
f0100be1:	89 e5                	mov    %esp,%ebp
	// LAB 3: Your code here.

	return 0;
}
f0100be3:	b8 00 00 00 00       	mov    $0x0,%eax
f0100be8:	5d                   	pop    %ebp
f0100be9:	c3                   	ret    

f0100bea <check_va2pa_large>:
	return PTE_ADDR(p[PTX(va)]);
}

static physaddr_t
check_va2pa_large(pde_t *pgdir, uintptr_t va)
{
f0100bea:	55                   	push   %ebp
f0100beb:	89 e5                	mov    %esp,%ebp
	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P) | !(*pgdir & PTE_PS))
f0100bed:	c1 ea 16             	shr    $0x16,%edx
f0100bf0:	8b 04 90             	mov    (%eax,%edx,4),%eax
f0100bf3:	89 c2                	mov    %eax,%edx
f0100bf5:	81 e2 81 00 00 00    	and    $0x81,%edx
f0100bfb:	89 c1                	mov    %eax,%ecx
f0100bfd:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0100c03:	81 fa 81 00 00 00    	cmp    $0x81,%edx
f0100c09:	0f 94 c0             	sete   %al
f0100c0c:	0f b6 c0             	movzbl %al,%eax
f0100c0f:	83 e8 01             	sub    $0x1,%eax
f0100c12:	09 c8                	or     %ecx,%eax
		return ~0;
	return PTE_ADDR(*pgdir);
}
f0100c14:	5d                   	pop    %ebp
f0100c15:	c3                   	ret    

f0100c16 <check_continuous>:
	cprintf("check_page() succeeded!\n");
}

static int
check_continuous(struct Page *pp, int num_page)
{
f0100c16:	55                   	push   %ebp
f0100c17:	89 e5                	mov    %esp,%ebp
f0100c19:	57                   	push   %edi
f0100c1a:	56                   	push   %esi
f0100c1b:	53                   	push   %ebx
	struct Page *tmp; 
	int i;
	for( tmp = pp, i = 0; i < num_page - 1; tmp = tmp->pp_link, i++ )
f0100c1c:	8d 72 ff             	lea    -0x1(%edx),%esi
f0100c1f:	85 f6                	test   %esi,%esi
f0100c21:	7e 5f                	jle    f0100c82 <check_continuous+0x6c>
	{
		if(tmp == NULL) 
f0100c23:	85 c0                	test   %eax,%eax
f0100c25:	74 54                	je     f0100c7b <check_continuous+0x65>
		{
			return 0;
		}
		if( (page2pa(tmp->pp_link) - page2pa(tmp)) != PGSIZE )
f0100c27:	8b 08                	mov    (%eax),%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0100c29:	8b 1d 0c d3 19 f0    	mov    0xf019d30c,%ebx
f0100c2f:	89 ca                	mov    %ecx,%edx
f0100c31:	29 da                	sub    %ebx,%edx
f0100c33:	c1 fa 03             	sar    $0x3,%edx
f0100c36:	29 d8                	sub    %ebx,%eax
f0100c38:	c1 f8 03             	sar    $0x3,%eax
f0100c3b:	29 c2                	sub    %eax,%edx
f0100c3d:	c1 e2 0c             	shl    $0xc,%edx
f0100c40:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c45:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
f0100c4b:	74 25                	je     f0100c72 <check_continuous+0x5c>
f0100c4d:	eb 2c                	jmp    f0100c7b <check_continuous+0x65>
{
	struct Page *tmp; 
	int i;
	for( tmp = pp, i = 0; i < num_page - 1; tmp = tmp->pp_link, i++ )
	{
		if(tmp == NULL) 
f0100c4f:	85 c9                	test   %ecx,%ecx
f0100c51:	74 28                	je     f0100c7b <check_continuous+0x65>
		{
			return 0;
		}
		if( (page2pa(tmp->pp_link) - page2pa(tmp)) != PGSIZE )
f0100c53:	8b 11                	mov    (%ecx),%edx
f0100c55:	89 d7                	mov    %edx,%edi
f0100c57:	29 df                	sub    %ebx,%edi
f0100c59:	c1 ff 03             	sar    $0x3,%edi
f0100c5c:	29 d9                	sub    %ebx,%ecx
f0100c5e:	c1 f9 03             	sar    $0x3,%ecx
f0100c61:	29 cf                	sub    %ecx,%edi
f0100c63:	89 f9                	mov    %edi,%ecx
f0100c65:	c1 e1 0c             	shl    $0xc,%ecx
f0100c68:	81 f9 00 10 00 00    	cmp    $0x1000,%ecx
f0100c6e:	75 0b                	jne    f0100c7b <check_continuous+0x65>
f0100c70:	89 d1                	mov    %edx,%ecx
static int
check_continuous(struct Page *pp, int num_page)
{
	struct Page *tmp; 
	int i;
	for( tmp = pp, i = 0; i < num_page - 1; tmp = tmp->pp_link, i++ )
f0100c72:	83 c0 01             	add    $0x1,%eax
f0100c75:	39 f0                	cmp    %esi,%eax
f0100c77:	7c d6                	jl     f0100c4f <check_continuous+0x39>
f0100c79:	eb 07                	jmp    f0100c82 <check_continuous+0x6c>
f0100c7b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c80:	eb 05                	jmp    f0100c87 <check_continuous+0x71>
f0100c82:	b8 01 00 00 00       	mov    $0x1,%eax
		{
			return 0;
		}
	}
	return 1;
}
f0100c87:	5b                   	pop    %ebx
f0100c88:	5e                   	pop    %esi
f0100c89:	5f                   	pop    %edi
f0100c8a:	5d                   	pop    %ebp
f0100c8b:	c3                   	ret    

f0100c8c <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct Page *pp)
{
f0100c8c:	55                   	push   %ebp
f0100c8d:	89 e5                	mov    %esp,%ebp
f0100c8f:	53                   	push   %ebx
f0100c90:	83 ec 14             	sub    $0x14,%esp
f0100c93:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// Fill this function in
	if(pp->pp_ref!=0){
f0100c96:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0100c9b:	74 0c                	je     f0100ca9 <page_free+0x1d>
		cprintf("free a page with ref not equal to 0\n");
f0100c9d:	c7 04 24 44 58 10 f0 	movl   $0xf0105844,(%esp)
f0100ca4:	e8 72 2f 00 00       	call   f0103c1b <cprintf>
	}
	pp->pp_link=page_free_list;
f0100ca9:	a1 50 c6 19 f0       	mov    0xf019c650,%eax
f0100cae:	89 03                	mov    %eax,(%ebx)
	page_free_list=pp;
f0100cb0:	89 1d 50 c6 19 f0    	mov    %ebx,0xf019c650
	return;
}
f0100cb6:	83 c4 14             	add    $0x14,%esp
f0100cb9:	5b                   	pop    %ebx
f0100cba:	5d                   	pop    %ebp
f0100cbb:	c3                   	ret    

f0100cbc <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct Page* pp)
{
f0100cbc:	55                   	push   %ebp
f0100cbd:	89 e5                	mov    %esp,%ebp
f0100cbf:	83 ec 18             	sub    $0x18,%esp
f0100cc2:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0100cc5:	0f b7 50 04          	movzwl 0x4(%eax),%edx
f0100cc9:	83 ea 01             	sub    $0x1,%edx
f0100ccc:	66 89 50 04          	mov    %dx,0x4(%eax)
f0100cd0:	66 85 d2             	test   %dx,%dx
f0100cd3:	75 08                	jne    f0100cdd <page_decref+0x21>
		page_free(pp);
f0100cd5:	89 04 24             	mov    %eax,(%esp)
f0100cd8:	e8 af ff ff ff       	call   f0100c8c <page_free>
}
f0100cdd:	c9                   	leave  
f0100cde:	c3                   	ret    

f0100cdf <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0100cdf:	55                   	push   %ebp
f0100ce0:	89 e5                	mov    %esp,%ebp
f0100ce2:	53                   	push   %ebx
f0100ce3:	83 ec 14             	sub    $0x14,%esp
f0100ce6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0100ce9:	8b 45 14             	mov    0x14(%ebp),%eax
f0100cec:	83 c8 04             	or     $0x4,%eax
f0100cef:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100cf3:	8b 45 10             	mov    0x10(%ebp),%eax
f0100cf6:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100cfa:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100cfd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100d01:	89 1c 24             	mov    %ebx,(%esp)
f0100d04:	e8 d7 fe ff ff       	call   f0100be0 <user_mem_check>
f0100d09:	85 c0                	test   %eax,%eax
f0100d0b:	79 23                	jns    f0100d30 <user_mem_assert+0x51>
		cprintf("[%08x] user_mem_check assertion failure for "
f0100d0d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100d14:	00 
f0100d15:	8b 43 48             	mov    0x48(%ebx),%eax
f0100d18:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100d1c:	c7 04 24 6c 58 10 f0 	movl   $0xf010586c,(%esp)
f0100d23:	e8 f3 2e 00 00       	call   f0103c1b <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0100d28:	89 1c 24             	mov    %ebx,(%esp)
f0100d2b:	e8 36 2d 00 00       	call   f0103a66 <env_destroy>
	}
}
f0100d30:	83 c4 14             	add    $0x14,%esp
f0100d33:	5b                   	pop    %ebx
f0100d34:	5d                   	pop    %ebp
f0100d35:	c3                   	ret    

f0100d36 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100d36:	55                   	push   %ebp
f0100d37:	89 e5                	mov    %esp,%ebp
f0100d39:	83 ec 18             	sub    $0x18,%esp
f0100d3c:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0100d3f:	89 75 fc             	mov    %esi,-0x4(%ebp)
f0100d42:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100d44:	89 04 24             	mov    %eax,(%esp)
f0100d47:	e8 74 2e 00 00       	call   f0103bc0 <mc146818_read>
f0100d4c:	89 c6                	mov    %eax,%esi
f0100d4e:	83 c3 01             	add    $0x1,%ebx
f0100d51:	89 1c 24             	mov    %ebx,(%esp)
f0100d54:	e8 67 2e 00 00       	call   f0103bc0 <mc146818_read>
f0100d59:	c1 e0 08             	shl    $0x8,%eax
f0100d5c:	09 f0                	or     %esi,%eax
}
f0100d5e:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0100d61:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0100d64:	89 ec                	mov    %ebp,%esp
f0100d66:	5d                   	pop    %ebp
f0100d67:	c3                   	ret    

f0100d68 <boot_map_region_large>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region_large(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0100d68:	55                   	push   %ebp
f0100d69:	89 e5                	mov    %esp,%ebp
f0100d6b:	57                   	push   %edi
f0100d6c:	56                   	push   %esi
f0100d6d:	53                   	push   %ebx
f0100d6e:	83 ec 1c             	sub    $0x1c,%esp
	// Fill this function in
	assert(size%PTSIZE==0);
f0100d71:	f7 c1 ff ff 3f 00    	test   $0x3fffff,%ecx
f0100d77:	75 19                	jne    f0100d92 <boot_map_region_large+0x2a>
	size_t add_interval=0;
	for(;size;size-=PTSIZE,add_interval+=PTSIZE){
f0100d79:	85 c9                	test   %ecx,%ecx
f0100d7b:	0f 84 98 00 00 00    	je     f0100e19 <boot_map_region_large+0xb1>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100d81:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0100d87:	77 67                	ja     f0100df0 <boot_map_region_large+0x88>
f0100d89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0100d90:	eb 3e                	jmp    f0100dd0 <boot_map_region_large+0x68>
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region_large(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	assert(size%PTSIZE==0);
f0100d92:	c7 44 24 0c 9b 60 10 	movl   $0xf010609b,0xc(%esp)
f0100d99:	f0 
f0100d9a:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0100da1:	f0 
f0100da2:	c7 44 24 04 08 02 00 	movl   $0x208,0x4(%esp)
f0100da9:	00 
f0100daa:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0100db1:	e8 cf f2 ff ff       	call   f0100085 <_panic>
f0100db6:	89 da                	mov    %ebx,%edx
f0100db8:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0100dbe:	76 10                	jbe    f0100dd0 <boot_map_region_large+0x68>
	size_t add_interval=0;
	for(;size;size-=PTSIZE,add_interval+=PTSIZE){
		pde_t* pde_now=&pgdir[PDX((void*)(va+add_interval))];
f0100dc0:	c1 ea 16             	shr    $0x16,%edx
f0100dc3:	8d 34 90             	lea    (%eax,%edx,4),%esi
f0100dc6:	89 da                	mov    %ebx,%edx
f0100dc8:	8d 9b 00 00 40 00    	lea    0x400000(%ebx),%ebx
f0100dce:	eb 37                	jmp    f0100e07 <boot_map_region_large+0x9f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100dd0:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100dd4:	c7 44 24 08 a4 58 10 	movl   $0xf01058a4,0x8(%esp)
f0100ddb:	f0 
f0100ddc:	c7 44 24 04 0c 02 00 	movl   $0x20c,0x4(%esp)
f0100de3:	00 
f0100de4:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0100deb:	e8 95 f2 ff ff       	call   f0100085 <_panic>
f0100df0:	89 d3                	mov    %edx,%ebx
f0100df2:	c1 eb 16             	shr    $0x16,%ebx
f0100df5:	8d 34 98             	lea    (%eax,%ebx,4),%esi
f0100df8:	8d 9a 00 00 40 00    	lea    0x400000(%edx),%ebx
		*pde_now=PADDR(((void*)va+add_interval))|perm|PTE_P|PTE_PS;
f0100dfe:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0100e01:	81 cf 81 00 00 00    	or     $0x81,%edi
f0100e07:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0100e0d:	09 fa                	or     %edi,%edx
f0100e0f:	89 16                	mov    %edx,(%esi)
boot_map_region_large(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	assert(size%PTSIZE==0);
	size_t add_interval=0;
	for(;size;size-=PTSIZE,add_interval+=PTSIZE){
f0100e11:	81 e9 00 00 40 00    	sub    $0x400000,%ecx
f0100e17:	75 9d                	jne    f0100db6 <boot_map_region_large+0x4e>
		pde_t* pde_now=&pgdir[PDX((void*)(va+add_interval))];
		*pde_now=PADDR(((void*)va+add_interval))|perm|PTE_P|PTE_PS;
	}
}
f0100e19:	83 c4 1c             	add    $0x1c,%esp
f0100e1c:	5b                   	pop    %ebx
f0100e1d:	5e                   	pop    %esi
f0100e1e:	5f                   	pop    %edi
f0100e1f:	5d                   	pop    %ebp
f0100e20:	c3                   	ret    

f0100e21 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct Page *
page_alloc(int alloc_flags)
{
f0100e21:	55                   	push   %ebp
f0100e22:	89 e5                	mov    %esp,%ebp
f0100e24:	53                   	push   %ebx
f0100e25:	83 ec 14             	sub    $0x14,%esp
	// Fill this function in
	//Frank:out of free mem
	if(page_free_list==NULL){
f0100e28:	8b 1d 50 c6 19 f0    	mov    0xf019c650,%ebx
f0100e2e:	85 db                	test   %ebx,%ebx
f0100e30:	74 6b                	je     f0100e9d <page_alloc+0x7c>
		return NULL;
	}
	struct Page *alloc_page=page_free_list;
	page_free_list=alloc_page->pp_link;
f0100e32:	8b 03                	mov    (%ebx),%eax
f0100e34:	a3 50 c6 19 f0       	mov    %eax,0xf019c650
	alloc_page->pp_link=NULL;
f0100e39:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (alloc_flags & ALLOC_ZERO){
f0100e3f:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100e43:	74 58                	je     f0100e9d <page_alloc+0x7c>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0100e45:	89 d8                	mov    %ebx,%eax
f0100e47:	2b 05 0c d3 19 f0    	sub    0xf019d30c,%eax
f0100e4d:	c1 f8 03             	sar    $0x3,%eax
f0100e50:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e53:	89 c2                	mov    %eax,%edx
f0100e55:	c1 ea 0c             	shr    $0xc,%edx
f0100e58:	3b 15 04 d3 19 f0    	cmp    0xf019d304,%edx
f0100e5e:	72 20                	jb     f0100e80 <page_alloc+0x5f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e60:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100e64:	c7 44 24 08 c8 58 10 	movl   $0xf01058c8,0x8(%esp)
f0100e6b:	f0 
f0100e6c:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0100e73:	00 
f0100e74:	c7 04 24 cb 60 10 f0 	movl   $0xf01060cb,(%esp)
f0100e7b:	e8 05 f2 ff ff       	call   f0100085 <_panic>
		memset(page2kva(alloc_page),0,PGSIZE);
f0100e80:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0100e87:	00 
f0100e88:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100e8f:	00 
f0100e90:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100e95:	89 04 24             	mov    %eax,(%esp)
f0100e98:	e8 b9 3f 00 00       	call   f0104e56 <memset>
	}
	return alloc_page;
}
f0100e9d:	89 d8                	mov    %ebx,%eax
f0100e9f:	83 c4 14             	add    $0x14,%esp
f0100ea2:	5b                   	pop    %ebx
f0100ea3:	5d                   	pop    %ebp
f0100ea4:	c3                   	ret    

f0100ea5 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100ea5:	55                   	push   %ebp
f0100ea6:	89 e5                	mov    %esp,%ebp
f0100ea8:	83 ec 18             	sub    $0x18,%esp
f0100eab:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0100eae:	89 75 fc             	mov    %esi,-0x4(%ebp)
	// Fill this function in
	// if the page table the va refers to does not exist
	if( (void*)pgdir[PDX(va)] == NULL){
f0100eb1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100eb4:	89 de                	mov    %ebx,%esi
f0100eb6:	c1 ee 16             	shr    $0x16,%esi
f0100eb9:	c1 e6 02             	shl    $0x2,%esi
f0100ebc:	03 75 08             	add    0x8(%ebp),%esi
f0100ebf:	8b 06                	mov    (%esi),%eax
f0100ec1:	85 c0                	test   %eax,%eax
f0100ec3:	0f 85 83 00 00 00    	jne    f0100f4c <pgdir_walk+0xa7>
		//if the page table does not exist and don't want to create it
		if(!create){
f0100ec9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100ecd:	0f 84 bd 00 00 00    	je     f0100f90 <pgdir_walk+0xeb>
		}
		//if the page table does not exist but want to create it
		else{
			struct Page *newpage; 
			//allocation fails
			if((newpage = page_alloc(1)) == NULL) return NULL;
f0100ed3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0100eda:	e8 42 ff ff ff       	call   f0100e21 <page_alloc>
f0100edf:	85 c0                	test   %eax,%eax
f0100ee1:	0f 84 a9 00 00 00    	je     f0100f90 <pgdir_walk+0xeb>
			//allocation succeeds
			newpage->pp_ref ++;
f0100ee7:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
			pgdir[PDX(va)]=page2pa(newpage)|PTE_P|PTE_U|PTE_W;//Frank: how about the 0-11 bit (as the physical address of a page table only needs 20 bits to express)
f0100eec:	89 c2                	mov    %eax,%edx
f0100eee:	2b 15 0c d3 19 f0    	sub    0xf019d30c,%edx
f0100ef4:	c1 fa 03             	sar    $0x3,%edx
f0100ef7:	c1 e2 0c             	shl    $0xc,%edx
f0100efa:	83 ca 07             	or     $0x7,%edx
f0100efd:	89 16                	mov    %edx,(%esi)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0100eff:	2b 05 0c d3 19 f0    	sub    0xf019d30c,%eax
f0100f05:	c1 f8 03             	sar    $0x3,%eax
f0100f08:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f0b:	89 c2                	mov    %eax,%edx
f0100f0d:	c1 ea 0c             	shr    $0xc,%edx
f0100f10:	3b 15 04 d3 19 f0    	cmp    0xf019d304,%edx
f0100f16:	72 20                	jb     f0100f38 <pgdir_walk+0x93>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f18:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100f1c:	c7 44 24 08 c8 58 10 	movl   $0xf01058c8,0x8(%esp)
f0100f23:	f0 
f0100f24:	c7 44 24 04 d8 01 00 	movl   $0x1d8,0x4(%esp)
f0100f2b:	00 
f0100f2c:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0100f33:	e8 4d f1 ff ff       	call   f0100085 <_panic>
			return (pte_t*)KADDR(page2pa(newpage))+PTX(va); //Frank: return virtual address ?(or maybe physical?)
f0100f38:	89 da                	mov    %ebx,%edx
f0100f3a:	c1 ea 0a             	shr    $0xa,%edx
f0100f3d:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
f0100f43:	8d 84 10 00 00 00 f0 	lea    -0x10000000(%eax,%edx,1),%eax
f0100f4a:	eb 49                	jmp    f0100f95 <pgdir_walk+0xf0>
		}
	}
	else{
		uintptr_t ptaddr_phy = PTE_ADDR(pgdir[PDX(va)]); //pte_addr() clear the flag bit
f0100f4c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f51:	89 c2                	mov    %eax,%edx
f0100f53:	c1 ea 0c             	shr    $0xc,%edx
f0100f56:	3b 15 04 d3 19 f0    	cmp    0xf019d304,%edx
f0100f5c:	72 20                	jb     f0100f7e <pgdir_walk+0xd9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f5e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100f62:	c7 44 24 08 c8 58 10 	movl   $0xf01058c8,0x8(%esp)
f0100f69:	f0 
f0100f6a:	c7 44 24 04 dd 01 00 	movl   $0x1dd,0x4(%esp)
f0100f71:	00 
f0100f72:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0100f79:	e8 07 f1 ff ff       	call   f0100085 <_panic>
		return (pte_t*)KADDR(ptaddr_phy)+PTX(va);//KADDR return a void* so that +PTX(va) will not multiply it by 4, therefore we need to change void* into pte_t*
f0100f7e:	c1 eb 0a             	shr    $0xa,%ebx
f0100f81:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f0100f87:	8d 84 18 00 00 00 f0 	lea    -0x10000000(%eax,%ebx,1),%eax
f0100f8e:	eb 05                	jmp    f0100f95 <pgdir_walk+0xf0>
f0100f90:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	
}
f0100f95:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0100f98:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0100f9b:	89 ec                	mov    %ebp,%esp
f0100f9d:	5d                   	pop    %ebp
f0100f9e:	c3                   	ret    

f0100f9f <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct Page *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0100f9f:	55                   	push   %ebp
f0100fa0:	89 e5                	mov    %esp,%ebp
f0100fa2:	53                   	push   %ebx
f0100fa3:	83 ec 14             	sub    $0x14,%esp
f0100fa6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	pte_t *pte_now;
	//no page table mapped(of course no page mapped)
	if((pte_now=pgdir_walk(pgdir,va,0))==NULL){
f0100fa9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100fb0:	00 
f0100fb1:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100fb4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100fb8:	8b 45 08             	mov    0x8(%ebp),%eax
f0100fbb:	89 04 24             	mov    %eax,(%esp)
f0100fbe:	e8 e2 fe ff ff       	call   f0100ea5 <pgdir_walk>
f0100fc3:	85 c0                	test   %eax,%eax
f0100fc5:	74 41                	je     f0101008 <page_lookup+0x69>
		return NULL;
	}
	//no page mapped
	if(*pte_now==0){
f0100fc7:	83 38 00             	cmpl   $0x0,(%eax)
f0100fca:	74 3c                	je     f0101008 <page_lookup+0x69>
		return NULL;
	}
	if(pte_store!=0){
f0100fcc:	85 db                	test   %ebx,%ebx
f0100fce:	66 90                	xchg   %ax,%ax
f0100fd0:	74 02                	je     f0100fd4 <page_lookup+0x35>
		*pte_store = pte_now;
f0100fd2:	89 03                	mov    %eax,(%ebx)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100fd4:	8b 00                	mov    (%eax),%eax
f0100fd6:	c1 e8 0c             	shr    $0xc,%eax
f0100fd9:	3b 05 04 d3 19 f0    	cmp    0xf019d304,%eax
f0100fdf:	72 1c                	jb     f0100ffd <page_lookup+0x5e>
		panic("pa2page called with invalid pa");
f0100fe1:	c7 44 24 08 ec 58 10 	movl   $0xf01058ec,0x8(%esp)
f0100fe8:	f0 
f0100fe9:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f0100ff0:	00 
f0100ff1:	c7 04 24 cb 60 10 f0 	movl   $0xf01060cb,(%esp)
f0100ff8:	e8 88 f0 ff ff       	call   f0100085 <_panic>
	return &pages[PGNUM(pa)];
f0100ffd:	c1 e0 03             	shl    $0x3,%eax
f0101000:	03 05 0c d3 19 f0    	add    0xf019d30c,%eax
	}
	return pa2page(PTE_ADDR(*pte_now));
f0101006:	eb 05                	jmp    f010100d <page_lookup+0x6e>
f0101008:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010100d:	83 c4 14             	add    $0x14,%esp
f0101010:	5b                   	pop    %ebx
f0101011:	5d                   	pop    %ebp
f0101012:	c3                   	ret    

f0101013 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0101013:	55                   	push   %ebp
f0101014:	89 e5                	mov    %esp,%ebp
f0101016:	56                   	push   %esi
f0101017:	53                   	push   %ebx
f0101018:	83 ec 20             	sub    $0x20,%esp
f010101b:	8b 75 08             	mov    0x8(%ebp),%esi
f010101e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	if(pgdir_walk(pgdir,va,0)==NULL || (void*)*pgdir_walk(pgdir,va,0)==NULL){
f0101021:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101028:	00 
f0101029:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010102d:	89 34 24             	mov    %esi,(%esp)
f0101030:	e8 70 fe ff ff       	call   f0100ea5 <pgdir_walk>
f0101035:	85 c0                	test   %eax,%eax
f0101037:	74 50                	je     f0101089 <page_remove+0x76>
f0101039:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101040:	00 
f0101041:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101045:	89 34 24             	mov    %esi,(%esp)
f0101048:	e8 58 fe ff ff       	call   f0100ea5 <pgdir_walk>
f010104d:	83 38 00             	cmpl   $0x0,(%eax)
f0101050:	74 37                	je     f0101089 <page_remove+0x76>
		return;
	}
	pte_t *addr_phy = 0;
f0101052:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	struct Page *page_now = page_lookup(pgdir,va,&addr_phy);
f0101059:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010105c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101060:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101064:	89 34 24             	mov    %esi,(%esp)
f0101067:	e8 33 ff ff ff       	call   f0100f9f <page_lookup>
	page_decref(page_now);
f010106c:	89 04 24             	mov    %eax,(%esp)
f010106f:	e8 48 fc ff ff       	call   f0100cbc <page_decref>
	*addr_phy=0;
f0101074:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101077:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	tlb_invalidate(pgdir,va);
f010107d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101081:	89 34 24             	mov    %esi,(%esp)
f0101084:	e8 4c fb ff ff       	call   f0100bd5 <tlb_invalidate>
	return;
}
f0101089:	83 c4 20             	add    $0x20,%esp
f010108c:	5b                   	pop    %ebx
f010108d:	5e                   	pop    %esi
f010108e:	5d                   	pop    %ebp
f010108f:	c3                   	ret    

f0101090 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct Page *pp, void *va, int perm)
{
f0101090:	55                   	push   %ebp
f0101091:	89 e5                	mov    %esp,%ebp
f0101093:	83 ec 28             	sub    $0x28,%esp
f0101096:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0101099:	89 75 f8             	mov    %esi,-0x8(%ebp)
f010109c:	89 7d fc             	mov    %edi,-0x4(%ebp)
f010109f:	8b 75 0c             	mov    0xc(%ebp),%esi
f01010a2:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in
	pte_t *pte_now=pgdir_walk(pgdir,va,1);
f01010a5:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01010ac:	00 
f01010ad:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01010b1:	8b 45 08             	mov    0x8(%ebp),%eax
f01010b4:	89 04 24             	mov    %eax,(%esp)
f01010b7:	e8 e9 fd ff ff       	call   f0100ea5 <pgdir_walk>
f01010bc:	89 c3                	mov    %eax,%ebx
	if(!pte_now){
f01010be:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01010c3:	85 db                	test   %ebx,%ebx
f01010c5:	74 38                	je     f01010ff <page_insert+0x6f>
		return -E_NO_MEM;
	}
	pp->pp_ref++;//add ref first to deal with the corner-case
f01010c7:	66 83 46 04 01       	addw   $0x1,0x4(%esi)
	if(*pte_now){
f01010cc:	83 3b 00             	cmpl   $0x0,(%ebx)
f01010cf:	74 0f                	je     f01010e0 <page_insert+0x50>
		page_remove(pgdir,va);
f01010d1:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01010d5:	8b 45 08             	mov    0x8(%ebp),%eax
f01010d8:	89 04 24             	mov    %eax,(%esp)
f01010db:	e8 33 ff ff ff       	call   f0101013 <page_remove>
	}
	*pte_now=page2pa(pp)|perm|PTE_P;
f01010e0:	8b 55 14             	mov    0x14(%ebp),%edx
f01010e3:	83 ca 01             	or     $0x1,%edx
f01010e6:	2b 35 0c d3 19 f0    	sub    0xf019d30c,%esi
f01010ec:	c1 fe 03             	sar    $0x3,%esi
f01010ef:	89 f0                	mov    %esi,%eax
f01010f1:	c1 e0 0c             	shl    $0xc,%eax
f01010f4:	89 d6                	mov    %edx,%esi
f01010f6:	09 c6                	or     %eax,%esi
f01010f8:	89 33                	mov    %esi,(%ebx)
f01010fa:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
f01010ff:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0101102:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0101105:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0101108:	89 ec                	mov    %ebp,%esp
f010110a:	5d                   	pop    %ebp
f010110b:	c3                   	ret    

f010110c <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f010110c:	55                   	push   %ebp
f010110d:	89 e5                	mov    %esp,%ebp
f010110f:	83 ec 18             	sub    $0x18,%esp
	pte_t *p;
	//cprintf("\n Frank test: va=%08x\n",va );
	pgdir = &pgdir[PDX(va)];
	//cprintf("\n Frank test: pgdir=%08x\n",*pgdir );
	if (!(*pgdir & PTE_P))
f0101112:	89 d1                	mov    %edx,%ecx
f0101114:	c1 e9 16             	shr    $0x16,%ecx
f0101117:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f010111a:	a8 01                	test   $0x1,%al
f010111c:	74 4d                	je     f010116b <check_va2pa+0x5f>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f010111e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101123:	89 c1                	mov    %eax,%ecx
f0101125:	c1 e9 0c             	shr    $0xc,%ecx
f0101128:	3b 0d 04 d3 19 f0    	cmp    0xf019d304,%ecx
f010112e:	72 20                	jb     f0101150 <check_va2pa+0x44>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101130:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101134:	c7 44 24 08 c8 58 10 	movl   $0xf01058c8,0x8(%esp)
f010113b:	f0 
f010113c:	c7 44 24 04 89 03 00 	movl   $0x389,0x4(%esp)
f0101143:	00 
f0101144:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f010114b:	e8 35 ef ff ff       	call   f0100085 <_panic>
	//cprintf("\n Frank test: p=%08x\n",p[PTX(va)] );
	if (!(p[PTX(va)] & PTE_P))
f0101150:	c1 ea 0c             	shr    $0xc,%edx
f0101153:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0101159:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0101160:	a8 01                	test   $0x1,%al
f0101162:	74 07                	je     f010116b <check_va2pa+0x5f>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0101164:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101169:	eb 05                	jmp    f0101170 <check_va2pa+0x64>
f010116b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0101170:	c9                   	leave  
f0101171:	c3                   	ret    

f0101172 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0101172:	55                   	push   %ebp
f0101173:	89 e5                	mov    %esp,%ebp
f0101175:	57                   	push   %edi
f0101176:	56                   	push   %esi
f0101177:	53                   	push   %ebx
f0101178:	83 ec 4c             	sub    $0x4c,%esp
	struct Page *pp;
	int pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f010117b:	83 f8 01             	cmp    $0x1,%eax
f010117e:	19 f6                	sbb    %esi,%esi
f0101180:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f0101186:	83 c6 01             	add    $0x1,%esi
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0101189:	8b 1d 50 c6 19 f0    	mov    0xf019c650,%ebx
f010118f:	85 db                	test   %ebx,%ebx
f0101191:	75 1c                	jne    f01011af <check_page_free_list+0x3d>
		panic("'page_free_list' is a null pointer!");
f0101193:	c7 44 24 08 0c 59 10 	movl   $0xf010590c,0x8(%esp)
f010119a:	f0 
f010119b:	c7 44 24 04 be 02 00 	movl   $0x2be,0x4(%esp)
f01011a2:	00 
f01011a3:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f01011aa:	e8 d6 ee ff ff       	call   f0100085 <_panic>
	if (only_low_memory) {
f01011af:	85 c0                	test   %eax,%eax
f01011b1:	74 52                	je     f0101205 <check_page_free_list+0x93>
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct Page *pp1, *pp2;
		struct Page **tp[2] = { &pp1, &pp2 };
f01011b3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01011b6:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01011b9:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01011bc:	89 45 dc             	mov    %eax,-0x24(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f01011bf:	8b 0d 0c d3 19 f0    	mov    0xf019d30c,%ecx
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f01011c5:	89 d8                	mov    %ebx,%eax
f01011c7:	29 c8                	sub    %ecx,%eax
f01011c9:	c1 e0 09             	shl    $0x9,%eax
f01011cc:	c1 e8 16             	shr    $0x16,%eax
f01011cf:	39 f0                	cmp    %esi,%eax
f01011d1:	0f 93 c0             	setae  %al
f01011d4:	0f b6 c0             	movzbl %al,%eax
			*tp[pagetype] = pp;
f01011d7:	8b 54 85 d8          	mov    -0x28(%ebp,%eax,4),%edx
f01011db:	89 1a                	mov    %ebx,(%edx)
			tp[pagetype] = &pp->pp_link;
f01011dd:	89 5c 85 d8          	mov    %ebx,-0x28(%ebp,%eax,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct Page *pp1, *pp2;
		struct Page **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f01011e1:	8b 1b                	mov    (%ebx),%ebx
f01011e3:	85 db                	test   %ebx,%ebx
f01011e5:	75 de                	jne    f01011c5 <check_page_free_list+0x53>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f01011e7:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01011ea:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f01011f0:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01011f3:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01011f6:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f01011f8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01011fb:	89 1d 50 c6 19 f0    	mov    %ebx,0xf019c650
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link){
f0101201:	85 db                	test   %ebx,%ebx
f0101203:	74 67                	je     f010126c <check_page_free_list+0xfa>
f0101205:	89 d8                	mov    %ebx,%eax
f0101207:	2b 05 0c d3 19 f0    	sub    0xf019d30c,%eax
f010120d:	c1 f8 03             	sar    $0x3,%eax
f0101210:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0101213:	89 c2                	mov    %eax,%edx
f0101215:	c1 ea 16             	shr    $0x16,%edx
f0101218:	39 f2                	cmp    %esi,%edx
f010121a:	73 4a                	jae    f0101266 <check_page_free_list+0xf4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010121c:	89 c2                	mov    %eax,%edx
f010121e:	c1 ea 0c             	shr    $0xc,%edx
f0101221:	3b 15 04 d3 19 f0    	cmp    0xf019d304,%edx
f0101227:	72 20                	jb     f0101249 <check_page_free_list+0xd7>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101229:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010122d:	c7 44 24 08 c8 58 10 	movl   $0xf01058c8,0x8(%esp)
f0101234:	f0 
f0101235:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f010123c:	00 
f010123d:	c7 04 24 cb 60 10 f0 	movl   $0xf01060cb,(%esp)
f0101244:	e8 3c ee ff ff       	call   f0100085 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0101249:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0101250:	00 
f0101251:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0101258:	00 
f0101259:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010125e:	89 04 24             	mov    %eax,(%esp)
f0101261:	e8 f0 3b 00 00       	call   f0104e56 <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link){
f0101266:	8b 1b                	mov    (%ebx),%ebx
f0101268:	85 db                	test   %ebx,%ebx
f010126a:	75 99                	jne    f0101205 <check_page_free_list+0x93>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);
	}
	first_free_page = (char *) boot_alloc(0);
f010126c:	b8 00 00 00 00       	mov    $0x0,%eax
f0101271:	e8 6a f8 ff ff       	call   f0100ae0 <boot_alloc>
f0101276:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101279:	a1 50 c6 19 f0       	mov    0xf019c650,%eax
f010127e:	85 c0                	test   %eax,%eax
f0101280:	0f 84 0c 02 00 00    	je     f0101492 <check_page_free_list+0x320>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0101286:	8b 0d 0c d3 19 f0    	mov    0xf019d30c,%ecx
f010128c:	39 c8                	cmp    %ecx,%eax
f010128e:	72 52                	jb     f01012e2 <check_page_free_list+0x170>
		assert(pp < pages + npages);
f0101290:	8b 15 04 d3 19 f0    	mov    0xf019d304,%edx
f0101296:	89 55 cc             	mov    %edx,-0x34(%ebp)
f0101299:	8d 3c d1             	lea    (%ecx,%edx,8),%edi
f010129c:	39 f8                	cmp    %edi,%eax
f010129e:	73 6a                	jae    f010130a <check_page_free_list+0x198>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f01012a0:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f01012a3:	89 c2                	mov    %eax,%edx
f01012a5:	29 ca                	sub    %ecx,%edx
f01012a7:	f6 c2 07             	test   $0x7,%dl
f01012aa:	0f 85 88 00 00 00    	jne    f0101338 <check_page_free_list+0x1c6>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f01012b0:	c1 fa 03             	sar    $0x3,%edx
f01012b3:	c1 e2 0c             	shl    $0xc,%edx

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f01012b6:	85 d2                	test   %edx,%edx
f01012b8:	0f 84 a8 00 00 00    	je     f0101366 <check_page_free_list+0x1f4>
		assert(page2pa(pp) != IOPHYSMEM);
f01012be:	81 fa 00 00 0a 00    	cmp    $0xa0000,%edx
f01012c4:	0f 84 c8 00 00 00    	je     f0101392 <check_page_free_list+0x220>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f01012ca:	81 fa 00 f0 0f 00    	cmp    $0xff000,%edx
f01012d0:	0f 85 0c 01 00 00    	jne    f01013e2 <check_page_free_list+0x270>
f01012d6:	66 90                	xchg   %ax,%ax
f01012d8:	e9 e1 00 00 00       	jmp    f01013be <check_page_free_list+0x24c>
			memset(page2kva(pp), 0x97, 128);
	}
	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f01012dd:	3b 45 c4             	cmp    -0x3c(%ebp),%eax
f01012e0:	73 24                	jae    f0101306 <check_page_free_list+0x194>
f01012e2:	c7 44 24 0c d9 60 10 	movl   $0xf01060d9,0xc(%esp)
f01012e9:	f0 
f01012ea:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f01012f1:	f0 
f01012f2:	c7 44 24 04 d7 02 00 	movl   $0x2d7,0x4(%esp)
f01012f9:	00 
f01012fa:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0101301:	e8 7f ed ff ff       	call   f0100085 <_panic>
		assert(pp < pages + npages);
f0101306:	39 f8                	cmp    %edi,%eax
f0101308:	72 24                	jb     f010132e <check_page_free_list+0x1bc>
f010130a:	c7 44 24 0c e5 60 10 	movl   $0xf01060e5,0xc(%esp)
f0101311:	f0 
f0101312:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0101319:	f0 
f010131a:	c7 44 24 04 d8 02 00 	movl   $0x2d8,0x4(%esp)
f0101321:	00 
f0101322:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0101329:	e8 57 ed ff ff       	call   f0100085 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f010132e:	89 c2                	mov    %eax,%edx
f0101330:	2b 55 d4             	sub    -0x2c(%ebp),%edx
f0101333:	f6 c2 07             	test   $0x7,%dl
f0101336:	74 24                	je     f010135c <check_page_free_list+0x1ea>
f0101338:	c7 44 24 0c 30 59 10 	movl   $0xf0105930,0xc(%esp)
f010133f:	f0 
f0101340:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0101347:	f0 
f0101348:	c7 44 24 04 d9 02 00 	movl   $0x2d9,0x4(%esp)
f010134f:	00 
f0101350:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0101357:	e8 29 ed ff ff       	call   f0100085 <_panic>
f010135c:	c1 fa 03             	sar    $0x3,%edx
f010135f:	c1 e2 0c             	shl    $0xc,%edx

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0101362:	85 d2                	test   %edx,%edx
f0101364:	75 24                	jne    f010138a <check_page_free_list+0x218>
f0101366:	c7 44 24 0c f9 60 10 	movl   $0xf01060f9,0xc(%esp)
f010136d:	f0 
f010136e:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0101375:	f0 
f0101376:	c7 44 24 04 dc 02 00 	movl   $0x2dc,0x4(%esp)
f010137d:	00 
f010137e:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0101385:	e8 fb ec ff ff       	call   f0100085 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f010138a:	81 fa 00 00 0a 00    	cmp    $0xa0000,%edx
f0101390:	75 24                	jne    f01013b6 <check_page_free_list+0x244>
f0101392:	c7 44 24 0c 0a 61 10 	movl   $0xf010610a,0xc(%esp)
f0101399:	f0 
f010139a:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f01013a1:	f0 
f01013a2:	c7 44 24 04 dd 02 00 	movl   $0x2dd,0x4(%esp)
f01013a9:	00 
f01013aa:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f01013b1:	e8 cf ec ff ff       	call   f0100085 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f01013b6:	81 fa 00 f0 0f 00    	cmp    $0xff000,%edx
f01013bc:	75 31                	jne    f01013ef <check_page_free_list+0x27d>
f01013be:	c7 44 24 0c 64 59 10 	movl   $0xf0105964,0xc(%esp)
f01013c5:	f0 
f01013c6:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f01013cd:	f0 
f01013ce:	c7 44 24 04 de 02 00 	movl   $0x2de,0x4(%esp)
f01013d5:	00 
f01013d6:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f01013dd:	e8 a3 ec ff ff       	call   f0100085 <_panic>
f01013e2:	bb 00 00 00 00       	mov    $0x0,%ebx
f01013e7:	be 00 00 00 00       	mov    $0x0,%esi
f01013ec:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
		assert(page2pa(pp) != EXTPHYSMEM);
f01013ef:	81 fa 00 00 10 00    	cmp    $0x100000,%edx
f01013f5:	75 24                	jne    f010141b <check_page_free_list+0x2a9>
f01013f7:	c7 44 24 0c 23 61 10 	movl   $0xf0106123,0xc(%esp)
f01013fe:	f0 
f01013ff:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0101406:	f0 
f0101407:	c7 44 24 04 df 02 00 	movl   $0x2df,0x4(%esp)
f010140e:	00 
f010140f:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0101416:	e8 6a ec ff ff       	call   f0100085 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f010141b:	81 fa ff ff 0f 00    	cmp    $0xfffff,%edx
f0101421:	76 59                	jbe    f010147c <check_page_free_list+0x30a>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101423:	89 d1                	mov    %edx,%ecx
f0101425:	c1 e9 0c             	shr    $0xc,%ecx
f0101428:	39 4d cc             	cmp    %ecx,-0x34(%ebp)
f010142b:	77 20                	ja     f010144d <check_page_free_list+0x2db>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010142d:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101431:	c7 44 24 08 c8 58 10 	movl   $0xf01058c8,0x8(%esp)
f0101438:	f0 
f0101439:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0101440:	00 
f0101441:	c7 04 24 cb 60 10 f0 	movl   $0xf01060cb,(%esp)
f0101448:	e8 38 ec ff ff       	call   f0100085 <_panic>
f010144d:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0101453:	39 55 c8             	cmp    %edx,-0x38(%ebp)
f0101456:	76 29                	jbe    f0101481 <check_page_free_list+0x30f>
f0101458:	c7 44 24 0c 88 59 10 	movl   $0xf0105988,0xc(%esp)
f010145f:	f0 
f0101460:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0101467:	f0 
f0101468:	c7 44 24 04 e0 02 00 	movl   $0x2e0,0x4(%esp)
f010146f:	00 
f0101470:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0101477:	e8 09 ec ff ff       	call   f0100085 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f010147c:	83 c6 01             	add    $0x1,%esi
f010147f:	eb 03                	jmp    f0101484 <check_page_free_list+0x312>
		else
			++nfree_extmem;
f0101481:	83 c3 01             	add    $0x1,%ebx
	for (pp = page_free_list; pp; pp = pp->pp_link){
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);
	}
	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101484:	8b 00                	mov    (%eax),%eax
f0101486:	85 c0                	test   %eax,%eax
f0101488:	0f 85 4f fe ff ff    	jne    f01012dd <check_page_free_list+0x16b>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f010148e:	85 f6                	test   %esi,%esi
f0101490:	7f 24                	jg     f01014b6 <check_page_free_list+0x344>
f0101492:	c7 44 24 0c 3d 61 10 	movl   $0xf010613d,0xc(%esp)
f0101499:	f0 
f010149a:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f01014a1:	f0 
f01014a2:	c7 44 24 04 e8 02 00 	movl   $0x2e8,0x4(%esp)
f01014a9:	00 
f01014aa:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f01014b1:	e8 cf eb ff ff       	call   f0100085 <_panic>
	assert(nfree_extmem > 0);
f01014b6:	85 db                	test   %ebx,%ebx
f01014b8:	7f 24                	jg     f01014de <check_page_free_list+0x36c>
f01014ba:	c7 44 24 0c 4f 61 10 	movl   $0xf010614f,0xc(%esp)
f01014c1:	f0 
f01014c2:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f01014c9:	f0 
f01014ca:	c7 44 24 04 e9 02 00 	movl   $0x2e9,0x4(%esp)
f01014d1:	00 
f01014d2:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f01014d9:	e8 a7 eb ff ff       	call   f0100085 <_panic>
}
f01014de:	83 c4 4c             	add    $0x4c,%esp
f01014e1:	5b                   	pop    %ebx
f01014e2:	5e                   	pop    %esi
f01014e3:	5f                   	pop    %edi
f01014e4:	5d                   	pop    %ebp
f01014e5:	c3                   	ret    

f01014e6 <check_page>:


// check page_insert, page_remove, &c
static void
check_page(void)
{
f01014e6:	55                   	push   %ebp
f01014e7:	89 e5                	mov    %esp,%ebp
f01014e9:	57                   	push   %edi
f01014ea:	56                   	push   %esi
f01014eb:	53                   	push   %ebx
f01014ec:	83 ec 3c             	sub    $0x3c,%esp
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01014ef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01014f6:	e8 26 f9 ff ff       	call   f0100e21 <page_alloc>
f01014fb:	89 c6                	mov    %eax,%esi
f01014fd:	85 c0                	test   %eax,%eax
f01014ff:	75 24                	jne    f0101525 <check_page+0x3f>
f0101501:	c7 44 24 0c 60 61 10 	movl   $0xf0106160,0xc(%esp)
f0101508:	f0 
f0101509:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0101510:	f0 
f0101511:	c7 44 24 04 a7 03 00 	movl   $0x3a7,0x4(%esp)
f0101518:	00 
f0101519:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0101520:	e8 60 eb ff ff       	call   f0100085 <_panic>
	assert((pp1 = page_alloc(0)));
f0101525:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010152c:	e8 f0 f8 ff ff       	call   f0100e21 <page_alloc>
f0101531:	89 c7                	mov    %eax,%edi
f0101533:	85 c0                	test   %eax,%eax
f0101535:	75 24                	jne    f010155b <check_page+0x75>
f0101537:	c7 44 24 0c 76 61 10 	movl   $0xf0106176,0xc(%esp)
f010153e:	f0 
f010153f:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0101546:	f0 
f0101547:	c7 44 24 04 a8 03 00 	movl   $0x3a8,0x4(%esp)
f010154e:	00 
f010154f:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0101556:	e8 2a eb ff ff       	call   f0100085 <_panic>
	assert((pp2 = page_alloc(0)));
f010155b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101562:	e8 ba f8 ff ff       	call   f0100e21 <page_alloc>
f0101567:	89 c3                	mov    %eax,%ebx
f0101569:	85 c0                	test   %eax,%eax
f010156b:	75 24                	jne    f0101591 <check_page+0xab>
f010156d:	c7 44 24 0c 8c 61 10 	movl   $0xf010618c,0xc(%esp)
f0101574:	f0 
f0101575:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f010157c:	f0 
f010157d:	c7 44 24 04 a9 03 00 	movl   $0x3a9,0x4(%esp)
f0101584:	00 
f0101585:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f010158c:	e8 f4 ea ff ff       	call   f0100085 <_panic>
	//cprintf("\n Frank check_page() start!!\n\n\n");
	//cprintf("\n Frank test: pp0=%08x,pp1=%08x,pp2=%08x\n",pp0,pp1,pp2);
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101591:	39 fe                	cmp    %edi,%esi
f0101593:	75 24                	jne    f01015b9 <check_page+0xd3>
f0101595:	c7 44 24 0c a2 61 10 	movl   $0xf01061a2,0xc(%esp)
f010159c:	f0 
f010159d:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f01015a4:	f0 
f01015a5:	c7 44 24 04 ad 03 00 	movl   $0x3ad,0x4(%esp)
f01015ac:	00 
f01015ad:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f01015b4:	e8 cc ea ff ff       	call   f0100085 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01015b9:	39 c7                	cmp    %eax,%edi
f01015bb:	74 04                	je     f01015c1 <check_page+0xdb>
f01015bd:	39 c6                	cmp    %eax,%esi
f01015bf:	75 24                	jne    f01015e5 <check_page+0xff>
f01015c1:	c7 44 24 0c d0 59 10 	movl   $0xf01059d0,0xc(%esp)
f01015c8:	f0 
f01015c9:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f01015d0:	f0 
f01015d1:	c7 44 24 04 ae 03 00 	movl   $0x3ae,0x4(%esp)
f01015d8:	00 
f01015d9:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f01015e0:	e8 a0 ea ff ff       	call   f0100085 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01015e5:	a1 50 c6 19 f0       	mov    0xf019c650,%eax
f01015ea:	89 45 c8             	mov    %eax,-0x38(%ebp)
	page_free_list = 0;
f01015ed:	c7 05 50 c6 19 f0 00 	movl   $0x0,0xf019c650
f01015f4:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01015f7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01015fe:	e8 1e f8 ff ff       	call   f0100e21 <page_alloc>
f0101603:	85 c0                	test   %eax,%eax
f0101605:	74 24                	je     f010162b <check_page+0x145>
f0101607:	c7 44 24 0c b4 61 10 	movl   $0xf01061b4,0xc(%esp)
f010160e:	f0 
f010160f:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0101616:	f0 
f0101617:	c7 44 24 04 b5 03 00 	movl   $0x3b5,0x4(%esp)
f010161e:	00 
f010161f:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0101626:	e8 5a ea ff ff       	call   f0100085 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f010162b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010162e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101632:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101639:	00 
f010163a:	a1 08 d3 19 f0       	mov    0xf019d308,%eax
f010163f:	89 04 24             	mov    %eax,(%esp)
f0101642:	e8 58 f9 ff ff       	call   f0100f9f <page_lookup>
f0101647:	85 c0                	test   %eax,%eax
f0101649:	74 24                	je     f010166f <check_page+0x189>
f010164b:	c7 44 24 0c f0 59 10 	movl   $0xf01059f0,0xc(%esp)
f0101652:	f0 
f0101653:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f010165a:	f0 
f010165b:	c7 44 24 04 b8 03 00 	movl   $0x3b8,0x4(%esp)
f0101662:	00 
f0101663:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f010166a:	e8 16 ea ff ff       	call   f0100085 <_panic>
	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f010166f:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101676:	00 
f0101677:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010167e:	00 
f010167f:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101683:	a1 08 d3 19 f0       	mov    0xf019d308,%eax
f0101688:	89 04 24             	mov    %eax,(%esp)
f010168b:	e8 00 fa ff ff       	call   f0101090 <page_insert>
f0101690:	85 c0                	test   %eax,%eax
f0101692:	78 24                	js     f01016b8 <check_page+0x1d2>
f0101694:	c7 44 24 0c 28 5a 10 	movl   $0xf0105a28,0xc(%esp)
f010169b:	f0 
f010169c:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f01016a3:	f0 
f01016a4:	c7 44 24 04 ba 03 00 	movl   $0x3ba,0x4(%esp)
f01016ab:	00 
f01016ac:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f01016b3:	e8 cd e9 ff ff       	call   f0100085 <_panic>
	//cprintf("\n Frank test: pp0=%08x,pp1=%08x,pp2=%08x\n",pp0,pp1,pp2);

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f01016b8:	89 34 24             	mov    %esi,(%esp)
f01016bb:	e8 cc f5 ff ff       	call   f0100c8c <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01016c0:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01016c7:	00 
f01016c8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01016cf:	00 
f01016d0:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01016d4:	a1 08 d3 19 f0       	mov    0xf019d308,%eax
f01016d9:	89 04 24             	mov    %eax,(%esp)
f01016dc:	e8 af f9 ff ff       	call   f0101090 <page_insert>
f01016e1:	85 c0                	test   %eax,%eax
f01016e3:	74 24                	je     f0101709 <check_page+0x223>
f01016e5:	c7 44 24 0c 58 5a 10 	movl   $0xf0105a58,0xc(%esp)
f01016ec:	f0 
f01016ed:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f01016f4:	f0 
f01016f5:	c7 44 24 04 bf 03 00 	movl   $0x3bf,0x4(%esp)
f01016fc:	00 
f01016fd:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0101704:	e8 7c e9 ff ff       	call   f0100085 <_panic>
	//cprintf("\n Frank test: %08x=%08x\n",pp0,pa2page(PADDR(pgdir_walk(kern_pgdir,0x0,0))));
	//cprintf("\n Frank test: %08x = %08x\n",PTE_ADDR(kern_pgdir[0]),page2pa(pp0)); //why physics address here 3ff000(about 4M but at the top of all phymem allocated which should be about 64M)
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101709:	a1 08 d3 19 f0       	mov    0xf019d308,%eax
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f010170e:	89 75 d0             	mov    %esi,-0x30(%ebp)
f0101711:	8b 08                	mov    (%eax),%ecx
f0101713:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0101719:	89 f2                	mov    %esi,%edx
f010171b:	2b 15 0c d3 19 f0    	sub    0xf019d30c,%edx
f0101721:	c1 fa 03             	sar    $0x3,%edx
f0101724:	c1 e2 0c             	shl    $0xc,%edx
f0101727:	39 d1                	cmp    %edx,%ecx
f0101729:	74 24                	je     f010174f <check_page+0x269>
f010172b:	c7 44 24 0c 88 5a 10 	movl   $0xf0105a88,0xc(%esp)
f0101732:	f0 
f0101733:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f010173a:	f0 
f010173b:	c7 44 24 04 c2 03 00 	movl   $0x3c2,0x4(%esp)
f0101742:	00 
f0101743:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f010174a:	e8 36 e9 ff ff       	call   f0100085 <_panic>
	//cprintf("\n Frank test: %08x = %08x\n",check_va2pa(kern_pgdir, 0x0),page2pa(pp1));
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f010174f:	ba 00 00 00 00       	mov    $0x0,%edx
f0101754:	e8 b3 f9 ff ff       	call   f010110c <check_va2pa>
f0101759:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f010175c:	89 fa                	mov    %edi,%edx
f010175e:	2b 15 0c d3 19 f0    	sub    0xf019d30c,%edx
f0101764:	c1 fa 03             	sar    $0x3,%edx
f0101767:	c1 e2 0c             	shl    $0xc,%edx
f010176a:	39 d0                	cmp    %edx,%eax
f010176c:	74 24                	je     f0101792 <check_page+0x2ac>
f010176e:	c7 44 24 0c b0 5a 10 	movl   $0xf0105ab0,0xc(%esp)
f0101775:	f0 
f0101776:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f010177d:	f0 
f010177e:	c7 44 24 04 c4 03 00 	movl   $0x3c4,0x4(%esp)
f0101785:	00 
f0101786:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f010178d:	e8 f3 e8 ff ff       	call   f0100085 <_panic>
	assert(pp1->pp_ref == 1);
f0101792:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101797:	74 24                	je     f01017bd <check_page+0x2d7>
f0101799:	c7 44 24 0c c3 61 10 	movl   $0xf01061c3,0xc(%esp)
f01017a0:	f0 
f01017a1:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f01017a8:	f0 
f01017a9:	c7 44 24 04 c5 03 00 	movl   $0x3c5,0x4(%esp)
f01017b0:	00 
f01017b1:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f01017b8:	e8 c8 e8 ff ff       	call   f0100085 <_panic>
	assert(pp0->pp_ref == 1);
f01017bd:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01017c2:	74 24                	je     f01017e8 <check_page+0x302>
f01017c4:	c7 44 24 0c d4 61 10 	movl   $0xf01061d4,0xc(%esp)
f01017cb:	f0 
f01017cc:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f01017d3:	f0 
f01017d4:	c7 44 24 04 c6 03 00 	movl   $0x3c6,0x4(%esp)
f01017db:	00 
f01017dc:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f01017e3:	e8 9d e8 ff ff       	call   f0100085 <_panic>
	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01017e8:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01017ef:	00 
f01017f0:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01017f7:	00 
f01017f8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01017fc:	a1 08 d3 19 f0       	mov    0xf019d308,%eax
f0101801:	89 04 24             	mov    %eax,(%esp)
f0101804:	e8 87 f8 ff ff       	call   f0101090 <page_insert>
f0101809:	85 c0                	test   %eax,%eax
f010180b:	74 24                	je     f0101831 <check_page+0x34b>
f010180d:	c7 44 24 0c e0 5a 10 	movl   $0xf0105ae0,0xc(%esp)
f0101814:	f0 
f0101815:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f010181c:	f0 
f010181d:	c7 44 24 04 c8 03 00 	movl   $0x3c8,0x4(%esp)
f0101824:	00 
f0101825:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f010182c:	e8 54 e8 ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101831:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101836:	a1 08 d3 19 f0       	mov    0xf019d308,%eax
f010183b:	e8 cc f8 ff ff       	call   f010110c <check_va2pa>
f0101840:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f0101843:	89 da                	mov    %ebx,%edx
f0101845:	2b 15 0c d3 19 f0    	sub    0xf019d30c,%edx
f010184b:	c1 fa 03             	sar    $0x3,%edx
f010184e:	c1 e2 0c             	shl    $0xc,%edx
f0101851:	39 d0                	cmp    %edx,%eax
f0101853:	74 24                	je     f0101879 <check_page+0x393>
f0101855:	c7 44 24 0c 1c 5b 10 	movl   $0xf0105b1c,0xc(%esp)
f010185c:	f0 
f010185d:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0101864:	f0 
f0101865:	c7 44 24 04 c9 03 00 	movl   $0x3c9,0x4(%esp)
f010186c:	00 
f010186d:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0101874:	e8 0c e8 ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 1);
f0101879:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010187e:	74 24                	je     f01018a4 <check_page+0x3be>
f0101880:	c7 44 24 0c e5 61 10 	movl   $0xf01061e5,0xc(%esp)
f0101887:	f0 
f0101888:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f010188f:	f0 
f0101890:	c7 44 24 04 ca 03 00 	movl   $0x3ca,0x4(%esp)
f0101897:	00 
f0101898:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f010189f:	e8 e1 e7 ff ff       	call   f0100085 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01018a4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01018ab:	e8 71 f5 ff ff       	call   f0100e21 <page_alloc>
f01018b0:	85 c0                	test   %eax,%eax
f01018b2:	74 24                	je     f01018d8 <check_page+0x3f2>
f01018b4:	c7 44 24 0c b4 61 10 	movl   $0xf01061b4,0xc(%esp)
f01018bb:	f0 
f01018bc:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f01018c3:	f0 
f01018c4:	c7 44 24 04 cd 03 00 	movl   $0x3cd,0x4(%esp)
f01018cb:	00 
f01018cc:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f01018d3:	e8 ad e7 ff ff       	call   f0100085 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01018d8:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01018df:	00 
f01018e0:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01018e7:	00 
f01018e8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01018ec:	a1 08 d3 19 f0       	mov    0xf019d308,%eax
f01018f1:	89 04 24             	mov    %eax,(%esp)
f01018f4:	e8 97 f7 ff ff       	call   f0101090 <page_insert>
f01018f9:	85 c0                	test   %eax,%eax
f01018fb:	74 24                	je     f0101921 <check_page+0x43b>
f01018fd:	c7 44 24 0c e0 5a 10 	movl   $0xf0105ae0,0xc(%esp)
f0101904:	f0 
f0101905:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f010190c:	f0 
f010190d:	c7 44 24 04 d0 03 00 	movl   $0x3d0,0x4(%esp)
f0101914:	00 
f0101915:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f010191c:	e8 64 e7 ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101921:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101926:	a1 08 d3 19 f0       	mov    0xf019d308,%eax
f010192b:	e8 dc f7 ff ff       	call   f010110c <check_va2pa>
f0101930:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0101933:	2b 15 0c d3 19 f0    	sub    0xf019d30c,%edx
f0101939:	c1 fa 03             	sar    $0x3,%edx
f010193c:	c1 e2 0c             	shl    $0xc,%edx
f010193f:	39 d0                	cmp    %edx,%eax
f0101941:	74 24                	je     f0101967 <check_page+0x481>
f0101943:	c7 44 24 0c 1c 5b 10 	movl   $0xf0105b1c,0xc(%esp)
f010194a:	f0 
f010194b:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0101952:	f0 
f0101953:	c7 44 24 04 d1 03 00 	movl   $0x3d1,0x4(%esp)
f010195a:	00 
f010195b:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0101962:	e8 1e e7 ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 1);
f0101967:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010196c:	74 24                	je     f0101992 <check_page+0x4ac>
f010196e:	c7 44 24 0c e5 61 10 	movl   $0xf01061e5,0xc(%esp)
f0101975:	f0 
f0101976:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f010197d:	f0 
f010197e:	c7 44 24 04 d2 03 00 	movl   $0x3d2,0x4(%esp)
f0101985:	00 
f0101986:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f010198d:	e8 f3 e6 ff ff       	call   f0100085 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101992:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101999:	e8 83 f4 ff ff       	call   f0100e21 <page_alloc>
f010199e:	85 c0                	test   %eax,%eax
f01019a0:	74 24                	je     f01019c6 <check_page+0x4e0>
f01019a2:	c7 44 24 0c b4 61 10 	movl   $0xf01061b4,0xc(%esp)
f01019a9:	f0 
f01019aa:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f01019b1:	f0 
f01019b2:	c7 44 24 04 d6 03 00 	movl   $0x3d6,0x4(%esp)
f01019b9:	00 
f01019ba:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f01019c1:	e8 bf e6 ff ff       	call   f0100085 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f01019c6:	a1 08 d3 19 f0       	mov    0xf019d308,%eax
f01019cb:	8b 00                	mov    (%eax),%eax
f01019cd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01019d2:	89 c2                	mov    %eax,%edx
f01019d4:	c1 ea 0c             	shr    $0xc,%edx
f01019d7:	3b 15 04 d3 19 f0    	cmp    0xf019d304,%edx
f01019dd:	72 20                	jb     f01019ff <check_page+0x519>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01019df:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01019e3:	c7 44 24 08 c8 58 10 	movl   $0xf01058c8,0x8(%esp)
f01019ea:	f0 
f01019eb:	c7 44 24 04 d9 03 00 	movl   $0x3d9,0x4(%esp)
f01019f2:	00 
f01019f3:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f01019fa:	e8 86 e6 ff ff       	call   f0100085 <_panic>
f01019ff:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101a04:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101a07:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101a0e:	00 
f0101a0f:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101a16:	00 
f0101a17:	a1 08 d3 19 f0       	mov    0xf019d308,%eax
f0101a1c:	89 04 24             	mov    %eax,(%esp)
f0101a1f:	e8 81 f4 ff ff       	call   f0100ea5 <pgdir_walk>
f0101a24:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101a27:	83 c2 04             	add    $0x4,%edx
f0101a2a:	39 d0                	cmp    %edx,%eax
f0101a2c:	74 24                	je     f0101a52 <check_page+0x56c>
f0101a2e:	c7 44 24 0c 4c 5b 10 	movl   $0xf0105b4c,0xc(%esp)
f0101a35:	f0 
f0101a36:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0101a3d:	f0 
f0101a3e:	c7 44 24 04 da 03 00 	movl   $0x3da,0x4(%esp)
f0101a45:	00 
f0101a46:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0101a4d:	e8 33 e6 ff ff       	call   f0100085 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101a52:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0101a59:	00 
f0101a5a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101a61:	00 
f0101a62:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101a66:	a1 08 d3 19 f0       	mov    0xf019d308,%eax
f0101a6b:	89 04 24             	mov    %eax,(%esp)
f0101a6e:	e8 1d f6 ff ff       	call   f0101090 <page_insert>
f0101a73:	85 c0                	test   %eax,%eax
f0101a75:	74 24                	je     f0101a9b <check_page+0x5b5>
f0101a77:	c7 44 24 0c 8c 5b 10 	movl   $0xf0105b8c,0xc(%esp)
f0101a7e:	f0 
f0101a7f:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0101a86:	f0 
f0101a87:	c7 44 24 04 dd 03 00 	movl   $0x3dd,0x4(%esp)
f0101a8e:	00 
f0101a8f:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0101a96:	e8 ea e5 ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101a9b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101aa0:	a1 08 d3 19 f0       	mov    0xf019d308,%eax
f0101aa5:	e8 62 f6 ff ff       	call   f010110c <check_va2pa>
f0101aaa:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0101aad:	2b 15 0c d3 19 f0    	sub    0xf019d30c,%edx
f0101ab3:	c1 fa 03             	sar    $0x3,%edx
f0101ab6:	c1 e2 0c             	shl    $0xc,%edx
f0101ab9:	39 d0                	cmp    %edx,%eax
f0101abb:	74 24                	je     f0101ae1 <check_page+0x5fb>
f0101abd:	c7 44 24 0c 1c 5b 10 	movl   $0xf0105b1c,0xc(%esp)
f0101ac4:	f0 
f0101ac5:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0101acc:	f0 
f0101acd:	c7 44 24 04 de 03 00 	movl   $0x3de,0x4(%esp)
f0101ad4:	00 
f0101ad5:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0101adc:	e8 a4 e5 ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 1);
f0101ae1:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101ae6:	74 24                	je     f0101b0c <check_page+0x626>
f0101ae8:	c7 44 24 0c e5 61 10 	movl   $0xf01061e5,0xc(%esp)
f0101aef:	f0 
f0101af0:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0101af7:	f0 
f0101af8:	c7 44 24 04 df 03 00 	movl   $0x3df,0x4(%esp)
f0101aff:	00 
f0101b00:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0101b07:	e8 79 e5 ff ff       	call   f0100085 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101b0c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101b13:	00 
f0101b14:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101b1b:	00 
f0101b1c:	a1 08 d3 19 f0       	mov    0xf019d308,%eax
f0101b21:	89 04 24             	mov    %eax,(%esp)
f0101b24:	e8 7c f3 ff ff       	call   f0100ea5 <pgdir_walk>
f0101b29:	f6 00 04             	testb  $0x4,(%eax)
f0101b2c:	75 24                	jne    f0101b52 <check_page+0x66c>
f0101b2e:	c7 44 24 0c cc 5b 10 	movl   $0xf0105bcc,0xc(%esp)
f0101b35:	f0 
f0101b36:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0101b3d:	f0 
f0101b3e:	c7 44 24 04 e0 03 00 	movl   $0x3e0,0x4(%esp)
f0101b45:	00 
f0101b46:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0101b4d:	e8 33 e5 ff ff       	call   f0100085 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101b52:	a1 08 d3 19 f0       	mov    0xf019d308,%eax
f0101b57:	f6 00 04             	testb  $0x4,(%eax)
f0101b5a:	75 24                	jne    f0101b80 <check_page+0x69a>
f0101b5c:	c7 44 24 0c f6 61 10 	movl   $0xf01061f6,0xc(%esp)
f0101b63:	f0 
f0101b64:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0101b6b:	f0 
f0101b6c:	c7 44 24 04 e1 03 00 	movl   $0x3e1,0x4(%esp)
f0101b73:	00 
f0101b74:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0101b7b:	e8 05 e5 ff ff       	call   f0100085 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101b80:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101b87:	00 
f0101b88:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f0101b8f:	00 
f0101b90:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101b94:	89 04 24             	mov    %eax,(%esp)
f0101b97:	e8 f4 f4 ff ff       	call   f0101090 <page_insert>
f0101b9c:	85 c0                	test   %eax,%eax
f0101b9e:	78 24                	js     f0101bc4 <check_page+0x6de>
f0101ba0:	c7 44 24 0c 00 5c 10 	movl   $0xf0105c00,0xc(%esp)
f0101ba7:	f0 
f0101ba8:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0101baf:	f0 
f0101bb0:	c7 44 24 04 e4 03 00 	movl   $0x3e4,0x4(%esp)
f0101bb7:	00 
f0101bb8:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0101bbf:	e8 c1 e4 ff ff       	call   f0100085 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101bc4:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101bcb:	00 
f0101bcc:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101bd3:	00 
f0101bd4:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101bd8:	a1 08 d3 19 f0       	mov    0xf019d308,%eax
f0101bdd:	89 04 24             	mov    %eax,(%esp)
f0101be0:	e8 ab f4 ff ff       	call   f0101090 <page_insert>
f0101be5:	85 c0                	test   %eax,%eax
f0101be7:	74 24                	je     f0101c0d <check_page+0x727>
f0101be9:	c7 44 24 0c 38 5c 10 	movl   $0xf0105c38,0xc(%esp)
f0101bf0:	f0 
f0101bf1:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0101bf8:	f0 
f0101bf9:	c7 44 24 04 e7 03 00 	movl   $0x3e7,0x4(%esp)
f0101c00:	00 
f0101c01:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0101c08:	e8 78 e4 ff ff       	call   f0100085 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101c0d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101c14:	00 
f0101c15:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101c1c:	00 
f0101c1d:	a1 08 d3 19 f0       	mov    0xf019d308,%eax
f0101c22:	89 04 24             	mov    %eax,(%esp)
f0101c25:	e8 7b f2 ff ff       	call   f0100ea5 <pgdir_walk>
f0101c2a:	f6 00 04             	testb  $0x4,(%eax)
f0101c2d:	74 24                	je     f0101c53 <check_page+0x76d>
f0101c2f:	c7 44 24 0c 74 5c 10 	movl   $0xf0105c74,0xc(%esp)
f0101c36:	f0 
f0101c37:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0101c3e:	f0 
f0101c3f:	c7 44 24 04 e8 03 00 	movl   $0x3e8,0x4(%esp)
f0101c46:	00 
f0101c47:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0101c4e:	e8 32 e4 ff ff       	call   f0100085 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101c53:	ba 00 00 00 00       	mov    $0x0,%edx
f0101c58:	a1 08 d3 19 f0       	mov    0xf019d308,%eax
f0101c5d:	e8 aa f4 ff ff       	call   f010110c <check_va2pa>
f0101c62:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101c65:	2b 15 0c d3 19 f0    	sub    0xf019d30c,%edx
f0101c6b:	c1 fa 03             	sar    $0x3,%edx
f0101c6e:	c1 e2 0c             	shl    $0xc,%edx
f0101c71:	39 d0                	cmp    %edx,%eax
f0101c73:	74 24                	je     f0101c99 <check_page+0x7b3>
f0101c75:	c7 44 24 0c ac 5c 10 	movl   $0xf0105cac,0xc(%esp)
f0101c7c:	f0 
f0101c7d:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0101c84:	f0 
f0101c85:	c7 44 24 04 eb 03 00 	movl   $0x3eb,0x4(%esp)
f0101c8c:	00 
f0101c8d:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0101c94:	e8 ec e3 ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101c99:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c9e:	a1 08 d3 19 f0       	mov    0xf019d308,%eax
f0101ca3:	e8 64 f4 ff ff       	call   f010110c <check_va2pa>
f0101ca8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101cab:	2b 15 0c d3 19 f0    	sub    0xf019d30c,%edx
f0101cb1:	c1 fa 03             	sar    $0x3,%edx
f0101cb4:	c1 e2 0c             	shl    $0xc,%edx
f0101cb7:	39 d0                	cmp    %edx,%eax
f0101cb9:	74 24                	je     f0101cdf <check_page+0x7f9>
f0101cbb:	c7 44 24 0c d8 5c 10 	movl   $0xf0105cd8,0xc(%esp)
f0101cc2:	f0 
f0101cc3:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0101cca:	f0 
f0101ccb:	c7 44 24 04 ec 03 00 	movl   $0x3ec,0x4(%esp)
f0101cd2:	00 
f0101cd3:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0101cda:	e8 a6 e3 ff ff       	call   f0100085 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101cdf:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f0101ce4:	74 24                	je     f0101d0a <check_page+0x824>
f0101ce6:	c7 44 24 0c 0c 62 10 	movl   $0xf010620c,0xc(%esp)
f0101ced:	f0 
f0101cee:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0101cf5:	f0 
f0101cf6:	c7 44 24 04 ee 03 00 	movl   $0x3ee,0x4(%esp)
f0101cfd:	00 
f0101cfe:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0101d05:	e8 7b e3 ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 0);
f0101d0a:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101d0f:	74 24                	je     f0101d35 <check_page+0x84f>
f0101d11:	c7 44 24 0c 1d 62 10 	movl   $0xf010621d,0xc(%esp)
f0101d18:	f0 
f0101d19:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0101d20:	f0 
f0101d21:	c7 44 24 04 ef 03 00 	movl   $0x3ef,0x4(%esp)
f0101d28:	00 
f0101d29:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0101d30:	e8 50 e3 ff ff       	call   f0100085 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101d35:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101d3c:	e8 e0 f0 ff ff       	call   f0100e21 <page_alloc>
f0101d41:	85 c0                	test   %eax,%eax
f0101d43:	74 04                	je     f0101d49 <check_page+0x863>
f0101d45:	39 c3                	cmp    %eax,%ebx
f0101d47:	74 24                	je     f0101d6d <check_page+0x887>
f0101d49:	c7 44 24 0c 08 5d 10 	movl   $0xf0105d08,0xc(%esp)
f0101d50:	f0 
f0101d51:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0101d58:	f0 
f0101d59:	c7 44 24 04 f2 03 00 	movl   $0x3f2,0x4(%esp)
f0101d60:	00 
f0101d61:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0101d68:	e8 18 e3 ff ff       	call   f0100085 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101d6d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101d74:	00 
f0101d75:	a1 08 d3 19 f0       	mov    0xf019d308,%eax
f0101d7a:	89 04 24             	mov    %eax,(%esp)
f0101d7d:	e8 91 f2 ff ff       	call   f0101013 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101d82:	ba 00 00 00 00       	mov    $0x0,%edx
f0101d87:	a1 08 d3 19 f0       	mov    0xf019d308,%eax
f0101d8c:	e8 7b f3 ff ff       	call   f010110c <check_va2pa>
f0101d91:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101d94:	74 24                	je     f0101dba <check_page+0x8d4>
f0101d96:	c7 44 24 0c 2c 5d 10 	movl   $0xf0105d2c,0xc(%esp)
f0101d9d:	f0 
f0101d9e:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0101da5:	f0 
f0101da6:	c7 44 24 04 f6 03 00 	movl   $0x3f6,0x4(%esp)
f0101dad:	00 
f0101dae:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0101db5:	e8 cb e2 ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101dba:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101dbf:	a1 08 d3 19 f0       	mov    0xf019d308,%eax
f0101dc4:	e8 43 f3 ff ff       	call   f010110c <check_va2pa>
f0101dc9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101dcc:	2b 15 0c d3 19 f0    	sub    0xf019d30c,%edx
f0101dd2:	c1 fa 03             	sar    $0x3,%edx
f0101dd5:	c1 e2 0c             	shl    $0xc,%edx
f0101dd8:	39 d0                	cmp    %edx,%eax
f0101dda:	74 24                	je     f0101e00 <check_page+0x91a>
f0101ddc:	c7 44 24 0c d8 5c 10 	movl   $0xf0105cd8,0xc(%esp)
f0101de3:	f0 
f0101de4:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0101deb:	f0 
f0101dec:	c7 44 24 04 f7 03 00 	movl   $0x3f7,0x4(%esp)
f0101df3:	00 
f0101df4:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0101dfb:	e8 85 e2 ff ff       	call   f0100085 <_panic>
	assert(pp1->pp_ref == 1);
f0101e00:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101e05:	74 24                	je     f0101e2b <check_page+0x945>
f0101e07:	c7 44 24 0c c3 61 10 	movl   $0xf01061c3,0xc(%esp)
f0101e0e:	f0 
f0101e0f:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0101e16:	f0 
f0101e17:	c7 44 24 04 f8 03 00 	movl   $0x3f8,0x4(%esp)
f0101e1e:	00 
f0101e1f:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0101e26:	e8 5a e2 ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 0);
f0101e2b:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101e30:	74 24                	je     f0101e56 <check_page+0x970>
f0101e32:	c7 44 24 0c 1d 62 10 	movl   $0xf010621d,0xc(%esp)
f0101e39:	f0 
f0101e3a:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0101e41:	f0 
f0101e42:	c7 44 24 04 f9 03 00 	movl   $0x3f9,0x4(%esp)
f0101e49:	00 
f0101e4a:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0101e51:	e8 2f e2 ff ff       	call   f0100085 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101e56:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101e5d:	00 
f0101e5e:	a1 08 d3 19 f0       	mov    0xf019d308,%eax
f0101e63:	89 04 24             	mov    %eax,(%esp)
f0101e66:	e8 a8 f1 ff ff       	call   f0101013 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101e6b:	ba 00 00 00 00       	mov    $0x0,%edx
f0101e70:	a1 08 d3 19 f0       	mov    0xf019d308,%eax
f0101e75:	e8 92 f2 ff ff       	call   f010110c <check_va2pa>
f0101e7a:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101e7d:	74 24                	je     f0101ea3 <check_page+0x9bd>
f0101e7f:	c7 44 24 0c 2c 5d 10 	movl   $0xf0105d2c,0xc(%esp)
f0101e86:	f0 
f0101e87:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0101e8e:	f0 
f0101e8f:	c7 44 24 04 fd 03 00 	movl   $0x3fd,0x4(%esp)
f0101e96:	00 
f0101e97:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0101e9e:	e8 e2 e1 ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101ea3:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ea8:	a1 08 d3 19 f0       	mov    0xf019d308,%eax
f0101ead:	e8 5a f2 ff ff       	call   f010110c <check_va2pa>
f0101eb2:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101eb5:	74 24                	je     f0101edb <check_page+0x9f5>
f0101eb7:	c7 44 24 0c 50 5d 10 	movl   $0xf0105d50,0xc(%esp)
f0101ebe:	f0 
f0101ebf:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0101ec6:	f0 
f0101ec7:	c7 44 24 04 fe 03 00 	movl   $0x3fe,0x4(%esp)
f0101ece:	00 
f0101ecf:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0101ed6:	e8 aa e1 ff ff       	call   f0100085 <_panic>
	assert(pp1->pp_ref == 0);
f0101edb:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101ee0:	74 24                	je     f0101f06 <check_page+0xa20>
f0101ee2:	c7 44 24 0c 2e 62 10 	movl   $0xf010622e,0xc(%esp)
f0101ee9:	f0 
f0101eea:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0101ef1:	f0 
f0101ef2:	c7 44 24 04 ff 03 00 	movl   $0x3ff,0x4(%esp)
f0101ef9:	00 
f0101efa:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0101f01:	e8 7f e1 ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 0);
f0101f06:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101f0b:	74 24                	je     f0101f31 <check_page+0xa4b>
f0101f0d:	c7 44 24 0c 1d 62 10 	movl   $0xf010621d,0xc(%esp)
f0101f14:	f0 
f0101f15:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0101f1c:	f0 
f0101f1d:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
f0101f24:	00 
f0101f25:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0101f2c:	e8 54 e1 ff ff       	call   f0100085 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101f31:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101f38:	e8 e4 ee ff ff       	call   f0100e21 <page_alloc>
f0101f3d:	85 c0                	test   %eax,%eax
f0101f3f:	74 04                	je     f0101f45 <check_page+0xa5f>
f0101f41:	39 c7                	cmp    %eax,%edi
f0101f43:	74 24                	je     f0101f69 <check_page+0xa83>
f0101f45:	c7 44 24 0c 78 5d 10 	movl   $0xf0105d78,0xc(%esp)
f0101f4c:	f0 
f0101f4d:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0101f54:	f0 
f0101f55:	c7 44 24 04 03 04 00 	movl   $0x403,0x4(%esp)
f0101f5c:	00 
f0101f5d:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0101f64:	e8 1c e1 ff ff       	call   f0100085 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101f69:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101f70:	e8 ac ee ff ff       	call   f0100e21 <page_alloc>
f0101f75:	85 c0                	test   %eax,%eax
f0101f77:	74 24                	je     f0101f9d <check_page+0xab7>
f0101f79:	c7 44 24 0c b4 61 10 	movl   $0xf01061b4,0xc(%esp)
f0101f80:	f0 
f0101f81:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0101f88:	f0 
f0101f89:	c7 44 24 04 06 04 00 	movl   $0x406,0x4(%esp)
f0101f90:	00 
f0101f91:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0101f98:	e8 e8 e0 ff ff       	call   f0100085 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101f9d:	a1 08 d3 19 f0       	mov    0xf019d308,%eax
f0101fa2:	8b 08                	mov    (%eax),%ecx
f0101fa4:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0101faa:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0101fad:	2b 15 0c d3 19 f0    	sub    0xf019d30c,%edx
f0101fb3:	c1 fa 03             	sar    $0x3,%edx
f0101fb6:	c1 e2 0c             	shl    $0xc,%edx
f0101fb9:	39 d1                	cmp    %edx,%ecx
f0101fbb:	74 24                	je     f0101fe1 <check_page+0xafb>
f0101fbd:	c7 44 24 0c 88 5a 10 	movl   $0xf0105a88,0xc(%esp)
f0101fc4:	f0 
f0101fc5:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0101fcc:	f0 
f0101fcd:	c7 44 24 04 09 04 00 	movl   $0x409,0x4(%esp)
f0101fd4:	00 
f0101fd5:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0101fdc:	e8 a4 e0 ff ff       	call   f0100085 <_panic>
	kern_pgdir[0] = 0;
f0101fe1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0101fe7:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101fec:	74 24                	je     f0102012 <check_page+0xb2c>
f0101fee:	c7 44 24 0c d4 61 10 	movl   $0xf01061d4,0xc(%esp)
f0101ff5:	f0 
f0101ff6:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0101ffd:	f0 
f0101ffe:	c7 44 24 04 0b 04 00 	movl   $0x40b,0x4(%esp)
f0102005:	00 
f0102006:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f010200d:	e8 73 e0 ff ff       	call   f0100085 <_panic>
	pp0->pp_ref = 0;
f0102012:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102018:	89 34 24             	mov    %esi,(%esp)
f010201b:	e8 6c ec ff ff       	call   f0100c8c <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102020:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102027:	00 
f0102028:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f010202f:	00 
f0102030:	a1 08 d3 19 f0       	mov    0xf019d308,%eax
f0102035:	89 04 24             	mov    %eax,(%esp)
f0102038:	e8 68 ee ff ff       	call   f0100ea5 <pgdir_walk>
f010203d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102040:	8b 0d 08 d3 19 f0    	mov    0xf019d308,%ecx
f0102046:	83 c1 04             	add    $0x4,%ecx
f0102049:	8b 11                	mov    (%ecx),%edx
f010204b:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102051:	89 55 cc             	mov    %edx,-0x34(%ebp)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102054:	c1 ea 0c             	shr    $0xc,%edx
f0102057:	3b 15 04 d3 19 f0    	cmp    0xf019d304,%edx
f010205d:	72 23                	jb     f0102082 <check_page+0xb9c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010205f:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0102062:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102066:	c7 44 24 08 c8 58 10 	movl   $0xf01058c8,0x8(%esp)
f010206d:	f0 
f010206e:	c7 44 24 04 12 04 00 	movl   $0x412,0x4(%esp)
f0102075:	00 
f0102076:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f010207d:	e8 03 e0 ff ff       	call   f0100085 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102082:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0102085:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f010208b:	39 d0                	cmp    %edx,%eax
f010208d:	74 24                	je     f01020b3 <check_page+0xbcd>
f010208f:	c7 44 24 0c 3f 62 10 	movl   $0xf010623f,0xc(%esp)
f0102096:	f0 
f0102097:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f010209e:	f0 
f010209f:	c7 44 24 04 13 04 00 	movl   $0x413,0x4(%esp)
f01020a6:	00 
f01020a7:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f01020ae:	e8 d2 df ff ff       	call   f0100085 <_panic>
	kern_pgdir[PDX(va)] = 0;
f01020b3:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	pp0->pp_ref = 0;
f01020b9:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f01020bf:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01020c2:	2b 05 0c d3 19 f0    	sub    0xf019d30c,%eax
f01020c8:	c1 f8 03             	sar    $0x3,%eax
f01020cb:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01020ce:	89 c2                	mov    %eax,%edx
f01020d0:	c1 ea 0c             	shr    $0xc,%edx
f01020d3:	3b 15 04 d3 19 f0    	cmp    0xf019d304,%edx
f01020d9:	72 20                	jb     f01020fb <check_page+0xc15>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01020db:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01020df:	c7 44 24 08 c8 58 10 	movl   $0xf01058c8,0x8(%esp)
f01020e6:	f0 
f01020e7:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f01020ee:	00 
f01020ef:	c7 04 24 cb 60 10 f0 	movl   $0xf01060cb,(%esp)
f01020f6:	e8 8a df ff ff       	call   f0100085 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01020fb:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102102:	00 
f0102103:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f010210a:	00 
f010210b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102110:	89 04 24             	mov    %eax,(%esp)
f0102113:	e8 3e 2d 00 00       	call   f0104e56 <memset>
	page_free(pp0);
f0102118:	89 34 24             	mov    %esi,(%esp)
f010211b:	e8 6c eb ff ff       	call   f0100c8c <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102120:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102127:	00 
f0102128:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010212f:	00 
f0102130:	a1 08 d3 19 f0       	mov    0xf019d308,%eax
f0102135:	89 04 24             	mov    %eax,(%esp)
f0102138:	e8 68 ed ff ff       	call   f0100ea5 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f010213d:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0102140:	2b 15 0c d3 19 f0    	sub    0xf019d30c,%edx
f0102146:	c1 fa 03             	sar    $0x3,%edx
f0102149:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010214c:	89 d0                	mov    %edx,%eax
f010214e:	c1 e8 0c             	shr    $0xc,%eax
f0102151:	3b 05 04 d3 19 f0    	cmp    0xf019d304,%eax
f0102157:	72 20                	jb     f0102179 <check_page+0xc93>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102159:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010215d:	c7 44 24 08 c8 58 10 	movl   $0xf01058c8,0x8(%esp)
f0102164:	f0 
f0102165:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f010216c:	00 
f010216d:	c7 04 24 cb 60 10 f0 	movl   $0xf01060cb,(%esp)
f0102174:	e8 0c df ff ff       	call   f0100085 <_panic>
	ptep = (pte_t *) page2kva(pp0);
f0102179:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f010217f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102182:	f6 00 01             	testb  $0x1,(%eax)
f0102185:	75 11                	jne    f0102198 <check_page+0xcb2>
f0102187:	8d 82 04 00 00 f0    	lea    -0xffffffc(%edx),%eax
}


// check page_insert, page_remove, &c
static void
check_page(void)
f010218d:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102193:	f6 00 01             	testb  $0x1,(%eax)
f0102196:	74 24                	je     f01021bc <check_page+0xcd6>
f0102198:	c7 44 24 0c 57 62 10 	movl   $0xf0106257,0xc(%esp)
f010219f:	f0 
f01021a0:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f01021a7:	f0 
f01021a8:	c7 44 24 04 1d 04 00 	movl   $0x41d,0x4(%esp)
f01021af:	00 
f01021b0:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f01021b7:	e8 c9 de ff ff       	call   f0100085 <_panic>
f01021bc:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f01021bf:	39 d0                	cmp    %edx,%eax
f01021c1:	75 d0                	jne    f0102193 <check_page+0xcad>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f01021c3:	a1 08 d3 19 f0       	mov    0xf019d308,%eax
f01021c8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01021ce:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// give free list back
	page_free_list = fl;
f01021d4:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01021d7:	a3 50 c6 19 f0       	mov    %eax,0xf019c650

	// free the pages we took
	page_free(pp0);
f01021dc:	89 34 24             	mov    %esi,(%esp)
f01021df:	e8 a8 ea ff ff       	call   f0100c8c <page_free>
	page_free(pp1);
f01021e4:	89 3c 24             	mov    %edi,(%esp)
f01021e7:	e8 a0 ea ff ff       	call   f0100c8c <page_free>
	page_free(pp2);
f01021ec:	89 1c 24             	mov    %ebx,(%esp)
f01021ef:	e8 98 ea ff ff       	call   f0100c8c <page_free>

	cprintf("check_page() succeeded!\n");
f01021f4:	c7 04 24 6e 62 10 f0 	movl   $0xf010626e,(%esp)
f01021fb:	e8 1b 1a 00 00       	call   f0103c1b <cprintf>
}
f0102200:	83 c4 3c             	add    $0x3c,%esp
f0102203:	5b                   	pop    %ebx
f0102204:	5e                   	pop    %esi
f0102205:	5f                   	pop    %edi
f0102206:	5d                   	pop    %ebp
f0102207:	c3                   	ret    

f0102208 <check_page_installed_pgdir>:
}

// check page_insert, page_remove, &c, with an installed kern_pgdir
static void
check_page_installed_pgdir(void)
{
f0102208:	55                   	push   %ebp
f0102209:	89 e5                	mov    %esp,%ebp
f010220b:	57                   	push   %edi
f010220c:	56                   	push   %esi
f010220d:	53                   	push   %ebx
f010220e:	83 ec 2c             	sub    $0x2c,%esp
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102211:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102218:	e8 04 ec ff ff       	call   f0100e21 <page_alloc>
f010221d:	89 c3                	mov    %eax,%ebx
f010221f:	85 c0                	test   %eax,%eax
f0102221:	75 24                	jne    f0102247 <check_page_installed_pgdir+0x3f>
f0102223:	c7 44 24 0c 60 61 10 	movl   $0xf0106160,0xc(%esp)
f010222a:	f0 
f010222b:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0102232:	f0 
f0102233:	c7 44 24 04 a5 04 00 	movl   $0x4a5,0x4(%esp)
f010223a:	00 
f010223b:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0102242:	e8 3e de ff ff       	call   f0100085 <_panic>
	assert((pp1 = page_alloc(0)));
f0102247:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010224e:	e8 ce eb ff ff       	call   f0100e21 <page_alloc>
f0102253:	89 c7                	mov    %eax,%edi
f0102255:	85 c0                	test   %eax,%eax
f0102257:	75 24                	jne    f010227d <check_page_installed_pgdir+0x75>
f0102259:	c7 44 24 0c 76 61 10 	movl   $0xf0106176,0xc(%esp)
f0102260:	f0 
f0102261:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0102268:	f0 
f0102269:	c7 44 24 04 a6 04 00 	movl   $0x4a6,0x4(%esp)
f0102270:	00 
f0102271:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0102278:	e8 08 de ff ff       	call   f0100085 <_panic>
	assert((pp2 = page_alloc(0)));
f010227d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102284:	e8 98 eb ff ff       	call   f0100e21 <page_alloc>
f0102289:	89 c6                	mov    %eax,%esi
f010228b:	85 c0                	test   %eax,%eax
f010228d:	75 24                	jne    f01022b3 <check_page_installed_pgdir+0xab>
f010228f:	c7 44 24 0c 8c 61 10 	movl   $0xf010618c,0xc(%esp)
f0102296:	f0 
f0102297:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f010229e:	f0 
f010229f:	c7 44 24 04 a7 04 00 	movl   $0x4a7,0x4(%esp)
f01022a6:	00 
f01022a7:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f01022ae:	e8 d2 dd ff ff       	call   f0100085 <_panic>
	page_free(pp0);
f01022b3:	89 1c 24             	mov    %ebx,(%esp)
f01022b6:	e8 d1 e9 ff ff       	call   f0100c8c <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f01022bb:	89 f8                	mov    %edi,%eax
f01022bd:	2b 05 0c d3 19 f0    	sub    0xf019d30c,%eax
f01022c3:	c1 f8 03             	sar    $0x3,%eax
f01022c6:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01022c9:	89 c2                	mov    %eax,%edx
f01022cb:	c1 ea 0c             	shr    $0xc,%edx
f01022ce:	3b 15 04 d3 19 f0    	cmp    0xf019d304,%edx
f01022d4:	72 20                	jb     f01022f6 <check_page_installed_pgdir+0xee>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01022d6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01022da:	c7 44 24 08 c8 58 10 	movl   $0xf01058c8,0x8(%esp)
f01022e1:	f0 
f01022e2:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f01022e9:	00 
f01022ea:	c7 04 24 cb 60 10 f0 	movl   $0xf01060cb,(%esp)
f01022f1:	e8 8f dd ff ff       	call   f0100085 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f01022f6:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01022fd:	00 
f01022fe:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0102305:	00 
f0102306:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010230b:	89 04 24             	mov    %eax,(%esp)
f010230e:	e8 43 2b 00 00       	call   f0104e56 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0102313:	89 75 e4             	mov    %esi,-0x1c(%ebp)
f0102316:	89 f0                	mov    %esi,%eax
f0102318:	2b 05 0c d3 19 f0    	sub    0xf019d30c,%eax
f010231e:	c1 f8 03             	sar    $0x3,%eax
f0102321:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102324:	89 c2                	mov    %eax,%edx
f0102326:	c1 ea 0c             	shr    $0xc,%edx
f0102329:	3b 15 04 d3 19 f0    	cmp    0xf019d304,%edx
f010232f:	72 20                	jb     f0102351 <check_page_installed_pgdir+0x149>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102331:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102335:	c7 44 24 08 c8 58 10 	movl   $0xf01058c8,0x8(%esp)
f010233c:	f0 
f010233d:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0102344:	00 
f0102345:	c7 04 24 cb 60 10 f0 	movl   $0xf01060cb,(%esp)
f010234c:	e8 34 dd ff ff       	call   f0100085 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102351:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102358:	00 
f0102359:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102360:	00 
f0102361:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102366:	89 04 24             	mov    %eax,(%esp)
f0102369:	e8 e8 2a 00 00       	call   f0104e56 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f010236e:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102375:	00 
f0102376:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010237d:	00 
f010237e:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102382:	a1 08 d3 19 f0       	mov    0xf019d308,%eax
f0102387:	89 04 24             	mov    %eax,(%esp)
f010238a:	e8 01 ed ff ff       	call   f0101090 <page_insert>
	assert(pp1->pp_ref == 1);
f010238f:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102394:	74 24                	je     f01023ba <check_page_installed_pgdir+0x1b2>
f0102396:	c7 44 24 0c c3 61 10 	movl   $0xf01061c3,0xc(%esp)
f010239d:	f0 
f010239e:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f01023a5:	f0 
f01023a6:	c7 44 24 04 ac 04 00 	movl   $0x4ac,0x4(%esp)
f01023ad:	00 
f01023ae:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f01023b5:	e8 cb dc ff ff       	call   f0100085 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f01023ba:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f01023c1:	01 01 01 
f01023c4:	74 24                	je     f01023ea <check_page_installed_pgdir+0x1e2>
f01023c6:	c7 44 24 0c 9c 5d 10 	movl   $0xf0105d9c,0xc(%esp)
f01023cd:	f0 
f01023ce:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f01023d5:	f0 
f01023d6:	c7 44 24 04 ad 04 00 	movl   $0x4ad,0x4(%esp)
f01023dd:	00 
f01023de:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f01023e5:	e8 9b dc ff ff       	call   f0100085 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f01023ea:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01023f1:	00 
f01023f2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01023f9:	00 
f01023fa:	89 74 24 04          	mov    %esi,0x4(%esp)
f01023fe:	a1 08 d3 19 f0       	mov    0xf019d308,%eax
f0102403:	89 04 24             	mov    %eax,(%esp)
f0102406:	e8 85 ec ff ff       	call   f0101090 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f010240b:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102412:	02 02 02 
f0102415:	74 24                	je     f010243b <check_page_installed_pgdir+0x233>
f0102417:	c7 44 24 0c c0 5d 10 	movl   $0xf0105dc0,0xc(%esp)
f010241e:	f0 
f010241f:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0102426:	f0 
f0102427:	c7 44 24 04 af 04 00 	movl   $0x4af,0x4(%esp)
f010242e:	00 
f010242f:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0102436:	e8 4a dc ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 1);
f010243b:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102440:	74 24                	je     f0102466 <check_page_installed_pgdir+0x25e>
f0102442:	c7 44 24 0c e5 61 10 	movl   $0xf01061e5,0xc(%esp)
f0102449:	f0 
f010244a:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0102451:	f0 
f0102452:	c7 44 24 04 b0 04 00 	movl   $0x4b0,0x4(%esp)
f0102459:	00 
f010245a:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0102461:	e8 1f dc ff ff       	call   f0100085 <_panic>
	assert(pp1->pp_ref == 0);
f0102466:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f010246b:	74 24                	je     f0102491 <check_page_installed_pgdir+0x289>
f010246d:	c7 44 24 0c 2e 62 10 	movl   $0xf010622e,0xc(%esp)
f0102474:	f0 
f0102475:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f010247c:	f0 
f010247d:	c7 44 24 04 b1 04 00 	movl   $0x4b1,0x4(%esp)
f0102484:	00 
f0102485:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f010248c:	e8 f4 db ff ff       	call   f0100085 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102491:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102498:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f010249b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010249e:	2b 05 0c d3 19 f0    	sub    0xf019d30c,%eax
f01024a4:	c1 f8 03             	sar    $0x3,%eax
f01024a7:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01024aa:	89 c2                	mov    %eax,%edx
f01024ac:	c1 ea 0c             	shr    $0xc,%edx
f01024af:	3b 15 04 d3 19 f0    	cmp    0xf019d304,%edx
f01024b5:	72 20                	jb     f01024d7 <check_page_installed_pgdir+0x2cf>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01024b7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01024bb:	c7 44 24 08 c8 58 10 	movl   $0xf01058c8,0x8(%esp)
f01024c2:	f0 
f01024c3:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f01024ca:	00 
f01024cb:	c7 04 24 cb 60 10 f0 	movl   $0xf01060cb,(%esp)
f01024d2:	e8 ae db ff ff       	call   f0100085 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f01024d7:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f01024de:	03 03 03 
f01024e1:	74 24                	je     f0102507 <check_page_installed_pgdir+0x2ff>
f01024e3:	c7 44 24 0c e4 5d 10 	movl   $0xf0105de4,0xc(%esp)
f01024ea:	f0 
f01024eb:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f01024f2:	f0 
f01024f3:	c7 44 24 04 b3 04 00 	movl   $0x4b3,0x4(%esp)
f01024fa:	00 
f01024fb:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0102502:	e8 7e db ff ff       	call   f0100085 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102507:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010250e:	00 
f010250f:	a1 08 d3 19 f0       	mov    0xf019d308,%eax
f0102514:	89 04 24             	mov    %eax,(%esp)
f0102517:	e8 f7 ea ff ff       	call   f0101013 <page_remove>
	assert(pp2->pp_ref == 0);
f010251c:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102521:	74 24                	je     f0102547 <check_page_installed_pgdir+0x33f>
f0102523:	c7 44 24 0c 1d 62 10 	movl   $0xf010621d,0xc(%esp)
f010252a:	f0 
f010252b:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0102532:	f0 
f0102533:	c7 44 24 04 b5 04 00 	movl   $0x4b5,0x4(%esp)
f010253a:	00 
f010253b:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0102542:	e8 3e db ff ff       	call   f0100085 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102547:	a1 08 d3 19 f0       	mov    0xf019d308,%eax
f010254c:	8b 08                	mov    (%eax),%ecx
f010254e:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102554:	89 da                	mov    %ebx,%edx
f0102556:	2b 15 0c d3 19 f0    	sub    0xf019d30c,%edx
f010255c:	c1 fa 03             	sar    $0x3,%edx
f010255f:	c1 e2 0c             	shl    $0xc,%edx
f0102562:	39 d1                	cmp    %edx,%ecx
f0102564:	74 24                	je     f010258a <check_page_installed_pgdir+0x382>
f0102566:	c7 44 24 0c 88 5a 10 	movl   $0xf0105a88,0xc(%esp)
f010256d:	f0 
f010256e:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0102575:	f0 
f0102576:	c7 44 24 04 b8 04 00 	movl   $0x4b8,0x4(%esp)
f010257d:	00 
f010257e:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0102585:	e8 fb da ff ff       	call   f0100085 <_panic>
	kern_pgdir[0] = 0;
f010258a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102590:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102595:	74 24                	je     f01025bb <check_page_installed_pgdir+0x3b3>
f0102597:	c7 44 24 0c d4 61 10 	movl   $0xf01061d4,0xc(%esp)
f010259e:	f0 
f010259f:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f01025a6:	f0 
f01025a7:	c7 44 24 04 ba 04 00 	movl   $0x4ba,0x4(%esp)
f01025ae:	00 
f01025af:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f01025b6:	e8 ca da ff ff       	call   f0100085 <_panic>
	pp0->pp_ref = 0;
f01025bb:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f01025c1:	89 1c 24             	mov    %ebx,(%esp)
f01025c4:	e8 c3 e6 ff ff       	call   f0100c8c <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f01025c9:	c7 04 24 10 5e 10 f0 	movl   $0xf0105e10,(%esp)
f01025d0:	e8 46 16 00 00       	call   f0103c1b <cprintf>
}
f01025d5:	83 c4 2c             	add    $0x2c,%esp
f01025d8:	5b                   	pop    %ebx
f01025d9:	5e                   	pop    %esi
f01025da:	5f                   	pop    %edi
f01025db:	5d                   	pop    %ebp
f01025dc:	c3                   	ret    

f01025dd <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f01025dd:	55                   	push   %ebp
f01025de:	89 e5                	mov    %esp,%ebp
f01025e0:	57                   	push   %edi
f01025e1:	56                   	push   %esi
f01025e2:	53                   	push   %ebx
f01025e3:	83 ec 2c             	sub    $0x2c,%esp
	uint32_t cr0,cr4;
	size_t n;

	cprintf("\n\n\n\n\n\n********** Frank's lab2 test interval(start of mem_init) ***********\n\n\n\n\n\n\n\n\n\n");
f01025e6:	c7 04 24 3c 5e 10 f0 	movl   $0xf0105e3c,(%esp)
f01025ed:	e8 29 16 00 00       	call   f0103c1b <cprintf>
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f01025f2:	b8 15 00 00 00       	mov    $0x15,%eax
f01025f7:	e8 3a e7 ff ff       	call   f0100d36 <nvram_read>
f01025fc:	c1 e0 0a             	shl    $0xa,%eax
f01025ff:	89 c2                	mov    %eax,%edx
f0102601:	c1 fa 1f             	sar    $0x1f,%edx
f0102604:	c1 ea 14             	shr    $0x14,%edx
f0102607:	8d 04 02             	lea    (%edx,%eax,1),%eax
f010260a:	c1 f8 0c             	sar    $0xc,%eax
f010260d:	a3 4c c6 19 f0       	mov    %eax,0xf019c64c
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0102612:	b8 17 00 00 00       	mov    $0x17,%eax
f0102617:	e8 1a e7 ff ff       	call   f0100d36 <nvram_read>
f010261c:	c1 e0 0a             	shl    $0xa,%eax
f010261f:	89 c2                	mov    %eax,%edx
f0102621:	c1 fa 1f             	sar    $0x1f,%edx
f0102624:	c1 ea 14             	shr    $0x14,%edx
f0102627:	8d 04 02             	lea    (%edx,%eax,1),%eax
f010262a:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f010262d:	85 c0                	test   %eax,%eax
f010262f:	74 0e                	je     f010263f <mem_init+0x62>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0102631:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f0102637:	89 15 04 d3 19 f0    	mov    %edx,0xf019d304
f010263d:	eb 0c                	jmp    f010264b <mem_init+0x6e>
	else
		npages = npages_basemem;
f010263f:	8b 15 4c c6 19 f0    	mov    0xf019c64c,%edx
f0102645:	89 15 04 d3 19 f0    	mov    %edx,0xf019d304

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010264b:	c1 e0 0c             	shl    $0xc,%eax
f010264e:	c1 e8 0a             	shr    $0xa,%eax
f0102651:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102655:	a1 4c c6 19 f0       	mov    0xf019c64c,%eax
f010265a:	c1 e0 0c             	shl    $0xc,%eax
f010265d:	c1 e8 0a             	shr    $0xa,%eax
f0102660:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102664:	a1 04 d3 19 f0       	mov    0xf019d304,%eax
f0102669:	c1 e0 0c             	shl    $0xc,%eax
f010266c:	c1 e8 0a             	shr    $0xa,%eax
f010266f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102673:	c7 04 24 94 5e 10 f0 	movl   $0xf0105e94,(%esp)
f010267a:	e8 9c 15 00 00       	call   f0103c1b <cprintf>
	// Find out how much memory the machine has (npages & npages_basemem).
	i386_detect_memory();

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f010267f:	b8 00 10 00 00       	mov    $0x1000,%eax
f0102684:	e8 57 e4 ff ff       	call   f0100ae0 <boot_alloc>
f0102689:	a3 08 d3 19 f0       	mov    %eax,0xf019d308
	memset(kern_pgdir, 0, PGSIZE);
f010268e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102695:	00 
f0102696:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010269d:	00 
f010269e:	89 04 24             	mov    %eax,(%esp)
f01026a1:	e8 b0 27 00 00       	call   f0104e56 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following two lines.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;//Frank:don't understand!
f01026a6:	a1 08 d3 19 f0       	mov    0xf019d308,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01026ab:	89 c2                	mov    %eax,%edx
f01026ad:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01026b2:	77 20                	ja     f01026d4 <mem_init+0xf7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01026b4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01026b8:	c7 44 24 08 a4 58 10 	movl   $0xf01058a4,0x8(%esp)
f01026bf:	f0 
f01026c0:	c7 44 24 04 92 00 00 	movl   $0x92,0x4(%esp)
f01026c7:	00 
f01026c8:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f01026cf:	e8 b1 d9 ff ff       	call   f0100085 <_panic>
f01026d4:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f01026da:	83 ca 05             	or     $0x5,%edx
f01026dd:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.

//=======
	pages = (struct Page *)boot_alloc(npages * sizeof(struct Page));
f01026e3:	a1 04 d3 19 f0       	mov    0xf019d304,%eax
f01026e8:	c1 e0 03             	shl    $0x3,%eax
f01026eb:	e8 f0 e3 ff ff       	call   f0100ae0 <boot_alloc>
f01026f0:	a3 0c d3 19 f0       	mov    %eax,0xf019d30c
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f01026f5:	e8 1d e4 ff ff       	call   f0100b17 <page_init>
	check_page_free_list(1);
f01026fa:	b8 01 00 00 00       	mov    $0x1,%eax
f01026ff:	e8 6e ea ff ff       	call   f0101172 <check_page_free_list>
	int nfree;
	struct Page *fl;
	char *c;
	int i;

	if (!pages)
f0102704:	83 3d 0c d3 19 f0 00 	cmpl   $0x0,0xf019d30c
f010270b:	75 1c                	jne    f0102729 <mem_init+0x14c>
		panic("'pages' is a null pointer!");
f010270d:	c7 44 24 08 87 62 10 	movl   $0xf0106287,0x8(%esp)
f0102714:	f0 
f0102715:	c7 44 24 04 fa 02 00 	movl   $0x2fa,0x4(%esp)
f010271c:	00 
f010271d:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0102724:	e8 5c d9 ff ff       	call   f0100085 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0102729:	a1 50 c6 19 f0       	mov    0xf019c650,%eax
f010272e:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102733:	85 c0                	test   %eax,%eax
f0102735:	74 09                	je     f0102740 <mem_init+0x163>
		++nfree;
f0102737:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010273a:	8b 00                	mov    (%eax),%eax
f010273c:	85 c0                	test   %eax,%eax
f010273e:	75 f7                	jne    f0102737 <mem_init+0x15a>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102740:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102747:	e8 d5 e6 ff ff       	call   f0100e21 <page_alloc>
f010274c:	89 c6                	mov    %eax,%esi
f010274e:	85 c0                	test   %eax,%eax
f0102750:	75 24                	jne    f0102776 <mem_init+0x199>
f0102752:	c7 44 24 0c 60 61 10 	movl   $0xf0106160,0xc(%esp)
f0102759:	f0 
f010275a:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0102761:	f0 
f0102762:	c7 44 24 04 02 03 00 	movl   $0x302,0x4(%esp)
f0102769:	00 
f010276a:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0102771:	e8 0f d9 ff ff       	call   f0100085 <_panic>
	assert((pp1 = page_alloc(0)));
f0102776:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010277d:	e8 9f e6 ff ff       	call   f0100e21 <page_alloc>
f0102782:	89 c7                	mov    %eax,%edi
f0102784:	85 c0                	test   %eax,%eax
f0102786:	75 24                	jne    f01027ac <mem_init+0x1cf>
f0102788:	c7 44 24 0c 76 61 10 	movl   $0xf0106176,0xc(%esp)
f010278f:	f0 
f0102790:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0102797:	f0 
f0102798:	c7 44 24 04 03 03 00 	movl   $0x303,0x4(%esp)
f010279f:	00 
f01027a0:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f01027a7:	e8 d9 d8 ff ff       	call   f0100085 <_panic>
	assert((pp2 = page_alloc(0)));
f01027ac:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01027b3:	e8 69 e6 ff ff       	call   f0100e21 <page_alloc>
f01027b8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01027bb:	85 c0                	test   %eax,%eax
f01027bd:	75 24                	jne    f01027e3 <mem_init+0x206>
f01027bf:	c7 44 24 0c 8c 61 10 	movl   $0xf010618c,0xc(%esp)
f01027c6:	f0 
f01027c7:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f01027ce:	f0 
f01027cf:	c7 44 24 04 04 03 00 	movl   $0x304,0x4(%esp)
f01027d6:	00 
f01027d7:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f01027de:	e8 a2 d8 ff ff       	call   f0100085 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01027e3:	39 fe                	cmp    %edi,%esi
f01027e5:	75 24                	jne    f010280b <mem_init+0x22e>
f01027e7:	c7 44 24 0c a2 61 10 	movl   $0xf01061a2,0xc(%esp)
f01027ee:	f0 
f01027ef:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f01027f6:	f0 
f01027f7:	c7 44 24 04 07 03 00 	movl   $0x307,0x4(%esp)
f01027fe:	00 
f01027ff:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0102806:	e8 7a d8 ff ff       	call   f0100085 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010280b:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
f010280e:	74 05                	je     f0102815 <mem_init+0x238>
f0102810:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f0102813:	75 24                	jne    f0102839 <mem_init+0x25c>
f0102815:	c7 44 24 0c d0 59 10 	movl   $0xf01059d0,0xc(%esp)
f010281c:	f0 
f010281d:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0102824:	f0 
f0102825:	c7 44 24 04 08 03 00 	movl   $0x308,0x4(%esp)
f010282c:	00 
f010282d:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0102834:	e8 4c d8 ff ff       	call   f0100085 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0102839:	8b 15 0c d3 19 f0    	mov    0xf019d30c,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f010283f:	a1 04 d3 19 f0       	mov    0xf019d304,%eax
f0102844:	c1 e0 0c             	shl    $0xc,%eax
f0102847:	89 f1                	mov    %esi,%ecx
f0102849:	29 d1                	sub    %edx,%ecx
f010284b:	c1 f9 03             	sar    $0x3,%ecx
f010284e:	c1 e1 0c             	shl    $0xc,%ecx
f0102851:	39 c1                	cmp    %eax,%ecx
f0102853:	72 24                	jb     f0102879 <mem_init+0x29c>
f0102855:	c7 44 24 0c a2 62 10 	movl   $0xf01062a2,0xc(%esp)
f010285c:	f0 
f010285d:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0102864:	f0 
f0102865:	c7 44 24 04 09 03 00 	movl   $0x309,0x4(%esp)
f010286c:	00 
f010286d:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0102874:	e8 0c d8 ff ff       	call   f0100085 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0102879:	89 f9                	mov    %edi,%ecx
f010287b:	29 d1                	sub    %edx,%ecx
f010287d:	c1 f9 03             	sar    $0x3,%ecx
f0102880:	c1 e1 0c             	shl    $0xc,%ecx
f0102883:	39 c8                	cmp    %ecx,%eax
f0102885:	77 24                	ja     f01028ab <mem_init+0x2ce>
f0102887:	c7 44 24 0c bf 62 10 	movl   $0xf01062bf,0xc(%esp)
f010288e:	f0 
f010288f:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0102896:	f0 
f0102897:	c7 44 24 04 0a 03 00 	movl   $0x30a,0x4(%esp)
f010289e:	00 
f010289f:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f01028a6:	e8 da d7 ff ff       	call   f0100085 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f01028ab:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01028ae:	29 d1                	sub    %edx,%ecx
f01028b0:	89 ca                	mov    %ecx,%edx
f01028b2:	c1 fa 03             	sar    $0x3,%edx
f01028b5:	c1 e2 0c             	shl    $0xc,%edx
f01028b8:	39 d0                	cmp    %edx,%eax
f01028ba:	77 24                	ja     f01028e0 <mem_init+0x303>
f01028bc:	c7 44 24 0c dc 62 10 	movl   $0xf01062dc,0xc(%esp)
f01028c3:	f0 
f01028c4:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f01028cb:	f0 
f01028cc:	c7 44 24 04 0b 03 00 	movl   $0x30b,0x4(%esp)
f01028d3:	00 
f01028d4:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f01028db:	e8 a5 d7 ff ff       	call   f0100085 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01028e0:	a1 50 c6 19 f0       	mov    0xf019c650,%eax
f01028e5:	89 45 dc             	mov    %eax,-0x24(%ebp)
	page_free_list = 0;
f01028e8:	c7 05 50 c6 19 f0 00 	movl   $0x0,0xf019c650
f01028ef:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01028f2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01028f9:	e8 23 e5 ff ff       	call   f0100e21 <page_alloc>
f01028fe:	85 c0                	test   %eax,%eax
f0102900:	74 24                	je     f0102926 <mem_init+0x349>
f0102902:	c7 44 24 0c b4 61 10 	movl   $0xf01061b4,0xc(%esp)
f0102909:	f0 
f010290a:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0102911:	f0 
f0102912:	c7 44 24 04 12 03 00 	movl   $0x312,0x4(%esp)
f0102919:	00 
f010291a:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0102921:	e8 5f d7 ff ff       	call   f0100085 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0102926:	89 34 24             	mov    %esi,(%esp)
f0102929:	e8 5e e3 ff ff       	call   f0100c8c <page_free>
	page_free(pp1);
f010292e:	89 3c 24             	mov    %edi,(%esp)
f0102931:	e8 56 e3 ff ff       	call   f0100c8c <page_free>
	page_free(pp2);
f0102936:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0102939:	89 14 24             	mov    %edx,(%esp)
f010293c:	e8 4b e3 ff ff       	call   f0100c8c <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102941:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102948:	e8 d4 e4 ff ff       	call   f0100e21 <page_alloc>
f010294d:	89 c6                	mov    %eax,%esi
f010294f:	85 c0                	test   %eax,%eax
f0102951:	75 24                	jne    f0102977 <mem_init+0x39a>
f0102953:	c7 44 24 0c 60 61 10 	movl   $0xf0106160,0xc(%esp)
f010295a:	f0 
f010295b:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0102962:	f0 
f0102963:	c7 44 24 04 19 03 00 	movl   $0x319,0x4(%esp)
f010296a:	00 
f010296b:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0102972:	e8 0e d7 ff ff       	call   f0100085 <_panic>
	assert((pp1 = page_alloc(0)));
f0102977:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010297e:	e8 9e e4 ff ff       	call   f0100e21 <page_alloc>
f0102983:	89 c7                	mov    %eax,%edi
f0102985:	85 c0                	test   %eax,%eax
f0102987:	75 24                	jne    f01029ad <mem_init+0x3d0>
f0102989:	c7 44 24 0c 76 61 10 	movl   $0xf0106176,0xc(%esp)
f0102990:	f0 
f0102991:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0102998:	f0 
f0102999:	c7 44 24 04 1a 03 00 	movl   $0x31a,0x4(%esp)
f01029a0:	00 
f01029a1:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f01029a8:	e8 d8 d6 ff ff       	call   f0100085 <_panic>
	assert((pp2 = page_alloc(0)));
f01029ad:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01029b4:	e8 68 e4 ff ff       	call   f0100e21 <page_alloc>
f01029b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01029bc:	85 c0                	test   %eax,%eax
f01029be:	75 24                	jne    f01029e4 <mem_init+0x407>
f01029c0:	c7 44 24 0c 8c 61 10 	movl   $0xf010618c,0xc(%esp)
f01029c7:	f0 
f01029c8:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f01029cf:	f0 
f01029d0:	c7 44 24 04 1b 03 00 	movl   $0x31b,0x4(%esp)
f01029d7:	00 
f01029d8:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f01029df:	e8 a1 d6 ff ff       	call   f0100085 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01029e4:	39 fe                	cmp    %edi,%esi
f01029e6:	75 24                	jne    f0102a0c <mem_init+0x42f>
f01029e8:	c7 44 24 0c a2 61 10 	movl   $0xf01061a2,0xc(%esp)
f01029ef:	f0 
f01029f0:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f01029f7:	f0 
f01029f8:	c7 44 24 04 1d 03 00 	movl   $0x31d,0x4(%esp)
f01029ff:	00 
f0102a00:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0102a07:	e8 79 d6 ff ff       	call   f0100085 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102a0c:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
f0102a0f:	74 05                	je     f0102a16 <mem_init+0x439>
f0102a11:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f0102a14:	75 24                	jne    f0102a3a <mem_init+0x45d>
f0102a16:	c7 44 24 0c d0 59 10 	movl   $0xf01059d0,0xc(%esp)
f0102a1d:	f0 
f0102a1e:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0102a25:	f0 
f0102a26:	c7 44 24 04 1e 03 00 	movl   $0x31e,0x4(%esp)
f0102a2d:	00 
f0102a2e:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0102a35:	e8 4b d6 ff ff       	call   f0100085 <_panic>
	assert(!page_alloc(0));
f0102a3a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102a41:	e8 db e3 ff ff       	call   f0100e21 <page_alloc>
f0102a46:	85 c0                	test   %eax,%eax
f0102a48:	74 24                	je     f0102a6e <mem_init+0x491>
f0102a4a:	c7 44 24 0c b4 61 10 	movl   $0xf01061b4,0xc(%esp)
f0102a51:	f0 
f0102a52:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0102a59:	f0 
f0102a5a:	c7 44 24 04 1f 03 00 	movl   $0x31f,0x4(%esp)
f0102a61:	00 
f0102a62:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0102a69:	e8 17 d6 ff ff       	call   f0100085 <_panic>
f0102a6e:	89 75 e0             	mov    %esi,-0x20(%ebp)
f0102a71:	89 f0                	mov    %esi,%eax
f0102a73:	2b 05 0c d3 19 f0    	sub    0xf019d30c,%eax
f0102a79:	c1 f8 03             	sar    $0x3,%eax
f0102a7c:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102a7f:	89 c2                	mov    %eax,%edx
f0102a81:	c1 ea 0c             	shr    $0xc,%edx
f0102a84:	3b 15 04 d3 19 f0    	cmp    0xf019d304,%edx
f0102a8a:	72 20                	jb     f0102aac <mem_init+0x4cf>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102a8c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102a90:	c7 44 24 08 c8 58 10 	movl   $0xf01058c8,0x8(%esp)
f0102a97:	f0 
f0102a98:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0102a9f:	00 
f0102aa0:	c7 04 24 cb 60 10 f0 	movl   $0xf01060cb,(%esp)
f0102aa7:	e8 d9 d5 ff ff       	call   f0100085 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0102aac:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102ab3:	00 
f0102ab4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0102abb:	00 
f0102abc:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102ac1:	89 04 24             	mov    %eax,(%esp)
f0102ac4:	e8 8d 23 00 00       	call   f0104e56 <memset>
	page_free(pp0);
f0102ac9:	89 34 24             	mov    %esi,(%esp)
f0102acc:	e8 bb e1 ff ff       	call   f0100c8c <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0102ad1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0102ad8:	e8 44 e3 ff ff       	call   f0100e21 <page_alloc>
f0102add:	85 c0                	test   %eax,%eax
f0102adf:	75 24                	jne    f0102b05 <mem_init+0x528>
f0102ae1:	c7 44 24 0c f9 62 10 	movl   $0xf01062f9,0xc(%esp)
f0102ae8:	f0 
f0102ae9:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0102af0:	f0 
f0102af1:	c7 44 24 04 24 03 00 	movl   $0x324,0x4(%esp)
f0102af8:	00 
f0102af9:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0102b00:	e8 80 d5 ff ff       	call   f0100085 <_panic>
	assert(pp && pp0 == pp);
f0102b05:	39 c6                	cmp    %eax,%esi
f0102b07:	74 24                	je     f0102b2d <mem_init+0x550>
f0102b09:	c7 44 24 0c 17 63 10 	movl   $0xf0106317,0xc(%esp)
f0102b10:	f0 
f0102b11:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0102b18:	f0 
f0102b19:	c7 44 24 04 25 03 00 	movl   $0x325,0x4(%esp)
f0102b20:	00 
f0102b21:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0102b28:	e8 58 d5 ff ff       	call   f0100085 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0102b2d:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0102b30:	2b 15 0c d3 19 f0    	sub    0xf019d30c,%edx
f0102b36:	c1 fa 03             	sar    $0x3,%edx
f0102b39:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102b3c:	89 d0                	mov    %edx,%eax
f0102b3e:	c1 e8 0c             	shr    $0xc,%eax
f0102b41:	3b 05 04 d3 19 f0    	cmp    0xf019d304,%eax
f0102b47:	72 20                	jb     f0102b69 <mem_init+0x58c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102b49:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102b4d:	c7 44 24 08 c8 58 10 	movl   $0xf01058c8,0x8(%esp)
f0102b54:	f0 
f0102b55:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0102b5c:	00 
f0102b5d:	c7 04 24 cb 60 10 f0 	movl   $0xf01060cb,(%esp)
f0102b64:	e8 1c d5 ff ff       	call   f0100085 <_panic>
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0102b69:	80 ba 00 00 00 f0 00 	cmpb   $0x0,-0x10000000(%edx)
f0102b70:	75 11                	jne    f0102b83 <mem_init+0x5a6>
f0102b72:	8d 82 01 00 00 f0    	lea    -0xfffffff(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102b78:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0102b7e:	80 38 00             	cmpb   $0x0,(%eax)
f0102b81:	74 24                	je     f0102ba7 <mem_init+0x5ca>
f0102b83:	c7 44 24 0c 27 63 10 	movl   $0xf0106327,0xc(%esp)
f0102b8a:	f0 
f0102b8b:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0102b92:	f0 
f0102b93:	c7 44 24 04 28 03 00 	movl   $0x328,0x4(%esp)
f0102b9a:	00 
f0102b9b:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0102ba2:	e8 de d4 ff ff       	call   f0100085 <_panic>
f0102ba7:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0102baa:	39 d0                	cmp    %edx,%eax
f0102bac:	75 d0                	jne    f0102b7e <mem_init+0x5a1>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0102bae:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0102bb1:	89 0d 50 c6 19 f0    	mov    %ecx,0xf019c650

	// free the pages we took
	page_free(pp0);
f0102bb7:	89 34 24             	mov    %esi,(%esp)
f0102bba:	e8 cd e0 ff ff       	call   f0100c8c <page_free>
	page_free(pp1);
f0102bbf:	89 3c 24             	mov    %edi,(%esp)
f0102bc2:	e8 c5 e0 ff ff       	call   f0100c8c <page_free>
	page_free(pp2);
f0102bc7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102bca:	89 04 24             	mov    %eax,(%esp)
f0102bcd:	e8 ba e0 ff ff       	call   f0100c8c <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0102bd2:	a1 50 c6 19 f0       	mov    0xf019c650,%eax
f0102bd7:	85 c0                	test   %eax,%eax
f0102bd9:	74 09                	je     f0102be4 <mem_init+0x607>
		--nfree;
f0102bdb:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0102bde:	8b 00                	mov    (%eax),%eax
f0102be0:	85 c0                	test   %eax,%eax
f0102be2:	75 f7                	jne    f0102bdb <mem_init+0x5fe>
		--nfree;
	assert(nfree == 0);
f0102be4:	85 db                	test   %ebx,%ebx
f0102be6:	74 24                	je     f0102c0c <mem_init+0x62f>
f0102be8:	c7 44 24 0c 31 63 10 	movl   $0xf0106331,0xc(%esp)
f0102bef:	f0 
f0102bf0:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0102bf7:	f0 
f0102bf8:	c7 44 24 04 35 03 00 	movl   $0x335,0x4(%esp)
f0102bff:	00 
f0102c00:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0102c07:	e8 79 d4 ff ff       	call   f0100085 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0102c0c:	c7 04 24 d0 5e 10 f0 	movl   $0xf0105ed0,(%esp)
f0102c13:	e8 03 10 00 00       	call   f0103c1b <cprintf>
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
	check_page_free_list(1);
	check_page_alloc();
	check_page();
f0102c18:	e8 c9 e8 ff ff       	call   f01014e6 <check_page>
	char* addr;
	int i;
	pp = pp0 = 0;
	
	// Allocate two single pages
	pp =  page_alloc(0);
f0102c1d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102c24:	e8 f8 e1 ff ff       	call   f0100e21 <page_alloc>
f0102c29:	89 c3                	mov    %eax,%ebx
	pp0 = page_alloc(0);
f0102c2b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102c32:	e8 ea e1 ff ff       	call   f0100e21 <page_alloc>
f0102c37:	89 c6                	mov    %eax,%esi
	assert(pp != 0);
f0102c39:	85 db                	test   %ebx,%ebx
f0102c3b:	75 24                	jne    f0102c61 <mem_init+0x684>
f0102c3d:	c7 44 24 0c 3c 63 10 	movl   $0xf010633c,0xc(%esp)
f0102c44:	f0 
f0102c45:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0102c4c:	f0 
f0102c4d:	c7 44 24 04 4a 04 00 	movl   $0x44a,0x4(%esp)
f0102c54:	00 
f0102c55:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0102c5c:	e8 24 d4 ff ff       	call   f0100085 <_panic>
	assert(pp0 != 0);
f0102c61:	85 c0                	test   %eax,%eax
f0102c63:	75 24                	jne    f0102c89 <mem_init+0x6ac>
f0102c65:	c7 44 24 0c 44 63 10 	movl   $0xf0106344,0xc(%esp)
f0102c6c:	f0 
f0102c6d:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0102c74:	f0 
f0102c75:	c7 44 24 04 4b 04 00 	movl   $0x44b,0x4(%esp)
f0102c7c:	00 
f0102c7d:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0102c84:	e8 fc d3 ff ff       	call   f0100085 <_panic>
	assert(pp != pp0);
f0102c89:	39 c3                	cmp    %eax,%ebx
f0102c8b:	75 24                	jne    f0102cb1 <mem_init+0x6d4>
f0102c8d:	c7 44 24 0c 4d 63 10 	movl   $0xf010634d,0xc(%esp)
f0102c94:	f0 
f0102c95:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0102c9c:	f0 
f0102c9d:	c7 44 24 04 4c 04 00 	movl   $0x44c,0x4(%esp)
f0102ca4:	00 
f0102ca5:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0102cac:	e8 d4 d3 ff ff       	call   f0100085 <_panic>

	
	// Free pp and assign four continuous pages
	page_free(pp);
f0102cb1:	89 1c 24             	mov    %ebx,(%esp)
f0102cb4:	e8 d3 df ff ff       	call   f0100c8c <page_free>
	pp = page_alloc_npages(0, 4);
f0102cb9:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
f0102cc0:	00 
f0102cc1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102cc8:	e8 ea de ff ff       	call   f0100bb7 <page_alloc_npages>
f0102ccd:	89 c3                	mov    %eax,%ebx
	assert(check_continuous(pp, 4));
f0102ccf:	ba 04 00 00 00       	mov    $0x4,%edx
f0102cd4:	e8 3d df ff ff       	call   f0100c16 <check_continuous>
f0102cd9:	85 c0                	test   %eax,%eax
f0102cdb:	75 24                	jne    f0102d01 <mem_init+0x724>
f0102cdd:	c7 44 24 0c 57 63 10 	movl   $0xf0106357,0xc(%esp)
f0102ce4:	f0 
f0102ce5:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0102cec:	f0 
f0102ced:	c7 44 24 04 52 04 00 	movl   $0x452,0x4(%esp)
f0102cf4:	00 
f0102cf5:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0102cfc:	e8 84 d3 ff ff       	call   f0100085 <_panic>

	// Free four continuous pages
	assert(!page_free_npages(pp, 4));
f0102d01:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
f0102d08:	00 
f0102d09:	89 1c 24             	mov    %ebx,(%esp)
f0102d0c:	e8 b0 de ff ff       	call   f0100bc1 <page_free_npages>
f0102d11:	85 c0                	test   %eax,%eax
f0102d13:	74 24                	je     f0102d39 <mem_init+0x75c>
f0102d15:	c7 44 24 0c 6f 63 10 	movl   $0xf010636f,0xc(%esp)
f0102d1c:	f0 
f0102d1d:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0102d24:	f0 
f0102d25:	c7 44 24 04 55 04 00 	movl   $0x455,0x4(%esp)
f0102d2c:	00 
f0102d2d:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0102d34:	e8 4c d3 ff ff       	call   f0100085 <_panic>

	// Free pp and assign eight continuous pages
	pp = page_alloc_npages(0, 8);
f0102d39:	c7 44 24 04 08 00 00 	movl   $0x8,0x4(%esp)
f0102d40:	00 
f0102d41:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102d48:	e8 6a de ff ff       	call   f0100bb7 <page_alloc_npages>
f0102d4d:	89 c3                	mov    %eax,%ebx
	assert(check_continuous(pp, 8));
f0102d4f:	ba 08 00 00 00       	mov    $0x8,%edx
f0102d54:	e8 bd de ff ff       	call   f0100c16 <check_continuous>
f0102d59:	85 c0                	test   %eax,%eax
f0102d5b:	75 24                	jne    f0102d81 <mem_init+0x7a4>
f0102d5d:	c7 44 24 0c 88 63 10 	movl   $0xf0106388,0xc(%esp)
f0102d64:	f0 
f0102d65:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0102d6c:	f0 
f0102d6d:	c7 44 24 04 59 04 00 	movl   $0x459,0x4(%esp)
f0102d74:	00 
f0102d75:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0102d7c:	e8 04 d3 ff ff       	call   f0100085 <_panic>

	// Free four continuous pages
	assert(!page_free_npages(pp, 8));
f0102d81:	c7 44 24 04 08 00 00 	movl   $0x8,0x4(%esp)
f0102d88:	00 
f0102d89:	89 1c 24             	mov    %ebx,(%esp)
f0102d8c:	e8 30 de ff ff       	call   f0100bc1 <page_free_npages>
f0102d91:	85 c0                	test   %eax,%eax
f0102d93:	74 24                	je     f0102db9 <mem_init+0x7dc>
f0102d95:	c7 44 24 0c a0 63 10 	movl   $0xf01063a0,0xc(%esp)
f0102d9c:	f0 
f0102d9d:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0102da4:	f0 
f0102da5:	c7 44 24 04 5c 04 00 	movl   $0x45c,0x4(%esp)
f0102dac:	00 
f0102dad:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0102db4:	e8 cc d2 ff ff       	call   f0100085 <_panic>


	// Free pp0 and assign four continuous zero pages
	page_free(pp0);
f0102db9:	89 34 24             	mov    %esi,(%esp)
f0102dbc:	e8 cb de ff ff       	call   f0100c8c <page_free>
	pp0 = page_alloc_npages(ALLOC_ZERO, 4);
f0102dc1:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
f0102dc8:	00 
f0102dc9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0102dd0:	e8 e2 dd ff ff       	call   f0100bb7 <page_alloc_npages>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0102dd5:	89 c1                	mov    %eax,%ecx
f0102dd7:	2b 0d 0c d3 19 f0    	sub    0xf019d30c,%ecx
f0102ddd:	c1 f9 03             	sar    $0x3,%ecx
f0102de0:	c1 e1 0c             	shl    $0xc,%ecx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102de3:	89 ca                	mov    %ecx,%edx
f0102de5:	c1 ea 0c             	shr    $0xc,%edx
f0102de8:	3b 15 04 d3 19 f0    	cmp    0xf019d304,%edx
f0102dee:	72 20                	jb     f0102e10 <mem_init+0x833>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102df0:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0102df4:	c7 44 24 08 c8 58 10 	movl   $0xf01058c8,0x8(%esp)
f0102dfb:	f0 
f0102dfc:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0102e03:	00 
f0102e04:	c7 04 24 cb 60 10 f0 	movl   $0xf01060cb,(%esp)
f0102e0b:	e8 75 d2 ff ff       	call   f0100085 <_panic>
	addr = (char*)page2kva(pp0);
	
	// Check Zero
	for( i = 0; i < 4 * PGSIZE; i++ ){
		assert(addr[i] == 0);
f0102e10:	80 b9 00 00 00 f0 00 	cmpb   $0x0,-0x10000000(%ecx)
f0102e17:	75 11                	jne    f0102e2a <mem_init+0x84d>
f0102e19:	8d 91 01 00 00 f0    	lea    -0xfffffff(%ecx),%edx
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102e1f:	81 e9 00 c0 ff 0f    	sub    $0xfffc000,%ecx
	pp0 = page_alloc_npages(ALLOC_ZERO, 4);
	addr = (char*)page2kva(pp0);
	
	// Check Zero
	for( i = 0; i < 4 * PGSIZE; i++ ){
		assert(addr[i] == 0);
f0102e25:	80 3a 00             	cmpb   $0x0,(%edx)
f0102e28:	74 24                	je     f0102e4e <mem_init+0x871>
f0102e2a:	c7 44 24 0c b9 63 10 	movl   $0xf01063b9,0xc(%esp)
f0102e31:	f0 
f0102e32:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0102e39:	f0 
f0102e3a:	c7 44 24 04 66 04 00 	movl   $0x466,0x4(%esp)
f0102e41:	00 
f0102e42:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0102e49:	e8 37 d2 ff ff       	call   f0100085 <_panic>
f0102e4e:	83 c2 01             	add    $0x1,%edx
	page_free(pp0);
	pp0 = page_alloc_npages(ALLOC_ZERO, 4);
	addr = (char*)page2kva(pp0);
	
	// Check Zero
	for( i = 0; i < 4 * PGSIZE; i++ ){
f0102e51:	39 ca                	cmp    %ecx,%edx
f0102e53:	75 d0                	jne    f0102e25 <mem_init+0x848>
		assert(addr[i] == 0);
	}

	// Free pages
	assert(!page_free_npages(pp0, 4));
f0102e55:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
f0102e5c:	00 
f0102e5d:	89 04 24             	mov    %eax,(%esp)
f0102e60:	e8 5c dd ff ff       	call   f0100bc1 <page_free_npages>
f0102e65:	85 c0                	test   %eax,%eax
f0102e67:	74 24                	je     f0102e8d <mem_init+0x8b0>
f0102e69:	c7 44 24 0c c6 63 10 	movl   $0xf01063c6,0xc(%esp)
f0102e70:	f0 
f0102e71:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0102e78:	f0 
f0102e79:	c7 44 24 04 6a 04 00 	movl   $0x46a,0x4(%esp)
f0102e80:	00 
f0102e81:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0102e88:	e8 f8 d1 ff ff       	call   f0100085 <_panic>
	cprintf("check_n_pages() succeeded!\n");
f0102e8d:	c7 04 24 e0 63 10 f0 	movl   $0xf01063e0,(%esp)
f0102e94:	e8 82 0d 00 00       	call   f0103c1b <cprintf>
	char* addr;
	int i;
	pp = pp0 = 0;

	// Allocate two single pages
	pp =  page_alloc(0);
f0102e99:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102ea0:	e8 7c df ff ff       	call   f0100e21 <page_alloc>
f0102ea5:	89 c6                	mov    %eax,%esi
	pp0 = page_alloc(0);
f0102ea7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102eae:	e8 6e df ff ff       	call   f0100e21 <page_alloc>
f0102eb3:	89 c7                	mov    %eax,%edi
	assert(pp != 0);
f0102eb5:	85 f6                	test   %esi,%esi
f0102eb7:	75 24                	jne    f0102edd <mem_init+0x900>
f0102eb9:	c7 44 24 0c 3c 63 10 	movl   $0xf010633c,0xc(%esp)
f0102ec0:	f0 
f0102ec1:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0102ec8:	f0 
f0102ec9:	c7 44 24 04 79 04 00 	movl   $0x479,0x4(%esp)
f0102ed0:	00 
f0102ed1:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0102ed8:	e8 a8 d1 ff ff       	call   f0100085 <_panic>
	assert(pp0 != 0);
f0102edd:	85 c0                	test   %eax,%eax
f0102edf:	75 24                	jne    f0102f05 <mem_init+0x928>
f0102ee1:	c7 44 24 0c 44 63 10 	movl   $0xf0106344,0xc(%esp)
f0102ee8:	f0 
f0102ee9:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0102ef0:	f0 
f0102ef1:	c7 44 24 04 7a 04 00 	movl   $0x47a,0x4(%esp)
f0102ef8:	00 
f0102ef9:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0102f00:	e8 80 d1 ff ff       	call   f0100085 <_panic>
	assert(pp != pp0);
f0102f05:	39 c6                	cmp    %eax,%esi
f0102f07:	75 24                	jne    f0102f2d <mem_init+0x950>
f0102f09:	c7 44 24 0c 4d 63 10 	movl   $0xf010634d,0xc(%esp)
f0102f10:	f0 
f0102f11:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0102f18:	f0 
f0102f19:	c7 44 24 04 7b 04 00 	movl   $0x47b,0x4(%esp)
f0102f20:	00 
f0102f21:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0102f28:	e8 58 d1 ff ff       	call   f0100085 <_panic>

	// Free pp and pp0
	page_free(pp);
f0102f2d:	89 34 24             	mov    %esi,(%esp)
f0102f30:	e8 57 dd ff ff       	call   f0100c8c <page_free>
	page_free(pp0);
f0102f35:	89 3c 24             	mov    %edi,(%esp)
f0102f38:	e8 4f dd ff ff       	call   f0100c8c <page_free>

	// Assign eight continuous pages
	pp = page_alloc_npages(0, 8);
	assert(check_continuous(pp, 8));
f0102f3d:	ba 08 00 00 00       	mov    $0x8,%edx
f0102f42:	89 d8                	mov    %ebx,%eax
f0102f44:	e8 cd dc ff ff       	call   f0100c16 <check_continuous>
f0102f49:	85 c0                	test   %eax,%eax
f0102f4b:	75 24                	jne    f0102f71 <mem_init+0x994>
f0102f4d:	c7 44 24 0c 88 63 10 	movl   $0xf0106388,0xc(%esp)
f0102f54:	f0 
f0102f55:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0102f5c:	f0 
f0102f5d:	c7 44 24 04 83 04 00 	movl   $0x483,0x4(%esp)
f0102f64:	00 
f0102f65:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0102f6c:	e8 14 d1 ff ff       	call   f0100085 <_panic>

	// Realloc to 4 pages
	pp0 = page_realloc_npages(pp, 8, 4);
f0102f71:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0102f78:	00 
f0102f79:	c7 44 24 04 08 00 00 	movl   $0x8,0x4(%esp)
f0102f80:	00 
f0102f81:	89 1c 24             	mov    %ebx,(%esp)
f0102f84:	e8 42 dc ff ff       	call   f0100bcb <page_realloc_npages>
	assert(pp0 == pp);
f0102f89:	39 c3                	cmp    %eax,%ebx
f0102f8b:	74 24                	je     f0102fb1 <mem_init+0x9d4>
f0102f8d:	c7 44 24 0c 1d 63 10 	movl   $0xf010631d,0xc(%esp)
f0102f94:	f0 
f0102f95:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0102f9c:	f0 
f0102f9d:	c7 44 24 04 87 04 00 	movl   $0x487,0x4(%esp)
f0102fa4:	00 
f0102fa5:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0102fac:	e8 d4 d0 ff ff       	call   f0100085 <_panic>
	assert(check_continuous(pp, 4));
f0102fb1:	ba 04 00 00 00       	mov    $0x4,%edx
f0102fb6:	89 d8                	mov    %ebx,%eax
f0102fb8:	e8 59 dc ff ff       	call   f0100c16 <check_continuous>
f0102fbd:	85 c0                	test   %eax,%eax
f0102fbf:	75 24                	jne    f0102fe5 <mem_init+0xa08>
f0102fc1:	c7 44 24 0c 57 63 10 	movl   $0xf0106357,0xc(%esp)
f0102fc8:	f0 
f0102fc9:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0102fd0:	f0 
f0102fd1:	c7 44 24 04 88 04 00 	movl   $0x488,0x4(%esp)
f0102fd8:	00 
f0102fd9:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0102fe0:	e8 a0 d0 ff ff       	call   f0100085 <_panic>

	// Realloc to 6 pages
	pp0 = page_realloc_npages(pp, 4, 6);
f0102fe5:	c7 44 24 08 06 00 00 	movl   $0x6,0x8(%esp)
f0102fec:	00 
f0102fed:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
f0102ff4:	00 
f0102ff5:	89 1c 24             	mov    %ebx,(%esp)
f0102ff8:	e8 ce db ff ff       	call   f0100bcb <page_realloc_npages>
	assert(pp0 == pp);
f0102ffd:	39 c3                	cmp    %eax,%ebx
f0102fff:	74 24                	je     f0103025 <mem_init+0xa48>
f0103001:	c7 44 24 0c 1d 63 10 	movl   $0xf010631d,0xc(%esp)
f0103008:	f0 
f0103009:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0103010:	f0 
f0103011:	c7 44 24 04 8c 04 00 	movl   $0x48c,0x4(%esp)
f0103018:	00 
f0103019:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0103020:	e8 60 d0 ff ff       	call   f0100085 <_panic>
	assert(check_continuous(pp, 6));
f0103025:	ba 06 00 00 00       	mov    $0x6,%edx
f010302a:	89 d8                	mov    %ebx,%eax
f010302c:	e8 e5 db ff ff       	call   f0100c16 <check_continuous>
f0103031:	85 c0                	test   %eax,%eax
f0103033:	75 24                	jne    f0103059 <mem_init+0xa7c>
f0103035:	c7 44 24 0c fc 63 10 	movl   $0xf01063fc,0xc(%esp)
f010303c:	f0 
f010303d:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0103044:	f0 
f0103045:	c7 44 24 04 8d 04 00 	movl   $0x48d,0x4(%esp)
f010304c:	00 
f010304d:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0103054:	e8 2c d0 ff ff       	call   f0100085 <_panic>

	// Realloc to 12 pages
	pp0 = page_realloc_npages(pp, 6, 12);
f0103059:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
f0103060:	00 
f0103061:	c7 44 24 04 06 00 00 	movl   $0x6,0x4(%esp)
f0103068:	00 
f0103069:	89 1c 24             	mov    %ebx,(%esp)
f010306c:	e8 5a db ff ff       	call   f0100bcb <page_realloc_npages>
f0103071:	89 c3                	mov    %eax,%ebx
	assert(check_continuous(pp0, 12));
f0103073:	ba 0c 00 00 00       	mov    $0xc,%edx
f0103078:	e8 99 db ff ff       	call   f0100c16 <check_continuous>
f010307d:	85 c0                	test   %eax,%eax
f010307f:	75 24                	jne    f01030a5 <mem_init+0xac8>
f0103081:	c7 44 24 0c 14 64 10 	movl   $0xf0106414,0xc(%esp)
f0103088:	f0 
f0103089:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0103090:	f0 
f0103091:	c7 44 24 04 91 04 00 	movl   $0x491,0x4(%esp)
f0103098:	00 
f0103099:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f01030a0:	e8 e0 cf ff ff       	call   f0100085 <_panic>

	// Free 12 continuous pages
	assert(!page_free_npages(pp0, 12));
f01030a5:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
f01030ac:	00 
f01030ad:	89 1c 24             	mov    %ebx,(%esp)
f01030b0:	e8 0c db ff ff       	call   f0100bc1 <page_free_npages>
f01030b5:	85 c0                	test   %eax,%eax
f01030b7:	74 24                	je     f01030dd <mem_init+0xb00>
f01030b9:	c7 44 24 0c 2e 64 10 	movl   $0xf010642e,0xc(%esp)
f01030c0:	f0 
f01030c1:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f01030c8:	f0 
f01030c9:	c7 44 24 04 94 04 00 	movl   $0x494,0x4(%esp)
f01030d0:	00 
f01030d1:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f01030d8:	e8 a8 cf ff ff       	call   f0100085 <_panic>

	cprintf("check_realloc_npages() succeeded!\n");
f01030dd:	c7 04 24 f0 5e 10 f0 	movl   $0xf0105ef0,(%esp)
f01030e4:	e8 32 0b 00 00       	call   f0103c1b <cprintf>
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	size_t i;
	for(i=0;i<ROUNDUP(npages*sizeof(struct Page),PGSIZE)/PGSIZE;i++){
f01030e9:	a1 04 d3 19 f0       	mov    0xf019d304,%eax
f01030ee:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f01030f5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01030fa:	3d ff 0f 00 00       	cmp    $0xfff,%eax
f01030ff:	0f 86 e8 00 00 00    	jbe    f01031ed <mem_init+0xc10>
f0103105:	bb 00 00 00 ef       	mov    $0xef000000,%ebx
f010310a:	be 00 00 00 00       	mov    $0x0,%esi
f010310f:	89 f2                	mov    %esi,%edx
f0103111:	c1 e2 0c             	shl    $0xc,%edx
f0103114:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		if(PTE_ADDR(*pgdir_walk(kern_pgdir,(void*)UPAGES+i*PGSIZE,1)) != 0){
f0103117:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010311e:	00 
f010311f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103123:	a1 08 d3 19 f0       	mov    0xf019d308,%eax
f0103128:	89 04 24             	mov    %eax,(%esp)
f010312b:	e8 75 dd ff ff       	call   f0100ea5 <pgdir_walk>
f0103130:	f7 00 00 f0 ff ff    	testl  $0xfffff000,(%eax)
f0103136:	74 15                	je     f010314d <mem_init+0xb70>
			cprintf("Frank attention! page (%08x) has been allocated\n",UPAGES + i*PGSIZE);
f0103138:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010313c:	c7 04 24 14 5f 10 f0 	movl   $0xf0105f14,(%esp)
f0103143:	e8 d3 0a 00 00       	call   f0103c1b <cprintf>
			continue;
f0103148:	e9 80 00 00 00       	jmp    f01031cd <mem_init+0xbf0>
		}
		page_insert(kern_pgdir,pa2page(PADDR(pages+i*PGSIZE/sizeof(*pages))),(void*)UPAGES+i*PGSIZE,PTE_U);
f010314d:	8b 15 0c d3 19 f0    	mov    0xf019d30c,%edx
f0103153:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0103156:	8d 04 0a             	lea    (%edx,%ecx,1),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103159:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010315e:	77 20                	ja     f0103180 <mem_init+0xba3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103160:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103164:	c7 44 24 08 a4 58 10 	movl   $0xf01058a4,0x8(%esp)
f010316b:	f0 
f010316c:	c7 44 24 04 c1 00 00 	movl   $0xc1,0x4(%esp)
f0103173:	00 
f0103174:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f010317b:	e8 05 cf ff ff       	call   f0100085 <_panic>
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103180:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f0103186:	c1 e8 0c             	shr    $0xc,%eax
f0103189:	3b 05 04 d3 19 f0    	cmp    0xf019d304,%eax
f010318f:	72 1c                	jb     f01031ad <mem_init+0xbd0>
		panic("pa2page called with invalid pa");
f0103191:	c7 44 24 08 ec 58 10 	movl   $0xf01058ec,0x8(%esp)
f0103198:	f0 
f0103199:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f01031a0:	00 
f01031a1:	c7 04 24 cb 60 10 f0 	movl   $0xf01060cb,(%esp)
f01031a8:	e8 d8 ce ff ff       	call   f0100085 <_panic>
f01031ad:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f01031b4:	00 
f01031b5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01031b9:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f01031bc:	89 44 24 04          	mov    %eax,0x4(%esp)
f01031c0:	a1 08 d3 19 f0       	mov    0xf019d308,%eax
f01031c5:	89 04 24             	mov    %eax,(%esp)
f01031c8:	e8 c3 de ff ff       	call   f0101090 <page_insert>
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	size_t i;
	for(i=0;i<ROUNDUP(npages*sizeof(struct Page),PGSIZE)/PGSIZE;i++){
f01031cd:	83 c6 01             	add    $0x1,%esi
f01031d0:	a1 04 d3 19 f0       	mov    0xf019d304,%eax
f01031d5:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f01031dc:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01031e2:	c1 e8 0c             	shr    $0xc,%eax
f01031e5:	39 f0                	cmp    %esi,%eax
f01031e7:	0f 87 22 ff ff ff    	ja     f010310f <mem_init+0xb32>
f01031ed:	be 00 20 11 f0       	mov    $0xf0112000,%esi
f01031f2:	bb 00 80 bf ef       	mov    $0xefbf8000,%ebx
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01031f7:	89 f0                	mov    %esi,%eax
f01031f9:	05 00 80 40 20       	add    $0x20408000,%eax
f01031fe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	for(i=0;i<ROUNDUP(KSTKSIZE,PGSIZE)/PGSIZE;i++){
		if(PTE_ADDR(*pgdir_walk(kern_pgdir,(void*)KSTACKTOP-KSTKSIZE+i*PGSIZE,1)) != 0){
f0103201:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0103208:	00 
f0103209:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010320d:	a1 08 d3 19 f0       	mov    0xf019d308,%eax
f0103212:	89 04 24             	mov    %eax,(%esp)
f0103215:	e8 8b dc ff ff       	call   f0100ea5 <pgdir_walk>
f010321a:	f7 00 00 f0 ff ff    	testl  $0xfffff000,(%eax)
f0103220:	74 18                	je     f010323a <mem_init+0xc5d>
			cprintf("Frank attention! page (%08x) has been allocated\n",UPAGES + i*PGSIZE);
f0103222:	8d 83 00 80 40 ff    	lea    -0xbf8000(%ebx),%eax
f0103228:	89 44 24 04          	mov    %eax,0x4(%esp)
f010322c:	c7 04 24 14 5f 10 f0 	movl   $0xf0105f14,(%esp)
f0103233:	e8 e3 09 00 00       	call   f0103c1b <cprintf>
			continue;
f0103238:	eb 7a                	jmp    f01032b4 <mem_init+0xcd7>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010323a:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f0103240:	77 20                	ja     f0103262 <mem_init+0xc85>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103242:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0103246:	c7 44 24 08 a4 58 10 	movl   $0xf01058a4,0x8(%esp)
f010324d:	f0 
f010324e:	c7 44 24 04 dd 00 00 	movl   $0xdd,0x4(%esp)
f0103255:	00 
f0103256:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f010325d:	e8 23 ce ff ff       	call   f0100085 <_panic>
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103262:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103265:	01 d8                	add    %ebx,%eax
f0103267:	c1 e8 0c             	shr    $0xc,%eax
f010326a:	3b 05 04 d3 19 f0    	cmp    0xf019d304,%eax
f0103270:	72 1c                	jb     f010328e <mem_init+0xcb1>
		panic("pa2page called with invalid pa");
f0103272:	c7 44 24 08 ec 58 10 	movl   $0xf01058ec,0x8(%esp)
f0103279:	f0 
f010327a:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f0103281:	00 
f0103282:	c7 04 24 cb 60 10 f0 	movl   $0xf01060cb,(%esp)
f0103289:	e8 f7 cd ff ff       	call   f0100085 <_panic>
		}
		page_insert(kern_pgdir,pa2page((physaddr_t)PADDR((void*)bootstack+i*PGSIZE)),(void*)KSTACKTOP-KSTKSIZE+i*PGSIZE,PTE_W);//Frank:bootstack area grows up or down?
f010328e:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103295:	00 
f0103296:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010329a:	c1 e0 03             	shl    $0x3,%eax
f010329d:	03 05 0c d3 19 f0    	add    0xf019d30c,%eax
f01032a3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01032a7:	a1 08 d3 19 f0       	mov    0xf019d308,%eax
f01032ac:	89 04 24             	mov    %eax,(%esp)
f01032af:	e8 dc dd ff ff       	call   f0101090 <page_insert>
f01032b4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01032ba:	81 c6 00 10 00 00    	add    $0x1000,%esi
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	for(i=0;i<ROUNDUP(KSTKSIZE,PGSIZE)/PGSIZE;i++){
f01032c0:	81 fb 00 00 c0 ef    	cmp    $0xefc00000,%ebx
f01032c6:	0f 85 35 ff ff ff    	jne    f0103201 <mem_init+0xc24>
			page_insert(kern_pgdir,pa2page(PADDR((void*)KERNBASE+i*PGSIZE)),(void*)KERNBASE,PTE_W);
			pa2page(PADDR((void*)KERNBASE))->pp_ref--;
		}
	}
*/
	boot_map_region_large(kern_pgdir,KERNBASE, ROUNDUP(npages*PGSIZE,PTSIZE),PADDR((void*)KERNBASE), PTE_W);
f01032cc:	8b 0d 04 d3 19 f0    	mov    0xf019d304,%ecx
f01032d2:	c1 e1 0c             	shl    $0xc,%ecx
f01032d5:	81 c1 ff ff 3f 00    	add    $0x3fffff,%ecx
f01032db:	81 e1 00 00 c0 ff    	and    $0xffc00000,%ecx
f01032e1:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f01032e8:	00 
f01032e9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01032f0:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01032f5:	a1 08 d3 19 f0       	mov    0xf019d308,%eax
f01032fa:	e8 69 da ff ff       	call   f0100d68 <boot_map_region_large>
	boot_map_region_large(kern_pgdir,KERNBASE+ROUNDUP(npages*PGSIZE,PTSIZE), ROUNDUP(0xffffffff-KERNBASE+1-ROUNDUP(npages*PGSIZE,PTSIZE),PTSIZE),PADDR((void*)KERNBASE), PTE_W);
f01032ff:	8b 15 04 d3 19 f0    	mov    0xf019d304,%edx
f0103305:	c1 e2 0c             	shl    $0xc,%edx
f0103308:	81 c2 ff ff 3f 00    	add    $0x3fffff,%edx
f010330e:	81 e2 00 00 c0 ff    	and    $0xffc00000,%edx
f0103314:	b9 ff ff 3f 10       	mov    $0x103fffff,%ecx
f0103319:	29 d1                	sub    %edx,%ecx
f010331b:	81 e1 00 00 c0 ff    	and    $0xffc00000,%ecx
f0103321:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0103327:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f010332e:	00 
f010332f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103336:	a1 08 d3 19 f0       	mov    0xf019d308,%eax
f010333b:	e8 28 da ff ff       	call   f0100d68 <boot_map_region_large>

static __inline uint32_t
rcr4(void)
{
	uint32_t cr4;
	__asm __volatile("movl %%cr4,%0" : "=r" (cr4));
f0103340:	0f 20 e3             	mov    %cr4,%ebx
	cr4 = rcr4();
	cprintf("cr4=%08x\n",cr4);
f0103343:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103347:	c7 04 24 49 64 10 f0 	movl   $0xf0106449,(%esp)
f010334e:	e8 c8 08 00 00       	call   f0103c1b <cprintf>
}

static __inline void
lcr4(uint32_t val)
{
	__asm __volatile("movl %0,%%cr4" : : "r" (val));
f0103353:	83 cb 10             	or     $0x10,%ebx
f0103356:	0f 22 e3             	mov    %ebx,%cr4
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0103359:	8b 1d 08 d3 19 f0    	mov    0xf019d308,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct Page), PGSIZE);
f010335f:	a1 04 d3 19 f0       	mov    0xf019d304,%eax
f0103364:	8d 3c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%edi
	for (i = 0; i < n; i += PGSIZE)
f010336b:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f0103371:	74 79                	je     f01033ec <mem_init+0xe0f>
f0103373:	be 00 00 00 00       	mov    $0x0,%esi
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0103378:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
f010337e:	89 d8                	mov    %ebx,%eax
f0103380:	e8 87 dd ff ff       	call   f010110c <check_va2pa>
f0103385:	8b 15 0c d3 19 f0    	mov    0xf019d30c,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010338b:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0103391:	77 20                	ja     f01033b3 <mem_init+0xdd6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103393:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103397:	c7 44 24 08 a4 58 10 	movl   $0xf01058a4,0x8(%esp)
f010339e:	f0 
f010339f:	c7 44 24 04 4d 03 00 	movl   $0x34d,0x4(%esp)
f01033a6:	00 
f01033a7:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f01033ae:	e8 d2 cc ff ff       	call   f0100085 <_panic>
f01033b3:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f01033ba:	39 d0                	cmp    %edx,%eax
f01033bc:	74 24                	je     f01033e2 <mem_init+0xe05>
f01033be:	c7 44 24 0c 48 5f 10 	movl   $0xf0105f48,0xc(%esp)
f01033c5:	f0 
f01033c6:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f01033cd:	f0 
f01033ce:	c7 44 24 04 4d 03 00 	movl   $0x34d,0x4(%esp)
f01033d5:	00 
f01033d6:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f01033dd:	e8 a3 cc ff ff       	call   f0100085 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct Page), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01033e2:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01033e8:	39 f7                	cmp    %esi,%edi
f01033ea:	77 8c                	ja     f0103378 <mem_init+0xd9b>
f01033ec:	be 00 00 00 00       	mov    $0x0,%esi
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01033f1:	8d 96 00 00 c0 ee    	lea    -0x11400000(%esi),%edx
f01033f7:	89 d8                	mov    %ebx,%eax
f01033f9:	e8 0e dd ff ff       	call   f010110c <check_va2pa>
f01033fe:	8b 15 58 c6 19 f0    	mov    0xf019c658,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103404:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f010340a:	77 20                	ja     f010342c <mem_init+0xe4f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010340c:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103410:	c7 44 24 08 a4 58 10 	movl   $0xf01058a4,0x8(%esp)
f0103417:	f0 
f0103418:	c7 44 24 04 52 03 00 	movl   $0x352,0x4(%esp)
f010341f:	00 
f0103420:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0103427:	e8 59 cc ff ff       	call   f0100085 <_panic>
f010342c:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f0103433:	39 d0                	cmp    %edx,%eax
f0103435:	74 24                	je     f010345b <mem_init+0xe7e>
f0103437:	c7 44 24 0c 7c 5f 10 	movl   $0xf0105f7c,0xc(%esp)
f010343e:	f0 
f010343f:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0103446:	f0 
f0103447:	c7 44 24 04 52 03 00 	movl   $0x352,0x4(%esp)
f010344e:	00 
f010344f:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0103456:	e8 2a cc ff ff       	call   f0100085 <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010345b:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0103461:	81 fe 00 80 01 00    	cmp    $0x18000,%esi
f0103467:	75 88                	jne    f01033f1 <mem_init+0xe14>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	if (check_va2pa_large(pgdir, KERNBASE) == 0) {
f0103469:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f010346e:	89 d8                	mov    %ebx,%eax
f0103470:	e8 75 d7 ff ff       	call   f0100bea <check_va2pa_large>
f0103475:	85 c0                	test   %eax,%eax
f0103477:	74 17                	je     f0103490 <mem_init+0xeb3>
		for (i = 0; i < npages * PGSIZE; i += PTSIZE)
			assert(check_va2pa_large(pgdir, KERNBASE + i) == i);

		cprintf("large page installed!\n");
	} else {
	    for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0103479:	a1 04 d3 19 f0       	mov    0xf019d304,%eax
f010347e:	c1 e0 0c             	shl    $0xc,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103481:	be 00 00 00 00       	mov    $0x0,%esi
f0103486:	85 c0                	test   %eax,%eax
f0103488:	0f 85 80 00 00 00    	jne    f010350e <mem_init+0xf31>
f010348e:	eb 63                	jmp    f01034f3 <mem_init+0xf16>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	if (check_va2pa_large(pgdir, KERNBASE) == 0) {
		for (i = 0; i < npages * PGSIZE; i += PTSIZE)
f0103490:	8b 3d 04 d3 19 f0    	mov    0xf019d304,%edi
f0103496:	c1 e7 0c             	shl    $0xc,%edi
			assert(check_va2pa_large(pgdir, KERNBASE + i) == i);
f0103499:	b8 00 00 00 00       	mov    $0x0,%eax
f010349e:	89 de                	mov    %ebx,%esi
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	if (check_va2pa_large(pgdir, KERNBASE) == 0) {
		for (i = 0; i < npages * PGSIZE; i += PTSIZE)
f01034a0:	85 ff                	test   %edi,%edi
f01034a2:	75 37                	jne    f01034db <mem_init+0xefe>
f01034a4:	eb 41                	jmp    f01034e7 <mem_init+0xf0a>
f01034a6:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
			assert(check_va2pa_large(pgdir, KERNBASE + i) == i);
f01034ac:	89 f0                	mov    %esi,%eax
f01034ae:	e8 37 d7 ff ff       	call   f0100bea <check_va2pa_large>
f01034b3:	39 d8                	cmp    %ebx,%eax
f01034b5:	74 24                	je     f01034db <mem_init+0xefe>
f01034b7:	c7 44 24 0c b0 5f 10 	movl   $0xf0105fb0,0xc(%esp)
f01034be:	f0 
f01034bf:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f01034c6:	f0 
f01034c7:	c7 44 24 04 57 03 00 	movl   $0x357,0x4(%esp)
f01034ce:	00 
f01034cf:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f01034d6:	e8 aa cb ff ff       	call   f0100085 <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	if (check_va2pa_large(pgdir, KERNBASE) == 0) {
		for (i = 0; i < npages * PGSIZE; i += PTSIZE)
f01034db:	8d 98 00 00 40 00    	lea    0x400000(%eax),%ebx
f01034e1:	39 fb                	cmp    %edi,%ebx
f01034e3:	72 c1                	jb     f01034a6 <mem_init+0xec9>
f01034e5:	89 f3                	mov    %esi,%ebx
			assert(check_va2pa_large(pgdir, KERNBASE + i) == i);

		cprintf("large page installed!\n");
f01034e7:	c7 04 24 53 64 10 f0 	movl   $0xf0106453,(%esp)
f01034ee:	e8 28 07 00 00       	call   f0103c1b <cprintf>



	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f01034f3:	ba 00 80 bf ef       	mov    $0xefbf8000,%edx
f01034f8:	89 d8                	mov    %ebx,%eax
f01034fa:	e8 0d dc ff ff       	call   f010110c <check_va2pa>
f01034ff:	ba 00 20 11 f0       	mov    $0xf0112000,%edx
f0103504:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f010350a:	77 6f                	ja     f010357b <mem_init+0xf9e>
f010350c:	eb 49                	jmp    f0103557 <mem_init+0xf7a>
			assert(check_va2pa_large(pgdir, KERNBASE + i) == i);

		cprintf("large page installed!\n");
	} else {
	    for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		    assert(check_va2pa(pgdir, KERNBASE + i) == i);
f010350e:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
f0103514:	89 d8                	mov    %ebx,%eax
f0103516:	e8 f1 db ff ff       	call   f010110c <check_va2pa>
f010351b:	39 c6                	cmp    %eax,%esi
f010351d:	74 24                	je     f0103543 <mem_init+0xf66>
f010351f:	c7 44 24 0c dc 5f 10 	movl   $0xf0105fdc,0xc(%esp)
f0103526:	f0 
f0103527:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f010352e:	f0 
f010352f:	c7 44 24 04 5c 03 00 	movl   $0x35c,0x4(%esp)
f0103536:	00 
f0103537:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f010353e:	e8 42 cb ff ff       	call   f0100085 <_panic>
		for (i = 0; i < npages * PGSIZE; i += PTSIZE)
			assert(check_va2pa_large(pgdir, KERNBASE + i) == i);

		cprintf("large page installed!\n");
	} else {
	    for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0103543:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0103549:	a1 04 d3 19 f0       	mov    0xf019d304,%eax
f010354e:	c1 e0 0c             	shl    $0xc,%eax
f0103551:	39 c6                	cmp    %eax,%esi
f0103553:	72 b9                	jb     f010350e <mem_init+0xf31>
f0103555:	eb 9c                	jmp    f01034f3 <mem_init+0xf16>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103557:	c7 44 24 0c 00 20 11 	movl   $0xf0112000,0xc(%esp)
f010355e:	f0 
f010355f:	c7 44 24 08 a4 58 10 	movl   $0xf01058a4,0x8(%esp)
f0103566:	f0 
f0103567:	c7 44 24 04 63 03 00 	movl   $0x363,0x4(%esp)
f010356e:	00 
f010356f:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0103576:	e8 0a cb ff ff       	call   f0100085 <_panic>
f010357b:	be 00 80 bf ef       	mov    $0xefbf8000,%esi



	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0103580:	bf 00 20 11 f0       	mov    $0xf0112000,%edi
f0103585:	81 c7 00 80 40 20    	add    $0x20408000,%edi
f010358b:	8d 14 37             	lea    (%edi,%esi,1),%edx
f010358e:	39 d0                	cmp    %edx,%eax
f0103590:	74 24                	je     f01035b6 <mem_init+0xfd9>
f0103592:	c7 44 24 0c 04 60 10 	movl   $0xf0106004,0xc(%esp)
f0103599:	f0 
f010359a:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f01035a1:	f0 
f01035a2:	c7 44 24 04 63 03 00 	movl   $0x363,0x4(%esp)
f01035a9:	00 
f01035aa:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f01035b1:	e8 cf ca ff ff       	call   f0100085 <_panic>
f01035b6:	81 c6 00 10 00 00    	add    $0x1000,%esi
	}



	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01035bc:	81 fe 00 00 c0 ef    	cmp    $0xefc00000,%esi
f01035c2:	0f 85 9d 01 00 00    	jne    f0103765 <mem_init+0x1188>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f01035c8:	ba 00 00 80 ef       	mov    $0xef800000,%edx
f01035cd:	89 d8                	mov    %ebx,%eax
f01035cf:	e8 38 db ff ff       	call   f010110c <check_va2pa>
f01035d4:	83 f8 ff             	cmp    $0xffffffff,%eax
f01035d7:	74 24                	je     f01035fd <mem_init+0x1020>
f01035d9:	c7 44 24 0c 4c 60 10 	movl   $0xf010604c,0xc(%esp)
f01035e0:	f0 
f01035e1:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f01035e8:	f0 
f01035e9:	c7 44 24 04 64 03 00 	movl   $0x364,0x4(%esp)
f01035f0:	00 
f01035f1:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f01035f8:	e8 88 ca ff ff       	call   f0100085 <_panic>
f01035fd:	b8 00 00 00 00       	mov    $0x0,%eax

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0103602:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0103608:	83 fa 03             	cmp    $0x3,%edx
f010360b:	77 2e                	ja     f010363b <mem_init+0x105e>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i] & PTE_P);
f010360d:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f0103611:	0f 85 aa 00 00 00    	jne    f01036c1 <mem_init+0x10e4>
f0103617:	c7 44 24 0c 6a 64 10 	movl   $0xf010646a,0xc(%esp)
f010361e:	f0 
f010361f:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0103626:	f0 
f0103627:	c7 44 24 04 6d 03 00 	movl   $0x36d,0x4(%esp)
f010362e:	00 
f010362f:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0103636:	e8 4a ca ff ff       	call   f0100085 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f010363b:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0103640:	76 55                	jbe    f0103697 <mem_init+0x10ba>
				assert(pgdir[i] & PTE_P);
f0103642:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f0103645:	f6 c2 01             	test   $0x1,%dl
f0103648:	75 24                	jne    f010366e <mem_init+0x1091>
f010364a:	c7 44 24 0c 6a 64 10 	movl   $0xf010646a,0xc(%esp)
f0103651:	f0 
f0103652:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0103659:	f0 
f010365a:	c7 44 24 04 71 03 00 	movl   $0x371,0x4(%esp)
f0103661:	00 
f0103662:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0103669:	e8 17 ca ff ff       	call   f0100085 <_panic>
				assert(pgdir[i] & PTE_W);
f010366e:	f6 c2 02             	test   $0x2,%dl
f0103671:	75 4e                	jne    f01036c1 <mem_init+0x10e4>
f0103673:	c7 44 24 0c 7b 64 10 	movl   $0xf010647b,0xc(%esp)
f010367a:	f0 
f010367b:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0103682:	f0 
f0103683:	c7 44 24 04 72 03 00 	movl   $0x372,0x4(%esp)
f010368a:	00 
f010368b:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f0103692:	e8 ee c9 ff ff       	call   f0100085 <_panic>
			} else
				assert(pgdir[i] == 0);
f0103697:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f010369b:	74 24                	je     f01036c1 <mem_init+0x10e4>
f010369d:	c7 44 24 0c 8c 64 10 	movl   $0xf010648c,0xc(%esp)
f01036a4:	f0 
f01036a5:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f01036ac:	f0 
f01036ad:	c7 44 24 04 74 03 00 	movl   $0x374,0x4(%esp)
f01036b4:	00 
f01036b5:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f01036bc:	e8 c4 c9 ff ff       	call   f0100085 <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f01036c1:	83 c0 01             	add    $0x1,%eax
f01036c4:	3d 00 04 00 00       	cmp    $0x400,%eax
f01036c9:	0f 85 33 ff ff ff    	jne    f0103602 <mem_init+0x1025>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f01036cf:	c7 04 24 7c 60 10 f0 	movl   $0xf010607c,(%esp)
f01036d6:	e8 40 05 00 00       	call   f0103c1b <cprintf>
	cprintf("cr4=%08x\n",cr4);
	cr4 |= CR4_PSE;
	lcr4(cr4);
	// Check that the initial page directory has been set up correctly.
	check_kern_pgdir();
	cprintf("\nFrank checkpoint 2\n");
f01036db:	c7 04 24 9a 64 10 f0 	movl   $0xf010649a,(%esp)
f01036e2:	e8 34 05 00 00       	call   f0103c1b <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f01036e7:	a1 08 d3 19 f0       	mov    0xf019d308,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01036ec:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01036f1:	77 20                	ja     f0103713 <mem_init+0x1136>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01036f3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01036f7:	c7 44 24 08 a4 58 10 	movl   $0xf01058a4,0x8(%esp)
f01036fe:	f0 
f01036ff:	c7 44 24 04 08 01 00 	movl   $0x108,0x4(%esp)
f0103706:	00 
f0103707:	c7 04 24 bf 60 10 f0 	movl   $0xf01060bf,(%esp)
f010370e:	e8 72 c9 ff ff       	call   f0100085 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103713:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f0103719:	0f 22 d8             	mov    %eax,%cr3

	
cprintf("\nFrank checkpoint 3\n");
f010371c:	c7 04 24 af 64 10 f0 	movl   $0xf01064af,(%esp)
f0103723:	e8 f3 04 00 00       	call   f0103c1b <cprintf>
	check_page_free_list(0);
f0103728:	b8 00 00 00 00       	mov    $0x0,%eax
f010372d:	e8 40 da ff ff       	call   f0101172 <check_page_free_list>
	cprintf("\nFrank checkpoint 3\n");
f0103732:	c7 04 24 af 64 10 f0 	movl   $0xf01064af,(%esp)
f0103739:	e8 dd 04 00 00       	call   f0103c1b <cprintf>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f010373e:	0f 20 c0             	mov    %cr0,%eax
	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f0103741:	0d 23 00 05 80       	or     $0x80050023,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0103746:	83 e0 f3             	and    $0xfffffff3,%eax
f0103749:	0f 22 c0             	mov    %eax,%cr0
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
f010374c:	e8 b7 ea ff ff       	call   f0102208 <check_page_installed_pgdir>
	cprintf("\nFrank checkpoint 4\n");
f0103751:	c7 04 24 c4 64 10 f0 	movl   $0xf01064c4,(%esp)
f0103758:	e8 be 04 00 00       	call   f0103c1b <cprintf>
}
f010375d:	83 c4 2c             	add    $0x2c,%esp
f0103760:	5b                   	pop    %ebx
f0103761:	5e                   	pop    %esi
f0103762:	5f                   	pop    %edi
f0103763:	5d                   	pop    %ebp
f0103764:	c3                   	ret    



	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0103765:	89 f2                	mov    %esi,%edx
f0103767:	89 d8                	mov    %ebx,%eax
f0103769:	e8 9e d9 ff ff       	call   f010110c <check_va2pa>
f010376e:	e9 18 fe ff ff       	jmp    f010358b <mem_init+0xfae>
	...

f0103780 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0103780:	55                   	push   %ebp
f0103781:	89 e5                	mov    %esp,%ebp
f0103783:	53                   	push   %ebx
f0103784:	8b 45 08             	mov    0x8(%ebp),%eax
f0103787:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f010378a:	85 c0                	test   %eax,%eax
f010378c:	75 0e                	jne    f010379c <envid2env+0x1c>
		*env_store = curenv;
f010378e:	a1 5c c6 19 f0       	mov    0xf019c65c,%eax
f0103793:	89 01                	mov    %eax,(%ecx)
f0103795:	b8 00 00 00 00       	mov    $0x0,%eax
		return 0;
f010379a:	eb 57                	jmp    f01037f3 <envid2env+0x73>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f010379c:	89 c2                	mov    %eax,%edx
f010379e:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f01037a4:	8d 14 52             	lea    (%edx,%edx,2),%edx
f01037a7:	c1 e2 05             	shl    $0x5,%edx
f01037aa:	03 15 58 c6 19 f0    	add    0xf019c658,%edx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f01037b0:	83 7a 54 00          	cmpl   $0x0,0x54(%edx)
f01037b4:	74 05                	je     f01037bb <envid2env+0x3b>
f01037b6:	39 42 48             	cmp    %eax,0x48(%edx)
f01037b9:	74 0d                	je     f01037c8 <envid2env+0x48>
		*env_store = 0;
f01037bb:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
f01037c1:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
		return -E_BAD_ENV;
f01037c6:	eb 2b                	jmp    f01037f3 <envid2env+0x73>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f01037c8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01037cc:	74 1e                	je     f01037ec <envid2env+0x6c>
f01037ce:	a1 5c c6 19 f0       	mov    0xf019c65c,%eax
f01037d3:	39 c2                	cmp    %eax,%edx
f01037d5:	74 15                	je     f01037ec <envid2env+0x6c>
f01037d7:	8b 5a 4c             	mov    0x4c(%edx),%ebx
f01037da:	3b 58 48             	cmp    0x48(%eax),%ebx
f01037dd:	74 0d                	je     f01037ec <envid2env+0x6c>
		*env_store = 0;
f01037df:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
f01037e5:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
		return -E_BAD_ENV;
f01037ea:	eb 07                	jmp    f01037f3 <envid2env+0x73>
	}

	*env_store = e;
f01037ec:	89 11                	mov    %edx,(%ecx)
f01037ee:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
f01037f3:	5b                   	pop    %ebx
f01037f4:	5d                   	pop    %ebp
f01037f5:	c3                   	ret    

f01037f6 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f01037f6:	55                   	push   %ebp
f01037f7:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f01037f9:	b8 30 c3 11 f0       	mov    $0xf011c330,%eax
f01037fe:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0103801:	b8 23 00 00 00       	mov    $0x23,%eax
f0103806:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0103808:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f010380a:	b0 10                	mov    $0x10,%al
f010380c:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f010380e:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f0103810:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f0103812:	ea 19 38 10 f0 08 00 	ljmp   $0x8,$0xf0103819
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f0103819:	b0 00                	mov    $0x0,%al
f010381b:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f010381e:	5d                   	pop    %ebp
f010381f:	c3                   	ret    

f0103820 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0103820:	55                   	push   %ebp
f0103821:	89 e5                	mov    %esp,%ebp
	// Set up envs array
	// LAB 3: Your code here.

	// Per-CPU part of the initialization
	env_init_percpu();
f0103823:	e8 ce ff ff ff       	call   f01037f6 <env_init_percpu>
}
f0103828:	5d                   	pop    %ebp
f0103829:	c3                   	ret    

f010382a <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, size_t size, enum EnvType type)
{
f010382a:	55                   	push   %ebp
f010382b:	89 e5                	mov    %esp,%ebp
	// LAB 3: Your code here.
}
f010382d:	5d                   	pop    %ebp
f010382e:	c3                   	ret    

f010382f <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f010382f:	55                   	push   %ebp
f0103830:	89 e5                	mov    %esp,%ebp
f0103832:	83 ec 18             	sub    $0x18,%esp
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.

	panic("env_run not yet implemented");
f0103835:	c7 44 24 08 d9 64 10 	movl   $0xf01064d9,0x8(%esp)
f010383c:	f0 
f010383d:	c7 44 24 04 cc 01 00 	movl   $0x1cc,0x4(%esp)
f0103844:	00 
f0103845:	c7 04 24 f5 64 10 f0 	movl   $0xf01064f5,(%esp)
f010384c:	e8 34 c8 ff ff       	call   f0100085 <_panic>

f0103851 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103851:	55                   	push   %ebp
f0103852:	89 e5                	mov    %esp,%ebp
f0103854:	83 ec 18             	sub    $0x18,%esp
	__asm __volatile("movl %0,%%esp\n"
f0103857:	8b 65 08             	mov    0x8(%ebp),%esp
f010385a:	61                   	popa   
f010385b:	07                   	pop    %es
f010385c:	1f                   	pop    %ds
f010385d:	83 c4 08             	add    $0x8,%esp
f0103860:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103861:	c7 44 24 08 00 65 10 	movl   $0xf0106500,0x8(%esp)
f0103868:	f0 
f0103869:	c7 44 24 04 ad 01 00 	movl   $0x1ad,0x4(%esp)
f0103870:	00 
f0103871:	c7 04 24 f5 64 10 f0 	movl   $0xf01064f5,(%esp)
f0103878:	e8 08 c8 ff ff       	call   f0100085 <_panic>

f010387d <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f010387d:	55                   	push   %ebp
f010387e:	89 e5                	mov    %esp,%ebp
f0103880:	57                   	push   %edi
f0103881:	56                   	push   %esi
f0103882:	53                   	push   %ebx
f0103883:	83 ec 2c             	sub    $0x2c,%esp
f0103886:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103889:	a1 5c c6 19 f0       	mov    0xf019c65c,%eax
f010388e:	39 c7                	cmp    %eax,%edi
f0103890:	75 37                	jne    f01038c9 <env_free+0x4c>
		lcr3(PADDR(kern_pgdir));
f0103892:	8b 15 08 d3 19 f0    	mov    0xf019d308,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103898:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f010389e:	77 20                	ja     f01038c0 <env_free+0x43>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01038a0:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01038a4:	c7 44 24 08 a4 58 10 	movl   $0xf01058a4,0x8(%esp)
f01038ab:	f0 
f01038ac:	c7 44 24 04 68 01 00 	movl   $0x168,0x4(%esp)
f01038b3:	00 
f01038b4:	c7 04 24 f5 64 10 f0 	movl   $0xf01064f5,(%esp)
f01038bb:	e8 c5 c7 ff ff       	call   f0100085 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01038c0:	8d 92 00 00 00 10    	lea    0x10000000(%edx),%edx
f01038c6:	0f 22 da             	mov    %edx,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01038c9:	8b 4f 48             	mov    0x48(%edi),%ecx
f01038cc:	ba 00 00 00 00       	mov    $0x0,%edx
f01038d1:	85 c0                	test   %eax,%eax
f01038d3:	74 03                	je     f01038d8 <env_free+0x5b>
f01038d5:	8b 50 48             	mov    0x48(%eax),%edx
f01038d8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01038dc:	89 54 24 04          	mov    %edx,0x4(%esp)
f01038e0:	c7 04 24 0c 65 10 f0 	movl   $0xf010650c,(%esp)
f01038e7:	e8 2f 03 00 00       	call   f0103c1b <cprintf>
f01038ec:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01038f3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01038f6:	c1 e0 02             	shl    $0x2,%eax
f01038f9:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f01038fc:	8b 47 5c             	mov    0x5c(%edi),%eax
f01038ff:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103902:	8b 34 10             	mov    (%eax,%edx,1),%esi
f0103905:	f7 c6 01 00 00 00    	test   $0x1,%esi
f010390b:	0f 84 b8 00 00 00    	je     f01039c9 <env_free+0x14c>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103911:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103917:	89 f0                	mov    %esi,%eax
f0103919:	c1 e8 0c             	shr    $0xc,%eax
f010391c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010391f:	3b 05 04 d3 19 f0    	cmp    0xf019d304,%eax
f0103925:	72 20                	jb     f0103947 <env_free+0xca>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103927:	89 74 24 0c          	mov    %esi,0xc(%esp)
f010392b:	c7 44 24 08 c8 58 10 	movl   $0xf01058c8,0x8(%esp)
f0103932:	f0 
f0103933:	c7 44 24 04 77 01 00 	movl   $0x177,0x4(%esp)
f010393a:	00 
f010393b:	c7 04 24 f5 64 10 f0 	movl   $0xf01064f5,(%esp)
f0103942:	e8 3e c7 ff ff       	call   f0100085 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103947:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010394a:	c1 e2 16             	shl    $0x16,%edx
f010394d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0103950:	bb 00 00 00 00       	mov    $0x0,%ebx
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
f0103955:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f010395c:	01 
f010395d:	74 17                	je     f0103976 <env_free+0xf9>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f010395f:	89 d8                	mov    %ebx,%eax
f0103961:	c1 e0 0c             	shl    $0xc,%eax
f0103964:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103967:	89 44 24 04          	mov    %eax,0x4(%esp)
f010396b:	8b 47 5c             	mov    0x5c(%edi),%eax
f010396e:	89 04 24             	mov    %eax,(%esp)
f0103971:	e8 9d d6 ff ff       	call   f0101013 <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103976:	83 c3 01             	add    $0x1,%ebx
f0103979:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f010397f:	75 d4                	jne    f0103955 <env_free+0xd8>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103981:	8b 47 5c             	mov    0x5c(%edi),%eax
f0103984:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103987:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010398e:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103991:	3b 05 04 d3 19 f0    	cmp    0xf019d304,%eax
f0103997:	72 1c                	jb     f01039b5 <env_free+0x138>
		panic("pa2page called with invalid pa");
f0103999:	c7 44 24 08 ec 58 10 	movl   $0xf01058ec,0x8(%esp)
f01039a0:	f0 
f01039a1:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f01039a8:	00 
f01039a9:	c7 04 24 cb 60 10 f0 	movl   $0xf01060cb,(%esp)
f01039b0:	e8 d0 c6 ff ff       	call   f0100085 <_panic>
		page_decref(pa2page(pa));
f01039b5:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01039b8:	c1 e0 03             	shl    $0x3,%eax
f01039bb:	03 05 0c d3 19 f0    	add    0xf019d30c,%eax
f01039c1:	89 04 24             	mov    %eax,(%esp)
f01039c4:	e8 f3 d2 ff ff       	call   f0100cbc <page_decref>
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01039c9:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f01039cd:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f01039d4:	0f 85 19 ff ff ff    	jne    f01038f3 <env_free+0x76>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f01039da:	8b 47 5c             	mov    0x5c(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01039dd:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01039e2:	77 20                	ja     f0103a04 <env_free+0x187>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01039e4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01039e8:	c7 44 24 08 a4 58 10 	movl   $0xf01058a4,0x8(%esp)
f01039ef:	f0 
f01039f0:	c7 44 24 04 85 01 00 	movl   $0x185,0x4(%esp)
f01039f7:	00 
f01039f8:	c7 04 24 f5 64 10 f0 	movl   $0xf01064f5,(%esp)
f01039ff:	e8 81 c6 ff ff       	call   f0100085 <_panic>
	e->env_pgdir = 0;
f0103a04:	c7 47 5c 00 00 00 00 	movl   $0x0,0x5c(%edi)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103a0b:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f0103a11:	c1 e8 0c             	shr    $0xc,%eax
f0103a14:	3b 05 04 d3 19 f0    	cmp    0xf019d304,%eax
f0103a1a:	72 1c                	jb     f0103a38 <env_free+0x1bb>
		panic("pa2page called with invalid pa");
f0103a1c:	c7 44 24 08 ec 58 10 	movl   $0xf01058ec,0x8(%esp)
f0103a23:	f0 
f0103a24:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f0103a2b:	00 
f0103a2c:	c7 04 24 cb 60 10 f0 	movl   $0xf01060cb,(%esp)
f0103a33:	e8 4d c6 ff ff       	call   f0100085 <_panic>
	page_decref(pa2page(pa));
f0103a38:	c1 e0 03             	shl    $0x3,%eax
f0103a3b:	03 05 0c d3 19 f0    	add    0xf019d30c,%eax
f0103a41:	89 04 24             	mov    %eax,(%esp)
f0103a44:	e8 73 d2 ff ff       	call   f0100cbc <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103a49:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103a50:	a1 60 c6 19 f0       	mov    0xf019c660,%eax
f0103a55:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103a58:	89 3d 60 c6 19 f0    	mov    %edi,0xf019c660
}
f0103a5e:	83 c4 2c             	add    $0x2c,%esp
f0103a61:	5b                   	pop    %ebx
f0103a62:	5e                   	pop    %esi
f0103a63:	5f                   	pop    %edi
f0103a64:	5d                   	pop    %ebp
f0103a65:	c3                   	ret    

f0103a66 <env_destroy>:
//
// Frees environment e.
//
void
env_destroy(struct Env *e)
{
f0103a66:	55                   	push   %ebp
f0103a67:	89 e5                	mov    %esp,%ebp
f0103a69:	83 ec 18             	sub    $0x18,%esp
	env_free(e);
f0103a6c:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a6f:	89 04 24             	mov    %eax,(%esp)
f0103a72:	e8 06 fe ff ff       	call   f010387d <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f0103a77:	c7 04 24 38 65 10 f0 	movl   $0xf0106538,(%esp)
f0103a7e:	e8 98 01 00 00       	call   f0103c1b <cprintf>
	while (1)
		monitor(NULL);
f0103a83:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103a8a:	e8 33 ce ff ff       	call   f01008c2 <monitor>
f0103a8f:	eb f2                	jmp    f0103a83 <env_destroy+0x1d>

f0103a91 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0103a91:	55                   	push   %ebp
f0103a92:	89 e5                	mov    %esp,%ebp
f0103a94:	53                   	push   %ebx
f0103a95:	83 ec 14             	sub    $0x14,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0103a98:	8b 1d 60 c6 19 f0    	mov    0xf019c660,%ebx
f0103a9e:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103aa3:	85 db                	test   %ebx,%ebx
f0103aa5:	0f 84 0d 01 00 00    	je     f0103bb8 <env_alloc+0x127>
{
	int i;
	struct Page *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103aab:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0103ab2:	e8 6a d3 ff ff       	call   f0100e21 <page_alloc>
f0103ab7:	89 c2                	mov    %eax,%edx
f0103ab9:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0103abe:	85 d2                	test   %edx,%edx
f0103ac0:	0f 84 f2 00 00 00    	je     f0103bb8 <env_alloc+0x127>

	// LAB 3: Your code here.

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0103ac6:	8b 43 5c             	mov    0x5c(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103ac9:	89 c2                	mov    %eax,%edx
f0103acb:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103ad0:	77 20                	ja     f0103af2 <env_alloc+0x61>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103ad2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103ad6:	c7 44 24 08 a4 58 10 	movl   $0xf01058a4,0x8(%esp)
f0103add:	f0 
f0103ade:	c7 44 24 04 b9 00 00 	movl   $0xb9,0x4(%esp)
f0103ae5:	00 
f0103ae6:	c7 04 24 f5 64 10 f0 	movl   $0xf01064f5,(%esp)
f0103aed:	e8 93 c5 ff ff       	call   f0100085 <_panic>
f0103af2:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0103af8:	83 ca 05             	or     $0x5,%edx
f0103afb:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103b01:	8b 43 48             	mov    0x48(%ebx),%eax
f0103b04:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0103b09:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0103b0e:	7f 05                	jg     f0103b15 <env_alloc+0x84>
f0103b10:	b8 00 10 00 00       	mov    $0x1000,%eax
		generation = 1 << ENVGENSHIFT;
	e->env_id = generation | (e - envs);
f0103b15:	89 da                	mov    %ebx,%edx
f0103b17:	2b 15 58 c6 19 f0    	sub    0xf019c658,%edx
f0103b1d:	c1 fa 05             	sar    $0x5,%edx
f0103b20:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0103b26:	09 d0                	or     %edx,%eax
f0103b28:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0103b2b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103b2e:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103b31:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0103b38:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
	e->env_runs = 0;
f0103b3f:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103b46:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0103b4d:	00 
f0103b4e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103b55:	00 
f0103b56:	89 1c 24             	mov    %ebx,(%esp)
f0103b59:	e8 f8 12 00 00       	call   f0104e56 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0103b5e:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103b64:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0103b6a:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103b70:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103b77:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// commit the allocation
	env_free_list = e->env_link;
f0103b7d:	8b 43 44             	mov    0x44(%ebx),%eax
f0103b80:	a3 60 c6 19 f0       	mov    %eax,0xf019c660
	*newenv_store = e;
f0103b85:	8b 45 08             	mov    0x8(%ebp),%eax
f0103b88:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103b8a:	8b 4b 48             	mov    0x48(%ebx),%ecx
f0103b8d:	8b 15 5c c6 19 f0    	mov    0xf019c65c,%edx
f0103b93:	b8 00 00 00 00       	mov    $0x0,%eax
f0103b98:	85 d2                	test   %edx,%edx
f0103b9a:	74 03                	je     f0103b9f <env_alloc+0x10e>
f0103b9c:	8b 42 48             	mov    0x48(%edx),%eax
f0103b9f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0103ba3:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103ba7:	c7 04 24 22 65 10 f0 	movl   $0xf0106522,(%esp)
f0103bae:	e8 68 00 00 00       	call   f0103c1b <cprintf>
f0103bb3:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
f0103bb8:	83 c4 14             	add    $0x14,%esp
f0103bbb:	5b                   	pop    %ebx
f0103bbc:	5d                   	pop    %ebp
f0103bbd:	c3                   	ret    
	...

f0103bc0 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103bc0:	55                   	push   %ebp
f0103bc1:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103bc3:	ba 70 00 00 00       	mov    $0x70,%edx
f0103bc8:	8b 45 08             	mov    0x8(%ebp),%eax
f0103bcb:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103bcc:	b2 71                	mov    $0x71,%dl
f0103bce:	ec                   	in     (%dx),%al
f0103bcf:	0f b6 c0             	movzbl %al,%eax
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
}
f0103bd2:	5d                   	pop    %ebp
f0103bd3:	c3                   	ret    

f0103bd4 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103bd4:	55                   	push   %ebp
f0103bd5:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103bd7:	ba 70 00 00 00       	mov    $0x70,%edx
f0103bdc:	8b 45 08             	mov    0x8(%ebp),%eax
f0103bdf:	ee                   	out    %al,(%dx)
f0103be0:	b2 71                	mov    $0x71,%dl
f0103be2:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103be5:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103be6:	5d                   	pop    %ebp
f0103be7:	c3                   	ret    

f0103be8 <vcprintf>:
    (*cnt)++;
}

int
vcprintf(const char *fmt, va_list ap)
{
f0103be8:	55                   	push   %ebp
f0103be9:	89 e5                	mov    %esp,%ebp
f0103beb:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0103bee:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103bf5:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103bf8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103bfc:	8b 45 08             	mov    0x8(%ebp),%eax
f0103bff:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103c03:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103c06:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c0a:	c7 04 24 35 3c 10 f0 	movl   $0xf0103c35,(%esp)
f0103c11:	e8 ea 09 00 00       	call   f0104600 <vprintfmt>
	return cnt;
}
f0103c16:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103c19:	c9                   	leave  
f0103c1a:	c3                   	ret    

f0103c1b <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103c1b:	55                   	push   %ebp
f0103c1c:	89 e5                	mov    %esp,%ebp
f0103c1e:	83 ec 18             	sub    $0x18,%esp
	vprintfmt((void*)putch, &cnt, fmt, ap);
	return cnt;
}

int
cprintf(const char *fmt, ...)
f0103c21:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
f0103c24:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c28:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c2b:	89 04 24             	mov    %eax,(%esp)
f0103c2e:	e8 b5 ff ff ff       	call   f0103be8 <vcprintf>
	va_end(ap);

	return cnt;
}
f0103c33:	c9                   	leave  
f0103c34:	c3                   	ret    

f0103c35 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103c35:	55                   	push   %ebp
f0103c36:	89 e5                	mov    %esp,%ebp
f0103c38:	53                   	push   %ebx
f0103c39:	83 ec 14             	sub    $0x14,%esp
f0103c3c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	cputchar(ch);
f0103c3f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c42:	89 04 24             	mov    %eax,(%esp)
f0103c45:	e8 10 c8 ff ff       	call   f010045a <cputchar>
    (*cnt)++;
f0103c4a:	83 03 01             	addl   $0x1,(%ebx)
}
f0103c4d:	83 c4 14             	add    $0x14,%esp
f0103c50:	5b                   	pop    %ebx
f0103c51:	5d                   	pop    %ebp
f0103c52:	c3                   	ret    
	...

f0103c54 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103c54:	55                   	push   %ebp
f0103c55:	89 e5                	mov    %esp,%ebp
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f0103c57:	c7 05 84 ce 19 f0 00 	movl   $0xefc00000,0xf019ce84
f0103c5e:	00 c0 ef 
	ts.ts_ss0 = GD_KD;
f0103c61:	66 c7 05 88 ce 19 f0 	movw   $0x10,0xf019ce88
f0103c68:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f0103c6a:	66 c7 05 28 c3 11 f0 	movw   $0x68,0xf011c328
f0103c71:	68 00 
f0103c73:	b8 80 ce 19 f0       	mov    $0xf019ce80,%eax
f0103c78:	66 a3 2a c3 11 f0    	mov    %ax,0xf011c32a
f0103c7e:	89 c2                	mov    %eax,%edx
f0103c80:	c1 ea 10             	shr    $0x10,%edx
f0103c83:	88 15 2c c3 11 f0    	mov    %dl,0xf011c32c
f0103c89:	c6 05 2e c3 11 f0 40 	movb   $0x40,0xf011c32e
f0103c90:	c1 e8 18             	shr    $0x18,%eax
f0103c93:	a2 2f c3 11 f0       	mov    %al,0xf011c32f
					sizeof(struct Taskstate), 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f0103c98:	c6 05 2d c3 11 f0 89 	movb   $0x89,0xf011c32d
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f0103c9f:	b8 28 00 00 00       	mov    $0x28,%eax
f0103ca4:	0f 00 d8             	ltr    %ax
}  

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f0103ca7:	b8 38 c3 11 f0       	mov    $0xf011c338,%eax
f0103cac:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f0103caf:	5d                   	pop    %ebp
f0103cb0:	c3                   	ret    

f0103cb1 <trap_init>:
}


void
trap_init(void)
{
f0103cb1:	55                   	push   %ebp
f0103cb2:	89 e5                	mov    %esp,%ebp
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.

	// Per-CPU setup 
	trap_init_percpu();
f0103cb4:	e8 9b ff ff ff       	call   f0103c54 <trap_init_percpu>
}
f0103cb9:	5d                   	pop    %ebp
f0103cba:	c3                   	ret    

f0103cbb <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103cbb:	55                   	push   %ebp
f0103cbc:	89 e5                	mov    %esp,%ebp
f0103cbe:	53                   	push   %ebx
f0103cbf:	83 ec 14             	sub    $0x14,%esp
f0103cc2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103cc5:	8b 03                	mov    (%ebx),%eax
f0103cc7:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103ccb:	c7 04 24 6e 65 10 f0 	movl   $0xf010656e,(%esp)
f0103cd2:	e8 44 ff ff ff       	call   f0103c1b <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103cd7:	8b 43 04             	mov    0x4(%ebx),%eax
f0103cda:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103cde:	c7 04 24 7d 65 10 f0 	movl   $0xf010657d,(%esp)
f0103ce5:	e8 31 ff ff ff       	call   f0103c1b <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103cea:	8b 43 08             	mov    0x8(%ebx),%eax
f0103ced:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103cf1:	c7 04 24 8c 65 10 f0 	movl   $0xf010658c,(%esp)
f0103cf8:	e8 1e ff ff ff       	call   f0103c1b <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103cfd:	8b 43 0c             	mov    0xc(%ebx),%eax
f0103d00:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103d04:	c7 04 24 9b 65 10 f0 	movl   $0xf010659b,(%esp)
f0103d0b:	e8 0b ff ff ff       	call   f0103c1b <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103d10:	8b 43 10             	mov    0x10(%ebx),%eax
f0103d13:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103d17:	c7 04 24 aa 65 10 f0 	movl   $0xf01065aa,(%esp)
f0103d1e:	e8 f8 fe ff ff       	call   f0103c1b <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103d23:	8b 43 14             	mov    0x14(%ebx),%eax
f0103d26:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103d2a:	c7 04 24 b9 65 10 f0 	movl   $0xf01065b9,(%esp)
f0103d31:	e8 e5 fe ff ff       	call   f0103c1b <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103d36:	8b 43 18             	mov    0x18(%ebx),%eax
f0103d39:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103d3d:	c7 04 24 c8 65 10 f0 	movl   $0xf01065c8,(%esp)
f0103d44:	e8 d2 fe ff ff       	call   f0103c1b <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103d49:	8b 43 1c             	mov    0x1c(%ebx),%eax
f0103d4c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103d50:	c7 04 24 d7 65 10 f0 	movl   $0xf01065d7,(%esp)
f0103d57:	e8 bf fe ff ff       	call   f0103c1b <cprintf>
}
f0103d5c:	83 c4 14             	add    $0x14,%esp
f0103d5f:	5b                   	pop    %ebx
f0103d60:	5d                   	pop    %ebp
f0103d61:	c3                   	ret    

f0103d62 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0103d62:	55                   	push   %ebp
f0103d63:	89 e5                	mov    %esp,%ebp
f0103d65:	56                   	push   %esi
f0103d66:	53                   	push   %ebx
f0103d67:	83 ec 10             	sub    $0x10,%esp
f0103d6a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p\n", tf);
f0103d6d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103d71:	c7 04 24 0d 67 10 f0 	movl   $0xf010670d,(%esp)
f0103d78:	e8 9e fe ff ff       	call   f0103c1b <cprintf>
	print_regs(&tf->tf_regs);
f0103d7d:	89 1c 24             	mov    %ebx,(%esp)
f0103d80:	e8 36 ff ff ff       	call   f0103cbb <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103d85:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103d89:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103d8d:	c7 04 24 e6 65 10 f0 	movl   $0xf01065e6,(%esp)
f0103d94:	e8 82 fe ff ff       	call   f0103c1b <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103d99:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103d9d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103da1:	c7 04 24 f9 65 10 f0 	movl   $0xf01065f9,(%esp)
f0103da8:	e8 6e fe ff ff       	call   f0103c1b <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103dad:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f0103db0:	83 f8 13             	cmp    $0x13,%eax
f0103db3:	77 09                	ja     f0103dbe <print_trapframe+0x5c>
		return excnames[trapno];
f0103db5:	8b 14 85 e0 68 10 f0 	mov    -0xfef9720(,%eax,4),%edx
f0103dbc:	eb 0f                	jmp    f0103dcd <print_trapframe+0x6b>
	if (trapno == T_SYSCALL)
f0103dbe:	ba 1b 66 10 f0       	mov    $0xf010661b,%edx
f0103dc3:	83 f8 30             	cmp    $0x30,%eax
f0103dc6:	74 05                	je     f0103dcd <print_trapframe+0x6b>
f0103dc8:	ba 0c 66 10 f0       	mov    $0xf010660c,%edx
{
	cprintf("TRAP frame at %p\n", tf);
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103dcd:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103dd1:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103dd5:	c7 04 24 27 66 10 f0 	movl   $0xf0106627,(%esp)
f0103ddc:	e8 3a fe ff ff       	call   f0103c1b <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103de1:	3b 1d e8 ce 19 f0    	cmp    0xf019cee8,%ebx
f0103de7:	75 19                	jne    f0103e02 <print_trapframe+0xa0>
f0103de9:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103ded:	75 13                	jne    f0103e02 <print_trapframe+0xa0>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0103def:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103df2:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103df6:	c7 04 24 39 66 10 f0 	movl   $0xf0106639,(%esp)
f0103dfd:	e8 19 fe ff ff       	call   f0103c1b <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f0103e02:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0103e05:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103e09:	c7 04 24 48 66 10 f0 	movl   $0xf0106648,(%esp)
f0103e10:	e8 06 fe ff ff       	call   f0103c1b <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0103e15:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103e19:	75 47                	jne    f0103e62 <print_trapframe+0x100>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0103e1b:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0103e1e:	be 62 66 10 f0       	mov    $0xf0106662,%esi
f0103e23:	a8 01                	test   $0x1,%al
f0103e25:	75 05                	jne    f0103e2c <print_trapframe+0xca>
f0103e27:	be 56 66 10 f0       	mov    $0xf0106656,%esi
f0103e2c:	b9 72 66 10 f0       	mov    $0xf0106672,%ecx
f0103e31:	a8 02                	test   $0x2,%al
f0103e33:	75 05                	jne    f0103e3a <print_trapframe+0xd8>
f0103e35:	b9 6d 66 10 f0       	mov    $0xf010666d,%ecx
f0103e3a:	ba 78 66 10 f0       	mov    $0xf0106678,%edx
f0103e3f:	a8 04                	test   $0x4,%al
f0103e41:	75 05                	jne    f0103e48 <print_trapframe+0xe6>
f0103e43:	ba 38 67 10 f0       	mov    $0xf0106738,%edx
f0103e48:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0103e4c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0103e50:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103e54:	c7 04 24 7d 66 10 f0 	movl   $0xf010667d,(%esp)
f0103e5b:	e8 bb fd ff ff       	call   f0103c1b <cprintf>
f0103e60:	eb 0c                	jmp    f0103e6e <print_trapframe+0x10c>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0103e62:	c7 04 24 85 62 10 f0 	movl   $0xf0106285,(%esp)
f0103e69:	e8 ad fd ff ff       	call   f0103c1b <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103e6e:	8b 43 30             	mov    0x30(%ebx),%eax
f0103e71:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103e75:	c7 04 24 8c 66 10 f0 	movl   $0xf010668c,(%esp)
f0103e7c:	e8 9a fd ff ff       	call   f0103c1b <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103e81:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103e85:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103e89:	c7 04 24 9b 66 10 f0 	movl   $0xf010669b,(%esp)
f0103e90:	e8 86 fd ff ff       	call   f0103c1b <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103e95:	8b 43 38             	mov    0x38(%ebx),%eax
f0103e98:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103e9c:	c7 04 24 ae 66 10 f0 	movl   $0xf01066ae,(%esp)
f0103ea3:	e8 73 fd ff ff       	call   f0103c1b <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103ea8:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103eac:	74 27                	je     f0103ed5 <print_trapframe+0x173>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103eae:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0103eb1:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103eb5:	c7 04 24 bd 66 10 f0 	movl   $0xf01066bd,(%esp)
f0103ebc:	e8 5a fd ff ff       	call   f0103c1b <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103ec1:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103ec5:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103ec9:	c7 04 24 cc 66 10 f0 	movl   $0xf01066cc,(%esp)
f0103ed0:	e8 46 fd ff ff       	call   f0103c1b <cprintf>
	}
}
f0103ed5:	83 c4 10             	add    $0x10,%esp
f0103ed8:	5b                   	pop    %ebx
f0103ed9:	5e                   	pop    %esi
f0103eda:	5d                   	pop    %ebp
f0103edb:	c3                   	ret    

f0103edc <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103edc:	55                   	push   %ebp
f0103edd:	89 e5                	mov    %esp,%ebp
f0103edf:	53                   	push   %ebx
f0103ee0:	83 ec 14             	sub    $0x14,%esp
f0103ee3:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103ee6:	0f 20 d0             	mov    %cr2,%eax

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103ee9:	8b 53 30             	mov    0x30(%ebx),%edx
f0103eec:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103ef0:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103ef4:	a1 5c c6 19 f0       	mov    0xf019c65c,%eax
f0103ef9:	8b 40 48             	mov    0x48(%eax),%eax
f0103efc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103f00:	c7 04 24 84 68 10 f0 	movl   $0xf0106884,(%esp)
f0103f07:	e8 0f fd ff ff       	call   f0103c1b <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0103f0c:	89 1c 24             	mov    %ebx,(%esp)
f0103f0f:	e8 4e fe ff ff       	call   f0103d62 <print_trapframe>
	env_destroy(curenv);
f0103f14:	a1 5c c6 19 f0       	mov    0xf019c65c,%eax
f0103f19:	89 04 24             	mov    %eax,(%esp)
f0103f1c:	e8 45 fb ff ff       	call   f0103a66 <env_destroy>
}
f0103f21:	83 c4 14             	add    $0x14,%esp
f0103f24:	5b                   	pop    %ebx
f0103f25:	5d                   	pop    %ebp
f0103f26:	c3                   	ret    

f0103f27 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0103f27:	55                   	push   %ebp
f0103f28:	89 e5                	mov    %esp,%ebp
f0103f2a:	57                   	push   %edi
f0103f2b:	56                   	push   %esi
f0103f2c:	83 ec 10             	sub    $0x10,%esp
f0103f2f:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0103f32:	fc                   	cld    

static __inline uint32_t
read_eflags(void)
{
        uint32_t eflags;
        __asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0103f33:	9c                   	pushf  
f0103f34:	58                   	pop    %eax

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0103f35:	f6 c4 02             	test   $0x2,%ah
f0103f38:	74 24                	je     f0103f5e <trap+0x37>
f0103f3a:	c7 44 24 0c df 66 10 	movl   $0xf01066df,0xc(%esp)
f0103f41:	f0 
f0103f42:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0103f49:	f0 
f0103f4a:	c7 44 24 04 a7 00 00 	movl   $0xa7,0x4(%esp)
f0103f51:	00 
f0103f52:	c7 04 24 f8 66 10 f0 	movl   $0xf01066f8,(%esp)
f0103f59:	e8 27 c1 ff ff       	call   f0100085 <_panic>

	cprintf("Incoming TRAP frame at %p\n", tf);
f0103f5e:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103f62:	c7 04 24 04 67 10 f0 	movl   $0xf0106704,(%esp)
f0103f69:	e8 ad fc ff ff       	call   f0103c1b <cprintf>

	if ((tf->tf_cs & 3) == 3) {
f0103f6e:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0103f72:	83 e0 03             	and    $0x3,%eax
f0103f75:	83 f8 03             	cmp    $0x3,%eax
f0103f78:	75 3c                	jne    f0103fb6 <trap+0x8f>
		// Trapped from user mode.
		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		assert(curenv);
f0103f7a:	a1 5c c6 19 f0       	mov    0xf019c65c,%eax
f0103f7f:	85 c0                	test   %eax,%eax
f0103f81:	75 24                	jne    f0103fa7 <trap+0x80>
f0103f83:	c7 44 24 0c 1f 67 10 	movl   $0xf010671f,0xc(%esp)
f0103f8a:	f0 
f0103f8b:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0103f92:	f0 
f0103f93:	c7 44 24 04 b0 00 00 	movl   $0xb0,0x4(%esp)
f0103f9a:	00 
f0103f9b:	c7 04 24 f8 66 10 f0 	movl   $0xf01066f8,(%esp)
f0103fa2:	e8 de c0 ff ff       	call   f0100085 <_panic>
		curenv->env_tf = *tf;
f0103fa7:	b9 11 00 00 00       	mov    $0x11,%ecx
f0103fac:	89 c7                	mov    %eax,%edi
f0103fae:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0103fb0:	8b 35 5c c6 19 f0    	mov    0xf019c65c,%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0103fb6:	89 35 e8 ce 19 f0    	mov    %esi,0xf019cee8
{
	// Handle processor exceptions.
	// LAB 3: Your code here.

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0103fbc:	89 34 24             	mov    %esi,(%esp)
f0103fbf:	e8 9e fd ff ff       	call   f0103d62 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0103fc4:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0103fc9:	75 1c                	jne    f0103fe7 <trap+0xc0>
		panic("unhandled trap in kernel");
f0103fcb:	c7 44 24 08 26 67 10 	movl   $0xf0106726,0x8(%esp)
f0103fd2:	f0 
f0103fd3:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
f0103fda:	00 
f0103fdb:	c7 04 24 f8 66 10 f0 	movl   $0xf01066f8,(%esp)
f0103fe2:	e8 9e c0 ff ff       	call   f0100085 <_panic>
	else {
		env_destroy(curenv);
f0103fe7:	a1 5c c6 19 f0       	mov    0xf019c65c,%eax
f0103fec:	89 04 24             	mov    %eax,(%esp)
f0103fef:	e8 72 fa ff ff       	call   f0103a66 <env_destroy>

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);

	// Return to the current environment, which should be running.
	assert(curenv && curenv->env_status == ENV_RUNNING);
f0103ff4:	a1 5c c6 19 f0       	mov    0xf019c65c,%eax
f0103ff9:	85 c0                	test   %eax,%eax
f0103ffb:	74 06                	je     f0104003 <trap+0xdc>
f0103ffd:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f0104001:	74 24                	je     f0104027 <trap+0x100>
f0104003:	c7 44 24 0c a8 68 10 	movl   $0xf01068a8,0xc(%esp)
f010400a:	f0 
f010400b:	c7 44 24 08 aa 60 10 	movl   $0xf01060aa,0x8(%esp)
f0104012:	f0 
f0104013:	c7 44 24 04 be 00 00 	movl   $0xbe,0x4(%esp)
f010401a:	00 
f010401b:	c7 04 24 f8 66 10 f0 	movl   $0xf01066f8,(%esp)
f0104022:	e8 5e c0 ff ff       	call   f0100085 <_panic>
	env_run(curenv);
f0104027:	89 04 24             	mov    %eax,(%esp)
f010402a:	e8 00 f8 ff ff       	call   f010382f <env_run>
	...

f0104030 <syscall>:
f0104030:	55                   	push   %ebp
f0104031:	89 e5                	mov    %esp,%ebp
f0104033:	83 ec 18             	sub    $0x18,%esp
f0104036:	c7 44 24 08 30 69 10 	movl   $0xf0106930,0x8(%esp)
f010403d:	f0 
f010403e:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
f0104045:	00 
f0104046:	c7 04 24 48 69 10 f0 	movl   $0xf0106948,(%esp)
f010404d:	e8 33 c0 ff ff       	call   f0100085 <_panic>
	...

f0104060 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104060:	55                   	push   %ebp
f0104061:	89 e5                	mov    %esp,%ebp
f0104063:	57                   	push   %edi
f0104064:	56                   	push   %esi
f0104065:	53                   	push   %ebx
f0104066:	83 ec 14             	sub    $0x14,%esp
f0104069:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010406c:	89 55 e8             	mov    %edx,-0x18(%ebp)
f010406f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104072:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104075:	8b 1a                	mov    (%edx),%ebx
f0104077:	8b 01                	mov    (%ecx),%eax
f0104079:	89 45 ec             	mov    %eax,-0x14(%ebp)
	
	while (l <= r) {
f010407c:	39 c3                	cmp    %eax,%ebx
f010407e:	0f 8f 9c 00 00 00    	jg     f0104120 <stab_binsearch+0xc0>
f0104084:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		int true_m = (l + r) / 2, m = true_m;
f010408b:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010408e:	01 d8                	add    %ebx,%eax
f0104090:	89 c7                	mov    %eax,%edi
f0104092:	c1 ef 1f             	shr    $0x1f,%edi
f0104095:	01 c7                	add    %eax,%edi
f0104097:	d1 ff                	sar    %edi
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104099:	39 df                	cmp    %ebx,%edi
f010409b:	7c 33                	jl     f01040d0 <stab_binsearch+0x70>
f010409d:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f01040a0:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01040a3:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f01040a8:	39 f0                	cmp    %esi,%eax
f01040aa:	0f 84 bc 00 00 00    	je     f010416c <stab_binsearch+0x10c>
f01040b0:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
f01040b4:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
f01040b8:	89 f8                	mov    %edi,%eax
			m--;
f01040ba:	83 e8 01             	sub    $0x1,%eax
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01040bd:	39 d8                	cmp    %ebx,%eax
f01040bf:	7c 0f                	jl     f01040d0 <stab_binsearch+0x70>
f01040c1:	0f b6 0a             	movzbl (%edx),%ecx
f01040c4:	83 ea 0c             	sub    $0xc,%edx
f01040c7:	39 f1                	cmp    %esi,%ecx
f01040c9:	75 ef                	jne    f01040ba <stab_binsearch+0x5a>
f01040cb:	e9 9e 00 00 00       	jmp    f010416e <stab_binsearch+0x10e>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f01040d0:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f01040d3:	eb 3c                	jmp    f0104111 <stab_binsearch+0xb1>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f01040d5:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f01040d8:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
f01040da:	8d 5f 01             	lea    0x1(%edi),%ebx
f01040dd:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f01040e4:	eb 2b                	jmp    f0104111 <stab_binsearch+0xb1>
		} else if (stabs[m].n_value > addr) {
f01040e6:	3b 55 0c             	cmp    0xc(%ebp),%edx
f01040e9:	76 14                	jbe    f01040ff <stab_binsearch+0x9f>
			*region_right = m - 1;
f01040eb:	83 e8 01             	sub    $0x1,%eax
f01040ee:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01040f1:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01040f4:	89 02                	mov    %eax,(%edx)
f01040f6:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f01040fd:	eb 12                	jmp    f0104111 <stab_binsearch+0xb1>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f01040ff:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0104102:	89 01                	mov    %eax,(%ecx)
			l = m;
			addr++;
f0104104:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0104108:	89 c3                	mov    %eax,%ebx
f010410a:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
	
	while (l <= r) {
f0104111:	39 5d ec             	cmp    %ebx,-0x14(%ebp)
f0104114:	0f 8d 71 ff ff ff    	jge    f010408b <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f010411a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010411e:	75 0f                	jne    f010412f <stab_binsearch+0xcf>
		*region_right = *region_left - 1;
f0104120:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0104123:	8b 03                	mov    (%ebx),%eax
f0104125:	83 e8 01             	sub    $0x1,%eax
f0104128:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010412b:	89 02                	mov    %eax,(%edx)
f010412d:	eb 57                	jmp    f0104186 <stab_binsearch+0x126>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010412f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0104132:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104134:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0104137:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104139:	39 c1                	cmp    %eax,%ecx
f010413b:	7d 28                	jge    f0104165 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f010413d:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104140:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f0104143:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
f0104148:	39 f2                	cmp    %esi,%edx
f010414a:	74 19                	je     f0104165 <stab_binsearch+0x105>
f010414c:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
f0104150:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		     l--)
f0104154:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104157:	39 c1                	cmp    %eax,%ecx
f0104159:	7d 0a                	jge    f0104165 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f010415b:	0f b6 1a             	movzbl (%edx),%ebx
f010415e:	83 ea 0c             	sub    $0xc,%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104161:	39 f3                	cmp    %esi,%ebx
f0104163:	75 ef                	jne    f0104154 <stab_binsearch+0xf4>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
f0104165:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0104168:	89 02                	mov    %eax,(%edx)
f010416a:	eb 1a                	jmp    f0104186 <stab_binsearch+0x126>
	}
}
f010416c:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f010416e:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104171:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0104174:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104178:	3b 55 0c             	cmp    0xc(%ebp),%edx
f010417b:	0f 82 54 ff ff ff    	jb     f01040d5 <stab_binsearch+0x75>
f0104181:	e9 60 ff ff ff       	jmp    f01040e6 <stab_binsearch+0x86>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0104186:	83 c4 14             	add    $0x14,%esp
f0104189:	5b                   	pop    %ebx
f010418a:	5e                   	pop    %esi
f010418b:	5f                   	pop    %edi
f010418c:	5d                   	pop    %ebp
f010418d:	c3                   	ret    

f010418e <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f010418e:	55                   	push   %ebp
f010418f:	89 e5                	mov    %esp,%ebp
f0104191:	83 ec 48             	sub    $0x48,%esp
f0104194:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0104197:	89 75 f8             	mov    %esi,-0x8(%ebp)
f010419a:	89 7d fc             	mov    %edi,-0x4(%ebp)
f010419d:	8b 7d 08             	mov    0x8(%ebp),%edi
f01041a0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01041a3:	c7 03 57 69 10 f0    	movl   $0xf0106957,(%ebx)
	info->eip_line = 0;
f01041a9:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f01041b0:	c7 43 08 57 69 10 f0 	movl   $0xf0106957,0x8(%ebx)
	info->eip_fn_namelen = 9;
f01041b7:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f01041be:	89 7b 10             	mov    %edi,0x10(%ebx)
	info->eip_fn_narg = 0;
f01041c1:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01041c8:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f01041ce:	76 1a                	jbe    f01041ea <debuginfo_eip+0x5c>
f01041d0:	be 63 15 11 f0       	mov    $0xf0111563,%esi
f01041d5:	c7 45 d4 25 e8 10 f0 	movl   $0xf010e825,-0x2c(%ebp)
f01041dc:	b8 24 e8 10 f0       	mov    $0xf010e824,%eax
f01041e1:	c7 45 d0 ec 6b 10 f0 	movl   $0xf0106bec,-0x30(%ebp)
f01041e8:	eb 16                	jmp    f0104200 <debuginfo_eip+0x72>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f01041ea:	ba 00 00 20 00       	mov    $0x200000,%edx
f01041ef:	8b 02                	mov    (%edx),%eax
f01041f1:	89 45 d0             	mov    %eax,-0x30(%ebp)
		stab_end = usd->stab_end;
f01041f4:	8b 42 04             	mov    0x4(%edx),%eax
		stabstr = usd->stabstr;
f01041f7:	8b 4a 08             	mov    0x8(%edx),%ecx
f01041fa:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
		stabstr_end = usd->stabstr_end;
f01041fd:	8b 72 0c             	mov    0xc(%edx),%esi
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104200:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
f0104203:	0f 83 5c 01 00 00    	jae    f0104365 <debuginfo_eip+0x1d7>
f0104209:	80 7e ff 00          	cmpb   $0x0,-0x1(%esi)
f010420d:	0f 85 52 01 00 00    	jne    f0104365 <debuginfo_eip+0x1d7>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.
	
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104213:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f010421a:	2b 45 d0             	sub    -0x30(%ebp),%eax
f010421d:	c1 f8 02             	sar    $0x2,%eax
f0104220:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0104226:	83 e8 01             	sub    $0x1,%eax
f0104229:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f010422c:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f010422f:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104232:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104236:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f010423d:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104240:	e8 1b fe ff ff       	call   f0104060 <stab_binsearch>
	if (lfile == 0)
f0104245:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104248:	85 c0                	test   %eax,%eax
f010424a:	0f 84 15 01 00 00    	je     f0104365 <debuginfo_eip+0x1d7>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0104250:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0104253:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104256:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104259:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f010425c:	8d 55 dc             	lea    -0x24(%ebp),%edx
f010425f:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104263:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f010426a:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010426d:	e8 ee fd ff ff       	call   f0104060 <stab_binsearch>

	if (lfun <= rfun) {
f0104272:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104275:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0104278:	7f 2a                	jg     f01042a4 <debuginfo_eip+0x116>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f010427a:	6b c0 0c             	imul   $0xc,%eax,%eax
f010427d:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0104280:	8b 04 10             	mov    (%eax,%edx,1),%eax
f0104283:	89 f2                	mov    %esi,%edx
f0104285:	2b 55 d4             	sub    -0x2c(%ebp),%edx
f0104288:	39 d0                	cmp    %edx,%eax
f010428a:	73 06                	jae    f0104292 <debuginfo_eip+0x104>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f010428c:	03 45 d4             	add    -0x2c(%ebp),%eax
f010428f:	89 43 08             	mov    %eax,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104292:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0104295:	6b c7 0c             	imul   $0xc,%edi,%eax
f0104298:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f010429b:	8b 44 08 08          	mov    0x8(%eax,%ecx,1),%eax
f010429f:	89 43 10             	mov    %eax,0x10(%ebx)
f01042a2:	eb 06                	jmp    f01042aa <debuginfo_eip+0x11c>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f01042a4:	89 7b 10             	mov    %edi,0x10(%ebx)
		lline = lfile;
f01042a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f01042aa:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f01042b1:	00 
f01042b2:	8b 43 08             	mov    0x8(%ebx),%eax
f01042b5:	89 04 24             	mov    %eax,(%esp)
f01042b8:	e8 6e 0b 00 00       	call   f0104e2b <strfind>
f01042bd:	2b 43 08             	sub    0x8(%ebx),%eax
f01042c0:	89 43 0c             	mov    %eax,0xc(%ebx)
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
f01042c3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01042c6:	89 45 cc             	mov    %eax,-0x34(%ebp)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01042c9:	39 c7                	cmp    %eax,%edi
f01042cb:	7c 5a                	jl     f0104327 <debuginfo_eip+0x199>
	       && stabs[lline].n_type != N_SOL
f01042cd:	6b cf 0c             	imul   $0xc,%edi,%ecx
f01042d0:	03 4d d0             	add    -0x30(%ebp),%ecx
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01042d3:	0f b6 51 04          	movzbl 0x4(%ecx),%edx
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01042d7:	80 fa 84             	cmp    $0x84,%dl
f01042da:	74 36                	je     f0104312 <debuginfo_eip+0x184>
f01042dc:	8d 47 ff             	lea    -0x1(%edi),%eax
f01042df:	6b c0 0c             	imul   $0xc,%eax,%eax
f01042e2:	03 45 d0             	add    -0x30(%ebp),%eax
f01042e5:	eb 16                	jmp    f01042fd <debuginfo_eip+0x16f>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f01042e7:	83 ef 01             	sub    $0x1,%edi
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01042ea:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f01042ed:	7f 38                	jg     f0104327 <debuginfo_eip+0x199>
f01042ef:	89 c1                	mov    %eax,%ecx
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01042f1:	0f b6 50 04          	movzbl 0x4(%eax),%edx
f01042f5:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01042f8:	80 fa 84             	cmp    $0x84,%dl
f01042fb:	74 15                	je     f0104312 <debuginfo_eip+0x184>
f01042fd:	80 fa 64             	cmp    $0x64,%dl
f0104300:	75 e5                	jne    f01042e7 <debuginfo_eip+0x159>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104302:	83 79 08 00          	cmpl   $0x0,0x8(%ecx)
f0104306:	74 df                	je     f01042e7 <debuginfo_eip+0x159>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104308:	3b 7d cc             	cmp    -0x34(%ebp),%edi
f010430b:	90                   	nop
f010430c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104310:	7c 15                	jl     f0104327 <debuginfo_eip+0x199>
f0104312:	6b ff 0c             	imul   $0xc,%edi,%edi
f0104315:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0104318:	8b 04 17             	mov    (%edi,%edx,1),%eax
f010431b:	2b 75 d4             	sub    -0x2c(%ebp),%esi
f010431e:	39 f0                	cmp    %esi,%eax
f0104320:	73 05                	jae    f0104327 <debuginfo_eip+0x199>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104322:	03 45 d4             	add    -0x2c(%ebp),%eax
f0104325:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104327:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010432a:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f010432d:	39 ca                	cmp    %ecx,%edx
f010432f:	7d 3b                	jge    f010436c <debuginfo_eip+0x1de>
		for (lline = lfun + 1;
f0104331:	8d 42 01             	lea    0x1(%edx),%eax
f0104334:	39 c1                	cmp    %eax,%ecx
f0104336:	7e 34                	jle    f010436c <debuginfo_eip+0x1de>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104338:	6b c8 0c             	imul   $0xc,%eax,%ecx
f010433b:	8b 75 d0             	mov    -0x30(%ebp),%esi
f010433e:	80 7c 31 04 a0       	cmpb   $0xa0,0x4(%ecx,%esi,1)
f0104343:	75 27                	jne    f010436c <debuginfo_eip+0x1de>
f0104345:	6b d2 0c             	imul   $0xc,%edx,%edx
f0104348:	8d 54 16 1c          	lea    0x1c(%esi,%edx,1),%edx
		     lline++)
			info->eip_fn_narg++;
f010434c:	83 43 14 01          	addl   $0x1,0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0104350:	83 c0 01             	add    $0x1,%eax


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0104353:	39 45 d8             	cmp    %eax,-0x28(%ebp)
f0104356:	7e 14                	jle    f010436c <debuginfo_eip+0x1de>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104358:	0f b6 0a             	movzbl (%edx),%ecx
f010435b:	83 c2 0c             	add    $0xc,%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f010435e:	80 f9 a0             	cmp    $0xa0,%cl
f0104361:	74 e9                	je     f010434c <debuginfo_eip+0x1be>
f0104363:	eb 07                	jmp    f010436c <debuginfo_eip+0x1de>
f0104365:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010436a:	eb 05                	jmp    f0104371 <debuginfo_eip+0x1e3>
f010436c:	b8 00 00 00 00       	mov    $0x0,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
	
	return 0;
}
f0104371:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0104374:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0104377:	8b 7d fc             	mov    -0x4(%ebp),%edi
f010437a:	89 ec                	mov    %ebp,%esp
f010437c:	5d                   	pop    %ebp
f010437d:	c3                   	ret    
	...

f0104380 <printnum_nopad>:

/*
* help function added by Lu to print only the num;
*/
static void printnum_nopad(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int *num_len){
f0104380:	55                   	push   %ebp
f0104381:	89 e5                	mov    %esp,%ebp
f0104383:	83 ec 48             	sub    $0x48,%esp
f0104386:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0104389:	89 75 f8             	mov    %esi,-0x8(%ebp)
f010438c:	89 7d fc             	mov    %edi,-0x4(%ebp)
f010438f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0104392:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0104395:	8b 45 08             	mov    0x8(%ebp),%eax
f0104398:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010439b:	8b 75 0c             	mov    0xc(%ebp),%esi
f010439e:	8b 45 10             	mov    0x10(%ebp),%eax
f01043a1:	8b 7d 14             	mov    0x14(%ebp),%edi
	if(num >= base){
f01043a4:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01043a7:	ba 00 00 00 00       	mov    $0x0,%edx
f01043ac:	39 f2                	cmp    %esi,%edx
f01043ae:	72 07                	jb     f01043b7 <printnum_nopad+0x37>
f01043b0:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f01043b3:	39 c8                	cmp    %ecx,%eax
f01043b5:	77 54                	ja     f010440b <printnum_nopad+0x8b>
		printnum_nopad(putch, putdat, num / base, base, num_len);
f01043b7:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01043bb:	89 44 24 08          	mov    %eax,0x8(%esp)
f01043bf:	8b 44 24 08          	mov    0x8(%esp),%eax
f01043c3:	8b 54 24 0c          	mov    0xc(%esp),%edx
f01043c7:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01043ca:	89 55 cc             	mov    %edx,-0x34(%ebp)
f01043cd:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01043d0:	89 54 24 08          	mov    %edx,0x8(%esp)
f01043d4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01043db:	00 
f01043dc:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f01043df:	89 0c 24             	mov    %ecx,(%esp)
f01043e2:	89 74 24 04          	mov    %esi,0x4(%esp)
f01043e6:	e8 d5 0c 00 00       	call   f01050c0 <__udivdi3>
f01043eb:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01043ee:	8b 5d cc             	mov    -0x34(%ebp),%ebx
f01043f1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01043f5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01043f9:	89 04 24             	mov    %eax,(%esp)
f01043fc:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104400:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104403:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104406:	e8 75 ff ff ff       	call   f0104380 <printnum_nopad>
	}
	*num_len += 1 ;
f010440b:	83 07 01             	addl   $0x1,(%edi)
	putch("0123456789abcdef"[num % base], putdat);
f010440e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104411:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104415:	8b 04 24             	mov    (%esp),%eax
f0104418:	8b 54 24 04          	mov    0x4(%esp),%edx
f010441c:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010441f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104422:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104425:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104429:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0104430:	00 
f0104431:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0104434:	89 0c 24             	mov    %ecx,(%esp)
f0104437:	89 74 24 04          	mov    %esi,0x4(%esp)
f010443b:	e8 b0 0d 00 00       	call   f01051f0 <__umoddi3>
f0104440:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0104443:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0104447:	0f be 80 61 69 10 f0 	movsbl -0xfef969f(%eax),%eax
f010444e:	89 04 24             	mov    %eax,(%esp)
f0104451:	ff 55 d4             	call   *-0x2c(%ebp)
}
f0104454:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0104457:	8b 75 f8             	mov    -0x8(%ebp),%esi
f010445a:	8b 7d fc             	mov    -0x4(%ebp),%edi
f010445d:	89 ec                	mov    %ebp,%esp
f010445f:	5d                   	pop    %ebp
f0104460:	c3                   	ret    

f0104461 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104461:	55                   	push   %ebp
f0104462:	89 e5                	mov    %esp,%ebp
f0104464:	57                   	push   %edi
f0104465:	56                   	push   %esi
f0104466:	53                   	push   %ebx
f0104467:	83 ec 5c             	sub    $0x5c,%esp
f010446a:	89 c7                	mov    %eax,%edi
f010446c:	89 d6                	mov    %edx,%esi
f010446e:	8b 45 08             	mov    0x8(%ebp),%eax
f0104471:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0104474:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104477:	89 55 cc             	mov    %edx,-0x34(%ebp)
f010447a:	8b 45 10             	mov    0x10(%ebp),%eax
f010447d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	if(padc == '-'){
f0104480:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
f0104484:	75 4c                	jne    f01044d2 <printnum+0x71>
		int num_len = 0;
f0104486:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		printnum_nopad(putch, putdat, num, base, &num_len);
f010448d:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104490:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0104494:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104498:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f010449b:	89 0c 24             	mov    %ecx,(%esp)
f010449e:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01044a1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01044a5:	89 f2                	mov    %esi,%edx
f01044a7:	89 f8                	mov    %edi,%eax
f01044a9:	e8 d2 fe ff ff       	call   f0104380 <printnum_nopad>
		width -= num_len;
f01044ae:	2b 5d e4             	sub    -0x1c(%ebp),%ebx
		while (width-- > 0)
f01044b1:	85 db                	test   %ebx,%ebx
f01044b3:	0f 8e e8 00 00 00    	jle    f01045a1 <printnum+0x140>
			putch(' ', putdat);
f01044b9:	89 74 24 04          	mov    %esi,0x4(%esp)
f01044bd:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f01044c4:	ff d7                	call   *%edi
f01044c6:	83 eb 01             	sub    $0x1,%ebx
	// your code here:
	if(padc == '-'){
		int num_len = 0;
		printnum_nopad(putch, putdat, num, base, &num_len);
		width -= num_len;
		while (width-- > 0)
f01044c9:	85 db                	test   %ebx,%ebx
f01044cb:	7f ec                	jg     f01044b9 <printnum+0x58>
f01044cd:	e9 cf 00 00 00       	jmp    f01045a1 <printnum+0x140>
			putch(' ', putdat);
	}
	else{
		// first recursively print all preceding (more significant) digits
		if (num >= base) {
f01044d2:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f01044d5:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
f01044d9:	77 19                	ja     f01044f4 <printnum+0x93>
f01044db:	90                   	nop
f01044dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01044e0:	72 05                	jb     f01044e7 <printnum+0x86>
f01044e2:	39 45 c8             	cmp    %eax,-0x38(%ebp)
f01044e5:	73 0d                	jae    f01044f4 <printnum+0x93>
			printnum(putch, putdat, num / base, base, width - 1, padc);
		} else {
			// print any needed pad characters before first digit
			while (--width > 0)
f01044e7:	83 eb 01             	sub    $0x1,%ebx
f01044ea:	85 db                	test   %ebx,%ebx
f01044ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01044f0:	7f 63                	jg     f0104555 <printnum+0xf4>
f01044f2:	eb 74                	jmp    f0104568 <printnum+0x107>
			putch(' ', putdat);
	}
	else{
		// first recursively print all preceding (more significant) digits
		if (num >= base) {
			printnum(putch, putdat, num / base, base, width - 1, padc);
f01044f4:	8b 55 18             	mov    0x18(%ebp),%edx
f01044f7:	89 54 24 10          	mov    %edx,0x10(%esp)
f01044fb:	83 eb 01             	sub    $0x1,%ebx
f01044fe:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0104502:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104506:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f010450a:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
f010450e:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0104511:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
f0104514:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0104517:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010451b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0104522:	00 
f0104523:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0104526:	89 04 24             	mov    %eax,(%esp)
f0104529:	8b 55 cc             	mov    -0x34(%ebp),%edx
f010452c:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104530:	e8 8b 0b 00 00       	call   f01050c0 <__udivdi3>
f0104535:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0104538:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010453b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010453f:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0104543:	89 04 24             	mov    %eax,(%esp)
f0104546:	89 54 24 04          	mov    %edx,0x4(%esp)
f010454a:	89 f2                	mov    %esi,%edx
f010454c:	89 f8                	mov    %edi,%eax
f010454e:	e8 0e ff ff ff       	call   f0104461 <printnum>
f0104553:	eb 13                	jmp    f0104568 <printnum+0x107>
		} else {
			// print any needed pad characters before first digit
			while (--width > 0)
				putch(padc, putdat);
f0104555:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104559:	8b 45 18             	mov    0x18(%ebp),%eax
f010455c:	89 04 24             	mov    %eax,(%esp)
f010455f:	ff d7                	call   *%edi
		// first recursively print all preceding (more significant) digits
		if (num >= base) {
			printnum(putch, putdat, num / base, base, width - 1, padc);
		} else {
			// print any needed pad characters before first digit
			while (--width > 0)
f0104561:	83 eb 01             	sub    $0x1,%ebx
f0104564:	85 db                	test   %ebx,%ebx
f0104566:	7f ed                	jg     f0104555 <printnum+0xf4>
				putch(padc, putdat);
		}

		// then print this (the least significant) digit
		putch("0123456789abcdef"[num % base], putdat);
f0104568:	89 74 24 04          	mov    %esi,0x4(%esp)
f010456c:	8b 74 24 04          	mov    0x4(%esp),%esi
f0104570:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0104573:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104577:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f010457e:	00 
f010457f:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0104582:	89 0c 24             	mov    %ecx,(%esp)
f0104585:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0104588:	89 44 24 04          	mov    %eax,0x4(%esp)
f010458c:	e8 5f 0c 00 00       	call   f01051f0 <__umoddi3>
f0104591:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104595:	0f be 80 61 69 10 f0 	movsbl -0xfef969f(%eax),%eax
f010459c:	89 04 24             	mov    %eax,(%esp)
f010459f:	ff d7                	call   *%edi
	}
	
}
f01045a1:	83 c4 5c             	add    $0x5c,%esp
f01045a4:	5b                   	pop    %ebx
f01045a5:	5e                   	pop    %esi
f01045a6:	5f                   	pop    %edi
f01045a7:	5d                   	pop    %ebp
f01045a8:	c3                   	ret    

f01045a9 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f01045a9:	55                   	push   %ebp
f01045aa:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f01045ac:	83 fa 01             	cmp    $0x1,%edx
f01045af:	7e 0e                	jle    f01045bf <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f01045b1:	8b 10                	mov    (%eax),%edx
f01045b3:	8d 4a 08             	lea    0x8(%edx),%ecx
f01045b6:	89 08                	mov    %ecx,(%eax)
f01045b8:	8b 02                	mov    (%edx),%eax
f01045ba:	8b 52 04             	mov    0x4(%edx),%edx
f01045bd:	eb 22                	jmp    f01045e1 <getuint+0x38>
	else if (lflag)
f01045bf:	85 d2                	test   %edx,%edx
f01045c1:	74 10                	je     f01045d3 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f01045c3:	8b 10                	mov    (%eax),%edx
f01045c5:	8d 4a 04             	lea    0x4(%edx),%ecx
f01045c8:	89 08                	mov    %ecx,(%eax)
f01045ca:	8b 02                	mov    (%edx),%eax
f01045cc:	ba 00 00 00 00       	mov    $0x0,%edx
f01045d1:	eb 0e                	jmp    f01045e1 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f01045d3:	8b 10                	mov    (%eax),%edx
f01045d5:	8d 4a 04             	lea    0x4(%edx),%ecx
f01045d8:	89 08                	mov    %ecx,(%eax)
f01045da:	8b 02                	mov    (%edx),%eax
f01045dc:	ba 00 00 00 00       	mov    $0x0,%edx
}
f01045e1:	5d                   	pop    %ebp
f01045e2:	c3                   	ret    

f01045e3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01045e3:	55                   	push   %ebp
f01045e4:	89 e5                	mov    %esp,%ebp
f01045e6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01045e9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f01045ed:	8b 10                	mov    (%eax),%edx
f01045ef:	3b 50 04             	cmp    0x4(%eax),%edx
f01045f2:	73 0a                	jae    f01045fe <sprintputch+0x1b>
		*b->buf++ = ch;
f01045f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01045f7:	88 0a                	mov    %cl,(%edx)
f01045f9:	83 c2 01             	add    $0x1,%edx
f01045fc:	89 10                	mov    %edx,(%eax)
}
f01045fe:	5d                   	pop    %ebp
f01045ff:	c3                   	ret    

f0104600 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0104600:	55                   	push   %ebp
f0104601:	89 e5                	mov    %esp,%ebp
f0104603:	57                   	push   %edi
f0104604:	56                   	push   %esi
f0104605:	53                   	push   %ebx
f0104606:	83 ec 5c             	sub    $0x5c,%esp
f0104609:	8b 7d 0c             	mov    0xc(%ebp),%edi
f010460c:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f010460f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
f0104616:	eb 12                	jmp    f010462a <vprintfmt+0x2a>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0104618:	85 c0                	test   %eax,%eax
f010461a:	0f 84 c6 04 00 00    	je     f0104ae6 <vprintfmt+0x4e6>
				return;
			putch(ch, putdat);
f0104620:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104624:	89 04 24             	mov    %eax,(%esp)
f0104627:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f010462a:	0f b6 03             	movzbl (%ebx),%eax
f010462d:	83 c3 01             	add    $0x1,%ebx
f0104630:	83 f8 25             	cmp    $0x25,%eax
f0104633:	75 e3                	jne    f0104618 <vprintfmt+0x18>
f0104635:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
f0104639:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0104640:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0104645:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
f010464c:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
f0104653:	eb 06                	jmp    f010465b <vprintfmt+0x5b>
f0104655:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
f0104659:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010465b:	0f b6 0b             	movzbl (%ebx),%ecx
f010465e:	0f b6 d1             	movzbl %cl,%edx
f0104661:	8d 43 01             	lea    0x1(%ebx),%eax
f0104664:	83 e9 23             	sub    $0x23,%ecx
f0104667:	80 f9 55             	cmp    $0x55,%cl
f010466a:	0f 87 58 04 00 00    	ja     f0104ac8 <vprintfmt+0x4c8>
f0104670:	0f b6 c9             	movzbl %cl,%ecx
f0104673:	ff 24 8d 68 6a 10 f0 	jmp    *-0xfef9598(,%ecx,4)
f010467a:	c6 45 e0 2b          	movb   $0x2b,-0x20(%ebp)
f010467e:	eb d9                	jmp    f0104659 <vprintfmt+0x59>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0104680:	8d 72 d0             	lea    -0x30(%edx),%esi
				ch = *fmt;
f0104683:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
f0104686:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0104689:	83 f9 09             	cmp    $0x9,%ecx
f010468c:	76 08                	jbe    f0104696 <vprintfmt+0x96>
f010468e:	eb 40                	jmp    f01046d0 <vprintfmt+0xd0>
f0104690:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
			goto reswitch;
f0104694:	eb c3                	jmp    f0104659 <vprintfmt+0x59>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0104696:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
f0104699:	8d 0c b6             	lea    (%esi,%esi,4),%ecx
f010469c:	8d 74 4a d0          	lea    -0x30(%edx,%ecx,2),%esi
				ch = *fmt;
f01046a0:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
f01046a3:	8d 4a d0             	lea    -0x30(%edx),%ecx
f01046a6:	83 f9 09             	cmp    $0x9,%ecx
f01046a9:	76 eb                	jbe    f0104696 <vprintfmt+0x96>
f01046ab:	eb 23                	jmp    f01046d0 <vprintfmt+0xd0>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f01046ad:	8b 55 14             	mov    0x14(%ebp),%edx
f01046b0:	8d 4a 04             	lea    0x4(%edx),%ecx
f01046b3:	89 4d 14             	mov    %ecx,0x14(%ebp)
f01046b6:	8b 32                	mov    (%edx),%esi
			goto process_precision;
f01046b8:	eb 16                	jmp    f01046d0 <vprintfmt+0xd0>

		case '.':
			if (width < 0)
f01046ba:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01046bd:	c1 fa 1f             	sar    $0x1f,%edx
f01046c0:	f7 d2                	not    %edx
f01046c2:	21 55 dc             	and    %edx,-0x24(%ebp)
f01046c5:	eb 92                	jmp    f0104659 <vprintfmt+0x59>
f01046c7:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
f01046ce:	eb 89                	jmp    f0104659 <vprintfmt+0x59>

		process_precision:
			if (width < 0)
f01046d0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01046d4:	79 83                	jns    f0104659 <vprintfmt+0x59>
f01046d6:	89 75 dc             	mov    %esi,-0x24(%ebp)
f01046d9:	8b 75 c8             	mov    -0x38(%ebp),%esi
f01046dc:	e9 78 ff ff ff       	jmp    f0104659 <vprintfmt+0x59>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f01046e1:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
			goto reswitch;
f01046e5:	e9 6f ff ff ff       	jmp    f0104659 <vprintfmt+0x59>
f01046ea:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01046ed:	8b 45 14             	mov    0x14(%ebp),%eax
f01046f0:	8d 50 04             	lea    0x4(%eax),%edx
f01046f3:	89 55 14             	mov    %edx,0x14(%ebp)
f01046f6:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01046fa:	8b 00                	mov    (%eax),%eax
f01046fc:	89 04 24             	mov    %eax,(%esp)
f01046ff:	ff 55 08             	call   *0x8(%ebp)
f0104702:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
f0104705:	e9 20 ff ff ff       	jmp    f010462a <vprintfmt+0x2a>
f010470a:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
f010470d:	8b 45 14             	mov    0x14(%ebp),%eax
f0104710:	8d 50 04             	lea    0x4(%eax),%edx
f0104713:	89 55 14             	mov    %edx,0x14(%ebp)
f0104716:	8b 00                	mov    (%eax),%eax
f0104718:	89 c2                	mov    %eax,%edx
f010471a:	c1 fa 1f             	sar    $0x1f,%edx
f010471d:	31 d0                	xor    %edx,%eax
f010471f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0104721:	83 f8 06             	cmp    $0x6,%eax
f0104724:	7f 0b                	jg     f0104731 <vprintfmt+0x131>
f0104726:	8b 14 85 c0 6b 10 f0 	mov    -0xfef9440(,%eax,4),%edx
f010472d:	85 d2                	test   %edx,%edx
f010472f:	75 23                	jne    f0104754 <vprintfmt+0x154>
				printfmt(putch, putdat, "error %d", err);
f0104731:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104735:	c7 44 24 08 72 69 10 	movl   $0xf0106972,0x8(%esp)
f010473c:	f0 
f010473d:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104741:	8b 45 08             	mov    0x8(%ebp),%eax
f0104744:	89 04 24             	mov    %eax,(%esp)
f0104747:	e8 22 04 00 00       	call   f0104b6e <printfmt>
f010474c:	8b 5d cc             	mov    -0x34(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f010474f:	e9 d6 fe ff ff       	jmp    f010462a <vprintfmt+0x2a>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
f0104754:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0104758:	c7 44 24 08 bc 60 10 	movl   $0xf01060bc,0x8(%esp)
f010475f:	f0 
f0104760:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104764:	8b 55 08             	mov    0x8(%ebp),%edx
f0104767:	89 14 24             	mov    %edx,(%esp)
f010476a:	e8 ff 03 00 00       	call   f0104b6e <printfmt>
f010476f:	8b 5d cc             	mov    -0x34(%ebp),%ebx
f0104772:	e9 b3 fe ff ff       	jmp    f010462a <vprintfmt+0x2a>
f0104777:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010477a:	89 c3                	mov    %eax,%ebx
f010477c:	89 f1                	mov    %esi,%ecx
f010477e:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104781:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0104784:	8b 45 14             	mov    0x14(%ebp),%eax
f0104787:	8d 50 04             	lea    0x4(%eax),%edx
f010478a:	89 55 14             	mov    %edx,0x14(%ebp)
f010478d:	8b 00                	mov    (%eax),%eax
f010478f:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104792:	85 c0                	test   %eax,%eax
f0104794:	75 07                	jne    f010479d <vprintfmt+0x19d>
f0104796:	c7 45 d0 7b 69 10 f0 	movl   $0xf010697b,-0x30(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
f010479d:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
f01047a1:	7e 06                	jle    f01047a9 <vprintfmt+0x1a9>
f01047a3:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
f01047a7:	75 13                	jne    f01047bc <vprintfmt+0x1bc>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01047a9:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01047ac:	0f be 02             	movsbl (%edx),%eax
f01047af:	85 c0                	test   %eax,%eax
f01047b1:	0f 85 a2 00 00 00    	jne    f0104859 <vprintfmt+0x259>
f01047b7:	e9 8f 00 00 00       	jmp    f010484b <vprintfmt+0x24b>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01047bc:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01047c0:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01047c3:	89 0c 24             	mov    %ecx,(%esp)
f01047c6:	e8 d0 04 00 00       	call   f0104c9b <strnlen>
f01047cb:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f01047ce:	29 c2                	sub    %eax,%edx
f01047d0:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01047d3:	85 d2                	test   %edx,%edx
f01047d5:	7e d2                	jle    f01047a9 <vprintfmt+0x1a9>
					putch(padc, putdat);
f01047d7:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
f01047db:	89 75 c4             	mov    %esi,-0x3c(%ebp)
f01047de:	89 5d c0             	mov    %ebx,-0x40(%ebp)
f01047e1:	89 d3                	mov    %edx,%ebx
f01047e3:	89 ce                	mov    %ecx,%esi
f01047e5:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01047e9:	89 34 24             	mov    %esi,(%esp)
f01047ec:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01047ef:	83 eb 01             	sub    $0x1,%ebx
f01047f2:	85 db                	test   %ebx,%ebx
f01047f4:	7f ef                	jg     f01047e5 <vprintfmt+0x1e5>
f01047f6:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f01047f9:	8b 5d c0             	mov    -0x40(%ebp),%ebx
f01047fc:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f0104803:	eb a4                	jmp    f01047a9 <vprintfmt+0x1a9>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0104805:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104809:	74 1b                	je     f0104826 <vprintfmt+0x226>
f010480b:	8d 50 e0             	lea    -0x20(%eax),%edx
f010480e:	83 fa 5e             	cmp    $0x5e,%edx
f0104811:	76 13                	jbe    f0104826 <vprintfmt+0x226>
					putch('?', putdat);
f0104813:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104816:	89 44 24 04          	mov    %eax,0x4(%esp)
f010481a:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0104821:	ff 55 08             	call   *0x8(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0104824:	eb 0d                	jmp    f0104833 <vprintfmt+0x233>
					putch('?', putdat);
				else
					putch(ch, putdat);
f0104826:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104829:	89 54 24 04          	mov    %edx,0x4(%esp)
f010482d:	89 04 24             	mov    %eax,(%esp)
f0104830:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104833:	83 ef 01             	sub    $0x1,%edi
f0104836:	0f be 03             	movsbl (%ebx),%eax
f0104839:	85 c0                	test   %eax,%eax
f010483b:	74 05                	je     f0104842 <vprintfmt+0x242>
f010483d:	83 c3 01             	add    $0x1,%ebx
f0104840:	eb 28                	jmp    f010486a <vprintfmt+0x26a>
f0104842:	89 7d dc             	mov    %edi,-0x24(%ebp)
f0104845:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104848:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f010484b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f010484f:	7f 2d                	jg     f010487e <vprintfmt+0x27e>
f0104851:	8b 5d cc             	mov    -0x34(%ebp),%ebx
f0104854:	e9 d1 fd ff ff       	jmp    f010462a <vprintfmt+0x2a>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104859:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f010485c:	83 c1 01             	add    $0x1,%ecx
f010485f:	89 7d e0             	mov    %edi,-0x20(%ebp)
f0104862:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0104865:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
f0104868:	89 cb                	mov    %ecx,%ebx
f010486a:	85 f6                	test   %esi,%esi
f010486c:	78 97                	js     f0104805 <vprintfmt+0x205>
f010486e:	83 ee 01             	sub    $0x1,%esi
f0104871:	79 92                	jns    f0104805 <vprintfmt+0x205>
f0104873:	89 7d dc             	mov    %edi,-0x24(%ebp)
f0104876:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104879:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f010487c:	eb cd                	jmp    f010484b <vprintfmt+0x24b>
f010487e:	8b 75 08             	mov    0x8(%ebp),%esi
f0104881:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0104884:	8b 5d dc             	mov    -0x24(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0104887:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010488b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0104892:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0104894:	83 eb 01             	sub    $0x1,%ebx
f0104897:	85 db                	test   %ebx,%ebx
f0104899:	7f ec                	jg     f0104887 <vprintfmt+0x287>
f010489b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010489e:	e9 87 fd ff ff       	jmp    f010462a <vprintfmt+0x2a>
f01048a3:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01048a6:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
f01048aa:	88 45 e4             	mov    %al,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01048ad:	83 7d d0 01          	cmpl   $0x1,-0x30(%ebp)
f01048b1:	7e 16                	jle    f01048c9 <vprintfmt+0x2c9>
		return va_arg(*ap, long long);
f01048b3:	8b 45 14             	mov    0x14(%ebp),%eax
f01048b6:	8d 50 08             	lea    0x8(%eax),%edx
f01048b9:	89 55 14             	mov    %edx,0x14(%ebp)
f01048bc:	8b 10                	mov    (%eax),%edx
f01048be:	8b 48 04             	mov    0x4(%eax),%ecx
f01048c1:	89 55 d0             	mov    %edx,-0x30(%ebp)
f01048c4:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f01048c7:	eb 34                	jmp    f01048fd <vprintfmt+0x2fd>
	else if (lflag)
f01048c9:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f01048cd:	74 18                	je     f01048e7 <vprintfmt+0x2e7>
		return va_arg(*ap, long);
f01048cf:	8b 45 14             	mov    0x14(%ebp),%eax
f01048d2:	8d 50 04             	lea    0x4(%eax),%edx
f01048d5:	89 55 14             	mov    %edx,0x14(%ebp)
f01048d8:	8b 00                	mov    (%eax),%eax
f01048da:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01048dd:	89 c1                	mov    %eax,%ecx
f01048df:	c1 f9 1f             	sar    $0x1f,%ecx
f01048e2:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f01048e5:	eb 16                	jmp    f01048fd <vprintfmt+0x2fd>
	else
		return va_arg(*ap, int);
f01048e7:	8b 45 14             	mov    0x14(%ebp),%eax
f01048ea:	8d 50 04             	lea    0x4(%eax),%edx
f01048ed:	89 55 14             	mov    %edx,0x14(%ebp)
f01048f0:	8b 00                	mov    (%eax),%eax
f01048f2:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01048f5:	89 c2                	mov    %eax,%edx
f01048f7:	c1 fa 1f             	sar    $0x1f,%edx
f01048fa:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f01048fd:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0104900:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if ((long long) num < 0) {
f0104903:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0104907:	79 2c                	jns    f0104935 <vprintfmt+0x335>
				putch('-', putdat);
f0104909:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010490d:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0104914:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0104917:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f010491a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f010491d:	f7 db                	neg    %ebx
f010491f:	83 d6 00             	adc    $0x0,%esi
f0104922:	f7 de                	neg    %esi
f0104924:	0f b6 4d e0          	movzbl -0x20(%ebp),%ecx
f0104928:	88 4d e4             	mov    %cl,-0x1c(%ebp)
f010492b:	ba 0a 00 00 00       	mov    $0xa,%edx
f0104930:	e9 db 00 00 00       	jmp    f0104a10 <vprintfmt+0x410>
			}
			else if (padc == '+'){
f0104935:	80 7d e4 2b          	cmpb   $0x2b,-0x1c(%ebp)
f0104939:	74 11                	je     f010494c <vprintfmt+0x34c>
f010493b:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
f010493f:	88 45 e4             	mov    %al,-0x1c(%ebp)
f0104942:	ba 0a 00 00 00       	mov    $0xa,%edx
f0104947:	e9 c4 00 00 00       	jmp    f0104a10 <vprintfmt+0x410>
				putch('+', putdat);
f010494c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104950:	c7 04 24 2b 00 00 00 	movl   $0x2b,(%esp)
f0104957:	ff 55 08             	call   *0x8(%ebp)
f010495a:	ba 0a 00 00 00       	mov    $0xa,%edx
f010495f:	e9 ac 00 00 00       	jmp    f0104a10 <vprintfmt+0x410>
f0104964:	89 45 cc             	mov    %eax,-0x34(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0104967:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010496a:	8d 45 14             	lea    0x14(%ebp),%eax
f010496d:	e8 37 fc ff ff       	call   f01045a9 <getuint>
f0104972:	89 c3                	mov    %eax,%ebx
f0104974:	89 d6                	mov    %edx,%esi
f0104976:	0f b6 55 e0          	movzbl -0x20(%ebp),%edx
f010497a:	88 55 e4             	mov    %dl,-0x1c(%ebp)
f010497d:	ba 0a 00 00 00       	mov    $0xa,%edx
			base = 10;
			goto number;
f0104982:	e9 89 00 00 00       	jmp    f0104a10 <vprintfmt+0x410>
f0104987:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) octal
		case 'o':
			putch('0', putdat);
f010498a:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010498e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0104995:	ff 55 08             	call   *0x8(%ebp)
			num = getuint(&ap, lflag);
f0104998:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010499b:	8d 45 14             	lea    0x14(%ebp),%eax
f010499e:	e8 06 fc ff ff       	call   f01045a9 <getuint>
f01049a3:	89 c3                	mov    %eax,%ebx
f01049a5:	89 d6                	mov    %edx,%esi
f01049a7:	0f b6 4d e0          	movzbl -0x20(%ebp),%ecx
f01049ab:	88 4d e4             	mov    %cl,-0x1c(%ebp)
f01049ae:	ba 08 00 00 00       	mov    $0x8,%edx
			base = 8;
			goto number;
f01049b3:	eb 5b                	jmp    f0104a10 <vprintfmt+0x410>
f01049b5:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
f01049b8:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01049bc:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f01049c3:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f01049c6:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01049ca:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f01049d1:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
f01049d4:	8b 45 14             	mov    0x14(%ebp),%eax
f01049d7:	8d 50 04             	lea    0x4(%eax),%edx
f01049da:	89 55 14             	mov    %edx,0x14(%ebp)
f01049dd:	8b 18                	mov    (%eax),%ebx
f01049df:	be 00 00 00 00       	mov    $0x0,%esi
f01049e4:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
f01049e8:	88 45 e4             	mov    %al,-0x1c(%ebp)
f01049eb:	ba 10 00 00 00       	mov    $0x10,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f01049f0:	eb 1e                	jmp    f0104a10 <vprintfmt+0x410>
f01049f2:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f01049f5:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01049f8:	8d 45 14             	lea    0x14(%ebp),%eax
f01049fb:	e8 a9 fb ff ff       	call   f01045a9 <getuint>
f0104a00:	89 c3                	mov    %eax,%ebx
f0104a02:	89 d6                	mov    %edx,%esi
f0104a04:	0f b6 55 e0          	movzbl -0x20(%ebp),%edx
f0104a08:	88 55 e4             	mov    %dl,-0x1c(%ebp)
f0104a0b:	ba 10 00 00 00       	mov    $0x10,%edx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
f0104a10:	0f be 45 e4          	movsbl -0x1c(%ebp),%eax
f0104a14:	89 44 24 10          	mov    %eax,0x10(%esp)
f0104a18:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0104a1b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0104a1f:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104a23:	89 1c 24             	mov    %ebx,(%esp)
f0104a26:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104a2a:	89 fa                	mov    %edi,%edx
f0104a2c:	8b 45 08             	mov    0x8(%ebp),%eax
f0104a2f:	e8 2d fa ff ff       	call   f0104461 <printnum>
f0104a34:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
f0104a37:	e9 ee fb ff ff       	jmp    f010462a <vprintfmt+0x2a>
f0104a3c:	89 45 cc             	mov    %eax,-0x34(%ebp)
            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
	    	uint32_t *num_now = putdat;
	    	char *ret_va = va_arg(ap, char *);
f0104a3f:	8b 45 14             	mov    0x14(%ebp),%eax
f0104a42:	8d 50 04             	lea    0x4(%eax),%edx
f0104a45:	89 55 14             	mov    %edx,0x14(%ebp)
f0104a48:	8b 00                	mov    (%eax),%eax
	    	if(ret_va == NULL){
f0104a4a:	85 c0                	test   %eax,%eax
f0104a4c:	75 27                	jne    f0104a75 <vprintfmt+0x475>
				printfmt(putch, putdat, "%s", null_error);
f0104a4e:	c7 44 24 0c ec 69 10 	movl   $0xf01069ec,0xc(%esp)
f0104a55:	f0 
f0104a56:	c7 44 24 08 bc 60 10 	movl   $0xf01060bc,0x8(%esp)
f0104a5d:	f0 
f0104a5e:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104a62:	8b 45 08             	mov    0x8(%ebp),%eax
f0104a65:	89 04 24             	mov    %eax,(%esp)
f0104a68:	e8 01 01 00 00       	call   f0104b6e <printfmt>
f0104a6d:	8b 5d cc             	mov    -0x34(%ebp),%ebx
f0104a70:	e9 b5 fb ff ff       	jmp    f010462a <vprintfmt+0x2a>
	    	}
	    	else if ((*num_now) >> 7 != 0 ){		//how to aurrately discribe overflow?
f0104a75:	8b 17                	mov    (%edi),%edx
f0104a77:	89 d1                	mov    %edx,%ecx
f0104a79:	c1 e9 07             	shr    $0x7,%ecx
f0104a7c:	85 c9                	test   %ecx,%ecx
f0104a7e:	74 29                	je     f0104aa9 <vprintfmt+0x4a9>
				*ret_va = *(num_now);	//get putdat at first as next print instruction will change ret_va as it's a pointer which means it's dynamic;
f0104a80:	88 10                	mov    %dl,(%eax)
				printfmt(putch, putdat, "%s", overflow_error);
f0104a82:	c7 44 24 0c 24 6a 10 	movl   $0xf0106a24,0xc(%esp)
f0104a89:	f0 
f0104a8a:	c7 44 24 08 bc 60 10 	movl   $0xf01060bc,0x8(%esp)
f0104a91:	f0 
f0104a92:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104a96:	8b 55 08             	mov    0x8(%ebp),%edx
f0104a99:	89 14 24             	mov    %edx,(%esp)
f0104a9c:	e8 cd 00 00 00       	call   f0104b6e <printfmt>
f0104aa1:	8b 5d cc             	mov    -0x34(%ebp),%ebx
f0104aa4:	e9 81 fb ff ff       	jmp    f010462a <vprintfmt+0x2a>
	    	}
	    	else{
				*ret_va = *(num_now);
f0104aa9:	88 10                	mov    %dl,(%eax)
f0104aab:	8b 5d cc             	mov    -0x34(%ebp),%ebx
f0104aae:	e9 77 fb ff ff       	jmp    f010462a <vprintfmt+0x2a>
f0104ab3:	89 45 cc             	mov    %eax,-0x34(%ebp)
            	break;
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0104ab6:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104aba:	89 14 24             	mov    %edx,(%esp)
f0104abd:	ff 55 08             	call   *0x8(%ebp)
f0104ac0:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
f0104ac3:	e9 62 fb ff ff       	jmp    f010462a <vprintfmt+0x2a>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0104ac8:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104acc:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0104ad3:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0104ad6:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0104ad9:	80 38 25             	cmpb   $0x25,(%eax)
f0104adc:	0f 84 48 fb ff ff    	je     f010462a <vprintfmt+0x2a>
f0104ae2:	89 c3                	mov    %eax,%ebx
f0104ae4:	eb f0                	jmp    f0104ad6 <vprintfmt+0x4d6>
				/* do nothing */;
			break;
		}
	}
}
f0104ae6:	83 c4 5c             	add    $0x5c,%esp
f0104ae9:	5b                   	pop    %ebx
f0104aea:	5e                   	pop    %esi
f0104aeb:	5f                   	pop    %edi
f0104aec:	5d                   	pop    %ebp
f0104aed:	c3                   	ret    

f0104aee <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0104aee:	55                   	push   %ebp
f0104aef:	89 e5                	mov    %esp,%ebp
f0104af1:	83 ec 28             	sub    $0x28,%esp
f0104af4:	8b 45 08             	mov    0x8(%ebp),%eax
f0104af7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
f0104afa:	85 c0                	test   %eax,%eax
f0104afc:	74 04                	je     f0104b02 <vsnprintf+0x14>
f0104afe:	85 d2                	test   %edx,%edx
f0104b00:	7f 07                	jg     f0104b09 <vsnprintf+0x1b>
f0104b02:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104b07:	eb 3b                	jmp    f0104b44 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
f0104b09:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104b0c:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
f0104b10:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104b13:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0104b1a:	8b 45 14             	mov    0x14(%ebp),%eax
f0104b1d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104b21:	8b 45 10             	mov    0x10(%ebp),%eax
f0104b24:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104b28:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0104b2b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104b2f:	c7 04 24 e3 45 10 f0 	movl   $0xf01045e3,(%esp)
f0104b36:	e8 c5 fa ff ff       	call   f0104600 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0104b3b:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104b3e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0104b41:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
f0104b44:	c9                   	leave  
f0104b45:	c3                   	ret    

f0104b46 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0104b46:	55                   	push   %ebp
f0104b47:	89 e5                	mov    %esp,%ebp
f0104b49:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
f0104b4c:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
f0104b4f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104b53:	8b 45 10             	mov    0x10(%ebp),%eax
f0104b56:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104b5a:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104b5d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104b61:	8b 45 08             	mov    0x8(%ebp),%eax
f0104b64:	89 04 24             	mov    %eax,(%esp)
f0104b67:	e8 82 ff ff ff       	call   f0104aee <vsnprintf>
	va_end(ap);

	return rc;
}
f0104b6c:	c9                   	leave  
f0104b6d:	c3                   	ret    

f0104b6e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0104b6e:	55                   	push   %ebp
f0104b6f:	89 e5                	mov    %esp,%ebp
f0104b71:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
f0104b74:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
f0104b77:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104b7b:	8b 45 10             	mov    0x10(%ebp),%eax
f0104b7e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104b82:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104b85:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104b89:	8b 45 08             	mov    0x8(%ebp),%eax
f0104b8c:	89 04 24             	mov    %eax,(%esp)
f0104b8f:	e8 6c fa ff ff       	call   f0104600 <vprintfmt>
	va_end(ap);
}
f0104b94:	c9                   	leave  
f0104b95:	c3                   	ret    
	...

f0104ba0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0104ba0:	55                   	push   %ebp
f0104ba1:	89 e5                	mov    %esp,%ebp
f0104ba3:	57                   	push   %edi
f0104ba4:	56                   	push   %esi
f0104ba5:	53                   	push   %ebx
f0104ba6:	83 ec 1c             	sub    $0x1c,%esp
f0104ba9:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0104bac:	85 c0                	test   %eax,%eax
f0104bae:	74 10                	je     f0104bc0 <readline+0x20>
		cprintf("%s", prompt);
f0104bb0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104bb4:	c7 04 24 bc 60 10 f0 	movl   $0xf01060bc,(%esp)
f0104bbb:	e8 5b f0 ff ff       	call   f0103c1b <cprintf>

	i = 0;
	echoing = iscons(0);
f0104bc0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0104bc7:	e8 8a b6 ff ff       	call   f0100256 <iscons>
f0104bcc:	89 c7                	mov    %eax,%edi
f0104bce:	be 00 00 00 00       	mov    $0x0,%esi
	while (1) {
		c = getchar();
f0104bd3:	e8 6d b6 ff ff       	call   f0100245 <getchar>
f0104bd8:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0104bda:	85 c0                	test   %eax,%eax
f0104bdc:	79 17                	jns    f0104bf5 <readline+0x55>
			cprintf("read error: %e\n", c);
f0104bde:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104be2:	c7 04 24 dc 6b 10 f0 	movl   $0xf0106bdc,(%esp)
f0104be9:	e8 2d f0 ff ff       	call   f0103c1b <cprintf>
f0104bee:	b8 00 00 00 00       	mov    $0x0,%eax
			return NULL;
f0104bf3:	eb 76                	jmp    f0104c6b <readline+0xcb>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0104bf5:	83 f8 08             	cmp    $0x8,%eax
f0104bf8:	74 08                	je     f0104c02 <readline+0x62>
f0104bfa:	83 f8 7f             	cmp    $0x7f,%eax
f0104bfd:	8d 76 00             	lea    0x0(%esi),%esi
f0104c00:	75 19                	jne    f0104c1b <readline+0x7b>
f0104c02:	85 f6                	test   %esi,%esi
f0104c04:	7e 15                	jle    f0104c1b <readline+0x7b>
			if (echoing)
f0104c06:	85 ff                	test   %edi,%edi
f0104c08:	74 0c                	je     f0104c16 <readline+0x76>
				cputchar('\b');
f0104c0a:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0104c11:	e8 44 b8 ff ff       	call   f010045a <cputchar>
			i--;
f0104c16:	83 ee 01             	sub    $0x1,%esi
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
			return NULL;
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0104c19:	eb b8                	jmp    f0104bd3 <readline+0x33>
			if (echoing)
				cputchar('\b');
			i--;
		} else if (c >= ' ' && i < BUFLEN-1) {
f0104c1b:	83 fb 1f             	cmp    $0x1f,%ebx
f0104c1e:	66 90                	xchg   %ax,%ax
f0104c20:	7e 23                	jle    f0104c45 <readline+0xa5>
f0104c22:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0104c28:	7f 1b                	jg     f0104c45 <readline+0xa5>
			if (echoing)
f0104c2a:	85 ff                	test   %edi,%edi
f0104c2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104c30:	74 08                	je     f0104c3a <readline+0x9a>
				cputchar(c);
f0104c32:	89 1c 24             	mov    %ebx,(%esp)
f0104c35:	e8 20 b8 ff ff       	call   f010045a <cputchar>
			buf[i++] = c;
f0104c3a:	88 9e 00 cf 19 f0    	mov    %bl,-0xfe63100(%esi)
f0104c40:	83 c6 01             	add    $0x1,%esi
f0104c43:	eb 8e                	jmp    f0104bd3 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0104c45:	83 fb 0a             	cmp    $0xa,%ebx
f0104c48:	74 05                	je     f0104c4f <readline+0xaf>
f0104c4a:	83 fb 0d             	cmp    $0xd,%ebx
f0104c4d:	75 84                	jne    f0104bd3 <readline+0x33>
			if (echoing)
f0104c4f:	85 ff                	test   %edi,%edi
f0104c51:	74 0c                	je     f0104c5f <readline+0xbf>
				cputchar('\n');
f0104c53:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0104c5a:	e8 fb b7 ff ff       	call   f010045a <cputchar>
			buf[i] = 0;
f0104c5f:	c6 86 00 cf 19 f0 00 	movb   $0x0,-0xfe63100(%esi)
f0104c66:	b8 00 cf 19 f0       	mov    $0xf019cf00,%eax
			return buf;
		}
	}
}
f0104c6b:	83 c4 1c             	add    $0x1c,%esp
f0104c6e:	5b                   	pop    %ebx
f0104c6f:	5e                   	pop    %esi
f0104c70:	5f                   	pop    %edi
f0104c71:	5d                   	pop    %ebp
f0104c72:	c3                   	ret    
	...

f0104c80 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0104c80:	55                   	push   %ebp
f0104c81:	89 e5                	mov    %esp,%ebp
f0104c83:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0104c86:	b8 00 00 00 00       	mov    $0x0,%eax
f0104c8b:	80 3a 00             	cmpb   $0x0,(%edx)
f0104c8e:	74 09                	je     f0104c99 <strlen+0x19>
		n++;
f0104c90:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0104c93:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0104c97:	75 f7                	jne    f0104c90 <strlen+0x10>
		n++;
	return n;
}
f0104c99:	5d                   	pop    %ebp
f0104c9a:	c3                   	ret    

f0104c9b <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0104c9b:	55                   	push   %ebp
f0104c9c:	89 e5                	mov    %esp,%ebp
f0104c9e:	53                   	push   %ebx
f0104c9f:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104ca2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104ca5:	85 c9                	test   %ecx,%ecx
f0104ca7:	74 19                	je     f0104cc2 <strnlen+0x27>
f0104ca9:	80 3b 00             	cmpb   $0x0,(%ebx)
f0104cac:	74 14                	je     f0104cc2 <strnlen+0x27>
f0104cae:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f0104cb3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104cb6:	39 c8                	cmp    %ecx,%eax
f0104cb8:	74 0d                	je     f0104cc7 <strnlen+0x2c>
f0104cba:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
f0104cbe:	75 f3                	jne    f0104cb3 <strnlen+0x18>
f0104cc0:	eb 05                	jmp    f0104cc7 <strnlen+0x2c>
f0104cc2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f0104cc7:	5b                   	pop    %ebx
f0104cc8:	5d                   	pop    %ebp
f0104cc9:	c3                   	ret    

f0104cca <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0104cca:	55                   	push   %ebp
f0104ccb:	89 e5                	mov    %esp,%ebp
f0104ccd:	53                   	push   %ebx
f0104cce:	8b 45 08             	mov    0x8(%ebp),%eax
f0104cd1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104cd4:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0104cd9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f0104cdd:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0104ce0:	83 c2 01             	add    $0x1,%edx
f0104ce3:	84 c9                	test   %cl,%cl
f0104ce5:	75 f2                	jne    f0104cd9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0104ce7:	5b                   	pop    %ebx
f0104ce8:	5d                   	pop    %ebp
f0104ce9:	c3                   	ret    

f0104cea <strcat>:

char *
strcat(char *dst, const char *src)
{
f0104cea:	55                   	push   %ebp
f0104ceb:	89 e5                	mov    %esp,%ebp
f0104ced:	53                   	push   %ebx
f0104cee:	83 ec 08             	sub    $0x8,%esp
f0104cf1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0104cf4:	89 1c 24             	mov    %ebx,(%esp)
f0104cf7:	e8 84 ff ff ff       	call   f0104c80 <strlen>
	strcpy(dst + len, src);
f0104cfc:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104cff:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104d03:	8d 04 03             	lea    (%ebx,%eax,1),%eax
f0104d06:	89 04 24             	mov    %eax,(%esp)
f0104d09:	e8 bc ff ff ff       	call   f0104cca <strcpy>
	return dst;
}
f0104d0e:	89 d8                	mov    %ebx,%eax
f0104d10:	83 c4 08             	add    $0x8,%esp
f0104d13:	5b                   	pop    %ebx
f0104d14:	5d                   	pop    %ebp
f0104d15:	c3                   	ret    

f0104d16 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0104d16:	55                   	push   %ebp
f0104d17:	89 e5                	mov    %esp,%ebp
f0104d19:	56                   	push   %esi
f0104d1a:	53                   	push   %ebx
f0104d1b:	8b 45 08             	mov    0x8(%ebp),%eax
f0104d1e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104d21:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104d24:	85 f6                	test   %esi,%esi
f0104d26:	74 18                	je     f0104d40 <strncpy+0x2a>
f0104d28:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f0104d2d:	0f b6 1a             	movzbl (%edx),%ebx
f0104d30:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0104d33:	80 3a 01             	cmpb   $0x1,(%edx)
f0104d36:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104d39:	83 c1 01             	add    $0x1,%ecx
f0104d3c:	39 ce                	cmp    %ecx,%esi
f0104d3e:	77 ed                	ja     f0104d2d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0104d40:	5b                   	pop    %ebx
f0104d41:	5e                   	pop    %esi
f0104d42:	5d                   	pop    %ebp
f0104d43:	c3                   	ret    

f0104d44 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0104d44:	55                   	push   %ebp
f0104d45:	89 e5                	mov    %esp,%ebp
f0104d47:	56                   	push   %esi
f0104d48:	53                   	push   %ebx
f0104d49:	8b 75 08             	mov    0x8(%ebp),%esi
f0104d4c:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104d4f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0104d52:	89 f0                	mov    %esi,%eax
f0104d54:	85 c9                	test   %ecx,%ecx
f0104d56:	74 27                	je     f0104d7f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
f0104d58:	83 e9 01             	sub    $0x1,%ecx
f0104d5b:	74 1d                	je     f0104d7a <strlcpy+0x36>
f0104d5d:	0f b6 1a             	movzbl (%edx),%ebx
f0104d60:	84 db                	test   %bl,%bl
f0104d62:	74 16                	je     f0104d7a <strlcpy+0x36>
			*dst++ = *src++;
f0104d64:	88 18                	mov    %bl,(%eax)
f0104d66:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0104d69:	83 e9 01             	sub    $0x1,%ecx
f0104d6c:	74 0e                	je     f0104d7c <strlcpy+0x38>
			*dst++ = *src++;
f0104d6e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0104d71:	0f b6 1a             	movzbl (%edx),%ebx
f0104d74:	84 db                	test   %bl,%bl
f0104d76:	75 ec                	jne    f0104d64 <strlcpy+0x20>
f0104d78:	eb 02                	jmp    f0104d7c <strlcpy+0x38>
f0104d7a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
f0104d7c:	c6 00 00             	movb   $0x0,(%eax)
f0104d7f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
f0104d81:	5b                   	pop    %ebx
f0104d82:	5e                   	pop    %esi
f0104d83:	5d                   	pop    %ebp
f0104d84:	c3                   	ret    

f0104d85 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0104d85:	55                   	push   %ebp
f0104d86:	89 e5                	mov    %esp,%ebp
f0104d88:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104d8b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0104d8e:	0f b6 01             	movzbl (%ecx),%eax
f0104d91:	84 c0                	test   %al,%al
f0104d93:	74 15                	je     f0104daa <strcmp+0x25>
f0104d95:	3a 02                	cmp    (%edx),%al
f0104d97:	75 11                	jne    f0104daa <strcmp+0x25>
		p++, q++;
f0104d99:	83 c1 01             	add    $0x1,%ecx
f0104d9c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0104d9f:	0f b6 01             	movzbl (%ecx),%eax
f0104da2:	84 c0                	test   %al,%al
f0104da4:	74 04                	je     f0104daa <strcmp+0x25>
f0104da6:	3a 02                	cmp    (%edx),%al
f0104da8:	74 ef                	je     f0104d99 <strcmp+0x14>
f0104daa:	0f b6 c0             	movzbl %al,%eax
f0104dad:	0f b6 12             	movzbl (%edx),%edx
f0104db0:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0104db2:	5d                   	pop    %ebp
f0104db3:	c3                   	ret    

f0104db4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0104db4:	55                   	push   %ebp
f0104db5:	89 e5                	mov    %esp,%ebp
f0104db7:	53                   	push   %ebx
f0104db8:	8b 55 08             	mov    0x8(%ebp),%edx
f0104dbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104dbe:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
f0104dc1:	85 c0                	test   %eax,%eax
f0104dc3:	74 23                	je     f0104de8 <strncmp+0x34>
f0104dc5:	0f b6 1a             	movzbl (%edx),%ebx
f0104dc8:	84 db                	test   %bl,%bl
f0104dca:	74 25                	je     f0104df1 <strncmp+0x3d>
f0104dcc:	3a 19                	cmp    (%ecx),%bl
f0104dce:	75 21                	jne    f0104df1 <strncmp+0x3d>
f0104dd0:	83 e8 01             	sub    $0x1,%eax
f0104dd3:	74 13                	je     f0104de8 <strncmp+0x34>
		n--, p++, q++;
f0104dd5:	83 c2 01             	add    $0x1,%edx
f0104dd8:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0104ddb:	0f b6 1a             	movzbl (%edx),%ebx
f0104dde:	84 db                	test   %bl,%bl
f0104de0:	74 0f                	je     f0104df1 <strncmp+0x3d>
f0104de2:	3a 19                	cmp    (%ecx),%bl
f0104de4:	74 ea                	je     f0104dd0 <strncmp+0x1c>
f0104de6:	eb 09                	jmp    f0104df1 <strncmp+0x3d>
f0104de8:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0104ded:	5b                   	pop    %ebx
f0104dee:	5d                   	pop    %ebp
f0104def:	90                   	nop
f0104df0:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0104df1:	0f b6 02             	movzbl (%edx),%eax
f0104df4:	0f b6 11             	movzbl (%ecx),%edx
f0104df7:	29 d0                	sub    %edx,%eax
f0104df9:	eb f2                	jmp    f0104ded <strncmp+0x39>

f0104dfb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0104dfb:	55                   	push   %ebp
f0104dfc:	89 e5                	mov    %esp,%ebp
f0104dfe:	8b 45 08             	mov    0x8(%ebp),%eax
f0104e01:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104e05:	0f b6 10             	movzbl (%eax),%edx
f0104e08:	84 d2                	test   %dl,%dl
f0104e0a:	74 18                	je     f0104e24 <strchr+0x29>
		if (*s == c)
f0104e0c:	38 ca                	cmp    %cl,%dl
f0104e0e:	75 0a                	jne    f0104e1a <strchr+0x1f>
f0104e10:	eb 17                	jmp    f0104e29 <strchr+0x2e>
f0104e12:	38 ca                	cmp    %cl,%dl
f0104e14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104e18:	74 0f                	je     f0104e29 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0104e1a:	83 c0 01             	add    $0x1,%eax
f0104e1d:	0f b6 10             	movzbl (%eax),%edx
f0104e20:	84 d2                	test   %dl,%dl
f0104e22:	75 ee                	jne    f0104e12 <strchr+0x17>
f0104e24:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
f0104e29:	5d                   	pop    %ebp
f0104e2a:	c3                   	ret    

f0104e2b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0104e2b:	55                   	push   %ebp
f0104e2c:	89 e5                	mov    %esp,%ebp
f0104e2e:	8b 45 08             	mov    0x8(%ebp),%eax
f0104e31:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104e35:	0f b6 10             	movzbl (%eax),%edx
f0104e38:	84 d2                	test   %dl,%dl
f0104e3a:	74 18                	je     f0104e54 <strfind+0x29>
		if (*s == c)
f0104e3c:	38 ca                	cmp    %cl,%dl
f0104e3e:	75 0a                	jne    f0104e4a <strfind+0x1f>
f0104e40:	eb 12                	jmp    f0104e54 <strfind+0x29>
f0104e42:	38 ca                	cmp    %cl,%dl
f0104e44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104e48:	74 0a                	je     f0104e54 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0104e4a:	83 c0 01             	add    $0x1,%eax
f0104e4d:	0f b6 10             	movzbl (%eax),%edx
f0104e50:	84 d2                	test   %dl,%dl
f0104e52:	75 ee                	jne    f0104e42 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
f0104e54:	5d                   	pop    %ebp
f0104e55:	c3                   	ret    

f0104e56 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0104e56:	55                   	push   %ebp
f0104e57:	89 e5                	mov    %esp,%ebp
f0104e59:	83 ec 0c             	sub    $0xc,%esp
f0104e5c:	89 1c 24             	mov    %ebx,(%esp)
f0104e5f:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104e63:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0104e67:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104e6a:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104e6d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0104e70:	85 c9                	test   %ecx,%ecx
f0104e72:	74 30                	je     f0104ea4 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0104e74:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0104e7a:	75 25                	jne    f0104ea1 <memset+0x4b>
f0104e7c:	f6 c1 03             	test   $0x3,%cl
f0104e7f:	75 20                	jne    f0104ea1 <memset+0x4b>
		c &= 0xFF;
f0104e81:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0104e84:	89 d3                	mov    %edx,%ebx
f0104e86:	c1 e3 08             	shl    $0x8,%ebx
f0104e89:	89 d6                	mov    %edx,%esi
f0104e8b:	c1 e6 18             	shl    $0x18,%esi
f0104e8e:	89 d0                	mov    %edx,%eax
f0104e90:	c1 e0 10             	shl    $0x10,%eax
f0104e93:	09 f0                	or     %esi,%eax
f0104e95:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
f0104e97:	09 d8                	or     %ebx,%eax
f0104e99:	c1 e9 02             	shr    $0x2,%ecx
f0104e9c:	fc                   	cld    
f0104e9d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0104e9f:	eb 03                	jmp    f0104ea4 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0104ea1:	fc                   	cld    
f0104ea2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0104ea4:	89 f8                	mov    %edi,%eax
f0104ea6:	8b 1c 24             	mov    (%esp),%ebx
f0104ea9:	8b 74 24 04          	mov    0x4(%esp),%esi
f0104ead:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0104eb1:	89 ec                	mov    %ebp,%esp
f0104eb3:	5d                   	pop    %ebp
f0104eb4:	c3                   	ret    

f0104eb5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0104eb5:	55                   	push   %ebp
f0104eb6:	89 e5                	mov    %esp,%ebp
f0104eb8:	83 ec 08             	sub    $0x8,%esp
f0104ebb:	89 34 24             	mov    %esi,(%esp)
f0104ebe:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104ec2:	8b 45 08             	mov    0x8(%ebp),%eax
f0104ec5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
f0104ec8:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
f0104ecb:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
f0104ecd:	39 c6                	cmp    %eax,%esi
f0104ecf:	73 35                	jae    f0104f06 <memmove+0x51>
f0104ed1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0104ed4:	39 d0                	cmp    %edx,%eax
f0104ed6:	73 2e                	jae    f0104f06 <memmove+0x51>
		s += n;
		d += n;
f0104ed8:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104eda:	f6 c2 03             	test   $0x3,%dl
f0104edd:	75 1b                	jne    f0104efa <memmove+0x45>
f0104edf:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0104ee5:	75 13                	jne    f0104efa <memmove+0x45>
f0104ee7:	f6 c1 03             	test   $0x3,%cl
f0104eea:	75 0e                	jne    f0104efa <memmove+0x45>
			asm volatile("std; rep movsl\n"
f0104eec:	83 ef 04             	sub    $0x4,%edi
f0104eef:	8d 72 fc             	lea    -0x4(%edx),%esi
f0104ef2:	c1 e9 02             	shr    $0x2,%ecx
f0104ef5:	fd                   	std    
f0104ef6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104ef8:	eb 09                	jmp    f0104f03 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0104efa:	83 ef 01             	sub    $0x1,%edi
f0104efd:	8d 72 ff             	lea    -0x1(%edx),%esi
f0104f00:	fd                   	std    
f0104f01:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0104f03:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0104f04:	eb 20                	jmp    f0104f26 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104f06:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0104f0c:	75 15                	jne    f0104f23 <memmove+0x6e>
f0104f0e:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0104f14:	75 0d                	jne    f0104f23 <memmove+0x6e>
f0104f16:	f6 c1 03             	test   $0x3,%cl
f0104f19:	75 08                	jne    f0104f23 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
f0104f1b:	c1 e9 02             	shr    $0x2,%ecx
f0104f1e:	fc                   	cld    
f0104f1f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104f21:	eb 03                	jmp    f0104f26 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0104f23:	fc                   	cld    
f0104f24:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0104f26:	8b 34 24             	mov    (%esp),%esi
f0104f29:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0104f2d:	89 ec                	mov    %ebp,%esp
f0104f2f:	5d                   	pop    %ebp
f0104f30:	c3                   	ret    

f0104f31 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
f0104f31:	55                   	push   %ebp
f0104f32:	89 e5                	mov    %esp,%ebp
f0104f34:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0104f37:	8b 45 10             	mov    0x10(%ebp),%eax
f0104f3a:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104f3e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104f41:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104f45:	8b 45 08             	mov    0x8(%ebp),%eax
f0104f48:	89 04 24             	mov    %eax,(%esp)
f0104f4b:	e8 65 ff ff ff       	call   f0104eb5 <memmove>
}
f0104f50:	c9                   	leave  
f0104f51:	c3                   	ret    

f0104f52 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0104f52:	55                   	push   %ebp
f0104f53:	89 e5                	mov    %esp,%ebp
f0104f55:	57                   	push   %edi
f0104f56:	56                   	push   %esi
f0104f57:	53                   	push   %ebx
f0104f58:	8b 75 08             	mov    0x8(%ebp),%esi
f0104f5b:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0104f5e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0104f61:	85 c9                	test   %ecx,%ecx
f0104f63:	74 36                	je     f0104f9b <memcmp+0x49>
		if (*s1 != *s2)
f0104f65:	0f b6 06             	movzbl (%esi),%eax
f0104f68:	0f b6 1f             	movzbl (%edi),%ebx
f0104f6b:	38 d8                	cmp    %bl,%al
f0104f6d:	74 20                	je     f0104f8f <memcmp+0x3d>
f0104f6f:	eb 14                	jmp    f0104f85 <memcmp+0x33>
f0104f71:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
f0104f76:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
f0104f7b:	83 c2 01             	add    $0x1,%edx
f0104f7e:	83 e9 01             	sub    $0x1,%ecx
f0104f81:	38 d8                	cmp    %bl,%al
f0104f83:	74 12                	je     f0104f97 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
f0104f85:	0f b6 c0             	movzbl %al,%eax
f0104f88:	0f b6 db             	movzbl %bl,%ebx
f0104f8b:	29 d8                	sub    %ebx,%eax
f0104f8d:	eb 11                	jmp    f0104fa0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0104f8f:	83 e9 01             	sub    $0x1,%ecx
f0104f92:	ba 00 00 00 00       	mov    $0x0,%edx
f0104f97:	85 c9                	test   %ecx,%ecx
f0104f99:	75 d6                	jne    f0104f71 <memcmp+0x1f>
f0104f9b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
f0104fa0:	5b                   	pop    %ebx
f0104fa1:	5e                   	pop    %esi
f0104fa2:	5f                   	pop    %edi
f0104fa3:	5d                   	pop    %ebp
f0104fa4:	c3                   	ret    

f0104fa5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0104fa5:	55                   	push   %ebp
f0104fa6:	89 e5                	mov    %esp,%ebp
f0104fa8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0104fab:	89 c2                	mov    %eax,%edx
f0104fad:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0104fb0:	39 d0                	cmp    %edx,%eax
f0104fb2:	73 15                	jae    f0104fc9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
f0104fb4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
f0104fb8:	38 08                	cmp    %cl,(%eax)
f0104fba:	75 06                	jne    f0104fc2 <memfind+0x1d>
f0104fbc:	eb 0b                	jmp    f0104fc9 <memfind+0x24>
f0104fbe:	38 08                	cmp    %cl,(%eax)
f0104fc0:	74 07                	je     f0104fc9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0104fc2:	83 c0 01             	add    $0x1,%eax
f0104fc5:	39 c2                	cmp    %eax,%edx
f0104fc7:	77 f5                	ja     f0104fbe <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0104fc9:	5d                   	pop    %ebp
f0104fca:	c3                   	ret    

f0104fcb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0104fcb:	55                   	push   %ebp
f0104fcc:	89 e5                	mov    %esp,%ebp
f0104fce:	57                   	push   %edi
f0104fcf:	56                   	push   %esi
f0104fd0:	53                   	push   %ebx
f0104fd1:	83 ec 04             	sub    $0x4,%esp
f0104fd4:	8b 55 08             	mov    0x8(%ebp),%edx
f0104fd7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104fda:	0f b6 02             	movzbl (%edx),%eax
f0104fdd:	3c 20                	cmp    $0x20,%al
f0104fdf:	74 04                	je     f0104fe5 <strtol+0x1a>
f0104fe1:	3c 09                	cmp    $0x9,%al
f0104fe3:	75 0e                	jne    f0104ff3 <strtol+0x28>
		s++;
f0104fe5:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104fe8:	0f b6 02             	movzbl (%edx),%eax
f0104feb:	3c 20                	cmp    $0x20,%al
f0104fed:	74 f6                	je     f0104fe5 <strtol+0x1a>
f0104fef:	3c 09                	cmp    $0x9,%al
f0104ff1:	74 f2                	je     f0104fe5 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
f0104ff3:	3c 2b                	cmp    $0x2b,%al
f0104ff5:	75 0c                	jne    f0105003 <strtol+0x38>
		s++;
f0104ff7:	83 c2 01             	add    $0x1,%edx
f0104ffa:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f0105001:	eb 15                	jmp    f0105018 <strtol+0x4d>
	else if (*s == '-')
f0105003:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f010500a:	3c 2d                	cmp    $0x2d,%al
f010500c:	75 0a                	jne    f0105018 <strtol+0x4d>
		s++, neg = 1;
f010500e:	83 c2 01             	add    $0x1,%edx
f0105011:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105018:	85 db                	test   %ebx,%ebx
f010501a:	0f 94 c0             	sete   %al
f010501d:	74 05                	je     f0105024 <strtol+0x59>
f010501f:	83 fb 10             	cmp    $0x10,%ebx
f0105022:	75 18                	jne    f010503c <strtol+0x71>
f0105024:	80 3a 30             	cmpb   $0x30,(%edx)
f0105027:	75 13                	jne    f010503c <strtol+0x71>
f0105029:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f010502d:	8d 76 00             	lea    0x0(%esi),%esi
f0105030:	75 0a                	jne    f010503c <strtol+0x71>
		s += 2, base = 16;
f0105032:	83 c2 02             	add    $0x2,%edx
f0105035:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010503a:	eb 15                	jmp    f0105051 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010503c:	84 c0                	test   %al,%al
f010503e:	66 90                	xchg   %ax,%ax
f0105040:	74 0f                	je     f0105051 <strtol+0x86>
f0105042:	bb 0a 00 00 00       	mov    $0xa,%ebx
f0105047:	80 3a 30             	cmpb   $0x30,(%edx)
f010504a:	75 05                	jne    f0105051 <strtol+0x86>
		s++, base = 8;
f010504c:	83 c2 01             	add    $0x1,%edx
f010504f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0105051:	b8 00 00 00 00       	mov    $0x0,%eax
f0105056:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0105058:	0f b6 0a             	movzbl (%edx),%ecx
f010505b:	89 cf                	mov    %ecx,%edi
f010505d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0105060:	80 fb 09             	cmp    $0x9,%bl
f0105063:	77 08                	ja     f010506d <strtol+0xa2>
			dig = *s - '0';
f0105065:	0f be c9             	movsbl %cl,%ecx
f0105068:	83 e9 30             	sub    $0x30,%ecx
f010506b:	eb 1e                	jmp    f010508b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
f010506d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
f0105070:	80 fb 19             	cmp    $0x19,%bl
f0105073:	77 08                	ja     f010507d <strtol+0xb2>
			dig = *s - 'a' + 10;
f0105075:	0f be c9             	movsbl %cl,%ecx
f0105078:	83 e9 57             	sub    $0x57,%ecx
f010507b:	eb 0e                	jmp    f010508b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
f010507d:	8d 5f bf             	lea    -0x41(%edi),%ebx
f0105080:	80 fb 19             	cmp    $0x19,%bl
f0105083:	77 15                	ja     f010509a <strtol+0xcf>
			dig = *s - 'A' + 10;
f0105085:	0f be c9             	movsbl %cl,%ecx
f0105088:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f010508b:	39 f1                	cmp    %esi,%ecx
f010508d:	7d 0b                	jge    f010509a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
f010508f:	83 c2 01             	add    $0x1,%edx
f0105092:	0f af c6             	imul   %esi,%eax
f0105095:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
f0105098:	eb be                	jmp    f0105058 <strtol+0x8d>
f010509a:	89 c1                	mov    %eax,%ecx

	if (endptr)
f010509c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01050a0:	74 05                	je     f01050a7 <strtol+0xdc>
		*endptr = (char *) s;
f01050a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01050a5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f01050a7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f01050ab:	74 04                	je     f01050b1 <strtol+0xe6>
f01050ad:	89 c8                	mov    %ecx,%eax
f01050af:	f7 d8                	neg    %eax
}
f01050b1:	83 c4 04             	add    $0x4,%esp
f01050b4:	5b                   	pop    %ebx
f01050b5:	5e                   	pop    %esi
f01050b6:	5f                   	pop    %edi
f01050b7:	5d                   	pop    %ebp
f01050b8:	c3                   	ret    
f01050b9:	00 00                	add    %al,(%eax)
f01050bb:	00 00                	add    %al,(%eax)
f01050bd:	00 00                	add    %al,(%eax)
	...

f01050c0 <__udivdi3>:
f01050c0:	55                   	push   %ebp
f01050c1:	89 e5                	mov    %esp,%ebp
f01050c3:	57                   	push   %edi
f01050c4:	56                   	push   %esi
f01050c5:	83 ec 10             	sub    $0x10,%esp
f01050c8:	8b 45 14             	mov    0x14(%ebp),%eax
f01050cb:	8b 55 08             	mov    0x8(%ebp),%edx
f01050ce:	8b 75 10             	mov    0x10(%ebp),%esi
f01050d1:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01050d4:	85 c0                	test   %eax,%eax
f01050d6:	89 55 f0             	mov    %edx,-0x10(%ebp)
f01050d9:	75 35                	jne    f0105110 <__udivdi3+0x50>
f01050db:	39 fe                	cmp    %edi,%esi
f01050dd:	77 61                	ja     f0105140 <__udivdi3+0x80>
f01050df:	85 f6                	test   %esi,%esi
f01050e1:	75 0b                	jne    f01050ee <__udivdi3+0x2e>
f01050e3:	b8 01 00 00 00       	mov    $0x1,%eax
f01050e8:	31 d2                	xor    %edx,%edx
f01050ea:	f7 f6                	div    %esi
f01050ec:	89 c6                	mov    %eax,%esi
f01050ee:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f01050f1:	31 d2                	xor    %edx,%edx
f01050f3:	89 f8                	mov    %edi,%eax
f01050f5:	f7 f6                	div    %esi
f01050f7:	89 c7                	mov    %eax,%edi
f01050f9:	89 c8                	mov    %ecx,%eax
f01050fb:	f7 f6                	div    %esi
f01050fd:	89 c1                	mov    %eax,%ecx
f01050ff:	89 fa                	mov    %edi,%edx
f0105101:	89 c8                	mov    %ecx,%eax
f0105103:	83 c4 10             	add    $0x10,%esp
f0105106:	5e                   	pop    %esi
f0105107:	5f                   	pop    %edi
f0105108:	5d                   	pop    %ebp
f0105109:	c3                   	ret    
f010510a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0105110:	39 f8                	cmp    %edi,%eax
f0105112:	77 1c                	ja     f0105130 <__udivdi3+0x70>
f0105114:	0f bd d0             	bsr    %eax,%edx
f0105117:	83 f2 1f             	xor    $0x1f,%edx
f010511a:	89 55 f4             	mov    %edx,-0xc(%ebp)
f010511d:	75 39                	jne    f0105158 <__udivdi3+0x98>
f010511f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f0105122:	0f 86 a0 00 00 00    	jbe    f01051c8 <__udivdi3+0x108>
f0105128:	39 f8                	cmp    %edi,%eax
f010512a:	0f 82 98 00 00 00    	jb     f01051c8 <__udivdi3+0x108>
f0105130:	31 ff                	xor    %edi,%edi
f0105132:	31 c9                	xor    %ecx,%ecx
f0105134:	89 c8                	mov    %ecx,%eax
f0105136:	89 fa                	mov    %edi,%edx
f0105138:	83 c4 10             	add    $0x10,%esp
f010513b:	5e                   	pop    %esi
f010513c:	5f                   	pop    %edi
f010513d:	5d                   	pop    %ebp
f010513e:	c3                   	ret    
f010513f:	90                   	nop
f0105140:	89 d1                	mov    %edx,%ecx
f0105142:	89 fa                	mov    %edi,%edx
f0105144:	89 c8                	mov    %ecx,%eax
f0105146:	31 ff                	xor    %edi,%edi
f0105148:	f7 f6                	div    %esi
f010514a:	89 c1                	mov    %eax,%ecx
f010514c:	89 fa                	mov    %edi,%edx
f010514e:	89 c8                	mov    %ecx,%eax
f0105150:	83 c4 10             	add    $0x10,%esp
f0105153:	5e                   	pop    %esi
f0105154:	5f                   	pop    %edi
f0105155:	5d                   	pop    %ebp
f0105156:	c3                   	ret    
f0105157:	90                   	nop
f0105158:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f010515c:	89 f2                	mov    %esi,%edx
f010515e:	d3 e0                	shl    %cl,%eax
f0105160:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105163:	b8 20 00 00 00       	mov    $0x20,%eax
f0105168:	2b 45 f4             	sub    -0xc(%ebp),%eax
f010516b:	89 c1                	mov    %eax,%ecx
f010516d:	d3 ea                	shr    %cl,%edx
f010516f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0105173:	0b 55 ec             	or     -0x14(%ebp),%edx
f0105176:	d3 e6                	shl    %cl,%esi
f0105178:	89 c1                	mov    %eax,%ecx
f010517a:	89 75 e8             	mov    %esi,-0x18(%ebp)
f010517d:	89 fe                	mov    %edi,%esi
f010517f:	d3 ee                	shr    %cl,%esi
f0105181:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0105185:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0105188:	8b 55 f0             	mov    -0x10(%ebp),%edx
f010518b:	d3 e7                	shl    %cl,%edi
f010518d:	89 c1                	mov    %eax,%ecx
f010518f:	d3 ea                	shr    %cl,%edx
f0105191:	09 d7                	or     %edx,%edi
f0105193:	89 f2                	mov    %esi,%edx
f0105195:	89 f8                	mov    %edi,%eax
f0105197:	f7 75 ec             	divl   -0x14(%ebp)
f010519a:	89 d6                	mov    %edx,%esi
f010519c:	89 c7                	mov    %eax,%edi
f010519e:	f7 65 e8             	mull   -0x18(%ebp)
f01051a1:	39 d6                	cmp    %edx,%esi
f01051a3:	89 55 ec             	mov    %edx,-0x14(%ebp)
f01051a6:	72 30                	jb     f01051d8 <__udivdi3+0x118>
f01051a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01051ab:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f01051af:	d3 e2                	shl    %cl,%edx
f01051b1:	39 c2                	cmp    %eax,%edx
f01051b3:	73 05                	jae    f01051ba <__udivdi3+0xfa>
f01051b5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
f01051b8:	74 1e                	je     f01051d8 <__udivdi3+0x118>
f01051ba:	89 f9                	mov    %edi,%ecx
f01051bc:	31 ff                	xor    %edi,%edi
f01051be:	e9 71 ff ff ff       	jmp    f0105134 <__udivdi3+0x74>
f01051c3:	90                   	nop
f01051c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01051c8:	31 ff                	xor    %edi,%edi
f01051ca:	b9 01 00 00 00       	mov    $0x1,%ecx
f01051cf:	e9 60 ff ff ff       	jmp    f0105134 <__udivdi3+0x74>
f01051d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01051d8:	8d 4f ff             	lea    -0x1(%edi),%ecx
f01051db:	31 ff                	xor    %edi,%edi
f01051dd:	89 c8                	mov    %ecx,%eax
f01051df:	89 fa                	mov    %edi,%edx
f01051e1:	83 c4 10             	add    $0x10,%esp
f01051e4:	5e                   	pop    %esi
f01051e5:	5f                   	pop    %edi
f01051e6:	5d                   	pop    %ebp
f01051e7:	c3                   	ret    
	...

f01051f0 <__umoddi3>:
f01051f0:	55                   	push   %ebp
f01051f1:	89 e5                	mov    %esp,%ebp
f01051f3:	57                   	push   %edi
f01051f4:	56                   	push   %esi
f01051f5:	83 ec 20             	sub    $0x20,%esp
f01051f8:	8b 55 14             	mov    0x14(%ebp),%edx
f01051fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01051fe:	8b 7d 10             	mov    0x10(%ebp),%edi
f0105201:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105204:	85 d2                	test   %edx,%edx
f0105206:	89 c8                	mov    %ecx,%eax
f0105208:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f010520b:	75 13                	jne    f0105220 <__umoddi3+0x30>
f010520d:	39 f7                	cmp    %esi,%edi
f010520f:	76 3f                	jbe    f0105250 <__umoddi3+0x60>
f0105211:	89 f2                	mov    %esi,%edx
f0105213:	f7 f7                	div    %edi
f0105215:	89 d0                	mov    %edx,%eax
f0105217:	31 d2                	xor    %edx,%edx
f0105219:	83 c4 20             	add    $0x20,%esp
f010521c:	5e                   	pop    %esi
f010521d:	5f                   	pop    %edi
f010521e:	5d                   	pop    %ebp
f010521f:	c3                   	ret    
f0105220:	39 f2                	cmp    %esi,%edx
f0105222:	77 4c                	ja     f0105270 <__umoddi3+0x80>
f0105224:	0f bd ca             	bsr    %edx,%ecx
f0105227:	83 f1 1f             	xor    $0x1f,%ecx
f010522a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f010522d:	75 51                	jne    f0105280 <__umoddi3+0x90>
f010522f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
f0105232:	0f 87 e0 00 00 00    	ja     f0105318 <__umoddi3+0x128>
f0105238:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010523b:	29 f8                	sub    %edi,%eax
f010523d:	19 d6                	sbb    %edx,%esi
f010523f:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0105242:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105245:	89 f2                	mov    %esi,%edx
f0105247:	83 c4 20             	add    $0x20,%esp
f010524a:	5e                   	pop    %esi
f010524b:	5f                   	pop    %edi
f010524c:	5d                   	pop    %ebp
f010524d:	c3                   	ret    
f010524e:	66 90                	xchg   %ax,%ax
f0105250:	85 ff                	test   %edi,%edi
f0105252:	75 0b                	jne    f010525f <__umoddi3+0x6f>
f0105254:	b8 01 00 00 00       	mov    $0x1,%eax
f0105259:	31 d2                	xor    %edx,%edx
f010525b:	f7 f7                	div    %edi
f010525d:	89 c7                	mov    %eax,%edi
f010525f:	89 f0                	mov    %esi,%eax
f0105261:	31 d2                	xor    %edx,%edx
f0105263:	f7 f7                	div    %edi
f0105265:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105268:	f7 f7                	div    %edi
f010526a:	eb a9                	jmp    f0105215 <__umoddi3+0x25>
f010526c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105270:	89 c8                	mov    %ecx,%eax
f0105272:	89 f2                	mov    %esi,%edx
f0105274:	83 c4 20             	add    $0x20,%esp
f0105277:	5e                   	pop    %esi
f0105278:	5f                   	pop    %edi
f0105279:	5d                   	pop    %ebp
f010527a:	c3                   	ret    
f010527b:	90                   	nop
f010527c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105280:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0105284:	d3 e2                	shl    %cl,%edx
f0105286:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0105289:	ba 20 00 00 00       	mov    $0x20,%edx
f010528e:	2b 55 f0             	sub    -0x10(%ebp),%edx
f0105291:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0105294:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0105298:	89 fa                	mov    %edi,%edx
f010529a:	d3 ea                	shr    %cl,%edx
f010529c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f01052a0:	0b 55 f4             	or     -0xc(%ebp),%edx
f01052a3:	d3 e7                	shl    %cl,%edi
f01052a5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f01052a9:	89 55 f4             	mov    %edx,-0xc(%ebp)
f01052ac:	89 f2                	mov    %esi,%edx
f01052ae:	89 7d e8             	mov    %edi,-0x18(%ebp)
f01052b1:	89 c7                	mov    %eax,%edi
f01052b3:	d3 ea                	shr    %cl,%edx
f01052b5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f01052b9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01052bc:	89 c2                	mov    %eax,%edx
f01052be:	d3 e6                	shl    %cl,%esi
f01052c0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f01052c4:	d3 ea                	shr    %cl,%edx
f01052c6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f01052ca:	09 d6                	or     %edx,%esi
f01052cc:	89 f0                	mov    %esi,%eax
f01052ce:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01052d1:	d3 e7                	shl    %cl,%edi
f01052d3:	89 f2                	mov    %esi,%edx
f01052d5:	f7 75 f4             	divl   -0xc(%ebp)
f01052d8:	89 d6                	mov    %edx,%esi
f01052da:	f7 65 e8             	mull   -0x18(%ebp)
f01052dd:	39 d6                	cmp    %edx,%esi
f01052df:	72 2b                	jb     f010530c <__umoddi3+0x11c>
f01052e1:	39 c7                	cmp    %eax,%edi
f01052e3:	72 23                	jb     f0105308 <__umoddi3+0x118>
f01052e5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f01052e9:	29 c7                	sub    %eax,%edi
f01052eb:	19 d6                	sbb    %edx,%esi
f01052ed:	89 f0                	mov    %esi,%eax
f01052ef:	89 f2                	mov    %esi,%edx
f01052f1:	d3 ef                	shr    %cl,%edi
f01052f3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f01052f7:	d3 e0                	shl    %cl,%eax
f01052f9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f01052fd:	09 f8                	or     %edi,%eax
f01052ff:	d3 ea                	shr    %cl,%edx
f0105301:	83 c4 20             	add    $0x20,%esp
f0105304:	5e                   	pop    %esi
f0105305:	5f                   	pop    %edi
f0105306:	5d                   	pop    %ebp
f0105307:	c3                   	ret    
f0105308:	39 d6                	cmp    %edx,%esi
f010530a:	75 d9                	jne    f01052e5 <__umoddi3+0xf5>
f010530c:	2b 45 e8             	sub    -0x18(%ebp),%eax
f010530f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
f0105312:	eb d1                	jmp    f01052e5 <__umoddi3+0xf5>
f0105314:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105318:	39 f2                	cmp    %esi,%edx
f010531a:	0f 82 18 ff ff ff    	jb     f0105238 <__umoddi3+0x48>
f0105320:	e9 1d ff ff ff       	jmp    f0105242 <__umoddi3+0x52>
