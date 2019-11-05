
bin/kernel：     文件格式 elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:
.text
.globl kern_entry
kern_entry:
    # reload temperate gdt (second time) to remap all physical memory
    # virtual_addr 0~4G=linear_addr&physical_addr -KERNBASE~4G-KERNBASE 
    lgdt REALLOC(__gdtdesc)
c0100000:	0f 01 15 18 70 11 00 	lgdtl  0x117018
    movl $KERNEL_DS, %eax
c0100007:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c010000c:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c010000e:	8e c0                	mov    %eax,%es
    movw %ax, %ss
c0100010:	8e d0                	mov    %eax,%ss

    ljmp $KERNEL_CS, $relocated
c0100012:	ea 19 00 10 c0 08 00 	ljmp   $0x8,$0xc0100019

c0100019 <relocated>:

relocated:

    # set ebp, esp
    movl $0x0, %ebp
c0100019:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010001e:	bc 00 70 11 c0       	mov    $0xc0117000,%esp
    # now kernel stack is ready , call the first C function
    call kern_init
c0100023:	e8 02 00 00 00       	call   c010002a <kern_init>

c0100028 <spin>:

# should never get here
spin:
    jmp spin
c0100028:	eb fe                	jmp    c0100028 <spin>

c010002a <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

int
kern_init(void) {
c010002a:	55                   	push   %ebp
c010002b:	89 e5                	mov    %esp,%ebp
c010002d:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
c0100030:	ba c8 89 11 c0       	mov    $0xc01189c8,%edx
c0100035:	b8 36 7a 11 c0       	mov    $0xc0117a36,%eax
c010003a:	29 c2                	sub    %eax,%edx
c010003c:	89 d0                	mov    %edx,%eax
c010003e:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100042:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100049:	00 
c010004a:	c7 04 24 36 7a 11 c0 	movl   $0xc0117a36,(%esp)
c0100051:	e8 f6 5d 00 00       	call   c0105e4c <memset>

    cons_init();                // init the console
c0100056:	e8 7c 15 00 00       	call   c01015d7 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c010005b:	c7 45 f4 e0 5f 10 c0 	movl   $0xc0105fe0,-0xc(%ebp)
    cprintf("%s\n\n", message);
c0100062:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100065:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100069:	c7 04 24 fc 5f 10 c0 	movl   $0xc0105ffc,(%esp)
c0100070:	e8 d2 02 00 00       	call   c0100347 <cprintf>

    print_kerninfo();
c0100075:	e8 01 08 00 00       	call   c010087b <print_kerninfo>

    grade_backtrace();
c010007a:	e8 86 00 00 00       	call   c0100105 <grade_backtrace>

    pmm_init();                 // init physical memory management
c010007f:	e8 e4 42 00 00       	call   c0104368 <pmm_init>

    pic_init();                 // init interrupt controller
c0100084:	e8 b7 16 00 00       	call   c0101740 <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100089:	e8 09 18 00 00       	call   c0101897 <idt_init>

    clock_init();               // init clock interrupt
c010008e:	e8 fa 0c 00 00       	call   c0100d8d <clock_init>
    intr_enable();              // enable irq interrupt
c0100093:	e8 16 16 00 00       	call   c01016ae <intr_enable>
    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();

    /* do nothing */
    while (1);
c0100098:	eb fe                	jmp    c0100098 <kern_init+0x6e>

c010009a <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
c010009a:	55                   	push   %ebp
c010009b:	89 e5                	mov    %esp,%ebp
c010009d:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
c01000a0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01000a7:	00 
c01000a8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01000af:	00 
c01000b0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01000b7:	e8 03 0c 00 00       	call   c0100cbf <mon_backtrace>
}
c01000bc:	c9                   	leave  
c01000bd:	c3                   	ret    

c01000be <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
c01000be:	55                   	push   %ebp
c01000bf:	89 e5                	mov    %esp,%ebp
c01000c1:	53                   	push   %ebx
c01000c2:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
c01000c5:	8d 5d 0c             	lea    0xc(%ebp),%ebx
c01000c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
c01000cb:	8d 55 08             	lea    0x8(%ebp),%edx
c01000ce:	8b 45 08             	mov    0x8(%ebp),%eax
c01000d1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01000d5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01000d9:	89 54 24 04          	mov    %edx,0x4(%esp)
c01000dd:	89 04 24             	mov    %eax,(%esp)
c01000e0:	e8 b5 ff ff ff       	call   c010009a <grade_backtrace2>
}
c01000e5:	83 c4 14             	add    $0x14,%esp
c01000e8:	5b                   	pop    %ebx
c01000e9:	5d                   	pop    %ebp
c01000ea:	c3                   	ret    

c01000eb <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
c01000eb:	55                   	push   %ebp
c01000ec:	89 e5                	mov    %esp,%ebp
c01000ee:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
c01000f1:	8b 45 10             	mov    0x10(%ebp),%eax
c01000f4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01000f8:	8b 45 08             	mov    0x8(%ebp),%eax
c01000fb:	89 04 24             	mov    %eax,(%esp)
c01000fe:	e8 bb ff ff ff       	call   c01000be <grade_backtrace1>
}
c0100103:	c9                   	leave  
c0100104:	c3                   	ret    

c0100105 <grade_backtrace>:

void
grade_backtrace(void) {
c0100105:	55                   	push   %ebp
c0100106:	89 e5                	mov    %esp,%ebp
c0100108:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
c010010b:	b8 2a 00 10 c0       	mov    $0xc010002a,%eax
c0100110:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
c0100117:	ff 
c0100118:	89 44 24 04          	mov    %eax,0x4(%esp)
c010011c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100123:	e8 c3 ff ff ff       	call   c01000eb <grade_backtrace0>
}
c0100128:	c9                   	leave  
c0100129:	c3                   	ret    

c010012a <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
c010012a:	55                   	push   %ebp
c010012b:	89 e5                	mov    %esp,%ebp
c010012d:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
c0100130:	8c 4d f6             	mov    %cs,-0xa(%ebp)
c0100133:	8c 5d f4             	mov    %ds,-0xc(%ebp)
c0100136:	8c 45 f2             	mov    %es,-0xe(%ebp)
c0100139:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
c010013c:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100140:	0f b7 c0             	movzwl %ax,%eax
c0100143:	83 e0 03             	and    $0x3,%eax
c0100146:	89 c2                	mov    %eax,%edx
c0100148:	a1 40 7a 11 c0       	mov    0xc0117a40,%eax
c010014d:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100151:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100155:	c7 04 24 01 60 10 c0 	movl   $0xc0106001,(%esp)
c010015c:	e8 e6 01 00 00       	call   c0100347 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
c0100161:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100165:	0f b7 d0             	movzwl %ax,%edx
c0100168:	a1 40 7a 11 c0       	mov    0xc0117a40,%eax
c010016d:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100171:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100175:	c7 04 24 0f 60 10 c0 	movl   $0xc010600f,(%esp)
c010017c:	e8 c6 01 00 00       	call   c0100347 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
c0100181:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c0100185:	0f b7 d0             	movzwl %ax,%edx
c0100188:	a1 40 7a 11 c0       	mov    0xc0117a40,%eax
c010018d:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100191:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100195:	c7 04 24 1d 60 10 c0 	movl   $0xc010601d,(%esp)
c010019c:	e8 a6 01 00 00       	call   c0100347 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
c01001a1:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001a5:	0f b7 d0             	movzwl %ax,%edx
c01001a8:	a1 40 7a 11 c0       	mov    0xc0117a40,%eax
c01001ad:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001b1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001b5:	c7 04 24 2b 60 10 c0 	movl   $0xc010602b,(%esp)
c01001bc:	e8 86 01 00 00       	call   c0100347 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
c01001c1:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001c5:	0f b7 d0             	movzwl %ax,%edx
c01001c8:	a1 40 7a 11 c0       	mov    0xc0117a40,%eax
c01001cd:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001d1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001d5:	c7 04 24 39 60 10 c0 	movl   $0xc0106039,(%esp)
c01001dc:	e8 66 01 00 00       	call   c0100347 <cprintf>
    round ++;
c01001e1:	a1 40 7a 11 c0       	mov    0xc0117a40,%eax
c01001e6:	83 c0 01             	add    $0x1,%eax
c01001e9:	a3 40 7a 11 c0       	mov    %eax,0xc0117a40
}
c01001ee:	c9                   	leave  
c01001ef:	c3                   	ret    

c01001f0 <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
c01001f0:	55                   	push   %ebp
c01001f1:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
	asm volatile (
c01001f3:	83 ec 08             	sub    $0x8,%esp
c01001f6:	cd 78                	int    $0x78
c01001f8:	89 ec                	mov    %ebp,%esp
	    "int %0 \n"
	    "movl %%ebp, %%esp"
	    : 
	    : "i"(T_SWITCH_TOU)
	);
}
c01001fa:	5d                   	pop    %ebp
c01001fb:	c3                   	ret    

c01001fc <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
c01001fc:	55                   	push   %ebp
c01001fd:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
	asm volatile (
c01001ff:	cd 79                	int    $0x79
c0100201:	89 ec                	mov    %ebp,%esp
	    "int %0 \n"
	    "movl %%ebp, %%esp \n"
	    : 
	    : "i"(T_SWITCH_TOK)
	);
}
c0100203:	5d                   	pop    %ebp
c0100204:	c3                   	ret    

c0100205 <lab1_switch_test>:

static void
lab1_switch_test(void) {
c0100205:	55                   	push   %ebp
c0100206:	89 e5                	mov    %esp,%ebp
c0100208:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
c010020b:	e8 1a ff ff ff       	call   c010012a <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
c0100210:	c7 04 24 48 60 10 c0 	movl   $0xc0106048,(%esp)
c0100217:	e8 2b 01 00 00       	call   c0100347 <cprintf>
    lab1_switch_to_user();
c010021c:	e8 cf ff ff ff       	call   c01001f0 <lab1_switch_to_user>
    lab1_print_cur_status();
c0100221:	e8 04 ff ff ff       	call   c010012a <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c0100226:	c7 04 24 68 60 10 c0 	movl   $0xc0106068,(%esp)
c010022d:	e8 15 01 00 00       	call   c0100347 <cprintf>
    lab1_switch_to_kernel();
c0100232:	e8 c5 ff ff ff       	call   c01001fc <lab1_switch_to_kernel>
    lab1_print_cur_status();
c0100237:	e8 ee fe ff ff       	call   c010012a <lab1_print_cur_status>
}
c010023c:	c9                   	leave  
c010023d:	c3                   	ret    

c010023e <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
c010023e:	55                   	push   %ebp
c010023f:	89 e5                	mov    %esp,%ebp
c0100241:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
c0100244:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100248:	74 13                	je     c010025d <readline+0x1f>
        cprintf("%s", prompt);
c010024a:	8b 45 08             	mov    0x8(%ebp),%eax
c010024d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100251:	c7 04 24 87 60 10 c0 	movl   $0xc0106087,(%esp)
c0100258:	e8 ea 00 00 00       	call   c0100347 <cprintf>
    }
    int i = 0, c;
c010025d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
c0100264:	e8 66 01 00 00       	call   c01003cf <getchar>
c0100269:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
c010026c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100270:	79 07                	jns    c0100279 <readline+0x3b>
            return NULL;
c0100272:	b8 00 00 00 00       	mov    $0x0,%eax
c0100277:	eb 79                	jmp    c01002f2 <readline+0xb4>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
c0100279:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
c010027d:	7e 28                	jle    c01002a7 <readline+0x69>
c010027f:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
c0100286:	7f 1f                	jg     c01002a7 <readline+0x69>
            cputchar(c);
c0100288:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010028b:	89 04 24             	mov    %eax,(%esp)
c010028e:	e8 da 00 00 00       	call   c010036d <cputchar>
            buf[i ++] = c;
c0100293:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100296:	8d 50 01             	lea    0x1(%eax),%edx
c0100299:	89 55 f4             	mov    %edx,-0xc(%ebp)
c010029c:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010029f:	88 90 60 7a 11 c0    	mov    %dl,-0x3fee85a0(%eax)
c01002a5:	eb 46                	jmp    c01002ed <readline+0xaf>
        }
        else if (c == '\b' && i > 0) {
c01002a7:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
c01002ab:	75 17                	jne    c01002c4 <readline+0x86>
c01002ad:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01002b1:	7e 11                	jle    c01002c4 <readline+0x86>
            cputchar(c);
c01002b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002b6:	89 04 24             	mov    %eax,(%esp)
c01002b9:	e8 af 00 00 00       	call   c010036d <cputchar>
            i --;
c01002be:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01002c2:	eb 29                	jmp    c01002ed <readline+0xaf>
        }
        else if (c == '\n' || c == '\r') {
c01002c4:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
c01002c8:	74 06                	je     c01002d0 <readline+0x92>
c01002ca:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
c01002ce:	75 1d                	jne    c01002ed <readline+0xaf>
            cputchar(c);
c01002d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002d3:	89 04 24             	mov    %eax,(%esp)
c01002d6:	e8 92 00 00 00       	call   c010036d <cputchar>
            buf[i] = '\0';
c01002db:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01002de:	05 60 7a 11 c0       	add    $0xc0117a60,%eax
c01002e3:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c01002e6:	b8 60 7a 11 c0       	mov    $0xc0117a60,%eax
c01002eb:	eb 05                	jmp    c01002f2 <readline+0xb4>
        }
    }
c01002ed:	e9 72 ff ff ff       	jmp    c0100264 <readline+0x26>
}
c01002f2:	c9                   	leave  
c01002f3:	c3                   	ret    

c01002f4 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
c01002f4:	55                   	push   %ebp
c01002f5:	89 e5                	mov    %esp,%ebp
c01002f7:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c01002fa:	8b 45 08             	mov    0x8(%ebp),%eax
c01002fd:	89 04 24             	mov    %eax,(%esp)
c0100300:	e8 fe 12 00 00       	call   c0101603 <cons_putc>
    (*cnt) ++;
c0100305:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100308:	8b 00                	mov    (%eax),%eax
c010030a:	8d 50 01             	lea    0x1(%eax),%edx
c010030d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100310:	89 10                	mov    %edx,(%eax)
}
c0100312:	c9                   	leave  
c0100313:	c3                   	ret    

c0100314 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
c0100314:	55                   	push   %ebp
c0100315:	89 e5                	mov    %esp,%ebp
c0100317:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c010031a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
c0100321:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100324:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0100328:	8b 45 08             	mov    0x8(%ebp),%eax
c010032b:	89 44 24 08          	mov    %eax,0x8(%esp)
c010032f:	8d 45 f4             	lea    -0xc(%ebp),%eax
c0100332:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100336:	c7 04 24 f4 02 10 c0 	movl   $0xc01002f4,(%esp)
c010033d:	e8 23 53 00 00       	call   c0105665 <vprintfmt>
    return cnt;
c0100342:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100345:	c9                   	leave  
c0100346:	c3                   	ret    

c0100347 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
c0100347:	55                   	push   %ebp
c0100348:	89 e5                	mov    %esp,%ebp
c010034a:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c010034d:	8d 45 0c             	lea    0xc(%ebp),%eax
c0100350:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
c0100353:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100356:	89 44 24 04          	mov    %eax,0x4(%esp)
c010035a:	8b 45 08             	mov    0x8(%ebp),%eax
c010035d:	89 04 24             	mov    %eax,(%esp)
c0100360:	e8 af ff ff ff       	call   c0100314 <vcprintf>
c0100365:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0100368:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010036b:	c9                   	leave  
c010036c:	c3                   	ret    

c010036d <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
c010036d:	55                   	push   %ebp
c010036e:	89 e5                	mov    %esp,%ebp
c0100370:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c0100373:	8b 45 08             	mov    0x8(%ebp),%eax
c0100376:	89 04 24             	mov    %eax,(%esp)
c0100379:	e8 85 12 00 00       	call   c0101603 <cons_putc>
}
c010037e:	c9                   	leave  
c010037f:	c3                   	ret    

c0100380 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
c0100380:	55                   	push   %ebp
c0100381:	89 e5                	mov    %esp,%ebp
c0100383:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c0100386:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
c010038d:	eb 13                	jmp    c01003a2 <cputs+0x22>
        cputch(c, &cnt);
c010038f:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0100393:	8d 55 f0             	lea    -0x10(%ebp),%edx
c0100396:	89 54 24 04          	mov    %edx,0x4(%esp)
c010039a:	89 04 24             	mov    %eax,(%esp)
c010039d:	e8 52 ff ff ff       	call   c01002f4 <cputch>
 * */
int
cputs(const char *str) {
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
c01003a2:	8b 45 08             	mov    0x8(%ebp),%eax
c01003a5:	8d 50 01             	lea    0x1(%eax),%edx
c01003a8:	89 55 08             	mov    %edx,0x8(%ebp)
c01003ab:	0f b6 00             	movzbl (%eax),%eax
c01003ae:	88 45 f7             	mov    %al,-0x9(%ebp)
c01003b1:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
c01003b5:	75 d8                	jne    c010038f <cputs+0xf>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
c01003b7:	8d 45 f0             	lea    -0x10(%ebp),%eax
c01003ba:	89 44 24 04          	mov    %eax,0x4(%esp)
c01003be:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
c01003c5:	e8 2a ff ff ff       	call   c01002f4 <cputch>
    return cnt;
c01003ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c01003cd:	c9                   	leave  
c01003ce:	c3                   	ret    

c01003cf <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
c01003cf:	55                   	push   %ebp
c01003d0:	89 e5                	mov    %esp,%ebp
c01003d2:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
c01003d5:	e8 65 12 00 00       	call   c010163f <cons_getc>
c01003da:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01003dd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01003e1:	74 f2                	je     c01003d5 <getchar+0x6>
        /* do nothing */;
    return c;
c01003e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01003e6:	c9                   	leave  
c01003e7:	c3                   	ret    

c01003e8 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
c01003e8:	55                   	push   %ebp
c01003e9:	89 e5                	mov    %esp,%ebp
c01003eb:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
c01003ee:	8b 45 0c             	mov    0xc(%ebp),%eax
c01003f1:	8b 00                	mov    (%eax),%eax
c01003f3:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01003f6:	8b 45 10             	mov    0x10(%ebp),%eax
c01003f9:	8b 00                	mov    (%eax),%eax
c01003fb:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01003fe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
c0100405:	e9 d2 00 00 00       	jmp    c01004dc <stab_binsearch+0xf4>
        int true_m = (l + r) / 2, m = true_m;
c010040a:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010040d:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100410:	01 d0                	add    %edx,%eax
c0100412:	89 c2                	mov    %eax,%edx
c0100414:	c1 ea 1f             	shr    $0x1f,%edx
c0100417:	01 d0                	add    %edx,%eax
c0100419:	d1 f8                	sar    %eax
c010041b:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010041e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100421:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c0100424:	eb 04                	jmp    c010042a <stab_binsearch+0x42>
            m --;
c0100426:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)

    while (l <= r) {
        int true_m = (l + r) / 2, m = true_m;

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c010042a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010042d:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100430:	7c 1f                	jl     c0100451 <stab_binsearch+0x69>
c0100432:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100435:	89 d0                	mov    %edx,%eax
c0100437:	01 c0                	add    %eax,%eax
c0100439:	01 d0                	add    %edx,%eax
c010043b:	c1 e0 02             	shl    $0x2,%eax
c010043e:	89 c2                	mov    %eax,%edx
c0100440:	8b 45 08             	mov    0x8(%ebp),%eax
c0100443:	01 d0                	add    %edx,%eax
c0100445:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100449:	0f b6 c0             	movzbl %al,%eax
c010044c:	3b 45 14             	cmp    0x14(%ebp),%eax
c010044f:	75 d5                	jne    c0100426 <stab_binsearch+0x3e>
            m --;
        }
        if (m < l) {    // no match in [l, m]
c0100451:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100454:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100457:	7d 0b                	jge    c0100464 <stab_binsearch+0x7c>
            l = true_m + 1;
c0100459:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010045c:	83 c0 01             	add    $0x1,%eax
c010045f:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
c0100462:	eb 78                	jmp    c01004dc <stab_binsearch+0xf4>
        }

        // actual binary search
        any_matches = 1;
c0100464:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
c010046b:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010046e:	89 d0                	mov    %edx,%eax
c0100470:	01 c0                	add    %eax,%eax
c0100472:	01 d0                	add    %edx,%eax
c0100474:	c1 e0 02             	shl    $0x2,%eax
c0100477:	89 c2                	mov    %eax,%edx
c0100479:	8b 45 08             	mov    0x8(%ebp),%eax
c010047c:	01 d0                	add    %edx,%eax
c010047e:	8b 40 08             	mov    0x8(%eax),%eax
c0100481:	3b 45 18             	cmp    0x18(%ebp),%eax
c0100484:	73 13                	jae    c0100499 <stab_binsearch+0xb1>
            *region_left = m;
c0100486:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100489:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010048c:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
c010048e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100491:	83 c0 01             	add    $0x1,%eax
c0100494:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100497:	eb 43                	jmp    c01004dc <stab_binsearch+0xf4>
        } else if (stabs[m].n_value > addr) {
c0100499:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010049c:	89 d0                	mov    %edx,%eax
c010049e:	01 c0                	add    %eax,%eax
c01004a0:	01 d0                	add    %edx,%eax
c01004a2:	c1 e0 02             	shl    $0x2,%eax
c01004a5:	89 c2                	mov    %eax,%edx
c01004a7:	8b 45 08             	mov    0x8(%ebp),%eax
c01004aa:	01 d0                	add    %edx,%eax
c01004ac:	8b 40 08             	mov    0x8(%eax),%eax
c01004af:	3b 45 18             	cmp    0x18(%ebp),%eax
c01004b2:	76 16                	jbe    c01004ca <stab_binsearch+0xe2>
            *region_right = m - 1;
c01004b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004b7:	8d 50 ff             	lea    -0x1(%eax),%edx
c01004ba:	8b 45 10             	mov    0x10(%ebp),%eax
c01004bd:	89 10                	mov    %edx,(%eax)
            r = m - 1;
c01004bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004c2:	83 e8 01             	sub    $0x1,%eax
c01004c5:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01004c8:	eb 12                	jmp    c01004dc <stab_binsearch+0xf4>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
c01004ca:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004cd:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004d0:	89 10                	mov    %edx,(%eax)
            l = m;
c01004d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004d5:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
c01004d8:	83 45 18 01          	addl   $0x1,0x18(%ebp)
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
    int l = *region_left, r = *region_right, any_matches = 0;

    while (l <= r) {
c01004dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01004df:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c01004e2:	0f 8e 22 ff ff ff    	jle    c010040a <stab_binsearch+0x22>
            l = m;
            addr ++;
        }
    }

    if (!any_matches) {
c01004e8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01004ec:	75 0f                	jne    c01004fd <stab_binsearch+0x115>
        *region_right = *region_left - 1;
c01004ee:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004f1:	8b 00                	mov    (%eax),%eax
c01004f3:	8d 50 ff             	lea    -0x1(%eax),%edx
c01004f6:	8b 45 10             	mov    0x10(%ebp),%eax
c01004f9:	89 10                	mov    %edx,(%eax)
c01004fb:	eb 3f                	jmp    c010053c <stab_binsearch+0x154>
    }
    else {
        // find rightmost region containing 'addr'
        l = *region_right;
c01004fd:	8b 45 10             	mov    0x10(%ebp),%eax
c0100500:	8b 00                	mov    (%eax),%eax
c0100502:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
c0100505:	eb 04                	jmp    c010050b <stab_binsearch+0x123>
c0100507:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
c010050b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010050e:	8b 00                	mov    (%eax),%eax
c0100510:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100513:	7d 1f                	jge    c0100534 <stab_binsearch+0x14c>
c0100515:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100518:	89 d0                	mov    %edx,%eax
c010051a:	01 c0                	add    %eax,%eax
c010051c:	01 d0                	add    %edx,%eax
c010051e:	c1 e0 02             	shl    $0x2,%eax
c0100521:	89 c2                	mov    %eax,%edx
c0100523:	8b 45 08             	mov    0x8(%ebp),%eax
c0100526:	01 d0                	add    %edx,%eax
c0100528:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010052c:	0f b6 c0             	movzbl %al,%eax
c010052f:	3b 45 14             	cmp    0x14(%ebp),%eax
c0100532:	75 d3                	jne    c0100507 <stab_binsearch+0x11f>
            /* do nothing */;
        *region_left = l;
c0100534:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100537:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010053a:	89 10                	mov    %edx,(%eax)
    }
}
c010053c:	c9                   	leave  
c010053d:	c3                   	ret    

c010053e <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
c010053e:	55                   	push   %ebp
c010053f:	89 e5                	mov    %esp,%ebp
c0100541:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
c0100544:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100547:	c7 00 8c 60 10 c0    	movl   $0xc010608c,(%eax)
    info->eip_line = 0;
c010054d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100550:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c0100557:	8b 45 0c             	mov    0xc(%ebp),%eax
c010055a:	c7 40 08 8c 60 10 c0 	movl   $0xc010608c,0x8(%eax)
    info->eip_fn_namelen = 9;
c0100561:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100564:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
c010056b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010056e:	8b 55 08             	mov    0x8(%ebp),%edx
c0100571:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
c0100574:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100577:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
c010057e:	c7 45 f4 c8 72 10 c0 	movl   $0xc01072c8,-0xc(%ebp)
    stab_end = __STAB_END__;
c0100585:	c7 45 f0 3c 1f 11 c0 	movl   $0xc0111f3c,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
c010058c:	c7 45 ec 3d 1f 11 c0 	movl   $0xc0111f3d,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
c0100593:	c7 45 e8 96 49 11 c0 	movl   $0xc0114996,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
c010059a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010059d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01005a0:	76 0d                	jbe    c01005af <debuginfo_eip+0x71>
c01005a2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01005a5:	83 e8 01             	sub    $0x1,%eax
c01005a8:	0f b6 00             	movzbl (%eax),%eax
c01005ab:	84 c0                	test   %al,%al
c01005ad:	74 0a                	je     c01005b9 <debuginfo_eip+0x7b>
        return -1;
c01005af:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01005b4:	e9 c0 02 00 00       	jmp    c0100879 <debuginfo_eip+0x33b>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
c01005b9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
c01005c0:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01005c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01005c6:	29 c2                	sub    %eax,%edx
c01005c8:	89 d0                	mov    %edx,%eax
c01005ca:	c1 f8 02             	sar    $0x2,%eax
c01005cd:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
c01005d3:	83 e8 01             	sub    $0x1,%eax
c01005d6:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c01005d9:	8b 45 08             	mov    0x8(%ebp),%eax
c01005dc:	89 44 24 10          	mov    %eax,0x10(%esp)
c01005e0:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
c01005e7:	00 
c01005e8:	8d 45 e0             	lea    -0x20(%ebp),%eax
c01005eb:	89 44 24 08          	mov    %eax,0x8(%esp)
c01005ef:	8d 45 e4             	lea    -0x1c(%ebp),%eax
c01005f2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01005f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01005f9:	89 04 24             	mov    %eax,(%esp)
c01005fc:	e8 e7 fd ff ff       	call   c01003e8 <stab_binsearch>
    if (lfile == 0)
c0100601:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100604:	85 c0                	test   %eax,%eax
c0100606:	75 0a                	jne    c0100612 <debuginfo_eip+0xd4>
        return -1;
c0100608:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010060d:	e9 67 02 00 00       	jmp    c0100879 <debuginfo_eip+0x33b>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c0100612:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100615:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0100618:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010061b:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c010061e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100621:	89 44 24 10          	mov    %eax,0x10(%esp)
c0100625:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
c010062c:	00 
c010062d:	8d 45 d8             	lea    -0x28(%ebp),%eax
c0100630:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100634:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0100637:	89 44 24 04          	mov    %eax,0x4(%esp)
c010063b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010063e:	89 04 24             	mov    %eax,(%esp)
c0100641:	e8 a2 fd ff ff       	call   c01003e8 <stab_binsearch>

    if (lfun <= rfun) {
c0100646:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0100649:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010064c:	39 c2                	cmp    %eax,%edx
c010064e:	7f 7c                	jg     c01006cc <debuginfo_eip+0x18e>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
c0100650:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100653:	89 c2                	mov    %eax,%edx
c0100655:	89 d0                	mov    %edx,%eax
c0100657:	01 c0                	add    %eax,%eax
c0100659:	01 d0                	add    %edx,%eax
c010065b:	c1 e0 02             	shl    $0x2,%eax
c010065e:	89 c2                	mov    %eax,%edx
c0100660:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100663:	01 d0                	add    %edx,%eax
c0100665:	8b 10                	mov    (%eax),%edx
c0100667:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c010066a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010066d:	29 c1                	sub    %eax,%ecx
c010066f:	89 c8                	mov    %ecx,%eax
c0100671:	39 c2                	cmp    %eax,%edx
c0100673:	73 22                	jae    c0100697 <debuginfo_eip+0x159>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c0100675:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100678:	89 c2                	mov    %eax,%edx
c010067a:	89 d0                	mov    %edx,%eax
c010067c:	01 c0                	add    %eax,%eax
c010067e:	01 d0                	add    %edx,%eax
c0100680:	c1 e0 02             	shl    $0x2,%eax
c0100683:	89 c2                	mov    %eax,%edx
c0100685:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100688:	01 d0                	add    %edx,%eax
c010068a:	8b 10                	mov    (%eax),%edx
c010068c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010068f:	01 c2                	add    %eax,%edx
c0100691:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100694:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c0100697:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010069a:	89 c2                	mov    %eax,%edx
c010069c:	89 d0                	mov    %edx,%eax
c010069e:	01 c0                	add    %eax,%eax
c01006a0:	01 d0                	add    %edx,%eax
c01006a2:	c1 e0 02             	shl    $0x2,%eax
c01006a5:	89 c2                	mov    %eax,%edx
c01006a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006aa:	01 d0                	add    %edx,%eax
c01006ac:	8b 50 08             	mov    0x8(%eax),%edx
c01006af:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006b2:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c01006b5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006b8:	8b 40 10             	mov    0x10(%eax),%eax
c01006bb:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c01006be:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01006c1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
c01006c4:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01006c7:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01006ca:	eb 15                	jmp    c01006e1 <debuginfo_eip+0x1a3>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c01006cc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006cf:	8b 55 08             	mov    0x8(%ebp),%edx
c01006d2:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c01006d5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006d8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
c01006db:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01006de:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c01006e1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006e4:	8b 40 08             	mov    0x8(%eax),%eax
c01006e7:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
c01006ee:	00 
c01006ef:	89 04 24             	mov    %eax,(%esp)
c01006f2:	e8 c9 55 00 00       	call   c0105cc0 <strfind>
c01006f7:	89 c2                	mov    %eax,%edx
c01006f9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006fc:	8b 40 08             	mov    0x8(%eax),%eax
c01006ff:	29 c2                	sub    %eax,%edx
c0100701:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100704:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c0100707:	8b 45 08             	mov    0x8(%ebp),%eax
c010070a:	89 44 24 10          	mov    %eax,0x10(%esp)
c010070e:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
c0100715:	00 
c0100716:	8d 45 d0             	lea    -0x30(%ebp),%eax
c0100719:	89 44 24 08          	mov    %eax,0x8(%esp)
c010071d:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c0100720:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100724:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100727:	89 04 24             	mov    %eax,(%esp)
c010072a:	e8 b9 fc ff ff       	call   c01003e8 <stab_binsearch>
    if (lline <= rline) {
c010072f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100732:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100735:	39 c2                	cmp    %eax,%edx
c0100737:	7f 24                	jg     c010075d <debuginfo_eip+0x21f>
        info->eip_line = stabs[rline].n_desc;
c0100739:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010073c:	89 c2                	mov    %eax,%edx
c010073e:	89 d0                	mov    %edx,%eax
c0100740:	01 c0                	add    %eax,%eax
c0100742:	01 d0                	add    %edx,%eax
c0100744:	c1 e0 02             	shl    $0x2,%eax
c0100747:	89 c2                	mov    %eax,%edx
c0100749:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010074c:	01 d0                	add    %edx,%eax
c010074e:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c0100752:	0f b7 d0             	movzwl %ax,%edx
c0100755:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100758:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c010075b:	eb 13                	jmp    c0100770 <debuginfo_eip+0x232>
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
    if (lline <= rline) {
        info->eip_line = stabs[rline].n_desc;
    } else {
        return -1;
c010075d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100762:	e9 12 01 00 00       	jmp    c0100879 <debuginfo_eip+0x33b>
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
c0100767:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010076a:	83 e8 01             	sub    $0x1,%eax
c010076d:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c0100770:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100773:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100776:	39 c2                	cmp    %eax,%edx
c0100778:	7c 56                	jl     c01007d0 <debuginfo_eip+0x292>
           && stabs[lline].n_type != N_SOL
c010077a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010077d:	89 c2                	mov    %eax,%edx
c010077f:	89 d0                	mov    %edx,%eax
c0100781:	01 c0                	add    %eax,%eax
c0100783:	01 d0                	add    %edx,%eax
c0100785:	c1 e0 02             	shl    $0x2,%eax
c0100788:	89 c2                	mov    %eax,%edx
c010078a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010078d:	01 d0                	add    %edx,%eax
c010078f:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100793:	3c 84                	cmp    $0x84,%al
c0100795:	74 39                	je     c01007d0 <debuginfo_eip+0x292>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c0100797:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010079a:	89 c2                	mov    %eax,%edx
c010079c:	89 d0                	mov    %edx,%eax
c010079e:	01 c0                	add    %eax,%eax
c01007a0:	01 d0                	add    %edx,%eax
c01007a2:	c1 e0 02             	shl    $0x2,%eax
c01007a5:	89 c2                	mov    %eax,%edx
c01007a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007aa:	01 d0                	add    %edx,%eax
c01007ac:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01007b0:	3c 64                	cmp    $0x64,%al
c01007b2:	75 b3                	jne    c0100767 <debuginfo_eip+0x229>
c01007b4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007b7:	89 c2                	mov    %eax,%edx
c01007b9:	89 d0                	mov    %edx,%eax
c01007bb:	01 c0                	add    %eax,%eax
c01007bd:	01 d0                	add    %edx,%eax
c01007bf:	c1 e0 02             	shl    $0x2,%eax
c01007c2:	89 c2                	mov    %eax,%edx
c01007c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007c7:	01 d0                	add    %edx,%eax
c01007c9:	8b 40 08             	mov    0x8(%eax),%eax
c01007cc:	85 c0                	test   %eax,%eax
c01007ce:	74 97                	je     c0100767 <debuginfo_eip+0x229>
        lline --;
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
c01007d0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01007d3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01007d6:	39 c2                	cmp    %eax,%edx
c01007d8:	7c 46                	jl     c0100820 <debuginfo_eip+0x2e2>
c01007da:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007dd:	89 c2                	mov    %eax,%edx
c01007df:	89 d0                	mov    %edx,%eax
c01007e1:	01 c0                	add    %eax,%eax
c01007e3:	01 d0                	add    %edx,%eax
c01007e5:	c1 e0 02             	shl    $0x2,%eax
c01007e8:	89 c2                	mov    %eax,%edx
c01007ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007ed:	01 d0                	add    %edx,%eax
c01007ef:	8b 10                	mov    (%eax),%edx
c01007f1:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c01007f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01007f7:	29 c1                	sub    %eax,%ecx
c01007f9:	89 c8                	mov    %ecx,%eax
c01007fb:	39 c2                	cmp    %eax,%edx
c01007fd:	73 21                	jae    c0100820 <debuginfo_eip+0x2e2>
        info->eip_file = stabstr + stabs[lline].n_strx;
c01007ff:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100802:	89 c2                	mov    %eax,%edx
c0100804:	89 d0                	mov    %edx,%eax
c0100806:	01 c0                	add    %eax,%eax
c0100808:	01 d0                	add    %edx,%eax
c010080a:	c1 e0 02             	shl    $0x2,%eax
c010080d:	89 c2                	mov    %eax,%edx
c010080f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100812:	01 d0                	add    %edx,%eax
c0100814:	8b 10                	mov    (%eax),%edx
c0100816:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100819:	01 c2                	add    %eax,%edx
c010081b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010081e:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
c0100820:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0100823:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100826:	39 c2                	cmp    %eax,%edx
c0100828:	7d 4a                	jge    c0100874 <debuginfo_eip+0x336>
        for (lline = lfun + 1;
c010082a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010082d:	83 c0 01             	add    $0x1,%eax
c0100830:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0100833:	eb 18                	jmp    c010084d <debuginfo_eip+0x30f>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
c0100835:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100838:	8b 40 14             	mov    0x14(%eax),%eax
c010083b:	8d 50 01             	lea    0x1(%eax),%edx
c010083e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100841:	89 50 14             	mov    %edx,0x14(%eax)
    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
c0100844:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100847:	83 c0 01             	add    $0x1,%eax
c010084a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
c010084d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100850:	8b 45 d8             	mov    -0x28(%ebp),%eax
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
c0100853:	39 c2                	cmp    %eax,%edx
c0100855:	7d 1d                	jge    c0100874 <debuginfo_eip+0x336>
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0100857:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010085a:	89 c2                	mov    %eax,%edx
c010085c:	89 d0                	mov    %edx,%eax
c010085e:	01 c0                	add    %eax,%eax
c0100860:	01 d0                	add    %edx,%eax
c0100862:	c1 e0 02             	shl    $0x2,%eax
c0100865:	89 c2                	mov    %eax,%edx
c0100867:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010086a:	01 d0                	add    %edx,%eax
c010086c:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100870:	3c a0                	cmp    $0xa0,%al
c0100872:	74 c1                	je     c0100835 <debuginfo_eip+0x2f7>
             lline ++) {
            info->eip_fn_narg ++;
        }
    }
    return 0;
c0100874:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100879:	c9                   	leave  
c010087a:	c3                   	ret    

c010087b <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
c010087b:	55                   	push   %ebp
c010087c:	89 e5                	mov    %esp,%ebp
c010087e:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c0100881:	c7 04 24 96 60 10 c0 	movl   $0xc0106096,(%esp)
c0100888:	e8 ba fa ff ff       	call   c0100347 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c010088d:	c7 44 24 04 2a 00 10 	movl   $0xc010002a,0x4(%esp)
c0100894:	c0 
c0100895:	c7 04 24 af 60 10 c0 	movl   $0xc01060af,(%esp)
c010089c:	e8 a6 fa ff ff       	call   c0100347 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
c01008a1:	c7 44 24 04 d5 5f 10 	movl   $0xc0105fd5,0x4(%esp)
c01008a8:	c0 
c01008a9:	c7 04 24 c7 60 10 c0 	movl   $0xc01060c7,(%esp)
c01008b0:	e8 92 fa ff ff       	call   c0100347 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
c01008b5:	c7 44 24 04 36 7a 11 	movl   $0xc0117a36,0x4(%esp)
c01008bc:	c0 
c01008bd:	c7 04 24 df 60 10 c0 	movl   $0xc01060df,(%esp)
c01008c4:	e8 7e fa ff ff       	call   c0100347 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
c01008c9:	c7 44 24 04 c8 89 11 	movl   $0xc01189c8,0x4(%esp)
c01008d0:	c0 
c01008d1:	c7 04 24 f7 60 10 c0 	movl   $0xc01060f7,(%esp)
c01008d8:	e8 6a fa ff ff       	call   c0100347 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c01008dd:	b8 c8 89 11 c0       	mov    $0xc01189c8,%eax
c01008e2:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01008e8:	b8 2a 00 10 c0       	mov    $0xc010002a,%eax
c01008ed:	29 c2                	sub    %eax,%edx
c01008ef:	89 d0                	mov    %edx,%eax
c01008f1:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01008f7:	85 c0                	test   %eax,%eax
c01008f9:	0f 48 c2             	cmovs  %edx,%eax
c01008fc:	c1 f8 0a             	sar    $0xa,%eax
c01008ff:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100903:	c7 04 24 10 61 10 c0 	movl   $0xc0106110,(%esp)
c010090a:	e8 38 fa ff ff       	call   c0100347 <cprintf>
}
c010090f:	c9                   	leave  
c0100910:	c3                   	ret    

c0100911 <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
c0100911:	55                   	push   %ebp
c0100912:	89 e5                	mov    %esp,%ebp
c0100914:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
c010091a:	8d 45 dc             	lea    -0x24(%ebp),%eax
c010091d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100921:	8b 45 08             	mov    0x8(%ebp),%eax
c0100924:	89 04 24             	mov    %eax,(%esp)
c0100927:	e8 12 fc ff ff       	call   c010053e <debuginfo_eip>
c010092c:	85 c0                	test   %eax,%eax
c010092e:	74 15                	je     c0100945 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c0100930:	8b 45 08             	mov    0x8(%ebp),%eax
c0100933:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100937:	c7 04 24 3a 61 10 c0 	movl   $0xc010613a,(%esp)
c010093e:	e8 04 fa ff ff       	call   c0100347 <cprintf>
c0100943:	eb 6d                	jmp    c01009b2 <print_debuginfo+0xa1>
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100945:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010094c:	eb 1c                	jmp    c010096a <print_debuginfo+0x59>
            fnname[j] = info.eip_fn_name[j];
c010094e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0100951:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100954:	01 d0                	add    %edx,%eax
c0100956:	0f b6 00             	movzbl (%eax),%eax
c0100959:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c010095f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100962:	01 ca                	add    %ecx,%edx
c0100964:	88 02                	mov    %al,(%edx)
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100966:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010096a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010096d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0100970:	7f dc                	jg     c010094e <print_debuginfo+0x3d>
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
c0100972:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c0100978:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010097b:	01 d0                	add    %edx,%eax
c010097d:	c6 00 00             	movb   $0x0,(%eax)
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
c0100980:	8b 45 ec             	mov    -0x14(%ebp),%eax
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c0100983:	8b 55 08             	mov    0x8(%ebp),%edx
c0100986:	89 d1                	mov    %edx,%ecx
c0100988:	29 c1                	sub    %eax,%ecx
c010098a:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010098d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100990:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0100994:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c010099a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c010099e:	89 54 24 08          	mov    %edx,0x8(%esp)
c01009a2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009a6:	c7 04 24 56 61 10 c0 	movl   $0xc0106156,(%esp)
c01009ad:	e8 95 f9 ff ff       	call   c0100347 <cprintf>
                fnname, eip - info.eip_fn_addr);
    }
}
c01009b2:	c9                   	leave  
c01009b3:	c3                   	ret    

c01009b4 <read_eip>:

static __noinline uint32_t
read_eip(void) {
c01009b4:	55                   	push   %ebp
c01009b5:	89 e5                	mov    %esp,%ebp
c01009b7:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
c01009ba:	8b 45 04             	mov    0x4(%ebp),%eax
c01009bd:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
c01009c0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01009c3:	c9                   	leave  
c01009c4:	c3                   	ret    

c01009c5 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
c01009c5:	55                   	push   %ebp
c01009c6:	89 e5                	mov    %esp,%ebp
c01009c8:	83 ec 38             	sub    $0x38,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
c01009cb:	89 e8                	mov    %ebp,%eax
c01009cd:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return ebp;
c01009d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp = read_ebp(), eip = read_eip();
c01009d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01009d6:	e8 d9 ff ff ff       	call   c01009b4 <read_eip>
c01009db:	89 45 f0             	mov    %eax,-0x10(%ebp)

    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
c01009de:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01009e5:	e9 88 00 00 00       	jmp    c0100a72 <print_stackframe+0xad>
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
c01009ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01009ed:	89 44 24 08          	mov    %eax,0x8(%esp)
c01009f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01009f4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009f8:	c7 04 24 68 61 10 c0 	movl   $0xc0106168,(%esp)
c01009ff:	e8 43 f9 ff ff       	call   c0100347 <cprintf>
        uint32_t *args = (uint32_t *)ebp + 2;
c0100a04:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a07:	83 c0 08             	add    $0x8,%eax
c0100a0a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (j = 0; j < 4; j ++) {
c0100a0d:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0100a14:	eb 25                	jmp    c0100a3b <print_stackframe+0x76>
            cprintf("0x%08x ", args[j]);
c0100a16:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a19:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100a20:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100a23:	01 d0                	add    %edx,%eax
c0100a25:	8b 00                	mov    (%eax),%eax
c0100a27:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a2b:	c7 04 24 84 61 10 c0 	movl   $0xc0106184,(%esp)
c0100a32:	e8 10 f9 ff ff       	call   c0100347 <cprintf>

    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
        uint32_t *args = (uint32_t *)ebp + 2;
        for (j = 0; j < 4; j ++) {
c0100a37:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
c0100a3b:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
c0100a3f:	7e d5                	jle    c0100a16 <print_stackframe+0x51>
            cprintf("0x%08x ", args[j]);
        }
        cprintf("\n");
c0100a41:	c7 04 24 8c 61 10 c0 	movl   $0xc010618c,(%esp)
c0100a48:	e8 fa f8 ff ff       	call   c0100347 <cprintf>
        print_debuginfo(eip - 1);
c0100a4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100a50:	83 e8 01             	sub    $0x1,%eax
c0100a53:	89 04 24             	mov    %eax,(%esp)
c0100a56:	e8 b6 fe ff ff       	call   c0100911 <print_debuginfo>
        eip = ((uint32_t *)ebp)[1];
c0100a5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a5e:	83 c0 04             	add    $0x4,%eax
c0100a61:	8b 00                	mov    (%eax),%eax
c0100a63:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ebp = ((uint32_t *)ebp)[0];
c0100a66:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a69:	8b 00                	mov    (%eax),%eax
c0100a6b:	89 45 f4             	mov    %eax,-0xc(%ebp)
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp = read_ebp(), eip = read_eip();

    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
c0100a6e:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0100a72:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100a76:	74 0a                	je     c0100a82 <print_stackframe+0xbd>
c0100a78:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
c0100a7c:	0f 8e 68 ff ff ff    	jle    c01009ea <print_stackframe+0x25>
        cprintf("\n");
        print_debuginfo(eip - 1);
        eip = ((uint32_t *)ebp)[1];
        ebp = ((uint32_t *)ebp)[0];
    }
}
c0100a82:	c9                   	leave  
c0100a83:	c3                   	ret    

c0100a84 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c0100a84:	55                   	push   %ebp
c0100a85:	89 e5                	mov    %esp,%ebp
c0100a87:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
c0100a8a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100a91:	eb 0c                	jmp    c0100a9f <parse+0x1b>
            *buf ++ = '\0';
c0100a93:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a96:	8d 50 01             	lea    0x1(%eax),%edx
c0100a99:	89 55 08             	mov    %edx,0x8(%ebp)
c0100a9c:	c6 00 00             	movb   $0x0,(%eax)
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100a9f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100aa2:	0f b6 00             	movzbl (%eax),%eax
c0100aa5:	84 c0                	test   %al,%al
c0100aa7:	74 1d                	je     c0100ac6 <parse+0x42>
c0100aa9:	8b 45 08             	mov    0x8(%ebp),%eax
c0100aac:	0f b6 00             	movzbl (%eax),%eax
c0100aaf:	0f be c0             	movsbl %al,%eax
c0100ab2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100ab6:	c7 04 24 10 62 10 c0 	movl   $0xc0106210,(%esp)
c0100abd:	e8 cb 51 00 00       	call   c0105c8d <strchr>
c0100ac2:	85 c0                	test   %eax,%eax
c0100ac4:	75 cd                	jne    c0100a93 <parse+0xf>
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
c0100ac6:	8b 45 08             	mov    0x8(%ebp),%eax
c0100ac9:	0f b6 00             	movzbl (%eax),%eax
c0100acc:	84 c0                	test   %al,%al
c0100ace:	75 02                	jne    c0100ad2 <parse+0x4e>
            break;
c0100ad0:	eb 67                	jmp    c0100b39 <parse+0xb5>
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0100ad2:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0100ad6:	75 14                	jne    c0100aec <parse+0x68>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0100ad8:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
c0100adf:	00 
c0100ae0:	c7 04 24 15 62 10 c0 	movl   $0xc0106215,(%esp)
c0100ae7:	e8 5b f8 ff ff       	call   c0100347 <cprintf>
        }
        argv[argc ++] = buf;
c0100aec:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100aef:	8d 50 01             	lea    0x1(%eax),%edx
c0100af2:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100af5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100afc:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100aff:	01 c2                	add    %eax,%edx
c0100b01:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b04:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100b06:	eb 04                	jmp    c0100b0c <parse+0x88>
            buf ++;
c0100b08:	83 45 08 01          	addl   $0x1,0x8(%ebp)
        // save and scan past next arg
        if (argc == MAXARGS - 1) {
            cprintf("Too many arguments (max %d).\n", MAXARGS);
        }
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100b0c:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b0f:	0f b6 00             	movzbl (%eax),%eax
c0100b12:	84 c0                	test   %al,%al
c0100b14:	74 1d                	je     c0100b33 <parse+0xaf>
c0100b16:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b19:	0f b6 00             	movzbl (%eax),%eax
c0100b1c:	0f be c0             	movsbl %al,%eax
c0100b1f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b23:	c7 04 24 10 62 10 c0 	movl   $0xc0106210,(%esp)
c0100b2a:	e8 5e 51 00 00       	call   c0105c8d <strchr>
c0100b2f:	85 c0                	test   %eax,%eax
c0100b31:	74 d5                	je     c0100b08 <parse+0x84>
            buf ++;
        }
    }
c0100b33:	90                   	nop
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100b34:	e9 66 ff ff ff       	jmp    c0100a9f <parse+0x1b>
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
            buf ++;
        }
    }
    return argc;
c0100b39:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100b3c:	c9                   	leave  
c0100b3d:	c3                   	ret    

c0100b3e <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c0100b3e:	55                   	push   %ebp
c0100b3f:	89 e5                	mov    %esp,%ebp
c0100b41:	83 ec 68             	sub    $0x68,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0100b44:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100b47:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b4b:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b4e:	89 04 24             	mov    %eax,(%esp)
c0100b51:	e8 2e ff ff ff       	call   c0100a84 <parse>
c0100b56:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0100b59:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100b5d:	75 0a                	jne    c0100b69 <runcmd+0x2b>
        return 0;
c0100b5f:	b8 00 00 00 00       	mov    $0x0,%eax
c0100b64:	e9 85 00 00 00       	jmp    c0100bee <runcmd+0xb0>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100b69:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100b70:	eb 5c                	jmp    c0100bce <runcmd+0x90>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0100b72:	8b 4d b0             	mov    -0x50(%ebp),%ecx
c0100b75:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100b78:	89 d0                	mov    %edx,%eax
c0100b7a:	01 c0                	add    %eax,%eax
c0100b7c:	01 d0                	add    %edx,%eax
c0100b7e:	c1 e0 02             	shl    $0x2,%eax
c0100b81:	05 20 70 11 c0       	add    $0xc0117020,%eax
c0100b86:	8b 00                	mov    (%eax),%eax
c0100b88:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0100b8c:	89 04 24             	mov    %eax,(%esp)
c0100b8f:	e8 5a 50 00 00       	call   c0105bee <strcmp>
c0100b94:	85 c0                	test   %eax,%eax
c0100b96:	75 32                	jne    c0100bca <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
c0100b98:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100b9b:	89 d0                	mov    %edx,%eax
c0100b9d:	01 c0                	add    %eax,%eax
c0100b9f:	01 d0                	add    %edx,%eax
c0100ba1:	c1 e0 02             	shl    $0x2,%eax
c0100ba4:	05 20 70 11 c0       	add    $0xc0117020,%eax
c0100ba9:	8b 40 08             	mov    0x8(%eax),%eax
c0100bac:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100baf:	8d 4a ff             	lea    -0x1(%edx),%ecx
c0100bb2:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100bb5:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100bb9:	8d 55 b0             	lea    -0x50(%ebp),%edx
c0100bbc:	83 c2 04             	add    $0x4,%edx
c0100bbf:	89 54 24 04          	mov    %edx,0x4(%esp)
c0100bc3:	89 0c 24             	mov    %ecx,(%esp)
c0100bc6:	ff d0                	call   *%eax
c0100bc8:	eb 24                	jmp    c0100bee <runcmd+0xb0>
    int argc = parse(buf, argv);
    if (argc == 0) {
        return 0;
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100bca:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100bce:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100bd1:	83 f8 02             	cmp    $0x2,%eax
c0100bd4:	76 9c                	jbe    c0100b72 <runcmd+0x34>
        if (strcmp(commands[i].name, argv[0]) == 0) {
            return commands[i].func(argc - 1, argv + 1, tf);
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0100bd6:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0100bd9:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100bdd:	c7 04 24 33 62 10 c0 	movl   $0xc0106233,(%esp)
c0100be4:	e8 5e f7 ff ff       	call   c0100347 <cprintf>
    return 0;
c0100be9:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100bee:	c9                   	leave  
c0100bef:	c3                   	ret    

c0100bf0 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c0100bf0:	55                   	push   %ebp
c0100bf1:	89 e5                	mov    %esp,%ebp
c0100bf3:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0100bf6:	c7 04 24 4c 62 10 c0 	movl   $0xc010624c,(%esp)
c0100bfd:	e8 45 f7 ff ff       	call   c0100347 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
c0100c02:	c7 04 24 74 62 10 c0 	movl   $0xc0106274,(%esp)
c0100c09:	e8 39 f7 ff ff       	call   c0100347 <cprintf>

    if (tf != NULL) {
c0100c0e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100c12:	74 0b                	je     c0100c1f <kmonitor+0x2f>
        print_trapframe(tf);
c0100c14:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c17:	89 04 24             	mov    %eax,(%esp)
c0100c1a:	e8 30 0e 00 00       	call   c0101a4f <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0100c1f:	c7 04 24 99 62 10 c0 	movl   $0xc0106299,(%esp)
c0100c26:	e8 13 f6 ff ff       	call   c010023e <readline>
c0100c2b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100c2e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100c32:	74 18                	je     c0100c4c <kmonitor+0x5c>
            if (runcmd(buf, tf) < 0) {
c0100c34:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c37:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c3e:	89 04 24             	mov    %eax,(%esp)
c0100c41:	e8 f8 fe ff ff       	call   c0100b3e <runcmd>
c0100c46:	85 c0                	test   %eax,%eax
c0100c48:	79 02                	jns    c0100c4c <kmonitor+0x5c>
                break;
c0100c4a:	eb 02                	jmp    c0100c4e <kmonitor+0x5e>
            }
        }
    }
c0100c4c:	eb d1                	jmp    c0100c1f <kmonitor+0x2f>
}
c0100c4e:	c9                   	leave  
c0100c4f:	c3                   	ret    

c0100c50 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c0100c50:	55                   	push   %ebp
c0100c51:	89 e5                	mov    %esp,%ebp
c0100c53:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c56:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100c5d:	eb 3f                	jmp    c0100c9e <mon_help+0x4e>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0100c5f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c62:	89 d0                	mov    %edx,%eax
c0100c64:	01 c0                	add    %eax,%eax
c0100c66:	01 d0                	add    %edx,%eax
c0100c68:	c1 e0 02             	shl    $0x2,%eax
c0100c6b:	05 20 70 11 c0       	add    $0xc0117020,%eax
c0100c70:	8b 48 04             	mov    0x4(%eax),%ecx
c0100c73:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c76:	89 d0                	mov    %edx,%eax
c0100c78:	01 c0                	add    %eax,%eax
c0100c7a:	01 d0                	add    %edx,%eax
c0100c7c:	c1 e0 02             	shl    $0x2,%eax
c0100c7f:	05 20 70 11 c0       	add    $0xc0117020,%eax
c0100c84:	8b 00                	mov    (%eax),%eax
c0100c86:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100c8a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c8e:	c7 04 24 9d 62 10 c0 	movl   $0xc010629d,(%esp)
c0100c95:	e8 ad f6 ff ff       	call   c0100347 <cprintf>

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c9a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100c9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ca1:	83 f8 02             	cmp    $0x2,%eax
c0100ca4:	76 b9                	jbe    c0100c5f <mon_help+0xf>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
    }
    return 0;
c0100ca6:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100cab:	c9                   	leave  
c0100cac:	c3                   	ret    

c0100cad <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c0100cad:	55                   	push   %ebp
c0100cae:	89 e5                	mov    %esp,%ebp
c0100cb0:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c0100cb3:	e8 c3 fb ff ff       	call   c010087b <print_kerninfo>
    return 0;
c0100cb8:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100cbd:	c9                   	leave  
c0100cbe:	c3                   	ret    

c0100cbf <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c0100cbf:	55                   	push   %ebp
c0100cc0:	89 e5                	mov    %esp,%ebp
c0100cc2:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c0100cc5:	e8 fb fc ff ff       	call   c01009c5 <print_stackframe>
    return 0;
c0100cca:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100ccf:	c9                   	leave  
c0100cd0:	c3                   	ret    

c0100cd1 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
c0100cd1:	55                   	push   %ebp
c0100cd2:	89 e5                	mov    %esp,%ebp
c0100cd4:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
c0100cd7:	a1 60 7e 11 c0       	mov    0xc0117e60,%eax
c0100cdc:	85 c0                	test   %eax,%eax
c0100cde:	74 02                	je     c0100ce2 <__panic+0x11>
        goto panic_dead;
c0100ce0:	eb 48                	jmp    c0100d2a <__panic+0x59>
    }
    is_panic = 1;
c0100ce2:	c7 05 60 7e 11 c0 01 	movl   $0x1,0xc0117e60
c0100ce9:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
c0100cec:	8d 45 14             	lea    0x14(%ebp),%eax
c0100cef:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
c0100cf2:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100cf5:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100cf9:	8b 45 08             	mov    0x8(%ebp),%eax
c0100cfc:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d00:	c7 04 24 a6 62 10 c0 	movl   $0xc01062a6,(%esp)
c0100d07:	e8 3b f6 ff ff       	call   c0100347 <cprintf>
    vcprintf(fmt, ap);
c0100d0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d0f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d13:	8b 45 10             	mov    0x10(%ebp),%eax
c0100d16:	89 04 24             	mov    %eax,(%esp)
c0100d19:	e8 f6 f5 ff ff       	call   c0100314 <vcprintf>
    cprintf("\n");
c0100d1e:	c7 04 24 c2 62 10 c0 	movl   $0xc01062c2,(%esp)
c0100d25:	e8 1d f6 ff ff       	call   c0100347 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
c0100d2a:	e8 85 09 00 00       	call   c01016b4 <intr_disable>
    while (1) {
        kmonitor(NULL);
c0100d2f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100d36:	e8 b5 fe ff ff       	call   c0100bf0 <kmonitor>
    }
c0100d3b:	eb f2                	jmp    c0100d2f <__panic+0x5e>

c0100d3d <__warn>:
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
c0100d3d:	55                   	push   %ebp
c0100d3e:	89 e5                	mov    %esp,%ebp
c0100d40:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
c0100d43:	8d 45 14             	lea    0x14(%ebp),%eax
c0100d46:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
c0100d49:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100d4c:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100d50:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d53:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d57:	c7 04 24 c4 62 10 c0 	movl   $0xc01062c4,(%esp)
c0100d5e:	e8 e4 f5 ff ff       	call   c0100347 <cprintf>
    vcprintf(fmt, ap);
c0100d63:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d66:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d6a:	8b 45 10             	mov    0x10(%ebp),%eax
c0100d6d:	89 04 24             	mov    %eax,(%esp)
c0100d70:	e8 9f f5 ff ff       	call   c0100314 <vcprintf>
    cprintf("\n");
c0100d75:	c7 04 24 c2 62 10 c0 	movl   $0xc01062c2,(%esp)
c0100d7c:	e8 c6 f5 ff ff       	call   c0100347 <cprintf>
    va_end(ap);
}
c0100d81:	c9                   	leave  
c0100d82:	c3                   	ret    

c0100d83 <is_kernel_panic>:

bool
is_kernel_panic(void) {
c0100d83:	55                   	push   %ebp
c0100d84:	89 e5                	mov    %esp,%ebp
    return is_panic;
c0100d86:	a1 60 7e 11 c0       	mov    0xc0117e60,%eax
}
c0100d8b:	5d                   	pop    %ebp
c0100d8c:	c3                   	ret    

c0100d8d <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c0100d8d:	55                   	push   %ebp
c0100d8e:	89 e5                	mov    %esp,%ebp
c0100d90:	83 ec 28             	sub    $0x28,%esp
c0100d93:	66 c7 45 f6 43 00    	movw   $0x43,-0xa(%ebp)
c0100d99:	c6 45 f5 34          	movb   $0x34,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100d9d:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0100da1:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100da5:	ee                   	out    %al,(%dx)
c0100da6:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c0100dac:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
c0100db0:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100db4:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100db8:	ee                   	out    %al,(%dx)
c0100db9:	66 c7 45 ee 40 00    	movw   $0x40,-0x12(%ebp)
c0100dbf:	c6 45 ed 2e          	movb   $0x2e,-0x13(%ebp)
c0100dc3:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100dc7:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100dcb:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c0100dcc:	c7 05 4c 89 11 c0 00 	movl   $0x0,0xc011894c
c0100dd3:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c0100dd6:	c7 04 24 e2 62 10 c0 	movl   $0xc01062e2,(%esp)
c0100ddd:	e8 65 f5 ff ff       	call   c0100347 <cprintf>
    pic_enable(IRQ_TIMER);
c0100de2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100de9:	e8 24 09 00 00       	call   c0101712 <pic_enable>
}
c0100dee:	c9                   	leave  
c0100def:	c3                   	ret    

c0100df0 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0100df0:	55                   	push   %ebp
c0100df1:	89 e5                	mov    %esp,%ebp
c0100df3:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0100df6:	9c                   	pushf  
c0100df7:	58                   	pop    %eax
c0100df8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0100dfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0100dfe:	25 00 02 00 00       	and    $0x200,%eax
c0100e03:	85 c0                	test   %eax,%eax
c0100e05:	74 0c                	je     c0100e13 <__intr_save+0x23>
        intr_disable();
c0100e07:	e8 a8 08 00 00       	call   c01016b4 <intr_disable>
        return 1;
c0100e0c:	b8 01 00 00 00       	mov    $0x1,%eax
c0100e11:	eb 05                	jmp    c0100e18 <__intr_save+0x28>
    }
    return 0;
c0100e13:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100e18:	c9                   	leave  
c0100e19:	c3                   	ret    

c0100e1a <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0100e1a:	55                   	push   %ebp
c0100e1b:	89 e5                	mov    %esp,%ebp
c0100e1d:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0100e20:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100e24:	74 05                	je     c0100e2b <__intr_restore+0x11>
        intr_enable();
c0100e26:	e8 83 08 00 00       	call   c01016ae <intr_enable>
    }
}
c0100e2b:	c9                   	leave  
c0100e2c:	c3                   	ret    

c0100e2d <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c0100e2d:	55                   	push   %ebp
c0100e2e:	89 e5                	mov    %esp,%ebp
c0100e30:	83 ec 10             	sub    $0x10,%esp
c0100e33:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100e39:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0100e3d:	89 c2                	mov    %eax,%edx
c0100e3f:	ec                   	in     (%dx),%al
c0100e40:	88 45 fd             	mov    %al,-0x3(%ebp)
c0100e43:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c0100e49:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0100e4d:	89 c2                	mov    %eax,%edx
c0100e4f:	ec                   	in     (%dx),%al
c0100e50:	88 45 f9             	mov    %al,-0x7(%ebp)
c0100e53:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
c0100e59:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100e5d:	89 c2                	mov    %eax,%edx
c0100e5f:	ec                   	in     (%dx),%al
c0100e60:	88 45 f5             	mov    %al,-0xb(%ebp)
c0100e63:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
c0100e69:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0100e6d:	89 c2                	mov    %eax,%edx
c0100e6f:	ec                   	in     (%dx),%al
c0100e70:	88 45 f1             	mov    %al,-0xf(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c0100e73:	c9                   	leave  
c0100e74:	c3                   	ret    

c0100e75 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c0100e75:	55                   	push   %ebp
c0100e76:	89 e5                	mov    %esp,%ebp
c0100e78:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c0100e7b:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c0100e82:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100e85:	0f b7 00             	movzwl (%eax),%eax
c0100e88:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c0100e8c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100e8f:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c0100e94:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100e97:	0f b7 00             	movzwl (%eax),%eax
c0100e9a:	66 3d 5a a5          	cmp    $0xa55a,%ax
c0100e9e:	74 12                	je     c0100eb2 <cga_init+0x3d>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c0100ea0:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c0100ea7:	66 c7 05 86 7e 11 c0 	movw   $0x3b4,0xc0117e86
c0100eae:	b4 03 
c0100eb0:	eb 13                	jmp    c0100ec5 <cga_init+0x50>
    } else {
        *cp = was;
c0100eb2:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100eb5:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0100eb9:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c0100ebc:	66 c7 05 86 7e 11 c0 	movw   $0x3d4,0xc0117e86
c0100ec3:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c0100ec5:	0f b7 05 86 7e 11 c0 	movzwl 0xc0117e86,%eax
c0100ecc:	0f b7 c0             	movzwl %ax,%eax
c0100ecf:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0100ed3:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100ed7:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100edb:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100edf:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
c0100ee0:	0f b7 05 86 7e 11 c0 	movzwl 0xc0117e86,%eax
c0100ee7:	83 c0 01             	add    $0x1,%eax
c0100eea:	0f b7 c0             	movzwl %ax,%eax
c0100eed:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100ef1:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c0100ef5:	89 c2                	mov    %eax,%edx
c0100ef7:	ec                   	in     (%dx),%al
c0100ef8:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c0100efb:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100eff:	0f b6 c0             	movzbl %al,%eax
c0100f02:	c1 e0 08             	shl    $0x8,%eax
c0100f05:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c0100f08:	0f b7 05 86 7e 11 c0 	movzwl 0xc0117e86,%eax
c0100f0f:	0f b7 c0             	movzwl %ax,%eax
c0100f12:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c0100f16:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f1a:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0100f1e:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0100f22:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
c0100f23:	0f b7 05 86 7e 11 c0 	movzwl 0xc0117e86,%eax
c0100f2a:	83 c0 01             	add    $0x1,%eax
c0100f2d:	0f b7 c0             	movzwl %ax,%eax
c0100f30:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f34:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
c0100f38:	89 c2                	mov    %eax,%edx
c0100f3a:	ec                   	in     (%dx),%al
c0100f3b:	88 45 e5             	mov    %al,-0x1b(%ebp)
    return data;
c0100f3e:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0100f42:	0f b6 c0             	movzbl %al,%eax
c0100f45:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c0100f48:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100f4b:	a3 80 7e 11 c0       	mov    %eax,0xc0117e80
    crt_pos = pos;
c0100f50:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100f53:	66 a3 84 7e 11 c0    	mov    %ax,0xc0117e84
}
c0100f59:	c9                   	leave  
c0100f5a:	c3                   	ret    

c0100f5b <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c0100f5b:	55                   	push   %ebp
c0100f5c:	89 e5                	mov    %esp,%ebp
c0100f5e:	83 ec 48             	sub    $0x48,%esp
c0100f61:	66 c7 45 f6 fa 03    	movw   $0x3fa,-0xa(%ebp)
c0100f67:	c6 45 f5 00          	movb   $0x0,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f6b:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0100f6f:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100f73:	ee                   	out    %al,(%dx)
c0100f74:	66 c7 45 f2 fb 03    	movw   $0x3fb,-0xe(%ebp)
c0100f7a:	c6 45 f1 80          	movb   $0x80,-0xf(%ebp)
c0100f7e:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100f82:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100f86:	ee                   	out    %al,(%dx)
c0100f87:	66 c7 45 ee f8 03    	movw   $0x3f8,-0x12(%ebp)
c0100f8d:	c6 45 ed 0c          	movb   $0xc,-0x13(%ebp)
c0100f91:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100f95:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100f99:	ee                   	out    %al,(%dx)
c0100f9a:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c0100fa0:	c6 45 e9 00          	movb   $0x0,-0x17(%ebp)
c0100fa4:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0100fa8:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0100fac:	ee                   	out    %al,(%dx)
c0100fad:	66 c7 45 e6 fb 03    	movw   $0x3fb,-0x1a(%ebp)
c0100fb3:	c6 45 e5 03          	movb   $0x3,-0x1b(%ebp)
c0100fb7:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0100fbb:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0100fbf:	ee                   	out    %al,(%dx)
c0100fc0:	66 c7 45 e2 fc 03    	movw   $0x3fc,-0x1e(%ebp)
c0100fc6:	c6 45 e1 00          	movb   $0x0,-0x1f(%ebp)
c0100fca:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0100fce:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0100fd2:	ee                   	out    %al,(%dx)
c0100fd3:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
c0100fd9:	c6 45 dd 01          	movb   $0x1,-0x23(%ebp)
c0100fdd:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0100fe1:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0100fe5:	ee                   	out    %al,(%dx)
c0100fe6:	66 c7 45 da fd 03    	movw   $0x3fd,-0x26(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100fec:	0f b7 45 da          	movzwl -0x26(%ebp),%eax
c0100ff0:	89 c2                	mov    %eax,%edx
c0100ff2:	ec                   	in     (%dx),%al
c0100ff3:	88 45 d9             	mov    %al,-0x27(%ebp)
    return data;
c0100ff6:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c0100ffa:	3c ff                	cmp    $0xff,%al
c0100ffc:	0f 95 c0             	setne  %al
c0100fff:	0f b6 c0             	movzbl %al,%eax
c0101002:	a3 88 7e 11 c0       	mov    %eax,0xc0117e88
c0101007:	66 c7 45 d6 fa 03    	movw   $0x3fa,-0x2a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010100d:	0f b7 45 d6          	movzwl -0x2a(%ebp),%eax
c0101011:	89 c2                	mov    %eax,%edx
c0101013:	ec                   	in     (%dx),%al
c0101014:	88 45 d5             	mov    %al,-0x2b(%ebp)
c0101017:	66 c7 45 d2 f8 03    	movw   $0x3f8,-0x2e(%ebp)
c010101d:	0f b7 45 d2          	movzwl -0x2e(%ebp),%eax
c0101021:	89 c2                	mov    %eax,%edx
c0101023:	ec                   	in     (%dx),%al
c0101024:	88 45 d1             	mov    %al,-0x2f(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c0101027:	a1 88 7e 11 c0       	mov    0xc0117e88,%eax
c010102c:	85 c0                	test   %eax,%eax
c010102e:	74 0c                	je     c010103c <serial_init+0xe1>
        pic_enable(IRQ_COM1);
c0101030:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0101037:	e8 d6 06 00 00       	call   c0101712 <pic_enable>
    }
}
c010103c:	c9                   	leave  
c010103d:	c3                   	ret    

c010103e <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c010103e:	55                   	push   %ebp
c010103f:	89 e5                	mov    %esp,%ebp
c0101041:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c0101044:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c010104b:	eb 09                	jmp    c0101056 <lpt_putc_sub+0x18>
        delay();
c010104d:	e8 db fd ff ff       	call   c0100e2d <delay>
}

static void
lpt_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c0101052:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0101056:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
c010105c:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101060:	89 c2                	mov    %eax,%edx
c0101062:	ec                   	in     (%dx),%al
c0101063:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101066:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c010106a:	84 c0                	test   %al,%al
c010106c:	78 09                	js     c0101077 <lpt_putc_sub+0x39>
c010106e:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0101075:	7e d6                	jle    c010104d <lpt_putc_sub+0xf>
        delay();
    }
    outb(LPTPORT + 0, c);
c0101077:	8b 45 08             	mov    0x8(%ebp),%eax
c010107a:	0f b6 c0             	movzbl %al,%eax
c010107d:	66 c7 45 f6 78 03    	movw   $0x378,-0xa(%ebp)
c0101083:	88 45 f5             	mov    %al,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101086:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c010108a:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c010108e:	ee                   	out    %al,(%dx)
c010108f:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
c0101095:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
c0101099:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c010109d:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01010a1:	ee                   	out    %al,(%dx)
c01010a2:	66 c7 45 ee 7a 03    	movw   $0x37a,-0x12(%ebp)
c01010a8:	c6 45 ed 08          	movb   $0x8,-0x13(%ebp)
c01010ac:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01010b0:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01010b4:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c01010b5:	c9                   	leave  
c01010b6:	c3                   	ret    

c01010b7 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c01010b7:	55                   	push   %ebp
c01010b8:	89 e5                	mov    %esp,%ebp
c01010ba:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c01010bd:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c01010c1:	74 0d                	je     c01010d0 <lpt_putc+0x19>
        lpt_putc_sub(c);
c01010c3:	8b 45 08             	mov    0x8(%ebp),%eax
c01010c6:	89 04 24             	mov    %eax,(%esp)
c01010c9:	e8 70 ff ff ff       	call   c010103e <lpt_putc_sub>
c01010ce:	eb 24                	jmp    c01010f4 <lpt_putc+0x3d>
    }
    else {
        lpt_putc_sub('\b');
c01010d0:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c01010d7:	e8 62 ff ff ff       	call   c010103e <lpt_putc_sub>
        lpt_putc_sub(' ');
c01010dc:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c01010e3:	e8 56 ff ff ff       	call   c010103e <lpt_putc_sub>
        lpt_putc_sub('\b');
c01010e8:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c01010ef:	e8 4a ff ff ff       	call   c010103e <lpt_putc_sub>
    }
}
c01010f4:	c9                   	leave  
c01010f5:	c3                   	ret    

c01010f6 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c01010f6:	55                   	push   %ebp
c01010f7:	89 e5                	mov    %esp,%ebp
c01010f9:	53                   	push   %ebx
c01010fa:	83 ec 34             	sub    $0x34,%esp
    // set black on white
    if (!(c & ~0xFF)) {
c01010fd:	8b 45 08             	mov    0x8(%ebp),%eax
c0101100:	b0 00                	mov    $0x0,%al
c0101102:	85 c0                	test   %eax,%eax
c0101104:	75 07                	jne    c010110d <cga_putc+0x17>
        c |= 0x0700;
c0101106:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c010110d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101110:	0f b6 c0             	movzbl %al,%eax
c0101113:	83 f8 0a             	cmp    $0xa,%eax
c0101116:	74 4c                	je     c0101164 <cga_putc+0x6e>
c0101118:	83 f8 0d             	cmp    $0xd,%eax
c010111b:	74 57                	je     c0101174 <cga_putc+0x7e>
c010111d:	83 f8 08             	cmp    $0x8,%eax
c0101120:	0f 85 88 00 00 00    	jne    c01011ae <cga_putc+0xb8>
    case '\b':
        if (crt_pos > 0) {
c0101126:	0f b7 05 84 7e 11 c0 	movzwl 0xc0117e84,%eax
c010112d:	66 85 c0             	test   %ax,%ax
c0101130:	74 30                	je     c0101162 <cga_putc+0x6c>
            crt_pos --;
c0101132:	0f b7 05 84 7e 11 c0 	movzwl 0xc0117e84,%eax
c0101139:	83 e8 01             	sub    $0x1,%eax
c010113c:	66 a3 84 7e 11 c0    	mov    %ax,0xc0117e84
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c0101142:	a1 80 7e 11 c0       	mov    0xc0117e80,%eax
c0101147:	0f b7 15 84 7e 11 c0 	movzwl 0xc0117e84,%edx
c010114e:	0f b7 d2             	movzwl %dx,%edx
c0101151:	01 d2                	add    %edx,%edx
c0101153:	01 c2                	add    %eax,%edx
c0101155:	8b 45 08             	mov    0x8(%ebp),%eax
c0101158:	b0 00                	mov    $0x0,%al
c010115a:	83 c8 20             	or     $0x20,%eax
c010115d:	66 89 02             	mov    %ax,(%edx)
        }
        break;
c0101160:	eb 72                	jmp    c01011d4 <cga_putc+0xde>
c0101162:	eb 70                	jmp    c01011d4 <cga_putc+0xde>
    case '\n':
        crt_pos += CRT_COLS;
c0101164:	0f b7 05 84 7e 11 c0 	movzwl 0xc0117e84,%eax
c010116b:	83 c0 50             	add    $0x50,%eax
c010116e:	66 a3 84 7e 11 c0    	mov    %ax,0xc0117e84
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c0101174:	0f b7 1d 84 7e 11 c0 	movzwl 0xc0117e84,%ebx
c010117b:	0f b7 0d 84 7e 11 c0 	movzwl 0xc0117e84,%ecx
c0101182:	0f b7 c1             	movzwl %cx,%eax
c0101185:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
c010118b:	c1 e8 10             	shr    $0x10,%eax
c010118e:	89 c2                	mov    %eax,%edx
c0101190:	66 c1 ea 06          	shr    $0x6,%dx
c0101194:	89 d0                	mov    %edx,%eax
c0101196:	c1 e0 02             	shl    $0x2,%eax
c0101199:	01 d0                	add    %edx,%eax
c010119b:	c1 e0 04             	shl    $0x4,%eax
c010119e:	29 c1                	sub    %eax,%ecx
c01011a0:	89 ca                	mov    %ecx,%edx
c01011a2:	89 d8                	mov    %ebx,%eax
c01011a4:	29 d0                	sub    %edx,%eax
c01011a6:	66 a3 84 7e 11 c0    	mov    %ax,0xc0117e84
        break;
c01011ac:	eb 26                	jmp    c01011d4 <cga_putc+0xde>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c01011ae:	8b 0d 80 7e 11 c0    	mov    0xc0117e80,%ecx
c01011b4:	0f b7 05 84 7e 11 c0 	movzwl 0xc0117e84,%eax
c01011bb:	8d 50 01             	lea    0x1(%eax),%edx
c01011be:	66 89 15 84 7e 11 c0 	mov    %dx,0xc0117e84
c01011c5:	0f b7 c0             	movzwl %ax,%eax
c01011c8:	01 c0                	add    %eax,%eax
c01011ca:	8d 14 01             	lea    (%ecx,%eax,1),%edx
c01011cd:	8b 45 08             	mov    0x8(%ebp),%eax
c01011d0:	66 89 02             	mov    %ax,(%edx)
        break;
c01011d3:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c01011d4:	0f b7 05 84 7e 11 c0 	movzwl 0xc0117e84,%eax
c01011db:	66 3d cf 07          	cmp    $0x7cf,%ax
c01011df:	76 5b                	jbe    c010123c <cga_putc+0x146>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c01011e1:	a1 80 7e 11 c0       	mov    0xc0117e80,%eax
c01011e6:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c01011ec:	a1 80 7e 11 c0       	mov    0xc0117e80,%eax
c01011f1:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
c01011f8:	00 
c01011f9:	89 54 24 04          	mov    %edx,0x4(%esp)
c01011fd:	89 04 24             	mov    %eax,(%esp)
c0101200:	e8 86 4c 00 00       	call   c0105e8b <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101205:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c010120c:	eb 15                	jmp    c0101223 <cga_putc+0x12d>
            crt_buf[i] = 0x0700 | ' ';
c010120e:	a1 80 7e 11 c0       	mov    0xc0117e80,%eax
c0101213:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101216:	01 d2                	add    %edx,%edx
c0101218:	01 d0                	add    %edx,%eax
c010121a:	66 c7 00 20 07       	movw   $0x720,(%eax)

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c010121f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101223:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c010122a:	7e e2                	jle    c010120e <cga_putc+0x118>
            crt_buf[i] = 0x0700 | ' ';
        }
        crt_pos -= CRT_COLS;
c010122c:	0f b7 05 84 7e 11 c0 	movzwl 0xc0117e84,%eax
c0101233:	83 e8 50             	sub    $0x50,%eax
c0101236:	66 a3 84 7e 11 c0    	mov    %ax,0xc0117e84
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c010123c:	0f b7 05 86 7e 11 c0 	movzwl 0xc0117e86,%eax
c0101243:	0f b7 c0             	movzwl %ax,%eax
c0101246:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c010124a:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
c010124e:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101252:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101256:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
c0101257:	0f b7 05 84 7e 11 c0 	movzwl 0xc0117e84,%eax
c010125e:	66 c1 e8 08          	shr    $0x8,%ax
c0101262:	0f b6 c0             	movzbl %al,%eax
c0101265:	0f b7 15 86 7e 11 c0 	movzwl 0xc0117e86,%edx
c010126c:	83 c2 01             	add    $0x1,%edx
c010126f:	0f b7 d2             	movzwl %dx,%edx
c0101272:	66 89 55 ee          	mov    %dx,-0x12(%ebp)
c0101276:	88 45 ed             	mov    %al,-0x13(%ebp)
c0101279:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c010127d:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101281:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
c0101282:	0f b7 05 86 7e 11 c0 	movzwl 0xc0117e86,%eax
c0101289:	0f b7 c0             	movzwl %ax,%eax
c010128c:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c0101290:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
c0101294:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101298:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c010129c:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
c010129d:	0f b7 05 84 7e 11 c0 	movzwl 0xc0117e84,%eax
c01012a4:	0f b6 c0             	movzbl %al,%eax
c01012a7:	0f b7 15 86 7e 11 c0 	movzwl 0xc0117e86,%edx
c01012ae:	83 c2 01             	add    $0x1,%edx
c01012b1:	0f b7 d2             	movzwl %dx,%edx
c01012b4:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c01012b8:	88 45 e5             	mov    %al,-0x1b(%ebp)
c01012bb:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01012bf:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01012c3:	ee                   	out    %al,(%dx)
}
c01012c4:	83 c4 34             	add    $0x34,%esp
c01012c7:	5b                   	pop    %ebx
c01012c8:	5d                   	pop    %ebp
c01012c9:	c3                   	ret    

c01012ca <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c01012ca:	55                   	push   %ebp
c01012cb:	89 e5                	mov    %esp,%ebp
c01012cd:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c01012d0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01012d7:	eb 09                	jmp    c01012e2 <serial_putc_sub+0x18>
        delay();
c01012d9:	e8 4f fb ff ff       	call   c0100e2d <delay>
}

static void
serial_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c01012de:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c01012e2:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01012e8:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01012ec:	89 c2                	mov    %eax,%edx
c01012ee:	ec                   	in     (%dx),%al
c01012ef:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c01012f2:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c01012f6:	0f b6 c0             	movzbl %al,%eax
c01012f9:	83 e0 20             	and    $0x20,%eax
c01012fc:	85 c0                	test   %eax,%eax
c01012fe:	75 09                	jne    c0101309 <serial_putc_sub+0x3f>
c0101300:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0101307:	7e d0                	jle    c01012d9 <serial_putc_sub+0xf>
        delay();
    }
    outb(COM1 + COM_TX, c);
c0101309:	8b 45 08             	mov    0x8(%ebp),%eax
c010130c:	0f b6 c0             	movzbl %al,%eax
c010130f:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c0101315:	88 45 f5             	mov    %al,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101318:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c010131c:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101320:	ee                   	out    %al,(%dx)
}
c0101321:	c9                   	leave  
c0101322:	c3                   	ret    

c0101323 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c0101323:	55                   	push   %ebp
c0101324:	89 e5                	mov    %esp,%ebp
c0101326:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c0101329:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c010132d:	74 0d                	je     c010133c <serial_putc+0x19>
        serial_putc_sub(c);
c010132f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101332:	89 04 24             	mov    %eax,(%esp)
c0101335:	e8 90 ff ff ff       	call   c01012ca <serial_putc_sub>
c010133a:	eb 24                	jmp    c0101360 <serial_putc+0x3d>
    }
    else {
        serial_putc_sub('\b');
c010133c:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101343:	e8 82 ff ff ff       	call   c01012ca <serial_putc_sub>
        serial_putc_sub(' ');
c0101348:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c010134f:	e8 76 ff ff ff       	call   c01012ca <serial_putc_sub>
        serial_putc_sub('\b');
c0101354:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c010135b:	e8 6a ff ff ff       	call   c01012ca <serial_putc_sub>
    }
}
c0101360:	c9                   	leave  
c0101361:	c3                   	ret    

c0101362 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c0101362:	55                   	push   %ebp
c0101363:	89 e5                	mov    %esp,%ebp
c0101365:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c0101368:	eb 33                	jmp    c010139d <cons_intr+0x3b>
        if (c != 0) {
c010136a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010136e:	74 2d                	je     c010139d <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
c0101370:	a1 a4 80 11 c0       	mov    0xc01180a4,%eax
c0101375:	8d 50 01             	lea    0x1(%eax),%edx
c0101378:	89 15 a4 80 11 c0    	mov    %edx,0xc01180a4
c010137e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101381:	88 90 a0 7e 11 c0    	mov    %dl,-0x3fee8160(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c0101387:	a1 a4 80 11 c0       	mov    0xc01180a4,%eax
c010138c:	3d 00 02 00 00       	cmp    $0x200,%eax
c0101391:	75 0a                	jne    c010139d <cons_intr+0x3b>
                cons.wpos = 0;
c0101393:	c7 05 a4 80 11 c0 00 	movl   $0x0,0xc01180a4
c010139a:	00 00 00 
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
    int c;
    while ((c = (*proc)()) != -1) {
c010139d:	8b 45 08             	mov    0x8(%ebp),%eax
c01013a0:	ff d0                	call   *%eax
c01013a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01013a5:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c01013a9:	75 bf                	jne    c010136a <cons_intr+0x8>
            if (cons.wpos == CONSBUFSIZE) {
                cons.wpos = 0;
            }
        }
    }
}
c01013ab:	c9                   	leave  
c01013ac:	c3                   	ret    

c01013ad <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c01013ad:	55                   	push   %ebp
c01013ae:	89 e5                	mov    %esp,%ebp
c01013b0:	83 ec 10             	sub    $0x10,%esp
c01013b3:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01013b9:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01013bd:	89 c2                	mov    %eax,%edx
c01013bf:	ec                   	in     (%dx),%al
c01013c0:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c01013c3:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c01013c7:	0f b6 c0             	movzbl %al,%eax
c01013ca:	83 e0 01             	and    $0x1,%eax
c01013cd:	85 c0                	test   %eax,%eax
c01013cf:	75 07                	jne    c01013d8 <serial_proc_data+0x2b>
        return -1;
c01013d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01013d6:	eb 2a                	jmp    c0101402 <serial_proc_data+0x55>
c01013d8:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01013de:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01013e2:	89 c2                	mov    %eax,%edx
c01013e4:	ec                   	in     (%dx),%al
c01013e5:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
c01013e8:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c01013ec:	0f b6 c0             	movzbl %al,%eax
c01013ef:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c01013f2:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c01013f6:	75 07                	jne    c01013ff <serial_proc_data+0x52>
        c = '\b';
c01013f8:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c01013ff:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0101402:	c9                   	leave  
c0101403:	c3                   	ret    

c0101404 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c0101404:	55                   	push   %ebp
c0101405:	89 e5                	mov    %esp,%ebp
c0101407:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
c010140a:	a1 88 7e 11 c0       	mov    0xc0117e88,%eax
c010140f:	85 c0                	test   %eax,%eax
c0101411:	74 0c                	je     c010141f <serial_intr+0x1b>
        cons_intr(serial_proc_data);
c0101413:	c7 04 24 ad 13 10 c0 	movl   $0xc01013ad,(%esp)
c010141a:	e8 43 ff ff ff       	call   c0101362 <cons_intr>
    }
}
c010141f:	c9                   	leave  
c0101420:	c3                   	ret    

c0101421 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c0101421:	55                   	push   %ebp
c0101422:	89 e5                	mov    %esp,%ebp
c0101424:	83 ec 38             	sub    $0x38,%esp
c0101427:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010142d:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c0101431:	89 c2                	mov    %eax,%edx
c0101433:	ec                   	in     (%dx),%al
c0101434:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
c0101437:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c010143b:	0f b6 c0             	movzbl %al,%eax
c010143e:	83 e0 01             	and    $0x1,%eax
c0101441:	85 c0                	test   %eax,%eax
c0101443:	75 0a                	jne    c010144f <kbd_proc_data+0x2e>
        return -1;
c0101445:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010144a:	e9 59 01 00 00       	jmp    c01015a8 <kbd_proc_data+0x187>
c010144f:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101455:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101459:	89 c2                	mov    %eax,%edx
c010145b:	ec                   	in     (%dx),%al
c010145c:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c010145f:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
c0101463:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c0101466:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c010146a:	75 17                	jne    c0101483 <kbd_proc_data+0x62>
        // E0 escape character
        shift |= E0ESC;
c010146c:	a1 a8 80 11 c0       	mov    0xc01180a8,%eax
c0101471:	83 c8 40             	or     $0x40,%eax
c0101474:	a3 a8 80 11 c0       	mov    %eax,0xc01180a8
        return 0;
c0101479:	b8 00 00 00 00       	mov    $0x0,%eax
c010147e:	e9 25 01 00 00       	jmp    c01015a8 <kbd_proc_data+0x187>
    } else if (data & 0x80) {
c0101483:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101487:	84 c0                	test   %al,%al
c0101489:	79 47                	jns    c01014d2 <kbd_proc_data+0xb1>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c010148b:	a1 a8 80 11 c0       	mov    0xc01180a8,%eax
c0101490:	83 e0 40             	and    $0x40,%eax
c0101493:	85 c0                	test   %eax,%eax
c0101495:	75 09                	jne    c01014a0 <kbd_proc_data+0x7f>
c0101497:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010149b:	83 e0 7f             	and    $0x7f,%eax
c010149e:	eb 04                	jmp    c01014a4 <kbd_proc_data+0x83>
c01014a0:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014a4:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c01014a7:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014ab:	0f b6 80 60 70 11 c0 	movzbl -0x3fee8fa0(%eax),%eax
c01014b2:	83 c8 40             	or     $0x40,%eax
c01014b5:	0f b6 c0             	movzbl %al,%eax
c01014b8:	f7 d0                	not    %eax
c01014ba:	89 c2                	mov    %eax,%edx
c01014bc:	a1 a8 80 11 c0       	mov    0xc01180a8,%eax
c01014c1:	21 d0                	and    %edx,%eax
c01014c3:	a3 a8 80 11 c0       	mov    %eax,0xc01180a8
        return 0;
c01014c8:	b8 00 00 00 00       	mov    $0x0,%eax
c01014cd:	e9 d6 00 00 00       	jmp    c01015a8 <kbd_proc_data+0x187>
    } else if (shift & E0ESC) {
c01014d2:	a1 a8 80 11 c0       	mov    0xc01180a8,%eax
c01014d7:	83 e0 40             	and    $0x40,%eax
c01014da:	85 c0                	test   %eax,%eax
c01014dc:	74 11                	je     c01014ef <kbd_proc_data+0xce>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c01014de:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c01014e2:	a1 a8 80 11 c0       	mov    0xc01180a8,%eax
c01014e7:	83 e0 bf             	and    $0xffffffbf,%eax
c01014ea:	a3 a8 80 11 c0       	mov    %eax,0xc01180a8
    }

    shift |= shiftcode[data];
c01014ef:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014f3:	0f b6 80 60 70 11 c0 	movzbl -0x3fee8fa0(%eax),%eax
c01014fa:	0f b6 d0             	movzbl %al,%edx
c01014fd:	a1 a8 80 11 c0       	mov    0xc01180a8,%eax
c0101502:	09 d0                	or     %edx,%eax
c0101504:	a3 a8 80 11 c0       	mov    %eax,0xc01180a8
    shift ^= togglecode[data];
c0101509:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010150d:	0f b6 80 60 71 11 c0 	movzbl -0x3fee8ea0(%eax),%eax
c0101514:	0f b6 d0             	movzbl %al,%edx
c0101517:	a1 a8 80 11 c0       	mov    0xc01180a8,%eax
c010151c:	31 d0                	xor    %edx,%eax
c010151e:	a3 a8 80 11 c0       	mov    %eax,0xc01180a8

    c = charcode[shift & (CTL | SHIFT)][data];
c0101523:	a1 a8 80 11 c0       	mov    0xc01180a8,%eax
c0101528:	83 e0 03             	and    $0x3,%eax
c010152b:	8b 14 85 60 75 11 c0 	mov    -0x3fee8aa0(,%eax,4),%edx
c0101532:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101536:	01 d0                	add    %edx,%eax
c0101538:	0f b6 00             	movzbl (%eax),%eax
c010153b:	0f b6 c0             	movzbl %al,%eax
c010153e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c0101541:	a1 a8 80 11 c0       	mov    0xc01180a8,%eax
c0101546:	83 e0 08             	and    $0x8,%eax
c0101549:	85 c0                	test   %eax,%eax
c010154b:	74 22                	je     c010156f <kbd_proc_data+0x14e>
        if ('a' <= c && c <= 'z')
c010154d:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c0101551:	7e 0c                	jle    c010155f <kbd_proc_data+0x13e>
c0101553:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c0101557:	7f 06                	jg     c010155f <kbd_proc_data+0x13e>
            c += 'A' - 'a';
c0101559:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c010155d:	eb 10                	jmp    c010156f <kbd_proc_data+0x14e>
        else if ('A' <= c && c <= 'Z')
c010155f:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c0101563:	7e 0a                	jle    c010156f <kbd_proc_data+0x14e>
c0101565:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c0101569:	7f 04                	jg     c010156f <kbd_proc_data+0x14e>
            c += 'a' - 'A';
c010156b:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c010156f:	a1 a8 80 11 c0       	mov    0xc01180a8,%eax
c0101574:	f7 d0                	not    %eax
c0101576:	83 e0 06             	and    $0x6,%eax
c0101579:	85 c0                	test   %eax,%eax
c010157b:	75 28                	jne    c01015a5 <kbd_proc_data+0x184>
c010157d:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c0101584:	75 1f                	jne    c01015a5 <kbd_proc_data+0x184>
        cprintf("Rebooting!\n");
c0101586:	c7 04 24 fd 62 10 c0 	movl   $0xc01062fd,(%esp)
c010158d:	e8 b5 ed ff ff       	call   c0100347 <cprintf>
c0101592:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
c0101598:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010159c:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
c01015a0:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
c01015a4:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c01015a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01015a8:	c9                   	leave  
c01015a9:	c3                   	ret    

c01015aa <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c01015aa:	55                   	push   %ebp
c01015ab:	89 e5                	mov    %esp,%ebp
c01015ad:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
c01015b0:	c7 04 24 21 14 10 c0 	movl   $0xc0101421,(%esp)
c01015b7:	e8 a6 fd ff ff       	call   c0101362 <cons_intr>
}
c01015bc:	c9                   	leave  
c01015bd:	c3                   	ret    

c01015be <kbd_init>:

static void
kbd_init(void) {
c01015be:	55                   	push   %ebp
c01015bf:	89 e5                	mov    %esp,%ebp
c01015c1:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
c01015c4:	e8 e1 ff ff ff       	call   c01015aa <kbd_intr>
    pic_enable(IRQ_KBD);
c01015c9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01015d0:	e8 3d 01 00 00       	call   c0101712 <pic_enable>
}
c01015d5:	c9                   	leave  
c01015d6:	c3                   	ret    

c01015d7 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c01015d7:	55                   	push   %ebp
c01015d8:	89 e5                	mov    %esp,%ebp
c01015da:	83 ec 18             	sub    $0x18,%esp
    cga_init();
c01015dd:	e8 93 f8 ff ff       	call   c0100e75 <cga_init>
    serial_init();
c01015e2:	e8 74 f9 ff ff       	call   c0100f5b <serial_init>
    kbd_init();
c01015e7:	e8 d2 ff ff ff       	call   c01015be <kbd_init>
    if (!serial_exists) {
c01015ec:	a1 88 7e 11 c0       	mov    0xc0117e88,%eax
c01015f1:	85 c0                	test   %eax,%eax
c01015f3:	75 0c                	jne    c0101601 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
c01015f5:	c7 04 24 09 63 10 c0 	movl   $0xc0106309,(%esp)
c01015fc:	e8 46 ed ff ff       	call   c0100347 <cprintf>
    }
}
c0101601:	c9                   	leave  
c0101602:	c3                   	ret    

c0101603 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c0101603:	55                   	push   %ebp
c0101604:	89 e5                	mov    %esp,%ebp
c0101606:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0101609:	e8 e2 f7 ff ff       	call   c0100df0 <__intr_save>
c010160e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c0101611:	8b 45 08             	mov    0x8(%ebp),%eax
c0101614:	89 04 24             	mov    %eax,(%esp)
c0101617:	e8 9b fa ff ff       	call   c01010b7 <lpt_putc>
        cga_putc(c);
c010161c:	8b 45 08             	mov    0x8(%ebp),%eax
c010161f:	89 04 24             	mov    %eax,(%esp)
c0101622:	e8 cf fa ff ff       	call   c01010f6 <cga_putc>
        serial_putc(c);
c0101627:	8b 45 08             	mov    0x8(%ebp),%eax
c010162a:	89 04 24             	mov    %eax,(%esp)
c010162d:	e8 f1 fc ff ff       	call   c0101323 <serial_putc>
    }
    local_intr_restore(intr_flag);
c0101632:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101635:	89 04 24             	mov    %eax,(%esp)
c0101638:	e8 dd f7 ff ff       	call   c0100e1a <__intr_restore>
}
c010163d:	c9                   	leave  
c010163e:	c3                   	ret    

c010163f <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c010163f:	55                   	push   %ebp
c0101640:	89 e5                	mov    %esp,%ebp
c0101642:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
c0101645:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c010164c:	e8 9f f7 ff ff       	call   c0100df0 <__intr_save>
c0101651:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c0101654:	e8 ab fd ff ff       	call   c0101404 <serial_intr>
        kbd_intr();
c0101659:	e8 4c ff ff ff       	call   c01015aa <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c010165e:	8b 15 a0 80 11 c0    	mov    0xc01180a0,%edx
c0101664:	a1 a4 80 11 c0       	mov    0xc01180a4,%eax
c0101669:	39 c2                	cmp    %eax,%edx
c010166b:	74 31                	je     c010169e <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
c010166d:	a1 a0 80 11 c0       	mov    0xc01180a0,%eax
c0101672:	8d 50 01             	lea    0x1(%eax),%edx
c0101675:	89 15 a0 80 11 c0    	mov    %edx,0xc01180a0
c010167b:	0f b6 80 a0 7e 11 c0 	movzbl -0x3fee8160(%eax),%eax
c0101682:	0f b6 c0             	movzbl %al,%eax
c0101685:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c0101688:	a1 a0 80 11 c0       	mov    0xc01180a0,%eax
c010168d:	3d 00 02 00 00       	cmp    $0x200,%eax
c0101692:	75 0a                	jne    c010169e <cons_getc+0x5f>
                cons.rpos = 0;
c0101694:	c7 05 a0 80 11 c0 00 	movl   $0x0,0xc01180a0
c010169b:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c010169e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01016a1:	89 04 24             	mov    %eax,(%esp)
c01016a4:	e8 71 f7 ff ff       	call   c0100e1a <__intr_restore>
    return c;
c01016a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01016ac:	c9                   	leave  
c01016ad:	c3                   	ret    

c01016ae <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c01016ae:	55                   	push   %ebp
c01016af:	89 e5                	mov    %esp,%ebp
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
}

static inline void
sti(void) {
    asm volatile ("sti");
c01016b1:	fb                   	sti    
    sti();
}
c01016b2:	5d                   	pop    %ebp
c01016b3:	c3                   	ret    

c01016b4 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c01016b4:	55                   	push   %ebp
c01016b5:	89 e5                	mov    %esp,%ebp
}

static inline void
cli(void) {
    asm volatile ("cli" ::: "memory");
c01016b7:	fa                   	cli    
    cli();
}
c01016b8:	5d                   	pop    %ebp
c01016b9:	c3                   	ret    

c01016ba <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c01016ba:	55                   	push   %ebp
c01016bb:	89 e5                	mov    %esp,%ebp
c01016bd:	83 ec 14             	sub    $0x14,%esp
c01016c0:	8b 45 08             	mov    0x8(%ebp),%eax
c01016c3:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c01016c7:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c01016cb:	66 a3 70 75 11 c0    	mov    %ax,0xc0117570
    if (did_init) {
c01016d1:	a1 ac 80 11 c0       	mov    0xc01180ac,%eax
c01016d6:	85 c0                	test   %eax,%eax
c01016d8:	74 36                	je     c0101710 <pic_setmask+0x56>
        outb(IO_PIC1 + 1, mask);
c01016da:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c01016de:	0f b6 c0             	movzbl %al,%eax
c01016e1:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c01016e7:	88 45 fd             	mov    %al,-0x3(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01016ea:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c01016ee:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c01016f2:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
c01016f3:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c01016f7:	66 c1 e8 08          	shr    $0x8,%ax
c01016fb:	0f b6 c0             	movzbl %al,%eax
c01016fe:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
c0101704:	88 45 f9             	mov    %al,-0x7(%ebp)
c0101707:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c010170b:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c010170f:	ee                   	out    %al,(%dx)
    }
}
c0101710:	c9                   	leave  
c0101711:	c3                   	ret    

c0101712 <pic_enable>:

void
pic_enable(unsigned int irq) {
c0101712:	55                   	push   %ebp
c0101713:	89 e5                	mov    %esp,%ebp
c0101715:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
c0101718:	8b 45 08             	mov    0x8(%ebp),%eax
c010171b:	ba 01 00 00 00       	mov    $0x1,%edx
c0101720:	89 c1                	mov    %eax,%ecx
c0101722:	d3 e2                	shl    %cl,%edx
c0101724:	89 d0                	mov    %edx,%eax
c0101726:	f7 d0                	not    %eax
c0101728:	89 c2                	mov    %eax,%edx
c010172a:	0f b7 05 70 75 11 c0 	movzwl 0xc0117570,%eax
c0101731:	21 d0                	and    %edx,%eax
c0101733:	0f b7 c0             	movzwl %ax,%eax
c0101736:	89 04 24             	mov    %eax,(%esp)
c0101739:	e8 7c ff ff ff       	call   c01016ba <pic_setmask>
}
c010173e:	c9                   	leave  
c010173f:	c3                   	ret    

c0101740 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c0101740:	55                   	push   %ebp
c0101741:	89 e5                	mov    %esp,%ebp
c0101743:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
c0101746:	c7 05 ac 80 11 c0 01 	movl   $0x1,0xc01180ac
c010174d:	00 00 00 
c0101750:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c0101756:	c6 45 fd ff          	movb   $0xff,-0x3(%ebp)
c010175a:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c010175e:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0101762:	ee                   	out    %al,(%dx)
c0101763:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
c0101769:	c6 45 f9 ff          	movb   $0xff,-0x7(%ebp)
c010176d:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101771:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101775:	ee                   	out    %al,(%dx)
c0101776:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
c010177c:	c6 45 f5 11          	movb   $0x11,-0xb(%ebp)
c0101780:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0101784:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101788:	ee                   	out    %al,(%dx)
c0101789:	66 c7 45 f2 21 00    	movw   $0x21,-0xe(%ebp)
c010178f:	c6 45 f1 20          	movb   $0x20,-0xf(%ebp)
c0101793:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101797:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010179b:	ee                   	out    %al,(%dx)
c010179c:	66 c7 45 ee 21 00    	movw   $0x21,-0x12(%ebp)
c01017a2:	c6 45 ed 04          	movb   $0x4,-0x13(%ebp)
c01017a6:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01017aa:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01017ae:	ee                   	out    %al,(%dx)
c01017af:	66 c7 45 ea 21 00    	movw   $0x21,-0x16(%ebp)
c01017b5:	c6 45 e9 03          	movb   $0x3,-0x17(%ebp)
c01017b9:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01017bd:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01017c1:	ee                   	out    %al,(%dx)
c01017c2:	66 c7 45 e6 a0 00    	movw   $0xa0,-0x1a(%ebp)
c01017c8:	c6 45 e5 11          	movb   $0x11,-0x1b(%ebp)
c01017cc:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01017d0:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01017d4:	ee                   	out    %al,(%dx)
c01017d5:	66 c7 45 e2 a1 00    	movw   $0xa1,-0x1e(%ebp)
c01017db:	c6 45 e1 28          	movb   $0x28,-0x1f(%ebp)
c01017df:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c01017e3:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c01017e7:	ee                   	out    %al,(%dx)
c01017e8:	66 c7 45 de a1 00    	movw   $0xa1,-0x22(%ebp)
c01017ee:	c6 45 dd 02          	movb   $0x2,-0x23(%ebp)
c01017f2:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c01017f6:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c01017fa:	ee                   	out    %al,(%dx)
c01017fb:	66 c7 45 da a1 00    	movw   $0xa1,-0x26(%ebp)
c0101801:	c6 45 d9 03          	movb   $0x3,-0x27(%ebp)
c0101805:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101809:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c010180d:	ee                   	out    %al,(%dx)
c010180e:	66 c7 45 d6 20 00    	movw   $0x20,-0x2a(%ebp)
c0101814:	c6 45 d5 68          	movb   $0x68,-0x2b(%ebp)
c0101818:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c010181c:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0101820:	ee                   	out    %al,(%dx)
c0101821:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
c0101827:	c6 45 d1 0a          	movb   $0xa,-0x2f(%ebp)
c010182b:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c010182f:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c0101833:	ee                   	out    %al,(%dx)
c0101834:	66 c7 45 ce a0 00    	movw   $0xa0,-0x32(%ebp)
c010183a:	c6 45 cd 68          	movb   $0x68,-0x33(%ebp)
c010183e:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c0101842:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c0101846:	ee                   	out    %al,(%dx)
c0101847:	66 c7 45 ca a0 00    	movw   $0xa0,-0x36(%ebp)
c010184d:	c6 45 c9 0a          	movb   $0xa,-0x37(%ebp)
c0101851:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c0101855:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c0101859:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c010185a:	0f b7 05 70 75 11 c0 	movzwl 0xc0117570,%eax
c0101861:	66 83 f8 ff          	cmp    $0xffff,%ax
c0101865:	74 12                	je     c0101879 <pic_init+0x139>
        pic_setmask(irq_mask);
c0101867:	0f b7 05 70 75 11 c0 	movzwl 0xc0117570,%eax
c010186e:	0f b7 c0             	movzwl %ax,%eax
c0101871:	89 04 24             	mov    %eax,(%esp)
c0101874:	e8 41 fe ff ff       	call   c01016ba <pic_setmask>
    }
}
c0101879:	c9                   	leave  
c010187a:	c3                   	ret    

c010187b <print_ticks>:
#include <console.h>
#include <kdebug.h>
#include <string.h>
#define TICK_NUM 100

static void print_ticks() {
c010187b:	55                   	push   %ebp
c010187c:	89 e5                	mov    %esp,%ebp
c010187e:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
c0101881:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c0101888:	00 
c0101889:	c7 04 24 40 63 10 c0 	movl   $0xc0106340,(%esp)
c0101890:	e8 b2 ea ff ff       	call   c0100347 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}
c0101895:	c9                   	leave  
c0101896:	c3                   	ret    

c0101897 <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c0101897:	55                   	push   %ebp
c0101898:	89 e5                	mov    %esp,%ebp
c010189a:	83 ec 10             	sub    $0x10,%esp
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
c010189d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01018a4:	e9 c3 00 00 00       	jmp    c010196c <idt_init+0xd5>
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
c01018a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018ac:	8b 04 85 00 76 11 c0 	mov    -0x3fee8a00(,%eax,4),%eax
c01018b3:	89 c2                	mov    %eax,%edx
c01018b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018b8:	66 89 14 c5 c0 80 11 	mov    %dx,-0x3fee7f40(,%eax,8)
c01018bf:	c0 
c01018c0:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018c3:	66 c7 04 c5 c2 80 11 	movw   $0x8,-0x3fee7f3e(,%eax,8)
c01018ca:	c0 08 00 
c01018cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018d0:	0f b6 14 c5 c4 80 11 	movzbl -0x3fee7f3c(,%eax,8),%edx
c01018d7:	c0 
c01018d8:	83 e2 e0             	and    $0xffffffe0,%edx
c01018db:	88 14 c5 c4 80 11 c0 	mov    %dl,-0x3fee7f3c(,%eax,8)
c01018e2:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018e5:	0f b6 14 c5 c4 80 11 	movzbl -0x3fee7f3c(,%eax,8),%edx
c01018ec:	c0 
c01018ed:	83 e2 1f             	and    $0x1f,%edx
c01018f0:	88 14 c5 c4 80 11 c0 	mov    %dl,-0x3fee7f3c(,%eax,8)
c01018f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018fa:	0f b6 14 c5 c5 80 11 	movzbl -0x3fee7f3b(,%eax,8),%edx
c0101901:	c0 
c0101902:	83 e2 f0             	and    $0xfffffff0,%edx
c0101905:	83 ca 0e             	or     $0xe,%edx
c0101908:	88 14 c5 c5 80 11 c0 	mov    %dl,-0x3fee7f3b(,%eax,8)
c010190f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101912:	0f b6 14 c5 c5 80 11 	movzbl -0x3fee7f3b(,%eax,8),%edx
c0101919:	c0 
c010191a:	83 e2 ef             	and    $0xffffffef,%edx
c010191d:	88 14 c5 c5 80 11 c0 	mov    %dl,-0x3fee7f3b(,%eax,8)
c0101924:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101927:	0f b6 14 c5 c5 80 11 	movzbl -0x3fee7f3b(,%eax,8),%edx
c010192e:	c0 
c010192f:	83 e2 9f             	and    $0xffffff9f,%edx
c0101932:	88 14 c5 c5 80 11 c0 	mov    %dl,-0x3fee7f3b(,%eax,8)
c0101939:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010193c:	0f b6 14 c5 c5 80 11 	movzbl -0x3fee7f3b(,%eax,8),%edx
c0101943:	c0 
c0101944:	83 ca 80             	or     $0xffffff80,%edx
c0101947:	88 14 c5 c5 80 11 c0 	mov    %dl,-0x3fee7f3b(,%eax,8)
c010194e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101951:	8b 04 85 00 76 11 c0 	mov    -0x3fee8a00(,%eax,4),%eax
c0101958:	c1 e8 10             	shr    $0x10,%eax
c010195b:	89 c2                	mov    %eax,%edx
c010195d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101960:	66 89 14 c5 c6 80 11 	mov    %dx,-0x3fee7f3a(,%eax,8)
c0101967:	c0 
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
c0101968:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c010196c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010196f:	3d ff 00 00 00       	cmp    $0xff,%eax
c0101974:	0f 86 2f ff ff ff    	jbe    c01018a9 <idt_init+0x12>
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
    }
	// set for switch from user to kernel
    SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT, __vectors[T_SWITCH_TOK], DPL_USER);
c010197a:	a1 e4 77 11 c0       	mov    0xc01177e4,%eax
c010197f:	66 a3 88 84 11 c0    	mov    %ax,0xc0118488
c0101985:	66 c7 05 8a 84 11 c0 	movw   $0x8,0xc011848a
c010198c:	08 00 
c010198e:	0f b6 05 8c 84 11 c0 	movzbl 0xc011848c,%eax
c0101995:	83 e0 e0             	and    $0xffffffe0,%eax
c0101998:	a2 8c 84 11 c0       	mov    %al,0xc011848c
c010199d:	0f b6 05 8c 84 11 c0 	movzbl 0xc011848c,%eax
c01019a4:	83 e0 1f             	and    $0x1f,%eax
c01019a7:	a2 8c 84 11 c0       	mov    %al,0xc011848c
c01019ac:	0f b6 05 8d 84 11 c0 	movzbl 0xc011848d,%eax
c01019b3:	83 e0 f0             	and    $0xfffffff0,%eax
c01019b6:	83 c8 0e             	or     $0xe,%eax
c01019b9:	a2 8d 84 11 c0       	mov    %al,0xc011848d
c01019be:	0f b6 05 8d 84 11 c0 	movzbl 0xc011848d,%eax
c01019c5:	83 e0 ef             	and    $0xffffffef,%eax
c01019c8:	a2 8d 84 11 c0       	mov    %al,0xc011848d
c01019cd:	0f b6 05 8d 84 11 c0 	movzbl 0xc011848d,%eax
c01019d4:	83 c8 60             	or     $0x60,%eax
c01019d7:	a2 8d 84 11 c0       	mov    %al,0xc011848d
c01019dc:	0f b6 05 8d 84 11 c0 	movzbl 0xc011848d,%eax
c01019e3:	83 c8 80             	or     $0xffffff80,%eax
c01019e6:	a2 8d 84 11 c0       	mov    %al,0xc011848d
c01019eb:	a1 e4 77 11 c0       	mov    0xc01177e4,%eax
c01019f0:	c1 e8 10             	shr    $0x10,%eax
c01019f3:	66 a3 8e 84 11 c0    	mov    %ax,0xc011848e
c01019f9:	c7 45 f8 80 75 11 c0 	movl   $0xc0117580,-0x8(%ebp)
    }
}

static inline void
lidt(struct pseudodesc *pd) {
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c0101a00:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0101a03:	0f 01 18             	lidtl  (%eax)
	// load the IDT
    lidt(&idt_pd);
}
c0101a06:	c9                   	leave  
c0101a07:	c3                   	ret    

c0101a08 <trapname>:

static const char *
trapname(int trapno) {
c0101a08:	55                   	push   %ebp
c0101a09:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c0101a0b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a0e:	83 f8 13             	cmp    $0x13,%eax
c0101a11:	77 0c                	ja     c0101a1f <trapname+0x17>
        return excnames[trapno];
c0101a13:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a16:	8b 04 85 a0 66 10 c0 	mov    -0x3fef9960(,%eax,4),%eax
c0101a1d:	eb 18                	jmp    c0101a37 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c0101a1f:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c0101a23:	7e 0d                	jle    c0101a32 <trapname+0x2a>
c0101a25:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c0101a29:	7f 07                	jg     c0101a32 <trapname+0x2a>
        return "Hardware Interrupt";
c0101a2b:	b8 4a 63 10 c0       	mov    $0xc010634a,%eax
c0101a30:	eb 05                	jmp    c0101a37 <trapname+0x2f>
    }
    return "(unknown trap)";
c0101a32:	b8 5d 63 10 c0       	mov    $0xc010635d,%eax
}
c0101a37:	5d                   	pop    %ebp
c0101a38:	c3                   	ret    

c0101a39 <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c0101a39:	55                   	push   %ebp
c0101a3a:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c0101a3c:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a3f:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101a43:	66 83 f8 08          	cmp    $0x8,%ax
c0101a47:	0f 94 c0             	sete   %al
c0101a4a:	0f b6 c0             	movzbl %al,%eax
}
c0101a4d:	5d                   	pop    %ebp
c0101a4e:	c3                   	ret    

c0101a4f <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c0101a4f:	55                   	push   %ebp
c0101a50:	89 e5                	mov    %esp,%ebp
c0101a52:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
c0101a55:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a58:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a5c:	c7 04 24 9e 63 10 c0 	movl   $0xc010639e,(%esp)
c0101a63:	e8 df e8 ff ff       	call   c0100347 <cprintf>
    print_regs(&tf->tf_regs);
c0101a68:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a6b:	89 04 24             	mov    %eax,(%esp)
c0101a6e:	e8 a1 01 00 00       	call   c0101c14 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c0101a73:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a76:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c0101a7a:	0f b7 c0             	movzwl %ax,%eax
c0101a7d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a81:	c7 04 24 af 63 10 c0 	movl   $0xc01063af,(%esp)
c0101a88:	e8 ba e8 ff ff       	call   c0100347 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
c0101a8d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a90:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c0101a94:	0f b7 c0             	movzwl %ax,%eax
c0101a97:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a9b:	c7 04 24 c2 63 10 c0 	movl   $0xc01063c2,(%esp)
c0101aa2:	e8 a0 e8 ff ff       	call   c0100347 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c0101aa7:	8b 45 08             	mov    0x8(%ebp),%eax
c0101aaa:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c0101aae:	0f b7 c0             	movzwl %ax,%eax
c0101ab1:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ab5:	c7 04 24 d5 63 10 c0 	movl   $0xc01063d5,(%esp)
c0101abc:	e8 86 e8 ff ff       	call   c0100347 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c0101ac1:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ac4:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c0101ac8:	0f b7 c0             	movzwl %ax,%eax
c0101acb:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101acf:	c7 04 24 e8 63 10 c0 	movl   $0xc01063e8,(%esp)
c0101ad6:	e8 6c e8 ff ff       	call   c0100347 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c0101adb:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ade:	8b 40 30             	mov    0x30(%eax),%eax
c0101ae1:	89 04 24             	mov    %eax,(%esp)
c0101ae4:	e8 1f ff ff ff       	call   c0101a08 <trapname>
c0101ae9:	8b 55 08             	mov    0x8(%ebp),%edx
c0101aec:	8b 52 30             	mov    0x30(%edx),%edx
c0101aef:	89 44 24 08          	mov    %eax,0x8(%esp)
c0101af3:	89 54 24 04          	mov    %edx,0x4(%esp)
c0101af7:	c7 04 24 fb 63 10 c0 	movl   $0xc01063fb,(%esp)
c0101afe:	e8 44 e8 ff ff       	call   c0100347 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
c0101b03:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b06:	8b 40 34             	mov    0x34(%eax),%eax
c0101b09:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b0d:	c7 04 24 0d 64 10 c0 	movl   $0xc010640d,(%esp)
c0101b14:	e8 2e e8 ff ff       	call   c0100347 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c0101b19:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b1c:	8b 40 38             	mov    0x38(%eax),%eax
c0101b1f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b23:	c7 04 24 1c 64 10 c0 	movl   $0xc010641c,(%esp)
c0101b2a:	e8 18 e8 ff ff       	call   c0100347 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c0101b2f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b32:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101b36:	0f b7 c0             	movzwl %ax,%eax
c0101b39:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b3d:	c7 04 24 2b 64 10 c0 	movl   $0xc010642b,(%esp)
c0101b44:	e8 fe e7 ff ff       	call   c0100347 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c0101b49:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b4c:	8b 40 40             	mov    0x40(%eax),%eax
c0101b4f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b53:	c7 04 24 3e 64 10 c0 	movl   $0xc010643e,(%esp)
c0101b5a:	e8 e8 e7 ff ff       	call   c0100347 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0101b5f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101b66:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c0101b6d:	eb 3e                	jmp    c0101bad <print_trapframe+0x15e>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c0101b6f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b72:	8b 50 40             	mov    0x40(%eax),%edx
c0101b75:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101b78:	21 d0                	and    %edx,%eax
c0101b7a:	85 c0                	test   %eax,%eax
c0101b7c:	74 28                	je     c0101ba6 <print_trapframe+0x157>
c0101b7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101b81:	8b 04 85 a0 75 11 c0 	mov    -0x3fee8a60(,%eax,4),%eax
c0101b88:	85 c0                	test   %eax,%eax
c0101b8a:	74 1a                	je     c0101ba6 <print_trapframe+0x157>
            cprintf("%s,", IA32flags[i]);
c0101b8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101b8f:	8b 04 85 a0 75 11 c0 	mov    -0x3fee8a60(,%eax,4),%eax
c0101b96:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b9a:	c7 04 24 4d 64 10 c0 	movl   $0xc010644d,(%esp)
c0101ba1:	e8 a1 e7 ff ff       	call   c0100347 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
    cprintf("  flag 0x%08x ", tf->tf_eflags);

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0101ba6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101baa:	d1 65 f0             	shll   -0x10(%ebp)
c0101bad:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101bb0:	83 f8 17             	cmp    $0x17,%eax
c0101bb3:	76 ba                	jbe    c0101b6f <print_trapframe+0x120>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
            cprintf("%s,", IA32flags[i]);
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c0101bb5:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bb8:	8b 40 40             	mov    0x40(%eax),%eax
c0101bbb:	25 00 30 00 00       	and    $0x3000,%eax
c0101bc0:	c1 e8 0c             	shr    $0xc,%eax
c0101bc3:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bc7:	c7 04 24 51 64 10 c0 	movl   $0xc0106451,(%esp)
c0101bce:	e8 74 e7 ff ff       	call   c0100347 <cprintf>

    if (!trap_in_kernel(tf)) {
c0101bd3:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bd6:	89 04 24             	mov    %eax,(%esp)
c0101bd9:	e8 5b fe ff ff       	call   c0101a39 <trap_in_kernel>
c0101bde:	85 c0                	test   %eax,%eax
c0101be0:	75 30                	jne    c0101c12 <print_trapframe+0x1c3>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c0101be2:	8b 45 08             	mov    0x8(%ebp),%eax
c0101be5:	8b 40 44             	mov    0x44(%eax),%eax
c0101be8:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bec:	c7 04 24 5a 64 10 c0 	movl   $0xc010645a,(%esp)
c0101bf3:	e8 4f e7 ff ff       	call   c0100347 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c0101bf8:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bfb:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c0101bff:	0f b7 c0             	movzwl %ax,%eax
c0101c02:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c06:	c7 04 24 69 64 10 c0 	movl   $0xc0106469,(%esp)
c0101c0d:	e8 35 e7 ff ff       	call   c0100347 <cprintf>
    }
}
c0101c12:	c9                   	leave  
c0101c13:	c3                   	ret    

c0101c14 <print_regs>:

void
print_regs(struct pushregs *regs) {
c0101c14:	55                   	push   %ebp
c0101c15:	89 e5                	mov    %esp,%ebp
c0101c17:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c0101c1a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c1d:	8b 00                	mov    (%eax),%eax
c0101c1f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c23:	c7 04 24 7c 64 10 c0 	movl   $0xc010647c,(%esp)
c0101c2a:	e8 18 e7 ff ff       	call   c0100347 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c0101c2f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c32:	8b 40 04             	mov    0x4(%eax),%eax
c0101c35:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c39:	c7 04 24 8b 64 10 c0 	movl   $0xc010648b,(%esp)
c0101c40:	e8 02 e7 ff ff       	call   c0100347 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c0101c45:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c48:	8b 40 08             	mov    0x8(%eax),%eax
c0101c4b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c4f:	c7 04 24 9a 64 10 c0 	movl   $0xc010649a,(%esp)
c0101c56:	e8 ec e6 ff ff       	call   c0100347 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c0101c5b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c5e:	8b 40 0c             	mov    0xc(%eax),%eax
c0101c61:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c65:	c7 04 24 a9 64 10 c0 	movl   $0xc01064a9,(%esp)
c0101c6c:	e8 d6 e6 ff ff       	call   c0100347 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c0101c71:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c74:	8b 40 10             	mov    0x10(%eax),%eax
c0101c77:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c7b:	c7 04 24 b8 64 10 c0 	movl   $0xc01064b8,(%esp)
c0101c82:	e8 c0 e6 ff ff       	call   c0100347 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c0101c87:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c8a:	8b 40 14             	mov    0x14(%eax),%eax
c0101c8d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c91:	c7 04 24 c7 64 10 c0 	movl   $0xc01064c7,(%esp)
c0101c98:	e8 aa e6 ff ff       	call   c0100347 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c0101c9d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ca0:	8b 40 18             	mov    0x18(%eax),%eax
c0101ca3:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ca7:	c7 04 24 d6 64 10 c0 	movl   $0xc01064d6,(%esp)
c0101cae:	e8 94 e6 ff ff       	call   c0100347 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c0101cb3:	8b 45 08             	mov    0x8(%ebp),%eax
c0101cb6:	8b 40 1c             	mov    0x1c(%eax),%eax
c0101cb9:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101cbd:	c7 04 24 e5 64 10 c0 	movl   $0xc01064e5,(%esp)
c0101cc4:	e8 7e e6 ff ff       	call   c0100347 <cprintf>
}
c0101cc9:	c9                   	leave  
c0101cca:	c3                   	ret    

c0101ccb <trap_dispatch>:
/* temporary trapframe or pointer to trapframe */
struct trapframe switchk2u, *switchu2k;

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
c0101ccb:	55                   	push   %ebp
c0101ccc:	89 e5                	mov    %esp,%ebp
c0101cce:	57                   	push   %edi
c0101ccf:	56                   	push   %esi
c0101cd0:	53                   	push   %ebx
c0101cd1:	83 ec 2c             	sub    $0x2c,%esp
    char c;

    switch (tf->tf_trapno) {
c0101cd4:	8b 45 08             	mov    0x8(%ebp),%eax
c0101cd7:	8b 40 30             	mov    0x30(%eax),%eax
c0101cda:	83 f8 2f             	cmp    $0x2f,%eax
c0101cdd:	77 21                	ja     c0101d00 <trap_dispatch+0x35>
c0101cdf:	83 f8 2e             	cmp    $0x2e,%eax
c0101ce2:	0f 83 89 01 00 00    	jae    c0101e71 <trap_dispatch+0x1a6>
c0101ce8:	83 f8 21             	cmp    $0x21,%eax
c0101ceb:	0f 84 8a 00 00 00    	je     c0101d7b <trap_dispatch+0xb0>
c0101cf1:	83 f8 24             	cmp    $0x24,%eax
c0101cf4:	74 5c                	je     c0101d52 <trap_dispatch+0x87>
c0101cf6:	83 f8 20             	cmp    $0x20,%eax
c0101cf9:	74 1c                	je     c0101d17 <trap_dispatch+0x4c>
c0101cfb:	e9 39 01 00 00       	jmp    c0101e39 <trap_dispatch+0x16e>
c0101d00:	83 f8 78             	cmp    $0x78,%eax
c0101d03:	0f 84 9b 00 00 00    	je     c0101da4 <trap_dispatch+0xd9>
c0101d09:	83 f8 79             	cmp    $0x79,%eax
c0101d0c:	0f 84 0b 01 00 00    	je     c0101e1d <trap_dispatch+0x152>
c0101d12:	e9 22 01 00 00       	jmp    c0101e39 <trap_dispatch+0x16e>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks ++;
c0101d17:	a1 4c 89 11 c0       	mov    0xc011894c,%eax
c0101d1c:	83 c0 01             	add    $0x1,%eax
c0101d1f:	a3 4c 89 11 c0       	mov    %eax,0xc011894c
        if (ticks % TICK_NUM == 0) {
c0101d24:	8b 0d 4c 89 11 c0    	mov    0xc011894c,%ecx
c0101d2a:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
c0101d2f:	89 c8                	mov    %ecx,%eax
c0101d31:	f7 e2                	mul    %edx
c0101d33:	89 d0                	mov    %edx,%eax
c0101d35:	c1 e8 05             	shr    $0x5,%eax
c0101d38:	6b c0 64             	imul   $0x64,%eax,%eax
c0101d3b:	29 c1                	sub    %eax,%ecx
c0101d3d:	89 c8                	mov    %ecx,%eax
c0101d3f:	85 c0                	test   %eax,%eax
c0101d41:	75 0a                	jne    c0101d4d <trap_dispatch+0x82>
            print_ticks();
c0101d43:	e8 33 fb ff ff       	call   c010187b <print_ticks>
        }
        break;
c0101d48:	e9 25 01 00 00       	jmp    c0101e72 <trap_dispatch+0x1a7>
c0101d4d:	e9 20 01 00 00       	jmp    c0101e72 <trap_dispatch+0x1a7>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c0101d52:	e8 e8 f8 ff ff       	call   c010163f <cons_getc>
c0101d57:	88 45 e7             	mov    %al,-0x19(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c0101d5a:	0f be 55 e7          	movsbl -0x19(%ebp),%edx
c0101d5e:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
c0101d62:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101d66:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d6a:	c7 04 24 f4 64 10 c0 	movl   $0xc01064f4,(%esp)
c0101d71:	e8 d1 e5 ff ff       	call   c0100347 <cprintf>
        break;
c0101d76:	e9 f7 00 00 00       	jmp    c0101e72 <trap_dispatch+0x1a7>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c0101d7b:	e8 bf f8 ff ff       	call   c010163f <cons_getc>
c0101d80:	88 45 e7             	mov    %al,-0x19(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c0101d83:	0f be 55 e7          	movsbl -0x19(%ebp),%edx
c0101d87:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
c0101d8b:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101d8f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d93:	c7 04 24 06 65 10 c0 	movl   $0xc0106506,(%esp)
c0101d9a:	e8 a8 e5 ff ff       	call   c0100347 <cprintf>
        break;
c0101d9f:	e9 ce 00 00 00       	jmp    c0101e72 <trap_dispatch+0x1a7>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
        if (tf->tf_cs != USER_CS) {
c0101da4:	8b 45 08             	mov    0x8(%ebp),%eax
c0101da7:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101dab:	66 83 f8 1b          	cmp    $0x1b,%ax
c0101daf:	74 6a                	je     c0101e1b <trap_dispatch+0x150>
            switchk2u = *tf;
c0101db1:	8b 45 08             	mov    0x8(%ebp),%eax
c0101db4:	ba 60 89 11 c0       	mov    $0xc0118960,%edx
c0101db9:	89 c3                	mov    %eax,%ebx
c0101dbb:	b8 13 00 00 00       	mov    $0x13,%eax
c0101dc0:	89 d7                	mov    %edx,%edi
c0101dc2:	89 de                	mov    %ebx,%esi
c0101dc4:	89 c1                	mov    %eax,%ecx
c0101dc6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
            switchk2u.tf_cs = USER_CS;
c0101dc8:	66 c7 05 9c 89 11 c0 	movw   $0x1b,0xc011899c
c0101dcf:	1b 00 
            switchk2u.tf_ds = switchk2u.tf_es = switchk2u.tf_ss = USER_DS;
c0101dd1:	66 c7 05 a8 89 11 c0 	movw   $0x23,0xc01189a8
c0101dd8:	23 00 
c0101dda:	0f b7 05 a8 89 11 c0 	movzwl 0xc01189a8,%eax
c0101de1:	66 a3 88 89 11 c0    	mov    %ax,0xc0118988
c0101de7:	0f b7 05 88 89 11 c0 	movzwl 0xc0118988,%eax
c0101dee:	66 a3 8c 89 11 c0    	mov    %ax,0xc011898c
            switchk2u.tf_esp = (uint32_t)tf + sizeof(struct trapframe) - 8;
c0101df4:	8b 45 08             	mov    0x8(%ebp),%eax
c0101df7:	83 c0 44             	add    $0x44,%eax
c0101dfa:	a3 a4 89 11 c0       	mov    %eax,0xc01189a4
		
            // set eflags, make sure ucore can use io under user mode.
            // if CPL > IOPL, then cpu will generate a general protection.
            switchk2u.tf_eflags |= FL_IOPL_MASK;
c0101dff:	a1 a0 89 11 c0       	mov    0xc01189a0,%eax
c0101e04:	80 cc 30             	or     $0x30,%ah
c0101e07:	a3 a0 89 11 c0       	mov    %eax,0xc01189a0
		
            // set temporary stack
            // then iret will jump to the right stack
            *((uint32_t *)tf - 1) = (uint32_t)&switchk2u;
c0101e0c:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e0f:	8d 50 fc             	lea    -0x4(%eax),%edx
c0101e12:	b8 60 89 11 c0       	mov    $0xc0118960,%eax
c0101e17:	89 02                	mov    %eax,(%edx)
        }
        break;
c0101e19:	eb 57                	jmp    c0101e72 <trap_dispatch+0x1a7>
c0101e1b:	eb 55                	jmp    c0101e72 <trap_dispatch+0x1a7>
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
c0101e1d:	c7 44 24 08 15 65 10 	movl   $0xc0106515,0x8(%esp)
c0101e24:	c0 
c0101e25:	c7 44 24 04 c1 00 00 	movl   $0xc1,0x4(%esp)
c0101e2c:	00 
c0101e2d:	c7 04 24 25 65 10 c0 	movl   $0xc0106525,(%esp)
c0101e34:	e8 98 ee ff ff       	call   c0100cd1 <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
c0101e39:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e3c:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101e40:	0f b7 c0             	movzwl %ax,%eax
c0101e43:	83 e0 03             	and    $0x3,%eax
c0101e46:	85 c0                	test   %eax,%eax
c0101e48:	75 28                	jne    c0101e72 <trap_dispatch+0x1a7>
            print_trapframe(tf);
c0101e4a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e4d:	89 04 24             	mov    %eax,(%esp)
c0101e50:	e8 fa fb ff ff       	call   c0101a4f <print_trapframe>
            panic("unexpected trap in kernel.\n");
c0101e55:	c7 44 24 08 36 65 10 	movl   $0xc0106536,0x8(%esp)
c0101e5c:	c0 
c0101e5d:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
c0101e64:	00 
c0101e65:	c7 04 24 25 65 10 c0 	movl   $0xc0106525,(%esp)
c0101e6c:	e8 60 ee ff ff       	call   c0100cd1 <__panic>
        panic("T_SWITCH_** ??\n");
        break;
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
c0101e71:	90                   	nop
        if ((tf->tf_cs & 3) == 0) {
            print_trapframe(tf);
            panic("unexpected trap in kernel.\n");
        }
    }
}
c0101e72:	83 c4 2c             	add    $0x2c,%esp
c0101e75:	5b                   	pop    %ebx
c0101e76:	5e                   	pop    %esi
c0101e77:	5f                   	pop    %edi
c0101e78:	5d                   	pop    %ebp
c0101e79:	c3                   	ret    

c0101e7a <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c0101e7a:	55                   	push   %ebp
c0101e7b:	89 e5                	mov    %esp,%ebp
c0101e7d:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
c0101e80:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e83:	89 04 24             	mov    %eax,(%esp)
c0101e86:	e8 40 fe ff ff       	call   c0101ccb <trap_dispatch>
}
c0101e8b:	c9                   	leave  
c0101e8c:	c3                   	ret    

c0101e8d <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c0101e8d:	1e                   	push   %ds
    pushl %es
c0101e8e:	06                   	push   %es
    pushl %fs
c0101e8f:	0f a0                	push   %fs
    pushl %gs
c0101e91:	0f a8                	push   %gs
    pushal
c0101e93:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c0101e94:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c0101e99:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c0101e9b:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c0101e9d:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c0101e9e:	e8 d7 ff ff ff       	call   c0101e7a <trap>

    # pop the pushed stack pointer
    popl %esp
c0101ea3:	5c                   	pop    %esp

c0101ea4 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c0101ea4:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c0101ea5:	0f a9                	pop    %gs
    popl %fs
c0101ea7:	0f a1                	pop    %fs
    popl %es
c0101ea9:	07                   	pop    %es
    popl %ds
c0101eaa:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c0101eab:	83 c4 08             	add    $0x8,%esp
    iret
c0101eae:	cf                   	iret   

c0101eaf <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c0101eaf:	6a 00                	push   $0x0
  pushl $0
c0101eb1:	6a 00                	push   $0x0
  jmp __alltraps
c0101eb3:	e9 d5 ff ff ff       	jmp    c0101e8d <__alltraps>

c0101eb8 <vector1>:
.globl vector1
vector1:
  pushl $0
c0101eb8:	6a 00                	push   $0x0
  pushl $1
c0101eba:	6a 01                	push   $0x1
  jmp __alltraps
c0101ebc:	e9 cc ff ff ff       	jmp    c0101e8d <__alltraps>

c0101ec1 <vector2>:
.globl vector2
vector2:
  pushl $0
c0101ec1:	6a 00                	push   $0x0
  pushl $2
c0101ec3:	6a 02                	push   $0x2
  jmp __alltraps
c0101ec5:	e9 c3 ff ff ff       	jmp    c0101e8d <__alltraps>

c0101eca <vector3>:
.globl vector3
vector3:
  pushl $0
c0101eca:	6a 00                	push   $0x0
  pushl $3
c0101ecc:	6a 03                	push   $0x3
  jmp __alltraps
c0101ece:	e9 ba ff ff ff       	jmp    c0101e8d <__alltraps>

c0101ed3 <vector4>:
.globl vector4
vector4:
  pushl $0
c0101ed3:	6a 00                	push   $0x0
  pushl $4
c0101ed5:	6a 04                	push   $0x4
  jmp __alltraps
c0101ed7:	e9 b1 ff ff ff       	jmp    c0101e8d <__alltraps>

c0101edc <vector5>:
.globl vector5
vector5:
  pushl $0
c0101edc:	6a 00                	push   $0x0
  pushl $5
c0101ede:	6a 05                	push   $0x5
  jmp __alltraps
c0101ee0:	e9 a8 ff ff ff       	jmp    c0101e8d <__alltraps>

c0101ee5 <vector6>:
.globl vector6
vector6:
  pushl $0
c0101ee5:	6a 00                	push   $0x0
  pushl $6
c0101ee7:	6a 06                	push   $0x6
  jmp __alltraps
c0101ee9:	e9 9f ff ff ff       	jmp    c0101e8d <__alltraps>

c0101eee <vector7>:
.globl vector7
vector7:
  pushl $0
c0101eee:	6a 00                	push   $0x0
  pushl $7
c0101ef0:	6a 07                	push   $0x7
  jmp __alltraps
c0101ef2:	e9 96 ff ff ff       	jmp    c0101e8d <__alltraps>

c0101ef7 <vector8>:
.globl vector8
vector8:
  pushl $8
c0101ef7:	6a 08                	push   $0x8
  jmp __alltraps
c0101ef9:	e9 8f ff ff ff       	jmp    c0101e8d <__alltraps>

c0101efe <vector9>:
.globl vector9
vector9:
  pushl $9
c0101efe:	6a 09                	push   $0x9
  jmp __alltraps
c0101f00:	e9 88 ff ff ff       	jmp    c0101e8d <__alltraps>

c0101f05 <vector10>:
.globl vector10
vector10:
  pushl $10
c0101f05:	6a 0a                	push   $0xa
  jmp __alltraps
c0101f07:	e9 81 ff ff ff       	jmp    c0101e8d <__alltraps>

c0101f0c <vector11>:
.globl vector11
vector11:
  pushl $11
c0101f0c:	6a 0b                	push   $0xb
  jmp __alltraps
c0101f0e:	e9 7a ff ff ff       	jmp    c0101e8d <__alltraps>

c0101f13 <vector12>:
.globl vector12
vector12:
  pushl $12
c0101f13:	6a 0c                	push   $0xc
  jmp __alltraps
c0101f15:	e9 73 ff ff ff       	jmp    c0101e8d <__alltraps>

c0101f1a <vector13>:
.globl vector13
vector13:
  pushl $13
c0101f1a:	6a 0d                	push   $0xd
  jmp __alltraps
c0101f1c:	e9 6c ff ff ff       	jmp    c0101e8d <__alltraps>

c0101f21 <vector14>:
.globl vector14
vector14:
  pushl $14
c0101f21:	6a 0e                	push   $0xe
  jmp __alltraps
c0101f23:	e9 65 ff ff ff       	jmp    c0101e8d <__alltraps>

c0101f28 <vector15>:
.globl vector15
vector15:
  pushl $0
c0101f28:	6a 00                	push   $0x0
  pushl $15
c0101f2a:	6a 0f                	push   $0xf
  jmp __alltraps
c0101f2c:	e9 5c ff ff ff       	jmp    c0101e8d <__alltraps>

c0101f31 <vector16>:
.globl vector16
vector16:
  pushl $0
c0101f31:	6a 00                	push   $0x0
  pushl $16
c0101f33:	6a 10                	push   $0x10
  jmp __alltraps
c0101f35:	e9 53 ff ff ff       	jmp    c0101e8d <__alltraps>

c0101f3a <vector17>:
.globl vector17
vector17:
  pushl $17
c0101f3a:	6a 11                	push   $0x11
  jmp __alltraps
c0101f3c:	e9 4c ff ff ff       	jmp    c0101e8d <__alltraps>

c0101f41 <vector18>:
.globl vector18
vector18:
  pushl $0
c0101f41:	6a 00                	push   $0x0
  pushl $18
c0101f43:	6a 12                	push   $0x12
  jmp __alltraps
c0101f45:	e9 43 ff ff ff       	jmp    c0101e8d <__alltraps>

c0101f4a <vector19>:
.globl vector19
vector19:
  pushl $0
c0101f4a:	6a 00                	push   $0x0
  pushl $19
c0101f4c:	6a 13                	push   $0x13
  jmp __alltraps
c0101f4e:	e9 3a ff ff ff       	jmp    c0101e8d <__alltraps>

c0101f53 <vector20>:
.globl vector20
vector20:
  pushl $0
c0101f53:	6a 00                	push   $0x0
  pushl $20
c0101f55:	6a 14                	push   $0x14
  jmp __alltraps
c0101f57:	e9 31 ff ff ff       	jmp    c0101e8d <__alltraps>

c0101f5c <vector21>:
.globl vector21
vector21:
  pushl $0
c0101f5c:	6a 00                	push   $0x0
  pushl $21
c0101f5e:	6a 15                	push   $0x15
  jmp __alltraps
c0101f60:	e9 28 ff ff ff       	jmp    c0101e8d <__alltraps>

c0101f65 <vector22>:
.globl vector22
vector22:
  pushl $0
c0101f65:	6a 00                	push   $0x0
  pushl $22
c0101f67:	6a 16                	push   $0x16
  jmp __alltraps
c0101f69:	e9 1f ff ff ff       	jmp    c0101e8d <__alltraps>

c0101f6e <vector23>:
.globl vector23
vector23:
  pushl $0
c0101f6e:	6a 00                	push   $0x0
  pushl $23
c0101f70:	6a 17                	push   $0x17
  jmp __alltraps
c0101f72:	e9 16 ff ff ff       	jmp    c0101e8d <__alltraps>

c0101f77 <vector24>:
.globl vector24
vector24:
  pushl $0
c0101f77:	6a 00                	push   $0x0
  pushl $24
c0101f79:	6a 18                	push   $0x18
  jmp __alltraps
c0101f7b:	e9 0d ff ff ff       	jmp    c0101e8d <__alltraps>

c0101f80 <vector25>:
.globl vector25
vector25:
  pushl $0
c0101f80:	6a 00                	push   $0x0
  pushl $25
c0101f82:	6a 19                	push   $0x19
  jmp __alltraps
c0101f84:	e9 04 ff ff ff       	jmp    c0101e8d <__alltraps>

c0101f89 <vector26>:
.globl vector26
vector26:
  pushl $0
c0101f89:	6a 00                	push   $0x0
  pushl $26
c0101f8b:	6a 1a                	push   $0x1a
  jmp __alltraps
c0101f8d:	e9 fb fe ff ff       	jmp    c0101e8d <__alltraps>

c0101f92 <vector27>:
.globl vector27
vector27:
  pushl $0
c0101f92:	6a 00                	push   $0x0
  pushl $27
c0101f94:	6a 1b                	push   $0x1b
  jmp __alltraps
c0101f96:	e9 f2 fe ff ff       	jmp    c0101e8d <__alltraps>

c0101f9b <vector28>:
.globl vector28
vector28:
  pushl $0
c0101f9b:	6a 00                	push   $0x0
  pushl $28
c0101f9d:	6a 1c                	push   $0x1c
  jmp __alltraps
c0101f9f:	e9 e9 fe ff ff       	jmp    c0101e8d <__alltraps>

c0101fa4 <vector29>:
.globl vector29
vector29:
  pushl $0
c0101fa4:	6a 00                	push   $0x0
  pushl $29
c0101fa6:	6a 1d                	push   $0x1d
  jmp __alltraps
c0101fa8:	e9 e0 fe ff ff       	jmp    c0101e8d <__alltraps>

c0101fad <vector30>:
.globl vector30
vector30:
  pushl $0
c0101fad:	6a 00                	push   $0x0
  pushl $30
c0101faf:	6a 1e                	push   $0x1e
  jmp __alltraps
c0101fb1:	e9 d7 fe ff ff       	jmp    c0101e8d <__alltraps>

c0101fb6 <vector31>:
.globl vector31
vector31:
  pushl $0
c0101fb6:	6a 00                	push   $0x0
  pushl $31
c0101fb8:	6a 1f                	push   $0x1f
  jmp __alltraps
c0101fba:	e9 ce fe ff ff       	jmp    c0101e8d <__alltraps>

c0101fbf <vector32>:
.globl vector32
vector32:
  pushl $0
c0101fbf:	6a 00                	push   $0x0
  pushl $32
c0101fc1:	6a 20                	push   $0x20
  jmp __alltraps
c0101fc3:	e9 c5 fe ff ff       	jmp    c0101e8d <__alltraps>

c0101fc8 <vector33>:
.globl vector33
vector33:
  pushl $0
c0101fc8:	6a 00                	push   $0x0
  pushl $33
c0101fca:	6a 21                	push   $0x21
  jmp __alltraps
c0101fcc:	e9 bc fe ff ff       	jmp    c0101e8d <__alltraps>

c0101fd1 <vector34>:
.globl vector34
vector34:
  pushl $0
c0101fd1:	6a 00                	push   $0x0
  pushl $34
c0101fd3:	6a 22                	push   $0x22
  jmp __alltraps
c0101fd5:	e9 b3 fe ff ff       	jmp    c0101e8d <__alltraps>

c0101fda <vector35>:
.globl vector35
vector35:
  pushl $0
c0101fda:	6a 00                	push   $0x0
  pushl $35
c0101fdc:	6a 23                	push   $0x23
  jmp __alltraps
c0101fde:	e9 aa fe ff ff       	jmp    c0101e8d <__alltraps>

c0101fe3 <vector36>:
.globl vector36
vector36:
  pushl $0
c0101fe3:	6a 00                	push   $0x0
  pushl $36
c0101fe5:	6a 24                	push   $0x24
  jmp __alltraps
c0101fe7:	e9 a1 fe ff ff       	jmp    c0101e8d <__alltraps>

c0101fec <vector37>:
.globl vector37
vector37:
  pushl $0
c0101fec:	6a 00                	push   $0x0
  pushl $37
c0101fee:	6a 25                	push   $0x25
  jmp __alltraps
c0101ff0:	e9 98 fe ff ff       	jmp    c0101e8d <__alltraps>

c0101ff5 <vector38>:
.globl vector38
vector38:
  pushl $0
c0101ff5:	6a 00                	push   $0x0
  pushl $38
c0101ff7:	6a 26                	push   $0x26
  jmp __alltraps
c0101ff9:	e9 8f fe ff ff       	jmp    c0101e8d <__alltraps>

c0101ffe <vector39>:
.globl vector39
vector39:
  pushl $0
c0101ffe:	6a 00                	push   $0x0
  pushl $39
c0102000:	6a 27                	push   $0x27
  jmp __alltraps
c0102002:	e9 86 fe ff ff       	jmp    c0101e8d <__alltraps>

c0102007 <vector40>:
.globl vector40
vector40:
  pushl $0
c0102007:	6a 00                	push   $0x0
  pushl $40
c0102009:	6a 28                	push   $0x28
  jmp __alltraps
c010200b:	e9 7d fe ff ff       	jmp    c0101e8d <__alltraps>

c0102010 <vector41>:
.globl vector41
vector41:
  pushl $0
c0102010:	6a 00                	push   $0x0
  pushl $41
c0102012:	6a 29                	push   $0x29
  jmp __alltraps
c0102014:	e9 74 fe ff ff       	jmp    c0101e8d <__alltraps>

c0102019 <vector42>:
.globl vector42
vector42:
  pushl $0
c0102019:	6a 00                	push   $0x0
  pushl $42
c010201b:	6a 2a                	push   $0x2a
  jmp __alltraps
c010201d:	e9 6b fe ff ff       	jmp    c0101e8d <__alltraps>

c0102022 <vector43>:
.globl vector43
vector43:
  pushl $0
c0102022:	6a 00                	push   $0x0
  pushl $43
c0102024:	6a 2b                	push   $0x2b
  jmp __alltraps
c0102026:	e9 62 fe ff ff       	jmp    c0101e8d <__alltraps>

c010202b <vector44>:
.globl vector44
vector44:
  pushl $0
c010202b:	6a 00                	push   $0x0
  pushl $44
c010202d:	6a 2c                	push   $0x2c
  jmp __alltraps
c010202f:	e9 59 fe ff ff       	jmp    c0101e8d <__alltraps>

c0102034 <vector45>:
.globl vector45
vector45:
  pushl $0
c0102034:	6a 00                	push   $0x0
  pushl $45
c0102036:	6a 2d                	push   $0x2d
  jmp __alltraps
c0102038:	e9 50 fe ff ff       	jmp    c0101e8d <__alltraps>

c010203d <vector46>:
.globl vector46
vector46:
  pushl $0
c010203d:	6a 00                	push   $0x0
  pushl $46
c010203f:	6a 2e                	push   $0x2e
  jmp __alltraps
c0102041:	e9 47 fe ff ff       	jmp    c0101e8d <__alltraps>

c0102046 <vector47>:
.globl vector47
vector47:
  pushl $0
c0102046:	6a 00                	push   $0x0
  pushl $47
c0102048:	6a 2f                	push   $0x2f
  jmp __alltraps
c010204a:	e9 3e fe ff ff       	jmp    c0101e8d <__alltraps>

c010204f <vector48>:
.globl vector48
vector48:
  pushl $0
c010204f:	6a 00                	push   $0x0
  pushl $48
c0102051:	6a 30                	push   $0x30
  jmp __alltraps
c0102053:	e9 35 fe ff ff       	jmp    c0101e8d <__alltraps>

c0102058 <vector49>:
.globl vector49
vector49:
  pushl $0
c0102058:	6a 00                	push   $0x0
  pushl $49
c010205a:	6a 31                	push   $0x31
  jmp __alltraps
c010205c:	e9 2c fe ff ff       	jmp    c0101e8d <__alltraps>

c0102061 <vector50>:
.globl vector50
vector50:
  pushl $0
c0102061:	6a 00                	push   $0x0
  pushl $50
c0102063:	6a 32                	push   $0x32
  jmp __alltraps
c0102065:	e9 23 fe ff ff       	jmp    c0101e8d <__alltraps>

c010206a <vector51>:
.globl vector51
vector51:
  pushl $0
c010206a:	6a 00                	push   $0x0
  pushl $51
c010206c:	6a 33                	push   $0x33
  jmp __alltraps
c010206e:	e9 1a fe ff ff       	jmp    c0101e8d <__alltraps>

c0102073 <vector52>:
.globl vector52
vector52:
  pushl $0
c0102073:	6a 00                	push   $0x0
  pushl $52
c0102075:	6a 34                	push   $0x34
  jmp __alltraps
c0102077:	e9 11 fe ff ff       	jmp    c0101e8d <__alltraps>

c010207c <vector53>:
.globl vector53
vector53:
  pushl $0
c010207c:	6a 00                	push   $0x0
  pushl $53
c010207e:	6a 35                	push   $0x35
  jmp __alltraps
c0102080:	e9 08 fe ff ff       	jmp    c0101e8d <__alltraps>

c0102085 <vector54>:
.globl vector54
vector54:
  pushl $0
c0102085:	6a 00                	push   $0x0
  pushl $54
c0102087:	6a 36                	push   $0x36
  jmp __alltraps
c0102089:	e9 ff fd ff ff       	jmp    c0101e8d <__alltraps>

c010208e <vector55>:
.globl vector55
vector55:
  pushl $0
c010208e:	6a 00                	push   $0x0
  pushl $55
c0102090:	6a 37                	push   $0x37
  jmp __alltraps
c0102092:	e9 f6 fd ff ff       	jmp    c0101e8d <__alltraps>

c0102097 <vector56>:
.globl vector56
vector56:
  pushl $0
c0102097:	6a 00                	push   $0x0
  pushl $56
c0102099:	6a 38                	push   $0x38
  jmp __alltraps
c010209b:	e9 ed fd ff ff       	jmp    c0101e8d <__alltraps>

c01020a0 <vector57>:
.globl vector57
vector57:
  pushl $0
c01020a0:	6a 00                	push   $0x0
  pushl $57
c01020a2:	6a 39                	push   $0x39
  jmp __alltraps
c01020a4:	e9 e4 fd ff ff       	jmp    c0101e8d <__alltraps>

c01020a9 <vector58>:
.globl vector58
vector58:
  pushl $0
c01020a9:	6a 00                	push   $0x0
  pushl $58
c01020ab:	6a 3a                	push   $0x3a
  jmp __alltraps
c01020ad:	e9 db fd ff ff       	jmp    c0101e8d <__alltraps>

c01020b2 <vector59>:
.globl vector59
vector59:
  pushl $0
c01020b2:	6a 00                	push   $0x0
  pushl $59
c01020b4:	6a 3b                	push   $0x3b
  jmp __alltraps
c01020b6:	e9 d2 fd ff ff       	jmp    c0101e8d <__alltraps>

c01020bb <vector60>:
.globl vector60
vector60:
  pushl $0
c01020bb:	6a 00                	push   $0x0
  pushl $60
c01020bd:	6a 3c                	push   $0x3c
  jmp __alltraps
c01020bf:	e9 c9 fd ff ff       	jmp    c0101e8d <__alltraps>

c01020c4 <vector61>:
.globl vector61
vector61:
  pushl $0
c01020c4:	6a 00                	push   $0x0
  pushl $61
c01020c6:	6a 3d                	push   $0x3d
  jmp __alltraps
c01020c8:	e9 c0 fd ff ff       	jmp    c0101e8d <__alltraps>

c01020cd <vector62>:
.globl vector62
vector62:
  pushl $0
c01020cd:	6a 00                	push   $0x0
  pushl $62
c01020cf:	6a 3e                	push   $0x3e
  jmp __alltraps
c01020d1:	e9 b7 fd ff ff       	jmp    c0101e8d <__alltraps>

c01020d6 <vector63>:
.globl vector63
vector63:
  pushl $0
c01020d6:	6a 00                	push   $0x0
  pushl $63
c01020d8:	6a 3f                	push   $0x3f
  jmp __alltraps
c01020da:	e9 ae fd ff ff       	jmp    c0101e8d <__alltraps>

c01020df <vector64>:
.globl vector64
vector64:
  pushl $0
c01020df:	6a 00                	push   $0x0
  pushl $64
c01020e1:	6a 40                	push   $0x40
  jmp __alltraps
c01020e3:	e9 a5 fd ff ff       	jmp    c0101e8d <__alltraps>

c01020e8 <vector65>:
.globl vector65
vector65:
  pushl $0
c01020e8:	6a 00                	push   $0x0
  pushl $65
c01020ea:	6a 41                	push   $0x41
  jmp __alltraps
c01020ec:	e9 9c fd ff ff       	jmp    c0101e8d <__alltraps>

c01020f1 <vector66>:
.globl vector66
vector66:
  pushl $0
c01020f1:	6a 00                	push   $0x0
  pushl $66
c01020f3:	6a 42                	push   $0x42
  jmp __alltraps
c01020f5:	e9 93 fd ff ff       	jmp    c0101e8d <__alltraps>

c01020fa <vector67>:
.globl vector67
vector67:
  pushl $0
c01020fa:	6a 00                	push   $0x0
  pushl $67
c01020fc:	6a 43                	push   $0x43
  jmp __alltraps
c01020fe:	e9 8a fd ff ff       	jmp    c0101e8d <__alltraps>

c0102103 <vector68>:
.globl vector68
vector68:
  pushl $0
c0102103:	6a 00                	push   $0x0
  pushl $68
c0102105:	6a 44                	push   $0x44
  jmp __alltraps
c0102107:	e9 81 fd ff ff       	jmp    c0101e8d <__alltraps>

c010210c <vector69>:
.globl vector69
vector69:
  pushl $0
c010210c:	6a 00                	push   $0x0
  pushl $69
c010210e:	6a 45                	push   $0x45
  jmp __alltraps
c0102110:	e9 78 fd ff ff       	jmp    c0101e8d <__alltraps>

c0102115 <vector70>:
.globl vector70
vector70:
  pushl $0
c0102115:	6a 00                	push   $0x0
  pushl $70
c0102117:	6a 46                	push   $0x46
  jmp __alltraps
c0102119:	e9 6f fd ff ff       	jmp    c0101e8d <__alltraps>

c010211e <vector71>:
.globl vector71
vector71:
  pushl $0
c010211e:	6a 00                	push   $0x0
  pushl $71
c0102120:	6a 47                	push   $0x47
  jmp __alltraps
c0102122:	e9 66 fd ff ff       	jmp    c0101e8d <__alltraps>

c0102127 <vector72>:
.globl vector72
vector72:
  pushl $0
c0102127:	6a 00                	push   $0x0
  pushl $72
c0102129:	6a 48                	push   $0x48
  jmp __alltraps
c010212b:	e9 5d fd ff ff       	jmp    c0101e8d <__alltraps>

c0102130 <vector73>:
.globl vector73
vector73:
  pushl $0
c0102130:	6a 00                	push   $0x0
  pushl $73
c0102132:	6a 49                	push   $0x49
  jmp __alltraps
c0102134:	e9 54 fd ff ff       	jmp    c0101e8d <__alltraps>

c0102139 <vector74>:
.globl vector74
vector74:
  pushl $0
c0102139:	6a 00                	push   $0x0
  pushl $74
c010213b:	6a 4a                	push   $0x4a
  jmp __alltraps
c010213d:	e9 4b fd ff ff       	jmp    c0101e8d <__alltraps>

c0102142 <vector75>:
.globl vector75
vector75:
  pushl $0
c0102142:	6a 00                	push   $0x0
  pushl $75
c0102144:	6a 4b                	push   $0x4b
  jmp __alltraps
c0102146:	e9 42 fd ff ff       	jmp    c0101e8d <__alltraps>

c010214b <vector76>:
.globl vector76
vector76:
  pushl $0
c010214b:	6a 00                	push   $0x0
  pushl $76
c010214d:	6a 4c                	push   $0x4c
  jmp __alltraps
c010214f:	e9 39 fd ff ff       	jmp    c0101e8d <__alltraps>

c0102154 <vector77>:
.globl vector77
vector77:
  pushl $0
c0102154:	6a 00                	push   $0x0
  pushl $77
c0102156:	6a 4d                	push   $0x4d
  jmp __alltraps
c0102158:	e9 30 fd ff ff       	jmp    c0101e8d <__alltraps>

c010215d <vector78>:
.globl vector78
vector78:
  pushl $0
c010215d:	6a 00                	push   $0x0
  pushl $78
c010215f:	6a 4e                	push   $0x4e
  jmp __alltraps
c0102161:	e9 27 fd ff ff       	jmp    c0101e8d <__alltraps>

c0102166 <vector79>:
.globl vector79
vector79:
  pushl $0
c0102166:	6a 00                	push   $0x0
  pushl $79
c0102168:	6a 4f                	push   $0x4f
  jmp __alltraps
c010216a:	e9 1e fd ff ff       	jmp    c0101e8d <__alltraps>

c010216f <vector80>:
.globl vector80
vector80:
  pushl $0
c010216f:	6a 00                	push   $0x0
  pushl $80
c0102171:	6a 50                	push   $0x50
  jmp __alltraps
c0102173:	e9 15 fd ff ff       	jmp    c0101e8d <__alltraps>

c0102178 <vector81>:
.globl vector81
vector81:
  pushl $0
c0102178:	6a 00                	push   $0x0
  pushl $81
c010217a:	6a 51                	push   $0x51
  jmp __alltraps
c010217c:	e9 0c fd ff ff       	jmp    c0101e8d <__alltraps>

c0102181 <vector82>:
.globl vector82
vector82:
  pushl $0
c0102181:	6a 00                	push   $0x0
  pushl $82
c0102183:	6a 52                	push   $0x52
  jmp __alltraps
c0102185:	e9 03 fd ff ff       	jmp    c0101e8d <__alltraps>

c010218a <vector83>:
.globl vector83
vector83:
  pushl $0
c010218a:	6a 00                	push   $0x0
  pushl $83
c010218c:	6a 53                	push   $0x53
  jmp __alltraps
c010218e:	e9 fa fc ff ff       	jmp    c0101e8d <__alltraps>

c0102193 <vector84>:
.globl vector84
vector84:
  pushl $0
c0102193:	6a 00                	push   $0x0
  pushl $84
c0102195:	6a 54                	push   $0x54
  jmp __alltraps
c0102197:	e9 f1 fc ff ff       	jmp    c0101e8d <__alltraps>

c010219c <vector85>:
.globl vector85
vector85:
  pushl $0
c010219c:	6a 00                	push   $0x0
  pushl $85
c010219e:	6a 55                	push   $0x55
  jmp __alltraps
c01021a0:	e9 e8 fc ff ff       	jmp    c0101e8d <__alltraps>

c01021a5 <vector86>:
.globl vector86
vector86:
  pushl $0
c01021a5:	6a 00                	push   $0x0
  pushl $86
c01021a7:	6a 56                	push   $0x56
  jmp __alltraps
c01021a9:	e9 df fc ff ff       	jmp    c0101e8d <__alltraps>

c01021ae <vector87>:
.globl vector87
vector87:
  pushl $0
c01021ae:	6a 00                	push   $0x0
  pushl $87
c01021b0:	6a 57                	push   $0x57
  jmp __alltraps
c01021b2:	e9 d6 fc ff ff       	jmp    c0101e8d <__alltraps>

c01021b7 <vector88>:
.globl vector88
vector88:
  pushl $0
c01021b7:	6a 00                	push   $0x0
  pushl $88
c01021b9:	6a 58                	push   $0x58
  jmp __alltraps
c01021bb:	e9 cd fc ff ff       	jmp    c0101e8d <__alltraps>

c01021c0 <vector89>:
.globl vector89
vector89:
  pushl $0
c01021c0:	6a 00                	push   $0x0
  pushl $89
c01021c2:	6a 59                	push   $0x59
  jmp __alltraps
c01021c4:	e9 c4 fc ff ff       	jmp    c0101e8d <__alltraps>

c01021c9 <vector90>:
.globl vector90
vector90:
  pushl $0
c01021c9:	6a 00                	push   $0x0
  pushl $90
c01021cb:	6a 5a                	push   $0x5a
  jmp __alltraps
c01021cd:	e9 bb fc ff ff       	jmp    c0101e8d <__alltraps>

c01021d2 <vector91>:
.globl vector91
vector91:
  pushl $0
c01021d2:	6a 00                	push   $0x0
  pushl $91
c01021d4:	6a 5b                	push   $0x5b
  jmp __alltraps
c01021d6:	e9 b2 fc ff ff       	jmp    c0101e8d <__alltraps>

c01021db <vector92>:
.globl vector92
vector92:
  pushl $0
c01021db:	6a 00                	push   $0x0
  pushl $92
c01021dd:	6a 5c                	push   $0x5c
  jmp __alltraps
c01021df:	e9 a9 fc ff ff       	jmp    c0101e8d <__alltraps>

c01021e4 <vector93>:
.globl vector93
vector93:
  pushl $0
c01021e4:	6a 00                	push   $0x0
  pushl $93
c01021e6:	6a 5d                	push   $0x5d
  jmp __alltraps
c01021e8:	e9 a0 fc ff ff       	jmp    c0101e8d <__alltraps>

c01021ed <vector94>:
.globl vector94
vector94:
  pushl $0
c01021ed:	6a 00                	push   $0x0
  pushl $94
c01021ef:	6a 5e                	push   $0x5e
  jmp __alltraps
c01021f1:	e9 97 fc ff ff       	jmp    c0101e8d <__alltraps>

c01021f6 <vector95>:
.globl vector95
vector95:
  pushl $0
c01021f6:	6a 00                	push   $0x0
  pushl $95
c01021f8:	6a 5f                	push   $0x5f
  jmp __alltraps
c01021fa:	e9 8e fc ff ff       	jmp    c0101e8d <__alltraps>

c01021ff <vector96>:
.globl vector96
vector96:
  pushl $0
c01021ff:	6a 00                	push   $0x0
  pushl $96
c0102201:	6a 60                	push   $0x60
  jmp __alltraps
c0102203:	e9 85 fc ff ff       	jmp    c0101e8d <__alltraps>

c0102208 <vector97>:
.globl vector97
vector97:
  pushl $0
c0102208:	6a 00                	push   $0x0
  pushl $97
c010220a:	6a 61                	push   $0x61
  jmp __alltraps
c010220c:	e9 7c fc ff ff       	jmp    c0101e8d <__alltraps>

c0102211 <vector98>:
.globl vector98
vector98:
  pushl $0
c0102211:	6a 00                	push   $0x0
  pushl $98
c0102213:	6a 62                	push   $0x62
  jmp __alltraps
c0102215:	e9 73 fc ff ff       	jmp    c0101e8d <__alltraps>

c010221a <vector99>:
.globl vector99
vector99:
  pushl $0
c010221a:	6a 00                	push   $0x0
  pushl $99
c010221c:	6a 63                	push   $0x63
  jmp __alltraps
c010221e:	e9 6a fc ff ff       	jmp    c0101e8d <__alltraps>

c0102223 <vector100>:
.globl vector100
vector100:
  pushl $0
c0102223:	6a 00                	push   $0x0
  pushl $100
c0102225:	6a 64                	push   $0x64
  jmp __alltraps
c0102227:	e9 61 fc ff ff       	jmp    c0101e8d <__alltraps>

c010222c <vector101>:
.globl vector101
vector101:
  pushl $0
c010222c:	6a 00                	push   $0x0
  pushl $101
c010222e:	6a 65                	push   $0x65
  jmp __alltraps
c0102230:	e9 58 fc ff ff       	jmp    c0101e8d <__alltraps>

c0102235 <vector102>:
.globl vector102
vector102:
  pushl $0
c0102235:	6a 00                	push   $0x0
  pushl $102
c0102237:	6a 66                	push   $0x66
  jmp __alltraps
c0102239:	e9 4f fc ff ff       	jmp    c0101e8d <__alltraps>

c010223e <vector103>:
.globl vector103
vector103:
  pushl $0
c010223e:	6a 00                	push   $0x0
  pushl $103
c0102240:	6a 67                	push   $0x67
  jmp __alltraps
c0102242:	e9 46 fc ff ff       	jmp    c0101e8d <__alltraps>

c0102247 <vector104>:
.globl vector104
vector104:
  pushl $0
c0102247:	6a 00                	push   $0x0
  pushl $104
c0102249:	6a 68                	push   $0x68
  jmp __alltraps
c010224b:	e9 3d fc ff ff       	jmp    c0101e8d <__alltraps>

c0102250 <vector105>:
.globl vector105
vector105:
  pushl $0
c0102250:	6a 00                	push   $0x0
  pushl $105
c0102252:	6a 69                	push   $0x69
  jmp __alltraps
c0102254:	e9 34 fc ff ff       	jmp    c0101e8d <__alltraps>

c0102259 <vector106>:
.globl vector106
vector106:
  pushl $0
c0102259:	6a 00                	push   $0x0
  pushl $106
c010225b:	6a 6a                	push   $0x6a
  jmp __alltraps
c010225d:	e9 2b fc ff ff       	jmp    c0101e8d <__alltraps>

c0102262 <vector107>:
.globl vector107
vector107:
  pushl $0
c0102262:	6a 00                	push   $0x0
  pushl $107
c0102264:	6a 6b                	push   $0x6b
  jmp __alltraps
c0102266:	e9 22 fc ff ff       	jmp    c0101e8d <__alltraps>

c010226b <vector108>:
.globl vector108
vector108:
  pushl $0
c010226b:	6a 00                	push   $0x0
  pushl $108
c010226d:	6a 6c                	push   $0x6c
  jmp __alltraps
c010226f:	e9 19 fc ff ff       	jmp    c0101e8d <__alltraps>

c0102274 <vector109>:
.globl vector109
vector109:
  pushl $0
c0102274:	6a 00                	push   $0x0
  pushl $109
c0102276:	6a 6d                	push   $0x6d
  jmp __alltraps
c0102278:	e9 10 fc ff ff       	jmp    c0101e8d <__alltraps>

c010227d <vector110>:
.globl vector110
vector110:
  pushl $0
c010227d:	6a 00                	push   $0x0
  pushl $110
c010227f:	6a 6e                	push   $0x6e
  jmp __alltraps
c0102281:	e9 07 fc ff ff       	jmp    c0101e8d <__alltraps>

c0102286 <vector111>:
.globl vector111
vector111:
  pushl $0
c0102286:	6a 00                	push   $0x0
  pushl $111
c0102288:	6a 6f                	push   $0x6f
  jmp __alltraps
c010228a:	e9 fe fb ff ff       	jmp    c0101e8d <__alltraps>

c010228f <vector112>:
.globl vector112
vector112:
  pushl $0
c010228f:	6a 00                	push   $0x0
  pushl $112
c0102291:	6a 70                	push   $0x70
  jmp __alltraps
c0102293:	e9 f5 fb ff ff       	jmp    c0101e8d <__alltraps>

c0102298 <vector113>:
.globl vector113
vector113:
  pushl $0
c0102298:	6a 00                	push   $0x0
  pushl $113
c010229a:	6a 71                	push   $0x71
  jmp __alltraps
c010229c:	e9 ec fb ff ff       	jmp    c0101e8d <__alltraps>

c01022a1 <vector114>:
.globl vector114
vector114:
  pushl $0
c01022a1:	6a 00                	push   $0x0
  pushl $114
c01022a3:	6a 72                	push   $0x72
  jmp __alltraps
c01022a5:	e9 e3 fb ff ff       	jmp    c0101e8d <__alltraps>

c01022aa <vector115>:
.globl vector115
vector115:
  pushl $0
c01022aa:	6a 00                	push   $0x0
  pushl $115
c01022ac:	6a 73                	push   $0x73
  jmp __alltraps
c01022ae:	e9 da fb ff ff       	jmp    c0101e8d <__alltraps>

c01022b3 <vector116>:
.globl vector116
vector116:
  pushl $0
c01022b3:	6a 00                	push   $0x0
  pushl $116
c01022b5:	6a 74                	push   $0x74
  jmp __alltraps
c01022b7:	e9 d1 fb ff ff       	jmp    c0101e8d <__alltraps>

c01022bc <vector117>:
.globl vector117
vector117:
  pushl $0
c01022bc:	6a 00                	push   $0x0
  pushl $117
c01022be:	6a 75                	push   $0x75
  jmp __alltraps
c01022c0:	e9 c8 fb ff ff       	jmp    c0101e8d <__alltraps>

c01022c5 <vector118>:
.globl vector118
vector118:
  pushl $0
c01022c5:	6a 00                	push   $0x0
  pushl $118
c01022c7:	6a 76                	push   $0x76
  jmp __alltraps
c01022c9:	e9 bf fb ff ff       	jmp    c0101e8d <__alltraps>

c01022ce <vector119>:
.globl vector119
vector119:
  pushl $0
c01022ce:	6a 00                	push   $0x0
  pushl $119
c01022d0:	6a 77                	push   $0x77
  jmp __alltraps
c01022d2:	e9 b6 fb ff ff       	jmp    c0101e8d <__alltraps>

c01022d7 <vector120>:
.globl vector120
vector120:
  pushl $0
c01022d7:	6a 00                	push   $0x0
  pushl $120
c01022d9:	6a 78                	push   $0x78
  jmp __alltraps
c01022db:	e9 ad fb ff ff       	jmp    c0101e8d <__alltraps>

c01022e0 <vector121>:
.globl vector121
vector121:
  pushl $0
c01022e0:	6a 00                	push   $0x0
  pushl $121
c01022e2:	6a 79                	push   $0x79
  jmp __alltraps
c01022e4:	e9 a4 fb ff ff       	jmp    c0101e8d <__alltraps>

c01022e9 <vector122>:
.globl vector122
vector122:
  pushl $0
c01022e9:	6a 00                	push   $0x0
  pushl $122
c01022eb:	6a 7a                	push   $0x7a
  jmp __alltraps
c01022ed:	e9 9b fb ff ff       	jmp    c0101e8d <__alltraps>

c01022f2 <vector123>:
.globl vector123
vector123:
  pushl $0
c01022f2:	6a 00                	push   $0x0
  pushl $123
c01022f4:	6a 7b                	push   $0x7b
  jmp __alltraps
c01022f6:	e9 92 fb ff ff       	jmp    c0101e8d <__alltraps>

c01022fb <vector124>:
.globl vector124
vector124:
  pushl $0
c01022fb:	6a 00                	push   $0x0
  pushl $124
c01022fd:	6a 7c                	push   $0x7c
  jmp __alltraps
c01022ff:	e9 89 fb ff ff       	jmp    c0101e8d <__alltraps>

c0102304 <vector125>:
.globl vector125
vector125:
  pushl $0
c0102304:	6a 00                	push   $0x0
  pushl $125
c0102306:	6a 7d                	push   $0x7d
  jmp __alltraps
c0102308:	e9 80 fb ff ff       	jmp    c0101e8d <__alltraps>

c010230d <vector126>:
.globl vector126
vector126:
  pushl $0
c010230d:	6a 00                	push   $0x0
  pushl $126
c010230f:	6a 7e                	push   $0x7e
  jmp __alltraps
c0102311:	e9 77 fb ff ff       	jmp    c0101e8d <__alltraps>

c0102316 <vector127>:
.globl vector127
vector127:
  pushl $0
c0102316:	6a 00                	push   $0x0
  pushl $127
c0102318:	6a 7f                	push   $0x7f
  jmp __alltraps
c010231a:	e9 6e fb ff ff       	jmp    c0101e8d <__alltraps>

c010231f <vector128>:
.globl vector128
vector128:
  pushl $0
c010231f:	6a 00                	push   $0x0
  pushl $128
c0102321:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c0102326:	e9 62 fb ff ff       	jmp    c0101e8d <__alltraps>

c010232b <vector129>:
.globl vector129
vector129:
  pushl $0
c010232b:	6a 00                	push   $0x0
  pushl $129
c010232d:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c0102332:	e9 56 fb ff ff       	jmp    c0101e8d <__alltraps>

c0102337 <vector130>:
.globl vector130
vector130:
  pushl $0
c0102337:	6a 00                	push   $0x0
  pushl $130
c0102339:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c010233e:	e9 4a fb ff ff       	jmp    c0101e8d <__alltraps>

c0102343 <vector131>:
.globl vector131
vector131:
  pushl $0
c0102343:	6a 00                	push   $0x0
  pushl $131
c0102345:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c010234a:	e9 3e fb ff ff       	jmp    c0101e8d <__alltraps>

c010234f <vector132>:
.globl vector132
vector132:
  pushl $0
c010234f:	6a 00                	push   $0x0
  pushl $132
c0102351:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c0102356:	e9 32 fb ff ff       	jmp    c0101e8d <__alltraps>

c010235b <vector133>:
.globl vector133
vector133:
  pushl $0
c010235b:	6a 00                	push   $0x0
  pushl $133
c010235d:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c0102362:	e9 26 fb ff ff       	jmp    c0101e8d <__alltraps>

c0102367 <vector134>:
.globl vector134
vector134:
  pushl $0
c0102367:	6a 00                	push   $0x0
  pushl $134
c0102369:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c010236e:	e9 1a fb ff ff       	jmp    c0101e8d <__alltraps>

c0102373 <vector135>:
.globl vector135
vector135:
  pushl $0
c0102373:	6a 00                	push   $0x0
  pushl $135
c0102375:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c010237a:	e9 0e fb ff ff       	jmp    c0101e8d <__alltraps>

c010237f <vector136>:
.globl vector136
vector136:
  pushl $0
c010237f:	6a 00                	push   $0x0
  pushl $136
c0102381:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c0102386:	e9 02 fb ff ff       	jmp    c0101e8d <__alltraps>

c010238b <vector137>:
.globl vector137
vector137:
  pushl $0
c010238b:	6a 00                	push   $0x0
  pushl $137
c010238d:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c0102392:	e9 f6 fa ff ff       	jmp    c0101e8d <__alltraps>

c0102397 <vector138>:
.globl vector138
vector138:
  pushl $0
c0102397:	6a 00                	push   $0x0
  pushl $138
c0102399:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c010239e:	e9 ea fa ff ff       	jmp    c0101e8d <__alltraps>

c01023a3 <vector139>:
.globl vector139
vector139:
  pushl $0
c01023a3:	6a 00                	push   $0x0
  pushl $139
c01023a5:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c01023aa:	e9 de fa ff ff       	jmp    c0101e8d <__alltraps>

c01023af <vector140>:
.globl vector140
vector140:
  pushl $0
c01023af:	6a 00                	push   $0x0
  pushl $140
c01023b1:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c01023b6:	e9 d2 fa ff ff       	jmp    c0101e8d <__alltraps>

c01023bb <vector141>:
.globl vector141
vector141:
  pushl $0
c01023bb:	6a 00                	push   $0x0
  pushl $141
c01023bd:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c01023c2:	e9 c6 fa ff ff       	jmp    c0101e8d <__alltraps>

c01023c7 <vector142>:
.globl vector142
vector142:
  pushl $0
c01023c7:	6a 00                	push   $0x0
  pushl $142
c01023c9:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c01023ce:	e9 ba fa ff ff       	jmp    c0101e8d <__alltraps>

c01023d3 <vector143>:
.globl vector143
vector143:
  pushl $0
c01023d3:	6a 00                	push   $0x0
  pushl $143
c01023d5:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c01023da:	e9 ae fa ff ff       	jmp    c0101e8d <__alltraps>

c01023df <vector144>:
.globl vector144
vector144:
  pushl $0
c01023df:	6a 00                	push   $0x0
  pushl $144
c01023e1:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c01023e6:	e9 a2 fa ff ff       	jmp    c0101e8d <__alltraps>

c01023eb <vector145>:
.globl vector145
vector145:
  pushl $0
c01023eb:	6a 00                	push   $0x0
  pushl $145
c01023ed:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c01023f2:	e9 96 fa ff ff       	jmp    c0101e8d <__alltraps>

c01023f7 <vector146>:
.globl vector146
vector146:
  pushl $0
c01023f7:	6a 00                	push   $0x0
  pushl $146
c01023f9:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c01023fe:	e9 8a fa ff ff       	jmp    c0101e8d <__alltraps>

c0102403 <vector147>:
.globl vector147
vector147:
  pushl $0
c0102403:	6a 00                	push   $0x0
  pushl $147
c0102405:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c010240a:	e9 7e fa ff ff       	jmp    c0101e8d <__alltraps>

c010240f <vector148>:
.globl vector148
vector148:
  pushl $0
c010240f:	6a 00                	push   $0x0
  pushl $148
c0102411:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c0102416:	e9 72 fa ff ff       	jmp    c0101e8d <__alltraps>

c010241b <vector149>:
.globl vector149
vector149:
  pushl $0
c010241b:	6a 00                	push   $0x0
  pushl $149
c010241d:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c0102422:	e9 66 fa ff ff       	jmp    c0101e8d <__alltraps>

c0102427 <vector150>:
.globl vector150
vector150:
  pushl $0
c0102427:	6a 00                	push   $0x0
  pushl $150
c0102429:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c010242e:	e9 5a fa ff ff       	jmp    c0101e8d <__alltraps>

c0102433 <vector151>:
.globl vector151
vector151:
  pushl $0
c0102433:	6a 00                	push   $0x0
  pushl $151
c0102435:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c010243a:	e9 4e fa ff ff       	jmp    c0101e8d <__alltraps>

c010243f <vector152>:
.globl vector152
vector152:
  pushl $0
c010243f:	6a 00                	push   $0x0
  pushl $152
c0102441:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c0102446:	e9 42 fa ff ff       	jmp    c0101e8d <__alltraps>

c010244b <vector153>:
.globl vector153
vector153:
  pushl $0
c010244b:	6a 00                	push   $0x0
  pushl $153
c010244d:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c0102452:	e9 36 fa ff ff       	jmp    c0101e8d <__alltraps>

c0102457 <vector154>:
.globl vector154
vector154:
  pushl $0
c0102457:	6a 00                	push   $0x0
  pushl $154
c0102459:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c010245e:	e9 2a fa ff ff       	jmp    c0101e8d <__alltraps>

c0102463 <vector155>:
.globl vector155
vector155:
  pushl $0
c0102463:	6a 00                	push   $0x0
  pushl $155
c0102465:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c010246a:	e9 1e fa ff ff       	jmp    c0101e8d <__alltraps>

c010246f <vector156>:
.globl vector156
vector156:
  pushl $0
c010246f:	6a 00                	push   $0x0
  pushl $156
c0102471:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c0102476:	e9 12 fa ff ff       	jmp    c0101e8d <__alltraps>

c010247b <vector157>:
.globl vector157
vector157:
  pushl $0
c010247b:	6a 00                	push   $0x0
  pushl $157
c010247d:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c0102482:	e9 06 fa ff ff       	jmp    c0101e8d <__alltraps>

c0102487 <vector158>:
.globl vector158
vector158:
  pushl $0
c0102487:	6a 00                	push   $0x0
  pushl $158
c0102489:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c010248e:	e9 fa f9 ff ff       	jmp    c0101e8d <__alltraps>

c0102493 <vector159>:
.globl vector159
vector159:
  pushl $0
c0102493:	6a 00                	push   $0x0
  pushl $159
c0102495:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c010249a:	e9 ee f9 ff ff       	jmp    c0101e8d <__alltraps>

c010249f <vector160>:
.globl vector160
vector160:
  pushl $0
c010249f:	6a 00                	push   $0x0
  pushl $160
c01024a1:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c01024a6:	e9 e2 f9 ff ff       	jmp    c0101e8d <__alltraps>

c01024ab <vector161>:
.globl vector161
vector161:
  pushl $0
c01024ab:	6a 00                	push   $0x0
  pushl $161
c01024ad:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c01024b2:	e9 d6 f9 ff ff       	jmp    c0101e8d <__alltraps>

c01024b7 <vector162>:
.globl vector162
vector162:
  pushl $0
c01024b7:	6a 00                	push   $0x0
  pushl $162
c01024b9:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c01024be:	e9 ca f9 ff ff       	jmp    c0101e8d <__alltraps>

c01024c3 <vector163>:
.globl vector163
vector163:
  pushl $0
c01024c3:	6a 00                	push   $0x0
  pushl $163
c01024c5:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c01024ca:	e9 be f9 ff ff       	jmp    c0101e8d <__alltraps>

c01024cf <vector164>:
.globl vector164
vector164:
  pushl $0
c01024cf:	6a 00                	push   $0x0
  pushl $164
c01024d1:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c01024d6:	e9 b2 f9 ff ff       	jmp    c0101e8d <__alltraps>

c01024db <vector165>:
.globl vector165
vector165:
  pushl $0
c01024db:	6a 00                	push   $0x0
  pushl $165
c01024dd:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c01024e2:	e9 a6 f9 ff ff       	jmp    c0101e8d <__alltraps>

c01024e7 <vector166>:
.globl vector166
vector166:
  pushl $0
c01024e7:	6a 00                	push   $0x0
  pushl $166
c01024e9:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c01024ee:	e9 9a f9 ff ff       	jmp    c0101e8d <__alltraps>

c01024f3 <vector167>:
.globl vector167
vector167:
  pushl $0
c01024f3:	6a 00                	push   $0x0
  pushl $167
c01024f5:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c01024fa:	e9 8e f9 ff ff       	jmp    c0101e8d <__alltraps>

c01024ff <vector168>:
.globl vector168
vector168:
  pushl $0
c01024ff:	6a 00                	push   $0x0
  pushl $168
c0102501:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c0102506:	e9 82 f9 ff ff       	jmp    c0101e8d <__alltraps>

c010250b <vector169>:
.globl vector169
vector169:
  pushl $0
c010250b:	6a 00                	push   $0x0
  pushl $169
c010250d:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c0102512:	e9 76 f9 ff ff       	jmp    c0101e8d <__alltraps>

c0102517 <vector170>:
.globl vector170
vector170:
  pushl $0
c0102517:	6a 00                	push   $0x0
  pushl $170
c0102519:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c010251e:	e9 6a f9 ff ff       	jmp    c0101e8d <__alltraps>

c0102523 <vector171>:
.globl vector171
vector171:
  pushl $0
c0102523:	6a 00                	push   $0x0
  pushl $171
c0102525:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c010252a:	e9 5e f9 ff ff       	jmp    c0101e8d <__alltraps>

c010252f <vector172>:
.globl vector172
vector172:
  pushl $0
c010252f:	6a 00                	push   $0x0
  pushl $172
c0102531:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c0102536:	e9 52 f9 ff ff       	jmp    c0101e8d <__alltraps>

c010253b <vector173>:
.globl vector173
vector173:
  pushl $0
c010253b:	6a 00                	push   $0x0
  pushl $173
c010253d:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c0102542:	e9 46 f9 ff ff       	jmp    c0101e8d <__alltraps>

c0102547 <vector174>:
.globl vector174
vector174:
  pushl $0
c0102547:	6a 00                	push   $0x0
  pushl $174
c0102549:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c010254e:	e9 3a f9 ff ff       	jmp    c0101e8d <__alltraps>

c0102553 <vector175>:
.globl vector175
vector175:
  pushl $0
c0102553:	6a 00                	push   $0x0
  pushl $175
c0102555:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c010255a:	e9 2e f9 ff ff       	jmp    c0101e8d <__alltraps>

c010255f <vector176>:
.globl vector176
vector176:
  pushl $0
c010255f:	6a 00                	push   $0x0
  pushl $176
c0102561:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c0102566:	e9 22 f9 ff ff       	jmp    c0101e8d <__alltraps>

c010256b <vector177>:
.globl vector177
vector177:
  pushl $0
c010256b:	6a 00                	push   $0x0
  pushl $177
c010256d:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c0102572:	e9 16 f9 ff ff       	jmp    c0101e8d <__alltraps>

c0102577 <vector178>:
.globl vector178
vector178:
  pushl $0
c0102577:	6a 00                	push   $0x0
  pushl $178
c0102579:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c010257e:	e9 0a f9 ff ff       	jmp    c0101e8d <__alltraps>

c0102583 <vector179>:
.globl vector179
vector179:
  pushl $0
c0102583:	6a 00                	push   $0x0
  pushl $179
c0102585:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c010258a:	e9 fe f8 ff ff       	jmp    c0101e8d <__alltraps>

c010258f <vector180>:
.globl vector180
vector180:
  pushl $0
c010258f:	6a 00                	push   $0x0
  pushl $180
c0102591:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c0102596:	e9 f2 f8 ff ff       	jmp    c0101e8d <__alltraps>

c010259b <vector181>:
.globl vector181
vector181:
  pushl $0
c010259b:	6a 00                	push   $0x0
  pushl $181
c010259d:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c01025a2:	e9 e6 f8 ff ff       	jmp    c0101e8d <__alltraps>

c01025a7 <vector182>:
.globl vector182
vector182:
  pushl $0
c01025a7:	6a 00                	push   $0x0
  pushl $182
c01025a9:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c01025ae:	e9 da f8 ff ff       	jmp    c0101e8d <__alltraps>

c01025b3 <vector183>:
.globl vector183
vector183:
  pushl $0
c01025b3:	6a 00                	push   $0x0
  pushl $183
c01025b5:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c01025ba:	e9 ce f8 ff ff       	jmp    c0101e8d <__alltraps>

c01025bf <vector184>:
.globl vector184
vector184:
  pushl $0
c01025bf:	6a 00                	push   $0x0
  pushl $184
c01025c1:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c01025c6:	e9 c2 f8 ff ff       	jmp    c0101e8d <__alltraps>

c01025cb <vector185>:
.globl vector185
vector185:
  pushl $0
c01025cb:	6a 00                	push   $0x0
  pushl $185
c01025cd:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c01025d2:	e9 b6 f8 ff ff       	jmp    c0101e8d <__alltraps>

c01025d7 <vector186>:
.globl vector186
vector186:
  pushl $0
c01025d7:	6a 00                	push   $0x0
  pushl $186
c01025d9:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c01025de:	e9 aa f8 ff ff       	jmp    c0101e8d <__alltraps>

c01025e3 <vector187>:
.globl vector187
vector187:
  pushl $0
c01025e3:	6a 00                	push   $0x0
  pushl $187
c01025e5:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c01025ea:	e9 9e f8 ff ff       	jmp    c0101e8d <__alltraps>

c01025ef <vector188>:
.globl vector188
vector188:
  pushl $0
c01025ef:	6a 00                	push   $0x0
  pushl $188
c01025f1:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c01025f6:	e9 92 f8 ff ff       	jmp    c0101e8d <__alltraps>

c01025fb <vector189>:
.globl vector189
vector189:
  pushl $0
c01025fb:	6a 00                	push   $0x0
  pushl $189
c01025fd:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c0102602:	e9 86 f8 ff ff       	jmp    c0101e8d <__alltraps>

c0102607 <vector190>:
.globl vector190
vector190:
  pushl $0
c0102607:	6a 00                	push   $0x0
  pushl $190
c0102609:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c010260e:	e9 7a f8 ff ff       	jmp    c0101e8d <__alltraps>

c0102613 <vector191>:
.globl vector191
vector191:
  pushl $0
c0102613:	6a 00                	push   $0x0
  pushl $191
c0102615:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c010261a:	e9 6e f8 ff ff       	jmp    c0101e8d <__alltraps>

c010261f <vector192>:
.globl vector192
vector192:
  pushl $0
c010261f:	6a 00                	push   $0x0
  pushl $192
c0102621:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c0102626:	e9 62 f8 ff ff       	jmp    c0101e8d <__alltraps>

c010262b <vector193>:
.globl vector193
vector193:
  pushl $0
c010262b:	6a 00                	push   $0x0
  pushl $193
c010262d:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c0102632:	e9 56 f8 ff ff       	jmp    c0101e8d <__alltraps>

c0102637 <vector194>:
.globl vector194
vector194:
  pushl $0
c0102637:	6a 00                	push   $0x0
  pushl $194
c0102639:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c010263e:	e9 4a f8 ff ff       	jmp    c0101e8d <__alltraps>

c0102643 <vector195>:
.globl vector195
vector195:
  pushl $0
c0102643:	6a 00                	push   $0x0
  pushl $195
c0102645:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c010264a:	e9 3e f8 ff ff       	jmp    c0101e8d <__alltraps>

c010264f <vector196>:
.globl vector196
vector196:
  pushl $0
c010264f:	6a 00                	push   $0x0
  pushl $196
c0102651:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c0102656:	e9 32 f8 ff ff       	jmp    c0101e8d <__alltraps>

c010265b <vector197>:
.globl vector197
vector197:
  pushl $0
c010265b:	6a 00                	push   $0x0
  pushl $197
c010265d:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c0102662:	e9 26 f8 ff ff       	jmp    c0101e8d <__alltraps>

c0102667 <vector198>:
.globl vector198
vector198:
  pushl $0
c0102667:	6a 00                	push   $0x0
  pushl $198
c0102669:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c010266e:	e9 1a f8 ff ff       	jmp    c0101e8d <__alltraps>

c0102673 <vector199>:
.globl vector199
vector199:
  pushl $0
c0102673:	6a 00                	push   $0x0
  pushl $199
c0102675:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c010267a:	e9 0e f8 ff ff       	jmp    c0101e8d <__alltraps>

c010267f <vector200>:
.globl vector200
vector200:
  pushl $0
c010267f:	6a 00                	push   $0x0
  pushl $200
c0102681:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c0102686:	e9 02 f8 ff ff       	jmp    c0101e8d <__alltraps>

c010268b <vector201>:
.globl vector201
vector201:
  pushl $0
c010268b:	6a 00                	push   $0x0
  pushl $201
c010268d:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c0102692:	e9 f6 f7 ff ff       	jmp    c0101e8d <__alltraps>

c0102697 <vector202>:
.globl vector202
vector202:
  pushl $0
c0102697:	6a 00                	push   $0x0
  pushl $202
c0102699:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c010269e:	e9 ea f7 ff ff       	jmp    c0101e8d <__alltraps>

c01026a3 <vector203>:
.globl vector203
vector203:
  pushl $0
c01026a3:	6a 00                	push   $0x0
  pushl $203
c01026a5:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c01026aa:	e9 de f7 ff ff       	jmp    c0101e8d <__alltraps>

c01026af <vector204>:
.globl vector204
vector204:
  pushl $0
c01026af:	6a 00                	push   $0x0
  pushl $204
c01026b1:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c01026b6:	e9 d2 f7 ff ff       	jmp    c0101e8d <__alltraps>

c01026bb <vector205>:
.globl vector205
vector205:
  pushl $0
c01026bb:	6a 00                	push   $0x0
  pushl $205
c01026bd:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c01026c2:	e9 c6 f7 ff ff       	jmp    c0101e8d <__alltraps>

c01026c7 <vector206>:
.globl vector206
vector206:
  pushl $0
c01026c7:	6a 00                	push   $0x0
  pushl $206
c01026c9:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c01026ce:	e9 ba f7 ff ff       	jmp    c0101e8d <__alltraps>

c01026d3 <vector207>:
.globl vector207
vector207:
  pushl $0
c01026d3:	6a 00                	push   $0x0
  pushl $207
c01026d5:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c01026da:	e9 ae f7 ff ff       	jmp    c0101e8d <__alltraps>

c01026df <vector208>:
.globl vector208
vector208:
  pushl $0
c01026df:	6a 00                	push   $0x0
  pushl $208
c01026e1:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c01026e6:	e9 a2 f7 ff ff       	jmp    c0101e8d <__alltraps>

c01026eb <vector209>:
.globl vector209
vector209:
  pushl $0
c01026eb:	6a 00                	push   $0x0
  pushl $209
c01026ed:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c01026f2:	e9 96 f7 ff ff       	jmp    c0101e8d <__alltraps>

c01026f7 <vector210>:
.globl vector210
vector210:
  pushl $0
c01026f7:	6a 00                	push   $0x0
  pushl $210
c01026f9:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c01026fe:	e9 8a f7 ff ff       	jmp    c0101e8d <__alltraps>

c0102703 <vector211>:
.globl vector211
vector211:
  pushl $0
c0102703:	6a 00                	push   $0x0
  pushl $211
c0102705:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c010270a:	e9 7e f7 ff ff       	jmp    c0101e8d <__alltraps>

c010270f <vector212>:
.globl vector212
vector212:
  pushl $0
c010270f:	6a 00                	push   $0x0
  pushl $212
c0102711:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c0102716:	e9 72 f7 ff ff       	jmp    c0101e8d <__alltraps>

c010271b <vector213>:
.globl vector213
vector213:
  pushl $0
c010271b:	6a 00                	push   $0x0
  pushl $213
c010271d:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c0102722:	e9 66 f7 ff ff       	jmp    c0101e8d <__alltraps>

c0102727 <vector214>:
.globl vector214
vector214:
  pushl $0
c0102727:	6a 00                	push   $0x0
  pushl $214
c0102729:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c010272e:	e9 5a f7 ff ff       	jmp    c0101e8d <__alltraps>

c0102733 <vector215>:
.globl vector215
vector215:
  pushl $0
c0102733:	6a 00                	push   $0x0
  pushl $215
c0102735:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c010273a:	e9 4e f7 ff ff       	jmp    c0101e8d <__alltraps>

c010273f <vector216>:
.globl vector216
vector216:
  pushl $0
c010273f:	6a 00                	push   $0x0
  pushl $216
c0102741:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c0102746:	e9 42 f7 ff ff       	jmp    c0101e8d <__alltraps>

c010274b <vector217>:
.globl vector217
vector217:
  pushl $0
c010274b:	6a 00                	push   $0x0
  pushl $217
c010274d:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c0102752:	e9 36 f7 ff ff       	jmp    c0101e8d <__alltraps>

c0102757 <vector218>:
.globl vector218
vector218:
  pushl $0
c0102757:	6a 00                	push   $0x0
  pushl $218
c0102759:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c010275e:	e9 2a f7 ff ff       	jmp    c0101e8d <__alltraps>

c0102763 <vector219>:
.globl vector219
vector219:
  pushl $0
c0102763:	6a 00                	push   $0x0
  pushl $219
c0102765:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c010276a:	e9 1e f7 ff ff       	jmp    c0101e8d <__alltraps>

c010276f <vector220>:
.globl vector220
vector220:
  pushl $0
c010276f:	6a 00                	push   $0x0
  pushl $220
c0102771:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c0102776:	e9 12 f7 ff ff       	jmp    c0101e8d <__alltraps>

c010277b <vector221>:
.globl vector221
vector221:
  pushl $0
c010277b:	6a 00                	push   $0x0
  pushl $221
c010277d:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c0102782:	e9 06 f7 ff ff       	jmp    c0101e8d <__alltraps>

c0102787 <vector222>:
.globl vector222
vector222:
  pushl $0
c0102787:	6a 00                	push   $0x0
  pushl $222
c0102789:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c010278e:	e9 fa f6 ff ff       	jmp    c0101e8d <__alltraps>

c0102793 <vector223>:
.globl vector223
vector223:
  pushl $0
c0102793:	6a 00                	push   $0x0
  pushl $223
c0102795:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c010279a:	e9 ee f6 ff ff       	jmp    c0101e8d <__alltraps>

c010279f <vector224>:
.globl vector224
vector224:
  pushl $0
c010279f:	6a 00                	push   $0x0
  pushl $224
c01027a1:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c01027a6:	e9 e2 f6 ff ff       	jmp    c0101e8d <__alltraps>

c01027ab <vector225>:
.globl vector225
vector225:
  pushl $0
c01027ab:	6a 00                	push   $0x0
  pushl $225
c01027ad:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c01027b2:	e9 d6 f6 ff ff       	jmp    c0101e8d <__alltraps>

c01027b7 <vector226>:
.globl vector226
vector226:
  pushl $0
c01027b7:	6a 00                	push   $0x0
  pushl $226
c01027b9:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c01027be:	e9 ca f6 ff ff       	jmp    c0101e8d <__alltraps>

c01027c3 <vector227>:
.globl vector227
vector227:
  pushl $0
c01027c3:	6a 00                	push   $0x0
  pushl $227
c01027c5:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c01027ca:	e9 be f6 ff ff       	jmp    c0101e8d <__alltraps>

c01027cf <vector228>:
.globl vector228
vector228:
  pushl $0
c01027cf:	6a 00                	push   $0x0
  pushl $228
c01027d1:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c01027d6:	e9 b2 f6 ff ff       	jmp    c0101e8d <__alltraps>

c01027db <vector229>:
.globl vector229
vector229:
  pushl $0
c01027db:	6a 00                	push   $0x0
  pushl $229
c01027dd:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c01027e2:	e9 a6 f6 ff ff       	jmp    c0101e8d <__alltraps>

c01027e7 <vector230>:
.globl vector230
vector230:
  pushl $0
c01027e7:	6a 00                	push   $0x0
  pushl $230
c01027e9:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c01027ee:	e9 9a f6 ff ff       	jmp    c0101e8d <__alltraps>

c01027f3 <vector231>:
.globl vector231
vector231:
  pushl $0
c01027f3:	6a 00                	push   $0x0
  pushl $231
c01027f5:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c01027fa:	e9 8e f6 ff ff       	jmp    c0101e8d <__alltraps>

c01027ff <vector232>:
.globl vector232
vector232:
  pushl $0
c01027ff:	6a 00                	push   $0x0
  pushl $232
c0102801:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c0102806:	e9 82 f6 ff ff       	jmp    c0101e8d <__alltraps>

c010280b <vector233>:
.globl vector233
vector233:
  pushl $0
c010280b:	6a 00                	push   $0x0
  pushl $233
c010280d:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c0102812:	e9 76 f6 ff ff       	jmp    c0101e8d <__alltraps>

c0102817 <vector234>:
.globl vector234
vector234:
  pushl $0
c0102817:	6a 00                	push   $0x0
  pushl $234
c0102819:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c010281e:	e9 6a f6 ff ff       	jmp    c0101e8d <__alltraps>

c0102823 <vector235>:
.globl vector235
vector235:
  pushl $0
c0102823:	6a 00                	push   $0x0
  pushl $235
c0102825:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c010282a:	e9 5e f6 ff ff       	jmp    c0101e8d <__alltraps>

c010282f <vector236>:
.globl vector236
vector236:
  pushl $0
c010282f:	6a 00                	push   $0x0
  pushl $236
c0102831:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c0102836:	e9 52 f6 ff ff       	jmp    c0101e8d <__alltraps>

c010283b <vector237>:
.globl vector237
vector237:
  pushl $0
c010283b:	6a 00                	push   $0x0
  pushl $237
c010283d:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c0102842:	e9 46 f6 ff ff       	jmp    c0101e8d <__alltraps>

c0102847 <vector238>:
.globl vector238
vector238:
  pushl $0
c0102847:	6a 00                	push   $0x0
  pushl $238
c0102849:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c010284e:	e9 3a f6 ff ff       	jmp    c0101e8d <__alltraps>

c0102853 <vector239>:
.globl vector239
vector239:
  pushl $0
c0102853:	6a 00                	push   $0x0
  pushl $239
c0102855:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c010285a:	e9 2e f6 ff ff       	jmp    c0101e8d <__alltraps>

c010285f <vector240>:
.globl vector240
vector240:
  pushl $0
c010285f:	6a 00                	push   $0x0
  pushl $240
c0102861:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c0102866:	e9 22 f6 ff ff       	jmp    c0101e8d <__alltraps>

c010286b <vector241>:
.globl vector241
vector241:
  pushl $0
c010286b:	6a 00                	push   $0x0
  pushl $241
c010286d:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c0102872:	e9 16 f6 ff ff       	jmp    c0101e8d <__alltraps>

c0102877 <vector242>:
.globl vector242
vector242:
  pushl $0
c0102877:	6a 00                	push   $0x0
  pushl $242
c0102879:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c010287e:	e9 0a f6 ff ff       	jmp    c0101e8d <__alltraps>

c0102883 <vector243>:
.globl vector243
vector243:
  pushl $0
c0102883:	6a 00                	push   $0x0
  pushl $243
c0102885:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c010288a:	e9 fe f5 ff ff       	jmp    c0101e8d <__alltraps>

c010288f <vector244>:
.globl vector244
vector244:
  pushl $0
c010288f:	6a 00                	push   $0x0
  pushl $244
c0102891:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c0102896:	e9 f2 f5 ff ff       	jmp    c0101e8d <__alltraps>

c010289b <vector245>:
.globl vector245
vector245:
  pushl $0
c010289b:	6a 00                	push   $0x0
  pushl $245
c010289d:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c01028a2:	e9 e6 f5 ff ff       	jmp    c0101e8d <__alltraps>

c01028a7 <vector246>:
.globl vector246
vector246:
  pushl $0
c01028a7:	6a 00                	push   $0x0
  pushl $246
c01028a9:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c01028ae:	e9 da f5 ff ff       	jmp    c0101e8d <__alltraps>

c01028b3 <vector247>:
.globl vector247
vector247:
  pushl $0
c01028b3:	6a 00                	push   $0x0
  pushl $247
c01028b5:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c01028ba:	e9 ce f5 ff ff       	jmp    c0101e8d <__alltraps>

c01028bf <vector248>:
.globl vector248
vector248:
  pushl $0
c01028bf:	6a 00                	push   $0x0
  pushl $248
c01028c1:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c01028c6:	e9 c2 f5 ff ff       	jmp    c0101e8d <__alltraps>

c01028cb <vector249>:
.globl vector249
vector249:
  pushl $0
c01028cb:	6a 00                	push   $0x0
  pushl $249
c01028cd:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c01028d2:	e9 b6 f5 ff ff       	jmp    c0101e8d <__alltraps>

c01028d7 <vector250>:
.globl vector250
vector250:
  pushl $0
c01028d7:	6a 00                	push   $0x0
  pushl $250
c01028d9:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c01028de:	e9 aa f5 ff ff       	jmp    c0101e8d <__alltraps>

c01028e3 <vector251>:
.globl vector251
vector251:
  pushl $0
c01028e3:	6a 00                	push   $0x0
  pushl $251
c01028e5:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c01028ea:	e9 9e f5 ff ff       	jmp    c0101e8d <__alltraps>

c01028ef <vector252>:
.globl vector252
vector252:
  pushl $0
c01028ef:	6a 00                	push   $0x0
  pushl $252
c01028f1:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c01028f6:	e9 92 f5 ff ff       	jmp    c0101e8d <__alltraps>

c01028fb <vector253>:
.globl vector253
vector253:
  pushl $0
c01028fb:	6a 00                	push   $0x0
  pushl $253
c01028fd:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c0102902:	e9 86 f5 ff ff       	jmp    c0101e8d <__alltraps>

c0102907 <vector254>:
.globl vector254
vector254:
  pushl $0
c0102907:	6a 00                	push   $0x0
  pushl $254
c0102909:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c010290e:	e9 7a f5 ff ff       	jmp    c0101e8d <__alltraps>

c0102913 <vector255>:
.globl vector255
vector255:
  pushl $0
c0102913:	6a 00                	push   $0x0
  pushl $255
c0102915:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c010291a:	e9 6e f5 ff ff       	jmp    c0101e8d <__alltraps>

c010291f <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c010291f:	55                   	push   %ebp
c0102920:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0102922:	8b 55 08             	mov    0x8(%ebp),%edx
c0102925:	a1 c4 89 11 c0       	mov    0xc01189c4,%eax
c010292a:	29 c2                	sub    %eax,%edx
c010292c:	89 d0                	mov    %edx,%eax
c010292e:	c1 f8 02             	sar    $0x2,%eax
c0102931:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c0102937:	5d                   	pop    %ebp
c0102938:	c3                   	ret    

c0102939 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0102939:	55                   	push   %ebp
c010293a:	89 e5                	mov    %esp,%ebp
c010293c:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c010293f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102942:	89 04 24             	mov    %eax,(%esp)
c0102945:	e8 d5 ff ff ff       	call   c010291f <page2ppn>
c010294a:	c1 e0 0c             	shl    $0xc,%eax
}
c010294d:	c9                   	leave  
c010294e:	c3                   	ret    

c010294f <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
c010294f:	55                   	push   %ebp
c0102950:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0102952:	8b 45 08             	mov    0x8(%ebp),%eax
c0102955:	8b 00                	mov    (%eax),%eax
}
c0102957:	5d                   	pop    %ebp
c0102958:	c3                   	ret    

c0102959 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0102959:	55                   	push   %ebp
c010295a:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c010295c:	8b 45 08             	mov    0x8(%ebp),%eax
c010295f:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102962:	89 10                	mov    %edx,(%eax)
}
c0102964:	5d                   	pop    %ebp
c0102965:	c3                   	ret    

c0102966 <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c0102966:	55                   	push   %ebp
c0102967:	89 e5                	mov    %esp,%ebp
c0102969:	83 ec 10             	sub    $0x10,%esp
c010296c:	c7 45 fc b0 89 11 c0 	movl   $0xc01189b0,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0102973:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102976:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0102979:	89 50 04             	mov    %edx,0x4(%eax)
c010297c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010297f:	8b 50 04             	mov    0x4(%eax),%edx
c0102982:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102985:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
c0102987:	c7 05 b8 89 11 c0 00 	movl   $0x0,0xc01189b8
c010298e:	00 00 00 
}
c0102991:	c9                   	leave  
c0102992:	c3                   	ret    

c0102993 <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
c0102993:	55                   	push   %ebp
c0102994:	89 e5                	mov    %esp,%ebp
c0102996:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
c0102999:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010299d:	75 24                	jne    c01029c3 <default_init_memmap+0x30>
c010299f:	c7 44 24 0c f0 66 10 	movl   $0xc01066f0,0xc(%esp)
c01029a6:	c0 
c01029a7:	c7 44 24 08 f6 66 10 	movl   $0xc01066f6,0x8(%esp)
c01029ae:	c0 
c01029af:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
c01029b6:	00 
c01029b7:	c7 04 24 0b 67 10 c0 	movl   $0xc010670b,(%esp)
c01029be:	e8 0e e3 ff ff       	call   c0100cd1 <__panic>
    struct Page *p = base;
c01029c3:	8b 45 08             	mov    0x8(%ebp),%eax
c01029c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c01029c9:	e9 dc 00 00 00       	jmp    c0102aaa <default_init_memmap+0x117>
        assert(PageReserved(p));
c01029ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01029d1:	83 c0 04             	add    $0x4,%eax
c01029d4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c01029db:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01029de:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01029e1:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01029e4:	0f a3 10             	bt     %edx,(%eax)
c01029e7:	19 c0                	sbb    %eax,%eax
c01029e9:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c01029ec:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01029f0:	0f 95 c0             	setne  %al
c01029f3:	0f b6 c0             	movzbl %al,%eax
c01029f6:	85 c0                	test   %eax,%eax
c01029f8:	75 24                	jne    c0102a1e <default_init_memmap+0x8b>
c01029fa:	c7 44 24 0c 21 67 10 	movl   $0xc0106721,0xc(%esp)
c0102a01:	c0 
c0102a02:	c7 44 24 08 f6 66 10 	movl   $0xc01066f6,0x8(%esp)
c0102a09:	c0 
c0102a0a:	c7 44 24 04 49 00 00 	movl   $0x49,0x4(%esp)
c0102a11:	00 
c0102a12:	c7 04 24 0b 67 10 c0 	movl   $0xc010670b,(%esp)
c0102a19:	e8 b3 e2 ff ff       	call   c0100cd1 <__panic>
        p->flags = 0;
c0102a1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102a21:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        SetPageProperty(p);
c0102a28:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102a2b:	83 c0 04             	add    $0x4,%eax
c0102a2e:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
c0102a35:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102a38:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102a3b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0102a3e:	0f ab 10             	bts    %edx,(%eax)
        p->property = 0;
c0102a41:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102a44:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        set_page_ref(p, 0);
c0102a4b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0102a52:	00 
c0102a53:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102a56:	89 04 24             	mov    %eax,(%esp)
c0102a59:	e8 fb fe ff ff       	call   c0102959 <set_page_ref>
        list_add_before(&free_list, &(p->page_link));
c0102a5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102a61:	83 c0 0c             	add    $0xc,%eax
c0102a64:	c7 45 dc b0 89 11 c0 	movl   $0xc01189b0,-0x24(%ebp)
c0102a6b:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c0102a6e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0102a71:	8b 00                	mov    (%eax),%eax
c0102a73:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0102a76:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0102a79:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0102a7c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0102a7f:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0102a82:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0102a85:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0102a88:	89 10                	mov    %edx,(%eax)
c0102a8a:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0102a8d:	8b 10                	mov    (%eax),%edx
c0102a8f:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102a92:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0102a95:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0102a98:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0102a9b:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0102a9e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0102aa1:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0102aa4:	89 10                	mov    %edx,(%eax)

static void
default_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
c0102aa6:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c0102aaa:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102aad:	89 d0                	mov    %edx,%eax
c0102aaf:	c1 e0 02             	shl    $0x2,%eax
c0102ab2:	01 d0                	add    %edx,%eax
c0102ab4:	c1 e0 02             	shl    $0x2,%eax
c0102ab7:	89 c2                	mov    %eax,%edx
c0102ab9:	8b 45 08             	mov    0x8(%ebp),%eax
c0102abc:	01 d0                	add    %edx,%eax
c0102abe:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0102ac1:	0f 85 07 ff ff ff    	jne    c01029ce <default_init_memmap+0x3b>
        SetPageProperty(p);
        p->property = 0;
        set_page_ref(p, 0);
        list_add_before(&free_list, &(p->page_link));
    }
    nr_free += n;
c0102ac7:	8b 15 b8 89 11 c0    	mov    0xc01189b8,%edx
c0102acd:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102ad0:	01 d0                	add    %edx,%eax
c0102ad2:	a3 b8 89 11 c0       	mov    %eax,0xc01189b8
    //first block
    base->property = n;
c0102ad7:	8b 45 08             	mov    0x8(%ebp),%eax
c0102ada:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102add:	89 50 08             	mov    %edx,0x8(%eax)
}
c0102ae0:	c9                   	leave  
c0102ae1:	c3                   	ret    

c0102ae2 <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
c0102ae2:	55                   	push   %ebp
c0102ae3:	89 e5                	mov    %esp,%ebp
c0102ae5:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
c0102ae8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0102aec:	75 24                	jne    c0102b12 <default_alloc_pages+0x30>
c0102aee:	c7 44 24 0c f0 66 10 	movl   $0xc01066f0,0xc(%esp)
c0102af5:	c0 
c0102af6:	c7 44 24 08 f6 66 10 	movl   $0xc01066f6,0x8(%esp)
c0102afd:	c0 
c0102afe:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
c0102b05:	00 
c0102b06:	c7 04 24 0b 67 10 c0 	movl   $0xc010670b,(%esp)
c0102b0d:	e8 bf e1 ff ff       	call   c0100cd1 <__panic>
    if (n > nr_free) {
c0102b12:	a1 b8 89 11 c0       	mov    0xc01189b8,%eax
c0102b17:	3b 45 08             	cmp    0x8(%ebp),%eax
c0102b1a:	73 0a                	jae    c0102b26 <default_alloc_pages+0x44>
        return NULL;
c0102b1c:	b8 00 00 00 00       	mov    $0x0,%eax
c0102b21:	e9 37 01 00 00       	jmp    c0102c5d <default_alloc_pages+0x17b>
    }
    list_entry_t *le, *len;
    le = &free_list;
c0102b26:	c7 45 f4 b0 89 11 c0 	movl   $0xc01189b0,-0xc(%ebp)

    while((le=list_next(le)) != &free_list) {
c0102b2d:	e9 0a 01 00 00       	jmp    c0102c3c <default_alloc_pages+0x15a>
      struct Page *p = le2page(le, page_link);
c0102b32:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102b35:	83 e8 0c             	sub    $0xc,%eax
c0102b38:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(p->property >= n){
c0102b3b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102b3e:	8b 40 08             	mov    0x8(%eax),%eax
c0102b41:	3b 45 08             	cmp    0x8(%ebp),%eax
c0102b44:	0f 82 f2 00 00 00    	jb     c0102c3c <default_alloc_pages+0x15a>
        int i;
        for(i=0;i<n;i++){
c0102b4a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c0102b51:	eb 7c                	jmp    c0102bcf <default_alloc_pages+0xed>
c0102b53:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102b56:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0102b59:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102b5c:	8b 40 04             	mov    0x4(%eax),%eax
          len = list_next(le);
c0102b5f:	89 45 e8             	mov    %eax,-0x18(%ebp)
          struct Page *pp = le2page(le, page_link);
c0102b62:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102b65:	83 e8 0c             	sub    $0xc,%eax
c0102b68:	89 45 e4             	mov    %eax,-0x1c(%ebp)
          SetPageReserved(pp);
c0102b6b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0102b6e:	83 c0 04             	add    $0x4,%eax
c0102b71:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0102b78:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0102b7b:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0102b7e:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102b81:	0f ab 10             	bts    %edx,(%eax)
          ClearPageProperty(pp);
c0102b84:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0102b87:	83 c0 04             	add    $0x4,%eax
c0102b8a:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
c0102b91:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102b94:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102b97:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0102b9a:	0f b3 10             	btr    %edx,(%eax)
c0102b9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102ba0:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0102ba3:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0102ba6:	8b 40 04             	mov    0x4(%eax),%eax
c0102ba9:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0102bac:	8b 12                	mov    (%edx),%edx
c0102bae:	89 55 c8             	mov    %edx,-0x38(%ebp)
c0102bb1:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0102bb4:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0102bb7:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0102bba:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0102bbd:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0102bc0:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0102bc3:	89 10                	mov    %edx,(%eax)
          list_del(le);
          le = len;
c0102bc5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0102bc8:	89 45 f4             	mov    %eax,-0xc(%ebp)

    while((le=list_next(le)) != &free_list) {
      struct Page *p = le2page(le, page_link);
      if(p->property >= n){
        int i;
        for(i=0;i<n;i++){
c0102bcb:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
c0102bcf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102bd2:	3b 45 08             	cmp    0x8(%ebp),%eax
c0102bd5:	0f 82 78 ff ff ff    	jb     c0102b53 <default_alloc_pages+0x71>
          SetPageReserved(pp);
          ClearPageProperty(pp);
          list_del(le);
          le = len;
        }
        if(p->property>n){
c0102bdb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102bde:	8b 40 08             	mov    0x8(%eax),%eax
c0102be1:	3b 45 08             	cmp    0x8(%ebp),%eax
c0102be4:	76 12                	jbe    c0102bf8 <default_alloc_pages+0x116>
          (le2page(le,page_link))->property = p->property - n;
c0102be6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102be9:	8d 50 f4             	lea    -0xc(%eax),%edx
c0102bec:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102bef:	8b 40 08             	mov    0x8(%eax),%eax
c0102bf2:	2b 45 08             	sub    0x8(%ebp),%eax
c0102bf5:	89 42 08             	mov    %eax,0x8(%edx)
        }
        ClearPageProperty(p);
c0102bf8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102bfb:	83 c0 04             	add    $0x4,%eax
c0102bfe:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c0102c05:	89 45 bc             	mov    %eax,-0x44(%ebp)
c0102c08:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0102c0b:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0102c0e:	0f b3 10             	btr    %edx,(%eax)
        SetPageReserved(p);
c0102c11:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102c14:	83 c0 04             	add    $0x4,%eax
c0102c17:	c7 45 b8 00 00 00 00 	movl   $0x0,-0x48(%ebp)
c0102c1e:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102c21:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0102c24:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0102c27:	0f ab 10             	bts    %edx,(%eax)
        nr_free -= n;
c0102c2a:	a1 b8 89 11 c0       	mov    0xc01189b8,%eax
c0102c2f:	2b 45 08             	sub    0x8(%ebp),%eax
c0102c32:	a3 b8 89 11 c0       	mov    %eax,0xc01189b8
        return p;
c0102c37:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102c3a:	eb 21                	jmp    c0102c5d <default_alloc_pages+0x17b>
c0102c3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102c3f:	89 45 b0             	mov    %eax,-0x50(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0102c42:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0102c45:	8b 40 04             	mov    0x4(%eax),%eax
        return NULL;
    }
    list_entry_t *le, *len;
    le = &free_list;

    while((le=list_next(le)) != &free_list) {
c0102c48:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102c4b:	81 7d f4 b0 89 11 c0 	cmpl   $0xc01189b0,-0xc(%ebp)
c0102c52:	0f 85 da fe ff ff    	jne    c0102b32 <default_alloc_pages+0x50>
        SetPageReserved(p);
        nr_free -= n;
        return p;
      }
    }
    return NULL;
c0102c58:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0102c5d:	c9                   	leave  
c0102c5e:	c3                   	ret    

c0102c5f <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
c0102c5f:	55                   	push   %ebp
c0102c60:	89 e5                	mov    %esp,%ebp
c0102c62:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
c0102c65:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0102c69:	75 24                	jne    c0102c8f <default_free_pages+0x30>
c0102c6b:	c7 44 24 0c f0 66 10 	movl   $0xc01066f0,0xc(%esp)
c0102c72:	c0 
c0102c73:	c7 44 24 08 f6 66 10 	movl   $0xc01066f6,0x8(%esp)
c0102c7a:	c0 
c0102c7b:	c7 44 24 04 78 00 00 	movl   $0x78,0x4(%esp)
c0102c82:	00 
c0102c83:	c7 04 24 0b 67 10 c0 	movl   $0xc010670b,(%esp)
c0102c8a:	e8 42 e0 ff ff       	call   c0100cd1 <__panic>
    assert(PageReserved(base));
c0102c8f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102c92:	83 c0 04             	add    $0x4,%eax
c0102c95:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0102c9c:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0102c9f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0102ca2:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0102ca5:	0f a3 10             	bt     %edx,(%eax)
c0102ca8:	19 c0                	sbb    %eax,%eax
c0102caa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
c0102cad:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0102cb1:	0f 95 c0             	setne  %al
c0102cb4:	0f b6 c0             	movzbl %al,%eax
c0102cb7:	85 c0                	test   %eax,%eax
c0102cb9:	75 24                	jne    c0102cdf <default_free_pages+0x80>
c0102cbb:	c7 44 24 0c 31 67 10 	movl   $0xc0106731,0xc(%esp)
c0102cc2:	c0 
c0102cc3:	c7 44 24 08 f6 66 10 	movl   $0xc01066f6,0x8(%esp)
c0102cca:	c0 
c0102ccb:	c7 44 24 04 79 00 00 	movl   $0x79,0x4(%esp)
c0102cd2:	00 
c0102cd3:	c7 04 24 0b 67 10 c0 	movl   $0xc010670b,(%esp)
c0102cda:	e8 f2 df ff ff       	call   c0100cd1 <__panic>

    list_entry_t *le = &free_list;
c0102cdf:	c7 45 f4 b0 89 11 c0 	movl   $0xc01189b0,-0xc(%ebp)
    struct Page * p;
    while((le=list_next(le)) != &free_list) {
c0102ce6:	eb 13                	jmp    c0102cfb <default_free_pages+0x9c>
      p = le2page(le, page_link);
c0102ce8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102ceb:	83 e8 0c             	sub    $0xc,%eax
c0102cee:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(p>base){
c0102cf1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102cf4:	3b 45 08             	cmp    0x8(%ebp),%eax
c0102cf7:	76 02                	jbe    c0102cfb <default_free_pages+0x9c>
        break;
c0102cf9:	eb 18                	jmp    c0102d13 <default_free_pages+0xb4>
c0102cfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102cfe:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0102d01:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102d04:	8b 40 04             	mov    0x4(%eax),%eax
    assert(n > 0);
    assert(PageReserved(base));

    list_entry_t *le = &free_list;
    struct Page * p;
    while((le=list_next(le)) != &free_list) {
c0102d07:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102d0a:	81 7d f4 b0 89 11 c0 	cmpl   $0xc01189b0,-0xc(%ebp)
c0102d11:	75 d5                	jne    c0102ce8 <default_free_pages+0x89>
      if(p>base){
        break;
      }
    }
    //list_add_before(le, base->page_link);
    for(p=base;p<base+n;p++){
c0102d13:	8b 45 08             	mov    0x8(%ebp),%eax
c0102d16:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0102d19:	eb 4b                	jmp    c0102d66 <default_free_pages+0x107>
      list_add_before(le, &(p->page_link));
c0102d1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102d1e:	8d 50 0c             	lea    0xc(%eax),%edx
c0102d21:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102d24:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0102d27:	89 55 d8             	mov    %edx,-0x28(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c0102d2a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0102d2d:	8b 00                	mov    (%eax),%eax
c0102d2f:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0102d32:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0102d35:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0102d38:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0102d3b:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0102d3e:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0102d41:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0102d44:	89 10                	mov    %edx,(%eax)
c0102d46:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0102d49:	8b 10                	mov    (%eax),%edx
c0102d4b:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102d4e:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0102d51:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0102d54:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0102d57:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0102d5a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0102d5d:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0102d60:	89 10                	mov    %edx,(%eax)
      if(p>base){
        break;
      }
    }
    //list_add_before(le, base->page_link);
    for(p=base;p<base+n;p++){
c0102d62:	83 45 f0 14          	addl   $0x14,-0x10(%ebp)
c0102d66:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102d69:	89 d0                	mov    %edx,%eax
c0102d6b:	c1 e0 02             	shl    $0x2,%eax
c0102d6e:	01 d0                	add    %edx,%eax
c0102d70:	c1 e0 02             	shl    $0x2,%eax
c0102d73:	89 c2                	mov    %eax,%edx
c0102d75:	8b 45 08             	mov    0x8(%ebp),%eax
c0102d78:	01 d0                	add    %edx,%eax
c0102d7a:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0102d7d:	77 9c                	ja     c0102d1b <default_free_pages+0xbc>
      list_add_before(le, &(p->page_link));
    }
    base->flags = 0;
c0102d7f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102d82:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    set_page_ref(base, 0);
c0102d89:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0102d90:	00 
c0102d91:	8b 45 08             	mov    0x8(%ebp),%eax
c0102d94:	89 04 24             	mov    %eax,(%esp)
c0102d97:	e8 bd fb ff ff       	call   c0102959 <set_page_ref>
    ClearPageProperty(base);
c0102d9c:	8b 45 08             	mov    0x8(%ebp),%eax
c0102d9f:	83 c0 04             	add    $0x4,%eax
c0102da2:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
c0102da9:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102dac:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0102daf:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0102db2:	0f b3 10             	btr    %edx,(%eax)
    SetPageProperty(base);
c0102db5:	8b 45 08             	mov    0x8(%ebp),%eax
c0102db8:	83 c0 04             	add    $0x4,%eax
c0102dbb:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c0102dc2:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102dc5:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0102dc8:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0102dcb:	0f ab 10             	bts    %edx,(%eax)
    base->property = n;
c0102dce:	8b 45 08             	mov    0x8(%ebp),%eax
c0102dd1:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102dd4:	89 50 08             	mov    %edx,0x8(%eax)
    
    p = le2page(le,page_link) ;
c0102dd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102dda:	83 e8 0c             	sub    $0xc,%eax
c0102ddd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if( base+n == p ){
c0102de0:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102de3:	89 d0                	mov    %edx,%eax
c0102de5:	c1 e0 02             	shl    $0x2,%eax
c0102de8:	01 d0                	add    %edx,%eax
c0102dea:	c1 e0 02             	shl    $0x2,%eax
c0102ded:	89 c2                	mov    %eax,%edx
c0102def:	8b 45 08             	mov    0x8(%ebp),%eax
c0102df2:	01 d0                	add    %edx,%eax
c0102df4:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0102df7:	75 1e                	jne    c0102e17 <default_free_pages+0x1b8>
      base->property += p->property;
c0102df9:	8b 45 08             	mov    0x8(%ebp),%eax
c0102dfc:	8b 50 08             	mov    0x8(%eax),%edx
c0102dff:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102e02:	8b 40 08             	mov    0x8(%eax),%eax
c0102e05:	01 c2                	add    %eax,%edx
c0102e07:	8b 45 08             	mov    0x8(%ebp),%eax
c0102e0a:	89 50 08             	mov    %edx,0x8(%eax)
      p->property = 0;
c0102e0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102e10:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    }
    le = list_prev(&(base->page_link));
c0102e17:	8b 45 08             	mov    0x8(%ebp),%eax
c0102e1a:	83 c0 0c             	add    $0xc,%eax
c0102e1d:	89 45 b8             	mov    %eax,-0x48(%ebp)
 * list_prev - get the previous entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_prev(list_entry_t *listelm) {
    return listelm->prev;
c0102e20:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0102e23:	8b 00                	mov    (%eax),%eax
c0102e25:	89 45 f4             	mov    %eax,-0xc(%ebp)
    p = le2page(le, page_link);
c0102e28:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102e2b:	83 e8 0c             	sub    $0xc,%eax
c0102e2e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(le!=&free_list && p==base-1){
c0102e31:	81 7d f4 b0 89 11 c0 	cmpl   $0xc01189b0,-0xc(%ebp)
c0102e38:	74 57                	je     c0102e91 <default_free_pages+0x232>
c0102e3a:	8b 45 08             	mov    0x8(%ebp),%eax
c0102e3d:	83 e8 14             	sub    $0x14,%eax
c0102e40:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0102e43:	75 4c                	jne    c0102e91 <default_free_pages+0x232>
      while(le!=&free_list){
c0102e45:	eb 41                	jmp    c0102e88 <default_free_pages+0x229>
        if(p->property){
c0102e47:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102e4a:	8b 40 08             	mov    0x8(%eax),%eax
c0102e4d:	85 c0                	test   %eax,%eax
c0102e4f:	74 20                	je     c0102e71 <default_free_pages+0x212>
          p->property += base->property;
c0102e51:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102e54:	8b 50 08             	mov    0x8(%eax),%edx
c0102e57:	8b 45 08             	mov    0x8(%ebp),%eax
c0102e5a:	8b 40 08             	mov    0x8(%eax),%eax
c0102e5d:	01 c2                	add    %eax,%edx
c0102e5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102e62:	89 50 08             	mov    %edx,0x8(%eax)
          base->property = 0;
c0102e65:	8b 45 08             	mov    0x8(%ebp),%eax
c0102e68:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
          break;
c0102e6f:	eb 20                	jmp    c0102e91 <default_free_pages+0x232>
c0102e71:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102e74:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c0102e77:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0102e7a:	8b 00                	mov    (%eax),%eax
        }
        le = list_prev(le);
c0102e7c:	89 45 f4             	mov    %eax,-0xc(%ebp)
        p = le2page(le,page_link);
c0102e7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102e82:	83 e8 0c             	sub    $0xc,%eax
c0102e85:	89 45 f0             	mov    %eax,-0x10(%ebp)
      p->property = 0;
    }
    le = list_prev(&(base->page_link));
    p = le2page(le, page_link);
    if(le!=&free_list && p==base-1){
      while(le!=&free_list){
c0102e88:	81 7d f4 b0 89 11 c0 	cmpl   $0xc01189b0,-0xc(%ebp)
c0102e8f:	75 b6                	jne    c0102e47 <default_free_pages+0x1e8>
        le = list_prev(le);
        p = le2page(le,page_link);
      }
    }

    nr_free += n;
c0102e91:	8b 15 b8 89 11 c0    	mov    0xc01189b8,%edx
c0102e97:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102e9a:	01 d0                	add    %edx,%eax
c0102e9c:	a3 b8 89 11 c0       	mov    %eax,0xc01189b8
    return ;
c0102ea1:	90                   	nop
}
c0102ea2:	c9                   	leave  
c0102ea3:	c3                   	ret    

c0102ea4 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
c0102ea4:	55                   	push   %ebp
c0102ea5:	89 e5                	mov    %esp,%ebp
    return nr_free;
c0102ea7:	a1 b8 89 11 c0       	mov    0xc01189b8,%eax
}
c0102eac:	5d                   	pop    %ebp
c0102ead:	c3                   	ret    

c0102eae <basic_check>:

static void
basic_check(void) {
c0102eae:	55                   	push   %ebp
c0102eaf:	89 e5                	mov    %esp,%ebp
c0102eb1:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c0102eb4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0102ebb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102ebe:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0102ec1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102ec4:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c0102ec7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0102ece:	e8 85 0e 00 00       	call   c0103d58 <alloc_pages>
c0102ed3:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0102ed6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0102eda:	75 24                	jne    c0102f00 <basic_check+0x52>
c0102edc:	c7 44 24 0c 44 67 10 	movl   $0xc0106744,0xc(%esp)
c0102ee3:	c0 
c0102ee4:	c7 44 24 08 f6 66 10 	movl   $0xc01066f6,0x8(%esp)
c0102eeb:	c0 
c0102eec:	c7 44 24 04 ad 00 00 	movl   $0xad,0x4(%esp)
c0102ef3:	00 
c0102ef4:	c7 04 24 0b 67 10 c0 	movl   $0xc010670b,(%esp)
c0102efb:	e8 d1 dd ff ff       	call   c0100cd1 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0102f00:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0102f07:	e8 4c 0e 00 00       	call   c0103d58 <alloc_pages>
c0102f0c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0102f0f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0102f13:	75 24                	jne    c0102f39 <basic_check+0x8b>
c0102f15:	c7 44 24 0c 60 67 10 	movl   $0xc0106760,0xc(%esp)
c0102f1c:	c0 
c0102f1d:	c7 44 24 08 f6 66 10 	movl   $0xc01066f6,0x8(%esp)
c0102f24:	c0 
c0102f25:	c7 44 24 04 ae 00 00 	movl   $0xae,0x4(%esp)
c0102f2c:	00 
c0102f2d:	c7 04 24 0b 67 10 c0 	movl   $0xc010670b,(%esp)
c0102f34:	e8 98 dd ff ff       	call   c0100cd1 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0102f39:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0102f40:	e8 13 0e 00 00       	call   c0103d58 <alloc_pages>
c0102f45:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102f48:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0102f4c:	75 24                	jne    c0102f72 <basic_check+0xc4>
c0102f4e:	c7 44 24 0c 7c 67 10 	movl   $0xc010677c,0xc(%esp)
c0102f55:	c0 
c0102f56:	c7 44 24 08 f6 66 10 	movl   $0xc01066f6,0x8(%esp)
c0102f5d:	c0 
c0102f5e:	c7 44 24 04 af 00 00 	movl   $0xaf,0x4(%esp)
c0102f65:	00 
c0102f66:	c7 04 24 0b 67 10 c0 	movl   $0xc010670b,(%esp)
c0102f6d:	e8 5f dd ff ff       	call   c0100cd1 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c0102f72:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102f75:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0102f78:	74 10                	je     c0102f8a <basic_check+0xdc>
c0102f7a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102f7d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0102f80:	74 08                	je     c0102f8a <basic_check+0xdc>
c0102f82:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102f85:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0102f88:	75 24                	jne    c0102fae <basic_check+0x100>
c0102f8a:	c7 44 24 0c 98 67 10 	movl   $0xc0106798,0xc(%esp)
c0102f91:	c0 
c0102f92:	c7 44 24 08 f6 66 10 	movl   $0xc01066f6,0x8(%esp)
c0102f99:	c0 
c0102f9a:	c7 44 24 04 b1 00 00 	movl   $0xb1,0x4(%esp)
c0102fa1:	00 
c0102fa2:	c7 04 24 0b 67 10 c0 	movl   $0xc010670b,(%esp)
c0102fa9:	e8 23 dd ff ff       	call   c0100cd1 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c0102fae:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102fb1:	89 04 24             	mov    %eax,(%esp)
c0102fb4:	e8 96 f9 ff ff       	call   c010294f <page_ref>
c0102fb9:	85 c0                	test   %eax,%eax
c0102fbb:	75 1e                	jne    c0102fdb <basic_check+0x12d>
c0102fbd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102fc0:	89 04 24             	mov    %eax,(%esp)
c0102fc3:	e8 87 f9 ff ff       	call   c010294f <page_ref>
c0102fc8:	85 c0                	test   %eax,%eax
c0102fca:	75 0f                	jne    c0102fdb <basic_check+0x12d>
c0102fcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102fcf:	89 04 24             	mov    %eax,(%esp)
c0102fd2:	e8 78 f9 ff ff       	call   c010294f <page_ref>
c0102fd7:	85 c0                	test   %eax,%eax
c0102fd9:	74 24                	je     c0102fff <basic_check+0x151>
c0102fdb:	c7 44 24 0c bc 67 10 	movl   $0xc01067bc,0xc(%esp)
c0102fe2:	c0 
c0102fe3:	c7 44 24 08 f6 66 10 	movl   $0xc01066f6,0x8(%esp)
c0102fea:	c0 
c0102feb:	c7 44 24 04 b2 00 00 	movl   $0xb2,0x4(%esp)
c0102ff2:	00 
c0102ff3:	c7 04 24 0b 67 10 c0 	movl   $0xc010670b,(%esp)
c0102ffa:	e8 d2 dc ff ff       	call   c0100cd1 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c0102fff:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103002:	89 04 24             	mov    %eax,(%esp)
c0103005:	e8 2f f9 ff ff       	call   c0102939 <page2pa>
c010300a:	8b 15 c0 88 11 c0    	mov    0xc01188c0,%edx
c0103010:	c1 e2 0c             	shl    $0xc,%edx
c0103013:	39 d0                	cmp    %edx,%eax
c0103015:	72 24                	jb     c010303b <basic_check+0x18d>
c0103017:	c7 44 24 0c f8 67 10 	movl   $0xc01067f8,0xc(%esp)
c010301e:	c0 
c010301f:	c7 44 24 08 f6 66 10 	movl   $0xc01066f6,0x8(%esp)
c0103026:	c0 
c0103027:	c7 44 24 04 b4 00 00 	movl   $0xb4,0x4(%esp)
c010302e:	00 
c010302f:	c7 04 24 0b 67 10 c0 	movl   $0xc010670b,(%esp)
c0103036:	e8 96 dc ff ff       	call   c0100cd1 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c010303b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010303e:	89 04 24             	mov    %eax,(%esp)
c0103041:	e8 f3 f8 ff ff       	call   c0102939 <page2pa>
c0103046:	8b 15 c0 88 11 c0    	mov    0xc01188c0,%edx
c010304c:	c1 e2 0c             	shl    $0xc,%edx
c010304f:	39 d0                	cmp    %edx,%eax
c0103051:	72 24                	jb     c0103077 <basic_check+0x1c9>
c0103053:	c7 44 24 0c 15 68 10 	movl   $0xc0106815,0xc(%esp)
c010305a:	c0 
c010305b:	c7 44 24 08 f6 66 10 	movl   $0xc01066f6,0x8(%esp)
c0103062:	c0 
c0103063:	c7 44 24 04 b5 00 00 	movl   $0xb5,0x4(%esp)
c010306a:	00 
c010306b:	c7 04 24 0b 67 10 c0 	movl   $0xc010670b,(%esp)
c0103072:	e8 5a dc ff ff       	call   c0100cd1 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c0103077:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010307a:	89 04 24             	mov    %eax,(%esp)
c010307d:	e8 b7 f8 ff ff       	call   c0102939 <page2pa>
c0103082:	8b 15 c0 88 11 c0    	mov    0xc01188c0,%edx
c0103088:	c1 e2 0c             	shl    $0xc,%edx
c010308b:	39 d0                	cmp    %edx,%eax
c010308d:	72 24                	jb     c01030b3 <basic_check+0x205>
c010308f:	c7 44 24 0c 32 68 10 	movl   $0xc0106832,0xc(%esp)
c0103096:	c0 
c0103097:	c7 44 24 08 f6 66 10 	movl   $0xc01066f6,0x8(%esp)
c010309e:	c0 
c010309f:	c7 44 24 04 b6 00 00 	movl   $0xb6,0x4(%esp)
c01030a6:	00 
c01030a7:	c7 04 24 0b 67 10 c0 	movl   $0xc010670b,(%esp)
c01030ae:	e8 1e dc ff ff       	call   c0100cd1 <__panic>

    list_entry_t free_list_store = free_list;
c01030b3:	a1 b0 89 11 c0       	mov    0xc01189b0,%eax
c01030b8:	8b 15 b4 89 11 c0    	mov    0xc01189b4,%edx
c01030be:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01030c1:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01030c4:	c7 45 e0 b0 89 11 c0 	movl   $0xc01189b0,-0x20(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c01030cb:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01030ce:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01030d1:	89 50 04             	mov    %edx,0x4(%eax)
c01030d4:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01030d7:	8b 50 04             	mov    0x4(%eax),%edx
c01030da:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01030dd:	89 10                	mov    %edx,(%eax)
c01030df:	c7 45 dc b0 89 11 c0 	movl   $0xc01189b0,-0x24(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c01030e6:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01030e9:	8b 40 04             	mov    0x4(%eax),%eax
c01030ec:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c01030ef:	0f 94 c0             	sete   %al
c01030f2:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c01030f5:	85 c0                	test   %eax,%eax
c01030f7:	75 24                	jne    c010311d <basic_check+0x26f>
c01030f9:	c7 44 24 0c 4f 68 10 	movl   $0xc010684f,0xc(%esp)
c0103100:	c0 
c0103101:	c7 44 24 08 f6 66 10 	movl   $0xc01066f6,0x8(%esp)
c0103108:	c0 
c0103109:	c7 44 24 04 ba 00 00 	movl   $0xba,0x4(%esp)
c0103110:	00 
c0103111:	c7 04 24 0b 67 10 c0 	movl   $0xc010670b,(%esp)
c0103118:	e8 b4 db ff ff       	call   c0100cd1 <__panic>

    unsigned int nr_free_store = nr_free;
c010311d:	a1 b8 89 11 c0       	mov    0xc01189b8,%eax
c0103122:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
c0103125:	c7 05 b8 89 11 c0 00 	movl   $0x0,0xc01189b8
c010312c:	00 00 00 

    assert(alloc_page() == NULL);
c010312f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103136:	e8 1d 0c 00 00       	call   c0103d58 <alloc_pages>
c010313b:	85 c0                	test   %eax,%eax
c010313d:	74 24                	je     c0103163 <basic_check+0x2b5>
c010313f:	c7 44 24 0c 66 68 10 	movl   $0xc0106866,0xc(%esp)
c0103146:	c0 
c0103147:	c7 44 24 08 f6 66 10 	movl   $0xc01066f6,0x8(%esp)
c010314e:	c0 
c010314f:	c7 44 24 04 bf 00 00 	movl   $0xbf,0x4(%esp)
c0103156:	00 
c0103157:	c7 04 24 0b 67 10 c0 	movl   $0xc010670b,(%esp)
c010315e:	e8 6e db ff ff       	call   c0100cd1 <__panic>

    free_page(p0);
c0103163:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010316a:	00 
c010316b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010316e:	89 04 24             	mov    %eax,(%esp)
c0103171:	e8 1a 0c 00 00       	call   c0103d90 <free_pages>
    free_page(p1);
c0103176:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010317d:	00 
c010317e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103181:	89 04 24             	mov    %eax,(%esp)
c0103184:	e8 07 0c 00 00       	call   c0103d90 <free_pages>
    free_page(p2);
c0103189:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103190:	00 
c0103191:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103194:	89 04 24             	mov    %eax,(%esp)
c0103197:	e8 f4 0b 00 00       	call   c0103d90 <free_pages>
    assert(nr_free == 3);
c010319c:	a1 b8 89 11 c0       	mov    0xc01189b8,%eax
c01031a1:	83 f8 03             	cmp    $0x3,%eax
c01031a4:	74 24                	je     c01031ca <basic_check+0x31c>
c01031a6:	c7 44 24 0c 7b 68 10 	movl   $0xc010687b,0xc(%esp)
c01031ad:	c0 
c01031ae:	c7 44 24 08 f6 66 10 	movl   $0xc01066f6,0x8(%esp)
c01031b5:	c0 
c01031b6:	c7 44 24 04 c4 00 00 	movl   $0xc4,0x4(%esp)
c01031bd:	00 
c01031be:	c7 04 24 0b 67 10 c0 	movl   $0xc010670b,(%esp)
c01031c5:	e8 07 db ff ff       	call   c0100cd1 <__panic>

    assert((p0 = alloc_page()) != NULL);
c01031ca:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01031d1:	e8 82 0b 00 00       	call   c0103d58 <alloc_pages>
c01031d6:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01031d9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01031dd:	75 24                	jne    c0103203 <basic_check+0x355>
c01031df:	c7 44 24 0c 44 67 10 	movl   $0xc0106744,0xc(%esp)
c01031e6:	c0 
c01031e7:	c7 44 24 08 f6 66 10 	movl   $0xc01066f6,0x8(%esp)
c01031ee:	c0 
c01031ef:	c7 44 24 04 c6 00 00 	movl   $0xc6,0x4(%esp)
c01031f6:	00 
c01031f7:	c7 04 24 0b 67 10 c0 	movl   $0xc010670b,(%esp)
c01031fe:	e8 ce da ff ff       	call   c0100cd1 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0103203:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010320a:	e8 49 0b 00 00       	call   c0103d58 <alloc_pages>
c010320f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103212:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103216:	75 24                	jne    c010323c <basic_check+0x38e>
c0103218:	c7 44 24 0c 60 67 10 	movl   $0xc0106760,0xc(%esp)
c010321f:	c0 
c0103220:	c7 44 24 08 f6 66 10 	movl   $0xc01066f6,0x8(%esp)
c0103227:	c0 
c0103228:	c7 44 24 04 c7 00 00 	movl   $0xc7,0x4(%esp)
c010322f:	00 
c0103230:	c7 04 24 0b 67 10 c0 	movl   $0xc010670b,(%esp)
c0103237:	e8 95 da ff ff       	call   c0100cd1 <__panic>
    assert((p2 = alloc_page()) != NULL);
c010323c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103243:	e8 10 0b 00 00       	call   c0103d58 <alloc_pages>
c0103248:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010324b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010324f:	75 24                	jne    c0103275 <basic_check+0x3c7>
c0103251:	c7 44 24 0c 7c 67 10 	movl   $0xc010677c,0xc(%esp)
c0103258:	c0 
c0103259:	c7 44 24 08 f6 66 10 	movl   $0xc01066f6,0x8(%esp)
c0103260:	c0 
c0103261:	c7 44 24 04 c8 00 00 	movl   $0xc8,0x4(%esp)
c0103268:	00 
c0103269:	c7 04 24 0b 67 10 c0 	movl   $0xc010670b,(%esp)
c0103270:	e8 5c da ff ff       	call   c0100cd1 <__panic>

    assert(alloc_page() == NULL);
c0103275:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010327c:	e8 d7 0a 00 00       	call   c0103d58 <alloc_pages>
c0103281:	85 c0                	test   %eax,%eax
c0103283:	74 24                	je     c01032a9 <basic_check+0x3fb>
c0103285:	c7 44 24 0c 66 68 10 	movl   $0xc0106866,0xc(%esp)
c010328c:	c0 
c010328d:	c7 44 24 08 f6 66 10 	movl   $0xc01066f6,0x8(%esp)
c0103294:	c0 
c0103295:	c7 44 24 04 ca 00 00 	movl   $0xca,0x4(%esp)
c010329c:	00 
c010329d:	c7 04 24 0b 67 10 c0 	movl   $0xc010670b,(%esp)
c01032a4:	e8 28 da ff ff       	call   c0100cd1 <__panic>

    free_page(p0);
c01032a9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01032b0:	00 
c01032b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01032b4:	89 04 24             	mov    %eax,(%esp)
c01032b7:	e8 d4 0a 00 00       	call   c0103d90 <free_pages>
c01032bc:	c7 45 d8 b0 89 11 c0 	movl   $0xc01189b0,-0x28(%ebp)
c01032c3:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01032c6:	8b 40 04             	mov    0x4(%eax),%eax
c01032c9:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c01032cc:	0f 94 c0             	sete   %al
c01032cf:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c01032d2:	85 c0                	test   %eax,%eax
c01032d4:	74 24                	je     c01032fa <basic_check+0x44c>
c01032d6:	c7 44 24 0c 88 68 10 	movl   $0xc0106888,0xc(%esp)
c01032dd:	c0 
c01032de:	c7 44 24 08 f6 66 10 	movl   $0xc01066f6,0x8(%esp)
c01032e5:	c0 
c01032e6:	c7 44 24 04 cd 00 00 	movl   $0xcd,0x4(%esp)
c01032ed:	00 
c01032ee:	c7 04 24 0b 67 10 c0 	movl   $0xc010670b,(%esp)
c01032f5:	e8 d7 d9 ff ff       	call   c0100cd1 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c01032fa:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103301:	e8 52 0a 00 00       	call   c0103d58 <alloc_pages>
c0103306:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103309:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010330c:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010330f:	74 24                	je     c0103335 <basic_check+0x487>
c0103311:	c7 44 24 0c a0 68 10 	movl   $0xc01068a0,0xc(%esp)
c0103318:	c0 
c0103319:	c7 44 24 08 f6 66 10 	movl   $0xc01066f6,0x8(%esp)
c0103320:	c0 
c0103321:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
c0103328:	00 
c0103329:	c7 04 24 0b 67 10 c0 	movl   $0xc010670b,(%esp)
c0103330:	e8 9c d9 ff ff       	call   c0100cd1 <__panic>
    assert(alloc_page() == NULL);
c0103335:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010333c:	e8 17 0a 00 00       	call   c0103d58 <alloc_pages>
c0103341:	85 c0                	test   %eax,%eax
c0103343:	74 24                	je     c0103369 <basic_check+0x4bb>
c0103345:	c7 44 24 0c 66 68 10 	movl   $0xc0106866,0xc(%esp)
c010334c:	c0 
c010334d:	c7 44 24 08 f6 66 10 	movl   $0xc01066f6,0x8(%esp)
c0103354:	c0 
c0103355:	c7 44 24 04 d1 00 00 	movl   $0xd1,0x4(%esp)
c010335c:	00 
c010335d:	c7 04 24 0b 67 10 c0 	movl   $0xc010670b,(%esp)
c0103364:	e8 68 d9 ff ff       	call   c0100cd1 <__panic>

    assert(nr_free == 0);
c0103369:	a1 b8 89 11 c0       	mov    0xc01189b8,%eax
c010336e:	85 c0                	test   %eax,%eax
c0103370:	74 24                	je     c0103396 <basic_check+0x4e8>
c0103372:	c7 44 24 0c b9 68 10 	movl   $0xc01068b9,0xc(%esp)
c0103379:	c0 
c010337a:	c7 44 24 08 f6 66 10 	movl   $0xc01066f6,0x8(%esp)
c0103381:	c0 
c0103382:	c7 44 24 04 d3 00 00 	movl   $0xd3,0x4(%esp)
c0103389:	00 
c010338a:	c7 04 24 0b 67 10 c0 	movl   $0xc010670b,(%esp)
c0103391:	e8 3b d9 ff ff       	call   c0100cd1 <__panic>
    free_list = free_list_store;
c0103396:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103399:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010339c:	a3 b0 89 11 c0       	mov    %eax,0xc01189b0
c01033a1:	89 15 b4 89 11 c0    	mov    %edx,0xc01189b4
    nr_free = nr_free_store;
c01033a7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01033aa:	a3 b8 89 11 c0       	mov    %eax,0xc01189b8

    free_page(p);
c01033af:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01033b6:	00 
c01033b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01033ba:	89 04 24             	mov    %eax,(%esp)
c01033bd:	e8 ce 09 00 00       	call   c0103d90 <free_pages>
    free_page(p1);
c01033c2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01033c9:	00 
c01033ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01033cd:	89 04 24             	mov    %eax,(%esp)
c01033d0:	e8 bb 09 00 00       	call   c0103d90 <free_pages>
    free_page(p2);
c01033d5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01033dc:	00 
c01033dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01033e0:	89 04 24             	mov    %eax,(%esp)
c01033e3:	e8 a8 09 00 00       	call   c0103d90 <free_pages>
}
c01033e8:	c9                   	leave  
c01033e9:	c3                   	ret    

c01033ea <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c01033ea:	55                   	push   %ebp
c01033eb:	89 e5                	mov    %esp,%ebp
c01033ed:	53                   	push   %ebx
c01033ee:	81 ec 94 00 00 00    	sub    $0x94,%esp
    int count = 0, total = 0;
c01033f4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01033fb:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c0103402:	c7 45 ec b0 89 11 c0 	movl   $0xc01189b0,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0103409:	eb 6b                	jmp    c0103476 <default_check+0x8c>
        struct Page *p = le2page(le, page_link);
c010340b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010340e:	83 e8 0c             	sub    $0xc,%eax
c0103411:	89 45 e8             	mov    %eax,-0x18(%ebp)
        assert(PageProperty(p));
c0103414:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103417:	83 c0 04             	add    $0x4,%eax
c010341a:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0103421:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103424:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103427:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010342a:	0f a3 10             	bt     %edx,(%eax)
c010342d:	19 c0                	sbb    %eax,%eax
c010342f:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
c0103432:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c0103436:	0f 95 c0             	setne  %al
c0103439:	0f b6 c0             	movzbl %al,%eax
c010343c:	85 c0                	test   %eax,%eax
c010343e:	75 24                	jne    c0103464 <default_check+0x7a>
c0103440:	c7 44 24 0c c6 68 10 	movl   $0xc01068c6,0xc(%esp)
c0103447:	c0 
c0103448:	c7 44 24 08 f6 66 10 	movl   $0xc01066f6,0x8(%esp)
c010344f:	c0 
c0103450:	c7 44 24 04 e4 00 00 	movl   $0xe4,0x4(%esp)
c0103457:	00 
c0103458:	c7 04 24 0b 67 10 c0 	movl   $0xc010670b,(%esp)
c010345f:	e8 6d d8 ff ff       	call   c0100cd1 <__panic>
        count ++, total += p->property;
c0103464:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0103468:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010346b:	8b 50 08             	mov    0x8(%eax),%edx
c010346e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103471:	01 d0                	add    %edx,%eax
c0103473:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103476:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103479:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c010347c:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010347f:	8b 40 04             	mov    0x4(%eax),%eax
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c0103482:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103485:	81 7d ec b0 89 11 c0 	cmpl   $0xc01189b0,-0x14(%ebp)
c010348c:	0f 85 79 ff ff ff    	jne    c010340b <default_check+0x21>
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    assert(total == nr_free_pages());
c0103492:	8b 5d f0             	mov    -0x10(%ebp),%ebx
c0103495:	e8 28 09 00 00       	call   c0103dc2 <nr_free_pages>
c010349a:	39 c3                	cmp    %eax,%ebx
c010349c:	74 24                	je     c01034c2 <default_check+0xd8>
c010349e:	c7 44 24 0c d6 68 10 	movl   $0xc01068d6,0xc(%esp)
c01034a5:	c0 
c01034a6:	c7 44 24 08 f6 66 10 	movl   $0xc01066f6,0x8(%esp)
c01034ad:	c0 
c01034ae:	c7 44 24 04 e7 00 00 	movl   $0xe7,0x4(%esp)
c01034b5:	00 
c01034b6:	c7 04 24 0b 67 10 c0 	movl   $0xc010670b,(%esp)
c01034bd:	e8 0f d8 ff ff       	call   c0100cd1 <__panic>

    basic_check();
c01034c2:	e8 e7 f9 ff ff       	call   c0102eae <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c01034c7:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c01034ce:	e8 85 08 00 00       	call   c0103d58 <alloc_pages>
c01034d3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(p0 != NULL);
c01034d6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01034da:	75 24                	jne    c0103500 <default_check+0x116>
c01034dc:	c7 44 24 0c ef 68 10 	movl   $0xc01068ef,0xc(%esp)
c01034e3:	c0 
c01034e4:	c7 44 24 08 f6 66 10 	movl   $0xc01066f6,0x8(%esp)
c01034eb:	c0 
c01034ec:	c7 44 24 04 ec 00 00 	movl   $0xec,0x4(%esp)
c01034f3:	00 
c01034f4:	c7 04 24 0b 67 10 c0 	movl   $0xc010670b,(%esp)
c01034fb:	e8 d1 d7 ff ff       	call   c0100cd1 <__panic>
    assert(!PageProperty(p0));
c0103500:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103503:	83 c0 04             	add    $0x4,%eax
c0103506:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c010350d:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103510:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0103513:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0103516:	0f a3 10             	bt     %edx,(%eax)
c0103519:	19 c0                	sbb    %eax,%eax
c010351b:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c010351e:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c0103522:	0f 95 c0             	setne  %al
c0103525:	0f b6 c0             	movzbl %al,%eax
c0103528:	85 c0                	test   %eax,%eax
c010352a:	74 24                	je     c0103550 <default_check+0x166>
c010352c:	c7 44 24 0c fa 68 10 	movl   $0xc01068fa,0xc(%esp)
c0103533:	c0 
c0103534:	c7 44 24 08 f6 66 10 	movl   $0xc01066f6,0x8(%esp)
c010353b:	c0 
c010353c:	c7 44 24 04 ed 00 00 	movl   $0xed,0x4(%esp)
c0103543:	00 
c0103544:	c7 04 24 0b 67 10 c0 	movl   $0xc010670b,(%esp)
c010354b:	e8 81 d7 ff ff       	call   c0100cd1 <__panic>

    list_entry_t free_list_store = free_list;
c0103550:	a1 b0 89 11 c0       	mov    0xc01189b0,%eax
c0103555:	8b 15 b4 89 11 c0    	mov    0xc01189b4,%edx
c010355b:	89 45 80             	mov    %eax,-0x80(%ebp)
c010355e:	89 55 84             	mov    %edx,-0x7c(%ebp)
c0103561:	c7 45 b4 b0 89 11 c0 	movl   $0xc01189b0,-0x4c(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0103568:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010356b:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c010356e:	89 50 04             	mov    %edx,0x4(%eax)
c0103571:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0103574:	8b 50 04             	mov    0x4(%eax),%edx
c0103577:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010357a:	89 10                	mov    %edx,(%eax)
c010357c:	c7 45 b0 b0 89 11 c0 	movl   $0xc01189b0,-0x50(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c0103583:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0103586:	8b 40 04             	mov    0x4(%eax),%eax
c0103589:	39 45 b0             	cmp    %eax,-0x50(%ebp)
c010358c:	0f 94 c0             	sete   %al
c010358f:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0103592:	85 c0                	test   %eax,%eax
c0103594:	75 24                	jne    c01035ba <default_check+0x1d0>
c0103596:	c7 44 24 0c 4f 68 10 	movl   $0xc010684f,0xc(%esp)
c010359d:	c0 
c010359e:	c7 44 24 08 f6 66 10 	movl   $0xc01066f6,0x8(%esp)
c01035a5:	c0 
c01035a6:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
c01035ad:	00 
c01035ae:	c7 04 24 0b 67 10 c0 	movl   $0xc010670b,(%esp)
c01035b5:	e8 17 d7 ff ff       	call   c0100cd1 <__panic>
    assert(alloc_page() == NULL);
c01035ba:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01035c1:	e8 92 07 00 00       	call   c0103d58 <alloc_pages>
c01035c6:	85 c0                	test   %eax,%eax
c01035c8:	74 24                	je     c01035ee <default_check+0x204>
c01035ca:	c7 44 24 0c 66 68 10 	movl   $0xc0106866,0xc(%esp)
c01035d1:	c0 
c01035d2:	c7 44 24 08 f6 66 10 	movl   $0xc01066f6,0x8(%esp)
c01035d9:	c0 
c01035da:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
c01035e1:	00 
c01035e2:	c7 04 24 0b 67 10 c0 	movl   $0xc010670b,(%esp)
c01035e9:	e8 e3 d6 ff ff       	call   c0100cd1 <__panic>

    unsigned int nr_free_store = nr_free;
c01035ee:	a1 b8 89 11 c0       	mov    0xc01189b8,%eax
c01035f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nr_free = 0;
c01035f6:	c7 05 b8 89 11 c0 00 	movl   $0x0,0xc01189b8
c01035fd:	00 00 00 

    free_pages(p0 + 2, 3);
c0103600:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103603:	83 c0 28             	add    $0x28,%eax
c0103606:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c010360d:	00 
c010360e:	89 04 24             	mov    %eax,(%esp)
c0103611:	e8 7a 07 00 00       	call   c0103d90 <free_pages>
    assert(alloc_pages(4) == NULL);
c0103616:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c010361d:	e8 36 07 00 00       	call   c0103d58 <alloc_pages>
c0103622:	85 c0                	test   %eax,%eax
c0103624:	74 24                	je     c010364a <default_check+0x260>
c0103626:	c7 44 24 0c 0c 69 10 	movl   $0xc010690c,0xc(%esp)
c010362d:	c0 
c010362e:	c7 44 24 08 f6 66 10 	movl   $0xc01066f6,0x8(%esp)
c0103635:	c0 
c0103636:	c7 44 24 04 f8 00 00 	movl   $0xf8,0x4(%esp)
c010363d:	00 
c010363e:	c7 04 24 0b 67 10 c0 	movl   $0xc010670b,(%esp)
c0103645:	e8 87 d6 ff ff       	call   c0100cd1 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c010364a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010364d:	83 c0 28             	add    $0x28,%eax
c0103650:	83 c0 04             	add    $0x4,%eax
c0103653:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c010365a:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010365d:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0103660:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0103663:	0f a3 10             	bt     %edx,(%eax)
c0103666:	19 c0                	sbb    %eax,%eax
c0103668:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
c010366b:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c010366f:	0f 95 c0             	setne  %al
c0103672:	0f b6 c0             	movzbl %al,%eax
c0103675:	85 c0                	test   %eax,%eax
c0103677:	74 0e                	je     c0103687 <default_check+0x29d>
c0103679:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010367c:	83 c0 28             	add    $0x28,%eax
c010367f:	8b 40 08             	mov    0x8(%eax),%eax
c0103682:	83 f8 03             	cmp    $0x3,%eax
c0103685:	74 24                	je     c01036ab <default_check+0x2c1>
c0103687:	c7 44 24 0c 24 69 10 	movl   $0xc0106924,0xc(%esp)
c010368e:	c0 
c010368f:	c7 44 24 08 f6 66 10 	movl   $0xc01066f6,0x8(%esp)
c0103696:	c0 
c0103697:	c7 44 24 04 f9 00 00 	movl   $0xf9,0x4(%esp)
c010369e:	00 
c010369f:	c7 04 24 0b 67 10 c0 	movl   $0xc010670b,(%esp)
c01036a6:	e8 26 d6 ff ff       	call   c0100cd1 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c01036ab:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
c01036b2:	e8 a1 06 00 00       	call   c0103d58 <alloc_pages>
c01036b7:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01036ba:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c01036be:	75 24                	jne    c01036e4 <default_check+0x2fa>
c01036c0:	c7 44 24 0c 50 69 10 	movl   $0xc0106950,0xc(%esp)
c01036c7:	c0 
c01036c8:	c7 44 24 08 f6 66 10 	movl   $0xc01066f6,0x8(%esp)
c01036cf:	c0 
c01036d0:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
c01036d7:	00 
c01036d8:	c7 04 24 0b 67 10 c0 	movl   $0xc010670b,(%esp)
c01036df:	e8 ed d5 ff ff       	call   c0100cd1 <__panic>
    assert(alloc_page() == NULL);
c01036e4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01036eb:	e8 68 06 00 00       	call   c0103d58 <alloc_pages>
c01036f0:	85 c0                	test   %eax,%eax
c01036f2:	74 24                	je     c0103718 <default_check+0x32e>
c01036f4:	c7 44 24 0c 66 68 10 	movl   $0xc0106866,0xc(%esp)
c01036fb:	c0 
c01036fc:	c7 44 24 08 f6 66 10 	movl   $0xc01066f6,0x8(%esp)
c0103703:	c0 
c0103704:	c7 44 24 04 fb 00 00 	movl   $0xfb,0x4(%esp)
c010370b:	00 
c010370c:	c7 04 24 0b 67 10 c0 	movl   $0xc010670b,(%esp)
c0103713:	e8 b9 d5 ff ff       	call   c0100cd1 <__panic>
    assert(p0 + 2 == p1);
c0103718:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010371b:	83 c0 28             	add    $0x28,%eax
c010371e:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c0103721:	74 24                	je     c0103747 <default_check+0x35d>
c0103723:	c7 44 24 0c 6e 69 10 	movl   $0xc010696e,0xc(%esp)
c010372a:	c0 
c010372b:	c7 44 24 08 f6 66 10 	movl   $0xc01066f6,0x8(%esp)
c0103732:	c0 
c0103733:	c7 44 24 04 fc 00 00 	movl   $0xfc,0x4(%esp)
c010373a:	00 
c010373b:	c7 04 24 0b 67 10 c0 	movl   $0xc010670b,(%esp)
c0103742:	e8 8a d5 ff ff       	call   c0100cd1 <__panic>

    p2 = p0 + 1;
c0103747:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010374a:	83 c0 14             	add    $0x14,%eax
c010374d:	89 45 d8             	mov    %eax,-0x28(%ebp)
    free_page(p0);
c0103750:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103757:	00 
c0103758:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010375b:	89 04 24             	mov    %eax,(%esp)
c010375e:	e8 2d 06 00 00       	call   c0103d90 <free_pages>
    free_pages(p1, 3);
c0103763:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c010376a:	00 
c010376b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010376e:	89 04 24             	mov    %eax,(%esp)
c0103771:	e8 1a 06 00 00       	call   c0103d90 <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
c0103776:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103779:	83 c0 04             	add    $0x4,%eax
c010377c:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
c0103783:	89 45 9c             	mov    %eax,-0x64(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103786:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0103789:	8b 55 a0             	mov    -0x60(%ebp),%edx
c010378c:	0f a3 10             	bt     %edx,(%eax)
c010378f:	19 c0                	sbb    %eax,%eax
c0103791:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c0103794:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c0103798:	0f 95 c0             	setne  %al
c010379b:	0f b6 c0             	movzbl %al,%eax
c010379e:	85 c0                	test   %eax,%eax
c01037a0:	74 0b                	je     c01037ad <default_check+0x3c3>
c01037a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01037a5:	8b 40 08             	mov    0x8(%eax),%eax
c01037a8:	83 f8 01             	cmp    $0x1,%eax
c01037ab:	74 24                	je     c01037d1 <default_check+0x3e7>
c01037ad:	c7 44 24 0c 7c 69 10 	movl   $0xc010697c,0xc(%esp)
c01037b4:	c0 
c01037b5:	c7 44 24 08 f6 66 10 	movl   $0xc01066f6,0x8(%esp)
c01037bc:	c0 
c01037bd:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
c01037c4:	00 
c01037c5:	c7 04 24 0b 67 10 c0 	movl   $0xc010670b,(%esp)
c01037cc:	e8 00 d5 ff ff       	call   c0100cd1 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c01037d1:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01037d4:	83 c0 04             	add    $0x4,%eax
c01037d7:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
c01037de:	89 45 90             	mov    %eax,-0x70(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01037e1:	8b 45 90             	mov    -0x70(%ebp),%eax
c01037e4:	8b 55 94             	mov    -0x6c(%ebp),%edx
c01037e7:	0f a3 10             	bt     %edx,(%eax)
c01037ea:	19 c0                	sbb    %eax,%eax
c01037ec:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
c01037ef:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
c01037f3:	0f 95 c0             	setne  %al
c01037f6:	0f b6 c0             	movzbl %al,%eax
c01037f9:	85 c0                	test   %eax,%eax
c01037fb:	74 0b                	je     c0103808 <default_check+0x41e>
c01037fd:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103800:	8b 40 08             	mov    0x8(%eax),%eax
c0103803:	83 f8 03             	cmp    $0x3,%eax
c0103806:	74 24                	je     c010382c <default_check+0x442>
c0103808:	c7 44 24 0c a4 69 10 	movl   $0xc01069a4,0xc(%esp)
c010380f:	c0 
c0103810:	c7 44 24 08 f6 66 10 	movl   $0xc01066f6,0x8(%esp)
c0103817:	c0 
c0103818:	c7 44 24 04 02 01 00 	movl   $0x102,0x4(%esp)
c010381f:	00 
c0103820:	c7 04 24 0b 67 10 c0 	movl   $0xc010670b,(%esp)
c0103827:	e8 a5 d4 ff ff       	call   c0100cd1 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c010382c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103833:	e8 20 05 00 00       	call   c0103d58 <alloc_pages>
c0103838:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010383b:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010383e:	83 e8 14             	sub    $0x14,%eax
c0103841:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c0103844:	74 24                	je     c010386a <default_check+0x480>
c0103846:	c7 44 24 0c ca 69 10 	movl   $0xc01069ca,0xc(%esp)
c010384d:	c0 
c010384e:	c7 44 24 08 f6 66 10 	movl   $0xc01066f6,0x8(%esp)
c0103855:	c0 
c0103856:	c7 44 24 04 04 01 00 	movl   $0x104,0x4(%esp)
c010385d:	00 
c010385e:	c7 04 24 0b 67 10 c0 	movl   $0xc010670b,(%esp)
c0103865:	e8 67 d4 ff ff       	call   c0100cd1 <__panic>
    free_page(p0);
c010386a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103871:	00 
c0103872:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103875:	89 04 24             	mov    %eax,(%esp)
c0103878:	e8 13 05 00 00       	call   c0103d90 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
c010387d:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c0103884:	e8 cf 04 00 00       	call   c0103d58 <alloc_pages>
c0103889:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010388c:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010388f:	83 c0 14             	add    $0x14,%eax
c0103892:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c0103895:	74 24                	je     c01038bb <default_check+0x4d1>
c0103897:	c7 44 24 0c e8 69 10 	movl   $0xc01069e8,0xc(%esp)
c010389e:	c0 
c010389f:	c7 44 24 08 f6 66 10 	movl   $0xc01066f6,0x8(%esp)
c01038a6:	c0 
c01038a7:	c7 44 24 04 06 01 00 	movl   $0x106,0x4(%esp)
c01038ae:	00 
c01038af:	c7 04 24 0b 67 10 c0 	movl   $0xc010670b,(%esp)
c01038b6:	e8 16 d4 ff ff       	call   c0100cd1 <__panic>

    free_pages(p0, 2);
c01038bb:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c01038c2:	00 
c01038c3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01038c6:	89 04 24             	mov    %eax,(%esp)
c01038c9:	e8 c2 04 00 00       	call   c0103d90 <free_pages>
    free_page(p2);
c01038ce:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01038d5:	00 
c01038d6:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01038d9:	89 04 24             	mov    %eax,(%esp)
c01038dc:	e8 af 04 00 00       	call   c0103d90 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
c01038e1:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c01038e8:	e8 6b 04 00 00       	call   c0103d58 <alloc_pages>
c01038ed:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01038f0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01038f4:	75 24                	jne    c010391a <default_check+0x530>
c01038f6:	c7 44 24 0c 08 6a 10 	movl   $0xc0106a08,0xc(%esp)
c01038fd:	c0 
c01038fe:	c7 44 24 08 f6 66 10 	movl   $0xc01066f6,0x8(%esp)
c0103905:	c0 
c0103906:	c7 44 24 04 0b 01 00 	movl   $0x10b,0x4(%esp)
c010390d:	00 
c010390e:	c7 04 24 0b 67 10 c0 	movl   $0xc010670b,(%esp)
c0103915:	e8 b7 d3 ff ff       	call   c0100cd1 <__panic>
    assert(alloc_page() == NULL);
c010391a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103921:	e8 32 04 00 00       	call   c0103d58 <alloc_pages>
c0103926:	85 c0                	test   %eax,%eax
c0103928:	74 24                	je     c010394e <default_check+0x564>
c010392a:	c7 44 24 0c 66 68 10 	movl   $0xc0106866,0xc(%esp)
c0103931:	c0 
c0103932:	c7 44 24 08 f6 66 10 	movl   $0xc01066f6,0x8(%esp)
c0103939:	c0 
c010393a:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
c0103941:	00 
c0103942:	c7 04 24 0b 67 10 c0 	movl   $0xc010670b,(%esp)
c0103949:	e8 83 d3 ff ff       	call   c0100cd1 <__panic>

    assert(nr_free == 0);
c010394e:	a1 b8 89 11 c0       	mov    0xc01189b8,%eax
c0103953:	85 c0                	test   %eax,%eax
c0103955:	74 24                	je     c010397b <default_check+0x591>
c0103957:	c7 44 24 0c b9 68 10 	movl   $0xc01068b9,0xc(%esp)
c010395e:	c0 
c010395f:	c7 44 24 08 f6 66 10 	movl   $0xc01066f6,0x8(%esp)
c0103966:	c0 
c0103967:	c7 44 24 04 0e 01 00 	movl   $0x10e,0x4(%esp)
c010396e:	00 
c010396f:	c7 04 24 0b 67 10 c0 	movl   $0xc010670b,(%esp)
c0103976:	e8 56 d3 ff ff       	call   c0100cd1 <__panic>
    nr_free = nr_free_store;
c010397b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010397e:	a3 b8 89 11 c0       	mov    %eax,0xc01189b8

    free_list = free_list_store;
c0103983:	8b 45 80             	mov    -0x80(%ebp),%eax
c0103986:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0103989:	a3 b0 89 11 c0       	mov    %eax,0xc01189b0
c010398e:	89 15 b4 89 11 c0    	mov    %edx,0xc01189b4
    free_pages(p0, 5);
c0103994:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
c010399b:	00 
c010399c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010399f:	89 04 24             	mov    %eax,(%esp)
c01039a2:	e8 e9 03 00 00       	call   c0103d90 <free_pages>

    le = &free_list;
c01039a7:	c7 45 ec b0 89 11 c0 	movl   $0xc01189b0,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c01039ae:	eb 1d                	jmp    c01039cd <default_check+0x5e3>
        struct Page *p = le2page(le, page_link);
c01039b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01039b3:	83 e8 0c             	sub    $0xc,%eax
c01039b6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        count --, total -= p->property;
c01039b9:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01039bd:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01039c0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01039c3:	8b 40 08             	mov    0x8(%eax),%eax
c01039c6:	29 c2                	sub    %eax,%edx
c01039c8:	89 d0                	mov    %edx,%eax
c01039ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01039cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01039d0:	89 45 88             	mov    %eax,-0x78(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01039d3:	8b 45 88             	mov    -0x78(%ebp),%eax
c01039d6:	8b 40 04             	mov    0x4(%eax),%eax

    free_list = free_list_store;
    free_pages(p0, 5);

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c01039d9:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01039dc:	81 7d ec b0 89 11 c0 	cmpl   $0xc01189b0,-0x14(%ebp)
c01039e3:	75 cb                	jne    c01039b0 <default_check+0x5c6>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
    }
    assert(count == 0);
c01039e5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01039e9:	74 24                	je     c0103a0f <default_check+0x625>
c01039eb:	c7 44 24 0c 26 6a 10 	movl   $0xc0106a26,0xc(%esp)
c01039f2:	c0 
c01039f3:	c7 44 24 08 f6 66 10 	movl   $0xc01066f6,0x8(%esp)
c01039fa:	c0 
c01039fb:	c7 44 24 04 19 01 00 	movl   $0x119,0x4(%esp)
c0103a02:	00 
c0103a03:	c7 04 24 0b 67 10 c0 	movl   $0xc010670b,(%esp)
c0103a0a:	e8 c2 d2 ff ff       	call   c0100cd1 <__panic>
    assert(total == 0);
c0103a0f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103a13:	74 24                	je     c0103a39 <default_check+0x64f>
c0103a15:	c7 44 24 0c 31 6a 10 	movl   $0xc0106a31,0xc(%esp)
c0103a1c:	c0 
c0103a1d:	c7 44 24 08 f6 66 10 	movl   $0xc01066f6,0x8(%esp)
c0103a24:	c0 
c0103a25:	c7 44 24 04 1a 01 00 	movl   $0x11a,0x4(%esp)
c0103a2c:	00 
c0103a2d:	c7 04 24 0b 67 10 c0 	movl   $0xc010670b,(%esp)
c0103a34:	e8 98 d2 ff ff       	call   c0100cd1 <__panic>
}
c0103a39:	81 c4 94 00 00 00    	add    $0x94,%esp
c0103a3f:	5b                   	pop    %ebx
c0103a40:	5d                   	pop    %ebp
c0103a41:	c3                   	ret    

c0103a42 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0103a42:	55                   	push   %ebp
c0103a43:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0103a45:	8b 55 08             	mov    0x8(%ebp),%edx
c0103a48:	a1 c4 89 11 c0       	mov    0xc01189c4,%eax
c0103a4d:	29 c2                	sub    %eax,%edx
c0103a4f:	89 d0                	mov    %edx,%eax
c0103a51:	c1 f8 02             	sar    $0x2,%eax
c0103a54:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c0103a5a:	5d                   	pop    %ebp
c0103a5b:	c3                   	ret    

c0103a5c <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0103a5c:	55                   	push   %ebp
c0103a5d:	89 e5                	mov    %esp,%ebp
c0103a5f:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0103a62:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a65:	89 04 24             	mov    %eax,(%esp)
c0103a68:	e8 d5 ff ff ff       	call   c0103a42 <page2ppn>
c0103a6d:	c1 e0 0c             	shl    $0xc,%eax
}
c0103a70:	c9                   	leave  
c0103a71:	c3                   	ret    

c0103a72 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c0103a72:	55                   	push   %ebp
c0103a73:	89 e5                	mov    %esp,%ebp
c0103a75:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0103a78:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a7b:	c1 e8 0c             	shr    $0xc,%eax
c0103a7e:	89 c2                	mov    %eax,%edx
c0103a80:	a1 c0 88 11 c0       	mov    0xc01188c0,%eax
c0103a85:	39 c2                	cmp    %eax,%edx
c0103a87:	72 1c                	jb     c0103aa5 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0103a89:	c7 44 24 08 6c 6a 10 	movl   $0xc0106a6c,0x8(%esp)
c0103a90:	c0 
c0103a91:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
c0103a98:	00 
c0103a99:	c7 04 24 8b 6a 10 c0 	movl   $0xc0106a8b,(%esp)
c0103aa0:	e8 2c d2 ff ff       	call   c0100cd1 <__panic>
    }
    return &pages[PPN(pa)];
c0103aa5:	8b 0d c4 89 11 c0    	mov    0xc01189c4,%ecx
c0103aab:	8b 45 08             	mov    0x8(%ebp),%eax
c0103aae:	c1 e8 0c             	shr    $0xc,%eax
c0103ab1:	89 c2                	mov    %eax,%edx
c0103ab3:	89 d0                	mov    %edx,%eax
c0103ab5:	c1 e0 02             	shl    $0x2,%eax
c0103ab8:	01 d0                	add    %edx,%eax
c0103aba:	c1 e0 02             	shl    $0x2,%eax
c0103abd:	01 c8                	add    %ecx,%eax
}
c0103abf:	c9                   	leave  
c0103ac0:	c3                   	ret    

c0103ac1 <page2kva>:

static inline void *
page2kva(struct Page *page) {
c0103ac1:	55                   	push   %ebp
c0103ac2:	89 e5                	mov    %esp,%ebp
c0103ac4:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0103ac7:	8b 45 08             	mov    0x8(%ebp),%eax
c0103aca:	89 04 24             	mov    %eax,(%esp)
c0103acd:	e8 8a ff ff ff       	call   c0103a5c <page2pa>
c0103ad2:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103ad5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103ad8:	c1 e8 0c             	shr    $0xc,%eax
c0103adb:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103ade:	a1 c0 88 11 c0       	mov    0xc01188c0,%eax
c0103ae3:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0103ae6:	72 23                	jb     c0103b0b <page2kva+0x4a>
c0103ae8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103aeb:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103aef:	c7 44 24 08 9c 6a 10 	movl   $0xc0106a9c,0x8(%esp)
c0103af6:	c0 
c0103af7:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
c0103afe:	00 
c0103aff:	c7 04 24 8b 6a 10 c0 	movl   $0xc0106a8b,(%esp)
c0103b06:	e8 c6 d1 ff ff       	call   c0100cd1 <__panic>
c0103b0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b0e:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0103b13:	c9                   	leave  
c0103b14:	c3                   	ret    

c0103b15 <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
c0103b15:	55                   	push   %ebp
c0103b16:	89 e5                	mov    %esp,%ebp
c0103b18:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c0103b1b:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b1e:	83 e0 01             	and    $0x1,%eax
c0103b21:	85 c0                	test   %eax,%eax
c0103b23:	75 1c                	jne    c0103b41 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c0103b25:	c7 44 24 08 c0 6a 10 	movl   $0xc0106ac0,0x8(%esp)
c0103b2c:	c0 
c0103b2d:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
c0103b34:	00 
c0103b35:	c7 04 24 8b 6a 10 c0 	movl   $0xc0106a8b,(%esp)
c0103b3c:	e8 90 d1 ff ff       	call   c0100cd1 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c0103b41:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b44:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103b49:	89 04 24             	mov    %eax,(%esp)
c0103b4c:	e8 21 ff ff ff       	call   c0103a72 <pa2page>
}
c0103b51:	c9                   	leave  
c0103b52:	c3                   	ret    

c0103b53 <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
c0103b53:	55                   	push   %ebp
c0103b54:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0103b56:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b59:	8b 00                	mov    (%eax),%eax
}
c0103b5b:	5d                   	pop    %ebp
c0103b5c:	c3                   	ret    

c0103b5d <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0103b5d:	55                   	push   %ebp
c0103b5e:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0103b60:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b63:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103b66:	89 10                	mov    %edx,(%eax)
}
c0103b68:	5d                   	pop    %ebp
c0103b69:	c3                   	ret    

c0103b6a <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c0103b6a:	55                   	push   %ebp
c0103b6b:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c0103b6d:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b70:	8b 00                	mov    (%eax),%eax
c0103b72:	8d 50 01             	lea    0x1(%eax),%edx
c0103b75:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b78:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0103b7a:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b7d:	8b 00                	mov    (%eax),%eax
}
c0103b7f:	5d                   	pop    %ebp
c0103b80:	c3                   	ret    

c0103b81 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c0103b81:	55                   	push   %ebp
c0103b82:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c0103b84:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b87:	8b 00                	mov    (%eax),%eax
c0103b89:	8d 50 ff             	lea    -0x1(%eax),%edx
c0103b8c:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b8f:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0103b91:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b94:	8b 00                	mov    (%eax),%eax
}
c0103b96:	5d                   	pop    %ebp
c0103b97:	c3                   	ret    

c0103b98 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0103b98:	55                   	push   %ebp
c0103b99:	89 e5                	mov    %esp,%ebp
c0103b9b:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0103b9e:	9c                   	pushf  
c0103b9f:	58                   	pop    %eax
c0103ba0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0103ba3:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0103ba6:	25 00 02 00 00       	and    $0x200,%eax
c0103bab:	85 c0                	test   %eax,%eax
c0103bad:	74 0c                	je     c0103bbb <__intr_save+0x23>
        intr_disable();
c0103baf:	e8 00 db ff ff       	call   c01016b4 <intr_disable>
        return 1;
c0103bb4:	b8 01 00 00 00       	mov    $0x1,%eax
c0103bb9:	eb 05                	jmp    c0103bc0 <__intr_save+0x28>
    }
    return 0;
c0103bbb:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0103bc0:	c9                   	leave  
c0103bc1:	c3                   	ret    

c0103bc2 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0103bc2:	55                   	push   %ebp
c0103bc3:	89 e5                	mov    %esp,%ebp
c0103bc5:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0103bc8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0103bcc:	74 05                	je     c0103bd3 <__intr_restore+0x11>
        intr_enable();
c0103bce:	e8 db da ff ff       	call   c01016ae <intr_enable>
    }
}
c0103bd3:	c9                   	leave  
c0103bd4:	c3                   	ret    

c0103bd5 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c0103bd5:	55                   	push   %ebp
c0103bd6:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c0103bd8:	8b 45 08             	mov    0x8(%ebp),%eax
c0103bdb:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c0103bde:	b8 23 00 00 00       	mov    $0x23,%eax
c0103be3:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c0103be5:	b8 23 00 00 00       	mov    $0x23,%eax
c0103bea:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c0103bec:	b8 10 00 00 00       	mov    $0x10,%eax
c0103bf1:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c0103bf3:	b8 10 00 00 00       	mov    $0x10,%eax
c0103bf8:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c0103bfa:	b8 10 00 00 00       	mov    $0x10,%eax
c0103bff:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c0103c01:	ea 08 3c 10 c0 08 00 	ljmp   $0x8,$0xc0103c08
}
c0103c08:	5d                   	pop    %ebp
c0103c09:	c3                   	ret    

c0103c0a <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c0103c0a:	55                   	push   %ebp
c0103c0b:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c0103c0d:	8b 45 08             	mov    0x8(%ebp),%eax
c0103c10:	a3 e4 88 11 c0       	mov    %eax,0xc01188e4
}
c0103c15:	5d                   	pop    %ebp
c0103c16:	c3                   	ret    

c0103c17 <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c0103c17:	55                   	push   %ebp
c0103c18:	89 e5                	mov    %esp,%ebp
c0103c1a:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c0103c1d:	b8 00 70 11 c0       	mov    $0xc0117000,%eax
c0103c22:	89 04 24             	mov    %eax,(%esp)
c0103c25:	e8 e0 ff ff ff       	call   c0103c0a <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
c0103c2a:	66 c7 05 e8 88 11 c0 	movw   $0x10,0xc01188e8
c0103c31:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c0103c33:	66 c7 05 28 7a 11 c0 	movw   $0x68,0xc0117a28
c0103c3a:	68 00 
c0103c3c:	b8 e0 88 11 c0       	mov    $0xc01188e0,%eax
c0103c41:	66 a3 2a 7a 11 c0    	mov    %ax,0xc0117a2a
c0103c47:	b8 e0 88 11 c0       	mov    $0xc01188e0,%eax
c0103c4c:	c1 e8 10             	shr    $0x10,%eax
c0103c4f:	a2 2c 7a 11 c0       	mov    %al,0xc0117a2c
c0103c54:	0f b6 05 2d 7a 11 c0 	movzbl 0xc0117a2d,%eax
c0103c5b:	83 e0 f0             	and    $0xfffffff0,%eax
c0103c5e:	83 c8 09             	or     $0x9,%eax
c0103c61:	a2 2d 7a 11 c0       	mov    %al,0xc0117a2d
c0103c66:	0f b6 05 2d 7a 11 c0 	movzbl 0xc0117a2d,%eax
c0103c6d:	83 e0 ef             	and    $0xffffffef,%eax
c0103c70:	a2 2d 7a 11 c0       	mov    %al,0xc0117a2d
c0103c75:	0f b6 05 2d 7a 11 c0 	movzbl 0xc0117a2d,%eax
c0103c7c:	83 e0 9f             	and    $0xffffff9f,%eax
c0103c7f:	a2 2d 7a 11 c0       	mov    %al,0xc0117a2d
c0103c84:	0f b6 05 2d 7a 11 c0 	movzbl 0xc0117a2d,%eax
c0103c8b:	83 c8 80             	or     $0xffffff80,%eax
c0103c8e:	a2 2d 7a 11 c0       	mov    %al,0xc0117a2d
c0103c93:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0103c9a:	83 e0 f0             	and    $0xfffffff0,%eax
c0103c9d:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0103ca2:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0103ca9:	83 e0 ef             	and    $0xffffffef,%eax
c0103cac:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0103cb1:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0103cb8:	83 e0 df             	and    $0xffffffdf,%eax
c0103cbb:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0103cc0:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0103cc7:	83 c8 40             	or     $0x40,%eax
c0103cca:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0103ccf:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0103cd6:	83 e0 7f             	and    $0x7f,%eax
c0103cd9:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0103cde:	b8 e0 88 11 c0       	mov    $0xc01188e0,%eax
c0103ce3:	c1 e8 18             	shr    $0x18,%eax
c0103ce6:	a2 2f 7a 11 c0       	mov    %al,0xc0117a2f

    // reload all segment registers
    lgdt(&gdt_pd);
c0103ceb:	c7 04 24 30 7a 11 c0 	movl   $0xc0117a30,(%esp)
c0103cf2:	e8 de fe ff ff       	call   c0103bd5 <lgdt>
c0103cf7:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("cli" ::: "memory");
}

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c0103cfd:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0103d01:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
c0103d04:	c9                   	leave  
c0103d05:	c3                   	ret    

c0103d06 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c0103d06:	55                   	push   %ebp
c0103d07:	89 e5                	mov    %esp,%ebp
c0103d09:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
c0103d0c:	c7 05 bc 89 11 c0 50 	movl   $0xc0106a50,0xc01189bc
c0103d13:	6a 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c0103d16:	a1 bc 89 11 c0       	mov    0xc01189bc,%eax
c0103d1b:	8b 00                	mov    (%eax),%eax
c0103d1d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103d21:	c7 04 24 ec 6a 10 c0 	movl   $0xc0106aec,(%esp)
c0103d28:	e8 1a c6 ff ff       	call   c0100347 <cprintf>
    pmm_manager->init();
c0103d2d:	a1 bc 89 11 c0       	mov    0xc01189bc,%eax
c0103d32:	8b 40 04             	mov    0x4(%eax),%eax
c0103d35:	ff d0                	call   *%eax
}
c0103d37:	c9                   	leave  
c0103d38:	c3                   	ret    

c0103d39 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
c0103d39:	55                   	push   %ebp
c0103d3a:	89 e5                	mov    %esp,%ebp
c0103d3c:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
c0103d3f:	a1 bc 89 11 c0       	mov    0xc01189bc,%eax
c0103d44:	8b 40 08             	mov    0x8(%eax),%eax
c0103d47:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103d4a:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103d4e:	8b 55 08             	mov    0x8(%ebp),%edx
c0103d51:	89 14 24             	mov    %edx,(%esp)
c0103d54:	ff d0                	call   *%eax
}
c0103d56:	c9                   	leave  
c0103d57:	c3                   	ret    

c0103d58 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
c0103d58:	55                   	push   %ebp
c0103d59:	89 e5                	mov    %esp,%ebp
c0103d5b:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
c0103d5e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0103d65:	e8 2e fe ff ff       	call   c0103b98 <__intr_save>
c0103d6a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
c0103d6d:	a1 bc 89 11 c0       	mov    0xc01189bc,%eax
c0103d72:	8b 40 0c             	mov    0xc(%eax),%eax
c0103d75:	8b 55 08             	mov    0x8(%ebp),%edx
c0103d78:	89 14 24             	mov    %edx,(%esp)
c0103d7b:	ff d0                	call   *%eax
c0103d7d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
c0103d80:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103d83:	89 04 24             	mov    %eax,(%esp)
c0103d86:	e8 37 fe ff ff       	call   c0103bc2 <__intr_restore>
    return page;
c0103d8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0103d8e:	c9                   	leave  
c0103d8f:	c3                   	ret    

c0103d90 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
c0103d90:	55                   	push   %ebp
c0103d91:	89 e5                	mov    %esp,%ebp
c0103d93:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0103d96:	e8 fd fd ff ff       	call   c0103b98 <__intr_save>
c0103d9b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c0103d9e:	a1 bc 89 11 c0       	mov    0xc01189bc,%eax
c0103da3:	8b 40 10             	mov    0x10(%eax),%eax
c0103da6:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103da9:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103dad:	8b 55 08             	mov    0x8(%ebp),%edx
c0103db0:	89 14 24             	mov    %edx,(%esp)
c0103db3:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
c0103db5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103db8:	89 04 24             	mov    %eax,(%esp)
c0103dbb:	e8 02 fe ff ff       	call   c0103bc2 <__intr_restore>
}
c0103dc0:	c9                   	leave  
c0103dc1:	c3                   	ret    

c0103dc2 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
c0103dc2:	55                   	push   %ebp
c0103dc3:	89 e5                	mov    %esp,%ebp
c0103dc5:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c0103dc8:	e8 cb fd ff ff       	call   c0103b98 <__intr_save>
c0103dcd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c0103dd0:	a1 bc 89 11 c0       	mov    0xc01189bc,%eax
c0103dd5:	8b 40 14             	mov    0x14(%eax),%eax
c0103dd8:	ff d0                	call   *%eax
c0103dda:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c0103ddd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103de0:	89 04 24             	mov    %eax,(%esp)
c0103de3:	e8 da fd ff ff       	call   c0103bc2 <__intr_restore>
    return ret;
c0103de8:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0103deb:	c9                   	leave  
c0103dec:	c3                   	ret    

c0103ded <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c0103ded:	55                   	push   %ebp
c0103dee:	89 e5                	mov    %esp,%ebp
c0103df0:	57                   	push   %edi
c0103df1:	56                   	push   %esi
c0103df2:	53                   	push   %ebx
c0103df3:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c0103df9:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c0103e00:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c0103e07:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c0103e0e:	c7 04 24 03 6b 10 c0 	movl   $0xc0106b03,(%esp)
c0103e15:	e8 2d c5 ff ff       	call   c0100347 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0103e1a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0103e21:	e9 15 01 00 00       	jmp    c0103f3b <page_init+0x14e>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0103e26:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103e29:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103e2c:	89 d0                	mov    %edx,%eax
c0103e2e:	c1 e0 02             	shl    $0x2,%eax
c0103e31:	01 d0                	add    %edx,%eax
c0103e33:	c1 e0 02             	shl    $0x2,%eax
c0103e36:	01 c8                	add    %ecx,%eax
c0103e38:	8b 50 08             	mov    0x8(%eax),%edx
c0103e3b:	8b 40 04             	mov    0x4(%eax),%eax
c0103e3e:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0103e41:	89 55 bc             	mov    %edx,-0x44(%ebp)
c0103e44:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103e47:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103e4a:	89 d0                	mov    %edx,%eax
c0103e4c:	c1 e0 02             	shl    $0x2,%eax
c0103e4f:	01 d0                	add    %edx,%eax
c0103e51:	c1 e0 02             	shl    $0x2,%eax
c0103e54:	01 c8                	add    %ecx,%eax
c0103e56:	8b 48 0c             	mov    0xc(%eax),%ecx
c0103e59:	8b 58 10             	mov    0x10(%eax),%ebx
c0103e5c:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0103e5f:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0103e62:	01 c8                	add    %ecx,%eax
c0103e64:	11 da                	adc    %ebx,%edx
c0103e66:	89 45 b0             	mov    %eax,-0x50(%ebp)
c0103e69:	89 55 b4             	mov    %edx,-0x4c(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c0103e6c:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103e6f:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103e72:	89 d0                	mov    %edx,%eax
c0103e74:	c1 e0 02             	shl    $0x2,%eax
c0103e77:	01 d0                	add    %edx,%eax
c0103e79:	c1 e0 02             	shl    $0x2,%eax
c0103e7c:	01 c8                	add    %ecx,%eax
c0103e7e:	83 c0 14             	add    $0x14,%eax
c0103e81:	8b 00                	mov    (%eax),%eax
c0103e83:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
c0103e89:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0103e8c:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0103e8f:	83 c0 ff             	add    $0xffffffff,%eax
c0103e92:	83 d2 ff             	adc    $0xffffffff,%edx
c0103e95:	89 c6                	mov    %eax,%esi
c0103e97:	89 d7                	mov    %edx,%edi
c0103e99:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103e9c:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103e9f:	89 d0                	mov    %edx,%eax
c0103ea1:	c1 e0 02             	shl    $0x2,%eax
c0103ea4:	01 d0                	add    %edx,%eax
c0103ea6:	c1 e0 02             	shl    $0x2,%eax
c0103ea9:	01 c8                	add    %ecx,%eax
c0103eab:	8b 48 0c             	mov    0xc(%eax),%ecx
c0103eae:	8b 58 10             	mov    0x10(%eax),%ebx
c0103eb1:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
c0103eb7:	89 44 24 1c          	mov    %eax,0x1c(%esp)
c0103ebb:	89 74 24 14          	mov    %esi,0x14(%esp)
c0103ebf:	89 7c 24 18          	mov    %edi,0x18(%esp)
c0103ec3:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0103ec6:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0103ec9:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103ecd:	89 54 24 10          	mov    %edx,0x10(%esp)
c0103ed1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0103ed5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
c0103ed9:	c7 04 24 10 6b 10 c0 	movl   $0xc0106b10,(%esp)
c0103ee0:	e8 62 c4 ff ff       	call   c0100347 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c0103ee5:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103ee8:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103eeb:	89 d0                	mov    %edx,%eax
c0103eed:	c1 e0 02             	shl    $0x2,%eax
c0103ef0:	01 d0                	add    %edx,%eax
c0103ef2:	c1 e0 02             	shl    $0x2,%eax
c0103ef5:	01 c8                	add    %ecx,%eax
c0103ef7:	83 c0 14             	add    $0x14,%eax
c0103efa:	8b 00                	mov    (%eax),%eax
c0103efc:	83 f8 01             	cmp    $0x1,%eax
c0103eff:	75 36                	jne    c0103f37 <page_init+0x14a>
            if (maxpa < end && begin < KMEMSIZE) {
c0103f01:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103f04:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0103f07:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c0103f0a:	77 2b                	ja     c0103f37 <page_init+0x14a>
c0103f0c:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c0103f0f:	72 05                	jb     c0103f16 <page_init+0x129>
c0103f11:	3b 45 b0             	cmp    -0x50(%ebp),%eax
c0103f14:	73 21                	jae    c0103f37 <page_init+0x14a>
c0103f16:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0103f1a:	77 1b                	ja     c0103f37 <page_init+0x14a>
c0103f1c:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0103f20:	72 09                	jb     c0103f2b <page_init+0x13e>
c0103f22:	81 7d b8 ff ff ff 37 	cmpl   $0x37ffffff,-0x48(%ebp)
c0103f29:	77 0c                	ja     c0103f37 <page_init+0x14a>
                maxpa = end;
c0103f2b:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0103f2e:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0103f31:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0103f34:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
    uint64_t maxpa = 0;

    cprintf("e820map:\n");
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0103f37:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0103f3b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0103f3e:	8b 00                	mov    (%eax),%eax
c0103f40:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c0103f43:	0f 8f dd fe ff ff    	jg     c0103e26 <page_init+0x39>
            if (maxpa < end && begin < KMEMSIZE) {
                maxpa = end;
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c0103f49:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0103f4d:	72 1d                	jb     c0103f6c <page_init+0x17f>
c0103f4f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0103f53:	77 09                	ja     c0103f5e <page_init+0x171>
c0103f55:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
c0103f5c:	76 0e                	jbe    c0103f6c <page_init+0x17f>
        maxpa = KMEMSIZE;
c0103f5e:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c0103f65:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
c0103f6c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103f6f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0103f72:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0103f76:	c1 ea 0c             	shr    $0xc,%edx
c0103f79:	a3 c0 88 11 c0       	mov    %eax,0xc01188c0
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c0103f7e:	c7 45 ac 00 10 00 00 	movl   $0x1000,-0x54(%ebp)
c0103f85:	b8 c8 89 11 c0       	mov    $0xc01189c8,%eax
c0103f8a:	8d 50 ff             	lea    -0x1(%eax),%edx
c0103f8d:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0103f90:	01 d0                	add    %edx,%eax
c0103f92:	89 45 a8             	mov    %eax,-0x58(%ebp)
c0103f95:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0103f98:	ba 00 00 00 00       	mov    $0x0,%edx
c0103f9d:	f7 75 ac             	divl   -0x54(%ebp)
c0103fa0:	89 d0                	mov    %edx,%eax
c0103fa2:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0103fa5:	29 c2                	sub    %eax,%edx
c0103fa7:	89 d0                	mov    %edx,%eax
c0103fa9:	a3 c4 89 11 c0       	mov    %eax,0xc01189c4

    for (i = 0; i < npage; i ++) {
c0103fae:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0103fb5:	eb 2f                	jmp    c0103fe6 <page_init+0x1f9>
        SetPageReserved(pages + i);
c0103fb7:	8b 0d c4 89 11 c0    	mov    0xc01189c4,%ecx
c0103fbd:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103fc0:	89 d0                	mov    %edx,%eax
c0103fc2:	c1 e0 02             	shl    $0x2,%eax
c0103fc5:	01 d0                	add    %edx,%eax
c0103fc7:	c1 e0 02             	shl    $0x2,%eax
c0103fca:	01 c8                	add    %ecx,%eax
c0103fcc:	83 c0 04             	add    $0x4,%eax
c0103fcf:	c7 45 90 00 00 00 00 	movl   $0x0,-0x70(%ebp)
c0103fd6:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0103fd9:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0103fdc:	8b 55 90             	mov    -0x70(%ebp),%edx
c0103fdf:	0f ab 10             	bts    %edx,(%eax)
    extern char end[];

    npage = maxpa / PGSIZE;
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);

    for (i = 0; i < npage; i ++) {
c0103fe2:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0103fe6:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103fe9:	a1 c0 88 11 c0       	mov    0xc01188c0,%eax
c0103fee:	39 c2                	cmp    %eax,%edx
c0103ff0:	72 c5                	jb     c0103fb7 <page_init+0x1ca>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c0103ff2:	8b 15 c0 88 11 c0    	mov    0xc01188c0,%edx
c0103ff8:	89 d0                	mov    %edx,%eax
c0103ffa:	c1 e0 02             	shl    $0x2,%eax
c0103ffd:	01 d0                	add    %edx,%eax
c0103fff:	c1 e0 02             	shl    $0x2,%eax
c0104002:	89 c2                	mov    %eax,%edx
c0104004:	a1 c4 89 11 c0       	mov    0xc01189c4,%eax
c0104009:	01 d0                	add    %edx,%eax
c010400b:	89 45 a4             	mov    %eax,-0x5c(%ebp)
c010400e:	81 7d a4 ff ff ff bf 	cmpl   $0xbfffffff,-0x5c(%ebp)
c0104015:	77 23                	ja     c010403a <page_init+0x24d>
c0104017:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c010401a:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010401e:	c7 44 24 08 40 6b 10 	movl   $0xc0106b40,0x8(%esp)
c0104025:	c0 
c0104026:	c7 44 24 04 db 00 00 	movl   $0xdb,0x4(%esp)
c010402d:	00 
c010402e:	c7 04 24 64 6b 10 c0 	movl   $0xc0106b64,(%esp)
c0104035:	e8 97 cc ff ff       	call   c0100cd1 <__panic>
c010403a:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c010403d:	05 00 00 00 40       	add    $0x40000000,%eax
c0104042:	89 45 a0             	mov    %eax,-0x60(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c0104045:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c010404c:	e9 74 01 00 00       	jmp    c01041c5 <page_init+0x3d8>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0104051:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104054:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104057:	89 d0                	mov    %edx,%eax
c0104059:	c1 e0 02             	shl    $0x2,%eax
c010405c:	01 d0                	add    %edx,%eax
c010405e:	c1 e0 02             	shl    $0x2,%eax
c0104061:	01 c8                	add    %ecx,%eax
c0104063:	8b 50 08             	mov    0x8(%eax),%edx
c0104066:	8b 40 04             	mov    0x4(%eax),%eax
c0104069:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010406c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010406f:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104072:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104075:	89 d0                	mov    %edx,%eax
c0104077:	c1 e0 02             	shl    $0x2,%eax
c010407a:	01 d0                	add    %edx,%eax
c010407c:	c1 e0 02             	shl    $0x2,%eax
c010407f:	01 c8                	add    %ecx,%eax
c0104081:	8b 48 0c             	mov    0xc(%eax),%ecx
c0104084:	8b 58 10             	mov    0x10(%eax),%ebx
c0104087:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010408a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010408d:	01 c8                	add    %ecx,%eax
c010408f:	11 da                	adc    %ebx,%edx
c0104091:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0104094:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c0104097:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c010409a:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010409d:	89 d0                	mov    %edx,%eax
c010409f:	c1 e0 02             	shl    $0x2,%eax
c01040a2:	01 d0                	add    %edx,%eax
c01040a4:	c1 e0 02             	shl    $0x2,%eax
c01040a7:	01 c8                	add    %ecx,%eax
c01040a9:	83 c0 14             	add    $0x14,%eax
c01040ac:	8b 00                	mov    (%eax),%eax
c01040ae:	83 f8 01             	cmp    $0x1,%eax
c01040b1:	0f 85 0a 01 00 00    	jne    c01041c1 <page_init+0x3d4>
            if (begin < freemem) {
c01040b7:	8b 45 a0             	mov    -0x60(%ebp),%eax
c01040ba:	ba 00 00 00 00       	mov    $0x0,%edx
c01040bf:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c01040c2:	72 17                	jb     c01040db <page_init+0x2ee>
c01040c4:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c01040c7:	77 05                	ja     c01040ce <page_init+0x2e1>
c01040c9:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c01040cc:	76 0d                	jbe    c01040db <page_init+0x2ee>
                begin = freemem;
c01040ce:	8b 45 a0             	mov    -0x60(%ebp),%eax
c01040d1:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01040d4:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c01040db:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c01040df:	72 1d                	jb     c01040fe <page_init+0x311>
c01040e1:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c01040e5:	77 09                	ja     c01040f0 <page_init+0x303>
c01040e7:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
c01040ee:	76 0e                	jbe    c01040fe <page_init+0x311>
                end = KMEMSIZE;
c01040f0:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c01040f7:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c01040fe:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104101:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104104:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0104107:	0f 87 b4 00 00 00    	ja     c01041c1 <page_init+0x3d4>
c010410d:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0104110:	72 09                	jb     c010411b <page_init+0x32e>
c0104112:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0104115:	0f 83 a6 00 00 00    	jae    c01041c1 <page_init+0x3d4>
                begin = ROUNDUP(begin, PGSIZE);
c010411b:	c7 45 9c 00 10 00 00 	movl   $0x1000,-0x64(%ebp)
c0104122:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0104125:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0104128:	01 d0                	add    %edx,%eax
c010412a:	83 e8 01             	sub    $0x1,%eax
c010412d:	89 45 98             	mov    %eax,-0x68(%ebp)
c0104130:	8b 45 98             	mov    -0x68(%ebp),%eax
c0104133:	ba 00 00 00 00       	mov    $0x0,%edx
c0104138:	f7 75 9c             	divl   -0x64(%ebp)
c010413b:	89 d0                	mov    %edx,%eax
c010413d:	8b 55 98             	mov    -0x68(%ebp),%edx
c0104140:	29 c2                	sub    %eax,%edx
c0104142:	89 d0                	mov    %edx,%eax
c0104144:	ba 00 00 00 00       	mov    $0x0,%edx
c0104149:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010414c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c010414f:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0104152:	89 45 94             	mov    %eax,-0x6c(%ebp)
c0104155:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0104158:	ba 00 00 00 00       	mov    $0x0,%edx
c010415d:	89 c7                	mov    %eax,%edi
c010415f:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
c0104165:	89 7d 80             	mov    %edi,-0x80(%ebp)
c0104168:	89 d0                	mov    %edx,%eax
c010416a:	83 e0 00             	and    $0x0,%eax
c010416d:	89 45 84             	mov    %eax,-0x7c(%ebp)
c0104170:	8b 45 80             	mov    -0x80(%ebp),%eax
c0104173:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0104176:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0104179:	89 55 cc             	mov    %edx,-0x34(%ebp)
                if (begin < end) {
c010417c:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010417f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104182:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0104185:	77 3a                	ja     c01041c1 <page_init+0x3d4>
c0104187:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c010418a:	72 05                	jb     c0104191 <page_init+0x3a4>
c010418c:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c010418f:	73 30                	jae    c01041c1 <page_init+0x3d4>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c0104191:	8b 4d d0             	mov    -0x30(%ebp),%ecx
c0104194:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
c0104197:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010419a:	8b 55 cc             	mov    -0x34(%ebp),%edx
c010419d:	29 c8                	sub    %ecx,%eax
c010419f:	19 da                	sbb    %ebx,%edx
c01041a1:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c01041a5:	c1 ea 0c             	shr    $0xc,%edx
c01041a8:	89 c3                	mov    %eax,%ebx
c01041aa:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01041ad:	89 04 24             	mov    %eax,(%esp)
c01041b0:	e8 bd f8 ff ff       	call   c0103a72 <pa2page>
c01041b5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01041b9:	89 04 24             	mov    %eax,(%esp)
c01041bc:	e8 78 fb ff ff       	call   c0103d39 <init_memmap>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);

    for (i = 0; i < memmap->nr_map; i ++) {
c01041c1:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c01041c5:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01041c8:	8b 00                	mov    (%eax),%eax
c01041ca:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c01041cd:	0f 8f 7e fe ff ff    	jg     c0104051 <page_init+0x264>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
                }
            }
        }
    }
}
c01041d3:	81 c4 9c 00 00 00    	add    $0x9c,%esp
c01041d9:	5b                   	pop    %ebx
c01041da:	5e                   	pop    %esi
c01041db:	5f                   	pop    %edi
c01041dc:	5d                   	pop    %ebp
c01041dd:	c3                   	ret    

c01041de <enable_paging>:

static void
enable_paging(void) {
c01041de:	55                   	push   %ebp
c01041df:	89 e5                	mov    %esp,%ebp
c01041e1:	83 ec 10             	sub    $0x10,%esp
    lcr3(boot_cr3);
c01041e4:	a1 c0 89 11 c0       	mov    0xc01189c0,%eax
c01041e9:	89 45 f8             	mov    %eax,-0x8(%ebp)
    asm volatile ("mov %0, %%cr0" :: "r" (cr0) : "memory");
}

static inline void
lcr3(uintptr_t cr3) {
    asm volatile ("mov %0, %%cr3" :: "r" (cr3) : "memory");
c01041ec:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01041ef:	0f 22 d8             	mov    %eax,%cr3
}

static inline uintptr_t
rcr0(void) {
    uintptr_t cr0;
    asm volatile ("mov %%cr0, %0" : "=r" (cr0) :: "memory");
c01041f2:	0f 20 c0             	mov    %cr0,%eax
c01041f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return cr0;
c01041f8:	8b 45 f4             	mov    -0xc(%ebp),%eax

    // turn on paging
    uint32_t cr0 = rcr0();
c01041fb:	89 45 fc             	mov    %eax,-0x4(%ebp)
    cr0 |= CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP;
c01041fe:	81 4d fc 2f 00 05 80 	orl    $0x8005002f,-0x4(%ebp)
    cr0 &= ~(CR0_TS | CR0_EM);
c0104205:	83 65 fc f3          	andl   $0xfffffff3,-0x4(%ebp)
c0104209:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010420c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile ("pushl %0; popfl" :: "r" (eflags));
}

static inline void
lcr0(uintptr_t cr0) {
    asm volatile ("mov %0, %%cr0" :: "r" (cr0) : "memory");
c010420f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104212:	0f 22 c0             	mov    %eax,%cr0
    lcr0(cr0);
}
c0104215:	c9                   	leave  
c0104216:	c3                   	ret    

c0104217 <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c0104217:	55                   	push   %ebp
c0104218:	89 e5                	mov    %esp,%ebp
c010421a:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
c010421d:	8b 45 14             	mov    0x14(%ebp),%eax
c0104220:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104223:	31 d0                	xor    %edx,%eax
c0104225:	25 ff 0f 00 00       	and    $0xfff,%eax
c010422a:	85 c0                	test   %eax,%eax
c010422c:	74 24                	je     c0104252 <boot_map_segment+0x3b>
c010422e:	c7 44 24 0c 72 6b 10 	movl   $0xc0106b72,0xc(%esp)
c0104235:	c0 
c0104236:	c7 44 24 08 89 6b 10 	movl   $0xc0106b89,0x8(%esp)
c010423d:	c0 
c010423e:	c7 44 24 04 04 01 00 	movl   $0x104,0x4(%esp)
c0104245:	00 
c0104246:	c7 04 24 64 6b 10 c0 	movl   $0xc0106b64,(%esp)
c010424d:	e8 7f ca ff ff       	call   c0100cd1 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c0104252:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c0104259:	8b 45 0c             	mov    0xc(%ebp),%eax
c010425c:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104261:	89 c2                	mov    %eax,%edx
c0104263:	8b 45 10             	mov    0x10(%ebp),%eax
c0104266:	01 c2                	add    %eax,%edx
c0104268:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010426b:	01 d0                	add    %edx,%eax
c010426d:	83 e8 01             	sub    $0x1,%eax
c0104270:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104273:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104276:	ba 00 00 00 00       	mov    $0x0,%edx
c010427b:	f7 75 f0             	divl   -0x10(%ebp)
c010427e:	89 d0                	mov    %edx,%eax
c0104280:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104283:	29 c2                	sub    %eax,%edx
c0104285:	89 d0                	mov    %edx,%eax
c0104287:	c1 e8 0c             	shr    $0xc,%eax
c010428a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c010428d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104290:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104293:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104296:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010429b:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c010429e:	8b 45 14             	mov    0x14(%ebp),%eax
c01042a1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01042a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01042a7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01042ac:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c01042af:	eb 6b                	jmp    c010431c <boot_map_segment+0x105>
        pte_t *ptep = get_pte(pgdir, la, 1);
c01042b1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c01042b8:	00 
c01042b9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01042bc:	89 44 24 04          	mov    %eax,0x4(%esp)
c01042c0:	8b 45 08             	mov    0x8(%ebp),%eax
c01042c3:	89 04 24             	mov    %eax,(%esp)
c01042c6:	e8 cc 01 00 00       	call   c0104497 <get_pte>
c01042cb:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c01042ce:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c01042d2:	75 24                	jne    c01042f8 <boot_map_segment+0xe1>
c01042d4:	c7 44 24 0c 9e 6b 10 	movl   $0xc0106b9e,0xc(%esp)
c01042db:	c0 
c01042dc:	c7 44 24 08 89 6b 10 	movl   $0xc0106b89,0x8(%esp)
c01042e3:	c0 
c01042e4:	c7 44 24 04 0a 01 00 	movl   $0x10a,0x4(%esp)
c01042eb:	00 
c01042ec:	c7 04 24 64 6b 10 c0 	movl   $0xc0106b64,(%esp)
c01042f3:	e8 d9 c9 ff ff       	call   c0100cd1 <__panic>
        *ptep = pa | PTE_P | perm;
c01042f8:	8b 45 18             	mov    0x18(%ebp),%eax
c01042fb:	8b 55 14             	mov    0x14(%ebp),%edx
c01042fe:	09 d0                	or     %edx,%eax
c0104300:	83 c8 01             	or     $0x1,%eax
c0104303:	89 c2                	mov    %eax,%edx
c0104305:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104308:	89 10                	mov    %edx,(%eax)
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
    assert(PGOFF(la) == PGOFF(pa));
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
    la = ROUNDDOWN(la, PGSIZE);
    pa = ROUNDDOWN(pa, PGSIZE);
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c010430a:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c010430e:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c0104315:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c010431c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104320:	75 8f                	jne    c01042b1 <boot_map_segment+0x9a>
        pte_t *ptep = get_pte(pgdir, la, 1);
        assert(ptep != NULL);
        *ptep = pa | PTE_P | perm;
    }
}
c0104322:	c9                   	leave  
c0104323:	c3                   	ret    

c0104324 <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c0104324:	55                   	push   %ebp
c0104325:	89 e5                	mov    %esp,%ebp
c0104327:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
c010432a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104331:	e8 22 fa ff ff       	call   c0103d58 <alloc_pages>
c0104336:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c0104339:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010433d:	75 1c                	jne    c010435b <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
c010433f:	c7 44 24 08 ab 6b 10 	movl   $0xc0106bab,0x8(%esp)
c0104346:	c0 
c0104347:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
c010434e:	00 
c010434f:	c7 04 24 64 6b 10 c0 	movl   $0xc0106b64,(%esp)
c0104356:	e8 76 c9 ff ff       	call   c0100cd1 <__panic>
    }
    return page2kva(p);
c010435b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010435e:	89 04 24             	mov    %eax,(%esp)
c0104361:	e8 5b f7 ff ff       	call   c0103ac1 <page2kva>
}
c0104366:	c9                   	leave  
c0104367:	c3                   	ret    

c0104368 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c0104368:	55                   	push   %ebp
c0104369:	89 e5                	mov    %esp,%ebp
c010436b:	83 ec 38             	sub    $0x38,%esp
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c010436e:	e8 93 f9 ff ff       	call   c0103d06 <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c0104373:	e8 75 fa ff ff       	call   c0103ded <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c0104378:	e8 66 04 00 00       	call   c01047e3 <check_alloc_page>

    // create boot_pgdir, an initial page directory(Page Directory Table, PDT)
    boot_pgdir = boot_alloc_page();
c010437d:	e8 a2 ff ff ff       	call   c0104324 <boot_alloc_page>
c0104382:	a3 c4 88 11 c0       	mov    %eax,0xc01188c4
    memset(boot_pgdir, 0, PGSIZE);
c0104387:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c010438c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0104393:	00 
c0104394:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010439b:	00 
c010439c:	89 04 24             	mov    %eax,(%esp)
c010439f:	e8 a8 1a 00 00       	call   c0105e4c <memset>
    boot_cr3 = PADDR(boot_pgdir);
c01043a4:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c01043a9:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01043ac:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c01043b3:	77 23                	ja     c01043d8 <pmm_init+0x70>
c01043b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01043b8:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01043bc:	c7 44 24 08 40 6b 10 	movl   $0xc0106b40,0x8(%esp)
c01043c3:	c0 
c01043c4:	c7 44 24 04 30 01 00 	movl   $0x130,0x4(%esp)
c01043cb:	00 
c01043cc:	c7 04 24 64 6b 10 c0 	movl   $0xc0106b64,(%esp)
c01043d3:	e8 f9 c8 ff ff       	call   c0100cd1 <__panic>
c01043d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01043db:	05 00 00 00 40       	add    $0x40000000,%eax
c01043e0:	a3 c0 89 11 c0       	mov    %eax,0xc01189c0

    check_pgdir();
c01043e5:	e8 17 04 00 00       	call   c0104801 <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c01043ea:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c01043ef:	8d 90 ac 0f 00 00    	lea    0xfac(%eax),%edx
c01043f5:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c01043fa:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01043fd:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0104404:	77 23                	ja     c0104429 <pmm_init+0xc1>
c0104406:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104409:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010440d:	c7 44 24 08 40 6b 10 	movl   $0xc0106b40,0x8(%esp)
c0104414:	c0 
c0104415:	c7 44 24 04 38 01 00 	movl   $0x138,0x4(%esp)
c010441c:	00 
c010441d:	c7 04 24 64 6b 10 c0 	movl   $0xc0106b64,(%esp)
c0104424:	e8 a8 c8 ff ff       	call   c0100cd1 <__panic>
c0104429:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010442c:	05 00 00 00 40       	add    $0x40000000,%eax
c0104431:	83 c8 03             	or     $0x3,%eax
c0104434:	89 02                	mov    %eax,(%edx)

    // map all physical memory to linear memory with base linear addr KERNBASE
    //linear_addr KERNBASE~KERNBASE+KMEMSIZE = phy_addr 0~KMEMSIZE
    //But shouldn't use this map until enable_paging() & gdt_init() finished.
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c0104436:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c010443b:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
c0104442:	00 
c0104443:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c010444a:	00 
c010444b:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
c0104452:	38 
c0104453:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
c010445a:	c0 
c010445b:	89 04 24             	mov    %eax,(%esp)
c010445e:	e8 b4 fd ff ff       	call   c0104217 <boot_map_segment>

    //temporary map: 
    //virtual_addr 3G~3G+4M = linear_addr 0~4M = linear_addr 3G~3G+4M = phy_addr 0~4M     
    boot_pgdir[0] = boot_pgdir[PDX(KERNBASE)];
c0104463:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c0104468:	8b 15 c4 88 11 c0    	mov    0xc01188c4,%edx
c010446e:	8b 92 00 0c 00 00    	mov    0xc00(%edx),%edx
c0104474:	89 10                	mov    %edx,(%eax)

    enable_paging();
c0104476:	e8 63 fd ff ff       	call   c01041de <enable_paging>

    //reload gdt(third time,the last time) to map all physical memory
    //virtual_addr 0~4G=liear_addr 0~4G
    //then set kernel stack(ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c010447b:	e8 97 f7 ff ff       	call   c0103c17 <gdt_init>

    //disable the map of virtual_addr 0~4M
    boot_pgdir[0] = 0;
c0104480:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c0104485:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c010448b:	e8 0c 0a 00 00       	call   c0104e9c <check_boot_pgdir>

    print_pgdir();
c0104490:	e8 99 0e 00 00       	call   c010532e <print_pgdir>

}
c0104495:	c9                   	leave  
c0104496:	c3                   	ret    

c0104497 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c0104497:	55                   	push   %ebp
c0104498:	89 e5                	mov    %esp,%ebp
c010449a:	83 ec 38             	sub    $0x38,%esp
                          // (6) clear page content using memset
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
    pde_t *pdep = &pgdir[PDX(la)];
c010449d:	8b 45 0c             	mov    0xc(%ebp),%eax
c01044a0:	c1 e8 16             	shr    $0x16,%eax
c01044a3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01044aa:	8b 45 08             	mov    0x8(%ebp),%eax
c01044ad:	01 d0                	add    %edx,%eax
c01044af:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!(*pdep & PTE_P)) {
c01044b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01044b5:	8b 00                	mov    (%eax),%eax
c01044b7:	83 e0 01             	and    $0x1,%eax
c01044ba:	85 c0                	test   %eax,%eax
c01044bc:	0f 85 af 00 00 00    	jne    c0104571 <get_pte+0xda>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
c01044c2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01044c6:	74 15                	je     c01044dd <get_pte+0x46>
c01044c8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01044cf:	e8 84 f8 ff ff       	call   c0103d58 <alloc_pages>
c01044d4:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01044d7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01044db:	75 0a                	jne    c01044e7 <get_pte+0x50>
            return NULL;
c01044dd:	b8 00 00 00 00       	mov    $0x0,%eax
c01044e2:	e9 e6 00 00 00       	jmp    c01045cd <get_pte+0x136>
        }
        set_page_ref(page, 1);
c01044e7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01044ee:	00 
c01044ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01044f2:	89 04 24             	mov    %eax,(%esp)
c01044f5:	e8 63 f6 ff ff       	call   c0103b5d <set_page_ref>
        uintptr_t pa = page2pa(page);
c01044fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01044fd:	89 04 24             	mov    %eax,(%esp)
c0104500:	e8 57 f5 ff ff       	call   c0103a5c <page2pa>
c0104505:	89 45 ec             	mov    %eax,-0x14(%ebp)
        memset(KADDR(pa), 0, PGSIZE);
c0104508:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010450b:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010450e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104511:	c1 e8 0c             	shr    $0xc,%eax
c0104514:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104517:	a1 c0 88 11 c0       	mov    0xc01188c0,%eax
c010451c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c010451f:	72 23                	jb     c0104544 <get_pte+0xad>
c0104521:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104524:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104528:	c7 44 24 08 9c 6a 10 	movl   $0xc0106a9c,0x8(%esp)
c010452f:	c0 
c0104530:	c7 44 24 04 87 01 00 	movl   $0x187,0x4(%esp)
c0104537:	00 
c0104538:	c7 04 24 64 6b 10 c0 	movl   $0xc0106b64,(%esp)
c010453f:	e8 8d c7 ff ff       	call   c0100cd1 <__panic>
c0104544:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104547:	2d 00 00 00 40       	sub    $0x40000000,%eax
c010454c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0104553:	00 
c0104554:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010455b:	00 
c010455c:	89 04 24             	mov    %eax,(%esp)
c010455f:	e8 e8 18 00 00       	call   c0105e4c <memset>
        *pdep = pa | PTE_U | PTE_W | PTE_P;
c0104564:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104567:	83 c8 07             	or     $0x7,%eax
c010456a:	89 c2                	mov    %eax,%edx
c010456c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010456f:	89 10                	mov    %edx,(%eax)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
c0104571:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104574:	8b 00                	mov    (%eax),%eax
c0104576:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010457b:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010457e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104581:	c1 e8 0c             	shr    $0xc,%eax
c0104584:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0104587:	a1 c0 88 11 c0       	mov    0xc01188c0,%eax
c010458c:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c010458f:	72 23                	jb     c01045b4 <get_pte+0x11d>
c0104591:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104594:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104598:	c7 44 24 08 9c 6a 10 	movl   $0xc0106a9c,0x8(%esp)
c010459f:	c0 
c01045a0:	c7 44 24 04 8a 01 00 	movl   $0x18a,0x4(%esp)
c01045a7:	00 
c01045a8:	c7 04 24 64 6b 10 c0 	movl   $0xc0106b64,(%esp)
c01045af:	e8 1d c7 ff ff       	call   c0100cd1 <__panic>
c01045b4:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01045b7:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01045bc:	8b 55 0c             	mov    0xc(%ebp),%edx
c01045bf:	c1 ea 0c             	shr    $0xc,%edx
c01045c2:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
c01045c8:	c1 e2 02             	shl    $0x2,%edx
c01045cb:	01 d0                	add    %edx,%eax
}
c01045cd:	c9                   	leave  
c01045ce:	c3                   	ret    

c01045cf <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c01045cf:	55                   	push   %ebp
c01045d0:	89 e5                	mov    %esp,%ebp
c01045d2:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c01045d5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01045dc:	00 
c01045dd:	8b 45 0c             	mov    0xc(%ebp),%eax
c01045e0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01045e4:	8b 45 08             	mov    0x8(%ebp),%eax
c01045e7:	89 04 24             	mov    %eax,(%esp)
c01045ea:	e8 a8 fe ff ff       	call   c0104497 <get_pte>
c01045ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c01045f2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01045f6:	74 08                	je     c0104600 <get_page+0x31>
        *ptep_store = ptep;
c01045f8:	8b 45 10             	mov    0x10(%ebp),%eax
c01045fb:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01045fe:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c0104600:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104604:	74 1b                	je     c0104621 <get_page+0x52>
c0104606:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104609:	8b 00                	mov    (%eax),%eax
c010460b:	83 e0 01             	and    $0x1,%eax
c010460e:	85 c0                	test   %eax,%eax
c0104610:	74 0f                	je     c0104621 <get_page+0x52>
        return pa2page(*ptep);
c0104612:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104615:	8b 00                	mov    (%eax),%eax
c0104617:	89 04 24             	mov    %eax,(%esp)
c010461a:	e8 53 f4 ff ff       	call   c0103a72 <pa2page>
c010461f:	eb 05                	jmp    c0104626 <get_page+0x57>
    }
    return NULL;
c0104621:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104626:	c9                   	leave  
c0104627:	c3                   	ret    

c0104628 <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c0104628:	55                   	push   %ebp
c0104629:	89 e5                	mov    %esp,%ebp
c010462b:	83 ec 28             	sub    $0x28,%esp
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
    if (*ptep & PTE_P) {
c010462e:	8b 45 10             	mov    0x10(%ebp),%eax
c0104631:	8b 00                	mov    (%eax),%eax
c0104633:	83 e0 01             	and    $0x1,%eax
c0104636:	85 c0                	test   %eax,%eax
c0104638:	74 4d                	je     c0104687 <page_remove_pte+0x5f>
        struct Page *page = pte2page(*ptep);
c010463a:	8b 45 10             	mov    0x10(%ebp),%eax
c010463d:	8b 00                	mov    (%eax),%eax
c010463f:	89 04 24             	mov    %eax,(%esp)
c0104642:	e8 ce f4 ff ff       	call   c0103b15 <pte2page>
c0104647:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (page_ref_dec(page) == 0) {
c010464a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010464d:	89 04 24             	mov    %eax,(%esp)
c0104650:	e8 2c f5 ff ff       	call   c0103b81 <page_ref_dec>
c0104655:	85 c0                	test   %eax,%eax
c0104657:	75 13                	jne    c010466c <page_remove_pte+0x44>
            free_page(page);
c0104659:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104660:	00 
c0104661:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104664:	89 04 24             	mov    %eax,(%esp)
c0104667:	e8 24 f7 ff ff       	call   c0103d90 <free_pages>
        }
        *ptep = 0;
c010466c:	8b 45 10             	mov    0x10(%ebp),%eax
c010466f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la);
c0104675:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104678:	89 44 24 04          	mov    %eax,0x4(%esp)
c010467c:	8b 45 08             	mov    0x8(%ebp),%eax
c010467f:	89 04 24             	mov    %eax,(%esp)
c0104682:	e8 ff 00 00 00       	call   c0104786 <tlb_invalidate>
    }
}
c0104687:	c9                   	leave  
c0104688:	c3                   	ret    

c0104689 <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c0104689:	55                   	push   %ebp
c010468a:	89 e5                	mov    %esp,%ebp
c010468c:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c010468f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104696:	00 
c0104697:	8b 45 0c             	mov    0xc(%ebp),%eax
c010469a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010469e:	8b 45 08             	mov    0x8(%ebp),%eax
c01046a1:	89 04 24             	mov    %eax,(%esp)
c01046a4:	e8 ee fd ff ff       	call   c0104497 <get_pte>
c01046a9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
c01046ac:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01046b0:	74 19                	je     c01046cb <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
c01046b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046b5:	89 44 24 08          	mov    %eax,0x8(%esp)
c01046b9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01046bc:	89 44 24 04          	mov    %eax,0x4(%esp)
c01046c0:	8b 45 08             	mov    0x8(%ebp),%eax
c01046c3:	89 04 24             	mov    %eax,(%esp)
c01046c6:	e8 5d ff ff ff       	call   c0104628 <page_remove_pte>
    }
}
c01046cb:	c9                   	leave  
c01046cc:	c3                   	ret    

c01046cd <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c01046cd:	55                   	push   %ebp
c01046ce:	89 e5                	mov    %esp,%ebp
c01046d0:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c01046d3:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c01046da:	00 
c01046db:	8b 45 10             	mov    0x10(%ebp),%eax
c01046de:	89 44 24 04          	mov    %eax,0x4(%esp)
c01046e2:	8b 45 08             	mov    0x8(%ebp),%eax
c01046e5:	89 04 24             	mov    %eax,(%esp)
c01046e8:	e8 aa fd ff ff       	call   c0104497 <get_pte>
c01046ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c01046f0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01046f4:	75 0a                	jne    c0104700 <page_insert+0x33>
        return -E_NO_MEM;
c01046f6:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c01046fb:	e9 84 00 00 00       	jmp    c0104784 <page_insert+0xb7>
    }
    page_ref_inc(page);
c0104700:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104703:	89 04 24             	mov    %eax,(%esp)
c0104706:	e8 5f f4 ff ff       	call   c0103b6a <page_ref_inc>
    if (*ptep & PTE_P) {
c010470b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010470e:	8b 00                	mov    (%eax),%eax
c0104710:	83 e0 01             	and    $0x1,%eax
c0104713:	85 c0                	test   %eax,%eax
c0104715:	74 3e                	je     c0104755 <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
c0104717:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010471a:	8b 00                	mov    (%eax),%eax
c010471c:	89 04 24             	mov    %eax,(%esp)
c010471f:	e8 f1 f3 ff ff       	call   c0103b15 <pte2page>
c0104724:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c0104727:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010472a:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010472d:	75 0d                	jne    c010473c <page_insert+0x6f>
            page_ref_dec(page);
c010472f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104732:	89 04 24             	mov    %eax,(%esp)
c0104735:	e8 47 f4 ff ff       	call   c0103b81 <page_ref_dec>
c010473a:	eb 19                	jmp    c0104755 <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c010473c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010473f:	89 44 24 08          	mov    %eax,0x8(%esp)
c0104743:	8b 45 10             	mov    0x10(%ebp),%eax
c0104746:	89 44 24 04          	mov    %eax,0x4(%esp)
c010474a:	8b 45 08             	mov    0x8(%ebp),%eax
c010474d:	89 04 24             	mov    %eax,(%esp)
c0104750:	e8 d3 fe ff ff       	call   c0104628 <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c0104755:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104758:	89 04 24             	mov    %eax,(%esp)
c010475b:	e8 fc f2 ff ff       	call   c0103a5c <page2pa>
c0104760:	0b 45 14             	or     0x14(%ebp),%eax
c0104763:	83 c8 01             	or     $0x1,%eax
c0104766:	89 c2                	mov    %eax,%edx
c0104768:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010476b:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c010476d:	8b 45 10             	mov    0x10(%ebp),%eax
c0104770:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104774:	8b 45 08             	mov    0x8(%ebp),%eax
c0104777:	89 04 24             	mov    %eax,(%esp)
c010477a:	e8 07 00 00 00       	call   c0104786 <tlb_invalidate>
    return 0;
c010477f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104784:	c9                   	leave  
c0104785:	c3                   	ret    

c0104786 <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c0104786:	55                   	push   %ebp
c0104787:	89 e5                	mov    %esp,%ebp
c0104789:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c010478c:	0f 20 d8             	mov    %cr3,%eax
c010478f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
c0104792:	8b 45 f0             	mov    -0x10(%ebp),%eax
    if (rcr3() == PADDR(pgdir)) {
c0104795:	89 c2                	mov    %eax,%edx
c0104797:	8b 45 08             	mov    0x8(%ebp),%eax
c010479a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010479d:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c01047a4:	77 23                	ja     c01047c9 <tlb_invalidate+0x43>
c01047a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01047a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01047ad:	c7 44 24 08 40 6b 10 	movl   $0xc0106b40,0x8(%esp)
c01047b4:	c0 
c01047b5:	c7 44 24 04 ec 01 00 	movl   $0x1ec,0x4(%esp)
c01047bc:	00 
c01047bd:	c7 04 24 64 6b 10 c0 	movl   $0xc0106b64,(%esp)
c01047c4:	e8 08 c5 ff ff       	call   c0100cd1 <__panic>
c01047c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01047cc:	05 00 00 00 40       	add    $0x40000000,%eax
c01047d1:	39 c2                	cmp    %eax,%edx
c01047d3:	75 0c                	jne    c01047e1 <tlb_invalidate+0x5b>
        invlpg((void *)la);
c01047d5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01047d8:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c01047db:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01047de:	0f 01 38             	invlpg (%eax)
    }
}
c01047e1:	c9                   	leave  
c01047e2:	c3                   	ret    

c01047e3 <check_alloc_page>:

static void
check_alloc_page(void) {
c01047e3:	55                   	push   %ebp
c01047e4:	89 e5                	mov    %esp,%ebp
c01047e6:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
c01047e9:	a1 bc 89 11 c0       	mov    0xc01189bc,%eax
c01047ee:	8b 40 18             	mov    0x18(%eax),%eax
c01047f1:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c01047f3:	c7 04 24 c4 6b 10 c0 	movl   $0xc0106bc4,(%esp)
c01047fa:	e8 48 bb ff ff       	call   c0100347 <cprintf>
}
c01047ff:	c9                   	leave  
c0104800:	c3                   	ret    

c0104801 <check_pgdir>:

static void
check_pgdir(void) {
c0104801:	55                   	push   %ebp
c0104802:	89 e5                	mov    %esp,%ebp
c0104804:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c0104807:	a1 c0 88 11 c0       	mov    0xc01188c0,%eax
c010480c:	3d 00 80 03 00       	cmp    $0x38000,%eax
c0104811:	76 24                	jbe    c0104837 <check_pgdir+0x36>
c0104813:	c7 44 24 0c e3 6b 10 	movl   $0xc0106be3,0xc(%esp)
c010481a:	c0 
c010481b:	c7 44 24 08 89 6b 10 	movl   $0xc0106b89,0x8(%esp)
c0104822:	c0 
c0104823:	c7 44 24 04 f9 01 00 	movl   $0x1f9,0x4(%esp)
c010482a:	00 
c010482b:	c7 04 24 64 6b 10 c0 	movl   $0xc0106b64,(%esp)
c0104832:	e8 9a c4 ff ff       	call   c0100cd1 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c0104837:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c010483c:	85 c0                	test   %eax,%eax
c010483e:	74 0e                	je     c010484e <check_pgdir+0x4d>
c0104840:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c0104845:	25 ff 0f 00 00       	and    $0xfff,%eax
c010484a:	85 c0                	test   %eax,%eax
c010484c:	74 24                	je     c0104872 <check_pgdir+0x71>
c010484e:	c7 44 24 0c 00 6c 10 	movl   $0xc0106c00,0xc(%esp)
c0104855:	c0 
c0104856:	c7 44 24 08 89 6b 10 	movl   $0xc0106b89,0x8(%esp)
c010485d:	c0 
c010485e:	c7 44 24 04 fa 01 00 	movl   $0x1fa,0x4(%esp)
c0104865:	00 
c0104866:	c7 04 24 64 6b 10 c0 	movl   $0xc0106b64,(%esp)
c010486d:	e8 5f c4 ff ff       	call   c0100cd1 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c0104872:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c0104877:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010487e:	00 
c010487f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104886:	00 
c0104887:	89 04 24             	mov    %eax,(%esp)
c010488a:	e8 40 fd ff ff       	call   c01045cf <get_page>
c010488f:	85 c0                	test   %eax,%eax
c0104891:	74 24                	je     c01048b7 <check_pgdir+0xb6>
c0104893:	c7 44 24 0c 38 6c 10 	movl   $0xc0106c38,0xc(%esp)
c010489a:	c0 
c010489b:	c7 44 24 08 89 6b 10 	movl   $0xc0106b89,0x8(%esp)
c01048a2:	c0 
c01048a3:	c7 44 24 04 fb 01 00 	movl   $0x1fb,0x4(%esp)
c01048aa:	00 
c01048ab:	c7 04 24 64 6b 10 c0 	movl   $0xc0106b64,(%esp)
c01048b2:	e8 1a c4 ff ff       	call   c0100cd1 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c01048b7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01048be:	e8 95 f4 ff ff       	call   c0103d58 <alloc_pages>
c01048c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c01048c6:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c01048cb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01048d2:	00 
c01048d3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01048da:	00 
c01048db:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01048de:	89 54 24 04          	mov    %edx,0x4(%esp)
c01048e2:	89 04 24             	mov    %eax,(%esp)
c01048e5:	e8 e3 fd ff ff       	call   c01046cd <page_insert>
c01048ea:	85 c0                	test   %eax,%eax
c01048ec:	74 24                	je     c0104912 <check_pgdir+0x111>
c01048ee:	c7 44 24 0c 60 6c 10 	movl   $0xc0106c60,0xc(%esp)
c01048f5:	c0 
c01048f6:	c7 44 24 08 89 6b 10 	movl   $0xc0106b89,0x8(%esp)
c01048fd:	c0 
c01048fe:	c7 44 24 04 ff 01 00 	movl   $0x1ff,0x4(%esp)
c0104905:	00 
c0104906:	c7 04 24 64 6b 10 c0 	movl   $0xc0106b64,(%esp)
c010490d:	e8 bf c3 ff ff       	call   c0100cd1 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c0104912:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c0104917:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010491e:	00 
c010491f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104926:	00 
c0104927:	89 04 24             	mov    %eax,(%esp)
c010492a:	e8 68 fb ff ff       	call   c0104497 <get_pte>
c010492f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104932:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104936:	75 24                	jne    c010495c <check_pgdir+0x15b>
c0104938:	c7 44 24 0c 8c 6c 10 	movl   $0xc0106c8c,0xc(%esp)
c010493f:	c0 
c0104940:	c7 44 24 08 89 6b 10 	movl   $0xc0106b89,0x8(%esp)
c0104947:	c0 
c0104948:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
c010494f:	00 
c0104950:	c7 04 24 64 6b 10 c0 	movl   $0xc0106b64,(%esp)
c0104957:	e8 75 c3 ff ff       	call   c0100cd1 <__panic>
    assert(pa2page(*ptep) == p1);
c010495c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010495f:	8b 00                	mov    (%eax),%eax
c0104961:	89 04 24             	mov    %eax,(%esp)
c0104964:	e8 09 f1 ff ff       	call   c0103a72 <pa2page>
c0104969:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010496c:	74 24                	je     c0104992 <check_pgdir+0x191>
c010496e:	c7 44 24 0c b9 6c 10 	movl   $0xc0106cb9,0xc(%esp)
c0104975:	c0 
c0104976:	c7 44 24 08 89 6b 10 	movl   $0xc0106b89,0x8(%esp)
c010497d:	c0 
c010497e:	c7 44 24 04 03 02 00 	movl   $0x203,0x4(%esp)
c0104985:	00 
c0104986:	c7 04 24 64 6b 10 c0 	movl   $0xc0106b64,(%esp)
c010498d:	e8 3f c3 ff ff       	call   c0100cd1 <__panic>
    assert(page_ref(p1) == 1);
c0104992:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104995:	89 04 24             	mov    %eax,(%esp)
c0104998:	e8 b6 f1 ff ff       	call   c0103b53 <page_ref>
c010499d:	83 f8 01             	cmp    $0x1,%eax
c01049a0:	74 24                	je     c01049c6 <check_pgdir+0x1c5>
c01049a2:	c7 44 24 0c ce 6c 10 	movl   $0xc0106cce,0xc(%esp)
c01049a9:	c0 
c01049aa:	c7 44 24 08 89 6b 10 	movl   $0xc0106b89,0x8(%esp)
c01049b1:	c0 
c01049b2:	c7 44 24 04 04 02 00 	movl   $0x204,0x4(%esp)
c01049b9:	00 
c01049ba:	c7 04 24 64 6b 10 c0 	movl   $0xc0106b64,(%esp)
c01049c1:	e8 0b c3 ff ff       	call   c0100cd1 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c01049c6:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c01049cb:	8b 00                	mov    (%eax),%eax
c01049cd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01049d2:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01049d5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01049d8:	c1 e8 0c             	shr    $0xc,%eax
c01049db:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01049de:	a1 c0 88 11 c0       	mov    0xc01188c0,%eax
c01049e3:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c01049e6:	72 23                	jb     c0104a0b <check_pgdir+0x20a>
c01049e8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01049eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01049ef:	c7 44 24 08 9c 6a 10 	movl   $0xc0106a9c,0x8(%esp)
c01049f6:	c0 
c01049f7:	c7 44 24 04 06 02 00 	movl   $0x206,0x4(%esp)
c01049fe:	00 
c01049ff:	c7 04 24 64 6b 10 c0 	movl   $0xc0106b64,(%esp)
c0104a06:	e8 c6 c2 ff ff       	call   c0100cd1 <__panic>
c0104a0b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104a0e:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0104a13:	83 c0 04             	add    $0x4,%eax
c0104a16:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c0104a19:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c0104a1e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104a25:	00 
c0104a26:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0104a2d:	00 
c0104a2e:	89 04 24             	mov    %eax,(%esp)
c0104a31:	e8 61 fa ff ff       	call   c0104497 <get_pte>
c0104a36:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0104a39:	74 24                	je     c0104a5f <check_pgdir+0x25e>
c0104a3b:	c7 44 24 0c e0 6c 10 	movl   $0xc0106ce0,0xc(%esp)
c0104a42:	c0 
c0104a43:	c7 44 24 08 89 6b 10 	movl   $0xc0106b89,0x8(%esp)
c0104a4a:	c0 
c0104a4b:	c7 44 24 04 07 02 00 	movl   $0x207,0x4(%esp)
c0104a52:	00 
c0104a53:	c7 04 24 64 6b 10 c0 	movl   $0xc0106b64,(%esp)
c0104a5a:	e8 72 c2 ff ff       	call   c0100cd1 <__panic>

    p2 = alloc_page();
c0104a5f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104a66:	e8 ed f2 ff ff       	call   c0103d58 <alloc_pages>
c0104a6b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c0104a6e:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c0104a73:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
c0104a7a:	00 
c0104a7b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0104a82:	00 
c0104a83:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0104a86:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104a8a:	89 04 24             	mov    %eax,(%esp)
c0104a8d:	e8 3b fc ff ff       	call   c01046cd <page_insert>
c0104a92:	85 c0                	test   %eax,%eax
c0104a94:	74 24                	je     c0104aba <check_pgdir+0x2b9>
c0104a96:	c7 44 24 0c 08 6d 10 	movl   $0xc0106d08,0xc(%esp)
c0104a9d:	c0 
c0104a9e:	c7 44 24 08 89 6b 10 	movl   $0xc0106b89,0x8(%esp)
c0104aa5:	c0 
c0104aa6:	c7 44 24 04 0a 02 00 	movl   $0x20a,0x4(%esp)
c0104aad:	00 
c0104aae:	c7 04 24 64 6b 10 c0 	movl   $0xc0106b64,(%esp)
c0104ab5:	e8 17 c2 ff ff       	call   c0100cd1 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0104aba:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c0104abf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104ac6:	00 
c0104ac7:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0104ace:	00 
c0104acf:	89 04 24             	mov    %eax,(%esp)
c0104ad2:	e8 c0 f9 ff ff       	call   c0104497 <get_pte>
c0104ad7:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104ada:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104ade:	75 24                	jne    c0104b04 <check_pgdir+0x303>
c0104ae0:	c7 44 24 0c 40 6d 10 	movl   $0xc0106d40,0xc(%esp)
c0104ae7:	c0 
c0104ae8:	c7 44 24 08 89 6b 10 	movl   $0xc0106b89,0x8(%esp)
c0104aef:	c0 
c0104af0:	c7 44 24 04 0b 02 00 	movl   $0x20b,0x4(%esp)
c0104af7:	00 
c0104af8:	c7 04 24 64 6b 10 c0 	movl   $0xc0106b64,(%esp)
c0104aff:	e8 cd c1 ff ff       	call   c0100cd1 <__panic>
    assert(*ptep & PTE_U);
c0104b04:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104b07:	8b 00                	mov    (%eax),%eax
c0104b09:	83 e0 04             	and    $0x4,%eax
c0104b0c:	85 c0                	test   %eax,%eax
c0104b0e:	75 24                	jne    c0104b34 <check_pgdir+0x333>
c0104b10:	c7 44 24 0c 70 6d 10 	movl   $0xc0106d70,0xc(%esp)
c0104b17:	c0 
c0104b18:	c7 44 24 08 89 6b 10 	movl   $0xc0106b89,0x8(%esp)
c0104b1f:	c0 
c0104b20:	c7 44 24 04 0c 02 00 	movl   $0x20c,0x4(%esp)
c0104b27:	00 
c0104b28:	c7 04 24 64 6b 10 c0 	movl   $0xc0106b64,(%esp)
c0104b2f:	e8 9d c1 ff ff       	call   c0100cd1 <__panic>
    assert(*ptep & PTE_W);
c0104b34:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104b37:	8b 00                	mov    (%eax),%eax
c0104b39:	83 e0 02             	and    $0x2,%eax
c0104b3c:	85 c0                	test   %eax,%eax
c0104b3e:	75 24                	jne    c0104b64 <check_pgdir+0x363>
c0104b40:	c7 44 24 0c 7e 6d 10 	movl   $0xc0106d7e,0xc(%esp)
c0104b47:	c0 
c0104b48:	c7 44 24 08 89 6b 10 	movl   $0xc0106b89,0x8(%esp)
c0104b4f:	c0 
c0104b50:	c7 44 24 04 0d 02 00 	movl   $0x20d,0x4(%esp)
c0104b57:	00 
c0104b58:	c7 04 24 64 6b 10 c0 	movl   $0xc0106b64,(%esp)
c0104b5f:	e8 6d c1 ff ff       	call   c0100cd1 <__panic>
    assert(boot_pgdir[0] & PTE_U);
c0104b64:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c0104b69:	8b 00                	mov    (%eax),%eax
c0104b6b:	83 e0 04             	and    $0x4,%eax
c0104b6e:	85 c0                	test   %eax,%eax
c0104b70:	75 24                	jne    c0104b96 <check_pgdir+0x395>
c0104b72:	c7 44 24 0c 8c 6d 10 	movl   $0xc0106d8c,0xc(%esp)
c0104b79:	c0 
c0104b7a:	c7 44 24 08 89 6b 10 	movl   $0xc0106b89,0x8(%esp)
c0104b81:	c0 
c0104b82:	c7 44 24 04 0e 02 00 	movl   $0x20e,0x4(%esp)
c0104b89:	00 
c0104b8a:	c7 04 24 64 6b 10 c0 	movl   $0xc0106b64,(%esp)
c0104b91:	e8 3b c1 ff ff       	call   c0100cd1 <__panic>
    assert(page_ref(p2) == 1);
c0104b96:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104b99:	89 04 24             	mov    %eax,(%esp)
c0104b9c:	e8 b2 ef ff ff       	call   c0103b53 <page_ref>
c0104ba1:	83 f8 01             	cmp    $0x1,%eax
c0104ba4:	74 24                	je     c0104bca <check_pgdir+0x3c9>
c0104ba6:	c7 44 24 0c a2 6d 10 	movl   $0xc0106da2,0xc(%esp)
c0104bad:	c0 
c0104bae:	c7 44 24 08 89 6b 10 	movl   $0xc0106b89,0x8(%esp)
c0104bb5:	c0 
c0104bb6:	c7 44 24 04 0f 02 00 	movl   $0x20f,0x4(%esp)
c0104bbd:	00 
c0104bbe:	c7 04 24 64 6b 10 c0 	movl   $0xc0106b64,(%esp)
c0104bc5:	e8 07 c1 ff ff       	call   c0100cd1 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c0104bca:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c0104bcf:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0104bd6:	00 
c0104bd7:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0104bde:	00 
c0104bdf:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104be2:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104be6:	89 04 24             	mov    %eax,(%esp)
c0104be9:	e8 df fa ff ff       	call   c01046cd <page_insert>
c0104bee:	85 c0                	test   %eax,%eax
c0104bf0:	74 24                	je     c0104c16 <check_pgdir+0x415>
c0104bf2:	c7 44 24 0c b4 6d 10 	movl   $0xc0106db4,0xc(%esp)
c0104bf9:	c0 
c0104bfa:	c7 44 24 08 89 6b 10 	movl   $0xc0106b89,0x8(%esp)
c0104c01:	c0 
c0104c02:	c7 44 24 04 11 02 00 	movl   $0x211,0x4(%esp)
c0104c09:	00 
c0104c0a:	c7 04 24 64 6b 10 c0 	movl   $0xc0106b64,(%esp)
c0104c11:	e8 bb c0 ff ff       	call   c0100cd1 <__panic>
    assert(page_ref(p1) == 2);
c0104c16:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c19:	89 04 24             	mov    %eax,(%esp)
c0104c1c:	e8 32 ef ff ff       	call   c0103b53 <page_ref>
c0104c21:	83 f8 02             	cmp    $0x2,%eax
c0104c24:	74 24                	je     c0104c4a <check_pgdir+0x449>
c0104c26:	c7 44 24 0c e0 6d 10 	movl   $0xc0106de0,0xc(%esp)
c0104c2d:	c0 
c0104c2e:	c7 44 24 08 89 6b 10 	movl   $0xc0106b89,0x8(%esp)
c0104c35:	c0 
c0104c36:	c7 44 24 04 12 02 00 	movl   $0x212,0x4(%esp)
c0104c3d:	00 
c0104c3e:	c7 04 24 64 6b 10 c0 	movl   $0xc0106b64,(%esp)
c0104c45:	e8 87 c0 ff ff       	call   c0100cd1 <__panic>
    assert(page_ref(p2) == 0);
c0104c4a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104c4d:	89 04 24             	mov    %eax,(%esp)
c0104c50:	e8 fe ee ff ff       	call   c0103b53 <page_ref>
c0104c55:	85 c0                	test   %eax,%eax
c0104c57:	74 24                	je     c0104c7d <check_pgdir+0x47c>
c0104c59:	c7 44 24 0c f2 6d 10 	movl   $0xc0106df2,0xc(%esp)
c0104c60:	c0 
c0104c61:	c7 44 24 08 89 6b 10 	movl   $0xc0106b89,0x8(%esp)
c0104c68:	c0 
c0104c69:	c7 44 24 04 13 02 00 	movl   $0x213,0x4(%esp)
c0104c70:	00 
c0104c71:	c7 04 24 64 6b 10 c0 	movl   $0xc0106b64,(%esp)
c0104c78:	e8 54 c0 ff ff       	call   c0100cd1 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0104c7d:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c0104c82:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104c89:	00 
c0104c8a:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0104c91:	00 
c0104c92:	89 04 24             	mov    %eax,(%esp)
c0104c95:	e8 fd f7 ff ff       	call   c0104497 <get_pte>
c0104c9a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104c9d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104ca1:	75 24                	jne    c0104cc7 <check_pgdir+0x4c6>
c0104ca3:	c7 44 24 0c 40 6d 10 	movl   $0xc0106d40,0xc(%esp)
c0104caa:	c0 
c0104cab:	c7 44 24 08 89 6b 10 	movl   $0xc0106b89,0x8(%esp)
c0104cb2:	c0 
c0104cb3:	c7 44 24 04 14 02 00 	movl   $0x214,0x4(%esp)
c0104cba:	00 
c0104cbb:	c7 04 24 64 6b 10 c0 	movl   $0xc0106b64,(%esp)
c0104cc2:	e8 0a c0 ff ff       	call   c0100cd1 <__panic>
    assert(pa2page(*ptep) == p1);
c0104cc7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104cca:	8b 00                	mov    (%eax),%eax
c0104ccc:	89 04 24             	mov    %eax,(%esp)
c0104ccf:	e8 9e ed ff ff       	call   c0103a72 <pa2page>
c0104cd4:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104cd7:	74 24                	je     c0104cfd <check_pgdir+0x4fc>
c0104cd9:	c7 44 24 0c b9 6c 10 	movl   $0xc0106cb9,0xc(%esp)
c0104ce0:	c0 
c0104ce1:	c7 44 24 08 89 6b 10 	movl   $0xc0106b89,0x8(%esp)
c0104ce8:	c0 
c0104ce9:	c7 44 24 04 15 02 00 	movl   $0x215,0x4(%esp)
c0104cf0:	00 
c0104cf1:	c7 04 24 64 6b 10 c0 	movl   $0xc0106b64,(%esp)
c0104cf8:	e8 d4 bf ff ff       	call   c0100cd1 <__panic>
    assert((*ptep & PTE_U) == 0);
c0104cfd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104d00:	8b 00                	mov    (%eax),%eax
c0104d02:	83 e0 04             	and    $0x4,%eax
c0104d05:	85 c0                	test   %eax,%eax
c0104d07:	74 24                	je     c0104d2d <check_pgdir+0x52c>
c0104d09:	c7 44 24 0c 04 6e 10 	movl   $0xc0106e04,0xc(%esp)
c0104d10:	c0 
c0104d11:	c7 44 24 08 89 6b 10 	movl   $0xc0106b89,0x8(%esp)
c0104d18:	c0 
c0104d19:	c7 44 24 04 16 02 00 	movl   $0x216,0x4(%esp)
c0104d20:	00 
c0104d21:	c7 04 24 64 6b 10 c0 	movl   $0xc0106b64,(%esp)
c0104d28:	e8 a4 bf ff ff       	call   c0100cd1 <__panic>

    page_remove(boot_pgdir, 0x0);
c0104d2d:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c0104d32:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104d39:	00 
c0104d3a:	89 04 24             	mov    %eax,(%esp)
c0104d3d:	e8 47 f9 ff ff       	call   c0104689 <page_remove>
    assert(page_ref(p1) == 1);
c0104d42:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d45:	89 04 24             	mov    %eax,(%esp)
c0104d48:	e8 06 ee ff ff       	call   c0103b53 <page_ref>
c0104d4d:	83 f8 01             	cmp    $0x1,%eax
c0104d50:	74 24                	je     c0104d76 <check_pgdir+0x575>
c0104d52:	c7 44 24 0c ce 6c 10 	movl   $0xc0106cce,0xc(%esp)
c0104d59:	c0 
c0104d5a:	c7 44 24 08 89 6b 10 	movl   $0xc0106b89,0x8(%esp)
c0104d61:	c0 
c0104d62:	c7 44 24 04 19 02 00 	movl   $0x219,0x4(%esp)
c0104d69:	00 
c0104d6a:	c7 04 24 64 6b 10 c0 	movl   $0xc0106b64,(%esp)
c0104d71:	e8 5b bf ff ff       	call   c0100cd1 <__panic>
    assert(page_ref(p2) == 0);
c0104d76:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104d79:	89 04 24             	mov    %eax,(%esp)
c0104d7c:	e8 d2 ed ff ff       	call   c0103b53 <page_ref>
c0104d81:	85 c0                	test   %eax,%eax
c0104d83:	74 24                	je     c0104da9 <check_pgdir+0x5a8>
c0104d85:	c7 44 24 0c f2 6d 10 	movl   $0xc0106df2,0xc(%esp)
c0104d8c:	c0 
c0104d8d:	c7 44 24 08 89 6b 10 	movl   $0xc0106b89,0x8(%esp)
c0104d94:	c0 
c0104d95:	c7 44 24 04 1a 02 00 	movl   $0x21a,0x4(%esp)
c0104d9c:	00 
c0104d9d:	c7 04 24 64 6b 10 c0 	movl   $0xc0106b64,(%esp)
c0104da4:	e8 28 bf ff ff       	call   c0100cd1 <__panic>

    page_remove(boot_pgdir, PGSIZE);
c0104da9:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c0104dae:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0104db5:	00 
c0104db6:	89 04 24             	mov    %eax,(%esp)
c0104db9:	e8 cb f8 ff ff       	call   c0104689 <page_remove>
    assert(page_ref(p1) == 0);
c0104dbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104dc1:	89 04 24             	mov    %eax,(%esp)
c0104dc4:	e8 8a ed ff ff       	call   c0103b53 <page_ref>
c0104dc9:	85 c0                	test   %eax,%eax
c0104dcb:	74 24                	je     c0104df1 <check_pgdir+0x5f0>
c0104dcd:	c7 44 24 0c 19 6e 10 	movl   $0xc0106e19,0xc(%esp)
c0104dd4:	c0 
c0104dd5:	c7 44 24 08 89 6b 10 	movl   $0xc0106b89,0x8(%esp)
c0104ddc:	c0 
c0104ddd:	c7 44 24 04 1d 02 00 	movl   $0x21d,0x4(%esp)
c0104de4:	00 
c0104de5:	c7 04 24 64 6b 10 c0 	movl   $0xc0106b64,(%esp)
c0104dec:	e8 e0 be ff ff       	call   c0100cd1 <__panic>
    assert(page_ref(p2) == 0);
c0104df1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104df4:	89 04 24             	mov    %eax,(%esp)
c0104df7:	e8 57 ed ff ff       	call   c0103b53 <page_ref>
c0104dfc:	85 c0                	test   %eax,%eax
c0104dfe:	74 24                	je     c0104e24 <check_pgdir+0x623>
c0104e00:	c7 44 24 0c f2 6d 10 	movl   $0xc0106df2,0xc(%esp)
c0104e07:	c0 
c0104e08:	c7 44 24 08 89 6b 10 	movl   $0xc0106b89,0x8(%esp)
c0104e0f:	c0 
c0104e10:	c7 44 24 04 1e 02 00 	movl   $0x21e,0x4(%esp)
c0104e17:	00 
c0104e18:	c7 04 24 64 6b 10 c0 	movl   $0xc0106b64,(%esp)
c0104e1f:	e8 ad be ff ff       	call   c0100cd1 <__panic>

    assert(page_ref(pa2page(boot_pgdir[0])) == 1);
c0104e24:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c0104e29:	8b 00                	mov    (%eax),%eax
c0104e2b:	89 04 24             	mov    %eax,(%esp)
c0104e2e:	e8 3f ec ff ff       	call   c0103a72 <pa2page>
c0104e33:	89 04 24             	mov    %eax,(%esp)
c0104e36:	e8 18 ed ff ff       	call   c0103b53 <page_ref>
c0104e3b:	83 f8 01             	cmp    $0x1,%eax
c0104e3e:	74 24                	je     c0104e64 <check_pgdir+0x663>
c0104e40:	c7 44 24 0c 2c 6e 10 	movl   $0xc0106e2c,0xc(%esp)
c0104e47:	c0 
c0104e48:	c7 44 24 08 89 6b 10 	movl   $0xc0106b89,0x8(%esp)
c0104e4f:	c0 
c0104e50:	c7 44 24 04 20 02 00 	movl   $0x220,0x4(%esp)
c0104e57:	00 
c0104e58:	c7 04 24 64 6b 10 c0 	movl   $0xc0106b64,(%esp)
c0104e5f:	e8 6d be ff ff       	call   c0100cd1 <__panic>
    free_page(pa2page(boot_pgdir[0]));
c0104e64:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c0104e69:	8b 00                	mov    (%eax),%eax
c0104e6b:	89 04 24             	mov    %eax,(%esp)
c0104e6e:	e8 ff eb ff ff       	call   c0103a72 <pa2page>
c0104e73:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104e7a:	00 
c0104e7b:	89 04 24             	mov    %eax,(%esp)
c0104e7e:	e8 0d ef ff ff       	call   c0103d90 <free_pages>
    boot_pgdir[0] = 0;
c0104e83:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c0104e88:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c0104e8e:	c7 04 24 52 6e 10 c0 	movl   $0xc0106e52,(%esp)
c0104e95:	e8 ad b4 ff ff       	call   c0100347 <cprintf>
}
c0104e9a:	c9                   	leave  
c0104e9b:	c3                   	ret    

c0104e9c <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c0104e9c:	55                   	push   %ebp
c0104e9d:	89 e5                	mov    %esp,%ebp
c0104e9f:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0104ea2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0104ea9:	e9 ca 00 00 00       	jmp    c0104f78 <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c0104eae:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104eb1:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104eb4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104eb7:	c1 e8 0c             	shr    $0xc,%eax
c0104eba:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104ebd:	a1 c0 88 11 c0       	mov    0xc01188c0,%eax
c0104ec2:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0104ec5:	72 23                	jb     c0104eea <check_boot_pgdir+0x4e>
c0104ec7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104eca:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104ece:	c7 44 24 08 9c 6a 10 	movl   $0xc0106a9c,0x8(%esp)
c0104ed5:	c0 
c0104ed6:	c7 44 24 04 2c 02 00 	movl   $0x22c,0x4(%esp)
c0104edd:	00 
c0104ede:	c7 04 24 64 6b 10 c0 	movl   $0xc0106b64,(%esp)
c0104ee5:	e8 e7 bd ff ff       	call   c0100cd1 <__panic>
c0104eea:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104eed:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0104ef2:	89 c2                	mov    %eax,%edx
c0104ef4:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c0104ef9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104f00:	00 
c0104f01:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104f05:	89 04 24             	mov    %eax,(%esp)
c0104f08:	e8 8a f5 ff ff       	call   c0104497 <get_pte>
c0104f0d:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104f10:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0104f14:	75 24                	jne    c0104f3a <check_boot_pgdir+0x9e>
c0104f16:	c7 44 24 0c 6c 6e 10 	movl   $0xc0106e6c,0xc(%esp)
c0104f1d:	c0 
c0104f1e:	c7 44 24 08 89 6b 10 	movl   $0xc0106b89,0x8(%esp)
c0104f25:	c0 
c0104f26:	c7 44 24 04 2c 02 00 	movl   $0x22c,0x4(%esp)
c0104f2d:	00 
c0104f2e:	c7 04 24 64 6b 10 c0 	movl   $0xc0106b64,(%esp)
c0104f35:	e8 97 bd ff ff       	call   c0100cd1 <__panic>
        assert(PTE_ADDR(*ptep) == i);
c0104f3a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104f3d:	8b 00                	mov    (%eax),%eax
c0104f3f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104f44:	89 c2                	mov    %eax,%edx
c0104f46:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104f49:	39 c2                	cmp    %eax,%edx
c0104f4b:	74 24                	je     c0104f71 <check_boot_pgdir+0xd5>
c0104f4d:	c7 44 24 0c a9 6e 10 	movl   $0xc0106ea9,0xc(%esp)
c0104f54:	c0 
c0104f55:	c7 44 24 08 89 6b 10 	movl   $0xc0106b89,0x8(%esp)
c0104f5c:	c0 
c0104f5d:	c7 44 24 04 2d 02 00 	movl   $0x22d,0x4(%esp)
c0104f64:	00 
c0104f65:	c7 04 24 64 6b 10 c0 	movl   $0xc0106b64,(%esp)
c0104f6c:	e8 60 bd ff ff       	call   c0100cd1 <__panic>

static void
check_boot_pgdir(void) {
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0104f71:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c0104f78:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104f7b:	a1 c0 88 11 c0       	mov    0xc01188c0,%eax
c0104f80:	39 c2                	cmp    %eax,%edx
c0104f82:	0f 82 26 ff ff ff    	jb     c0104eae <check_boot_pgdir+0x12>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c0104f88:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c0104f8d:	05 ac 0f 00 00       	add    $0xfac,%eax
c0104f92:	8b 00                	mov    (%eax),%eax
c0104f94:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104f99:	89 c2                	mov    %eax,%edx
c0104f9b:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c0104fa0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104fa3:	81 7d e4 ff ff ff bf 	cmpl   $0xbfffffff,-0x1c(%ebp)
c0104faa:	77 23                	ja     c0104fcf <check_boot_pgdir+0x133>
c0104fac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104faf:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104fb3:	c7 44 24 08 40 6b 10 	movl   $0xc0106b40,0x8(%esp)
c0104fba:	c0 
c0104fbb:	c7 44 24 04 30 02 00 	movl   $0x230,0x4(%esp)
c0104fc2:	00 
c0104fc3:	c7 04 24 64 6b 10 c0 	movl   $0xc0106b64,(%esp)
c0104fca:	e8 02 bd ff ff       	call   c0100cd1 <__panic>
c0104fcf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104fd2:	05 00 00 00 40       	add    $0x40000000,%eax
c0104fd7:	39 c2                	cmp    %eax,%edx
c0104fd9:	74 24                	je     c0104fff <check_boot_pgdir+0x163>
c0104fdb:	c7 44 24 0c c0 6e 10 	movl   $0xc0106ec0,0xc(%esp)
c0104fe2:	c0 
c0104fe3:	c7 44 24 08 89 6b 10 	movl   $0xc0106b89,0x8(%esp)
c0104fea:	c0 
c0104feb:	c7 44 24 04 30 02 00 	movl   $0x230,0x4(%esp)
c0104ff2:	00 
c0104ff3:	c7 04 24 64 6b 10 c0 	movl   $0xc0106b64,(%esp)
c0104ffa:	e8 d2 bc ff ff       	call   c0100cd1 <__panic>

    assert(boot_pgdir[0] == 0);
c0104fff:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c0105004:	8b 00                	mov    (%eax),%eax
c0105006:	85 c0                	test   %eax,%eax
c0105008:	74 24                	je     c010502e <check_boot_pgdir+0x192>
c010500a:	c7 44 24 0c f4 6e 10 	movl   $0xc0106ef4,0xc(%esp)
c0105011:	c0 
c0105012:	c7 44 24 08 89 6b 10 	movl   $0xc0106b89,0x8(%esp)
c0105019:	c0 
c010501a:	c7 44 24 04 32 02 00 	movl   $0x232,0x4(%esp)
c0105021:	00 
c0105022:	c7 04 24 64 6b 10 c0 	movl   $0xc0106b64,(%esp)
c0105029:	e8 a3 bc ff ff       	call   c0100cd1 <__panic>

    struct Page *p;
    p = alloc_page();
c010502e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105035:	e8 1e ed ff ff       	call   c0103d58 <alloc_pages>
c010503a:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c010503d:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c0105042:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0105049:	00 
c010504a:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
c0105051:	00 
c0105052:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105055:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105059:	89 04 24             	mov    %eax,(%esp)
c010505c:	e8 6c f6 ff ff       	call   c01046cd <page_insert>
c0105061:	85 c0                	test   %eax,%eax
c0105063:	74 24                	je     c0105089 <check_boot_pgdir+0x1ed>
c0105065:	c7 44 24 0c 08 6f 10 	movl   $0xc0106f08,0xc(%esp)
c010506c:	c0 
c010506d:	c7 44 24 08 89 6b 10 	movl   $0xc0106b89,0x8(%esp)
c0105074:	c0 
c0105075:	c7 44 24 04 36 02 00 	movl   $0x236,0x4(%esp)
c010507c:	00 
c010507d:	c7 04 24 64 6b 10 c0 	movl   $0xc0106b64,(%esp)
c0105084:	e8 48 bc ff ff       	call   c0100cd1 <__panic>
    assert(page_ref(p) == 1);
c0105089:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010508c:	89 04 24             	mov    %eax,(%esp)
c010508f:	e8 bf ea ff ff       	call   c0103b53 <page_ref>
c0105094:	83 f8 01             	cmp    $0x1,%eax
c0105097:	74 24                	je     c01050bd <check_boot_pgdir+0x221>
c0105099:	c7 44 24 0c 36 6f 10 	movl   $0xc0106f36,0xc(%esp)
c01050a0:	c0 
c01050a1:	c7 44 24 08 89 6b 10 	movl   $0xc0106b89,0x8(%esp)
c01050a8:	c0 
c01050a9:	c7 44 24 04 37 02 00 	movl   $0x237,0x4(%esp)
c01050b0:	00 
c01050b1:	c7 04 24 64 6b 10 c0 	movl   $0xc0106b64,(%esp)
c01050b8:	e8 14 bc ff ff       	call   c0100cd1 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c01050bd:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c01050c2:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c01050c9:	00 
c01050ca:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
c01050d1:	00 
c01050d2:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01050d5:	89 54 24 04          	mov    %edx,0x4(%esp)
c01050d9:	89 04 24             	mov    %eax,(%esp)
c01050dc:	e8 ec f5 ff ff       	call   c01046cd <page_insert>
c01050e1:	85 c0                	test   %eax,%eax
c01050e3:	74 24                	je     c0105109 <check_boot_pgdir+0x26d>
c01050e5:	c7 44 24 0c 48 6f 10 	movl   $0xc0106f48,0xc(%esp)
c01050ec:	c0 
c01050ed:	c7 44 24 08 89 6b 10 	movl   $0xc0106b89,0x8(%esp)
c01050f4:	c0 
c01050f5:	c7 44 24 04 38 02 00 	movl   $0x238,0x4(%esp)
c01050fc:	00 
c01050fd:	c7 04 24 64 6b 10 c0 	movl   $0xc0106b64,(%esp)
c0105104:	e8 c8 bb ff ff       	call   c0100cd1 <__panic>
    assert(page_ref(p) == 2);
c0105109:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010510c:	89 04 24             	mov    %eax,(%esp)
c010510f:	e8 3f ea ff ff       	call   c0103b53 <page_ref>
c0105114:	83 f8 02             	cmp    $0x2,%eax
c0105117:	74 24                	je     c010513d <check_boot_pgdir+0x2a1>
c0105119:	c7 44 24 0c 7f 6f 10 	movl   $0xc0106f7f,0xc(%esp)
c0105120:	c0 
c0105121:	c7 44 24 08 89 6b 10 	movl   $0xc0106b89,0x8(%esp)
c0105128:	c0 
c0105129:	c7 44 24 04 39 02 00 	movl   $0x239,0x4(%esp)
c0105130:	00 
c0105131:	c7 04 24 64 6b 10 c0 	movl   $0xc0106b64,(%esp)
c0105138:	e8 94 bb ff ff       	call   c0100cd1 <__panic>

    const char *str = "ucore: Hello world!!";
c010513d:	c7 45 dc 90 6f 10 c0 	movl   $0xc0106f90,-0x24(%ebp)
    strcpy((void *)0x100, str);
c0105144:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105147:	89 44 24 04          	mov    %eax,0x4(%esp)
c010514b:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0105152:	e8 1e 0a 00 00       	call   c0105b75 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c0105157:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
c010515e:	00 
c010515f:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0105166:	e8 83 0a 00 00       	call   c0105bee <strcmp>
c010516b:	85 c0                	test   %eax,%eax
c010516d:	74 24                	je     c0105193 <check_boot_pgdir+0x2f7>
c010516f:	c7 44 24 0c a8 6f 10 	movl   $0xc0106fa8,0xc(%esp)
c0105176:	c0 
c0105177:	c7 44 24 08 89 6b 10 	movl   $0xc0106b89,0x8(%esp)
c010517e:	c0 
c010517f:	c7 44 24 04 3d 02 00 	movl   $0x23d,0x4(%esp)
c0105186:	00 
c0105187:	c7 04 24 64 6b 10 c0 	movl   $0xc0106b64,(%esp)
c010518e:	e8 3e bb ff ff       	call   c0100cd1 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c0105193:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105196:	89 04 24             	mov    %eax,(%esp)
c0105199:	e8 23 e9 ff ff       	call   c0103ac1 <page2kva>
c010519e:	05 00 01 00 00       	add    $0x100,%eax
c01051a3:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c01051a6:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c01051ad:	e8 6b 09 00 00       	call   c0105b1d <strlen>
c01051b2:	85 c0                	test   %eax,%eax
c01051b4:	74 24                	je     c01051da <check_boot_pgdir+0x33e>
c01051b6:	c7 44 24 0c e0 6f 10 	movl   $0xc0106fe0,0xc(%esp)
c01051bd:	c0 
c01051be:	c7 44 24 08 89 6b 10 	movl   $0xc0106b89,0x8(%esp)
c01051c5:	c0 
c01051c6:	c7 44 24 04 40 02 00 	movl   $0x240,0x4(%esp)
c01051cd:	00 
c01051ce:	c7 04 24 64 6b 10 c0 	movl   $0xc0106b64,(%esp)
c01051d5:	e8 f7 ba ff ff       	call   c0100cd1 <__panic>

    free_page(p);
c01051da:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01051e1:	00 
c01051e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01051e5:	89 04 24             	mov    %eax,(%esp)
c01051e8:	e8 a3 eb ff ff       	call   c0103d90 <free_pages>
    free_page(pa2page(PDE_ADDR(boot_pgdir[0])));
c01051ed:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c01051f2:	8b 00                	mov    (%eax),%eax
c01051f4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01051f9:	89 04 24             	mov    %eax,(%esp)
c01051fc:	e8 71 e8 ff ff       	call   c0103a72 <pa2page>
c0105201:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105208:	00 
c0105209:	89 04 24             	mov    %eax,(%esp)
c010520c:	e8 7f eb ff ff       	call   c0103d90 <free_pages>
    boot_pgdir[0] = 0;
c0105211:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c0105216:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c010521c:	c7 04 24 04 70 10 c0 	movl   $0xc0107004,(%esp)
c0105223:	e8 1f b1 ff ff       	call   c0100347 <cprintf>
}
c0105228:	c9                   	leave  
c0105229:	c3                   	ret    

c010522a <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c010522a:	55                   	push   %ebp
c010522b:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c010522d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105230:	83 e0 04             	and    $0x4,%eax
c0105233:	85 c0                	test   %eax,%eax
c0105235:	74 07                	je     c010523e <perm2str+0x14>
c0105237:	b8 75 00 00 00       	mov    $0x75,%eax
c010523c:	eb 05                	jmp    c0105243 <perm2str+0x19>
c010523e:	b8 2d 00 00 00       	mov    $0x2d,%eax
c0105243:	a2 48 89 11 c0       	mov    %al,0xc0118948
    str[1] = 'r';
c0105248:	c6 05 49 89 11 c0 72 	movb   $0x72,0xc0118949
    str[2] = (perm & PTE_W) ? 'w' : '-';
c010524f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105252:	83 e0 02             	and    $0x2,%eax
c0105255:	85 c0                	test   %eax,%eax
c0105257:	74 07                	je     c0105260 <perm2str+0x36>
c0105259:	b8 77 00 00 00       	mov    $0x77,%eax
c010525e:	eb 05                	jmp    c0105265 <perm2str+0x3b>
c0105260:	b8 2d 00 00 00       	mov    $0x2d,%eax
c0105265:	a2 4a 89 11 c0       	mov    %al,0xc011894a
    str[3] = '\0';
c010526a:	c6 05 4b 89 11 c0 00 	movb   $0x0,0xc011894b
    return str;
c0105271:	b8 48 89 11 c0       	mov    $0xc0118948,%eax
}
c0105276:	5d                   	pop    %ebp
c0105277:	c3                   	ret    

c0105278 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c0105278:	55                   	push   %ebp
c0105279:	89 e5                	mov    %esp,%ebp
c010527b:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c010527e:	8b 45 10             	mov    0x10(%ebp),%eax
c0105281:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105284:	72 0a                	jb     c0105290 <get_pgtable_items+0x18>
        return 0;
c0105286:	b8 00 00 00 00       	mov    $0x0,%eax
c010528b:	e9 9c 00 00 00       	jmp    c010532c <get_pgtable_items+0xb4>
    }
    while (start < right && !(table[start] & PTE_P)) {
c0105290:	eb 04                	jmp    c0105296 <get_pgtable_items+0x1e>
        start ++;
c0105292:	83 45 10 01          	addl   $0x1,0x10(%ebp)
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
    if (start >= right) {
        return 0;
    }
    while (start < right && !(table[start] & PTE_P)) {
c0105296:	8b 45 10             	mov    0x10(%ebp),%eax
c0105299:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010529c:	73 18                	jae    c01052b6 <get_pgtable_items+0x3e>
c010529e:	8b 45 10             	mov    0x10(%ebp),%eax
c01052a1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01052a8:	8b 45 14             	mov    0x14(%ebp),%eax
c01052ab:	01 d0                	add    %edx,%eax
c01052ad:	8b 00                	mov    (%eax),%eax
c01052af:	83 e0 01             	and    $0x1,%eax
c01052b2:	85 c0                	test   %eax,%eax
c01052b4:	74 dc                	je     c0105292 <get_pgtable_items+0x1a>
        start ++;
    }
    if (start < right) {
c01052b6:	8b 45 10             	mov    0x10(%ebp),%eax
c01052b9:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01052bc:	73 69                	jae    c0105327 <get_pgtable_items+0xaf>
        if (left_store != NULL) {
c01052be:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c01052c2:	74 08                	je     c01052cc <get_pgtable_items+0x54>
            *left_store = start;
c01052c4:	8b 45 18             	mov    0x18(%ebp),%eax
c01052c7:	8b 55 10             	mov    0x10(%ebp),%edx
c01052ca:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c01052cc:	8b 45 10             	mov    0x10(%ebp),%eax
c01052cf:	8d 50 01             	lea    0x1(%eax),%edx
c01052d2:	89 55 10             	mov    %edx,0x10(%ebp)
c01052d5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01052dc:	8b 45 14             	mov    0x14(%ebp),%eax
c01052df:	01 d0                	add    %edx,%eax
c01052e1:	8b 00                	mov    (%eax),%eax
c01052e3:	83 e0 07             	and    $0x7,%eax
c01052e6:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c01052e9:	eb 04                	jmp    c01052ef <get_pgtable_items+0x77>
            start ++;
c01052eb:	83 45 10 01          	addl   $0x1,0x10(%ebp)
    if (start < right) {
        if (left_store != NULL) {
            *left_store = start;
        }
        int perm = (table[start ++] & PTE_USER);
        while (start < right && (table[start] & PTE_USER) == perm) {
c01052ef:	8b 45 10             	mov    0x10(%ebp),%eax
c01052f2:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01052f5:	73 1d                	jae    c0105314 <get_pgtable_items+0x9c>
c01052f7:	8b 45 10             	mov    0x10(%ebp),%eax
c01052fa:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105301:	8b 45 14             	mov    0x14(%ebp),%eax
c0105304:	01 d0                	add    %edx,%eax
c0105306:	8b 00                	mov    (%eax),%eax
c0105308:	83 e0 07             	and    $0x7,%eax
c010530b:	89 c2                	mov    %eax,%edx
c010530d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105310:	39 c2                	cmp    %eax,%edx
c0105312:	74 d7                	je     c01052eb <get_pgtable_items+0x73>
            start ++;
        }
        if (right_store != NULL) {
c0105314:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0105318:	74 08                	je     c0105322 <get_pgtable_items+0xaa>
            *right_store = start;
c010531a:	8b 45 1c             	mov    0x1c(%ebp),%eax
c010531d:	8b 55 10             	mov    0x10(%ebp),%edx
c0105320:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c0105322:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105325:	eb 05                	jmp    c010532c <get_pgtable_items+0xb4>
    }
    return 0;
c0105327:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010532c:	c9                   	leave  
c010532d:	c3                   	ret    

c010532e <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c010532e:	55                   	push   %ebp
c010532f:	89 e5                	mov    %esp,%ebp
c0105331:	57                   	push   %edi
c0105332:	56                   	push   %esi
c0105333:	53                   	push   %ebx
c0105334:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c0105337:	c7 04 24 24 70 10 c0 	movl   $0xc0107024,(%esp)
c010533e:	e8 04 b0 ff ff       	call   c0100347 <cprintf>
    size_t left, right = 0, perm;
c0105343:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c010534a:	e9 fa 00 00 00       	jmp    c0105449 <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c010534f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105352:	89 04 24             	mov    %eax,(%esp)
c0105355:	e8 d0 fe ff ff       	call   c010522a <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c010535a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c010535d:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105360:	29 d1                	sub    %edx,%ecx
c0105362:	89 ca                	mov    %ecx,%edx
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0105364:	89 d6                	mov    %edx,%esi
c0105366:	c1 e6 16             	shl    $0x16,%esi
c0105369:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010536c:	89 d3                	mov    %edx,%ebx
c010536e:	c1 e3 16             	shl    $0x16,%ebx
c0105371:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105374:	89 d1                	mov    %edx,%ecx
c0105376:	c1 e1 16             	shl    $0x16,%ecx
c0105379:	8b 7d dc             	mov    -0x24(%ebp),%edi
c010537c:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010537f:	29 d7                	sub    %edx,%edi
c0105381:	89 fa                	mov    %edi,%edx
c0105383:	89 44 24 14          	mov    %eax,0x14(%esp)
c0105387:	89 74 24 10          	mov    %esi,0x10(%esp)
c010538b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c010538f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0105393:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105397:	c7 04 24 55 70 10 c0 	movl   $0xc0107055,(%esp)
c010539e:	e8 a4 af ff ff       	call   c0100347 <cprintf>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
c01053a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01053a6:	c1 e0 0a             	shl    $0xa,%eax
c01053a9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c01053ac:	eb 54                	jmp    c0105402 <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c01053ae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01053b1:	89 04 24             	mov    %eax,(%esp)
c01053b4:	e8 71 fe ff ff       	call   c010522a <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c01053b9:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c01053bc:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01053bf:	29 d1                	sub    %edx,%ecx
c01053c1:	89 ca                	mov    %ecx,%edx
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c01053c3:	89 d6                	mov    %edx,%esi
c01053c5:	c1 e6 0c             	shl    $0xc,%esi
c01053c8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01053cb:	89 d3                	mov    %edx,%ebx
c01053cd:	c1 e3 0c             	shl    $0xc,%ebx
c01053d0:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01053d3:	c1 e2 0c             	shl    $0xc,%edx
c01053d6:	89 d1                	mov    %edx,%ecx
c01053d8:	8b 7d d4             	mov    -0x2c(%ebp),%edi
c01053db:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01053de:	29 d7                	sub    %edx,%edi
c01053e0:	89 fa                	mov    %edi,%edx
c01053e2:	89 44 24 14          	mov    %eax,0x14(%esp)
c01053e6:	89 74 24 10          	mov    %esi,0x10(%esp)
c01053ea:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01053ee:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01053f2:	89 54 24 04          	mov    %edx,0x4(%esp)
c01053f6:	c7 04 24 74 70 10 c0 	movl   $0xc0107074,(%esp)
c01053fd:	e8 45 af ff ff       	call   c0100347 <cprintf>
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0105402:	ba 00 00 c0 fa       	mov    $0xfac00000,%edx
c0105407:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010540a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c010540d:	89 ce                	mov    %ecx,%esi
c010540f:	c1 e6 0a             	shl    $0xa,%esi
c0105412:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c0105415:	89 cb                	mov    %ecx,%ebx
c0105417:	c1 e3 0a             	shl    $0xa,%ebx
c010541a:	8d 4d d4             	lea    -0x2c(%ebp),%ecx
c010541d:	89 4c 24 14          	mov    %ecx,0x14(%esp)
c0105421:	8d 4d d8             	lea    -0x28(%ebp),%ecx
c0105424:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0105428:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010542c:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105430:	89 74 24 04          	mov    %esi,0x4(%esp)
c0105434:	89 1c 24             	mov    %ebx,(%esp)
c0105437:	e8 3c fe ff ff       	call   c0105278 <get_pgtable_items>
c010543c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010543f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105443:	0f 85 65 ff ff ff    	jne    c01053ae <print_pgdir+0x80>
//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0105449:	ba 00 b0 fe fa       	mov    $0xfafeb000,%edx
c010544e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105451:	8d 4d dc             	lea    -0x24(%ebp),%ecx
c0105454:	89 4c 24 14          	mov    %ecx,0x14(%esp)
c0105458:	8d 4d e0             	lea    -0x20(%ebp),%ecx
c010545b:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c010545f:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0105463:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105467:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
c010546e:	00 
c010546f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0105476:	e8 fd fd ff ff       	call   c0105278 <get_pgtable_items>
c010547b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010547e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105482:	0f 85 c7 fe ff ff    	jne    c010534f <print_pgdir+0x21>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
        }
    }
    cprintf("--------------------- END ---------------------\n");
c0105488:	c7 04 24 98 70 10 c0 	movl   $0xc0107098,(%esp)
c010548f:	e8 b3 ae ff ff       	call   c0100347 <cprintf>
}
c0105494:	83 c4 4c             	add    $0x4c,%esp
c0105497:	5b                   	pop    %ebx
c0105498:	5e                   	pop    %esi
c0105499:	5f                   	pop    %edi
c010549a:	5d                   	pop    %ebp
c010549b:	c3                   	ret    

c010549c <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c010549c:	55                   	push   %ebp
c010549d:	89 e5                	mov    %esp,%ebp
c010549f:	83 ec 58             	sub    $0x58,%esp
c01054a2:	8b 45 10             	mov    0x10(%ebp),%eax
c01054a5:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01054a8:	8b 45 14             	mov    0x14(%ebp),%eax
c01054ab:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c01054ae:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01054b1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01054b4:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01054b7:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c01054ba:	8b 45 18             	mov    0x18(%ebp),%eax
c01054bd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01054c0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01054c3:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01054c6:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01054c9:	89 55 f0             	mov    %edx,-0x10(%ebp)
c01054cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01054cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01054d2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01054d6:	74 1c                	je     c01054f4 <printnum+0x58>
c01054d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01054db:	ba 00 00 00 00       	mov    $0x0,%edx
c01054e0:	f7 75 e4             	divl   -0x1c(%ebp)
c01054e3:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01054e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01054e9:	ba 00 00 00 00       	mov    $0x0,%edx
c01054ee:	f7 75 e4             	divl   -0x1c(%ebp)
c01054f1:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01054f4:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01054f7:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01054fa:	f7 75 e4             	divl   -0x1c(%ebp)
c01054fd:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105500:	89 55 dc             	mov    %edx,-0x24(%ebp)
c0105503:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105506:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105509:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010550c:	89 55 ec             	mov    %edx,-0x14(%ebp)
c010550f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105512:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c0105515:	8b 45 18             	mov    0x18(%ebp),%eax
c0105518:	ba 00 00 00 00       	mov    $0x0,%edx
c010551d:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0105520:	77 56                	ja     c0105578 <printnum+0xdc>
c0105522:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0105525:	72 05                	jb     c010552c <printnum+0x90>
c0105527:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c010552a:	77 4c                	ja     c0105578 <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
c010552c:	8b 45 1c             	mov    0x1c(%ebp),%eax
c010552f:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105532:	8b 45 20             	mov    0x20(%ebp),%eax
c0105535:	89 44 24 18          	mov    %eax,0x18(%esp)
c0105539:	89 54 24 14          	mov    %edx,0x14(%esp)
c010553d:	8b 45 18             	mov    0x18(%ebp),%eax
c0105540:	89 44 24 10          	mov    %eax,0x10(%esp)
c0105544:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105547:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010554a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010554e:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0105552:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105555:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105559:	8b 45 08             	mov    0x8(%ebp),%eax
c010555c:	89 04 24             	mov    %eax,(%esp)
c010555f:	e8 38 ff ff ff       	call   c010549c <printnum>
c0105564:	eb 1c                	jmp    c0105582 <printnum+0xe6>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c0105566:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105569:	89 44 24 04          	mov    %eax,0x4(%esp)
c010556d:	8b 45 20             	mov    0x20(%ebp),%eax
c0105570:	89 04 24             	mov    %eax,(%esp)
c0105573:	8b 45 08             	mov    0x8(%ebp),%eax
c0105576:	ff d0                	call   *%eax
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
c0105578:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
c010557c:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0105580:	7f e4                	jg     c0105566 <printnum+0xca>
            putch(padc, putdat);
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c0105582:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105585:	05 4c 71 10 c0       	add    $0xc010714c,%eax
c010558a:	0f b6 00             	movzbl (%eax),%eax
c010558d:	0f be c0             	movsbl %al,%eax
c0105590:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105593:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105597:	89 04 24             	mov    %eax,(%esp)
c010559a:	8b 45 08             	mov    0x8(%ebp),%eax
c010559d:	ff d0                	call   *%eax
}
c010559f:	c9                   	leave  
c01055a0:	c3                   	ret    

c01055a1 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c01055a1:	55                   	push   %ebp
c01055a2:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c01055a4:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c01055a8:	7e 14                	jle    c01055be <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c01055aa:	8b 45 08             	mov    0x8(%ebp),%eax
c01055ad:	8b 00                	mov    (%eax),%eax
c01055af:	8d 48 08             	lea    0x8(%eax),%ecx
c01055b2:	8b 55 08             	mov    0x8(%ebp),%edx
c01055b5:	89 0a                	mov    %ecx,(%edx)
c01055b7:	8b 50 04             	mov    0x4(%eax),%edx
c01055ba:	8b 00                	mov    (%eax),%eax
c01055bc:	eb 30                	jmp    c01055ee <getuint+0x4d>
    }
    else if (lflag) {
c01055be:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01055c2:	74 16                	je     c01055da <getuint+0x39>
        return va_arg(*ap, unsigned long);
c01055c4:	8b 45 08             	mov    0x8(%ebp),%eax
c01055c7:	8b 00                	mov    (%eax),%eax
c01055c9:	8d 48 04             	lea    0x4(%eax),%ecx
c01055cc:	8b 55 08             	mov    0x8(%ebp),%edx
c01055cf:	89 0a                	mov    %ecx,(%edx)
c01055d1:	8b 00                	mov    (%eax),%eax
c01055d3:	ba 00 00 00 00       	mov    $0x0,%edx
c01055d8:	eb 14                	jmp    c01055ee <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c01055da:	8b 45 08             	mov    0x8(%ebp),%eax
c01055dd:	8b 00                	mov    (%eax),%eax
c01055df:	8d 48 04             	lea    0x4(%eax),%ecx
c01055e2:	8b 55 08             	mov    0x8(%ebp),%edx
c01055e5:	89 0a                	mov    %ecx,(%edx)
c01055e7:	8b 00                	mov    (%eax),%eax
c01055e9:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c01055ee:	5d                   	pop    %ebp
c01055ef:	c3                   	ret    

c01055f0 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c01055f0:	55                   	push   %ebp
c01055f1:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c01055f3:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c01055f7:	7e 14                	jle    c010560d <getint+0x1d>
        return va_arg(*ap, long long);
c01055f9:	8b 45 08             	mov    0x8(%ebp),%eax
c01055fc:	8b 00                	mov    (%eax),%eax
c01055fe:	8d 48 08             	lea    0x8(%eax),%ecx
c0105601:	8b 55 08             	mov    0x8(%ebp),%edx
c0105604:	89 0a                	mov    %ecx,(%edx)
c0105606:	8b 50 04             	mov    0x4(%eax),%edx
c0105609:	8b 00                	mov    (%eax),%eax
c010560b:	eb 28                	jmp    c0105635 <getint+0x45>
    }
    else if (lflag) {
c010560d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105611:	74 12                	je     c0105625 <getint+0x35>
        return va_arg(*ap, long);
c0105613:	8b 45 08             	mov    0x8(%ebp),%eax
c0105616:	8b 00                	mov    (%eax),%eax
c0105618:	8d 48 04             	lea    0x4(%eax),%ecx
c010561b:	8b 55 08             	mov    0x8(%ebp),%edx
c010561e:	89 0a                	mov    %ecx,(%edx)
c0105620:	8b 00                	mov    (%eax),%eax
c0105622:	99                   	cltd   
c0105623:	eb 10                	jmp    c0105635 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c0105625:	8b 45 08             	mov    0x8(%ebp),%eax
c0105628:	8b 00                	mov    (%eax),%eax
c010562a:	8d 48 04             	lea    0x4(%eax),%ecx
c010562d:	8b 55 08             	mov    0x8(%ebp),%edx
c0105630:	89 0a                	mov    %ecx,(%edx)
c0105632:	8b 00                	mov    (%eax),%eax
c0105634:	99                   	cltd   
    }
}
c0105635:	5d                   	pop    %ebp
c0105636:	c3                   	ret    

c0105637 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c0105637:	55                   	push   %ebp
c0105638:	89 e5                	mov    %esp,%ebp
c010563a:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
c010563d:	8d 45 14             	lea    0x14(%ebp),%eax
c0105640:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c0105643:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105646:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010564a:	8b 45 10             	mov    0x10(%ebp),%eax
c010564d:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105651:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105654:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105658:	8b 45 08             	mov    0x8(%ebp),%eax
c010565b:	89 04 24             	mov    %eax,(%esp)
c010565e:	e8 02 00 00 00       	call   c0105665 <vprintfmt>
    va_end(ap);
}
c0105663:	c9                   	leave  
c0105664:	c3                   	ret    

c0105665 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c0105665:	55                   	push   %ebp
c0105666:	89 e5                	mov    %esp,%ebp
c0105668:	56                   	push   %esi
c0105669:	53                   	push   %ebx
c010566a:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c010566d:	eb 18                	jmp    c0105687 <vprintfmt+0x22>
            if (ch == '\0') {
c010566f:	85 db                	test   %ebx,%ebx
c0105671:	75 05                	jne    c0105678 <vprintfmt+0x13>
                return;
c0105673:	e9 d1 03 00 00       	jmp    c0105a49 <vprintfmt+0x3e4>
            }
            putch(ch, putdat);
c0105678:	8b 45 0c             	mov    0xc(%ebp),%eax
c010567b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010567f:	89 1c 24             	mov    %ebx,(%esp)
c0105682:	8b 45 08             	mov    0x8(%ebp),%eax
c0105685:	ff d0                	call   *%eax
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0105687:	8b 45 10             	mov    0x10(%ebp),%eax
c010568a:	8d 50 01             	lea    0x1(%eax),%edx
c010568d:	89 55 10             	mov    %edx,0x10(%ebp)
c0105690:	0f b6 00             	movzbl (%eax),%eax
c0105693:	0f b6 d8             	movzbl %al,%ebx
c0105696:	83 fb 25             	cmp    $0x25,%ebx
c0105699:	75 d4                	jne    c010566f <vprintfmt+0xa>
            }
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
c010569b:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c010569f:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c01056a6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01056a9:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c01056ac:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01056b3:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01056b6:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c01056b9:	8b 45 10             	mov    0x10(%ebp),%eax
c01056bc:	8d 50 01             	lea    0x1(%eax),%edx
c01056bf:	89 55 10             	mov    %edx,0x10(%ebp)
c01056c2:	0f b6 00             	movzbl (%eax),%eax
c01056c5:	0f b6 d8             	movzbl %al,%ebx
c01056c8:	8d 43 dd             	lea    -0x23(%ebx),%eax
c01056cb:	83 f8 55             	cmp    $0x55,%eax
c01056ce:	0f 87 44 03 00 00    	ja     c0105a18 <vprintfmt+0x3b3>
c01056d4:	8b 04 85 70 71 10 c0 	mov    -0x3fef8e90(,%eax,4),%eax
c01056db:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c01056dd:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c01056e1:	eb d6                	jmp    c01056b9 <vprintfmt+0x54>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c01056e3:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c01056e7:	eb d0                	jmp    c01056b9 <vprintfmt+0x54>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c01056e9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c01056f0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01056f3:	89 d0                	mov    %edx,%eax
c01056f5:	c1 e0 02             	shl    $0x2,%eax
c01056f8:	01 d0                	add    %edx,%eax
c01056fa:	01 c0                	add    %eax,%eax
c01056fc:	01 d8                	add    %ebx,%eax
c01056fe:	83 e8 30             	sub    $0x30,%eax
c0105701:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c0105704:	8b 45 10             	mov    0x10(%ebp),%eax
c0105707:	0f b6 00             	movzbl (%eax),%eax
c010570a:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c010570d:	83 fb 2f             	cmp    $0x2f,%ebx
c0105710:	7e 0b                	jle    c010571d <vprintfmt+0xb8>
c0105712:	83 fb 39             	cmp    $0x39,%ebx
c0105715:	7f 06                	jg     c010571d <vprintfmt+0xb8>
            padc = '0';
            goto reswitch;

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c0105717:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                precision = precision * 10 + ch - '0';
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
c010571b:	eb d3                	jmp    c01056f0 <vprintfmt+0x8b>
            goto process_precision;
c010571d:	eb 33                	jmp    c0105752 <vprintfmt+0xed>

        case '*':
            precision = va_arg(ap, int);
c010571f:	8b 45 14             	mov    0x14(%ebp),%eax
c0105722:	8d 50 04             	lea    0x4(%eax),%edx
c0105725:	89 55 14             	mov    %edx,0x14(%ebp)
c0105728:	8b 00                	mov    (%eax),%eax
c010572a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c010572d:	eb 23                	jmp    c0105752 <vprintfmt+0xed>

        case '.':
            if (width < 0)
c010572f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105733:	79 0c                	jns    c0105741 <vprintfmt+0xdc>
                width = 0;
c0105735:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c010573c:	e9 78 ff ff ff       	jmp    c01056b9 <vprintfmt+0x54>
c0105741:	e9 73 ff ff ff       	jmp    c01056b9 <vprintfmt+0x54>

        case '#':
            altflag = 1;
c0105746:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c010574d:	e9 67 ff ff ff       	jmp    c01056b9 <vprintfmt+0x54>

        process_precision:
            if (width < 0)
c0105752:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105756:	79 12                	jns    c010576a <vprintfmt+0x105>
                width = precision, precision = -1;
c0105758:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010575b:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010575e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c0105765:	e9 4f ff ff ff       	jmp    c01056b9 <vprintfmt+0x54>
c010576a:	e9 4a ff ff ff       	jmp    c01056b9 <vprintfmt+0x54>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c010576f:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
c0105773:	e9 41 ff ff ff       	jmp    c01056b9 <vprintfmt+0x54>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c0105778:	8b 45 14             	mov    0x14(%ebp),%eax
c010577b:	8d 50 04             	lea    0x4(%eax),%edx
c010577e:	89 55 14             	mov    %edx,0x14(%ebp)
c0105781:	8b 00                	mov    (%eax),%eax
c0105783:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105786:	89 54 24 04          	mov    %edx,0x4(%esp)
c010578a:	89 04 24             	mov    %eax,(%esp)
c010578d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105790:	ff d0                	call   *%eax
            break;
c0105792:	e9 ac 02 00 00       	jmp    c0105a43 <vprintfmt+0x3de>

        // error message
        case 'e':
            err = va_arg(ap, int);
c0105797:	8b 45 14             	mov    0x14(%ebp),%eax
c010579a:	8d 50 04             	lea    0x4(%eax),%edx
c010579d:	89 55 14             	mov    %edx,0x14(%ebp)
c01057a0:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c01057a2:	85 db                	test   %ebx,%ebx
c01057a4:	79 02                	jns    c01057a8 <vprintfmt+0x143>
                err = -err;
c01057a6:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c01057a8:	83 fb 06             	cmp    $0x6,%ebx
c01057ab:	7f 0b                	jg     c01057b8 <vprintfmt+0x153>
c01057ad:	8b 34 9d 30 71 10 c0 	mov    -0x3fef8ed0(,%ebx,4),%esi
c01057b4:	85 f6                	test   %esi,%esi
c01057b6:	75 23                	jne    c01057db <vprintfmt+0x176>
                printfmt(putch, putdat, "error %d", err);
c01057b8:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01057bc:	c7 44 24 08 5d 71 10 	movl   $0xc010715d,0x8(%esp)
c01057c3:	c0 
c01057c4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01057c7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01057cb:	8b 45 08             	mov    0x8(%ebp),%eax
c01057ce:	89 04 24             	mov    %eax,(%esp)
c01057d1:	e8 61 fe ff ff       	call   c0105637 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c01057d6:	e9 68 02 00 00       	jmp    c0105a43 <vprintfmt+0x3de>
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
                printfmt(putch, putdat, "error %d", err);
            }
            else {
                printfmt(putch, putdat, "%s", p);
c01057db:	89 74 24 0c          	mov    %esi,0xc(%esp)
c01057df:	c7 44 24 08 66 71 10 	movl   $0xc0107166,0x8(%esp)
c01057e6:	c0 
c01057e7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01057ea:	89 44 24 04          	mov    %eax,0x4(%esp)
c01057ee:	8b 45 08             	mov    0x8(%ebp),%eax
c01057f1:	89 04 24             	mov    %eax,(%esp)
c01057f4:	e8 3e fe ff ff       	call   c0105637 <printfmt>
            }
            break;
c01057f9:	e9 45 02 00 00       	jmp    c0105a43 <vprintfmt+0x3de>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c01057fe:	8b 45 14             	mov    0x14(%ebp),%eax
c0105801:	8d 50 04             	lea    0x4(%eax),%edx
c0105804:	89 55 14             	mov    %edx,0x14(%ebp)
c0105807:	8b 30                	mov    (%eax),%esi
c0105809:	85 f6                	test   %esi,%esi
c010580b:	75 05                	jne    c0105812 <vprintfmt+0x1ad>
                p = "(null)";
c010580d:	be 69 71 10 c0       	mov    $0xc0107169,%esi
            }
            if (width > 0 && padc != '-') {
c0105812:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105816:	7e 3e                	jle    c0105856 <vprintfmt+0x1f1>
c0105818:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c010581c:	74 38                	je     c0105856 <vprintfmt+0x1f1>
                for (width -= strnlen(p, precision); width > 0; width --) {
c010581e:	8b 5d e8             	mov    -0x18(%ebp),%ebx
c0105821:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105824:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105828:	89 34 24             	mov    %esi,(%esp)
c010582b:	e8 15 03 00 00       	call   c0105b45 <strnlen>
c0105830:	29 c3                	sub    %eax,%ebx
c0105832:	89 d8                	mov    %ebx,%eax
c0105834:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105837:	eb 17                	jmp    c0105850 <vprintfmt+0x1eb>
                    putch(padc, putdat);
c0105839:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c010583d:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105840:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105844:	89 04 24             	mov    %eax,(%esp)
c0105847:	8b 45 08             	mov    0x8(%ebp),%eax
c010584a:	ff d0                	call   *%eax
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
                p = "(null)";
            }
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
c010584c:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c0105850:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105854:	7f e3                	jg     c0105839 <vprintfmt+0x1d4>
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0105856:	eb 38                	jmp    c0105890 <vprintfmt+0x22b>
                if (altflag && (ch < ' ' || ch > '~')) {
c0105858:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c010585c:	74 1f                	je     c010587d <vprintfmt+0x218>
c010585e:	83 fb 1f             	cmp    $0x1f,%ebx
c0105861:	7e 05                	jle    c0105868 <vprintfmt+0x203>
c0105863:	83 fb 7e             	cmp    $0x7e,%ebx
c0105866:	7e 15                	jle    c010587d <vprintfmt+0x218>
                    putch('?', putdat);
c0105868:	8b 45 0c             	mov    0xc(%ebp),%eax
c010586b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010586f:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
c0105876:	8b 45 08             	mov    0x8(%ebp),%eax
c0105879:	ff d0                	call   *%eax
c010587b:	eb 0f                	jmp    c010588c <vprintfmt+0x227>
                }
                else {
                    putch(ch, putdat);
c010587d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105880:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105884:	89 1c 24             	mov    %ebx,(%esp)
c0105887:	8b 45 08             	mov    0x8(%ebp),%eax
c010588a:	ff d0                	call   *%eax
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c010588c:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c0105890:	89 f0                	mov    %esi,%eax
c0105892:	8d 70 01             	lea    0x1(%eax),%esi
c0105895:	0f b6 00             	movzbl (%eax),%eax
c0105898:	0f be d8             	movsbl %al,%ebx
c010589b:	85 db                	test   %ebx,%ebx
c010589d:	74 10                	je     c01058af <vprintfmt+0x24a>
c010589f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01058a3:	78 b3                	js     c0105858 <vprintfmt+0x1f3>
c01058a5:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
c01058a9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01058ad:	79 a9                	jns    c0105858 <vprintfmt+0x1f3>
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c01058af:	eb 17                	jmp    c01058c8 <vprintfmt+0x263>
                putch(' ', putdat);
c01058b1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01058b4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01058b8:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c01058bf:	8b 45 08             	mov    0x8(%ebp),%eax
c01058c2:	ff d0                	call   *%eax
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c01058c4:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c01058c8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01058cc:	7f e3                	jg     c01058b1 <vprintfmt+0x24c>
                putch(' ', putdat);
            }
            break;
c01058ce:	e9 70 01 00 00       	jmp    c0105a43 <vprintfmt+0x3de>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c01058d3:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01058d6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01058da:	8d 45 14             	lea    0x14(%ebp),%eax
c01058dd:	89 04 24             	mov    %eax,(%esp)
c01058e0:	e8 0b fd ff ff       	call   c01055f0 <getint>
c01058e5:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01058e8:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c01058eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01058ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01058f1:	85 d2                	test   %edx,%edx
c01058f3:	79 26                	jns    c010591b <vprintfmt+0x2b6>
                putch('-', putdat);
c01058f5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01058f8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01058fc:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
c0105903:	8b 45 08             	mov    0x8(%ebp),%eax
c0105906:	ff d0                	call   *%eax
                num = -(long long)num;
c0105908:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010590b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010590e:	f7 d8                	neg    %eax
c0105910:	83 d2 00             	adc    $0x0,%edx
c0105913:	f7 da                	neg    %edx
c0105915:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105918:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c010591b:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c0105922:	e9 a8 00 00 00       	jmp    c01059cf <vprintfmt+0x36a>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c0105927:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010592a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010592e:	8d 45 14             	lea    0x14(%ebp),%eax
c0105931:	89 04 24             	mov    %eax,(%esp)
c0105934:	e8 68 fc ff ff       	call   c01055a1 <getuint>
c0105939:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010593c:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c010593f:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c0105946:	e9 84 00 00 00       	jmp    c01059cf <vprintfmt+0x36a>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c010594b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010594e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105952:	8d 45 14             	lea    0x14(%ebp),%eax
c0105955:	89 04 24             	mov    %eax,(%esp)
c0105958:	e8 44 fc ff ff       	call   c01055a1 <getuint>
c010595d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105960:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c0105963:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c010596a:	eb 63                	jmp    c01059cf <vprintfmt+0x36a>

        // pointer
        case 'p':
            putch('0', putdat);
c010596c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010596f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105973:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
c010597a:	8b 45 08             	mov    0x8(%ebp),%eax
c010597d:	ff d0                	call   *%eax
            putch('x', putdat);
c010597f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105982:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105986:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
c010598d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105990:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c0105992:	8b 45 14             	mov    0x14(%ebp),%eax
c0105995:	8d 50 04             	lea    0x4(%eax),%edx
c0105998:	89 55 14             	mov    %edx,0x14(%ebp)
c010599b:	8b 00                	mov    (%eax),%eax
c010599d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01059a0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c01059a7:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c01059ae:	eb 1f                	jmp    c01059cf <vprintfmt+0x36a>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c01059b0:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01059b3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01059b7:	8d 45 14             	lea    0x14(%ebp),%eax
c01059ba:	89 04 24             	mov    %eax,(%esp)
c01059bd:	e8 df fb ff ff       	call   c01055a1 <getuint>
c01059c2:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01059c5:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c01059c8:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c01059cf:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c01059d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01059d6:	89 54 24 18          	mov    %edx,0x18(%esp)
c01059da:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01059dd:	89 54 24 14          	mov    %edx,0x14(%esp)
c01059e1:	89 44 24 10          	mov    %eax,0x10(%esp)
c01059e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01059e8:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01059eb:	89 44 24 08          	mov    %eax,0x8(%esp)
c01059ef:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01059f3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01059f6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01059fa:	8b 45 08             	mov    0x8(%ebp),%eax
c01059fd:	89 04 24             	mov    %eax,(%esp)
c0105a00:	e8 97 fa ff ff       	call   c010549c <printnum>
            break;
c0105a05:	eb 3c                	jmp    c0105a43 <vprintfmt+0x3de>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c0105a07:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a0a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105a0e:	89 1c 24             	mov    %ebx,(%esp)
c0105a11:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a14:	ff d0                	call   *%eax
            break;
c0105a16:	eb 2b                	jmp    c0105a43 <vprintfmt+0x3de>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c0105a18:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a1b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105a1f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
c0105a26:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a29:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
c0105a2b:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c0105a2f:	eb 04                	jmp    c0105a35 <vprintfmt+0x3d0>
c0105a31:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c0105a35:	8b 45 10             	mov    0x10(%ebp),%eax
c0105a38:	83 e8 01             	sub    $0x1,%eax
c0105a3b:	0f b6 00             	movzbl (%eax),%eax
c0105a3e:	3c 25                	cmp    $0x25,%al
c0105a40:	75 ef                	jne    c0105a31 <vprintfmt+0x3cc>
                /* do nothing */;
            break;
c0105a42:	90                   	nop
        }
    }
c0105a43:	90                   	nop
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0105a44:	e9 3e fc ff ff       	jmp    c0105687 <vprintfmt+0x22>
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
c0105a49:	83 c4 40             	add    $0x40,%esp
c0105a4c:	5b                   	pop    %ebx
c0105a4d:	5e                   	pop    %esi
c0105a4e:	5d                   	pop    %ebp
c0105a4f:	c3                   	ret    

c0105a50 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c0105a50:	55                   	push   %ebp
c0105a51:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c0105a53:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a56:	8b 40 08             	mov    0x8(%eax),%eax
c0105a59:	8d 50 01             	lea    0x1(%eax),%edx
c0105a5c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a5f:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c0105a62:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a65:	8b 10                	mov    (%eax),%edx
c0105a67:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a6a:	8b 40 04             	mov    0x4(%eax),%eax
c0105a6d:	39 c2                	cmp    %eax,%edx
c0105a6f:	73 12                	jae    c0105a83 <sprintputch+0x33>
        *b->buf ++ = ch;
c0105a71:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a74:	8b 00                	mov    (%eax),%eax
c0105a76:	8d 48 01             	lea    0x1(%eax),%ecx
c0105a79:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105a7c:	89 0a                	mov    %ecx,(%edx)
c0105a7e:	8b 55 08             	mov    0x8(%ebp),%edx
c0105a81:	88 10                	mov    %dl,(%eax)
    }
}
c0105a83:	5d                   	pop    %ebp
c0105a84:	c3                   	ret    

c0105a85 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c0105a85:	55                   	push   %ebp
c0105a86:	89 e5                	mov    %esp,%ebp
c0105a88:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c0105a8b:	8d 45 14             	lea    0x14(%ebp),%eax
c0105a8e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c0105a91:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105a94:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105a98:	8b 45 10             	mov    0x10(%ebp),%eax
c0105a9b:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105a9f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105aa2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105aa6:	8b 45 08             	mov    0x8(%ebp),%eax
c0105aa9:	89 04 24             	mov    %eax,(%esp)
c0105aac:	e8 08 00 00 00       	call   c0105ab9 <vsnprintf>
c0105ab1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0105ab4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105ab7:	c9                   	leave  
c0105ab8:	c3                   	ret    

c0105ab9 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c0105ab9:	55                   	push   %ebp
c0105aba:	89 e5                	mov    %esp,%ebp
c0105abc:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c0105abf:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ac2:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105ac5:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105ac8:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105acb:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ace:	01 d0                	add    %edx,%eax
c0105ad0:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105ad3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c0105ada:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0105ade:	74 0a                	je     c0105aea <vsnprintf+0x31>
c0105ae0:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105ae3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105ae6:	39 c2                	cmp    %eax,%edx
c0105ae8:	76 07                	jbe    c0105af1 <vsnprintf+0x38>
        return -E_INVAL;
c0105aea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c0105aef:	eb 2a                	jmp    c0105b1b <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c0105af1:	8b 45 14             	mov    0x14(%ebp),%eax
c0105af4:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105af8:	8b 45 10             	mov    0x10(%ebp),%eax
c0105afb:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105aff:	8d 45 ec             	lea    -0x14(%ebp),%eax
c0105b02:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105b06:	c7 04 24 50 5a 10 c0 	movl   $0xc0105a50,(%esp)
c0105b0d:	e8 53 fb ff ff       	call   c0105665 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
c0105b12:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105b15:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c0105b18:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105b1b:	c9                   	leave  
c0105b1c:	c3                   	ret    

c0105b1d <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c0105b1d:	55                   	push   %ebp
c0105b1e:	89 e5                	mov    %esp,%ebp
c0105b20:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0105b23:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c0105b2a:	eb 04                	jmp    c0105b30 <strlen+0x13>
        cnt ++;
c0105b2c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
c0105b30:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b33:	8d 50 01             	lea    0x1(%eax),%edx
c0105b36:	89 55 08             	mov    %edx,0x8(%ebp)
c0105b39:	0f b6 00             	movzbl (%eax),%eax
c0105b3c:	84 c0                	test   %al,%al
c0105b3e:	75 ec                	jne    c0105b2c <strlen+0xf>
        cnt ++;
    }
    return cnt;
c0105b40:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0105b43:	c9                   	leave  
c0105b44:	c3                   	ret    

c0105b45 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c0105b45:	55                   	push   %ebp
c0105b46:	89 e5                	mov    %esp,%ebp
c0105b48:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0105b4b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c0105b52:	eb 04                	jmp    c0105b58 <strnlen+0x13>
        cnt ++;
c0105b54:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
c0105b58:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105b5b:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105b5e:	73 10                	jae    c0105b70 <strnlen+0x2b>
c0105b60:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b63:	8d 50 01             	lea    0x1(%eax),%edx
c0105b66:	89 55 08             	mov    %edx,0x8(%ebp)
c0105b69:	0f b6 00             	movzbl (%eax),%eax
c0105b6c:	84 c0                	test   %al,%al
c0105b6e:	75 e4                	jne    c0105b54 <strnlen+0xf>
        cnt ++;
    }
    return cnt;
c0105b70:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0105b73:	c9                   	leave  
c0105b74:	c3                   	ret    

c0105b75 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c0105b75:	55                   	push   %ebp
c0105b76:	89 e5                	mov    %esp,%ebp
c0105b78:	57                   	push   %edi
c0105b79:	56                   	push   %esi
c0105b7a:	83 ec 20             	sub    $0x20,%esp
c0105b7d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b80:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105b83:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105b86:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c0105b89:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105b8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105b8f:	89 d1                	mov    %edx,%ecx
c0105b91:	89 c2                	mov    %eax,%edx
c0105b93:	89 ce                	mov    %ecx,%esi
c0105b95:	89 d7                	mov    %edx,%edi
c0105b97:	ac                   	lods   %ds:(%esi),%al
c0105b98:	aa                   	stos   %al,%es:(%edi)
c0105b99:	84 c0                	test   %al,%al
c0105b9b:	75 fa                	jne    c0105b97 <strcpy+0x22>
c0105b9d:	89 fa                	mov    %edi,%edx
c0105b9f:	89 f1                	mov    %esi,%ecx
c0105ba1:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0105ba4:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0105ba7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c0105baa:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c0105bad:	83 c4 20             	add    $0x20,%esp
c0105bb0:	5e                   	pop    %esi
c0105bb1:	5f                   	pop    %edi
c0105bb2:	5d                   	pop    %ebp
c0105bb3:	c3                   	ret    

c0105bb4 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c0105bb4:	55                   	push   %ebp
c0105bb5:	89 e5                	mov    %esp,%ebp
c0105bb7:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c0105bba:	8b 45 08             	mov    0x8(%ebp),%eax
c0105bbd:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c0105bc0:	eb 21                	jmp    c0105be3 <strncpy+0x2f>
        if ((*p = *src) != '\0') {
c0105bc2:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105bc5:	0f b6 10             	movzbl (%eax),%edx
c0105bc8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105bcb:	88 10                	mov    %dl,(%eax)
c0105bcd:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105bd0:	0f b6 00             	movzbl (%eax),%eax
c0105bd3:	84 c0                	test   %al,%al
c0105bd5:	74 04                	je     c0105bdb <strncpy+0x27>
            src ++;
c0105bd7:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
c0105bdb:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0105bdf:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
    char *p = dst;
    while (len > 0) {
c0105be3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105be7:	75 d9                	jne    c0105bc2 <strncpy+0xe>
        if ((*p = *src) != '\0') {
            src ++;
        }
        p ++, len --;
    }
    return dst;
c0105be9:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0105bec:	c9                   	leave  
c0105bed:	c3                   	ret    

c0105bee <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c0105bee:	55                   	push   %ebp
c0105bef:	89 e5                	mov    %esp,%ebp
c0105bf1:	57                   	push   %edi
c0105bf2:	56                   	push   %esi
c0105bf3:	83 ec 20             	sub    $0x20,%esp
c0105bf6:	8b 45 08             	mov    0x8(%ebp),%eax
c0105bf9:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105bfc:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105bff:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCMP
#define __HAVE_ARCH_STRCMP
static inline int
__strcmp(const char *s1, const char *s2) {
    int d0, d1, ret;
    asm volatile (
c0105c02:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105c05:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105c08:	89 d1                	mov    %edx,%ecx
c0105c0a:	89 c2                	mov    %eax,%edx
c0105c0c:	89 ce                	mov    %ecx,%esi
c0105c0e:	89 d7                	mov    %edx,%edi
c0105c10:	ac                   	lods   %ds:(%esi),%al
c0105c11:	ae                   	scas   %es:(%edi),%al
c0105c12:	75 08                	jne    c0105c1c <strcmp+0x2e>
c0105c14:	84 c0                	test   %al,%al
c0105c16:	75 f8                	jne    c0105c10 <strcmp+0x22>
c0105c18:	31 c0                	xor    %eax,%eax
c0105c1a:	eb 04                	jmp    c0105c20 <strcmp+0x32>
c0105c1c:	19 c0                	sbb    %eax,%eax
c0105c1e:	0c 01                	or     $0x1,%al
c0105c20:	89 fa                	mov    %edi,%edx
c0105c22:	89 f1                	mov    %esi,%ecx
c0105c24:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105c27:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0105c2a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
        "orb $1, %%al;"
        "3:"
        : "=a" (ret), "=&S" (d0), "=&D" (d1)
        : "1" (s1), "2" (s2)
        : "memory");
    return ret;
c0105c2d:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c0105c30:	83 c4 20             	add    $0x20,%esp
c0105c33:	5e                   	pop    %esi
c0105c34:	5f                   	pop    %edi
c0105c35:	5d                   	pop    %ebp
c0105c36:	c3                   	ret    

c0105c37 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c0105c37:	55                   	push   %ebp
c0105c38:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0105c3a:	eb 0c                	jmp    c0105c48 <strncmp+0x11>
        n --, s1 ++, s2 ++;
c0105c3c:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c0105c40:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0105c44:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0105c48:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105c4c:	74 1a                	je     c0105c68 <strncmp+0x31>
c0105c4e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c51:	0f b6 00             	movzbl (%eax),%eax
c0105c54:	84 c0                	test   %al,%al
c0105c56:	74 10                	je     c0105c68 <strncmp+0x31>
c0105c58:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c5b:	0f b6 10             	movzbl (%eax),%edx
c0105c5e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c61:	0f b6 00             	movzbl (%eax),%eax
c0105c64:	38 c2                	cmp    %al,%dl
c0105c66:	74 d4                	je     c0105c3c <strncmp+0x5>
        n --, s1 ++, s2 ++;
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c0105c68:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105c6c:	74 18                	je     c0105c86 <strncmp+0x4f>
c0105c6e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c71:	0f b6 00             	movzbl (%eax),%eax
c0105c74:	0f b6 d0             	movzbl %al,%edx
c0105c77:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c7a:	0f b6 00             	movzbl (%eax),%eax
c0105c7d:	0f b6 c0             	movzbl %al,%eax
c0105c80:	29 c2                	sub    %eax,%edx
c0105c82:	89 d0                	mov    %edx,%eax
c0105c84:	eb 05                	jmp    c0105c8b <strncmp+0x54>
c0105c86:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105c8b:	5d                   	pop    %ebp
c0105c8c:	c3                   	ret    

c0105c8d <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c0105c8d:	55                   	push   %ebp
c0105c8e:	89 e5                	mov    %esp,%ebp
c0105c90:	83 ec 04             	sub    $0x4,%esp
c0105c93:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c96:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0105c99:	eb 14                	jmp    c0105caf <strchr+0x22>
        if (*s == c) {
c0105c9b:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c9e:	0f b6 00             	movzbl (%eax),%eax
c0105ca1:	3a 45 fc             	cmp    -0x4(%ebp),%al
c0105ca4:	75 05                	jne    c0105cab <strchr+0x1e>
            return (char *)s;
c0105ca6:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ca9:	eb 13                	jmp    c0105cbe <strchr+0x31>
        }
        s ++;
c0105cab:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
c0105caf:	8b 45 08             	mov    0x8(%ebp),%eax
c0105cb2:	0f b6 00             	movzbl (%eax),%eax
c0105cb5:	84 c0                	test   %al,%al
c0105cb7:	75 e2                	jne    c0105c9b <strchr+0xe>
        if (*s == c) {
            return (char *)s;
        }
        s ++;
    }
    return NULL;
c0105cb9:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105cbe:	c9                   	leave  
c0105cbf:	c3                   	ret    

c0105cc0 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c0105cc0:	55                   	push   %ebp
c0105cc1:	89 e5                	mov    %esp,%ebp
c0105cc3:	83 ec 04             	sub    $0x4,%esp
c0105cc6:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105cc9:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0105ccc:	eb 11                	jmp    c0105cdf <strfind+0x1f>
        if (*s == c) {
c0105cce:	8b 45 08             	mov    0x8(%ebp),%eax
c0105cd1:	0f b6 00             	movzbl (%eax),%eax
c0105cd4:	3a 45 fc             	cmp    -0x4(%ebp),%al
c0105cd7:	75 02                	jne    c0105cdb <strfind+0x1b>
            break;
c0105cd9:	eb 0e                	jmp    c0105ce9 <strfind+0x29>
        }
        s ++;
c0105cdb:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
    while (*s != '\0') {
c0105cdf:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ce2:	0f b6 00             	movzbl (%eax),%eax
c0105ce5:	84 c0                	test   %al,%al
c0105ce7:	75 e5                	jne    c0105cce <strfind+0xe>
        if (*s == c) {
            break;
        }
        s ++;
    }
    return (char *)s;
c0105ce9:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0105cec:	c9                   	leave  
c0105ced:	c3                   	ret    

c0105cee <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c0105cee:	55                   	push   %ebp
c0105cef:	89 e5                	mov    %esp,%ebp
c0105cf1:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c0105cf4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c0105cfb:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c0105d02:	eb 04                	jmp    c0105d08 <strtol+0x1a>
        s ++;
c0105d04:	83 45 08 01          	addl   $0x1,0x8(%ebp)
strtol(const char *s, char **endptr, int base) {
    int neg = 0;
    long val = 0;

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c0105d08:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d0b:	0f b6 00             	movzbl (%eax),%eax
c0105d0e:	3c 20                	cmp    $0x20,%al
c0105d10:	74 f2                	je     c0105d04 <strtol+0x16>
c0105d12:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d15:	0f b6 00             	movzbl (%eax),%eax
c0105d18:	3c 09                	cmp    $0x9,%al
c0105d1a:	74 e8                	je     c0105d04 <strtol+0x16>
        s ++;
    }

    // plus/minus sign
    if (*s == '+') {
c0105d1c:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d1f:	0f b6 00             	movzbl (%eax),%eax
c0105d22:	3c 2b                	cmp    $0x2b,%al
c0105d24:	75 06                	jne    c0105d2c <strtol+0x3e>
        s ++;
c0105d26:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0105d2a:	eb 15                	jmp    c0105d41 <strtol+0x53>
    }
    else if (*s == '-') {
c0105d2c:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d2f:	0f b6 00             	movzbl (%eax),%eax
c0105d32:	3c 2d                	cmp    $0x2d,%al
c0105d34:	75 0b                	jne    c0105d41 <strtol+0x53>
        s ++, neg = 1;
c0105d36:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0105d3a:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c0105d41:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105d45:	74 06                	je     c0105d4d <strtol+0x5f>
c0105d47:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c0105d4b:	75 24                	jne    c0105d71 <strtol+0x83>
c0105d4d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d50:	0f b6 00             	movzbl (%eax),%eax
c0105d53:	3c 30                	cmp    $0x30,%al
c0105d55:	75 1a                	jne    c0105d71 <strtol+0x83>
c0105d57:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d5a:	83 c0 01             	add    $0x1,%eax
c0105d5d:	0f b6 00             	movzbl (%eax),%eax
c0105d60:	3c 78                	cmp    $0x78,%al
c0105d62:	75 0d                	jne    c0105d71 <strtol+0x83>
        s += 2, base = 16;
c0105d64:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c0105d68:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c0105d6f:	eb 2a                	jmp    c0105d9b <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
c0105d71:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105d75:	75 17                	jne    c0105d8e <strtol+0xa0>
c0105d77:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d7a:	0f b6 00             	movzbl (%eax),%eax
c0105d7d:	3c 30                	cmp    $0x30,%al
c0105d7f:	75 0d                	jne    c0105d8e <strtol+0xa0>
        s ++, base = 8;
c0105d81:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0105d85:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c0105d8c:	eb 0d                	jmp    c0105d9b <strtol+0xad>
    }
    else if (base == 0) {
c0105d8e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105d92:	75 07                	jne    c0105d9b <strtol+0xad>
        base = 10;
c0105d94:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c0105d9b:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d9e:	0f b6 00             	movzbl (%eax),%eax
c0105da1:	3c 2f                	cmp    $0x2f,%al
c0105da3:	7e 1b                	jle    c0105dc0 <strtol+0xd2>
c0105da5:	8b 45 08             	mov    0x8(%ebp),%eax
c0105da8:	0f b6 00             	movzbl (%eax),%eax
c0105dab:	3c 39                	cmp    $0x39,%al
c0105dad:	7f 11                	jg     c0105dc0 <strtol+0xd2>
            dig = *s - '0';
c0105daf:	8b 45 08             	mov    0x8(%ebp),%eax
c0105db2:	0f b6 00             	movzbl (%eax),%eax
c0105db5:	0f be c0             	movsbl %al,%eax
c0105db8:	83 e8 30             	sub    $0x30,%eax
c0105dbb:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105dbe:	eb 48                	jmp    c0105e08 <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
c0105dc0:	8b 45 08             	mov    0x8(%ebp),%eax
c0105dc3:	0f b6 00             	movzbl (%eax),%eax
c0105dc6:	3c 60                	cmp    $0x60,%al
c0105dc8:	7e 1b                	jle    c0105de5 <strtol+0xf7>
c0105dca:	8b 45 08             	mov    0x8(%ebp),%eax
c0105dcd:	0f b6 00             	movzbl (%eax),%eax
c0105dd0:	3c 7a                	cmp    $0x7a,%al
c0105dd2:	7f 11                	jg     c0105de5 <strtol+0xf7>
            dig = *s - 'a' + 10;
c0105dd4:	8b 45 08             	mov    0x8(%ebp),%eax
c0105dd7:	0f b6 00             	movzbl (%eax),%eax
c0105dda:	0f be c0             	movsbl %al,%eax
c0105ddd:	83 e8 57             	sub    $0x57,%eax
c0105de0:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105de3:	eb 23                	jmp    c0105e08 <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c0105de5:	8b 45 08             	mov    0x8(%ebp),%eax
c0105de8:	0f b6 00             	movzbl (%eax),%eax
c0105deb:	3c 40                	cmp    $0x40,%al
c0105ded:	7e 3d                	jle    c0105e2c <strtol+0x13e>
c0105def:	8b 45 08             	mov    0x8(%ebp),%eax
c0105df2:	0f b6 00             	movzbl (%eax),%eax
c0105df5:	3c 5a                	cmp    $0x5a,%al
c0105df7:	7f 33                	jg     c0105e2c <strtol+0x13e>
            dig = *s - 'A' + 10;
c0105df9:	8b 45 08             	mov    0x8(%ebp),%eax
c0105dfc:	0f b6 00             	movzbl (%eax),%eax
c0105dff:	0f be c0             	movsbl %al,%eax
c0105e02:	83 e8 37             	sub    $0x37,%eax
c0105e05:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c0105e08:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105e0b:	3b 45 10             	cmp    0x10(%ebp),%eax
c0105e0e:	7c 02                	jl     c0105e12 <strtol+0x124>
            break;
c0105e10:	eb 1a                	jmp    c0105e2c <strtol+0x13e>
        }
        s ++, val = (val * base) + dig;
c0105e12:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0105e16:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105e19:	0f af 45 10          	imul   0x10(%ebp),%eax
c0105e1d:	89 c2                	mov    %eax,%edx
c0105e1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105e22:	01 d0                	add    %edx,%eax
c0105e24:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
c0105e27:	e9 6f ff ff ff       	jmp    c0105d9b <strtol+0xad>

    if (endptr) {
c0105e2c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105e30:	74 08                	je     c0105e3a <strtol+0x14c>
        *endptr = (char *) s;
c0105e32:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105e35:	8b 55 08             	mov    0x8(%ebp),%edx
c0105e38:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c0105e3a:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0105e3e:	74 07                	je     c0105e47 <strtol+0x159>
c0105e40:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105e43:	f7 d8                	neg    %eax
c0105e45:	eb 03                	jmp    c0105e4a <strtol+0x15c>
c0105e47:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c0105e4a:	c9                   	leave  
c0105e4b:	c3                   	ret    

c0105e4c <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c0105e4c:	55                   	push   %ebp
c0105e4d:	89 e5                	mov    %esp,%ebp
c0105e4f:	57                   	push   %edi
c0105e50:	83 ec 24             	sub    $0x24,%esp
c0105e53:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105e56:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c0105e59:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
c0105e5d:	8b 55 08             	mov    0x8(%ebp),%edx
c0105e60:	89 55 f8             	mov    %edx,-0x8(%ebp)
c0105e63:	88 45 f7             	mov    %al,-0x9(%ebp)
c0105e66:	8b 45 10             	mov    0x10(%ebp),%eax
c0105e69:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c0105e6c:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0105e6f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c0105e73:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0105e76:	89 d7                	mov    %edx,%edi
c0105e78:	f3 aa                	rep stos %al,%es:(%edi)
c0105e7a:	89 fa                	mov    %edi,%edx
c0105e7c:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0105e7f:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c0105e82:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c0105e85:	83 c4 24             	add    $0x24,%esp
c0105e88:	5f                   	pop    %edi
c0105e89:	5d                   	pop    %ebp
c0105e8a:	c3                   	ret    

c0105e8b <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c0105e8b:	55                   	push   %ebp
c0105e8c:	89 e5                	mov    %esp,%ebp
c0105e8e:	57                   	push   %edi
c0105e8f:	56                   	push   %esi
c0105e90:	53                   	push   %ebx
c0105e91:	83 ec 30             	sub    $0x30,%esp
c0105e94:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e97:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105e9a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105e9d:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105ea0:	8b 45 10             	mov    0x10(%ebp),%eax
c0105ea3:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c0105ea6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105ea9:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0105eac:	73 42                	jae    c0105ef0 <memmove+0x65>
c0105eae:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105eb1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105eb4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105eb7:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105eba:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105ebd:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0105ec0:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105ec3:	c1 e8 02             	shr    $0x2,%eax
c0105ec6:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c0105ec8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105ecb:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105ece:	89 d7                	mov    %edx,%edi
c0105ed0:	89 c6                	mov    %eax,%esi
c0105ed2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0105ed4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0105ed7:	83 e1 03             	and    $0x3,%ecx
c0105eda:	74 02                	je     c0105ede <memmove+0x53>
c0105edc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0105ede:	89 f0                	mov    %esi,%eax
c0105ee0:	89 fa                	mov    %edi,%edx
c0105ee2:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c0105ee5:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0105ee8:	89 45 d0             	mov    %eax,-0x30(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c0105eeb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105eee:	eb 36                	jmp    c0105f26 <memmove+0x9b>
    asm volatile (
        "std;"
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c0105ef0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105ef3:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105ef6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105ef9:	01 c2                	add    %eax,%edx
c0105efb:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105efe:	8d 48 ff             	lea    -0x1(%eax),%ecx
c0105f01:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105f04:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
        return __memcpy(dst, src, n);
    }
    int d0, d1, d2;
    asm volatile (
c0105f07:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105f0a:	89 c1                	mov    %eax,%ecx
c0105f0c:	89 d8                	mov    %ebx,%eax
c0105f0e:	89 d6                	mov    %edx,%esi
c0105f10:	89 c7                	mov    %eax,%edi
c0105f12:	fd                   	std    
c0105f13:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0105f15:	fc                   	cld    
c0105f16:	89 f8                	mov    %edi,%eax
c0105f18:	89 f2                	mov    %esi,%edx
c0105f1a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c0105f1d:	89 55 c8             	mov    %edx,-0x38(%ebp)
c0105f20:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
        : "memory");
    return dst;
c0105f23:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c0105f26:	83 c4 30             	add    $0x30,%esp
c0105f29:	5b                   	pop    %ebx
c0105f2a:	5e                   	pop    %esi
c0105f2b:	5f                   	pop    %edi
c0105f2c:	5d                   	pop    %ebp
c0105f2d:	c3                   	ret    

c0105f2e <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c0105f2e:	55                   	push   %ebp
c0105f2f:	89 e5                	mov    %esp,%ebp
c0105f31:	57                   	push   %edi
c0105f32:	56                   	push   %esi
c0105f33:	83 ec 20             	sub    $0x20,%esp
c0105f36:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f39:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105f3c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105f3f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105f42:	8b 45 10             	mov    0x10(%ebp),%eax
c0105f45:	89 45 ec             	mov    %eax,-0x14(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0105f48:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105f4b:	c1 e8 02             	shr    $0x2,%eax
c0105f4e:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c0105f50:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105f53:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105f56:	89 d7                	mov    %edx,%edi
c0105f58:	89 c6                	mov    %eax,%esi
c0105f5a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0105f5c:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c0105f5f:	83 e1 03             	and    $0x3,%ecx
c0105f62:	74 02                	je     c0105f66 <memcpy+0x38>
c0105f64:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0105f66:	89 f0                	mov    %esi,%eax
c0105f68:	89 fa                	mov    %edi,%edx
c0105f6a:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0105f6d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0105f70:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c0105f73:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c0105f76:	83 c4 20             	add    $0x20,%esp
c0105f79:	5e                   	pop    %esi
c0105f7a:	5f                   	pop    %edi
c0105f7b:	5d                   	pop    %ebp
c0105f7c:	c3                   	ret    

c0105f7d <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c0105f7d:	55                   	push   %ebp
c0105f7e:	89 e5                	mov    %esp,%ebp
c0105f80:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c0105f83:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f86:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c0105f89:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105f8c:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c0105f8f:	eb 30                	jmp    c0105fc1 <memcmp+0x44>
        if (*s1 != *s2) {
c0105f91:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105f94:	0f b6 10             	movzbl (%eax),%edx
c0105f97:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105f9a:	0f b6 00             	movzbl (%eax),%eax
c0105f9d:	38 c2                	cmp    %al,%dl
c0105f9f:	74 18                	je     c0105fb9 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c0105fa1:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105fa4:	0f b6 00             	movzbl (%eax),%eax
c0105fa7:	0f b6 d0             	movzbl %al,%edx
c0105faa:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105fad:	0f b6 00             	movzbl (%eax),%eax
c0105fb0:	0f b6 c0             	movzbl %al,%eax
c0105fb3:	29 c2                	sub    %eax,%edx
c0105fb5:	89 d0                	mov    %edx,%eax
c0105fb7:	eb 1a                	jmp    c0105fd3 <memcmp+0x56>
        }
        s1 ++, s2 ++;
c0105fb9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0105fbd:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
c0105fc1:	8b 45 10             	mov    0x10(%ebp),%eax
c0105fc4:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105fc7:	89 55 10             	mov    %edx,0x10(%ebp)
c0105fca:	85 c0                	test   %eax,%eax
c0105fcc:	75 c3                	jne    c0105f91 <memcmp+0x14>
        if (*s1 != *s2) {
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
    }
    return 0;
c0105fce:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105fd3:	c9                   	leave  
c0105fd4:	c3                   	ret    
