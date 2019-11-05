
bin/kernel_nopage：     文件格式 elf32-i386


Disassembly of section .text:

00100000 <kern_entry>:
.text
.globl kern_entry
kern_entry:
    # reload temperate gdt (second time) to remap all physical memory
    # virtual_addr 0~4G=linear_addr&physical_addr -KERNBASE~4G-KERNBASE 
    lgdt REALLOC(__gdtdesc)
  100000:	0f 01 15 18 70 11 40 	lgdtl  0x40117018
    movl $KERNEL_DS, %eax
  100007:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
  10000c:	8e d8                	mov    %eax,%ds
    movw %ax, %es
  10000e:	8e c0                	mov    %eax,%es
    movw %ax, %ss
  100010:	8e d0                	mov    %eax,%ss

    ljmp $KERNEL_CS, $relocated
  100012:	ea 19 00 10 00 08 00 	ljmp   $0x8,$0x100019

00100019 <relocated>:

relocated:

    # set ebp, esp
    movl $0x0, %ebp
  100019:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
  10001e:	bc 00 70 11 00       	mov    $0x117000,%esp
    # now kernel stack is ready , call the first C function
    call kern_init
  100023:	e8 02 00 00 00       	call   10002a <kern_init>

00100028 <spin>:

# should never get here
spin:
    jmp spin
  100028:	eb fe                	jmp    100028 <spin>

0010002a <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

int
kern_init(void) {
  10002a:	55                   	push   %ebp
  10002b:	89 e5                	mov    %esp,%ebp
  10002d:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
  100030:	ba c8 89 11 00       	mov    $0x1189c8,%edx
  100035:	b8 36 7a 11 00       	mov    $0x117a36,%eax
  10003a:	29 c2                	sub    %eax,%edx
  10003c:	89 d0                	mov    %edx,%eax
  10003e:	89 44 24 08          	mov    %eax,0x8(%esp)
  100042:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  100049:	00 
  10004a:	c7 04 24 36 7a 11 00 	movl   $0x117a36,(%esp)
  100051:	e8 f6 5d 00 00       	call   105e4c <memset>

    cons_init();                // init the console
  100056:	e8 7c 15 00 00       	call   1015d7 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
  10005b:	c7 45 f4 e0 5f 10 00 	movl   $0x105fe0,-0xc(%ebp)
    cprintf("%s\n\n", message);
  100062:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100065:	89 44 24 04          	mov    %eax,0x4(%esp)
  100069:	c7 04 24 fc 5f 10 00 	movl   $0x105ffc,(%esp)
  100070:	e8 d2 02 00 00       	call   100347 <cprintf>

    print_kerninfo();
  100075:	e8 01 08 00 00       	call   10087b <print_kerninfo>

    grade_backtrace();
  10007a:	e8 86 00 00 00       	call   100105 <grade_backtrace>

    pmm_init();                 // init physical memory management
  10007f:	e8 e4 42 00 00       	call   104368 <pmm_init>

    pic_init();                 // init interrupt controller
  100084:	e8 b7 16 00 00       	call   101740 <pic_init>
    idt_init();                 // init interrupt descriptor table
  100089:	e8 09 18 00 00       	call   101897 <idt_init>

    clock_init();               // init clock interrupt
  10008e:	e8 fa 0c 00 00       	call   100d8d <clock_init>
    intr_enable();              // enable irq interrupt
  100093:	e8 16 16 00 00       	call   1016ae <intr_enable>
    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();

    /* do nothing */
    while (1);
  100098:	eb fe                	jmp    100098 <kern_init+0x6e>

0010009a <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
  10009a:	55                   	push   %ebp
  10009b:	89 e5                	mov    %esp,%ebp
  10009d:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
  1000a0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1000a7:	00 
  1000a8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1000af:	00 
  1000b0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  1000b7:	e8 03 0c 00 00       	call   100cbf <mon_backtrace>
}
  1000bc:	c9                   	leave  
  1000bd:	c3                   	ret    

001000be <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
  1000be:	55                   	push   %ebp
  1000bf:	89 e5                	mov    %esp,%ebp
  1000c1:	53                   	push   %ebx
  1000c2:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
  1000c5:	8d 5d 0c             	lea    0xc(%ebp),%ebx
  1000c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  1000cb:	8d 55 08             	lea    0x8(%ebp),%edx
  1000ce:	8b 45 08             	mov    0x8(%ebp),%eax
  1000d1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  1000d5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  1000d9:	89 54 24 04          	mov    %edx,0x4(%esp)
  1000dd:	89 04 24             	mov    %eax,(%esp)
  1000e0:	e8 b5 ff ff ff       	call   10009a <grade_backtrace2>
}
  1000e5:	83 c4 14             	add    $0x14,%esp
  1000e8:	5b                   	pop    %ebx
  1000e9:	5d                   	pop    %ebp
  1000ea:	c3                   	ret    

001000eb <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
  1000eb:	55                   	push   %ebp
  1000ec:	89 e5                	mov    %esp,%ebp
  1000ee:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
  1000f1:	8b 45 10             	mov    0x10(%ebp),%eax
  1000f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  1000f8:	8b 45 08             	mov    0x8(%ebp),%eax
  1000fb:	89 04 24             	mov    %eax,(%esp)
  1000fe:	e8 bb ff ff ff       	call   1000be <grade_backtrace1>
}
  100103:	c9                   	leave  
  100104:	c3                   	ret    

00100105 <grade_backtrace>:

void
grade_backtrace(void) {
  100105:	55                   	push   %ebp
  100106:	89 e5                	mov    %esp,%ebp
  100108:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
  10010b:	b8 2a 00 10 00       	mov    $0x10002a,%eax
  100110:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
  100117:	ff 
  100118:	89 44 24 04          	mov    %eax,0x4(%esp)
  10011c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100123:	e8 c3 ff ff ff       	call   1000eb <grade_backtrace0>
}
  100128:	c9                   	leave  
  100129:	c3                   	ret    

0010012a <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
  10012a:	55                   	push   %ebp
  10012b:	89 e5                	mov    %esp,%ebp
  10012d:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
  100130:	8c 4d f6             	mov    %cs,-0xa(%ebp)
  100133:	8c 5d f4             	mov    %ds,-0xc(%ebp)
  100136:	8c 45 f2             	mov    %es,-0xe(%ebp)
  100139:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
  10013c:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100140:	0f b7 c0             	movzwl %ax,%eax
  100143:	83 e0 03             	and    $0x3,%eax
  100146:	89 c2                	mov    %eax,%edx
  100148:	a1 40 7a 11 00       	mov    0x117a40,%eax
  10014d:	89 54 24 08          	mov    %edx,0x8(%esp)
  100151:	89 44 24 04          	mov    %eax,0x4(%esp)
  100155:	c7 04 24 01 60 10 00 	movl   $0x106001,(%esp)
  10015c:	e8 e6 01 00 00       	call   100347 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
  100161:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100165:	0f b7 d0             	movzwl %ax,%edx
  100168:	a1 40 7a 11 00       	mov    0x117a40,%eax
  10016d:	89 54 24 08          	mov    %edx,0x8(%esp)
  100171:	89 44 24 04          	mov    %eax,0x4(%esp)
  100175:	c7 04 24 0f 60 10 00 	movl   $0x10600f,(%esp)
  10017c:	e8 c6 01 00 00       	call   100347 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
  100181:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
  100185:	0f b7 d0             	movzwl %ax,%edx
  100188:	a1 40 7a 11 00       	mov    0x117a40,%eax
  10018d:	89 54 24 08          	mov    %edx,0x8(%esp)
  100191:	89 44 24 04          	mov    %eax,0x4(%esp)
  100195:	c7 04 24 1d 60 10 00 	movl   $0x10601d,(%esp)
  10019c:	e8 a6 01 00 00       	call   100347 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
  1001a1:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  1001a5:	0f b7 d0             	movzwl %ax,%edx
  1001a8:	a1 40 7a 11 00       	mov    0x117a40,%eax
  1001ad:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001b5:	c7 04 24 2b 60 10 00 	movl   $0x10602b,(%esp)
  1001bc:	e8 86 01 00 00       	call   100347 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
  1001c1:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  1001c5:	0f b7 d0             	movzwl %ax,%edx
  1001c8:	a1 40 7a 11 00       	mov    0x117a40,%eax
  1001cd:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001d5:	c7 04 24 39 60 10 00 	movl   $0x106039,(%esp)
  1001dc:	e8 66 01 00 00       	call   100347 <cprintf>
    round ++;
  1001e1:	a1 40 7a 11 00       	mov    0x117a40,%eax
  1001e6:	83 c0 01             	add    $0x1,%eax
  1001e9:	a3 40 7a 11 00       	mov    %eax,0x117a40
}
  1001ee:	c9                   	leave  
  1001ef:	c3                   	ret    

001001f0 <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
  1001f0:	55                   	push   %ebp
  1001f1:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
	asm volatile (
  1001f3:	83 ec 08             	sub    $0x8,%esp
  1001f6:	cd 78                	int    $0x78
  1001f8:	89 ec                	mov    %ebp,%esp
	    "int %0 \n"
	    "movl %%ebp, %%esp"
	    : 
	    : "i"(T_SWITCH_TOU)
	);
}
  1001fa:	5d                   	pop    %ebp
  1001fb:	c3                   	ret    

001001fc <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
  1001fc:	55                   	push   %ebp
  1001fd:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
	asm volatile (
  1001ff:	cd 79                	int    $0x79
  100201:	89 ec                	mov    %ebp,%esp
	    "int %0 \n"
	    "movl %%ebp, %%esp \n"
	    : 
	    : "i"(T_SWITCH_TOK)
	);
}
  100203:	5d                   	pop    %ebp
  100204:	c3                   	ret    

00100205 <lab1_switch_test>:

static void
lab1_switch_test(void) {
  100205:	55                   	push   %ebp
  100206:	89 e5                	mov    %esp,%ebp
  100208:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
  10020b:	e8 1a ff ff ff       	call   10012a <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
  100210:	c7 04 24 48 60 10 00 	movl   $0x106048,(%esp)
  100217:	e8 2b 01 00 00       	call   100347 <cprintf>
    lab1_switch_to_user();
  10021c:	e8 cf ff ff ff       	call   1001f0 <lab1_switch_to_user>
    lab1_print_cur_status();
  100221:	e8 04 ff ff ff       	call   10012a <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
  100226:	c7 04 24 68 60 10 00 	movl   $0x106068,(%esp)
  10022d:	e8 15 01 00 00       	call   100347 <cprintf>
    lab1_switch_to_kernel();
  100232:	e8 c5 ff ff ff       	call   1001fc <lab1_switch_to_kernel>
    lab1_print_cur_status();
  100237:	e8 ee fe ff ff       	call   10012a <lab1_print_cur_status>
}
  10023c:	c9                   	leave  
  10023d:	c3                   	ret    

0010023e <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
  10023e:	55                   	push   %ebp
  10023f:	89 e5                	mov    %esp,%ebp
  100241:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
  100244:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100248:	74 13                	je     10025d <readline+0x1f>
        cprintf("%s", prompt);
  10024a:	8b 45 08             	mov    0x8(%ebp),%eax
  10024d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100251:	c7 04 24 87 60 10 00 	movl   $0x106087,(%esp)
  100258:	e8 ea 00 00 00       	call   100347 <cprintf>
    }
    int i = 0, c;
  10025d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
  100264:	e8 66 01 00 00       	call   1003cf <getchar>
  100269:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
  10026c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100270:	79 07                	jns    100279 <readline+0x3b>
            return NULL;
  100272:	b8 00 00 00 00       	mov    $0x0,%eax
  100277:	eb 79                	jmp    1002f2 <readline+0xb4>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
  100279:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
  10027d:	7e 28                	jle    1002a7 <readline+0x69>
  10027f:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
  100286:	7f 1f                	jg     1002a7 <readline+0x69>
            cputchar(c);
  100288:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10028b:	89 04 24             	mov    %eax,(%esp)
  10028e:	e8 da 00 00 00       	call   10036d <cputchar>
            buf[i ++] = c;
  100293:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100296:	8d 50 01             	lea    0x1(%eax),%edx
  100299:	89 55 f4             	mov    %edx,-0xc(%ebp)
  10029c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10029f:	88 90 60 7a 11 00    	mov    %dl,0x117a60(%eax)
  1002a5:	eb 46                	jmp    1002ed <readline+0xaf>
        }
        else if (c == '\b' && i > 0) {
  1002a7:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
  1002ab:	75 17                	jne    1002c4 <readline+0x86>
  1002ad:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1002b1:	7e 11                	jle    1002c4 <readline+0x86>
            cputchar(c);
  1002b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1002b6:	89 04 24             	mov    %eax,(%esp)
  1002b9:	e8 af 00 00 00       	call   10036d <cputchar>
            i --;
  1002be:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  1002c2:	eb 29                	jmp    1002ed <readline+0xaf>
        }
        else if (c == '\n' || c == '\r') {
  1002c4:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
  1002c8:	74 06                	je     1002d0 <readline+0x92>
  1002ca:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
  1002ce:	75 1d                	jne    1002ed <readline+0xaf>
            cputchar(c);
  1002d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1002d3:	89 04 24             	mov    %eax,(%esp)
  1002d6:	e8 92 00 00 00       	call   10036d <cputchar>
            buf[i] = '\0';
  1002db:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1002de:	05 60 7a 11 00       	add    $0x117a60,%eax
  1002e3:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
  1002e6:	b8 60 7a 11 00       	mov    $0x117a60,%eax
  1002eb:	eb 05                	jmp    1002f2 <readline+0xb4>
        }
    }
  1002ed:	e9 72 ff ff ff       	jmp    100264 <readline+0x26>
}
  1002f2:	c9                   	leave  
  1002f3:	c3                   	ret    

001002f4 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  1002f4:	55                   	push   %ebp
  1002f5:	89 e5                	mov    %esp,%ebp
  1002f7:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  1002fa:	8b 45 08             	mov    0x8(%ebp),%eax
  1002fd:	89 04 24             	mov    %eax,(%esp)
  100300:	e8 fe 12 00 00       	call   101603 <cons_putc>
    (*cnt) ++;
  100305:	8b 45 0c             	mov    0xc(%ebp),%eax
  100308:	8b 00                	mov    (%eax),%eax
  10030a:	8d 50 01             	lea    0x1(%eax),%edx
  10030d:	8b 45 0c             	mov    0xc(%ebp),%eax
  100310:	89 10                	mov    %edx,(%eax)
}
  100312:	c9                   	leave  
  100313:	c3                   	ret    

00100314 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  100314:	55                   	push   %ebp
  100315:	89 e5                	mov    %esp,%ebp
  100317:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  10031a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  100321:	8b 45 0c             	mov    0xc(%ebp),%eax
  100324:	89 44 24 0c          	mov    %eax,0xc(%esp)
  100328:	8b 45 08             	mov    0x8(%ebp),%eax
  10032b:	89 44 24 08          	mov    %eax,0x8(%esp)
  10032f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  100332:	89 44 24 04          	mov    %eax,0x4(%esp)
  100336:	c7 04 24 f4 02 10 00 	movl   $0x1002f4,(%esp)
  10033d:	e8 23 53 00 00       	call   105665 <vprintfmt>
    return cnt;
  100342:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100345:	c9                   	leave  
  100346:	c3                   	ret    

00100347 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  100347:	55                   	push   %ebp
  100348:	89 e5                	mov    %esp,%ebp
  10034a:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  10034d:	8d 45 0c             	lea    0xc(%ebp),%eax
  100350:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
  100353:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100356:	89 44 24 04          	mov    %eax,0x4(%esp)
  10035a:	8b 45 08             	mov    0x8(%ebp),%eax
  10035d:	89 04 24             	mov    %eax,(%esp)
  100360:	e8 af ff ff ff       	call   100314 <vcprintf>
  100365:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  100368:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  10036b:	c9                   	leave  
  10036c:	c3                   	ret    

0010036d <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
  10036d:	55                   	push   %ebp
  10036e:	89 e5                	mov    %esp,%ebp
  100370:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  100373:	8b 45 08             	mov    0x8(%ebp),%eax
  100376:	89 04 24             	mov    %eax,(%esp)
  100379:	e8 85 12 00 00       	call   101603 <cons_putc>
}
  10037e:	c9                   	leave  
  10037f:	c3                   	ret    

00100380 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
  100380:	55                   	push   %ebp
  100381:	89 e5                	mov    %esp,%ebp
  100383:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  100386:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
  10038d:	eb 13                	jmp    1003a2 <cputs+0x22>
        cputch(c, &cnt);
  10038f:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  100393:	8d 55 f0             	lea    -0x10(%ebp),%edx
  100396:	89 54 24 04          	mov    %edx,0x4(%esp)
  10039a:	89 04 24             	mov    %eax,(%esp)
  10039d:	e8 52 ff ff ff       	call   1002f4 <cputch>
 * */
int
cputs(const char *str) {
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
  1003a2:	8b 45 08             	mov    0x8(%ebp),%eax
  1003a5:	8d 50 01             	lea    0x1(%eax),%edx
  1003a8:	89 55 08             	mov    %edx,0x8(%ebp)
  1003ab:	0f b6 00             	movzbl (%eax),%eax
  1003ae:	88 45 f7             	mov    %al,-0x9(%ebp)
  1003b1:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
  1003b5:	75 d8                	jne    10038f <cputs+0xf>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
  1003b7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  1003ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  1003be:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  1003c5:	e8 2a ff ff ff       	call   1002f4 <cputch>
    return cnt;
  1003ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  1003cd:	c9                   	leave  
  1003ce:	c3                   	ret    

001003cf <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
  1003cf:	55                   	push   %ebp
  1003d0:	89 e5                	mov    %esp,%ebp
  1003d2:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
  1003d5:	e8 65 12 00 00       	call   10163f <cons_getc>
  1003da:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1003dd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1003e1:	74 f2                	je     1003d5 <getchar+0x6>
        /* do nothing */;
    return c;
  1003e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1003e6:	c9                   	leave  
  1003e7:	c3                   	ret    

001003e8 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
  1003e8:	55                   	push   %ebp
  1003e9:	89 e5                	mov    %esp,%ebp
  1003eb:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
  1003ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  1003f1:	8b 00                	mov    (%eax),%eax
  1003f3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  1003f6:	8b 45 10             	mov    0x10(%ebp),%eax
  1003f9:	8b 00                	mov    (%eax),%eax
  1003fb:	89 45 f8             	mov    %eax,-0x8(%ebp)
  1003fe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
  100405:	e9 d2 00 00 00       	jmp    1004dc <stab_binsearch+0xf4>
        int true_m = (l + r) / 2, m = true_m;
  10040a:	8b 45 f8             	mov    -0x8(%ebp),%eax
  10040d:	8b 55 fc             	mov    -0x4(%ebp),%edx
  100410:	01 d0                	add    %edx,%eax
  100412:	89 c2                	mov    %eax,%edx
  100414:	c1 ea 1f             	shr    $0x1f,%edx
  100417:	01 d0                	add    %edx,%eax
  100419:	d1 f8                	sar    %eax
  10041b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10041e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100421:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
  100424:	eb 04                	jmp    10042a <stab_binsearch+0x42>
            m --;
  100426:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)

    while (l <= r) {
        int true_m = (l + r) / 2, m = true_m;

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
  10042a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10042d:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  100430:	7c 1f                	jl     100451 <stab_binsearch+0x69>
  100432:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100435:	89 d0                	mov    %edx,%eax
  100437:	01 c0                	add    %eax,%eax
  100439:	01 d0                	add    %edx,%eax
  10043b:	c1 e0 02             	shl    $0x2,%eax
  10043e:	89 c2                	mov    %eax,%edx
  100440:	8b 45 08             	mov    0x8(%ebp),%eax
  100443:	01 d0                	add    %edx,%eax
  100445:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100449:	0f b6 c0             	movzbl %al,%eax
  10044c:	3b 45 14             	cmp    0x14(%ebp),%eax
  10044f:	75 d5                	jne    100426 <stab_binsearch+0x3e>
            m --;
        }
        if (m < l) {    // no match in [l, m]
  100451:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100454:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  100457:	7d 0b                	jge    100464 <stab_binsearch+0x7c>
            l = true_m + 1;
  100459:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10045c:	83 c0 01             	add    $0x1,%eax
  10045f:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
  100462:	eb 78                	jmp    1004dc <stab_binsearch+0xf4>
        }

        // actual binary search
        any_matches = 1;
  100464:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
  10046b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10046e:	89 d0                	mov    %edx,%eax
  100470:	01 c0                	add    %eax,%eax
  100472:	01 d0                	add    %edx,%eax
  100474:	c1 e0 02             	shl    $0x2,%eax
  100477:	89 c2                	mov    %eax,%edx
  100479:	8b 45 08             	mov    0x8(%ebp),%eax
  10047c:	01 d0                	add    %edx,%eax
  10047e:	8b 40 08             	mov    0x8(%eax),%eax
  100481:	3b 45 18             	cmp    0x18(%ebp),%eax
  100484:	73 13                	jae    100499 <stab_binsearch+0xb1>
            *region_left = m;
  100486:	8b 45 0c             	mov    0xc(%ebp),%eax
  100489:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10048c:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
  10048e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100491:	83 c0 01             	add    $0x1,%eax
  100494:	89 45 fc             	mov    %eax,-0x4(%ebp)
  100497:	eb 43                	jmp    1004dc <stab_binsearch+0xf4>
        } else if (stabs[m].n_value > addr) {
  100499:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10049c:	89 d0                	mov    %edx,%eax
  10049e:	01 c0                	add    %eax,%eax
  1004a0:	01 d0                	add    %edx,%eax
  1004a2:	c1 e0 02             	shl    $0x2,%eax
  1004a5:	89 c2                	mov    %eax,%edx
  1004a7:	8b 45 08             	mov    0x8(%ebp),%eax
  1004aa:	01 d0                	add    %edx,%eax
  1004ac:	8b 40 08             	mov    0x8(%eax),%eax
  1004af:	3b 45 18             	cmp    0x18(%ebp),%eax
  1004b2:	76 16                	jbe    1004ca <stab_binsearch+0xe2>
            *region_right = m - 1;
  1004b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004b7:	8d 50 ff             	lea    -0x1(%eax),%edx
  1004ba:	8b 45 10             	mov    0x10(%ebp),%eax
  1004bd:	89 10                	mov    %edx,(%eax)
            r = m - 1;
  1004bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004c2:	83 e8 01             	sub    $0x1,%eax
  1004c5:	89 45 f8             	mov    %eax,-0x8(%ebp)
  1004c8:	eb 12                	jmp    1004dc <stab_binsearch+0xf4>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
  1004ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  1004cd:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1004d0:	89 10                	mov    %edx,(%eax)
            l = m;
  1004d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004d5:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
  1004d8:	83 45 18 01          	addl   $0x1,0x18(%ebp)
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
    int l = *region_left, r = *region_right, any_matches = 0;

    while (l <= r) {
  1004dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1004df:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  1004e2:	0f 8e 22 ff ff ff    	jle    10040a <stab_binsearch+0x22>
            l = m;
            addr ++;
        }
    }

    if (!any_matches) {
  1004e8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1004ec:	75 0f                	jne    1004fd <stab_binsearch+0x115>
        *region_right = *region_left - 1;
  1004ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  1004f1:	8b 00                	mov    (%eax),%eax
  1004f3:	8d 50 ff             	lea    -0x1(%eax),%edx
  1004f6:	8b 45 10             	mov    0x10(%ebp),%eax
  1004f9:	89 10                	mov    %edx,(%eax)
  1004fb:	eb 3f                	jmp    10053c <stab_binsearch+0x154>
    }
    else {
        // find rightmost region containing 'addr'
        l = *region_right;
  1004fd:	8b 45 10             	mov    0x10(%ebp),%eax
  100500:	8b 00                	mov    (%eax),%eax
  100502:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
  100505:	eb 04                	jmp    10050b <stab_binsearch+0x123>
  100507:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
  10050b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10050e:	8b 00                	mov    (%eax),%eax
  100510:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  100513:	7d 1f                	jge    100534 <stab_binsearch+0x14c>
  100515:	8b 55 fc             	mov    -0x4(%ebp),%edx
  100518:	89 d0                	mov    %edx,%eax
  10051a:	01 c0                	add    %eax,%eax
  10051c:	01 d0                	add    %edx,%eax
  10051e:	c1 e0 02             	shl    $0x2,%eax
  100521:	89 c2                	mov    %eax,%edx
  100523:	8b 45 08             	mov    0x8(%ebp),%eax
  100526:	01 d0                	add    %edx,%eax
  100528:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  10052c:	0f b6 c0             	movzbl %al,%eax
  10052f:	3b 45 14             	cmp    0x14(%ebp),%eax
  100532:	75 d3                	jne    100507 <stab_binsearch+0x11f>
            /* do nothing */;
        *region_left = l;
  100534:	8b 45 0c             	mov    0xc(%ebp),%eax
  100537:	8b 55 fc             	mov    -0x4(%ebp),%edx
  10053a:	89 10                	mov    %edx,(%eax)
    }
}
  10053c:	c9                   	leave  
  10053d:	c3                   	ret    

0010053e <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
  10053e:	55                   	push   %ebp
  10053f:	89 e5                	mov    %esp,%ebp
  100541:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
  100544:	8b 45 0c             	mov    0xc(%ebp),%eax
  100547:	c7 00 8c 60 10 00    	movl   $0x10608c,(%eax)
    info->eip_line = 0;
  10054d:	8b 45 0c             	mov    0xc(%ebp),%eax
  100550:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
  100557:	8b 45 0c             	mov    0xc(%ebp),%eax
  10055a:	c7 40 08 8c 60 10 00 	movl   $0x10608c,0x8(%eax)
    info->eip_fn_namelen = 9;
  100561:	8b 45 0c             	mov    0xc(%ebp),%eax
  100564:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
  10056b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10056e:	8b 55 08             	mov    0x8(%ebp),%edx
  100571:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
  100574:	8b 45 0c             	mov    0xc(%ebp),%eax
  100577:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
  10057e:	c7 45 f4 c8 72 10 00 	movl   $0x1072c8,-0xc(%ebp)
    stab_end = __STAB_END__;
  100585:	c7 45 f0 3c 1f 11 00 	movl   $0x111f3c,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
  10058c:	c7 45 ec 3d 1f 11 00 	movl   $0x111f3d,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
  100593:	c7 45 e8 96 49 11 00 	movl   $0x114996,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
  10059a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10059d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  1005a0:	76 0d                	jbe    1005af <debuginfo_eip+0x71>
  1005a2:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1005a5:	83 e8 01             	sub    $0x1,%eax
  1005a8:	0f b6 00             	movzbl (%eax),%eax
  1005ab:	84 c0                	test   %al,%al
  1005ad:	74 0a                	je     1005b9 <debuginfo_eip+0x7b>
        return -1;
  1005af:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1005b4:	e9 c0 02 00 00       	jmp    100879 <debuginfo_eip+0x33b>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
  1005b9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  1005c0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1005c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1005c6:	29 c2                	sub    %eax,%edx
  1005c8:	89 d0                	mov    %edx,%eax
  1005ca:	c1 f8 02             	sar    $0x2,%eax
  1005cd:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
  1005d3:	83 e8 01             	sub    $0x1,%eax
  1005d6:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
  1005d9:	8b 45 08             	mov    0x8(%ebp),%eax
  1005dc:	89 44 24 10          	mov    %eax,0x10(%esp)
  1005e0:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
  1005e7:	00 
  1005e8:	8d 45 e0             	lea    -0x20(%ebp),%eax
  1005eb:	89 44 24 08          	mov    %eax,0x8(%esp)
  1005ef:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  1005f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  1005f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1005f9:	89 04 24             	mov    %eax,(%esp)
  1005fc:	e8 e7 fd ff ff       	call   1003e8 <stab_binsearch>
    if (lfile == 0)
  100601:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100604:	85 c0                	test   %eax,%eax
  100606:	75 0a                	jne    100612 <debuginfo_eip+0xd4>
        return -1;
  100608:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10060d:	e9 67 02 00 00       	jmp    100879 <debuginfo_eip+0x33b>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
  100612:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100615:	89 45 dc             	mov    %eax,-0x24(%ebp)
  100618:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10061b:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
  10061e:	8b 45 08             	mov    0x8(%ebp),%eax
  100621:	89 44 24 10          	mov    %eax,0x10(%esp)
  100625:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
  10062c:	00 
  10062d:	8d 45 d8             	lea    -0x28(%ebp),%eax
  100630:	89 44 24 08          	mov    %eax,0x8(%esp)
  100634:	8d 45 dc             	lea    -0x24(%ebp),%eax
  100637:	89 44 24 04          	mov    %eax,0x4(%esp)
  10063b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10063e:	89 04 24             	mov    %eax,(%esp)
  100641:	e8 a2 fd ff ff       	call   1003e8 <stab_binsearch>

    if (lfun <= rfun) {
  100646:	8b 55 dc             	mov    -0x24(%ebp),%edx
  100649:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10064c:	39 c2                	cmp    %eax,%edx
  10064e:	7f 7c                	jg     1006cc <debuginfo_eip+0x18e>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
  100650:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100653:	89 c2                	mov    %eax,%edx
  100655:	89 d0                	mov    %edx,%eax
  100657:	01 c0                	add    %eax,%eax
  100659:	01 d0                	add    %edx,%eax
  10065b:	c1 e0 02             	shl    $0x2,%eax
  10065e:	89 c2                	mov    %eax,%edx
  100660:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100663:	01 d0                	add    %edx,%eax
  100665:	8b 10                	mov    (%eax),%edx
  100667:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  10066a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10066d:	29 c1                	sub    %eax,%ecx
  10066f:	89 c8                	mov    %ecx,%eax
  100671:	39 c2                	cmp    %eax,%edx
  100673:	73 22                	jae    100697 <debuginfo_eip+0x159>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
  100675:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100678:	89 c2                	mov    %eax,%edx
  10067a:	89 d0                	mov    %edx,%eax
  10067c:	01 c0                	add    %eax,%eax
  10067e:	01 d0                	add    %edx,%eax
  100680:	c1 e0 02             	shl    $0x2,%eax
  100683:	89 c2                	mov    %eax,%edx
  100685:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100688:	01 d0                	add    %edx,%eax
  10068a:	8b 10                	mov    (%eax),%edx
  10068c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10068f:	01 c2                	add    %eax,%edx
  100691:	8b 45 0c             	mov    0xc(%ebp),%eax
  100694:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
  100697:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10069a:	89 c2                	mov    %eax,%edx
  10069c:	89 d0                	mov    %edx,%eax
  10069e:	01 c0                	add    %eax,%eax
  1006a0:	01 d0                	add    %edx,%eax
  1006a2:	c1 e0 02             	shl    $0x2,%eax
  1006a5:	89 c2                	mov    %eax,%edx
  1006a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1006aa:	01 d0                	add    %edx,%eax
  1006ac:	8b 50 08             	mov    0x8(%eax),%edx
  1006af:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006b2:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
  1006b5:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006b8:	8b 40 10             	mov    0x10(%eax),%eax
  1006bb:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
  1006be:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1006c1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
  1006c4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1006c7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1006ca:	eb 15                	jmp    1006e1 <debuginfo_eip+0x1a3>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
  1006cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006cf:	8b 55 08             	mov    0x8(%ebp),%edx
  1006d2:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
  1006d5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1006d8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
  1006db:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1006de:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
  1006e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006e4:	8b 40 08             	mov    0x8(%eax),%eax
  1006e7:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  1006ee:	00 
  1006ef:	89 04 24             	mov    %eax,(%esp)
  1006f2:	e8 c9 55 00 00       	call   105cc0 <strfind>
  1006f7:	89 c2                	mov    %eax,%edx
  1006f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006fc:	8b 40 08             	mov    0x8(%eax),%eax
  1006ff:	29 c2                	sub    %eax,%edx
  100701:	8b 45 0c             	mov    0xc(%ebp),%eax
  100704:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
  100707:	8b 45 08             	mov    0x8(%ebp),%eax
  10070a:	89 44 24 10          	mov    %eax,0x10(%esp)
  10070e:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
  100715:	00 
  100716:	8d 45 d0             	lea    -0x30(%ebp),%eax
  100719:	89 44 24 08          	mov    %eax,0x8(%esp)
  10071d:	8d 45 d4             	lea    -0x2c(%ebp),%eax
  100720:	89 44 24 04          	mov    %eax,0x4(%esp)
  100724:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100727:	89 04 24             	mov    %eax,(%esp)
  10072a:	e8 b9 fc ff ff       	call   1003e8 <stab_binsearch>
    if (lline <= rline) {
  10072f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  100732:	8b 45 d0             	mov    -0x30(%ebp),%eax
  100735:	39 c2                	cmp    %eax,%edx
  100737:	7f 24                	jg     10075d <debuginfo_eip+0x21f>
        info->eip_line = stabs[rline].n_desc;
  100739:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10073c:	89 c2                	mov    %eax,%edx
  10073e:	89 d0                	mov    %edx,%eax
  100740:	01 c0                	add    %eax,%eax
  100742:	01 d0                	add    %edx,%eax
  100744:	c1 e0 02             	shl    $0x2,%eax
  100747:	89 c2                	mov    %eax,%edx
  100749:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10074c:	01 d0                	add    %edx,%eax
  10074e:	0f b7 40 06          	movzwl 0x6(%eax),%eax
  100752:	0f b7 d0             	movzwl %ax,%edx
  100755:	8b 45 0c             	mov    0xc(%ebp),%eax
  100758:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
  10075b:	eb 13                	jmp    100770 <debuginfo_eip+0x232>
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
    if (lline <= rline) {
        info->eip_line = stabs[rline].n_desc;
    } else {
        return -1;
  10075d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  100762:	e9 12 01 00 00       	jmp    100879 <debuginfo_eip+0x33b>
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
  100767:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10076a:	83 e8 01             	sub    $0x1,%eax
  10076d:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
  100770:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  100773:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100776:	39 c2                	cmp    %eax,%edx
  100778:	7c 56                	jl     1007d0 <debuginfo_eip+0x292>
           && stabs[lline].n_type != N_SOL
  10077a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10077d:	89 c2                	mov    %eax,%edx
  10077f:	89 d0                	mov    %edx,%eax
  100781:	01 c0                	add    %eax,%eax
  100783:	01 d0                	add    %edx,%eax
  100785:	c1 e0 02             	shl    $0x2,%eax
  100788:	89 c2                	mov    %eax,%edx
  10078a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10078d:	01 d0                	add    %edx,%eax
  10078f:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100793:	3c 84                	cmp    $0x84,%al
  100795:	74 39                	je     1007d0 <debuginfo_eip+0x292>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
  100797:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10079a:	89 c2                	mov    %eax,%edx
  10079c:	89 d0                	mov    %edx,%eax
  10079e:	01 c0                	add    %eax,%eax
  1007a0:	01 d0                	add    %edx,%eax
  1007a2:	c1 e0 02             	shl    $0x2,%eax
  1007a5:	89 c2                	mov    %eax,%edx
  1007a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007aa:	01 d0                	add    %edx,%eax
  1007ac:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  1007b0:	3c 64                	cmp    $0x64,%al
  1007b2:	75 b3                	jne    100767 <debuginfo_eip+0x229>
  1007b4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1007b7:	89 c2                	mov    %eax,%edx
  1007b9:	89 d0                	mov    %edx,%eax
  1007bb:	01 c0                	add    %eax,%eax
  1007bd:	01 d0                	add    %edx,%eax
  1007bf:	c1 e0 02             	shl    $0x2,%eax
  1007c2:	89 c2                	mov    %eax,%edx
  1007c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007c7:	01 d0                	add    %edx,%eax
  1007c9:	8b 40 08             	mov    0x8(%eax),%eax
  1007cc:	85 c0                	test   %eax,%eax
  1007ce:	74 97                	je     100767 <debuginfo_eip+0x229>
        lline --;
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
  1007d0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1007d3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1007d6:	39 c2                	cmp    %eax,%edx
  1007d8:	7c 46                	jl     100820 <debuginfo_eip+0x2e2>
  1007da:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1007dd:	89 c2                	mov    %eax,%edx
  1007df:	89 d0                	mov    %edx,%eax
  1007e1:	01 c0                	add    %eax,%eax
  1007e3:	01 d0                	add    %edx,%eax
  1007e5:	c1 e0 02             	shl    $0x2,%eax
  1007e8:	89 c2                	mov    %eax,%edx
  1007ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007ed:	01 d0                	add    %edx,%eax
  1007ef:	8b 10                	mov    (%eax),%edx
  1007f1:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  1007f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1007f7:	29 c1                	sub    %eax,%ecx
  1007f9:	89 c8                	mov    %ecx,%eax
  1007fb:	39 c2                	cmp    %eax,%edx
  1007fd:	73 21                	jae    100820 <debuginfo_eip+0x2e2>
        info->eip_file = stabstr + stabs[lline].n_strx;
  1007ff:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100802:	89 c2                	mov    %eax,%edx
  100804:	89 d0                	mov    %edx,%eax
  100806:	01 c0                	add    %eax,%eax
  100808:	01 d0                	add    %edx,%eax
  10080a:	c1 e0 02             	shl    $0x2,%eax
  10080d:	89 c2                	mov    %eax,%edx
  10080f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100812:	01 d0                	add    %edx,%eax
  100814:	8b 10                	mov    (%eax),%edx
  100816:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100819:	01 c2                	add    %eax,%edx
  10081b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10081e:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
  100820:	8b 55 dc             	mov    -0x24(%ebp),%edx
  100823:	8b 45 d8             	mov    -0x28(%ebp),%eax
  100826:	39 c2                	cmp    %eax,%edx
  100828:	7d 4a                	jge    100874 <debuginfo_eip+0x336>
        for (lline = lfun + 1;
  10082a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10082d:	83 c0 01             	add    $0x1,%eax
  100830:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  100833:	eb 18                	jmp    10084d <debuginfo_eip+0x30f>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
  100835:	8b 45 0c             	mov    0xc(%ebp),%eax
  100838:	8b 40 14             	mov    0x14(%eax),%eax
  10083b:	8d 50 01             	lea    0x1(%eax),%edx
  10083e:	8b 45 0c             	mov    0xc(%ebp),%eax
  100841:	89 50 14             	mov    %edx,0x14(%eax)
    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
  100844:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100847:	83 c0 01             	add    $0x1,%eax
  10084a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
  10084d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  100850:	8b 45 d8             	mov    -0x28(%ebp),%eax
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
  100853:	39 c2                	cmp    %eax,%edx
  100855:	7d 1d                	jge    100874 <debuginfo_eip+0x336>
             lline < rfun && stabs[lline].n_type == N_PSYM;
  100857:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10085a:	89 c2                	mov    %eax,%edx
  10085c:	89 d0                	mov    %edx,%eax
  10085e:	01 c0                	add    %eax,%eax
  100860:	01 d0                	add    %edx,%eax
  100862:	c1 e0 02             	shl    $0x2,%eax
  100865:	89 c2                	mov    %eax,%edx
  100867:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10086a:	01 d0                	add    %edx,%eax
  10086c:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100870:	3c a0                	cmp    $0xa0,%al
  100872:	74 c1                	je     100835 <debuginfo_eip+0x2f7>
             lline ++) {
            info->eip_fn_narg ++;
        }
    }
    return 0;
  100874:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100879:	c9                   	leave  
  10087a:	c3                   	ret    

0010087b <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
  10087b:	55                   	push   %ebp
  10087c:	89 e5                	mov    %esp,%ebp
  10087e:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
  100881:	c7 04 24 96 60 10 00 	movl   $0x106096,(%esp)
  100888:	e8 ba fa ff ff       	call   100347 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
  10088d:	c7 44 24 04 2a 00 10 	movl   $0x10002a,0x4(%esp)
  100894:	00 
  100895:	c7 04 24 af 60 10 00 	movl   $0x1060af,(%esp)
  10089c:	e8 a6 fa ff ff       	call   100347 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
  1008a1:	c7 44 24 04 d5 5f 10 	movl   $0x105fd5,0x4(%esp)
  1008a8:	00 
  1008a9:	c7 04 24 c7 60 10 00 	movl   $0x1060c7,(%esp)
  1008b0:	e8 92 fa ff ff       	call   100347 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
  1008b5:	c7 44 24 04 36 7a 11 	movl   $0x117a36,0x4(%esp)
  1008bc:	00 
  1008bd:	c7 04 24 df 60 10 00 	movl   $0x1060df,(%esp)
  1008c4:	e8 7e fa ff ff       	call   100347 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
  1008c9:	c7 44 24 04 c8 89 11 	movl   $0x1189c8,0x4(%esp)
  1008d0:	00 
  1008d1:	c7 04 24 f7 60 10 00 	movl   $0x1060f7,(%esp)
  1008d8:	e8 6a fa ff ff       	call   100347 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
  1008dd:	b8 c8 89 11 00       	mov    $0x1189c8,%eax
  1008e2:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  1008e8:	b8 2a 00 10 00       	mov    $0x10002a,%eax
  1008ed:	29 c2                	sub    %eax,%edx
  1008ef:	89 d0                	mov    %edx,%eax
  1008f1:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  1008f7:	85 c0                	test   %eax,%eax
  1008f9:	0f 48 c2             	cmovs  %edx,%eax
  1008fc:	c1 f8 0a             	sar    $0xa,%eax
  1008ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  100903:	c7 04 24 10 61 10 00 	movl   $0x106110,(%esp)
  10090a:	e8 38 fa ff ff       	call   100347 <cprintf>
}
  10090f:	c9                   	leave  
  100910:	c3                   	ret    

00100911 <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
  100911:	55                   	push   %ebp
  100912:	89 e5                	mov    %esp,%ebp
  100914:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
  10091a:	8d 45 dc             	lea    -0x24(%ebp),%eax
  10091d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100921:	8b 45 08             	mov    0x8(%ebp),%eax
  100924:	89 04 24             	mov    %eax,(%esp)
  100927:	e8 12 fc ff ff       	call   10053e <debuginfo_eip>
  10092c:	85 c0                	test   %eax,%eax
  10092e:	74 15                	je     100945 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
  100930:	8b 45 08             	mov    0x8(%ebp),%eax
  100933:	89 44 24 04          	mov    %eax,0x4(%esp)
  100937:	c7 04 24 3a 61 10 00 	movl   $0x10613a,(%esp)
  10093e:	e8 04 fa ff ff       	call   100347 <cprintf>
  100943:	eb 6d                	jmp    1009b2 <print_debuginfo+0xa1>
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  100945:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  10094c:	eb 1c                	jmp    10096a <print_debuginfo+0x59>
            fnname[j] = info.eip_fn_name[j];
  10094e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  100951:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100954:	01 d0                	add    %edx,%eax
  100956:	0f b6 00             	movzbl (%eax),%eax
  100959:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  10095f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100962:	01 ca                	add    %ecx,%edx
  100964:	88 02                	mov    %al,(%edx)
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  100966:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  10096a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10096d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  100970:	7f dc                	jg     10094e <print_debuginfo+0x3d>
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
  100972:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
  100978:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10097b:	01 d0                	add    %edx,%eax
  10097d:	c6 00 00             	movb   $0x0,(%eax)
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
  100980:	8b 45 ec             	mov    -0x14(%ebp),%eax
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
  100983:	8b 55 08             	mov    0x8(%ebp),%edx
  100986:	89 d1                	mov    %edx,%ecx
  100988:	29 c1                	sub    %eax,%ecx
  10098a:	8b 55 e0             	mov    -0x20(%ebp),%edx
  10098d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100990:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  100994:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  10099a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  10099e:	89 54 24 08          	mov    %edx,0x8(%esp)
  1009a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009a6:	c7 04 24 56 61 10 00 	movl   $0x106156,(%esp)
  1009ad:	e8 95 f9 ff ff       	call   100347 <cprintf>
                fnname, eip - info.eip_fn_addr);
    }
}
  1009b2:	c9                   	leave  
  1009b3:	c3                   	ret    

001009b4 <read_eip>:

static __noinline uint32_t
read_eip(void) {
  1009b4:	55                   	push   %ebp
  1009b5:	89 e5                	mov    %esp,%ebp
  1009b7:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
  1009ba:	8b 45 04             	mov    0x4(%ebp),%eax
  1009bd:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
  1009c0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  1009c3:	c9                   	leave  
  1009c4:	c3                   	ret    

001009c5 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
  1009c5:	55                   	push   %ebp
  1009c6:	89 e5                	mov    %esp,%ebp
  1009c8:	83 ec 38             	sub    $0x38,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
  1009cb:	89 e8                	mov    %ebp,%eax
  1009cd:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return ebp;
  1009d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp = read_ebp(), eip = read_eip();
  1009d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1009d6:	e8 d9 ff ff ff       	call   1009b4 <read_eip>
  1009db:	89 45 f0             	mov    %eax,-0x10(%ebp)

    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
  1009de:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  1009e5:	e9 88 00 00 00       	jmp    100a72 <print_stackframe+0xad>
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
  1009ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1009ed:	89 44 24 08          	mov    %eax,0x8(%esp)
  1009f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1009f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009f8:	c7 04 24 68 61 10 00 	movl   $0x106168,(%esp)
  1009ff:	e8 43 f9 ff ff       	call   100347 <cprintf>
        uint32_t *args = (uint32_t *)ebp + 2;
  100a04:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a07:	83 c0 08             	add    $0x8,%eax
  100a0a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (j = 0; j < 4; j ++) {
  100a0d:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  100a14:	eb 25                	jmp    100a3b <print_stackframe+0x76>
            cprintf("0x%08x ", args[j]);
  100a16:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100a19:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100a20:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100a23:	01 d0                	add    %edx,%eax
  100a25:	8b 00                	mov    (%eax),%eax
  100a27:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a2b:	c7 04 24 84 61 10 00 	movl   $0x106184,(%esp)
  100a32:	e8 10 f9 ff ff       	call   100347 <cprintf>

    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
        uint32_t *args = (uint32_t *)ebp + 2;
        for (j = 0; j < 4; j ++) {
  100a37:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
  100a3b:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
  100a3f:	7e d5                	jle    100a16 <print_stackframe+0x51>
            cprintf("0x%08x ", args[j]);
        }
        cprintf("\n");
  100a41:	c7 04 24 8c 61 10 00 	movl   $0x10618c,(%esp)
  100a48:	e8 fa f8 ff ff       	call   100347 <cprintf>
        print_debuginfo(eip - 1);
  100a4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100a50:	83 e8 01             	sub    $0x1,%eax
  100a53:	89 04 24             	mov    %eax,(%esp)
  100a56:	e8 b6 fe ff ff       	call   100911 <print_debuginfo>
        eip = ((uint32_t *)ebp)[1];
  100a5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a5e:	83 c0 04             	add    $0x4,%eax
  100a61:	8b 00                	mov    (%eax),%eax
  100a63:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ebp = ((uint32_t *)ebp)[0];
  100a66:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a69:	8b 00                	mov    (%eax),%eax
  100a6b:	89 45 f4             	mov    %eax,-0xc(%ebp)
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp = read_ebp(), eip = read_eip();

    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
  100a6e:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
  100a72:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100a76:	74 0a                	je     100a82 <print_stackframe+0xbd>
  100a78:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
  100a7c:	0f 8e 68 ff ff ff    	jle    1009ea <print_stackframe+0x25>
        cprintf("\n");
        print_debuginfo(eip - 1);
        eip = ((uint32_t *)ebp)[1];
        ebp = ((uint32_t *)ebp)[0];
    }
}
  100a82:	c9                   	leave  
  100a83:	c3                   	ret    

00100a84 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
  100a84:	55                   	push   %ebp
  100a85:	89 e5                	mov    %esp,%ebp
  100a87:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
  100a8a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100a91:	eb 0c                	jmp    100a9f <parse+0x1b>
            *buf ++ = '\0';
  100a93:	8b 45 08             	mov    0x8(%ebp),%eax
  100a96:	8d 50 01             	lea    0x1(%eax),%edx
  100a99:	89 55 08             	mov    %edx,0x8(%ebp)
  100a9c:	c6 00 00             	movb   $0x0,(%eax)
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100a9f:	8b 45 08             	mov    0x8(%ebp),%eax
  100aa2:	0f b6 00             	movzbl (%eax),%eax
  100aa5:	84 c0                	test   %al,%al
  100aa7:	74 1d                	je     100ac6 <parse+0x42>
  100aa9:	8b 45 08             	mov    0x8(%ebp),%eax
  100aac:	0f b6 00             	movzbl (%eax),%eax
  100aaf:	0f be c0             	movsbl %al,%eax
  100ab2:	89 44 24 04          	mov    %eax,0x4(%esp)
  100ab6:	c7 04 24 10 62 10 00 	movl   $0x106210,(%esp)
  100abd:	e8 cb 51 00 00       	call   105c8d <strchr>
  100ac2:	85 c0                	test   %eax,%eax
  100ac4:	75 cd                	jne    100a93 <parse+0xf>
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
  100ac6:	8b 45 08             	mov    0x8(%ebp),%eax
  100ac9:	0f b6 00             	movzbl (%eax),%eax
  100acc:	84 c0                	test   %al,%al
  100ace:	75 02                	jne    100ad2 <parse+0x4e>
            break;
  100ad0:	eb 67                	jmp    100b39 <parse+0xb5>
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
  100ad2:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
  100ad6:	75 14                	jne    100aec <parse+0x68>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
  100ad8:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
  100adf:	00 
  100ae0:	c7 04 24 15 62 10 00 	movl   $0x106215,(%esp)
  100ae7:	e8 5b f8 ff ff       	call   100347 <cprintf>
        }
        argv[argc ++] = buf;
  100aec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100aef:	8d 50 01             	lea    0x1(%eax),%edx
  100af2:	89 55 f4             	mov    %edx,-0xc(%ebp)
  100af5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100afc:	8b 45 0c             	mov    0xc(%ebp),%eax
  100aff:	01 c2                	add    %eax,%edx
  100b01:	8b 45 08             	mov    0x8(%ebp),%eax
  100b04:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100b06:	eb 04                	jmp    100b0c <parse+0x88>
            buf ++;
  100b08:	83 45 08 01          	addl   $0x1,0x8(%ebp)
        // save and scan past next arg
        if (argc == MAXARGS - 1) {
            cprintf("Too many arguments (max %d).\n", MAXARGS);
        }
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100b0c:	8b 45 08             	mov    0x8(%ebp),%eax
  100b0f:	0f b6 00             	movzbl (%eax),%eax
  100b12:	84 c0                	test   %al,%al
  100b14:	74 1d                	je     100b33 <parse+0xaf>
  100b16:	8b 45 08             	mov    0x8(%ebp),%eax
  100b19:	0f b6 00             	movzbl (%eax),%eax
  100b1c:	0f be c0             	movsbl %al,%eax
  100b1f:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b23:	c7 04 24 10 62 10 00 	movl   $0x106210,(%esp)
  100b2a:	e8 5e 51 00 00       	call   105c8d <strchr>
  100b2f:	85 c0                	test   %eax,%eax
  100b31:	74 d5                	je     100b08 <parse+0x84>
            buf ++;
        }
    }
  100b33:	90                   	nop
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100b34:	e9 66 ff ff ff       	jmp    100a9f <parse+0x1b>
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
            buf ++;
        }
    }
    return argc;
  100b39:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100b3c:	c9                   	leave  
  100b3d:	c3                   	ret    

00100b3e <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
  100b3e:	55                   	push   %ebp
  100b3f:	89 e5                	mov    %esp,%ebp
  100b41:	83 ec 68             	sub    $0x68,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
  100b44:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100b47:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b4b:	8b 45 08             	mov    0x8(%ebp),%eax
  100b4e:	89 04 24             	mov    %eax,(%esp)
  100b51:	e8 2e ff ff ff       	call   100a84 <parse>
  100b56:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
  100b59:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100b5d:	75 0a                	jne    100b69 <runcmd+0x2b>
        return 0;
  100b5f:	b8 00 00 00 00       	mov    $0x0,%eax
  100b64:	e9 85 00 00 00       	jmp    100bee <runcmd+0xb0>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100b69:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100b70:	eb 5c                	jmp    100bce <runcmd+0x90>
        if (strcmp(commands[i].name, argv[0]) == 0) {
  100b72:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  100b75:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100b78:	89 d0                	mov    %edx,%eax
  100b7a:	01 c0                	add    %eax,%eax
  100b7c:	01 d0                	add    %edx,%eax
  100b7e:	c1 e0 02             	shl    $0x2,%eax
  100b81:	05 20 70 11 00       	add    $0x117020,%eax
  100b86:	8b 00                	mov    (%eax),%eax
  100b88:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  100b8c:	89 04 24             	mov    %eax,(%esp)
  100b8f:	e8 5a 50 00 00       	call   105bee <strcmp>
  100b94:	85 c0                	test   %eax,%eax
  100b96:	75 32                	jne    100bca <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
  100b98:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100b9b:	89 d0                	mov    %edx,%eax
  100b9d:	01 c0                	add    %eax,%eax
  100b9f:	01 d0                	add    %edx,%eax
  100ba1:	c1 e0 02             	shl    $0x2,%eax
  100ba4:	05 20 70 11 00       	add    $0x117020,%eax
  100ba9:	8b 40 08             	mov    0x8(%eax),%eax
  100bac:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100baf:	8d 4a ff             	lea    -0x1(%edx),%ecx
  100bb2:	8b 55 0c             	mov    0xc(%ebp),%edx
  100bb5:	89 54 24 08          	mov    %edx,0x8(%esp)
  100bb9:	8d 55 b0             	lea    -0x50(%ebp),%edx
  100bbc:	83 c2 04             	add    $0x4,%edx
  100bbf:	89 54 24 04          	mov    %edx,0x4(%esp)
  100bc3:	89 0c 24             	mov    %ecx,(%esp)
  100bc6:	ff d0                	call   *%eax
  100bc8:	eb 24                	jmp    100bee <runcmd+0xb0>
    int argc = parse(buf, argv);
    if (argc == 0) {
        return 0;
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100bca:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  100bce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100bd1:	83 f8 02             	cmp    $0x2,%eax
  100bd4:	76 9c                	jbe    100b72 <runcmd+0x34>
        if (strcmp(commands[i].name, argv[0]) == 0) {
            return commands[i].func(argc - 1, argv + 1, tf);
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
  100bd6:	8b 45 b0             	mov    -0x50(%ebp),%eax
  100bd9:	89 44 24 04          	mov    %eax,0x4(%esp)
  100bdd:	c7 04 24 33 62 10 00 	movl   $0x106233,(%esp)
  100be4:	e8 5e f7 ff ff       	call   100347 <cprintf>
    return 0;
  100be9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100bee:	c9                   	leave  
  100bef:	c3                   	ret    

00100bf0 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
  100bf0:	55                   	push   %ebp
  100bf1:	89 e5                	mov    %esp,%ebp
  100bf3:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
  100bf6:	c7 04 24 4c 62 10 00 	movl   $0x10624c,(%esp)
  100bfd:	e8 45 f7 ff ff       	call   100347 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
  100c02:	c7 04 24 74 62 10 00 	movl   $0x106274,(%esp)
  100c09:	e8 39 f7 ff ff       	call   100347 <cprintf>

    if (tf != NULL) {
  100c0e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100c12:	74 0b                	je     100c1f <kmonitor+0x2f>
        print_trapframe(tf);
  100c14:	8b 45 08             	mov    0x8(%ebp),%eax
  100c17:	89 04 24             	mov    %eax,(%esp)
  100c1a:	e8 30 0e 00 00       	call   101a4f <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
  100c1f:	c7 04 24 99 62 10 00 	movl   $0x106299,(%esp)
  100c26:	e8 13 f6 ff ff       	call   10023e <readline>
  100c2b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100c2e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100c32:	74 18                	je     100c4c <kmonitor+0x5c>
            if (runcmd(buf, tf) < 0) {
  100c34:	8b 45 08             	mov    0x8(%ebp),%eax
  100c37:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100c3e:	89 04 24             	mov    %eax,(%esp)
  100c41:	e8 f8 fe ff ff       	call   100b3e <runcmd>
  100c46:	85 c0                	test   %eax,%eax
  100c48:	79 02                	jns    100c4c <kmonitor+0x5c>
                break;
  100c4a:	eb 02                	jmp    100c4e <kmonitor+0x5e>
            }
        }
    }
  100c4c:	eb d1                	jmp    100c1f <kmonitor+0x2f>
}
  100c4e:	c9                   	leave  
  100c4f:	c3                   	ret    

00100c50 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
  100c50:	55                   	push   %ebp
  100c51:	89 e5                	mov    %esp,%ebp
  100c53:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100c56:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100c5d:	eb 3f                	jmp    100c9e <mon_help+0x4e>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
  100c5f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c62:	89 d0                	mov    %edx,%eax
  100c64:	01 c0                	add    %eax,%eax
  100c66:	01 d0                	add    %edx,%eax
  100c68:	c1 e0 02             	shl    $0x2,%eax
  100c6b:	05 20 70 11 00       	add    $0x117020,%eax
  100c70:	8b 48 04             	mov    0x4(%eax),%ecx
  100c73:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c76:	89 d0                	mov    %edx,%eax
  100c78:	01 c0                	add    %eax,%eax
  100c7a:	01 d0                	add    %edx,%eax
  100c7c:	c1 e0 02             	shl    $0x2,%eax
  100c7f:	05 20 70 11 00       	add    $0x117020,%eax
  100c84:	8b 00                	mov    (%eax),%eax
  100c86:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  100c8a:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c8e:	c7 04 24 9d 62 10 00 	movl   $0x10629d,(%esp)
  100c95:	e8 ad f6 ff ff       	call   100347 <cprintf>

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100c9a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  100c9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100ca1:	83 f8 02             	cmp    $0x2,%eax
  100ca4:	76 b9                	jbe    100c5f <mon_help+0xf>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
    }
    return 0;
  100ca6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100cab:	c9                   	leave  
  100cac:	c3                   	ret    

00100cad <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
  100cad:	55                   	push   %ebp
  100cae:	89 e5                	mov    %esp,%ebp
  100cb0:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
  100cb3:	e8 c3 fb ff ff       	call   10087b <print_kerninfo>
    return 0;
  100cb8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100cbd:	c9                   	leave  
  100cbe:	c3                   	ret    

00100cbf <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
  100cbf:	55                   	push   %ebp
  100cc0:	89 e5                	mov    %esp,%ebp
  100cc2:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
  100cc5:	e8 fb fc ff ff       	call   1009c5 <print_stackframe>
    return 0;
  100cca:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100ccf:	c9                   	leave  
  100cd0:	c3                   	ret    

00100cd1 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
  100cd1:	55                   	push   %ebp
  100cd2:	89 e5                	mov    %esp,%ebp
  100cd4:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
  100cd7:	a1 60 7e 11 00       	mov    0x117e60,%eax
  100cdc:	85 c0                	test   %eax,%eax
  100cde:	74 02                	je     100ce2 <__panic+0x11>
        goto panic_dead;
  100ce0:	eb 48                	jmp    100d2a <__panic+0x59>
    }
    is_panic = 1;
  100ce2:	c7 05 60 7e 11 00 01 	movl   $0x1,0x117e60
  100ce9:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
  100cec:	8d 45 14             	lea    0x14(%ebp),%eax
  100cef:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
  100cf2:	8b 45 0c             	mov    0xc(%ebp),%eax
  100cf5:	89 44 24 08          	mov    %eax,0x8(%esp)
  100cf9:	8b 45 08             	mov    0x8(%ebp),%eax
  100cfc:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d00:	c7 04 24 a6 62 10 00 	movl   $0x1062a6,(%esp)
  100d07:	e8 3b f6 ff ff       	call   100347 <cprintf>
    vcprintf(fmt, ap);
  100d0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100d0f:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d13:	8b 45 10             	mov    0x10(%ebp),%eax
  100d16:	89 04 24             	mov    %eax,(%esp)
  100d19:	e8 f6 f5 ff ff       	call   100314 <vcprintf>
    cprintf("\n");
  100d1e:	c7 04 24 c2 62 10 00 	movl   $0x1062c2,(%esp)
  100d25:	e8 1d f6 ff ff       	call   100347 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
  100d2a:	e8 85 09 00 00       	call   1016b4 <intr_disable>
    while (1) {
        kmonitor(NULL);
  100d2f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100d36:	e8 b5 fe ff ff       	call   100bf0 <kmonitor>
    }
  100d3b:	eb f2                	jmp    100d2f <__panic+0x5e>

00100d3d <__warn>:
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
  100d3d:	55                   	push   %ebp
  100d3e:	89 e5                	mov    %esp,%ebp
  100d40:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
  100d43:	8d 45 14             	lea    0x14(%ebp),%eax
  100d46:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
  100d49:	8b 45 0c             	mov    0xc(%ebp),%eax
  100d4c:	89 44 24 08          	mov    %eax,0x8(%esp)
  100d50:	8b 45 08             	mov    0x8(%ebp),%eax
  100d53:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d57:	c7 04 24 c4 62 10 00 	movl   $0x1062c4,(%esp)
  100d5e:	e8 e4 f5 ff ff       	call   100347 <cprintf>
    vcprintf(fmt, ap);
  100d63:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100d66:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d6a:	8b 45 10             	mov    0x10(%ebp),%eax
  100d6d:	89 04 24             	mov    %eax,(%esp)
  100d70:	e8 9f f5 ff ff       	call   100314 <vcprintf>
    cprintf("\n");
  100d75:	c7 04 24 c2 62 10 00 	movl   $0x1062c2,(%esp)
  100d7c:	e8 c6 f5 ff ff       	call   100347 <cprintf>
    va_end(ap);
}
  100d81:	c9                   	leave  
  100d82:	c3                   	ret    

00100d83 <is_kernel_panic>:

bool
is_kernel_panic(void) {
  100d83:	55                   	push   %ebp
  100d84:	89 e5                	mov    %esp,%ebp
    return is_panic;
  100d86:	a1 60 7e 11 00       	mov    0x117e60,%eax
}
  100d8b:	5d                   	pop    %ebp
  100d8c:	c3                   	ret    

00100d8d <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
  100d8d:	55                   	push   %ebp
  100d8e:	89 e5                	mov    %esp,%ebp
  100d90:	83 ec 28             	sub    $0x28,%esp
  100d93:	66 c7 45 f6 43 00    	movw   $0x43,-0xa(%ebp)
  100d99:	c6 45 f5 34          	movb   $0x34,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100d9d:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  100da1:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100da5:	ee                   	out    %al,(%dx)
  100da6:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
  100dac:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
  100db0:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100db4:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100db8:	ee                   	out    %al,(%dx)
  100db9:	66 c7 45 ee 40 00    	movw   $0x40,-0x12(%ebp)
  100dbf:	c6 45 ed 2e          	movb   $0x2e,-0x13(%ebp)
  100dc3:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100dc7:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100dcb:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
  100dcc:	c7 05 4c 89 11 00 00 	movl   $0x0,0x11894c
  100dd3:	00 00 00 

    cprintf("++ setup timer interrupts\n");
  100dd6:	c7 04 24 e2 62 10 00 	movl   $0x1062e2,(%esp)
  100ddd:	e8 65 f5 ff ff       	call   100347 <cprintf>
    pic_enable(IRQ_TIMER);
  100de2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100de9:	e8 24 09 00 00       	call   101712 <pic_enable>
}
  100dee:	c9                   	leave  
  100def:	c3                   	ret    

00100df0 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
  100df0:	55                   	push   %ebp
  100df1:	89 e5                	mov    %esp,%ebp
  100df3:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
  100df6:	9c                   	pushf  
  100df7:	58                   	pop    %eax
  100df8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
  100dfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
  100dfe:	25 00 02 00 00       	and    $0x200,%eax
  100e03:	85 c0                	test   %eax,%eax
  100e05:	74 0c                	je     100e13 <__intr_save+0x23>
        intr_disable();
  100e07:	e8 a8 08 00 00       	call   1016b4 <intr_disable>
        return 1;
  100e0c:	b8 01 00 00 00       	mov    $0x1,%eax
  100e11:	eb 05                	jmp    100e18 <__intr_save+0x28>
    }
    return 0;
  100e13:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100e18:	c9                   	leave  
  100e19:	c3                   	ret    

00100e1a <__intr_restore>:

static inline void
__intr_restore(bool flag) {
  100e1a:	55                   	push   %ebp
  100e1b:	89 e5                	mov    %esp,%ebp
  100e1d:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
  100e20:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100e24:	74 05                	je     100e2b <__intr_restore+0x11>
        intr_enable();
  100e26:	e8 83 08 00 00       	call   1016ae <intr_enable>
    }
}
  100e2b:	c9                   	leave  
  100e2c:	c3                   	ret    

00100e2d <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
  100e2d:	55                   	push   %ebp
  100e2e:	89 e5                	mov    %esp,%ebp
  100e30:	83 ec 10             	sub    $0x10,%esp
  100e33:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100e39:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  100e3d:	89 c2                	mov    %eax,%edx
  100e3f:	ec                   	in     (%dx),%al
  100e40:	88 45 fd             	mov    %al,-0x3(%ebp)
  100e43:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
  100e49:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  100e4d:	89 c2                	mov    %eax,%edx
  100e4f:	ec                   	in     (%dx),%al
  100e50:	88 45 f9             	mov    %al,-0x7(%ebp)
  100e53:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
  100e59:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100e5d:	89 c2                	mov    %eax,%edx
  100e5f:	ec                   	in     (%dx),%al
  100e60:	88 45 f5             	mov    %al,-0xb(%ebp)
  100e63:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
  100e69:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100e6d:	89 c2                	mov    %eax,%edx
  100e6f:	ec                   	in     (%dx),%al
  100e70:	88 45 f1             	mov    %al,-0xf(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
  100e73:	c9                   	leave  
  100e74:	c3                   	ret    

00100e75 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
  100e75:	55                   	push   %ebp
  100e76:	89 e5                	mov    %esp,%ebp
  100e78:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
  100e7b:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
  100e82:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e85:	0f b7 00             	movzwl (%eax),%eax
  100e88:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
  100e8c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e8f:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
  100e94:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e97:	0f b7 00             	movzwl (%eax),%eax
  100e9a:	66 3d 5a a5          	cmp    $0xa55a,%ax
  100e9e:	74 12                	je     100eb2 <cga_init+0x3d>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
  100ea0:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
  100ea7:	66 c7 05 86 7e 11 00 	movw   $0x3b4,0x117e86
  100eae:	b4 03 
  100eb0:	eb 13                	jmp    100ec5 <cga_init+0x50>
    } else {
        *cp = was;
  100eb2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100eb5:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  100eb9:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
  100ebc:	66 c7 05 86 7e 11 00 	movw   $0x3d4,0x117e86
  100ec3:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
  100ec5:	0f b7 05 86 7e 11 00 	movzwl 0x117e86,%eax
  100ecc:	0f b7 c0             	movzwl %ax,%eax
  100ecf:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
  100ed3:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100ed7:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100edb:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100edf:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
  100ee0:	0f b7 05 86 7e 11 00 	movzwl 0x117e86,%eax
  100ee7:	83 c0 01             	add    $0x1,%eax
  100eea:	0f b7 c0             	movzwl %ax,%eax
  100eed:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100ef1:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
  100ef5:	89 c2                	mov    %eax,%edx
  100ef7:	ec                   	in     (%dx),%al
  100ef8:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
  100efb:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100eff:	0f b6 c0             	movzbl %al,%eax
  100f02:	c1 e0 08             	shl    $0x8,%eax
  100f05:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
  100f08:	0f b7 05 86 7e 11 00 	movzwl 0x117e86,%eax
  100f0f:	0f b7 c0             	movzwl %ax,%eax
  100f12:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
  100f16:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100f1a:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  100f1e:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  100f22:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
  100f23:	0f b7 05 86 7e 11 00 	movzwl 0x117e86,%eax
  100f2a:	83 c0 01             	add    $0x1,%eax
  100f2d:	0f b7 c0             	movzwl %ax,%eax
  100f30:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100f34:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
  100f38:	89 c2                	mov    %eax,%edx
  100f3a:	ec                   	in     (%dx),%al
  100f3b:	88 45 e5             	mov    %al,-0x1b(%ebp)
    return data;
  100f3e:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  100f42:	0f b6 c0             	movzbl %al,%eax
  100f45:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
  100f48:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100f4b:	a3 80 7e 11 00       	mov    %eax,0x117e80
    crt_pos = pos;
  100f50:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100f53:	66 a3 84 7e 11 00    	mov    %ax,0x117e84
}
  100f59:	c9                   	leave  
  100f5a:	c3                   	ret    

00100f5b <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
  100f5b:	55                   	push   %ebp
  100f5c:	89 e5                	mov    %esp,%ebp
  100f5e:	83 ec 48             	sub    $0x48,%esp
  100f61:	66 c7 45 f6 fa 03    	movw   $0x3fa,-0xa(%ebp)
  100f67:	c6 45 f5 00          	movb   $0x0,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100f6b:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  100f6f:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100f73:	ee                   	out    %al,(%dx)
  100f74:	66 c7 45 f2 fb 03    	movw   $0x3fb,-0xe(%ebp)
  100f7a:	c6 45 f1 80          	movb   $0x80,-0xf(%ebp)
  100f7e:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100f82:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100f86:	ee                   	out    %al,(%dx)
  100f87:	66 c7 45 ee f8 03    	movw   $0x3f8,-0x12(%ebp)
  100f8d:	c6 45 ed 0c          	movb   $0xc,-0x13(%ebp)
  100f91:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100f95:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100f99:	ee                   	out    %al,(%dx)
  100f9a:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
  100fa0:	c6 45 e9 00          	movb   $0x0,-0x17(%ebp)
  100fa4:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  100fa8:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  100fac:	ee                   	out    %al,(%dx)
  100fad:	66 c7 45 e6 fb 03    	movw   $0x3fb,-0x1a(%ebp)
  100fb3:	c6 45 e5 03          	movb   $0x3,-0x1b(%ebp)
  100fb7:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  100fbb:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  100fbf:	ee                   	out    %al,(%dx)
  100fc0:	66 c7 45 e2 fc 03    	movw   $0x3fc,-0x1e(%ebp)
  100fc6:	c6 45 e1 00          	movb   $0x0,-0x1f(%ebp)
  100fca:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  100fce:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  100fd2:	ee                   	out    %al,(%dx)
  100fd3:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
  100fd9:	c6 45 dd 01          	movb   $0x1,-0x23(%ebp)
  100fdd:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  100fe1:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  100fe5:	ee                   	out    %al,(%dx)
  100fe6:	66 c7 45 da fd 03    	movw   $0x3fd,-0x26(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100fec:	0f b7 45 da          	movzwl -0x26(%ebp),%eax
  100ff0:	89 c2                	mov    %eax,%edx
  100ff2:	ec                   	in     (%dx),%al
  100ff3:	88 45 d9             	mov    %al,-0x27(%ebp)
    return data;
  100ff6:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
  100ffa:	3c ff                	cmp    $0xff,%al
  100ffc:	0f 95 c0             	setne  %al
  100fff:	0f b6 c0             	movzbl %al,%eax
  101002:	a3 88 7e 11 00       	mov    %eax,0x117e88
  101007:	66 c7 45 d6 fa 03    	movw   $0x3fa,-0x2a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  10100d:	0f b7 45 d6          	movzwl -0x2a(%ebp),%eax
  101011:	89 c2                	mov    %eax,%edx
  101013:	ec                   	in     (%dx),%al
  101014:	88 45 d5             	mov    %al,-0x2b(%ebp)
  101017:	66 c7 45 d2 f8 03    	movw   $0x3f8,-0x2e(%ebp)
  10101d:	0f b7 45 d2          	movzwl -0x2e(%ebp),%eax
  101021:	89 c2                	mov    %eax,%edx
  101023:	ec                   	in     (%dx),%al
  101024:	88 45 d1             	mov    %al,-0x2f(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
  101027:	a1 88 7e 11 00       	mov    0x117e88,%eax
  10102c:	85 c0                	test   %eax,%eax
  10102e:	74 0c                	je     10103c <serial_init+0xe1>
        pic_enable(IRQ_COM1);
  101030:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  101037:	e8 d6 06 00 00       	call   101712 <pic_enable>
    }
}
  10103c:	c9                   	leave  
  10103d:	c3                   	ret    

0010103e <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
  10103e:	55                   	push   %ebp
  10103f:	89 e5                	mov    %esp,%ebp
  101041:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  101044:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  10104b:	eb 09                	jmp    101056 <lpt_putc_sub+0x18>
        delay();
  10104d:	e8 db fd ff ff       	call   100e2d <delay>
}

static void
lpt_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  101052:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  101056:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
  10105c:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  101060:	89 c2                	mov    %eax,%edx
  101062:	ec                   	in     (%dx),%al
  101063:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  101066:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  10106a:	84 c0                	test   %al,%al
  10106c:	78 09                	js     101077 <lpt_putc_sub+0x39>
  10106e:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  101075:	7e d6                	jle    10104d <lpt_putc_sub+0xf>
        delay();
    }
    outb(LPTPORT + 0, c);
  101077:	8b 45 08             	mov    0x8(%ebp),%eax
  10107a:	0f b6 c0             	movzbl %al,%eax
  10107d:	66 c7 45 f6 78 03    	movw   $0x378,-0xa(%ebp)
  101083:	88 45 f5             	mov    %al,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101086:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  10108a:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  10108e:	ee                   	out    %al,(%dx)
  10108f:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
  101095:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
  101099:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  10109d:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  1010a1:	ee                   	out    %al,(%dx)
  1010a2:	66 c7 45 ee 7a 03    	movw   $0x37a,-0x12(%ebp)
  1010a8:	c6 45 ed 08          	movb   $0x8,-0x13(%ebp)
  1010ac:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  1010b0:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  1010b4:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
  1010b5:	c9                   	leave  
  1010b6:	c3                   	ret    

001010b7 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
  1010b7:	55                   	push   %ebp
  1010b8:	89 e5                	mov    %esp,%ebp
  1010ba:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  1010bd:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  1010c1:	74 0d                	je     1010d0 <lpt_putc+0x19>
        lpt_putc_sub(c);
  1010c3:	8b 45 08             	mov    0x8(%ebp),%eax
  1010c6:	89 04 24             	mov    %eax,(%esp)
  1010c9:	e8 70 ff ff ff       	call   10103e <lpt_putc_sub>
  1010ce:	eb 24                	jmp    1010f4 <lpt_putc+0x3d>
    }
    else {
        lpt_putc_sub('\b');
  1010d0:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  1010d7:	e8 62 ff ff ff       	call   10103e <lpt_putc_sub>
        lpt_putc_sub(' ');
  1010dc:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  1010e3:	e8 56 ff ff ff       	call   10103e <lpt_putc_sub>
        lpt_putc_sub('\b');
  1010e8:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  1010ef:	e8 4a ff ff ff       	call   10103e <lpt_putc_sub>
    }
}
  1010f4:	c9                   	leave  
  1010f5:	c3                   	ret    

001010f6 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
  1010f6:	55                   	push   %ebp
  1010f7:	89 e5                	mov    %esp,%ebp
  1010f9:	53                   	push   %ebx
  1010fa:	83 ec 34             	sub    $0x34,%esp
    // set black on white
    if (!(c & ~0xFF)) {
  1010fd:	8b 45 08             	mov    0x8(%ebp),%eax
  101100:	b0 00                	mov    $0x0,%al
  101102:	85 c0                	test   %eax,%eax
  101104:	75 07                	jne    10110d <cga_putc+0x17>
        c |= 0x0700;
  101106:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
  10110d:	8b 45 08             	mov    0x8(%ebp),%eax
  101110:	0f b6 c0             	movzbl %al,%eax
  101113:	83 f8 0a             	cmp    $0xa,%eax
  101116:	74 4c                	je     101164 <cga_putc+0x6e>
  101118:	83 f8 0d             	cmp    $0xd,%eax
  10111b:	74 57                	je     101174 <cga_putc+0x7e>
  10111d:	83 f8 08             	cmp    $0x8,%eax
  101120:	0f 85 88 00 00 00    	jne    1011ae <cga_putc+0xb8>
    case '\b':
        if (crt_pos > 0) {
  101126:	0f b7 05 84 7e 11 00 	movzwl 0x117e84,%eax
  10112d:	66 85 c0             	test   %ax,%ax
  101130:	74 30                	je     101162 <cga_putc+0x6c>
            crt_pos --;
  101132:	0f b7 05 84 7e 11 00 	movzwl 0x117e84,%eax
  101139:	83 e8 01             	sub    $0x1,%eax
  10113c:	66 a3 84 7e 11 00    	mov    %ax,0x117e84
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
  101142:	a1 80 7e 11 00       	mov    0x117e80,%eax
  101147:	0f b7 15 84 7e 11 00 	movzwl 0x117e84,%edx
  10114e:	0f b7 d2             	movzwl %dx,%edx
  101151:	01 d2                	add    %edx,%edx
  101153:	01 c2                	add    %eax,%edx
  101155:	8b 45 08             	mov    0x8(%ebp),%eax
  101158:	b0 00                	mov    $0x0,%al
  10115a:	83 c8 20             	or     $0x20,%eax
  10115d:	66 89 02             	mov    %ax,(%edx)
        }
        break;
  101160:	eb 72                	jmp    1011d4 <cga_putc+0xde>
  101162:	eb 70                	jmp    1011d4 <cga_putc+0xde>
    case '\n':
        crt_pos += CRT_COLS;
  101164:	0f b7 05 84 7e 11 00 	movzwl 0x117e84,%eax
  10116b:	83 c0 50             	add    $0x50,%eax
  10116e:	66 a3 84 7e 11 00    	mov    %ax,0x117e84
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
  101174:	0f b7 1d 84 7e 11 00 	movzwl 0x117e84,%ebx
  10117b:	0f b7 0d 84 7e 11 00 	movzwl 0x117e84,%ecx
  101182:	0f b7 c1             	movzwl %cx,%eax
  101185:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
  10118b:	c1 e8 10             	shr    $0x10,%eax
  10118e:	89 c2                	mov    %eax,%edx
  101190:	66 c1 ea 06          	shr    $0x6,%dx
  101194:	89 d0                	mov    %edx,%eax
  101196:	c1 e0 02             	shl    $0x2,%eax
  101199:	01 d0                	add    %edx,%eax
  10119b:	c1 e0 04             	shl    $0x4,%eax
  10119e:	29 c1                	sub    %eax,%ecx
  1011a0:	89 ca                	mov    %ecx,%edx
  1011a2:	89 d8                	mov    %ebx,%eax
  1011a4:	29 d0                	sub    %edx,%eax
  1011a6:	66 a3 84 7e 11 00    	mov    %ax,0x117e84
        break;
  1011ac:	eb 26                	jmp    1011d4 <cga_putc+0xde>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
  1011ae:	8b 0d 80 7e 11 00    	mov    0x117e80,%ecx
  1011b4:	0f b7 05 84 7e 11 00 	movzwl 0x117e84,%eax
  1011bb:	8d 50 01             	lea    0x1(%eax),%edx
  1011be:	66 89 15 84 7e 11 00 	mov    %dx,0x117e84
  1011c5:	0f b7 c0             	movzwl %ax,%eax
  1011c8:	01 c0                	add    %eax,%eax
  1011ca:	8d 14 01             	lea    (%ecx,%eax,1),%edx
  1011cd:	8b 45 08             	mov    0x8(%ebp),%eax
  1011d0:	66 89 02             	mov    %ax,(%edx)
        break;
  1011d3:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
  1011d4:	0f b7 05 84 7e 11 00 	movzwl 0x117e84,%eax
  1011db:	66 3d cf 07          	cmp    $0x7cf,%ax
  1011df:	76 5b                	jbe    10123c <cga_putc+0x146>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
  1011e1:	a1 80 7e 11 00       	mov    0x117e80,%eax
  1011e6:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
  1011ec:	a1 80 7e 11 00       	mov    0x117e80,%eax
  1011f1:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
  1011f8:	00 
  1011f9:	89 54 24 04          	mov    %edx,0x4(%esp)
  1011fd:	89 04 24             	mov    %eax,(%esp)
  101200:	e8 86 4c 00 00       	call   105e8b <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  101205:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
  10120c:	eb 15                	jmp    101223 <cga_putc+0x12d>
            crt_buf[i] = 0x0700 | ' ';
  10120e:	a1 80 7e 11 00       	mov    0x117e80,%eax
  101213:	8b 55 f4             	mov    -0xc(%ebp),%edx
  101216:	01 d2                	add    %edx,%edx
  101218:	01 d0                	add    %edx,%eax
  10121a:	66 c7 00 20 07       	movw   $0x720,(%eax)

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  10121f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  101223:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
  10122a:	7e e2                	jle    10120e <cga_putc+0x118>
            crt_buf[i] = 0x0700 | ' ';
        }
        crt_pos -= CRT_COLS;
  10122c:	0f b7 05 84 7e 11 00 	movzwl 0x117e84,%eax
  101233:	83 e8 50             	sub    $0x50,%eax
  101236:	66 a3 84 7e 11 00    	mov    %ax,0x117e84
    }

    // move that little blinky thing
    outb(addr_6845, 14);
  10123c:	0f b7 05 86 7e 11 00 	movzwl 0x117e86,%eax
  101243:	0f b7 c0             	movzwl %ax,%eax
  101246:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
  10124a:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
  10124e:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  101252:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  101256:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
  101257:	0f b7 05 84 7e 11 00 	movzwl 0x117e84,%eax
  10125e:	66 c1 e8 08          	shr    $0x8,%ax
  101262:	0f b6 c0             	movzbl %al,%eax
  101265:	0f b7 15 86 7e 11 00 	movzwl 0x117e86,%edx
  10126c:	83 c2 01             	add    $0x1,%edx
  10126f:	0f b7 d2             	movzwl %dx,%edx
  101272:	66 89 55 ee          	mov    %dx,-0x12(%ebp)
  101276:	88 45 ed             	mov    %al,-0x13(%ebp)
  101279:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  10127d:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  101281:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
  101282:	0f b7 05 86 7e 11 00 	movzwl 0x117e86,%eax
  101289:	0f b7 c0             	movzwl %ax,%eax
  10128c:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
  101290:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
  101294:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  101298:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  10129c:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
  10129d:	0f b7 05 84 7e 11 00 	movzwl 0x117e84,%eax
  1012a4:	0f b6 c0             	movzbl %al,%eax
  1012a7:	0f b7 15 86 7e 11 00 	movzwl 0x117e86,%edx
  1012ae:	83 c2 01             	add    $0x1,%edx
  1012b1:	0f b7 d2             	movzwl %dx,%edx
  1012b4:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
  1012b8:	88 45 e5             	mov    %al,-0x1b(%ebp)
  1012bb:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  1012bf:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  1012c3:	ee                   	out    %al,(%dx)
}
  1012c4:	83 c4 34             	add    $0x34,%esp
  1012c7:	5b                   	pop    %ebx
  1012c8:	5d                   	pop    %ebp
  1012c9:	c3                   	ret    

001012ca <serial_putc_sub>:

static void
serial_putc_sub(int c) {
  1012ca:	55                   	push   %ebp
  1012cb:	89 e5                	mov    %esp,%ebp
  1012cd:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  1012d0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  1012d7:	eb 09                	jmp    1012e2 <serial_putc_sub+0x18>
        delay();
  1012d9:	e8 4f fb ff ff       	call   100e2d <delay>
}

static void
serial_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  1012de:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  1012e2:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  1012e8:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  1012ec:	89 c2                	mov    %eax,%edx
  1012ee:	ec                   	in     (%dx),%al
  1012ef:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  1012f2:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  1012f6:	0f b6 c0             	movzbl %al,%eax
  1012f9:	83 e0 20             	and    $0x20,%eax
  1012fc:	85 c0                	test   %eax,%eax
  1012fe:	75 09                	jne    101309 <serial_putc_sub+0x3f>
  101300:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  101307:	7e d0                	jle    1012d9 <serial_putc_sub+0xf>
        delay();
    }
    outb(COM1 + COM_TX, c);
  101309:	8b 45 08             	mov    0x8(%ebp),%eax
  10130c:	0f b6 c0             	movzbl %al,%eax
  10130f:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
  101315:	88 45 f5             	mov    %al,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101318:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  10131c:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  101320:	ee                   	out    %al,(%dx)
}
  101321:	c9                   	leave  
  101322:	c3                   	ret    

00101323 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
  101323:	55                   	push   %ebp
  101324:	89 e5                	mov    %esp,%ebp
  101326:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  101329:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  10132d:	74 0d                	je     10133c <serial_putc+0x19>
        serial_putc_sub(c);
  10132f:	8b 45 08             	mov    0x8(%ebp),%eax
  101332:	89 04 24             	mov    %eax,(%esp)
  101335:	e8 90 ff ff ff       	call   1012ca <serial_putc_sub>
  10133a:	eb 24                	jmp    101360 <serial_putc+0x3d>
    }
    else {
        serial_putc_sub('\b');
  10133c:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  101343:	e8 82 ff ff ff       	call   1012ca <serial_putc_sub>
        serial_putc_sub(' ');
  101348:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  10134f:	e8 76 ff ff ff       	call   1012ca <serial_putc_sub>
        serial_putc_sub('\b');
  101354:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  10135b:	e8 6a ff ff ff       	call   1012ca <serial_putc_sub>
    }
}
  101360:	c9                   	leave  
  101361:	c3                   	ret    

00101362 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
  101362:	55                   	push   %ebp
  101363:	89 e5                	mov    %esp,%ebp
  101365:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
  101368:	eb 33                	jmp    10139d <cons_intr+0x3b>
        if (c != 0) {
  10136a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10136e:	74 2d                	je     10139d <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
  101370:	a1 a4 80 11 00       	mov    0x1180a4,%eax
  101375:	8d 50 01             	lea    0x1(%eax),%edx
  101378:	89 15 a4 80 11 00    	mov    %edx,0x1180a4
  10137e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  101381:	88 90 a0 7e 11 00    	mov    %dl,0x117ea0(%eax)
            if (cons.wpos == CONSBUFSIZE) {
  101387:	a1 a4 80 11 00       	mov    0x1180a4,%eax
  10138c:	3d 00 02 00 00       	cmp    $0x200,%eax
  101391:	75 0a                	jne    10139d <cons_intr+0x3b>
                cons.wpos = 0;
  101393:	c7 05 a4 80 11 00 00 	movl   $0x0,0x1180a4
  10139a:	00 00 00 
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
    int c;
    while ((c = (*proc)()) != -1) {
  10139d:	8b 45 08             	mov    0x8(%ebp),%eax
  1013a0:	ff d0                	call   *%eax
  1013a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1013a5:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
  1013a9:	75 bf                	jne    10136a <cons_intr+0x8>
            if (cons.wpos == CONSBUFSIZE) {
                cons.wpos = 0;
            }
        }
    }
}
  1013ab:	c9                   	leave  
  1013ac:	c3                   	ret    

001013ad <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
  1013ad:	55                   	push   %ebp
  1013ae:	89 e5                	mov    %esp,%ebp
  1013b0:	83 ec 10             	sub    $0x10,%esp
  1013b3:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  1013b9:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  1013bd:	89 c2                	mov    %eax,%edx
  1013bf:	ec                   	in     (%dx),%al
  1013c0:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  1013c3:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
  1013c7:	0f b6 c0             	movzbl %al,%eax
  1013ca:	83 e0 01             	and    $0x1,%eax
  1013cd:	85 c0                	test   %eax,%eax
  1013cf:	75 07                	jne    1013d8 <serial_proc_data+0x2b>
        return -1;
  1013d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1013d6:	eb 2a                	jmp    101402 <serial_proc_data+0x55>
  1013d8:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  1013de:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  1013e2:	89 c2                	mov    %eax,%edx
  1013e4:	ec                   	in     (%dx),%al
  1013e5:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
  1013e8:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
  1013ec:	0f b6 c0             	movzbl %al,%eax
  1013ef:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
  1013f2:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
  1013f6:	75 07                	jne    1013ff <serial_proc_data+0x52>
        c = '\b';
  1013f8:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
  1013ff:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  101402:	c9                   	leave  
  101403:	c3                   	ret    

00101404 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
  101404:	55                   	push   %ebp
  101405:	89 e5                	mov    %esp,%ebp
  101407:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
  10140a:	a1 88 7e 11 00       	mov    0x117e88,%eax
  10140f:	85 c0                	test   %eax,%eax
  101411:	74 0c                	je     10141f <serial_intr+0x1b>
        cons_intr(serial_proc_data);
  101413:	c7 04 24 ad 13 10 00 	movl   $0x1013ad,(%esp)
  10141a:	e8 43 ff ff ff       	call   101362 <cons_intr>
    }
}
  10141f:	c9                   	leave  
  101420:	c3                   	ret    

00101421 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
  101421:	55                   	push   %ebp
  101422:	89 e5                	mov    %esp,%ebp
  101424:	83 ec 38             	sub    $0x38,%esp
  101427:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  10142d:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  101431:	89 c2                	mov    %eax,%edx
  101433:	ec                   	in     (%dx),%al
  101434:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
  101437:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
  10143b:	0f b6 c0             	movzbl %al,%eax
  10143e:	83 e0 01             	and    $0x1,%eax
  101441:	85 c0                	test   %eax,%eax
  101443:	75 0a                	jne    10144f <kbd_proc_data+0x2e>
        return -1;
  101445:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10144a:	e9 59 01 00 00       	jmp    1015a8 <kbd_proc_data+0x187>
  10144f:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101455:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  101459:	89 c2                	mov    %eax,%edx
  10145b:	ec                   	in     (%dx),%al
  10145c:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
  10145f:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
  101463:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
  101466:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
  10146a:	75 17                	jne    101483 <kbd_proc_data+0x62>
        // E0 escape character
        shift |= E0ESC;
  10146c:	a1 a8 80 11 00       	mov    0x1180a8,%eax
  101471:	83 c8 40             	or     $0x40,%eax
  101474:	a3 a8 80 11 00       	mov    %eax,0x1180a8
        return 0;
  101479:	b8 00 00 00 00       	mov    $0x0,%eax
  10147e:	e9 25 01 00 00       	jmp    1015a8 <kbd_proc_data+0x187>
    } else if (data & 0x80) {
  101483:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101487:	84 c0                	test   %al,%al
  101489:	79 47                	jns    1014d2 <kbd_proc_data+0xb1>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
  10148b:	a1 a8 80 11 00       	mov    0x1180a8,%eax
  101490:	83 e0 40             	and    $0x40,%eax
  101493:	85 c0                	test   %eax,%eax
  101495:	75 09                	jne    1014a0 <kbd_proc_data+0x7f>
  101497:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10149b:	83 e0 7f             	and    $0x7f,%eax
  10149e:	eb 04                	jmp    1014a4 <kbd_proc_data+0x83>
  1014a0:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014a4:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
  1014a7:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014ab:	0f b6 80 60 70 11 00 	movzbl 0x117060(%eax),%eax
  1014b2:	83 c8 40             	or     $0x40,%eax
  1014b5:	0f b6 c0             	movzbl %al,%eax
  1014b8:	f7 d0                	not    %eax
  1014ba:	89 c2                	mov    %eax,%edx
  1014bc:	a1 a8 80 11 00       	mov    0x1180a8,%eax
  1014c1:	21 d0                	and    %edx,%eax
  1014c3:	a3 a8 80 11 00       	mov    %eax,0x1180a8
        return 0;
  1014c8:	b8 00 00 00 00       	mov    $0x0,%eax
  1014cd:	e9 d6 00 00 00       	jmp    1015a8 <kbd_proc_data+0x187>
    } else if (shift & E0ESC) {
  1014d2:	a1 a8 80 11 00       	mov    0x1180a8,%eax
  1014d7:	83 e0 40             	and    $0x40,%eax
  1014da:	85 c0                	test   %eax,%eax
  1014dc:	74 11                	je     1014ef <kbd_proc_data+0xce>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
  1014de:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
  1014e2:	a1 a8 80 11 00       	mov    0x1180a8,%eax
  1014e7:	83 e0 bf             	and    $0xffffffbf,%eax
  1014ea:	a3 a8 80 11 00       	mov    %eax,0x1180a8
    }

    shift |= shiftcode[data];
  1014ef:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014f3:	0f b6 80 60 70 11 00 	movzbl 0x117060(%eax),%eax
  1014fa:	0f b6 d0             	movzbl %al,%edx
  1014fd:	a1 a8 80 11 00       	mov    0x1180a8,%eax
  101502:	09 d0                	or     %edx,%eax
  101504:	a3 a8 80 11 00       	mov    %eax,0x1180a8
    shift ^= togglecode[data];
  101509:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10150d:	0f b6 80 60 71 11 00 	movzbl 0x117160(%eax),%eax
  101514:	0f b6 d0             	movzbl %al,%edx
  101517:	a1 a8 80 11 00       	mov    0x1180a8,%eax
  10151c:	31 d0                	xor    %edx,%eax
  10151e:	a3 a8 80 11 00       	mov    %eax,0x1180a8

    c = charcode[shift & (CTL | SHIFT)][data];
  101523:	a1 a8 80 11 00       	mov    0x1180a8,%eax
  101528:	83 e0 03             	and    $0x3,%eax
  10152b:	8b 14 85 60 75 11 00 	mov    0x117560(,%eax,4),%edx
  101532:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101536:	01 d0                	add    %edx,%eax
  101538:	0f b6 00             	movzbl (%eax),%eax
  10153b:	0f b6 c0             	movzbl %al,%eax
  10153e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
  101541:	a1 a8 80 11 00       	mov    0x1180a8,%eax
  101546:	83 e0 08             	and    $0x8,%eax
  101549:	85 c0                	test   %eax,%eax
  10154b:	74 22                	je     10156f <kbd_proc_data+0x14e>
        if ('a' <= c && c <= 'z')
  10154d:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
  101551:	7e 0c                	jle    10155f <kbd_proc_data+0x13e>
  101553:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
  101557:	7f 06                	jg     10155f <kbd_proc_data+0x13e>
            c += 'A' - 'a';
  101559:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
  10155d:	eb 10                	jmp    10156f <kbd_proc_data+0x14e>
        else if ('A' <= c && c <= 'Z')
  10155f:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
  101563:	7e 0a                	jle    10156f <kbd_proc_data+0x14e>
  101565:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
  101569:	7f 04                	jg     10156f <kbd_proc_data+0x14e>
            c += 'a' - 'A';
  10156b:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  10156f:	a1 a8 80 11 00       	mov    0x1180a8,%eax
  101574:	f7 d0                	not    %eax
  101576:	83 e0 06             	and    $0x6,%eax
  101579:	85 c0                	test   %eax,%eax
  10157b:	75 28                	jne    1015a5 <kbd_proc_data+0x184>
  10157d:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
  101584:	75 1f                	jne    1015a5 <kbd_proc_data+0x184>
        cprintf("Rebooting!\n");
  101586:	c7 04 24 fd 62 10 00 	movl   $0x1062fd,(%esp)
  10158d:	e8 b5 ed ff ff       	call   100347 <cprintf>
  101592:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
  101598:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10159c:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
  1015a0:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
  1015a4:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
  1015a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1015a8:	c9                   	leave  
  1015a9:	c3                   	ret    

001015aa <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
  1015aa:	55                   	push   %ebp
  1015ab:	89 e5                	mov    %esp,%ebp
  1015ad:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
  1015b0:	c7 04 24 21 14 10 00 	movl   $0x101421,(%esp)
  1015b7:	e8 a6 fd ff ff       	call   101362 <cons_intr>
}
  1015bc:	c9                   	leave  
  1015bd:	c3                   	ret    

001015be <kbd_init>:

static void
kbd_init(void) {
  1015be:	55                   	push   %ebp
  1015bf:	89 e5                	mov    %esp,%ebp
  1015c1:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
  1015c4:	e8 e1 ff ff ff       	call   1015aa <kbd_intr>
    pic_enable(IRQ_KBD);
  1015c9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1015d0:	e8 3d 01 00 00       	call   101712 <pic_enable>
}
  1015d5:	c9                   	leave  
  1015d6:	c3                   	ret    

001015d7 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
  1015d7:	55                   	push   %ebp
  1015d8:	89 e5                	mov    %esp,%ebp
  1015da:	83 ec 18             	sub    $0x18,%esp
    cga_init();
  1015dd:	e8 93 f8 ff ff       	call   100e75 <cga_init>
    serial_init();
  1015e2:	e8 74 f9 ff ff       	call   100f5b <serial_init>
    kbd_init();
  1015e7:	e8 d2 ff ff ff       	call   1015be <kbd_init>
    if (!serial_exists) {
  1015ec:	a1 88 7e 11 00       	mov    0x117e88,%eax
  1015f1:	85 c0                	test   %eax,%eax
  1015f3:	75 0c                	jne    101601 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
  1015f5:	c7 04 24 09 63 10 00 	movl   $0x106309,(%esp)
  1015fc:	e8 46 ed ff ff       	call   100347 <cprintf>
    }
}
  101601:	c9                   	leave  
  101602:	c3                   	ret    

00101603 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
  101603:	55                   	push   %ebp
  101604:	89 e5                	mov    %esp,%ebp
  101606:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
  101609:	e8 e2 f7 ff ff       	call   100df0 <__intr_save>
  10160e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
  101611:	8b 45 08             	mov    0x8(%ebp),%eax
  101614:	89 04 24             	mov    %eax,(%esp)
  101617:	e8 9b fa ff ff       	call   1010b7 <lpt_putc>
        cga_putc(c);
  10161c:	8b 45 08             	mov    0x8(%ebp),%eax
  10161f:	89 04 24             	mov    %eax,(%esp)
  101622:	e8 cf fa ff ff       	call   1010f6 <cga_putc>
        serial_putc(c);
  101627:	8b 45 08             	mov    0x8(%ebp),%eax
  10162a:	89 04 24             	mov    %eax,(%esp)
  10162d:	e8 f1 fc ff ff       	call   101323 <serial_putc>
    }
    local_intr_restore(intr_flag);
  101632:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101635:	89 04 24             	mov    %eax,(%esp)
  101638:	e8 dd f7 ff ff       	call   100e1a <__intr_restore>
}
  10163d:	c9                   	leave  
  10163e:	c3                   	ret    

0010163f <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
  10163f:	55                   	push   %ebp
  101640:	89 e5                	mov    %esp,%ebp
  101642:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
  101645:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
  10164c:	e8 9f f7 ff ff       	call   100df0 <__intr_save>
  101651:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
  101654:	e8 ab fd ff ff       	call   101404 <serial_intr>
        kbd_intr();
  101659:	e8 4c ff ff ff       	call   1015aa <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
  10165e:	8b 15 a0 80 11 00    	mov    0x1180a0,%edx
  101664:	a1 a4 80 11 00       	mov    0x1180a4,%eax
  101669:	39 c2                	cmp    %eax,%edx
  10166b:	74 31                	je     10169e <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
  10166d:	a1 a0 80 11 00       	mov    0x1180a0,%eax
  101672:	8d 50 01             	lea    0x1(%eax),%edx
  101675:	89 15 a0 80 11 00    	mov    %edx,0x1180a0
  10167b:	0f b6 80 a0 7e 11 00 	movzbl 0x117ea0(%eax),%eax
  101682:	0f b6 c0             	movzbl %al,%eax
  101685:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
  101688:	a1 a0 80 11 00       	mov    0x1180a0,%eax
  10168d:	3d 00 02 00 00       	cmp    $0x200,%eax
  101692:	75 0a                	jne    10169e <cons_getc+0x5f>
                cons.rpos = 0;
  101694:	c7 05 a0 80 11 00 00 	movl   $0x0,0x1180a0
  10169b:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
  10169e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1016a1:	89 04 24             	mov    %eax,(%esp)
  1016a4:	e8 71 f7 ff ff       	call   100e1a <__intr_restore>
    return c;
  1016a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1016ac:	c9                   	leave  
  1016ad:	c3                   	ret    

001016ae <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
  1016ae:	55                   	push   %ebp
  1016af:	89 e5                	mov    %esp,%ebp
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
}

static inline void
sti(void) {
    asm volatile ("sti");
  1016b1:	fb                   	sti    
    sti();
}
  1016b2:	5d                   	pop    %ebp
  1016b3:	c3                   	ret    

001016b4 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
  1016b4:	55                   	push   %ebp
  1016b5:	89 e5                	mov    %esp,%ebp
}

static inline void
cli(void) {
    asm volatile ("cli" ::: "memory");
  1016b7:	fa                   	cli    
    cli();
}
  1016b8:	5d                   	pop    %ebp
  1016b9:	c3                   	ret    

001016ba <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
  1016ba:	55                   	push   %ebp
  1016bb:	89 e5                	mov    %esp,%ebp
  1016bd:	83 ec 14             	sub    $0x14,%esp
  1016c0:	8b 45 08             	mov    0x8(%ebp),%eax
  1016c3:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
  1016c7:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  1016cb:	66 a3 70 75 11 00    	mov    %ax,0x117570
    if (did_init) {
  1016d1:	a1 ac 80 11 00       	mov    0x1180ac,%eax
  1016d6:	85 c0                	test   %eax,%eax
  1016d8:	74 36                	je     101710 <pic_setmask+0x56>
        outb(IO_PIC1 + 1, mask);
  1016da:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  1016de:	0f b6 c0             	movzbl %al,%eax
  1016e1:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
  1016e7:	88 45 fd             	mov    %al,-0x3(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1016ea:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  1016ee:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  1016f2:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
  1016f3:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  1016f7:	66 c1 e8 08          	shr    $0x8,%ax
  1016fb:	0f b6 c0             	movzbl %al,%eax
  1016fe:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
  101704:	88 45 f9             	mov    %al,-0x7(%ebp)
  101707:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  10170b:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  10170f:	ee                   	out    %al,(%dx)
    }
}
  101710:	c9                   	leave  
  101711:	c3                   	ret    

00101712 <pic_enable>:

void
pic_enable(unsigned int irq) {
  101712:	55                   	push   %ebp
  101713:	89 e5                	mov    %esp,%ebp
  101715:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
  101718:	8b 45 08             	mov    0x8(%ebp),%eax
  10171b:	ba 01 00 00 00       	mov    $0x1,%edx
  101720:	89 c1                	mov    %eax,%ecx
  101722:	d3 e2                	shl    %cl,%edx
  101724:	89 d0                	mov    %edx,%eax
  101726:	f7 d0                	not    %eax
  101728:	89 c2                	mov    %eax,%edx
  10172a:	0f b7 05 70 75 11 00 	movzwl 0x117570,%eax
  101731:	21 d0                	and    %edx,%eax
  101733:	0f b7 c0             	movzwl %ax,%eax
  101736:	89 04 24             	mov    %eax,(%esp)
  101739:	e8 7c ff ff ff       	call   1016ba <pic_setmask>
}
  10173e:	c9                   	leave  
  10173f:	c3                   	ret    

00101740 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
  101740:	55                   	push   %ebp
  101741:	89 e5                	mov    %esp,%ebp
  101743:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
  101746:	c7 05 ac 80 11 00 01 	movl   $0x1,0x1180ac
  10174d:	00 00 00 
  101750:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
  101756:	c6 45 fd ff          	movb   $0xff,-0x3(%ebp)
  10175a:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  10175e:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  101762:	ee                   	out    %al,(%dx)
  101763:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
  101769:	c6 45 f9 ff          	movb   $0xff,-0x7(%ebp)
  10176d:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101771:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  101775:	ee                   	out    %al,(%dx)
  101776:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
  10177c:	c6 45 f5 11          	movb   $0x11,-0xb(%ebp)
  101780:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  101784:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  101788:	ee                   	out    %al,(%dx)
  101789:	66 c7 45 f2 21 00    	movw   $0x21,-0xe(%ebp)
  10178f:	c6 45 f1 20          	movb   $0x20,-0xf(%ebp)
  101793:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  101797:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  10179b:	ee                   	out    %al,(%dx)
  10179c:	66 c7 45 ee 21 00    	movw   $0x21,-0x12(%ebp)
  1017a2:	c6 45 ed 04          	movb   $0x4,-0x13(%ebp)
  1017a6:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  1017aa:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  1017ae:	ee                   	out    %al,(%dx)
  1017af:	66 c7 45 ea 21 00    	movw   $0x21,-0x16(%ebp)
  1017b5:	c6 45 e9 03          	movb   $0x3,-0x17(%ebp)
  1017b9:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  1017bd:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  1017c1:	ee                   	out    %al,(%dx)
  1017c2:	66 c7 45 e6 a0 00    	movw   $0xa0,-0x1a(%ebp)
  1017c8:	c6 45 e5 11          	movb   $0x11,-0x1b(%ebp)
  1017cc:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  1017d0:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  1017d4:	ee                   	out    %al,(%dx)
  1017d5:	66 c7 45 e2 a1 00    	movw   $0xa1,-0x1e(%ebp)
  1017db:	c6 45 e1 28          	movb   $0x28,-0x1f(%ebp)
  1017df:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  1017e3:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  1017e7:	ee                   	out    %al,(%dx)
  1017e8:	66 c7 45 de a1 00    	movw   $0xa1,-0x22(%ebp)
  1017ee:	c6 45 dd 02          	movb   $0x2,-0x23(%ebp)
  1017f2:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  1017f6:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  1017fa:	ee                   	out    %al,(%dx)
  1017fb:	66 c7 45 da a1 00    	movw   $0xa1,-0x26(%ebp)
  101801:	c6 45 d9 03          	movb   $0x3,-0x27(%ebp)
  101805:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
  101809:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
  10180d:	ee                   	out    %al,(%dx)
  10180e:	66 c7 45 d6 20 00    	movw   $0x20,-0x2a(%ebp)
  101814:	c6 45 d5 68          	movb   $0x68,-0x2b(%ebp)
  101818:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
  10181c:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
  101820:	ee                   	out    %al,(%dx)
  101821:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
  101827:	c6 45 d1 0a          	movb   $0xa,-0x2f(%ebp)
  10182b:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
  10182f:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
  101833:	ee                   	out    %al,(%dx)
  101834:	66 c7 45 ce a0 00    	movw   $0xa0,-0x32(%ebp)
  10183a:	c6 45 cd 68          	movb   $0x68,-0x33(%ebp)
  10183e:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
  101842:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
  101846:	ee                   	out    %al,(%dx)
  101847:	66 c7 45 ca a0 00    	movw   $0xa0,-0x36(%ebp)
  10184d:	c6 45 c9 0a          	movb   $0xa,-0x37(%ebp)
  101851:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
  101855:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
  101859:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
  10185a:	0f b7 05 70 75 11 00 	movzwl 0x117570,%eax
  101861:	66 83 f8 ff          	cmp    $0xffff,%ax
  101865:	74 12                	je     101879 <pic_init+0x139>
        pic_setmask(irq_mask);
  101867:	0f b7 05 70 75 11 00 	movzwl 0x117570,%eax
  10186e:	0f b7 c0             	movzwl %ax,%eax
  101871:	89 04 24             	mov    %eax,(%esp)
  101874:	e8 41 fe ff ff       	call   1016ba <pic_setmask>
    }
}
  101879:	c9                   	leave  
  10187a:	c3                   	ret    

0010187b <print_ticks>:
#include <console.h>
#include <kdebug.h>
#include <string.h>
#define TICK_NUM 100

static void print_ticks() {
  10187b:	55                   	push   %ebp
  10187c:	89 e5                	mov    %esp,%ebp
  10187e:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
  101881:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  101888:	00 
  101889:	c7 04 24 40 63 10 00 	movl   $0x106340,(%esp)
  101890:	e8 b2 ea ff ff       	call   100347 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}
  101895:	c9                   	leave  
  101896:	c3                   	ret    

00101897 <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
  101897:	55                   	push   %ebp
  101898:	89 e5                	mov    %esp,%ebp
  10189a:	83 ec 10             	sub    $0x10,%esp
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
  10189d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  1018a4:	e9 c3 00 00 00       	jmp    10196c <idt_init+0xd5>
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
  1018a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018ac:	8b 04 85 00 76 11 00 	mov    0x117600(,%eax,4),%eax
  1018b3:	89 c2                	mov    %eax,%edx
  1018b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018b8:	66 89 14 c5 c0 80 11 	mov    %dx,0x1180c0(,%eax,8)
  1018bf:	00 
  1018c0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018c3:	66 c7 04 c5 c2 80 11 	movw   $0x8,0x1180c2(,%eax,8)
  1018ca:	00 08 00 
  1018cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018d0:	0f b6 14 c5 c4 80 11 	movzbl 0x1180c4(,%eax,8),%edx
  1018d7:	00 
  1018d8:	83 e2 e0             	and    $0xffffffe0,%edx
  1018db:	88 14 c5 c4 80 11 00 	mov    %dl,0x1180c4(,%eax,8)
  1018e2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018e5:	0f b6 14 c5 c4 80 11 	movzbl 0x1180c4(,%eax,8),%edx
  1018ec:	00 
  1018ed:	83 e2 1f             	and    $0x1f,%edx
  1018f0:	88 14 c5 c4 80 11 00 	mov    %dl,0x1180c4(,%eax,8)
  1018f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018fa:	0f b6 14 c5 c5 80 11 	movzbl 0x1180c5(,%eax,8),%edx
  101901:	00 
  101902:	83 e2 f0             	and    $0xfffffff0,%edx
  101905:	83 ca 0e             	or     $0xe,%edx
  101908:	88 14 c5 c5 80 11 00 	mov    %dl,0x1180c5(,%eax,8)
  10190f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101912:	0f b6 14 c5 c5 80 11 	movzbl 0x1180c5(,%eax,8),%edx
  101919:	00 
  10191a:	83 e2 ef             	and    $0xffffffef,%edx
  10191d:	88 14 c5 c5 80 11 00 	mov    %dl,0x1180c5(,%eax,8)
  101924:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101927:	0f b6 14 c5 c5 80 11 	movzbl 0x1180c5(,%eax,8),%edx
  10192e:	00 
  10192f:	83 e2 9f             	and    $0xffffff9f,%edx
  101932:	88 14 c5 c5 80 11 00 	mov    %dl,0x1180c5(,%eax,8)
  101939:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10193c:	0f b6 14 c5 c5 80 11 	movzbl 0x1180c5(,%eax,8),%edx
  101943:	00 
  101944:	83 ca 80             	or     $0xffffff80,%edx
  101947:	88 14 c5 c5 80 11 00 	mov    %dl,0x1180c5(,%eax,8)
  10194e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101951:	8b 04 85 00 76 11 00 	mov    0x117600(,%eax,4),%eax
  101958:	c1 e8 10             	shr    $0x10,%eax
  10195b:	89 c2                	mov    %eax,%edx
  10195d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101960:	66 89 14 c5 c6 80 11 	mov    %dx,0x1180c6(,%eax,8)
  101967:	00 
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
  101968:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  10196c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10196f:	3d ff 00 00 00       	cmp    $0xff,%eax
  101974:	0f 86 2f ff ff ff    	jbe    1018a9 <idt_init+0x12>
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
    }
	// set for switch from user to kernel
    SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT, __vectors[T_SWITCH_TOK], DPL_USER);
  10197a:	a1 e4 77 11 00       	mov    0x1177e4,%eax
  10197f:	66 a3 88 84 11 00    	mov    %ax,0x118488
  101985:	66 c7 05 8a 84 11 00 	movw   $0x8,0x11848a
  10198c:	08 00 
  10198e:	0f b6 05 8c 84 11 00 	movzbl 0x11848c,%eax
  101995:	83 e0 e0             	and    $0xffffffe0,%eax
  101998:	a2 8c 84 11 00       	mov    %al,0x11848c
  10199d:	0f b6 05 8c 84 11 00 	movzbl 0x11848c,%eax
  1019a4:	83 e0 1f             	and    $0x1f,%eax
  1019a7:	a2 8c 84 11 00       	mov    %al,0x11848c
  1019ac:	0f b6 05 8d 84 11 00 	movzbl 0x11848d,%eax
  1019b3:	83 e0 f0             	and    $0xfffffff0,%eax
  1019b6:	83 c8 0e             	or     $0xe,%eax
  1019b9:	a2 8d 84 11 00       	mov    %al,0x11848d
  1019be:	0f b6 05 8d 84 11 00 	movzbl 0x11848d,%eax
  1019c5:	83 e0 ef             	and    $0xffffffef,%eax
  1019c8:	a2 8d 84 11 00       	mov    %al,0x11848d
  1019cd:	0f b6 05 8d 84 11 00 	movzbl 0x11848d,%eax
  1019d4:	83 c8 60             	or     $0x60,%eax
  1019d7:	a2 8d 84 11 00       	mov    %al,0x11848d
  1019dc:	0f b6 05 8d 84 11 00 	movzbl 0x11848d,%eax
  1019e3:	83 c8 80             	or     $0xffffff80,%eax
  1019e6:	a2 8d 84 11 00       	mov    %al,0x11848d
  1019eb:	a1 e4 77 11 00       	mov    0x1177e4,%eax
  1019f0:	c1 e8 10             	shr    $0x10,%eax
  1019f3:	66 a3 8e 84 11 00    	mov    %ax,0x11848e
  1019f9:	c7 45 f8 80 75 11 00 	movl   $0x117580,-0x8(%ebp)
    }
}

static inline void
lidt(struct pseudodesc *pd) {
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
  101a00:	8b 45 f8             	mov    -0x8(%ebp),%eax
  101a03:	0f 01 18             	lidtl  (%eax)
	// load the IDT
    lidt(&idt_pd);
}
  101a06:	c9                   	leave  
  101a07:	c3                   	ret    

00101a08 <trapname>:

static const char *
trapname(int trapno) {
  101a08:	55                   	push   %ebp
  101a09:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
  101a0b:	8b 45 08             	mov    0x8(%ebp),%eax
  101a0e:	83 f8 13             	cmp    $0x13,%eax
  101a11:	77 0c                	ja     101a1f <trapname+0x17>
        return excnames[trapno];
  101a13:	8b 45 08             	mov    0x8(%ebp),%eax
  101a16:	8b 04 85 a0 66 10 00 	mov    0x1066a0(,%eax,4),%eax
  101a1d:	eb 18                	jmp    101a37 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
  101a1f:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  101a23:	7e 0d                	jle    101a32 <trapname+0x2a>
  101a25:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
  101a29:	7f 07                	jg     101a32 <trapname+0x2a>
        return "Hardware Interrupt";
  101a2b:	b8 4a 63 10 00       	mov    $0x10634a,%eax
  101a30:	eb 05                	jmp    101a37 <trapname+0x2f>
    }
    return "(unknown trap)";
  101a32:	b8 5d 63 10 00       	mov    $0x10635d,%eax
}
  101a37:	5d                   	pop    %ebp
  101a38:	c3                   	ret    

00101a39 <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
  101a39:	55                   	push   %ebp
  101a3a:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
  101a3c:	8b 45 08             	mov    0x8(%ebp),%eax
  101a3f:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101a43:	66 83 f8 08          	cmp    $0x8,%ax
  101a47:	0f 94 c0             	sete   %al
  101a4a:	0f b6 c0             	movzbl %al,%eax
}
  101a4d:	5d                   	pop    %ebp
  101a4e:	c3                   	ret    

00101a4f <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
  101a4f:	55                   	push   %ebp
  101a50:	89 e5                	mov    %esp,%ebp
  101a52:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
  101a55:	8b 45 08             	mov    0x8(%ebp),%eax
  101a58:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a5c:	c7 04 24 9e 63 10 00 	movl   $0x10639e,(%esp)
  101a63:	e8 df e8 ff ff       	call   100347 <cprintf>
    print_regs(&tf->tf_regs);
  101a68:	8b 45 08             	mov    0x8(%ebp),%eax
  101a6b:	89 04 24             	mov    %eax,(%esp)
  101a6e:	e8 a1 01 00 00       	call   101c14 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
  101a73:	8b 45 08             	mov    0x8(%ebp),%eax
  101a76:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
  101a7a:	0f b7 c0             	movzwl %ax,%eax
  101a7d:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a81:	c7 04 24 af 63 10 00 	movl   $0x1063af,(%esp)
  101a88:	e8 ba e8 ff ff       	call   100347 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
  101a8d:	8b 45 08             	mov    0x8(%ebp),%eax
  101a90:	0f b7 40 28          	movzwl 0x28(%eax),%eax
  101a94:	0f b7 c0             	movzwl %ax,%eax
  101a97:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a9b:	c7 04 24 c2 63 10 00 	movl   $0x1063c2,(%esp)
  101aa2:	e8 a0 e8 ff ff       	call   100347 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
  101aa7:	8b 45 08             	mov    0x8(%ebp),%eax
  101aaa:	0f b7 40 24          	movzwl 0x24(%eax),%eax
  101aae:	0f b7 c0             	movzwl %ax,%eax
  101ab1:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ab5:	c7 04 24 d5 63 10 00 	movl   $0x1063d5,(%esp)
  101abc:	e8 86 e8 ff ff       	call   100347 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
  101ac1:	8b 45 08             	mov    0x8(%ebp),%eax
  101ac4:	0f b7 40 20          	movzwl 0x20(%eax),%eax
  101ac8:	0f b7 c0             	movzwl %ax,%eax
  101acb:	89 44 24 04          	mov    %eax,0x4(%esp)
  101acf:	c7 04 24 e8 63 10 00 	movl   $0x1063e8,(%esp)
  101ad6:	e8 6c e8 ff ff       	call   100347 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
  101adb:	8b 45 08             	mov    0x8(%ebp),%eax
  101ade:	8b 40 30             	mov    0x30(%eax),%eax
  101ae1:	89 04 24             	mov    %eax,(%esp)
  101ae4:	e8 1f ff ff ff       	call   101a08 <trapname>
  101ae9:	8b 55 08             	mov    0x8(%ebp),%edx
  101aec:	8b 52 30             	mov    0x30(%edx),%edx
  101aef:	89 44 24 08          	mov    %eax,0x8(%esp)
  101af3:	89 54 24 04          	mov    %edx,0x4(%esp)
  101af7:	c7 04 24 fb 63 10 00 	movl   $0x1063fb,(%esp)
  101afe:	e8 44 e8 ff ff       	call   100347 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
  101b03:	8b 45 08             	mov    0x8(%ebp),%eax
  101b06:	8b 40 34             	mov    0x34(%eax),%eax
  101b09:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b0d:	c7 04 24 0d 64 10 00 	movl   $0x10640d,(%esp)
  101b14:	e8 2e e8 ff ff       	call   100347 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
  101b19:	8b 45 08             	mov    0x8(%ebp),%eax
  101b1c:	8b 40 38             	mov    0x38(%eax),%eax
  101b1f:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b23:	c7 04 24 1c 64 10 00 	movl   $0x10641c,(%esp)
  101b2a:	e8 18 e8 ff ff       	call   100347 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
  101b2f:	8b 45 08             	mov    0x8(%ebp),%eax
  101b32:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101b36:	0f b7 c0             	movzwl %ax,%eax
  101b39:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b3d:	c7 04 24 2b 64 10 00 	movl   $0x10642b,(%esp)
  101b44:	e8 fe e7 ff ff       	call   100347 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
  101b49:	8b 45 08             	mov    0x8(%ebp),%eax
  101b4c:	8b 40 40             	mov    0x40(%eax),%eax
  101b4f:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b53:	c7 04 24 3e 64 10 00 	movl   $0x10643e,(%esp)
  101b5a:	e8 e8 e7 ff ff       	call   100347 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101b5f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  101b66:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  101b6d:	eb 3e                	jmp    101bad <print_trapframe+0x15e>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
  101b6f:	8b 45 08             	mov    0x8(%ebp),%eax
  101b72:	8b 50 40             	mov    0x40(%eax),%edx
  101b75:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101b78:	21 d0                	and    %edx,%eax
  101b7a:	85 c0                	test   %eax,%eax
  101b7c:	74 28                	je     101ba6 <print_trapframe+0x157>
  101b7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101b81:	8b 04 85 a0 75 11 00 	mov    0x1175a0(,%eax,4),%eax
  101b88:	85 c0                	test   %eax,%eax
  101b8a:	74 1a                	je     101ba6 <print_trapframe+0x157>
            cprintf("%s,", IA32flags[i]);
  101b8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101b8f:	8b 04 85 a0 75 11 00 	mov    0x1175a0(,%eax,4),%eax
  101b96:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b9a:	c7 04 24 4d 64 10 00 	movl   $0x10644d,(%esp)
  101ba1:	e8 a1 e7 ff ff       	call   100347 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
    cprintf("  flag 0x%08x ", tf->tf_eflags);

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101ba6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  101baa:	d1 65 f0             	shll   -0x10(%ebp)
  101bad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101bb0:	83 f8 17             	cmp    $0x17,%eax
  101bb3:	76 ba                	jbe    101b6f <print_trapframe+0x120>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
            cprintf("%s,", IA32flags[i]);
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
  101bb5:	8b 45 08             	mov    0x8(%ebp),%eax
  101bb8:	8b 40 40             	mov    0x40(%eax),%eax
  101bbb:	25 00 30 00 00       	and    $0x3000,%eax
  101bc0:	c1 e8 0c             	shr    $0xc,%eax
  101bc3:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bc7:	c7 04 24 51 64 10 00 	movl   $0x106451,(%esp)
  101bce:	e8 74 e7 ff ff       	call   100347 <cprintf>

    if (!trap_in_kernel(tf)) {
  101bd3:	8b 45 08             	mov    0x8(%ebp),%eax
  101bd6:	89 04 24             	mov    %eax,(%esp)
  101bd9:	e8 5b fe ff ff       	call   101a39 <trap_in_kernel>
  101bde:	85 c0                	test   %eax,%eax
  101be0:	75 30                	jne    101c12 <print_trapframe+0x1c3>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
  101be2:	8b 45 08             	mov    0x8(%ebp),%eax
  101be5:	8b 40 44             	mov    0x44(%eax),%eax
  101be8:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bec:	c7 04 24 5a 64 10 00 	movl   $0x10645a,(%esp)
  101bf3:	e8 4f e7 ff ff       	call   100347 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
  101bf8:	8b 45 08             	mov    0x8(%ebp),%eax
  101bfb:	0f b7 40 48          	movzwl 0x48(%eax),%eax
  101bff:	0f b7 c0             	movzwl %ax,%eax
  101c02:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c06:	c7 04 24 69 64 10 00 	movl   $0x106469,(%esp)
  101c0d:	e8 35 e7 ff ff       	call   100347 <cprintf>
    }
}
  101c12:	c9                   	leave  
  101c13:	c3                   	ret    

00101c14 <print_regs>:

void
print_regs(struct pushregs *regs) {
  101c14:	55                   	push   %ebp
  101c15:	89 e5                	mov    %esp,%ebp
  101c17:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
  101c1a:	8b 45 08             	mov    0x8(%ebp),%eax
  101c1d:	8b 00                	mov    (%eax),%eax
  101c1f:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c23:	c7 04 24 7c 64 10 00 	movl   $0x10647c,(%esp)
  101c2a:	e8 18 e7 ff ff       	call   100347 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
  101c2f:	8b 45 08             	mov    0x8(%ebp),%eax
  101c32:	8b 40 04             	mov    0x4(%eax),%eax
  101c35:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c39:	c7 04 24 8b 64 10 00 	movl   $0x10648b,(%esp)
  101c40:	e8 02 e7 ff ff       	call   100347 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
  101c45:	8b 45 08             	mov    0x8(%ebp),%eax
  101c48:	8b 40 08             	mov    0x8(%eax),%eax
  101c4b:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c4f:	c7 04 24 9a 64 10 00 	movl   $0x10649a,(%esp)
  101c56:	e8 ec e6 ff ff       	call   100347 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
  101c5b:	8b 45 08             	mov    0x8(%ebp),%eax
  101c5e:	8b 40 0c             	mov    0xc(%eax),%eax
  101c61:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c65:	c7 04 24 a9 64 10 00 	movl   $0x1064a9,(%esp)
  101c6c:	e8 d6 e6 ff ff       	call   100347 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
  101c71:	8b 45 08             	mov    0x8(%ebp),%eax
  101c74:	8b 40 10             	mov    0x10(%eax),%eax
  101c77:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c7b:	c7 04 24 b8 64 10 00 	movl   $0x1064b8,(%esp)
  101c82:	e8 c0 e6 ff ff       	call   100347 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
  101c87:	8b 45 08             	mov    0x8(%ebp),%eax
  101c8a:	8b 40 14             	mov    0x14(%eax),%eax
  101c8d:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c91:	c7 04 24 c7 64 10 00 	movl   $0x1064c7,(%esp)
  101c98:	e8 aa e6 ff ff       	call   100347 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
  101c9d:	8b 45 08             	mov    0x8(%ebp),%eax
  101ca0:	8b 40 18             	mov    0x18(%eax),%eax
  101ca3:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ca7:	c7 04 24 d6 64 10 00 	movl   $0x1064d6,(%esp)
  101cae:	e8 94 e6 ff ff       	call   100347 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
  101cb3:	8b 45 08             	mov    0x8(%ebp),%eax
  101cb6:	8b 40 1c             	mov    0x1c(%eax),%eax
  101cb9:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cbd:	c7 04 24 e5 64 10 00 	movl   $0x1064e5,(%esp)
  101cc4:	e8 7e e6 ff ff       	call   100347 <cprintf>
}
  101cc9:	c9                   	leave  
  101cca:	c3                   	ret    

00101ccb <trap_dispatch>:
/* temporary trapframe or pointer to trapframe */
struct trapframe switchk2u, *switchu2k;

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
  101ccb:	55                   	push   %ebp
  101ccc:	89 e5                	mov    %esp,%ebp
  101cce:	57                   	push   %edi
  101ccf:	56                   	push   %esi
  101cd0:	53                   	push   %ebx
  101cd1:	83 ec 2c             	sub    $0x2c,%esp
    char c;

    switch (tf->tf_trapno) {
  101cd4:	8b 45 08             	mov    0x8(%ebp),%eax
  101cd7:	8b 40 30             	mov    0x30(%eax),%eax
  101cda:	83 f8 2f             	cmp    $0x2f,%eax
  101cdd:	77 21                	ja     101d00 <trap_dispatch+0x35>
  101cdf:	83 f8 2e             	cmp    $0x2e,%eax
  101ce2:	0f 83 89 01 00 00    	jae    101e71 <trap_dispatch+0x1a6>
  101ce8:	83 f8 21             	cmp    $0x21,%eax
  101ceb:	0f 84 8a 00 00 00    	je     101d7b <trap_dispatch+0xb0>
  101cf1:	83 f8 24             	cmp    $0x24,%eax
  101cf4:	74 5c                	je     101d52 <trap_dispatch+0x87>
  101cf6:	83 f8 20             	cmp    $0x20,%eax
  101cf9:	74 1c                	je     101d17 <trap_dispatch+0x4c>
  101cfb:	e9 39 01 00 00       	jmp    101e39 <trap_dispatch+0x16e>
  101d00:	83 f8 78             	cmp    $0x78,%eax
  101d03:	0f 84 9b 00 00 00    	je     101da4 <trap_dispatch+0xd9>
  101d09:	83 f8 79             	cmp    $0x79,%eax
  101d0c:	0f 84 0b 01 00 00    	je     101e1d <trap_dispatch+0x152>
  101d12:	e9 22 01 00 00       	jmp    101e39 <trap_dispatch+0x16e>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks ++;
  101d17:	a1 4c 89 11 00       	mov    0x11894c,%eax
  101d1c:	83 c0 01             	add    $0x1,%eax
  101d1f:	a3 4c 89 11 00       	mov    %eax,0x11894c
        if (ticks % TICK_NUM == 0) {
  101d24:	8b 0d 4c 89 11 00    	mov    0x11894c,%ecx
  101d2a:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
  101d2f:	89 c8                	mov    %ecx,%eax
  101d31:	f7 e2                	mul    %edx
  101d33:	89 d0                	mov    %edx,%eax
  101d35:	c1 e8 05             	shr    $0x5,%eax
  101d38:	6b c0 64             	imul   $0x64,%eax,%eax
  101d3b:	29 c1                	sub    %eax,%ecx
  101d3d:	89 c8                	mov    %ecx,%eax
  101d3f:	85 c0                	test   %eax,%eax
  101d41:	75 0a                	jne    101d4d <trap_dispatch+0x82>
            print_ticks();
  101d43:	e8 33 fb ff ff       	call   10187b <print_ticks>
        }
        break;
  101d48:	e9 25 01 00 00       	jmp    101e72 <trap_dispatch+0x1a7>
  101d4d:	e9 20 01 00 00       	jmp    101e72 <trap_dispatch+0x1a7>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
  101d52:	e8 e8 f8 ff ff       	call   10163f <cons_getc>
  101d57:	88 45 e7             	mov    %al,-0x19(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
  101d5a:	0f be 55 e7          	movsbl -0x19(%ebp),%edx
  101d5e:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  101d62:	89 54 24 08          	mov    %edx,0x8(%esp)
  101d66:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d6a:	c7 04 24 f4 64 10 00 	movl   $0x1064f4,(%esp)
  101d71:	e8 d1 e5 ff ff       	call   100347 <cprintf>
        break;
  101d76:	e9 f7 00 00 00       	jmp    101e72 <trap_dispatch+0x1a7>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
  101d7b:	e8 bf f8 ff ff       	call   10163f <cons_getc>
  101d80:	88 45 e7             	mov    %al,-0x19(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
  101d83:	0f be 55 e7          	movsbl -0x19(%ebp),%edx
  101d87:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  101d8b:	89 54 24 08          	mov    %edx,0x8(%esp)
  101d8f:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d93:	c7 04 24 06 65 10 00 	movl   $0x106506,(%esp)
  101d9a:	e8 a8 e5 ff ff       	call   100347 <cprintf>
        break;
  101d9f:	e9 ce 00 00 00       	jmp    101e72 <trap_dispatch+0x1a7>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
        if (tf->tf_cs != USER_CS) {
  101da4:	8b 45 08             	mov    0x8(%ebp),%eax
  101da7:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101dab:	66 83 f8 1b          	cmp    $0x1b,%ax
  101daf:	74 6a                	je     101e1b <trap_dispatch+0x150>
            switchk2u = *tf;
  101db1:	8b 45 08             	mov    0x8(%ebp),%eax
  101db4:	ba 60 89 11 00       	mov    $0x118960,%edx
  101db9:	89 c3                	mov    %eax,%ebx
  101dbb:	b8 13 00 00 00       	mov    $0x13,%eax
  101dc0:	89 d7                	mov    %edx,%edi
  101dc2:	89 de                	mov    %ebx,%esi
  101dc4:	89 c1                	mov    %eax,%ecx
  101dc6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
            switchk2u.tf_cs = USER_CS;
  101dc8:	66 c7 05 9c 89 11 00 	movw   $0x1b,0x11899c
  101dcf:	1b 00 
            switchk2u.tf_ds = switchk2u.tf_es = switchk2u.tf_ss = USER_DS;
  101dd1:	66 c7 05 a8 89 11 00 	movw   $0x23,0x1189a8
  101dd8:	23 00 
  101dda:	0f b7 05 a8 89 11 00 	movzwl 0x1189a8,%eax
  101de1:	66 a3 88 89 11 00    	mov    %ax,0x118988
  101de7:	0f b7 05 88 89 11 00 	movzwl 0x118988,%eax
  101dee:	66 a3 8c 89 11 00    	mov    %ax,0x11898c
            switchk2u.tf_esp = (uint32_t)tf + sizeof(struct trapframe) - 8;
  101df4:	8b 45 08             	mov    0x8(%ebp),%eax
  101df7:	83 c0 44             	add    $0x44,%eax
  101dfa:	a3 a4 89 11 00       	mov    %eax,0x1189a4
		
            // set eflags, make sure ucore can use io under user mode.
            // if CPL > IOPL, then cpu will generate a general protection.
            switchk2u.tf_eflags |= FL_IOPL_MASK;
  101dff:	a1 a0 89 11 00       	mov    0x1189a0,%eax
  101e04:	80 cc 30             	or     $0x30,%ah
  101e07:	a3 a0 89 11 00       	mov    %eax,0x1189a0
		
            // set temporary stack
            // then iret will jump to the right stack
            *((uint32_t *)tf - 1) = (uint32_t)&switchk2u;
  101e0c:	8b 45 08             	mov    0x8(%ebp),%eax
  101e0f:	8d 50 fc             	lea    -0x4(%eax),%edx
  101e12:	b8 60 89 11 00       	mov    $0x118960,%eax
  101e17:	89 02                	mov    %eax,(%edx)
        }
        break;
  101e19:	eb 57                	jmp    101e72 <trap_dispatch+0x1a7>
  101e1b:	eb 55                	jmp    101e72 <trap_dispatch+0x1a7>
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
  101e1d:	c7 44 24 08 15 65 10 	movl   $0x106515,0x8(%esp)
  101e24:	00 
  101e25:	c7 44 24 04 c1 00 00 	movl   $0xc1,0x4(%esp)
  101e2c:	00 
  101e2d:	c7 04 24 25 65 10 00 	movl   $0x106525,(%esp)
  101e34:	e8 98 ee ff ff       	call   100cd1 <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
  101e39:	8b 45 08             	mov    0x8(%ebp),%eax
  101e3c:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101e40:	0f b7 c0             	movzwl %ax,%eax
  101e43:	83 e0 03             	and    $0x3,%eax
  101e46:	85 c0                	test   %eax,%eax
  101e48:	75 28                	jne    101e72 <trap_dispatch+0x1a7>
            print_trapframe(tf);
  101e4a:	8b 45 08             	mov    0x8(%ebp),%eax
  101e4d:	89 04 24             	mov    %eax,(%esp)
  101e50:	e8 fa fb ff ff       	call   101a4f <print_trapframe>
            panic("unexpected trap in kernel.\n");
  101e55:	c7 44 24 08 36 65 10 	movl   $0x106536,0x8(%esp)
  101e5c:	00 
  101e5d:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
  101e64:	00 
  101e65:	c7 04 24 25 65 10 00 	movl   $0x106525,(%esp)
  101e6c:	e8 60 ee ff ff       	call   100cd1 <__panic>
        panic("T_SWITCH_** ??\n");
        break;
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
  101e71:	90                   	nop
        if ((tf->tf_cs & 3) == 0) {
            print_trapframe(tf);
            panic("unexpected trap in kernel.\n");
        }
    }
}
  101e72:	83 c4 2c             	add    $0x2c,%esp
  101e75:	5b                   	pop    %ebx
  101e76:	5e                   	pop    %esi
  101e77:	5f                   	pop    %edi
  101e78:	5d                   	pop    %ebp
  101e79:	c3                   	ret    

00101e7a <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
  101e7a:	55                   	push   %ebp
  101e7b:	89 e5                	mov    %esp,%ebp
  101e7d:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
  101e80:	8b 45 08             	mov    0x8(%ebp),%eax
  101e83:	89 04 24             	mov    %eax,(%esp)
  101e86:	e8 40 fe ff ff       	call   101ccb <trap_dispatch>
}
  101e8b:	c9                   	leave  
  101e8c:	c3                   	ret    

00101e8d <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
  101e8d:	1e                   	push   %ds
    pushl %es
  101e8e:	06                   	push   %es
    pushl %fs
  101e8f:	0f a0                	push   %fs
    pushl %gs
  101e91:	0f a8                	push   %gs
    pushal
  101e93:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
  101e94:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
  101e99:	8e d8                	mov    %eax,%ds
    movw %ax, %es
  101e9b:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
  101e9d:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
  101e9e:	e8 d7 ff ff ff       	call   101e7a <trap>

    # pop the pushed stack pointer
    popl %esp
  101ea3:	5c                   	pop    %esp

00101ea4 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
  101ea4:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
  101ea5:	0f a9                	pop    %gs
    popl %fs
  101ea7:	0f a1                	pop    %fs
    popl %es
  101ea9:	07                   	pop    %es
    popl %ds
  101eaa:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
  101eab:	83 c4 08             	add    $0x8,%esp
    iret
  101eae:	cf                   	iret   

00101eaf <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
  101eaf:	6a 00                	push   $0x0
  pushl $0
  101eb1:	6a 00                	push   $0x0
  jmp __alltraps
  101eb3:	e9 d5 ff ff ff       	jmp    101e8d <__alltraps>

00101eb8 <vector1>:
.globl vector1
vector1:
  pushl $0
  101eb8:	6a 00                	push   $0x0
  pushl $1
  101eba:	6a 01                	push   $0x1
  jmp __alltraps
  101ebc:	e9 cc ff ff ff       	jmp    101e8d <__alltraps>

00101ec1 <vector2>:
.globl vector2
vector2:
  pushl $0
  101ec1:	6a 00                	push   $0x0
  pushl $2
  101ec3:	6a 02                	push   $0x2
  jmp __alltraps
  101ec5:	e9 c3 ff ff ff       	jmp    101e8d <__alltraps>

00101eca <vector3>:
.globl vector3
vector3:
  pushl $0
  101eca:	6a 00                	push   $0x0
  pushl $3
  101ecc:	6a 03                	push   $0x3
  jmp __alltraps
  101ece:	e9 ba ff ff ff       	jmp    101e8d <__alltraps>

00101ed3 <vector4>:
.globl vector4
vector4:
  pushl $0
  101ed3:	6a 00                	push   $0x0
  pushl $4
  101ed5:	6a 04                	push   $0x4
  jmp __alltraps
  101ed7:	e9 b1 ff ff ff       	jmp    101e8d <__alltraps>

00101edc <vector5>:
.globl vector5
vector5:
  pushl $0
  101edc:	6a 00                	push   $0x0
  pushl $5
  101ede:	6a 05                	push   $0x5
  jmp __alltraps
  101ee0:	e9 a8 ff ff ff       	jmp    101e8d <__alltraps>

00101ee5 <vector6>:
.globl vector6
vector6:
  pushl $0
  101ee5:	6a 00                	push   $0x0
  pushl $6
  101ee7:	6a 06                	push   $0x6
  jmp __alltraps
  101ee9:	e9 9f ff ff ff       	jmp    101e8d <__alltraps>

00101eee <vector7>:
.globl vector7
vector7:
  pushl $0
  101eee:	6a 00                	push   $0x0
  pushl $7
  101ef0:	6a 07                	push   $0x7
  jmp __alltraps
  101ef2:	e9 96 ff ff ff       	jmp    101e8d <__alltraps>

00101ef7 <vector8>:
.globl vector8
vector8:
  pushl $8
  101ef7:	6a 08                	push   $0x8
  jmp __alltraps
  101ef9:	e9 8f ff ff ff       	jmp    101e8d <__alltraps>

00101efe <vector9>:
.globl vector9
vector9:
  pushl $9
  101efe:	6a 09                	push   $0x9
  jmp __alltraps
  101f00:	e9 88 ff ff ff       	jmp    101e8d <__alltraps>

00101f05 <vector10>:
.globl vector10
vector10:
  pushl $10
  101f05:	6a 0a                	push   $0xa
  jmp __alltraps
  101f07:	e9 81 ff ff ff       	jmp    101e8d <__alltraps>

00101f0c <vector11>:
.globl vector11
vector11:
  pushl $11
  101f0c:	6a 0b                	push   $0xb
  jmp __alltraps
  101f0e:	e9 7a ff ff ff       	jmp    101e8d <__alltraps>

00101f13 <vector12>:
.globl vector12
vector12:
  pushl $12
  101f13:	6a 0c                	push   $0xc
  jmp __alltraps
  101f15:	e9 73 ff ff ff       	jmp    101e8d <__alltraps>

00101f1a <vector13>:
.globl vector13
vector13:
  pushl $13
  101f1a:	6a 0d                	push   $0xd
  jmp __alltraps
  101f1c:	e9 6c ff ff ff       	jmp    101e8d <__alltraps>

00101f21 <vector14>:
.globl vector14
vector14:
  pushl $14
  101f21:	6a 0e                	push   $0xe
  jmp __alltraps
  101f23:	e9 65 ff ff ff       	jmp    101e8d <__alltraps>

00101f28 <vector15>:
.globl vector15
vector15:
  pushl $0
  101f28:	6a 00                	push   $0x0
  pushl $15
  101f2a:	6a 0f                	push   $0xf
  jmp __alltraps
  101f2c:	e9 5c ff ff ff       	jmp    101e8d <__alltraps>

00101f31 <vector16>:
.globl vector16
vector16:
  pushl $0
  101f31:	6a 00                	push   $0x0
  pushl $16
  101f33:	6a 10                	push   $0x10
  jmp __alltraps
  101f35:	e9 53 ff ff ff       	jmp    101e8d <__alltraps>

00101f3a <vector17>:
.globl vector17
vector17:
  pushl $17
  101f3a:	6a 11                	push   $0x11
  jmp __alltraps
  101f3c:	e9 4c ff ff ff       	jmp    101e8d <__alltraps>

00101f41 <vector18>:
.globl vector18
vector18:
  pushl $0
  101f41:	6a 00                	push   $0x0
  pushl $18
  101f43:	6a 12                	push   $0x12
  jmp __alltraps
  101f45:	e9 43 ff ff ff       	jmp    101e8d <__alltraps>

00101f4a <vector19>:
.globl vector19
vector19:
  pushl $0
  101f4a:	6a 00                	push   $0x0
  pushl $19
  101f4c:	6a 13                	push   $0x13
  jmp __alltraps
  101f4e:	e9 3a ff ff ff       	jmp    101e8d <__alltraps>

00101f53 <vector20>:
.globl vector20
vector20:
  pushl $0
  101f53:	6a 00                	push   $0x0
  pushl $20
  101f55:	6a 14                	push   $0x14
  jmp __alltraps
  101f57:	e9 31 ff ff ff       	jmp    101e8d <__alltraps>

00101f5c <vector21>:
.globl vector21
vector21:
  pushl $0
  101f5c:	6a 00                	push   $0x0
  pushl $21
  101f5e:	6a 15                	push   $0x15
  jmp __alltraps
  101f60:	e9 28 ff ff ff       	jmp    101e8d <__alltraps>

00101f65 <vector22>:
.globl vector22
vector22:
  pushl $0
  101f65:	6a 00                	push   $0x0
  pushl $22
  101f67:	6a 16                	push   $0x16
  jmp __alltraps
  101f69:	e9 1f ff ff ff       	jmp    101e8d <__alltraps>

00101f6e <vector23>:
.globl vector23
vector23:
  pushl $0
  101f6e:	6a 00                	push   $0x0
  pushl $23
  101f70:	6a 17                	push   $0x17
  jmp __alltraps
  101f72:	e9 16 ff ff ff       	jmp    101e8d <__alltraps>

00101f77 <vector24>:
.globl vector24
vector24:
  pushl $0
  101f77:	6a 00                	push   $0x0
  pushl $24
  101f79:	6a 18                	push   $0x18
  jmp __alltraps
  101f7b:	e9 0d ff ff ff       	jmp    101e8d <__alltraps>

00101f80 <vector25>:
.globl vector25
vector25:
  pushl $0
  101f80:	6a 00                	push   $0x0
  pushl $25
  101f82:	6a 19                	push   $0x19
  jmp __alltraps
  101f84:	e9 04 ff ff ff       	jmp    101e8d <__alltraps>

00101f89 <vector26>:
.globl vector26
vector26:
  pushl $0
  101f89:	6a 00                	push   $0x0
  pushl $26
  101f8b:	6a 1a                	push   $0x1a
  jmp __alltraps
  101f8d:	e9 fb fe ff ff       	jmp    101e8d <__alltraps>

00101f92 <vector27>:
.globl vector27
vector27:
  pushl $0
  101f92:	6a 00                	push   $0x0
  pushl $27
  101f94:	6a 1b                	push   $0x1b
  jmp __alltraps
  101f96:	e9 f2 fe ff ff       	jmp    101e8d <__alltraps>

00101f9b <vector28>:
.globl vector28
vector28:
  pushl $0
  101f9b:	6a 00                	push   $0x0
  pushl $28
  101f9d:	6a 1c                	push   $0x1c
  jmp __alltraps
  101f9f:	e9 e9 fe ff ff       	jmp    101e8d <__alltraps>

00101fa4 <vector29>:
.globl vector29
vector29:
  pushl $0
  101fa4:	6a 00                	push   $0x0
  pushl $29
  101fa6:	6a 1d                	push   $0x1d
  jmp __alltraps
  101fa8:	e9 e0 fe ff ff       	jmp    101e8d <__alltraps>

00101fad <vector30>:
.globl vector30
vector30:
  pushl $0
  101fad:	6a 00                	push   $0x0
  pushl $30
  101faf:	6a 1e                	push   $0x1e
  jmp __alltraps
  101fb1:	e9 d7 fe ff ff       	jmp    101e8d <__alltraps>

00101fb6 <vector31>:
.globl vector31
vector31:
  pushl $0
  101fb6:	6a 00                	push   $0x0
  pushl $31
  101fb8:	6a 1f                	push   $0x1f
  jmp __alltraps
  101fba:	e9 ce fe ff ff       	jmp    101e8d <__alltraps>

00101fbf <vector32>:
.globl vector32
vector32:
  pushl $0
  101fbf:	6a 00                	push   $0x0
  pushl $32
  101fc1:	6a 20                	push   $0x20
  jmp __alltraps
  101fc3:	e9 c5 fe ff ff       	jmp    101e8d <__alltraps>

00101fc8 <vector33>:
.globl vector33
vector33:
  pushl $0
  101fc8:	6a 00                	push   $0x0
  pushl $33
  101fca:	6a 21                	push   $0x21
  jmp __alltraps
  101fcc:	e9 bc fe ff ff       	jmp    101e8d <__alltraps>

00101fd1 <vector34>:
.globl vector34
vector34:
  pushl $0
  101fd1:	6a 00                	push   $0x0
  pushl $34
  101fd3:	6a 22                	push   $0x22
  jmp __alltraps
  101fd5:	e9 b3 fe ff ff       	jmp    101e8d <__alltraps>

00101fda <vector35>:
.globl vector35
vector35:
  pushl $0
  101fda:	6a 00                	push   $0x0
  pushl $35
  101fdc:	6a 23                	push   $0x23
  jmp __alltraps
  101fde:	e9 aa fe ff ff       	jmp    101e8d <__alltraps>

00101fe3 <vector36>:
.globl vector36
vector36:
  pushl $0
  101fe3:	6a 00                	push   $0x0
  pushl $36
  101fe5:	6a 24                	push   $0x24
  jmp __alltraps
  101fe7:	e9 a1 fe ff ff       	jmp    101e8d <__alltraps>

00101fec <vector37>:
.globl vector37
vector37:
  pushl $0
  101fec:	6a 00                	push   $0x0
  pushl $37
  101fee:	6a 25                	push   $0x25
  jmp __alltraps
  101ff0:	e9 98 fe ff ff       	jmp    101e8d <__alltraps>

00101ff5 <vector38>:
.globl vector38
vector38:
  pushl $0
  101ff5:	6a 00                	push   $0x0
  pushl $38
  101ff7:	6a 26                	push   $0x26
  jmp __alltraps
  101ff9:	e9 8f fe ff ff       	jmp    101e8d <__alltraps>

00101ffe <vector39>:
.globl vector39
vector39:
  pushl $0
  101ffe:	6a 00                	push   $0x0
  pushl $39
  102000:	6a 27                	push   $0x27
  jmp __alltraps
  102002:	e9 86 fe ff ff       	jmp    101e8d <__alltraps>

00102007 <vector40>:
.globl vector40
vector40:
  pushl $0
  102007:	6a 00                	push   $0x0
  pushl $40
  102009:	6a 28                	push   $0x28
  jmp __alltraps
  10200b:	e9 7d fe ff ff       	jmp    101e8d <__alltraps>

00102010 <vector41>:
.globl vector41
vector41:
  pushl $0
  102010:	6a 00                	push   $0x0
  pushl $41
  102012:	6a 29                	push   $0x29
  jmp __alltraps
  102014:	e9 74 fe ff ff       	jmp    101e8d <__alltraps>

00102019 <vector42>:
.globl vector42
vector42:
  pushl $0
  102019:	6a 00                	push   $0x0
  pushl $42
  10201b:	6a 2a                	push   $0x2a
  jmp __alltraps
  10201d:	e9 6b fe ff ff       	jmp    101e8d <__alltraps>

00102022 <vector43>:
.globl vector43
vector43:
  pushl $0
  102022:	6a 00                	push   $0x0
  pushl $43
  102024:	6a 2b                	push   $0x2b
  jmp __alltraps
  102026:	e9 62 fe ff ff       	jmp    101e8d <__alltraps>

0010202b <vector44>:
.globl vector44
vector44:
  pushl $0
  10202b:	6a 00                	push   $0x0
  pushl $44
  10202d:	6a 2c                	push   $0x2c
  jmp __alltraps
  10202f:	e9 59 fe ff ff       	jmp    101e8d <__alltraps>

00102034 <vector45>:
.globl vector45
vector45:
  pushl $0
  102034:	6a 00                	push   $0x0
  pushl $45
  102036:	6a 2d                	push   $0x2d
  jmp __alltraps
  102038:	e9 50 fe ff ff       	jmp    101e8d <__alltraps>

0010203d <vector46>:
.globl vector46
vector46:
  pushl $0
  10203d:	6a 00                	push   $0x0
  pushl $46
  10203f:	6a 2e                	push   $0x2e
  jmp __alltraps
  102041:	e9 47 fe ff ff       	jmp    101e8d <__alltraps>

00102046 <vector47>:
.globl vector47
vector47:
  pushl $0
  102046:	6a 00                	push   $0x0
  pushl $47
  102048:	6a 2f                	push   $0x2f
  jmp __alltraps
  10204a:	e9 3e fe ff ff       	jmp    101e8d <__alltraps>

0010204f <vector48>:
.globl vector48
vector48:
  pushl $0
  10204f:	6a 00                	push   $0x0
  pushl $48
  102051:	6a 30                	push   $0x30
  jmp __alltraps
  102053:	e9 35 fe ff ff       	jmp    101e8d <__alltraps>

00102058 <vector49>:
.globl vector49
vector49:
  pushl $0
  102058:	6a 00                	push   $0x0
  pushl $49
  10205a:	6a 31                	push   $0x31
  jmp __alltraps
  10205c:	e9 2c fe ff ff       	jmp    101e8d <__alltraps>

00102061 <vector50>:
.globl vector50
vector50:
  pushl $0
  102061:	6a 00                	push   $0x0
  pushl $50
  102063:	6a 32                	push   $0x32
  jmp __alltraps
  102065:	e9 23 fe ff ff       	jmp    101e8d <__alltraps>

0010206a <vector51>:
.globl vector51
vector51:
  pushl $0
  10206a:	6a 00                	push   $0x0
  pushl $51
  10206c:	6a 33                	push   $0x33
  jmp __alltraps
  10206e:	e9 1a fe ff ff       	jmp    101e8d <__alltraps>

00102073 <vector52>:
.globl vector52
vector52:
  pushl $0
  102073:	6a 00                	push   $0x0
  pushl $52
  102075:	6a 34                	push   $0x34
  jmp __alltraps
  102077:	e9 11 fe ff ff       	jmp    101e8d <__alltraps>

0010207c <vector53>:
.globl vector53
vector53:
  pushl $0
  10207c:	6a 00                	push   $0x0
  pushl $53
  10207e:	6a 35                	push   $0x35
  jmp __alltraps
  102080:	e9 08 fe ff ff       	jmp    101e8d <__alltraps>

00102085 <vector54>:
.globl vector54
vector54:
  pushl $0
  102085:	6a 00                	push   $0x0
  pushl $54
  102087:	6a 36                	push   $0x36
  jmp __alltraps
  102089:	e9 ff fd ff ff       	jmp    101e8d <__alltraps>

0010208e <vector55>:
.globl vector55
vector55:
  pushl $0
  10208e:	6a 00                	push   $0x0
  pushl $55
  102090:	6a 37                	push   $0x37
  jmp __alltraps
  102092:	e9 f6 fd ff ff       	jmp    101e8d <__alltraps>

00102097 <vector56>:
.globl vector56
vector56:
  pushl $0
  102097:	6a 00                	push   $0x0
  pushl $56
  102099:	6a 38                	push   $0x38
  jmp __alltraps
  10209b:	e9 ed fd ff ff       	jmp    101e8d <__alltraps>

001020a0 <vector57>:
.globl vector57
vector57:
  pushl $0
  1020a0:	6a 00                	push   $0x0
  pushl $57
  1020a2:	6a 39                	push   $0x39
  jmp __alltraps
  1020a4:	e9 e4 fd ff ff       	jmp    101e8d <__alltraps>

001020a9 <vector58>:
.globl vector58
vector58:
  pushl $0
  1020a9:	6a 00                	push   $0x0
  pushl $58
  1020ab:	6a 3a                	push   $0x3a
  jmp __alltraps
  1020ad:	e9 db fd ff ff       	jmp    101e8d <__alltraps>

001020b2 <vector59>:
.globl vector59
vector59:
  pushl $0
  1020b2:	6a 00                	push   $0x0
  pushl $59
  1020b4:	6a 3b                	push   $0x3b
  jmp __alltraps
  1020b6:	e9 d2 fd ff ff       	jmp    101e8d <__alltraps>

001020bb <vector60>:
.globl vector60
vector60:
  pushl $0
  1020bb:	6a 00                	push   $0x0
  pushl $60
  1020bd:	6a 3c                	push   $0x3c
  jmp __alltraps
  1020bf:	e9 c9 fd ff ff       	jmp    101e8d <__alltraps>

001020c4 <vector61>:
.globl vector61
vector61:
  pushl $0
  1020c4:	6a 00                	push   $0x0
  pushl $61
  1020c6:	6a 3d                	push   $0x3d
  jmp __alltraps
  1020c8:	e9 c0 fd ff ff       	jmp    101e8d <__alltraps>

001020cd <vector62>:
.globl vector62
vector62:
  pushl $0
  1020cd:	6a 00                	push   $0x0
  pushl $62
  1020cf:	6a 3e                	push   $0x3e
  jmp __alltraps
  1020d1:	e9 b7 fd ff ff       	jmp    101e8d <__alltraps>

001020d6 <vector63>:
.globl vector63
vector63:
  pushl $0
  1020d6:	6a 00                	push   $0x0
  pushl $63
  1020d8:	6a 3f                	push   $0x3f
  jmp __alltraps
  1020da:	e9 ae fd ff ff       	jmp    101e8d <__alltraps>

001020df <vector64>:
.globl vector64
vector64:
  pushl $0
  1020df:	6a 00                	push   $0x0
  pushl $64
  1020e1:	6a 40                	push   $0x40
  jmp __alltraps
  1020e3:	e9 a5 fd ff ff       	jmp    101e8d <__alltraps>

001020e8 <vector65>:
.globl vector65
vector65:
  pushl $0
  1020e8:	6a 00                	push   $0x0
  pushl $65
  1020ea:	6a 41                	push   $0x41
  jmp __alltraps
  1020ec:	e9 9c fd ff ff       	jmp    101e8d <__alltraps>

001020f1 <vector66>:
.globl vector66
vector66:
  pushl $0
  1020f1:	6a 00                	push   $0x0
  pushl $66
  1020f3:	6a 42                	push   $0x42
  jmp __alltraps
  1020f5:	e9 93 fd ff ff       	jmp    101e8d <__alltraps>

001020fa <vector67>:
.globl vector67
vector67:
  pushl $0
  1020fa:	6a 00                	push   $0x0
  pushl $67
  1020fc:	6a 43                	push   $0x43
  jmp __alltraps
  1020fe:	e9 8a fd ff ff       	jmp    101e8d <__alltraps>

00102103 <vector68>:
.globl vector68
vector68:
  pushl $0
  102103:	6a 00                	push   $0x0
  pushl $68
  102105:	6a 44                	push   $0x44
  jmp __alltraps
  102107:	e9 81 fd ff ff       	jmp    101e8d <__alltraps>

0010210c <vector69>:
.globl vector69
vector69:
  pushl $0
  10210c:	6a 00                	push   $0x0
  pushl $69
  10210e:	6a 45                	push   $0x45
  jmp __alltraps
  102110:	e9 78 fd ff ff       	jmp    101e8d <__alltraps>

00102115 <vector70>:
.globl vector70
vector70:
  pushl $0
  102115:	6a 00                	push   $0x0
  pushl $70
  102117:	6a 46                	push   $0x46
  jmp __alltraps
  102119:	e9 6f fd ff ff       	jmp    101e8d <__alltraps>

0010211e <vector71>:
.globl vector71
vector71:
  pushl $0
  10211e:	6a 00                	push   $0x0
  pushl $71
  102120:	6a 47                	push   $0x47
  jmp __alltraps
  102122:	e9 66 fd ff ff       	jmp    101e8d <__alltraps>

00102127 <vector72>:
.globl vector72
vector72:
  pushl $0
  102127:	6a 00                	push   $0x0
  pushl $72
  102129:	6a 48                	push   $0x48
  jmp __alltraps
  10212b:	e9 5d fd ff ff       	jmp    101e8d <__alltraps>

00102130 <vector73>:
.globl vector73
vector73:
  pushl $0
  102130:	6a 00                	push   $0x0
  pushl $73
  102132:	6a 49                	push   $0x49
  jmp __alltraps
  102134:	e9 54 fd ff ff       	jmp    101e8d <__alltraps>

00102139 <vector74>:
.globl vector74
vector74:
  pushl $0
  102139:	6a 00                	push   $0x0
  pushl $74
  10213b:	6a 4a                	push   $0x4a
  jmp __alltraps
  10213d:	e9 4b fd ff ff       	jmp    101e8d <__alltraps>

00102142 <vector75>:
.globl vector75
vector75:
  pushl $0
  102142:	6a 00                	push   $0x0
  pushl $75
  102144:	6a 4b                	push   $0x4b
  jmp __alltraps
  102146:	e9 42 fd ff ff       	jmp    101e8d <__alltraps>

0010214b <vector76>:
.globl vector76
vector76:
  pushl $0
  10214b:	6a 00                	push   $0x0
  pushl $76
  10214d:	6a 4c                	push   $0x4c
  jmp __alltraps
  10214f:	e9 39 fd ff ff       	jmp    101e8d <__alltraps>

00102154 <vector77>:
.globl vector77
vector77:
  pushl $0
  102154:	6a 00                	push   $0x0
  pushl $77
  102156:	6a 4d                	push   $0x4d
  jmp __alltraps
  102158:	e9 30 fd ff ff       	jmp    101e8d <__alltraps>

0010215d <vector78>:
.globl vector78
vector78:
  pushl $0
  10215d:	6a 00                	push   $0x0
  pushl $78
  10215f:	6a 4e                	push   $0x4e
  jmp __alltraps
  102161:	e9 27 fd ff ff       	jmp    101e8d <__alltraps>

00102166 <vector79>:
.globl vector79
vector79:
  pushl $0
  102166:	6a 00                	push   $0x0
  pushl $79
  102168:	6a 4f                	push   $0x4f
  jmp __alltraps
  10216a:	e9 1e fd ff ff       	jmp    101e8d <__alltraps>

0010216f <vector80>:
.globl vector80
vector80:
  pushl $0
  10216f:	6a 00                	push   $0x0
  pushl $80
  102171:	6a 50                	push   $0x50
  jmp __alltraps
  102173:	e9 15 fd ff ff       	jmp    101e8d <__alltraps>

00102178 <vector81>:
.globl vector81
vector81:
  pushl $0
  102178:	6a 00                	push   $0x0
  pushl $81
  10217a:	6a 51                	push   $0x51
  jmp __alltraps
  10217c:	e9 0c fd ff ff       	jmp    101e8d <__alltraps>

00102181 <vector82>:
.globl vector82
vector82:
  pushl $0
  102181:	6a 00                	push   $0x0
  pushl $82
  102183:	6a 52                	push   $0x52
  jmp __alltraps
  102185:	e9 03 fd ff ff       	jmp    101e8d <__alltraps>

0010218a <vector83>:
.globl vector83
vector83:
  pushl $0
  10218a:	6a 00                	push   $0x0
  pushl $83
  10218c:	6a 53                	push   $0x53
  jmp __alltraps
  10218e:	e9 fa fc ff ff       	jmp    101e8d <__alltraps>

00102193 <vector84>:
.globl vector84
vector84:
  pushl $0
  102193:	6a 00                	push   $0x0
  pushl $84
  102195:	6a 54                	push   $0x54
  jmp __alltraps
  102197:	e9 f1 fc ff ff       	jmp    101e8d <__alltraps>

0010219c <vector85>:
.globl vector85
vector85:
  pushl $0
  10219c:	6a 00                	push   $0x0
  pushl $85
  10219e:	6a 55                	push   $0x55
  jmp __alltraps
  1021a0:	e9 e8 fc ff ff       	jmp    101e8d <__alltraps>

001021a5 <vector86>:
.globl vector86
vector86:
  pushl $0
  1021a5:	6a 00                	push   $0x0
  pushl $86
  1021a7:	6a 56                	push   $0x56
  jmp __alltraps
  1021a9:	e9 df fc ff ff       	jmp    101e8d <__alltraps>

001021ae <vector87>:
.globl vector87
vector87:
  pushl $0
  1021ae:	6a 00                	push   $0x0
  pushl $87
  1021b0:	6a 57                	push   $0x57
  jmp __alltraps
  1021b2:	e9 d6 fc ff ff       	jmp    101e8d <__alltraps>

001021b7 <vector88>:
.globl vector88
vector88:
  pushl $0
  1021b7:	6a 00                	push   $0x0
  pushl $88
  1021b9:	6a 58                	push   $0x58
  jmp __alltraps
  1021bb:	e9 cd fc ff ff       	jmp    101e8d <__alltraps>

001021c0 <vector89>:
.globl vector89
vector89:
  pushl $0
  1021c0:	6a 00                	push   $0x0
  pushl $89
  1021c2:	6a 59                	push   $0x59
  jmp __alltraps
  1021c4:	e9 c4 fc ff ff       	jmp    101e8d <__alltraps>

001021c9 <vector90>:
.globl vector90
vector90:
  pushl $0
  1021c9:	6a 00                	push   $0x0
  pushl $90
  1021cb:	6a 5a                	push   $0x5a
  jmp __alltraps
  1021cd:	e9 bb fc ff ff       	jmp    101e8d <__alltraps>

001021d2 <vector91>:
.globl vector91
vector91:
  pushl $0
  1021d2:	6a 00                	push   $0x0
  pushl $91
  1021d4:	6a 5b                	push   $0x5b
  jmp __alltraps
  1021d6:	e9 b2 fc ff ff       	jmp    101e8d <__alltraps>

001021db <vector92>:
.globl vector92
vector92:
  pushl $0
  1021db:	6a 00                	push   $0x0
  pushl $92
  1021dd:	6a 5c                	push   $0x5c
  jmp __alltraps
  1021df:	e9 a9 fc ff ff       	jmp    101e8d <__alltraps>

001021e4 <vector93>:
.globl vector93
vector93:
  pushl $0
  1021e4:	6a 00                	push   $0x0
  pushl $93
  1021e6:	6a 5d                	push   $0x5d
  jmp __alltraps
  1021e8:	e9 a0 fc ff ff       	jmp    101e8d <__alltraps>

001021ed <vector94>:
.globl vector94
vector94:
  pushl $0
  1021ed:	6a 00                	push   $0x0
  pushl $94
  1021ef:	6a 5e                	push   $0x5e
  jmp __alltraps
  1021f1:	e9 97 fc ff ff       	jmp    101e8d <__alltraps>

001021f6 <vector95>:
.globl vector95
vector95:
  pushl $0
  1021f6:	6a 00                	push   $0x0
  pushl $95
  1021f8:	6a 5f                	push   $0x5f
  jmp __alltraps
  1021fa:	e9 8e fc ff ff       	jmp    101e8d <__alltraps>

001021ff <vector96>:
.globl vector96
vector96:
  pushl $0
  1021ff:	6a 00                	push   $0x0
  pushl $96
  102201:	6a 60                	push   $0x60
  jmp __alltraps
  102203:	e9 85 fc ff ff       	jmp    101e8d <__alltraps>

00102208 <vector97>:
.globl vector97
vector97:
  pushl $0
  102208:	6a 00                	push   $0x0
  pushl $97
  10220a:	6a 61                	push   $0x61
  jmp __alltraps
  10220c:	e9 7c fc ff ff       	jmp    101e8d <__alltraps>

00102211 <vector98>:
.globl vector98
vector98:
  pushl $0
  102211:	6a 00                	push   $0x0
  pushl $98
  102213:	6a 62                	push   $0x62
  jmp __alltraps
  102215:	e9 73 fc ff ff       	jmp    101e8d <__alltraps>

0010221a <vector99>:
.globl vector99
vector99:
  pushl $0
  10221a:	6a 00                	push   $0x0
  pushl $99
  10221c:	6a 63                	push   $0x63
  jmp __alltraps
  10221e:	e9 6a fc ff ff       	jmp    101e8d <__alltraps>

00102223 <vector100>:
.globl vector100
vector100:
  pushl $0
  102223:	6a 00                	push   $0x0
  pushl $100
  102225:	6a 64                	push   $0x64
  jmp __alltraps
  102227:	e9 61 fc ff ff       	jmp    101e8d <__alltraps>

0010222c <vector101>:
.globl vector101
vector101:
  pushl $0
  10222c:	6a 00                	push   $0x0
  pushl $101
  10222e:	6a 65                	push   $0x65
  jmp __alltraps
  102230:	e9 58 fc ff ff       	jmp    101e8d <__alltraps>

00102235 <vector102>:
.globl vector102
vector102:
  pushl $0
  102235:	6a 00                	push   $0x0
  pushl $102
  102237:	6a 66                	push   $0x66
  jmp __alltraps
  102239:	e9 4f fc ff ff       	jmp    101e8d <__alltraps>

0010223e <vector103>:
.globl vector103
vector103:
  pushl $0
  10223e:	6a 00                	push   $0x0
  pushl $103
  102240:	6a 67                	push   $0x67
  jmp __alltraps
  102242:	e9 46 fc ff ff       	jmp    101e8d <__alltraps>

00102247 <vector104>:
.globl vector104
vector104:
  pushl $0
  102247:	6a 00                	push   $0x0
  pushl $104
  102249:	6a 68                	push   $0x68
  jmp __alltraps
  10224b:	e9 3d fc ff ff       	jmp    101e8d <__alltraps>

00102250 <vector105>:
.globl vector105
vector105:
  pushl $0
  102250:	6a 00                	push   $0x0
  pushl $105
  102252:	6a 69                	push   $0x69
  jmp __alltraps
  102254:	e9 34 fc ff ff       	jmp    101e8d <__alltraps>

00102259 <vector106>:
.globl vector106
vector106:
  pushl $0
  102259:	6a 00                	push   $0x0
  pushl $106
  10225b:	6a 6a                	push   $0x6a
  jmp __alltraps
  10225d:	e9 2b fc ff ff       	jmp    101e8d <__alltraps>

00102262 <vector107>:
.globl vector107
vector107:
  pushl $0
  102262:	6a 00                	push   $0x0
  pushl $107
  102264:	6a 6b                	push   $0x6b
  jmp __alltraps
  102266:	e9 22 fc ff ff       	jmp    101e8d <__alltraps>

0010226b <vector108>:
.globl vector108
vector108:
  pushl $0
  10226b:	6a 00                	push   $0x0
  pushl $108
  10226d:	6a 6c                	push   $0x6c
  jmp __alltraps
  10226f:	e9 19 fc ff ff       	jmp    101e8d <__alltraps>

00102274 <vector109>:
.globl vector109
vector109:
  pushl $0
  102274:	6a 00                	push   $0x0
  pushl $109
  102276:	6a 6d                	push   $0x6d
  jmp __alltraps
  102278:	e9 10 fc ff ff       	jmp    101e8d <__alltraps>

0010227d <vector110>:
.globl vector110
vector110:
  pushl $0
  10227d:	6a 00                	push   $0x0
  pushl $110
  10227f:	6a 6e                	push   $0x6e
  jmp __alltraps
  102281:	e9 07 fc ff ff       	jmp    101e8d <__alltraps>

00102286 <vector111>:
.globl vector111
vector111:
  pushl $0
  102286:	6a 00                	push   $0x0
  pushl $111
  102288:	6a 6f                	push   $0x6f
  jmp __alltraps
  10228a:	e9 fe fb ff ff       	jmp    101e8d <__alltraps>

0010228f <vector112>:
.globl vector112
vector112:
  pushl $0
  10228f:	6a 00                	push   $0x0
  pushl $112
  102291:	6a 70                	push   $0x70
  jmp __alltraps
  102293:	e9 f5 fb ff ff       	jmp    101e8d <__alltraps>

00102298 <vector113>:
.globl vector113
vector113:
  pushl $0
  102298:	6a 00                	push   $0x0
  pushl $113
  10229a:	6a 71                	push   $0x71
  jmp __alltraps
  10229c:	e9 ec fb ff ff       	jmp    101e8d <__alltraps>

001022a1 <vector114>:
.globl vector114
vector114:
  pushl $0
  1022a1:	6a 00                	push   $0x0
  pushl $114
  1022a3:	6a 72                	push   $0x72
  jmp __alltraps
  1022a5:	e9 e3 fb ff ff       	jmp    101e8d <__alltraps>

001022aa <vector115>:
.globl vector115
vector115:
  pushl $0
  1022aa:	6a 00                	push   $0x0
  pushl $115
  1022ac:	6a 73                	push   $0x73
  jmp __alltraps
  1022ae:	e9 da fb ff ff       	jmp    101e8d <__alltraps>

001022b3 <vector116>:
.globl vector116
vector116:
  pushl $0
  1022b3:	6a 00                	push   $0x0
  pushl $116
  1022b5:	6a 74                	push   $0x74
  jmp __alltraps
  1022b7:	e9 d1 fb ff ff       	jmp    101e8d <__alltraps>

001022bc <vector117>:
.globl vector117
vector117:
  pushl $0
  1022bc:	6a 00                	push   $0x0
  pushl $117
  1022be:	6a 75                	push   $0x75
  jmp __alltraps
  1022c0:	e9 c8 fb ff ff       	jmp    101e8d <__alltraps>

001022c5 <vector118>:
.globl vector118
vector118:
  pushl $0
  1022c5:	6a 00                	push   $0x0
  pushl $118
  1022c7:	6a 76                	push   $0x76
  jmp __alltraps
  1022c9:	e9 bf fb ff ff       	jmp    101e8d <__alltraps>

001022ce <vector119>:
.globl vector119
vector119:
  pushl $0
  1022ce:	6a 00                	push   $0x0
  pushl $119
  1022d0:	6a 77                	push   $0x77
  jmp __alltraps
  1022d2:	e9 b6 fb ff ff       	jmp    101e8d <__alltraps>

001022d7 <vector120>:
.globl vector120
vector120:
  pushl $0
  1022d7:	6a 00                	push   $0x0
  pushl $120
  1022d9:	6a 78                	push   $0x78
  jmp __alltraps
  1022db:	e9 ad fb ff ff       	jmp    101e8d <__alltraps>

001022e0 <vector121>:
.globl vector121
vector121:
  pushl $0
  1022e0:	6a 00                	push   $0x0
  pushl $121
  1022e2:	6a 79                	push   $0x79
  jmp __alltraps
  1022e4:	e9 a4 fb ff ff       	jmp    101e8d <__alltraps>

001022e9 <vector122>:
.globl vector122
vector122:
  pushl $0
  1022e9:	6a 00                	push   $0x0
  pushl $122
  1022eb:	6a 7a                	push   $0x7a
  jmp __alltraps
  1022ed:	e9 9b fb ff ff       	jmp    101e8d <__alltraps>

001022f2 <vector123>:
.globl vector123
vector123:
  pushl $0
  1022f2:	6a 00                	push   $0x0
  pushl $123
  1022f4:	6a 7b                	push   $0x7b
  jmp __alltraps
  1022f6:	e9 92 fb ff ff       	jmp    101e8d <__alltraps>

001022fb <vector124>:
.globl vector124
vector124:
  pushl $0
  1022fb:	6a 00                	push   $0x0
  pushl $124
  1022fd:	6a 7c                	push   $0x7c
  jmp __alltraps
  1022ff:	e9 89 fb ff ff       	jmp    101e8d <__alltraps>

00102304 <vector125>:
.globl vector125
vector125:
  pushl $0
  102304:	6a 00                	push   $0x0
  pushl $125
  102306:	6a 7d                	push   $0x7d
  jmp __alltraps
  102308:	e9 80 fb ff ff       	jmp    101e8d <__alltraps>

0010230d <vector126>:
.globl vector126
vector126:
  pushl $0
  10230d:	6a 00                	push   $0x0
  pushl $126
  10230f:	6a 7e                	push   $0x7e
  jmp __alltraps
  102311:	e9 77 fb ff ff       	jmp    101e8d <__alltraps>

00102316 <vector127>:
.globl vector127
vector127:
  pushl $0
  102316:	6a 00                	push   $0x0
  pushl $127
  102318:	6a 7f                	push   $0x7f
  jmp __alltraps
  10231a:	e9 6e fb ff ff       	jmp    101e8d <__alltraps>

0010231f <vector128>:
.globl vector128
vector128:
  pushl $0
  10231f:	6a 00                	push   $0x0
  pushl $128
  102321:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
  102326:	e9 62 fb ff ff       	jmp    101e8d <__alltraps>

0010232b <vector129>:
.globl vector129
vector129:
  pushl $0
  10232b:	6a 00                	push   $0x0
  pushl $129
  10232d:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
  102332:	e9 56 fb ff ff       	jmp    101e8d <__alltraps>

00102337 <vector130>:
.globl vector130
vector130:
  pushl $0
  102337:	6a 00                	push   $0x0
  pushl $130
  102339:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
  10233e:	e9 4a fb ff ff       	jmp    101e8d <__alltraps>

00102343 <vector131>:
.globl vector131
vector131:
  pushl $0
  102343:	6a 00                	push   $0x0
  pushl $131
  102345:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
  10234a:	e9 3e fb ff ff       	jmp    101e8d <__alltraps>

0010234f <vector132>:
.globl vector132
vector132:
  pushl $0
  10234f:	6a 00                	push   $0x0
  pushl $132
  102351:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
  102356:	e9 32 fb ff ff       	jmp    101e8d <__alltraps>

0010235b <vector133>:
.globl vector133
vector133:
  pushl $0
  10235b:	6a 00                	push   $0x0
  pushl $133
  10235d:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
  102362:	e9 26 fb ff ff       	jmp    101e8d <__alltraps>

00102367 <vector134>:
.globl vector134
vector134:
  pushl $0
  102367:	6a 00                	push   $0x0
  pushl $134
  102369:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
  10236e:	e9 1a fb ff ff       	jmp    101e8d <__alltraps>

00102373 <vector135>:
.globl vector135
vector135:
  pushl $0
  102373:	6a 00                	push   $0x0
  pushl $135
  102375:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
  10237a:	e9 0e fb ff ff       	jmp    101e8d <__alltraps>

0010237f <vector136>:
.globl vector136
vector136:
  pushl $0
  10237f:	6a 00                	push   $0x0
  pushl $136
  102381:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
  102386:	e9 02 fb ff ff       	jmp    101e8d <__alltraps>

0010238b <vector137>:
.globl vector137
vector137:
  pushl $0
  10238b:	6a 00                	push   $0x0
  pushl $137
  10238d:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
  102392:	e9 f6 fa ff ff       	jmp    101e8d <__alltraps>

00102397 <vector138>:
.globl vector138
vector138:
  pushl $0
  102397:	6a 00                	push   $0x0
  pushl $138
  102399:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
  10239e:	e9 ea fa ff ff       	jmp    101e8d <__alltraps>

001023a3 <vector139>:
.globl vector139
vector139:
  pushl $0
  1023a3:	6a 00                	push   $0x0
  pushl $139
  1023a5:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
  1023aa:	e9 de fa ff ff       	jmp    101e8d <__alltraps>

001023af <vector140>:
.globl vector140
vector140:
  pushl $0
  1023af:	6a 00                	push   $0x0
  pushl $140
  1023b1:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
  1023b6:	e9 d2 fa ff ff       	jmp    101e8d <__alltraps>

001023bb <vector141>:
.globl vector141
vector141:
  pushl $0
  1023bb:	6a 00                	push   $0x0
  pushl $141
  1023bd:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
  1023c2:	e9 c6 fa ff ff       	jmp    101e8d <__alltraps>

001023c7 <vector142>:
.globl vector142
vector142:
  pushl $0
  1023c7:	6a 00                	push   $0x0
  pushl $142
  1023c9:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
  1023ce:	e9 ba fa ff ff       	jmp    101e8d <__alltraps>

001023d3 <vector143>:
.globl vector143
vector143:
  pushl $0
  1023d3:	6a 00                	push   $0x0
  pushl $143
  1023d5:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
  1023da:	e9 ae fa ff ff       	jmp    101e8d <__alltraps>

001023df <vector144>:
.globl vector144
vector144:
  pushl $0
  1023df:	6a 00                	push   $0x0
  pushl $144
  1023e1:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
  1023e6:	e9 a2 fa ff ff       	jmp    101e8d <__alltraps>

001023eb <vector145>:
.globl vector145
vector145:
  pushl $0
  1023eb:	6a 00                	push   $0x0
  pushl $145
  1023ed:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
  1023f2:	e9 96 fa ff ff       	jmp    101e8d <__alltraps>

001023f7 <vector146>:
.globl vector146
vector146:
  pushl $0
  1023f7:	6a 00                	push   $0x0
  pushl $146
  1023f9:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
  1023fe:	e9 8a fa ff ff       	jmp    101e8d <__alltraps>

00102403 <vector147>:
.globl vector147
vector147:
  pushl $0
  102403:	6a 00                	push   $0x0
  pushl $147
  102405:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
  10240a:	e9 7e fa ff ff       	jmp    101e8d <__alltraps>

0010240f <vector148>:
.globl vector148
vector148:
  pushl $0
  10240f:	6a 00                	push   $0x0
  pushl $148
  102411:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
  102416:	e9 72 fa ff ff       	jmp    101e8d <__alltraps>

0010241b <vector149>:
.globl vector149
vector149:
  pushl $0
  10241b:	6a 00                	push   $0x0
  pushl $149
  10241d:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
  102422:	e9 66 fa ff ff       	jmp    101e8d <__alltraps>

00102427 <vector150>:
.globl vector150
vector150:
  pushl $0
  102427:	6a 00                	push   $0x0
  pushl $150
  102429:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
  10242e:	e9 5a fa ff ff       	jmp    101e8d <__alltraps>

00102433 <vector151>:
.globl vector151
vector151:
  pushl $0
  102433:	6a 00                	push   $0x0
  pushl $151
  102435:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
  10243a:	e9 4e fa ff ff       	jmp    101e8d <__alltraps>

0010243f <vector152>:
.globl vector152
vector152:
  pushl $0
  10243f:	6a 00                	push   $0x0
  pushl $152
  102441:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
  102446:	e9 42 fa ff ff       	jmp    101e8d <__alltraps>

0010244b <vector153>:
.globl vector153
vector153:
  pushl $0
  10244b:	6a 00                	push   $0x0
  pushl $153
  10244d:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
  102452:	e9 36 fa ff ff       	jmp    101e8d <__alltraps>

00102457 <vector154>:
.globl vector154
vector154:
  pushl $0
  102457:	6a 00                	push   $0x0
  pushl $154
  102459:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
  10245e:	e9 2a fa ff ff       	jmp    101e8d <__alltraps>

00102463 <vector155>:
.globl vector155
vector155:
  pushl $0
  102463:	6a 00                	push   $0x0
  pushl $155
  102465:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
  10246a:	e9 1e fa ff ff       	jmp    101e8d <__alltraps>

0010246f <vector156>:
.globl vector156
vector156:
  pushl $0
  10246f:	6a 00                	push   $0x0
  pushl $156
  102471:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
  102476:	e9 12 fa ff ff       	jmp    101e8d <__alltraps>

0010247b <vector157>:
.globl vector157
vector157:
  pushl $0
  10247b:	6a 00                	push   $0x0
  pushl $157
  10247d:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
  102482:	e9 06 fa ff ff       	jmp    101e8d <__alltraps>

00102487 <vector158>:
.globl vector158
vector158:
  pushl $0
  102487:	6a 00                	push   $0x0
  pushl $158
  102489:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
  10248e:	e9 fa f9 ff ff       	jmp    101e8d <__alltraps>

00102493 <vector159>:
.globl vector159
vector159:
  pushl $0
  102493:	6a 00                	push   $0x0
  pushl $159
  102495:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
  10249a:	e9 ee f9 ff ff       	jmp    101e8d <__alltraps>

0010249f <vector160>:
.globl vector160
vector160:
  pushl $0
  10249f:	6a 00                	push   $0x0
  pushl $160
  1024a1:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
  1024a6:	e9 e2 f9 ff ff       	jmp    101e8d <__alltraps>

001024ab <vector161>:
.globl vector161
vector161:
  pushl $0
  1024ab:	6a 00                	push   $0x0
  pushl $161
  1024ad:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
  1024b2:	e9 d6 f9 ff ff       	jmp    101e8d <__alltraps>

001024b7 <vector162>:
.globl vector162
vector162:
  pushl $0
  1024b7:	6a 00                	push   $0x0
  pushl $162
  1024b9:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
  1024be:	e9 ca f9 ff ff       	jmp    101e8d <__alltraps>

001024c3 <vector163>:
.globl vector163
vector163:
  pushl $0
  1024c3:	6a 00                	push   $0x0
  pushl $163
  1024c5:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
  1024ca:	e9 be f9 ff ff       	jmp    101e8d <__alltraps>

001024cf <vector164>:
.globl vector164
vector164:
  pushl $0
  1024cf:	6a 00                	push   $0x0
  pushl $164
  1024d1:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
  1024d6:	e9 b2 f9 ff ff       	jmp    101e8d <__alltraps>

001024db <vector165>:
.globl vector165
vector165:
  pushl $0
  1024db:	6a 00                	push   $0x0
  pushl $165
  1024dd:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
  1024e2:	e9 a6 f9 ff ff       	jmp    101e8d <__alltraps>

001024e7 <vector166>:
.globl vector166
vector166:
  pushl $0
  1024e7:	6a 00                	push   $0x0
  pushl $166
  1024e9:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
  1024ee:	e9 9a f9 ff ff       	jmp    101e8d <__alltraps>

001024f3 <vector167>:
.globl vector167
vector167:
  pushl $0
  1024f3:	6a 00                	push   $0x0
  pushl $167
  1024f5:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
  1024fa:	e9 8e f9 ff ff       	jmp    101e8d <__alltraps>

001024ff <vector168>:
.globl vector168
vector168:
  pushl $0
  1024ff:	6a 00                	push   $0x0
  pushl $168
  102501:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
  102506:	e9 82 f9 ff ff       	jmp    101e8d <__alltraps>

0010250b <vector169>:
.globl vector169
vector169:
  pushl $0
  10250b:	6a 00                	push   $0x0
  pushl $169
  10250d:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
  102512:	e9 76 f9 ff ff       	jmp    101e8d <__alltraps>

00102517 <vector170>:
.globl vector170
vector170:
  pushl $0
  102517:	6a 00                	push   $0x0
  pushl $170
  102519:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
  10251e:	e9 6a f9 ff ff       	jmp    101e8d <__alltraps>

00102523 <vector171>:
.globl vector171
vector171:
  pushl $0
  102523:	6a 00                	push   $0x0
  pushl $171
  102525:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
  10252a:	e9 5e f9 ff ff       	jmp    101e8d <__alltraps>

0010252f <vector172>:
.globl vector172
vector172:
  pushl $0
  10252f:	6a 00                	push   $0x0
  pushl $172
  102531:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
  102536:	e9 52 f9 ff ff       	jmp    101e8d <__alltraps>

0010253b <vector173>:
.globl vector173
vector173:
  pushl $0
  10253b:	6a 00                	push   $0x0
  pushl $173
  10253d:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
  102542:	e9 46 f9 ff ff       	jmp    101e8d <__alltraps>

00102547 <vector174>:
.globl vector174
vector174:
  pushl $0
  102547:	6a 00                	push   $0x0
  pushl $174
  102549:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
  10254e:	e9 3a f9 ff ff       	jmp    101e8d <__alltraps>

00102553 <vector175>:
.globl vector175
vector175:
  pushl $0
  102553:	6a 00                	push   $0x0
  pushl $175
  102555:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
  10255a:	e9 2e f9 ff ff       	jmp    101e8d <__alltraps>

0010255f <vector176>:
.globl vector176
vector176:
  pushl $0
  10255f:	6a 00                	push   $0x0
  pushl $176
  102561:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
  102566:	e9 22 f9 ff ff       	jmp    101e8d <__alltraps>

0010256b <vector177>:
.globl vector177
vector177:
  pushl $0
  10256b:	6a 00                	push   $0x0
  pushl $177
  10256d:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
  102572:	e9 16 f9 ff ff       	jmp    101e8d <__alltraps>

00102577 <vector178>:
.globl vector178
vector178:
  pushl $0
  102577:	6a 00                	push   $0x0
  pushl $178
  102579:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
  10257e:	e9 0a f9 ff ff       	jmp    101e8d <__alltraps>

00102583 <vector179>:
.globl vector179
vector179:
  pushl $0
  102583:	6a 00                	push   $0x0
  pushl $179
  102585:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
  10258a:	e9 fe f8 ff ff       	jmp    101e8d <__alltraps>

0010258f <vector180>:
.globl vector180
vector180:
  pushl $0
  10258f:	6a 00                	push   $0x0
  pushl $180
  102591:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
  102596:	e9 f2 f8 ff ff       	jmp    101e8d <__alltraps>

0010259b <vector181>:
.globl vector181
vector181:
  pushl $0
  10259b:	6a 00                	push   $0x0
  pushl $181
  10259d:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
  1025a2:	e9 e6 f8 ff ff       	jmp    101e8d <__alltraps>

001025a7 <vector182>:
.globl vector182
vector182:
  pushl $0
  1025a7:	6a 00                	push   $0x0
  pushl $182
  1025a9:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
  1025ae:	e9 da f8 ff ff       	jmp    101e8d <__alltraps>

001025b3 <vector183>:
.globl vector183
vector183:
  pushl $0
  1025b3:	6a 00                	push   $0x0
  pushl $183
  1025b5:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
  1025ba:	e9 ce f8 ff ff       	jmp    101e8d <__alltraps>

001025bf <vector184>:
.globl vector184
vector184:
  pushl $0
  1025bf:	6a 00                	push   $0x0
  pushl $184
  1025c1:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
  1025c6:	e9 c2 f8 ff ff       	jmp    101e8d <__alltraps>

001025cb <vector185>:
.globl vector185
vector185:
  pushl $0
  1025cb:	6a 00                	push   $0x0
  pushl $185
  1025cd:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
  1025d2:	e9 b6 f8 ff ff       	jmp    101e8d <__alltraps>

001025d7 <vector186>:
.globl vector186
vector186:
  pushl $0
  1025d7:	6a 00                	push   $0x0
  pushl $186
  1025d9:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
  1025de:	e9 aa f8 ff ff       	jmp    101e8d <__alltraps>

001025e3 <vector187>:
.globl vector187
vector187:
  pushl $0
  1025e3:	6a 00                	push   $0x0
  pushl $187
  1025e5:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
  1025ea:	e9 9e f8 ff ff       	jmp    101e8d <__alltraps>

001025ef <vector188>:
.globl vector188
vector188:
  pushl $0
  1025ef:	6a 00                	push   $0x0
  pushl $188
  1025f1:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
  1025f6:	e9 92 f8 ff ff       	jmp    101e8d <__alltraps>

001025fb <vector189>:
.globl vector189
vector189:
  pushl $0
  1025fb:	6a 00                	push   $0x0
  pushl $189
  1025fd:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
  102602:	e9 86 f8 ff ff       	jmp    101e8d <__alltraps>

00102607 <vector190>:
.globl vector190
vector190:
  pushl $0
  102607:	6a 00                	push   $0x0
  pushl $190
  102609:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
  10260e:	e9 7a f8 ff ff       	jmp    101e8d <__alltraps>

00102613 <vector191>:
.globl vector191
vector191:
  pushl $0
  102613:	6a 00                	push   $0x0
  pushl $191
  102615:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
  10261a:	e9 6e f8 ff ff       	jmp    101e8d <__alltraps>

0010261f <vector192>:
.globl vector192
vector192:
  pushl $0
  10261f:	6a 00                	push   $0x0
  pushl $192
  102621:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
  102626:	e9 62 f8 ff ff       	jmp    101e8d <__alltraps>

0010262b <vector193>:
.globl vector193
vector193:
  pushl $0
  10262b:	6a 00                	push   $0x0
  pushl $193
  10262d:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
  102632:	e9 56 f8 ff ff       	jmp    101e8d <__alltraps>

00102637 <vector194>:
.globl vector194
vector194:
  pushl $0
  102637:	6a 00                	push   $0x0
  pushl $194
  102639:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
  10263e:	e9 4a f8 ff ff       	jmp    101e8d <__alltraps>

00102643 <vector195>:
.globl vector195
vector195:
  pushl $0
  102643:	6a 00                	push   $0x0
  pushl $195
  102645:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
  10264a:	e9 3e f8 ff ff       	jmp    101e8d <__alltraps>

0010264f <vector196>:
.globl vector196
vector196:
  pushl $0
  10264f:	6a 00                	push   $0x0
  pushl $196
  102651:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
  102656:	e9 32 f8 ff ff       	jmp    101e8d <__alltraps>

0010265b <vector197>:
.globl vector197
vector197:
  pushl $0
  10265b:	6a 00                	push   $0x0
  pushl $197
  10265d:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
  102662:	e9 26 f8 ff ff       	jmp    101e8d <__alltraps>

00102667 <vector198>:
.globl vector198
vector198:
  pushl $0
  102667:	6a 00                	push   $0x0
  pushl $198
  102669:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
  10266e:	e9 1a f8 ff ff       	jmp    101e8d <__alltraps>

00102673 <vector199>:
.globl vector199
vector199:
  pushl $0
  102673:	6a 00                	push   $0x0
  pushl $199
  102675:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
  10267a:	e9 0e f8 ff ff       	jmp    101e8d <__alltraps>

0010267f <vector200>:
.globl vector200
vector200:
  pushl $0
  10267f:	6a 00                	push   $0x0
  pushl $200
  102681:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
  102686:	e9 02 f8 ff ff       	jmp    101e8d <__alltraps>

0010268b <vector201>:
.globl vector201
vector201:
  pushl $0
  10268b:	6a 00                	push   $0x0
  pushl $201
  10268d:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
  102692:	e9 f6 f7 ff ff       	jmp    101e8d <__alltraps>

00102697 <vector202>:
.globl vector202
vector202:
  pushl $0
  102697:	6a 00                	push   $0x0
  pushl $202
  102699:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
  10269e:	e9 ea f7 ff ff       	jmp    101e8d <__alltraps>

001026a3 <vector203>:
.globl vector203
vector203:
  pushl $0
  1026a3:	6a 00                	push   $0x0
  pushl $203
  1026a5:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
  1026aa:	e9 de f7 ff ff       	jmp    101e8d <__alltraps>

001026af <vector204>:
.globl vector204
vector204:
  pushl $0
  1026af:	6a 00                	push   $0x0
  pushl $204
  1026b1:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
  1026b6:	e9 d2 f7 ff ff       	jmp    101e8d <__alltraps>

001026bb <vector205>:
.globl vector205
vector205:
  pushl $0
  1026bb:	6a 00                	push   $0x0
  pushl $205
  1026bd:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
  1026c2:	e9 c6 f7 ff ff       	jmp    101e8d <__alltraps>

001026c7 <vector206>:
.globl vector206
vector206:
  pushl $0
  1026c7:	6a 00                	push   $0x0
  pushl $206
  1026c9:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
  1026ce:	e9 ba f7 ff ff       	jmp    101e8d <__alltraps>

001026d3 <vector207>:
.globl vector207
vector207:
  pushl $0
  1026d3:	6a 00                	push   $0x0
  pushl $207
  1026d5:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
  1026da:	e9 ae f7 ff ff       	jmp    101e8d <__alltraps>

001026df <vector208>:
.globl vector208
vector208:
  pushl $0
  1026df:	6a 00                	push   $0x0
  pushl $208
  1026e1:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
  1026e6:	e9 a2 f7 ff ff       	jmp    101e8d <__alltraps>

001026eb <vector209>:
.globl vector209
vector209:
  pushl $0
  1026eb:	6a 00                	push   $0x0
  pushl $209
  1026ed:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
  1026f2:	e9 96 f7 ff ff       	jmp    101e8d <__alltraps>

001026f7 <vector210>:
.globl vector210
vector210:
  pushl $0
  1026f7:	6a 00                	push   $0x0
  pushl $210
  1026f9:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
  1026fe:	e9 8a f7 ff ff       	jmp    101e8d <__alltraps>

00102703 <vector211>:
.globl vector211
vector211:
  pushl $0
  102703:	6a 00                	push   $0x0
  pushl $211
  102705:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
  10270a:	e9 7e f7 ff ff       	jmp    101e8d <__alltraps>

0010270f <vector212>:
.globl vector212
vector212:
  pushl $0
  10270f:	6a 00                	push   $0x0
  pushl $212
  102711:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
  102716:	e9 72 f7 ff ff       	jmp    101e8d <__alltraps>

0010271b <vector213>:
.globl vector213
vector213:
  pushl $0
  10271b:	6a 00                	push   $0x0
  pushl $213
  10271d:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
  102722:	e9 66 f7 ff ff       	jmp    101e8d <__alltraps>

00102727 <vector214>:
.globl vector214
vector214:
  pushl $0
  102727:	6a 00                	push   $0x0
  pushl $214
  102729:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
  10272e:	e9 5a f7 ff ff       	jmp    101e8d <__alltraps>

00102733 <vector215>:
.globl vector215
vector215:
  pushl $0
  102733:	6a 00                	push   $0x0
  pushl $215
  102735:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
  10273a:	e9 4e f7 ff ff       	jmp    101e8d <__alltraps>

0010273f <vector216>:
.globl vector216
vector216:
  pushl $0
  10273f:	6a 00                	push   $0x0
  pushl $216
  102741:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
  102746:	e9 42 f7 ff ff       	jmp    101e8d <__alltraps>

0010274b <vector217>:
.globl vector217
vector217:
  pushl $0
  10274b:	6a 00                	push   $0x0
  pushl $217
  10274d:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
  102752:	e9 36 f7 ff ff       	jmp    101e8d <__alltraps>

00102757 <vector218>:
.globl vector218
vector218:
  pushl $0
  102757:	6a 00                	push   $0x0
  pushl $218
  102759:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
  10275e:	e9 2a f7 ff ff       	jmp    101e8d <__alltraps>

00102763 <vector219>:
.globl vector219
vector219:
  pushl $0
  102763:	6a 00                	push   $0x0
  pushl $219
  102765:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
  10276a:	e9 1e f7 ff ff       	jmp    101e8d <__alltraps>

0010276f <vector220>:
.globl vector220
vector220:
  pushl $0
  10276f:	6a 00                	push   $0x0
  pushl $220
  102771:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
  102776:	e9 12 f7 ff ff       	jmp    101e8d <__alltraps>

0010277b <vector221>:
.globl vector221
vector221:
  pushl $0
  10277b:	6a 00                	push   $0x0
  pushl $221
  10277d:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
  102782:	e9 06 f7 ff ff       	jmp    101e8d <__alltraps>

00102787 <vector222>:
.globl vector222
vector222:
  pushl $0
  102787:	6a 00                	push   $0x0
  pushl $222
  102789:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
  10278e:	e9 fa f6 ff ff       	jmp    101e8d <__alltraps>

00102793 <vector223>:
.globl vector223
vector223:
  pushl $0
  102793:	6a 00                	push   $0x0
  pushl $223
  102795:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
  10279a:	e9 ee f6 ff ff       	jmp    101e8d <__alltraps>

0010279f <vector224>:
.globl vector224
vector224:
  pushl $0
  10279f:	6a 00                	push   $0x0
  pushl $224
  1027a1:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
  1027a6:	e9 e2 f6 ff ff       	jmp    101e8d <__alltraps>

001027ab <vector225>:
.globl vector225
vector225:
  pushl $0
  1027ab:	6a 00                	push   $0x0
  pushl $225
  1027ad:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
  1027b2:	e9 d6 f6 ff ff       	jmp    101e8d <__alltraps>

001027b7 <vector226>:
.globl vector226
vector226:
  pushl $0
  1027b7:	6a 00                	push   $0x0
  pushl $226
  1027b9:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
  1027be:	e9 ca f6 ff ff       	jmp    101e8d <__alltraps>

001027c3 <vector227>:
.globl vector227
vector227:
  pushl $0
  1027c3:	6a 00                	push   $0x0
  pushl $227
  1027c5:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
  1027ca:	e9 be f6 ff ff       	jmp    101e8d <__alltraps>

001027cf <vector228>:
.globl vector228
vector228:
  pushl $0
  1027cf:	6a 00                	push   $0x0
  pushl $228
  1027d1:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
  1027d6:	e9 b2 f6 ff ff       	jmp    101e8d <__alltraps>

001027db <vector229>:
.globl vector229
vector229:
  pushl $0
  1027db:	6a 00                	push   $0x0
  pushl $229
  1027dd:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
  1027e2:	e9 a6 f6 ff ff       	jmp    101e8d <__alltraps>

001027e7 <vector230>:
.globl vector230
vector230:
  pushl $0
  1027e7:	6a 00                	push   $0x0
  pushl $230
  1027e9:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
  1027ee:	e9 9a f6 ff ff       	jmp    101e8d <__alltraps>

001027f3 <vector231>:
.globl vector231
vector231:
  pushl $0
  1027f3:	6a 00                	push   $0x0
  pushl $231
  1027f5:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
  1027fa:	e9 8e f6 ff ff       	jmp    101e8d <__alltraps>

001027ff <vector232>:
.globl vector232
vector232:
  pushl $0
  1027ff:	6a 00                	push   $0x0
  pushl $232
  102801:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
  102806:	e9 82 f6 ff ff       	jmp    101e8d <__alltraps>

0010280b <vector233>:
.globl vector233
vector233:
  pushl $0
  10280b:	6a 00                	push   $0x0
  pushl $233
  10280d:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
  102812:	e9 76 f6 ff ff       	jmp    101e8d <__alltraps>

00102817 <vector234>:
.globl vector234
vector234:
  pushl $0
  102817:	6a 00                	push   $0x0
  pushl $234
  102819:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
  10281e:	e9 6a f6 ff ff       	jmp    101e8d <__alltraps>

00102823 <vector235>:
.globl vector235
vector235:
  pushl $0
  102823:	6a 00                	push   $0x0
  pushl $235
  102825:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
  10282a:	e9 5e f6 ff ff       	jmp    101e8d <__alltraps>

0010282f <vector236>:
.globl vector236
vector236:
  pushl $0
  10282f:	6a 00                	push   $0x0
  pushl $236
  102831:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
  102836:	e9 52 f6 ff ff       	jmp    101e8d <__alltraps>

0010283b <vector237>:
.globl vector237
vector237:
  pushl $0
  10283b:	6a 00                	push   $0x0
  pushl $237
  10283d:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
  102842:	e9 46 f6 ff ff       	jmp    101e8d <__alltraps>

00102847 <vector238>:
.globl vector238
vector238:
  pushl $0
  102847:	6a 00                	push   $0x0
  pushl $238
  102849:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
  10284e:	e9 3a f6 ff ff       	jmp    101e8d <__alltraps>

00102853 <vector239>:
.globl vector239
vector239:
  pushl $0
  102853:	6a 00                	push   $0x0
  pushl $239
  102855:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
  10285a:	e9 2e f6 ff ff       	jmp    101e8d <__alltraps>

0010285f <vector240>:
.globl vector240
vector240:
  pushl $0
  10285f:	6a 00                	push   $0x0
  pushl $240
  102861:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
  102866:	e9 22 f6 ff ff       	jmp    101e8d <__alltraps>

0010286b <vector241>:
.globl vector241
vector241:
  pushl $0
  10286b:	6a 00                	push   $0x0
  pushl $241
  10286d:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
  102872:	e9 16 f6 ff ff       	jmp    101e8d <__alltraps>

00102877 <vector242>:
.globl vector242
vector242:
  pushl $0
  102877:	6a 00                	push   $0x0
  pushl $242
  102879:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
  10287e:	e9 0a f6 ff ff       	jmp    101e8d <__alltraps>

00102883 <vector243>:
.globl vector243
vector243:
  pushl $0
  102883:	6a 00                	push   $0x0
  pushl $243
  102885:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
  10288a:	e9 fe f5 ff ff       	jmp    101e8d <__alltraps>

0010288f <vector244>:
.globl vector244
vector244:
  pushl $0
  10288f:	6a 00                	push   $0x0
  pushl $244
  102891:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
  102896:	e9 f2 f5 ff ff       	jmp    101e8d <__alltraps>

0010289b <vector245>:
.globl vector245
vector245:
  pushl $0
  10289b:	6a 00                	push   $0x0
  pushl $245
  10289d:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
  1028a2:	e9 e6 f5 ff ff       	jmp    101e8d <__alltraps>

001028a7 <vector246>:
.globl vector246
vector246:
  pushl $0
  1028a7:	6a 00                	push   $0x0
  pushl $246
  1028a9:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
  1028ae:	e9 da f5 ff ff       	jmp    101e8d <__alltraps>

001028b3 <vector247>:
.globl vector247
vector247:
  pushl $0
  1028b3:	6a 00                	push   $0x0
  pushl $247
  1028b5:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
  1028ba:	e9 ce f5 ff ff       	jmp    101e8d <__alltraps>

001028bf <vector248>:
.globl vector248
vector248:
  pushl $0
  1028bf:	6a 00                	push   $0x0
  pushl $248
  1028c1:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
  1028c6:	e9 c2 f5 ff ff       	jmp    101e8d <__alltraps>

001028cb <vector249>:
.globl vector249
vector249:
  pushl $0
  1028cb:	6a 00                	push   $0x0
  pushl $249
  1028cd:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
  1028d2:	e9 b6 f5 ff ff       	jmp    101e8d <__alltraps>

001028d7 <vector250>:
.globl vector250
vector250:
  pushl $0
  1028d7:	6a 00                	push   $0x0
  pushl $250
  1028d9:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
  1028de:	e9 aa f5 ff ff       	jmp    101e8d <__alltraps>

001028e3 <vector251>:
.globl vector251
vector251:
  pushl $0
  1028e3:	6a 00                	push   $0x0
  pushl $251
  1028e5:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
  1028ea:	e9 9e f5 ff ff       	jmp    101e8d <__alltraps>

001028ef <vector252>:
.globl vector252
vector252:
  pushl $0
  1028ef:	6a 00                	push   $0x0
  pushl $252
  1028f1:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
  1028f6:	e9 92 f5 ff ff       	jmp    101e8d <__alltraps>

001028fb <vector253>:
.globl vector253
vector253:
  pushl $0
  1028fb:	6a 00                	push   $0x0
  pushl $253
  1028fd:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
  102902:	e9 86 f5 ff ff       	jmp    101e8d <__alltraps>

00102907 <vector254>:
.globl vector254
vector254:
  pushl $0
  102907:	6a 00                	push   $0x0
  pushl $254
  102909:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
  10290e:	e9 7a f5 ff ff       	jmp    101e8d <__alltraps>

00102913 <vector255>:
.globl vector255
vector255:
  pushl $0
  102913:	6a 00                	push   $0x0
  pushl $255
  102915:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
  10291a:	e9 6e f5 ff ff       	jmp    101e8d <__alltraps>

0010291f <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
  10291f:	55                   	push   %ebp
  102920:	89 e5                	mov    %esp,%ebp
    return page - pages;
  102922:	8b 55 08             	mov    0x8(%ebp),%edx
  102925:	a1 c4 89 11 00       	mov    0x1189c4,%eax
  10292a:	29 c2                	sub    %eax,%edx
  10292c:	89 d0                	mov    %edx,%eax
  10292e:	c1 f8 02             	sar    $0x2,%eax
  102931:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  102937:	5d                   	pop    %ebp
  102938:	c3                   	ret    

00102939 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
  102939:	55                   	push   %ebp
  10293a:	89 e5                	mov    %esp,%ebp
  10293c:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  10293f:	8b 45 08             	mov    0x8(%ebp),%eax
  102942:	89 04 24             	mov    %eax,(%esp)
  102945:	e8 d5 ff ff ff       	call   10291f <page2ppn>
  10294a:	c1 e0 0c             	shl    $0xc,%eax
}
  10294d:	c9                   	leave  
  10294e:	c3                   	ret    

0010294f <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
  10294f:	55                   	push   %ebp
  102950:	89 e5                	mov    %esp,%ebp
    return page->ref;
  102952:	8b 45 08             	mov    0x8(%ebp),%eax
  102955:	8b 00                	mov    (%eax),%eax
}
  102957:	5d                   	pop    %ebp
  102958:	c3                   	ret    

00102959 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
  102959:	55                   	push   %ebp
  10295a:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  10295c:	8b 45 08             	mov    0x8(%ebp),%eax
  10295f:	8b 55 0c             	mov    0xc(%ebp),%edx
  102962:	89 10                	mov    %edx,(%eax)
}
  102964:	5d                   	pop    %ebp
  102965:	c3                   	ret    

00102966 <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
  102966:	55                   	push   %ebp
  102967:	89 e5                	mov    %esp,%ebp
  102969:	83 ec 10             	sub    $0x10,%esp
  10296c:	c7 45 fc b0 89 11 00 	movl   $0x1189b0,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  102973:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102976:	8b 55 fc             	mov    -0x4(%ebp),%edx
  102979:	89 50 04             	mov    %edx,0x4(%eax)
  10297c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10297f:	8b 50 04             	mov    0x4(%eax),%edx
  102982:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102985:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
  102987:	c7 05 b8 89 11 00 00 	movl   $0x0,0x1189b8
  10298e:	00 00 00 
}
  102991:	c9                   	leave  
  102992:	c3                   	ret    

00102993 <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
  102993:	55                   	push   %ebp
  102994:	89 e5                	mov    %esp,%ebp
  102996:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
  102999:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  10299d:	75 24                	jne    1029c3 <default_init_memmap+0x30>
  10299f:	c7 44 24 0c f0 66 10 	movl   $0x1066f0,0xc(%esp)
  1029a6:	00 
  1029a7:	c7 44 24 08 f6 66 10 	movl   $0x1066f6,0x8(%esp)
  1029ae:	00 
  1029af:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  1029b6:	00 
  1029b7:	c7 04 24 0b 67 10 00 	movl   $0x10670b,(%esp)
  1029be:	e8 0e e3 ff ff       	call   100cd1 <__panic>
    struct Page *p = base;
  1029c3:	8b 45 08             	mov    0x8(%ebp),%eax
  1029c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
  1029c9:	e9 dc 00 00 00       	jmp    102aaa <default_init_memmap+0x117>
        assert(PageReserved(p));
  1029ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1029d1:	83 c0 04             	add    $0x4,%eax
  1029d4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  1029db:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1029de:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1029e1:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1029e4:	0f a3 10             	bt     %edx,(%eax)
  1029e7:	19 c0                	sbb    %eax,%eax
  1029e9:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
  1029ec:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1029f0:	0f 95 c0             	setne  %al
  1029f3:	0f b6 c0             	movzbl %al,%eax
  1029f6:	85 c0                	test   %eax,%eax
  1029f8:	75 24                	jne    102a1e <default_init_memmap+0x8b>
  1029fa:	c7 44 24 0c 21 67 10 	movl   $0x106721,0xc(%esp)
  102a01:	00 
  102a02:	c7 44 24 08 f6 66 10 	movl   $0x1066f6,0x8(%esp)
  102a09:	00 
  102a0a:	c7 44 24 04 49 00 00 	movl   $0x49,0x4(%esp)
  102a11:	00 
  102a12:	c7 04 24 0b 67 10 00 	movl   $0x10670b,(%esp)
  102a19:	e8 b3 e2 ff ff       	call   100cd1 <__panic>
        p->flags = 0;
  102a1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102a21:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        SetPageProperty(p);
  102a28:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102a2b:	83 c0 04             	add    $0x4,%eax
  102a2e:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
  102a35:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102a38:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102a3b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  102a3e:	0f ab 10             	bts    %edx,(%eax)
        p->property = 0;
  102a41:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102a44:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        set_page_ref(p, 0);
  102a4b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  102a52:	00 
  102a53:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102a56:	89 04 24             	mov    %eax,(%esp)
  102a59:	e8 fb fe ff ff       	call   102959 <set_page_ref>
        list_add_before(&free_list, &(p->page_link));
  102a5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102a61:	83 c0 0c             	add    $0xc,%eax
  102a64:	c7 45 dc b0 89 11 00 	movl   $0x1189b0,-0x24(%ebp)
  102a6b:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
  102a6e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102a71:	8b 00                	mov    (%eax),%eax
  102a73:	8b 55 d8             	mov    -0x28(%ebp),%edx
  102a76:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  102a79:	89 45 d0             	mov    %eax,-0x30(%ebp)
  102a7c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102a7f:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  102a82:	8b 45 cc             	mov    -0x34(%ebp),%eax
  102a85:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102a88:	89 10                	mov    %edx,(%eax)
  102a8a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  102a8d:	8b 10                	mov    (%eax),%edx
  102a8f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102a92:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  102a95:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  102a98:	8b 55 cc             	mov    -0x34(%ebp),%edx
  102a9b:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  102a9e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  102aa1:	8b 55 d0             	mov    -0x30(%ebp),%edx
  102aa4:	89 10                	mov    %edx,(%eax)

static void
default_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
  102aa6:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  102aaa:	8b 55 0c             	mov    0xc(%ebp),%edx
  102aad:	89 d0                	mov    %edx,%eax
  102aaf:	c1 e0 02             	shl    $0x2,%eax
  102ab2:	01 d0                	add    %edx,%eax
  102ab4:	c1 e0 02             	shl    $0x2,%eax
  102ab7:	89 c2                	mov    %eax,%edx
  102ab9:	8b 45 08             	mov    0x8(%ebp),%eax
  102abc:	01 d0                	add    %edx,%eax
  102abe:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  102ac1:	0f 85 07 ff ff ff    	jne    1029ce <default_init_memmap+0x3b>
        SetPageProperty(p);
        p->property = 0;
        set_page_ref(p, 0);
        list_add_before(&free_list, &(p->page_link));
    }
    nr_free += n;
  102ac7:	8b 15 b8 89 11 00    	mov    0x1189b8,%edx
  102acd:	8b 45 0c             	mov    0xc(%ebp),%eax
  102ad0:	01 d0                	add    %edx,%eax
  102ad2:	a3 b8 89 11 00       	mov    %eax,0x1189b8
    //first block
    base->property = n;
  102ad7:	8b 45 08             	mov    0x8(%ebp),%eax
  102ada:	8b 55 0c             	mov    0xc(%ebp),%edx
  102add:	89 50 08             	mov    %edx,0x8(%eax)
}
  102ae0:	c9                   	leave  
  102ae1:	c3                   	ret    

00102ae2 <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
  102ae2:	55                   	push   %ebp
  102ae3:	89 e5                	mov    %esp,%ebp
  102ae5:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
  102ae8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  102aec:	75 24                	jne    102b12 <default_alloc_pages+0x30>
  102aee:	c7 44 24 0c f0 66 10 	movl   $0x1066f0,0xc(%esp)
  102af5:	00 
  102af6:	c7 44 24 08 f6 66 10 	movl   $0x1066f6,0x8(%esp)
  102afd:	00 
  102afe:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
  102b05:	00 
  102b06:	c7 04 24 0b 67 10 00 	movl   $0x10670b,(%esp)
  102b0d:	e8 bf e1 ff ff       	call   100cd1 <__panic>
    if (n > nr_free) {
  102b12:	a1 b8 89 11 00       	mov    0x1189b8,%eax
  102b17:	3b 45 08             	cmp    0x8(%ebp),%eax
  102b1a:	73 0a                	jae    102b26 <default_alloc_pages+0x44>
        return NULL;
  102b1c:	b8 00 00 00 00       	mov    $0x0,%eax
  102b21:	e9 37 01 00 00       	jmp    102c5d <default_alloc_pages+0x17b>
    }
    list_entry_t *le, *len;
    le = &free_list;
  102b26:	c7 45 f4 b0 89 11 00 	movl   $0x1189b0,-0xc(%ebp)

    while((le=list_next(le)) != &free_list) {
  102b2d:	e9 0a 01 00 00       	jmp    102c3c <default_alloc_pages+0x15a>
      struct Page *p = le2page(le, page_link);
  102b32:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102b35:	83 e8 0c             	sub    $0xc,%eax
  102b38:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(p->property >= n){
  102b3b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102b3e:	8b 40 08             	mov    0x8(%eax),%eax
  102b41:	3b 45 08             	cmp    0x8(%ebp),%eax
  102b44:	0f 82 f2 00 00 00    	jb     102c3c <default_alloc_pages+0x15a>
        int i;
        for(i=0;i<n;i++){
  102b4a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  102b51:	eb 7c                	jmp    102bcf <default_alloc_pages+0xed>
  102b53:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102b56:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  102b59:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102b5c:	8b 40 04             	mov    0x4(%eax),%eax
          len = list_next(le);
  102b5f:	89 45 e8             	mov    %eax,-0x18(%ebp)
          struct Page *pp = le2page(le, page_link);
  102b62:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102b65:	83 e8 0c             	sub    $0xc,%eax
  102b68:	89 45 e4             	mov    %eax,-0x1c(%ebp)
          SetPageReserved(pp);
  102b6b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  102b6e:	83 c0 04             	add    $0x4,%eax
  102b71:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  102b78:	89 45 d8             	mov    %eax,-0x28(%ebp)
  102b7b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  102b7e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102b81:	0f ab 10             	bts    %edx,(%eax)
          ClearPageProperty(pp);
  102b84:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  102b87:	83 c0 04             	add    $0x4,%eax
  102b8a:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  102b91:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102b94:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102b97:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102b9a:	0f b3 10             	btr    %edx,(%eax)
  102b9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102ba0:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
  102ba3:	8b 45 cc             	mov    -0x34(%ebp),%eax
  102ba6:	8b 40 04             	mov    0x4(%eax),%eax
  102ba9:	8b 55 cc             	mov    -0x34(%ebp),%edx
  102bac:	8b 12                	mov    (%edx),%edx
  102bae:	89 55 c8             	mov    %edx,-0x38(%ebp)
  102bb1:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
  102bb4:	8b 45 c8             	mov    -0x38(%ebp),%eax
  102bb7:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  102bba:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  102bbd:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  102bc0:	8b 55 c8             	mov    -0x38(%ebp),%edx
  102bc3:	89 10                	mov    %edx,(%eax)
          list_del(le);
          le = len;
  102bc5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102bc8:	89 45 f4             	mov    %eax,-0xc(%ebp)

    while((le=list_next(le)) != &free_list) {
      struct Page *p = le2page(le, page_link);
      if(p->property >= n){
        int i;
        for(i=0;i<n;i++){
  102bcb:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
  102bcf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102bd2:	3b 45 08             	cmp    0x8(%ebp),%eax
  102bd5:	0f 82 78 ff ff ff    	jb     102b53 <default_alloc_pages+0x71>
          SetPageReserved(pp);
          ClearPageProperty(pp);
          list_del(le);
          le = len;
        }
        if(p->property>n){
  102bdb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102bde:	8b 40 08             	mov    0x8(%eax),%eax
  102be1:	3b 45 08             	cmp    0x8(%ebp),%eax
  102be4:	76 12                	jbe    102bf8 <default_alloc_pages+0x116>
          (le2page(le,page_link))->property = p->property - n;
  102be6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102be9:	8d 50 f4             	lea    -0xc(%eax),%edx
  102bec:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102bef:	8b 40 08             	mov    0x8(%eax),%eax
  102bf2:	2b 45 08             	sub    0x8(%ebp),%eax
  102bf5:	89 42 08             	mov    %eax,0x8(%edx)
        }
        ClearPageProperty(p);
  102bf8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102bfb:	83 c0 04             	add    $0x4,%eax
  102bfe:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
  102c05:	89 45 bc             	mov    %eax,-0x44(%ebp)
  102c08:	8b 45 bc             	mov    -0x44(%ebp),%eax
  102c0b:	8b 55 c0             	mov    -0x40(%ebp),%edx
  102c0e:	0f b3 10             	btr    %edx,(%eax)
        SetPageReserved(p);
  102c11:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102c14:	83 c0 04             	add    $0x4,%eax
  102c17:	c7 45 b8 00 00 00 00 	movl   $0x0,-0x48(%ebp)
  102c1e:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102c21:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  102c24:	8b 55 b8             	mov    -0x48(%ebp),%edx
  102c27:	0f ab 10             	bts    %edx,(%eax)
        nr_free -= n;
  102c2a:	a1 b8 89 11 00       	mov    0x1189b8,%eax
  102c2f:	2b 45 08             	sub    0x8(%ebp),%eax
  102c32:	a3 b8 89 11 00       	mov    %eax,0x1189b8
        return p;
  102c37:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102c3a:	eb 21                	jmp    102c5d <default_alloc_pages+0x17b>
  102c3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102c3f:	89 45 b0             	mov    %eax,-0x50(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  102c42:	8b 45 b0             	mov    -0x50(%ebp),%eax
  102c45:	8b 40 04             	mov    0x4(%eax),%eax
        return NULL;
    }
    list_entry_t *le, *len;
    le = &free_list;

    while((le=list_next(le)) != &free_list) {
  102c48:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102c4b:	81 7d f4 b0 89 11 00 	cmpl   $0x1189b0,-0xc(%ebp)
  102c52:	0f 85 da fe ff ff    	jne    102b32 <default_alloc_pages+0x50>
        SetPageReserved(p);
        nr_free -= n;
        return p;
      }
    }
    return NULL;
  102c58:	b8 00 00 00 00       	mov    $0x0,%eax
}
  102c5d:	c9                   	leave  
  102c5e:	c3                   	ret    

00102c5f <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
  102c5f:	55                   	push   %ebp
  102c60:	89 e5                	mov    %esp,%ebp
  102c62:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
  102c65:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  102c69:	75 24                	jne    102c8f <default_free_pages+0x30>
  102c6b:	c7 44 24 0c f0 66 10 	movl   $0x1066f0,0xc(%esp)
  102c72:	00 
  102c73:	c7 44 24 08 f6 66 10 	movl   $0x1066f6,0x8(%esp)
  102c7a:	00 
  102c7b:	c7 44 24 04 78 00 00 	movl   $0x78,0x4(%esp)
  102c82:	00 
  102c83:	c7 04 24 0b 67 10 00 	movl   $0x10670b,(%esp)
  102c8a:	e8 42 e0 ff ff       	call   100cd1 <__panic>
    assert(PageReserved(base));
  102c8f:	8b 45 08             	mov    0x8(%ebp),%eax
  102c92:	83 c0 04             	add    $0x4,%eax
  102c95:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  102c9c:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  102c9f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102ca2:	8b 55 ec             	mov    -0x14(%ebp),%edx
  102ca5:	0f a3 10             	bt     %edx,(%eax)
  102ca8:	19 c0                	sbb    %eax,%eax
  102caa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
  102cad:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  102cb1:	0f 95 c0             	setne  %al
  102cb4:	0f b6 c0             	movzbl %al,%eax
  102cb7:	85 c0                	test   %eax,%eax
  102cb9:	75 24                	jne    102cdf <default_free_pages+0x80>
  102cbb:	c7 44 24 0c 31 67 10 	movl   $0x106731,0xc(%esp)
  102cc2:	00 
  102cc3:	c7 44 24 08 f6 66 10 	movl   $0x1066f6,0x8(%esp)
  102cca:	00 
  102ccb:	c7 44 24 04 79 00 00 	movl   $0x79,0x4(%esp)
  102cd2:	00 
  102cd3:	c7 04 24 0b 67 10 00 	movl   $0x10670b,(%esp)
  102cda:	e8 f2 df ff ff       	call   100cd1 <__panic>

    list_entry_t *le = &free_list;
  102cdf:	c7 45 f4 b0 89 11 00 	movl   $0x1189b0,-0xc(%ebp)
    struct Page * p;
    while((le=list_next(le)) != &free_list) {
  102ce6:	eb 13                	jmp    102cfb <default_free_pages+0x9c>
      p = le2page(le, page_link);
  102ce8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102ceb:	83 e8 0c             	sub    $0xc,%eax
  102cee:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(p>base){
  102cf1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102cf4:	3b 45 08             	cmp    0x8(%ebp),%eax
  102cf7:	76 02                	jbe    102cfb <default_free_pages+0x9c>
        break;
  102cf9:	eb 18                	jmp    102d13 <default_free_pages+0xb4>
  102cfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102cfe:	89 45 e0             	mov    %eax,-0x20(%ebp)
  102d01:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102d04:	8b 40 04             	mov    0x4(%eax),%eax
    assert(n > 0);
    assert(PageReserved(base));

    list_entry_t *le = &free_list;
    struct Page * p;
    while((le=list_next(le)) != &free_list) {
  102d07:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102d0a:	81 7d f4 b0 89 11 00 	cmpl   $0x1189b0,-0xc(%ebp)
  102d11:	75 d5                	jne    102ce8 <default_free_pages+0x89>
      if(p>base){
        break;
      }
    }
    //list_add_before(le, base->page_link);
    for(p=base;p<base+n;p++){
  102d13:	8b 45 08             	mov    0x8(%ebp),%eax
  102d16:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102d19:	eb 4b                	jmp    102d66 <default_free_pages+0x107>
      list_add_before(le, &(p->page_link));
  102d1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102d1e:	8d 50 0c             	lea    0xc(%eax),%edx
  102d21:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102d24:	89 45 dc             	mov    %eax,-0x24(%ebp)
  102d27:	89 55 d8             	mov    %edx,-0x28(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
  102d2a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102d2d:	8b 00                	mov    (%eax),%eax
  102d2f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  102d32:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  102d35:	89 45 d0             	mov    %eax,-0x30(%ebp)
  102d38:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102d3b:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  102d3e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  102d41:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102d44:	89 10                	mov    %edx,(%eax)
  102d46:	8b 45 cc             	mov    -0x34(%ebp),%eax
  102d49:	8b 10                	mov    (%eax),%edx
  102d4b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102d4e:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  102d51:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  102d54:	8b 55 cc             	mov    -0x34(%ebp),%edx
  102d57:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  102d5a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  102d5d:	8b 55 d0             	mov    -0x30(%ebp),%edx
  102d60:	89 10                	mov    %edx,(%eax)
      if(p>base){
        break;
      }
    }
    //list_add_before(le, base->page_link);
    for(p=base;p<base+n;p++){
  102d62:	83 45 f0 14          	addl   $0x14,-0x10(%ebp)
  102d66:	8b 55 0c             	mov    0xc(%ebp),%edx
  102d69:	89 d0                	mov    %edx,%eax
  102d6b:	c1 e0 02             	shl    $0x2,%eax
  102d6e:	01 d0                	add    %edx,%eax
  102d70:	c1 e0 02             	shl    $0x2,%eax
  102d73:	89 c2                	mov    %eax,%edx
  102d75:	8b 45 08             	mov    0x8(%ebp),%eax
  102d78:	01 d0                	add    %edx,%eax
  102d7a:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  102d7d:	77 9c                	ja     102d1b <default_free_pages+0xbc>
      list_add_before(le, &(p->page_link));
    }
    base->flags = 0;
  102d7f:	8b 45 08             	mov    0x8(%ebp),%eax
  102d82:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    set_page_ref(base, 0);
  102d89:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  102d90:	00 
  102d91:	8b 45 08             	mov    0x8(%ebp),%eax
  102d94:	89 04 24             	mov    %eax,(%esp)
  102d97:	e8 bd fb ff ff       	call   102959 <set_page_ref>
    ClearPageProperty(base);
  102d9c:	8b 45 08             	mov    0x8(%ebp),%eax
  102d9f:	83 c0 04             	add    $0x4,%eax
  102da2:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
  102da9:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102dac:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  102daf:	8b 55 c8             	mov    -0x38(%ebp),%edx
  102db2:	0f b3 10             	btr    %edx,(%eax)
    SetPageProperty(base);
  102db5:	8b 45 08             	mov    0x8(%ebp),%eax
  102db8:	83 c0 04             	add    $0x4,%eax
  102dbb:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
  102dc2:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102dc5:	8b 45 bc             	mov    -0x44(%ebp),%eax
  102dc8:	8b 55 c0             	mov    -0x40(%ebp),%edx
  102dcb:	0f ab 10             	bts    %edx,(%eax)
    base->property = n;
  102dce:	8b 45 08             	mov    0x8(%ebp),%eax
  102dd1:	8b 55 0c             	mov    0xc(%ebp),%edx
  102dd4:	89 50 08             	mov    %edx,0x8(%eax)
    
    p = le2page(le,page_link) ;
  102dd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102dda:	83 e8 0c             	sub    $0xc,%eax
  102ddd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if( base+n == p ){
  102de0:	8b 55 0c             	mov    0xc(%ebp),%edx
  102de3:	89 d0                	mov    %edx,%eax
  102de5:	c1 e0 02             	shl    $0x2,%eax
  102de8:	01 d0                	add    %edx,%eax
  102dea:	c1 e0 02             	shl    $0x2,%eax
  102ded:	89 c2                	mov    %eax,%edx
  102def:	8b 45 08             	mov    0x8(%ebp),%eax
  102df2:	01 d0                	add    %edx,%eax
  102df4:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  102df7:	75 1e                	jne    102e17 <default_free_pages+0x1b8>
      base->property += p->property;
  102df9:	8b 45 08             	mov    0x8(%ebp),%eax
  102dfc:	8b 50 08             	mov    0x8(%eax),%edx
  102dff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102e02:	8b 40 08             	mov    0x8(%eax),%eax
  102e05:	01 c2                	add    %eax,%edx
  102e07:	8b 45 08             	mov    0x8(%ebp),%eax
  102e0a:	89 50 08             	mov    %edx,0x8(%eax)
      p->property = 0;
  102e0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102e10:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    }
    le = list_prev(&(base->page_link));
  102e17:	8b 45 08             	mov    0x8(%ebp),%eax
  102e1a:	83 c0 0c             	add    $0xc,%eax
  102e1d:	89 45 b8             	mov    %eax,-0x48(%ebp)
 * list_prev - get the previous entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_prev(list_entry_t *listelm) {
    return listelm->prev;
  102e20:	8b 45 b8             	mov    -0x48(%ebp),%eax
  102e23:	8b 00                	mov    (%eax),%eax
  102e25:	89 45 f4             	mov    %eax,-0xc(%ebp)
    p = le2page(le, page_link);
  102e28:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102e2b:	83 e8 0c             	sub    $0xc,%eax
  102e2e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(le!=&free_list && p==base-1){
  102e31:	81 7d f4 b0 89 11 00 	cmpl   $0x1189b0,-0xc(%ebp)
  102e38:	74 57                	je     102e91 <default_free_pages+0x232>
  102e3a:	8b 45 08             	mov    0x8(%ebp),%eax
  102e3d:	83 e8 14             	sub    $0x14,%eax
  102e40:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  102e43:	75 4c                	jne    102e91 <default_free_pages+0x232>
      while(le!=&free_list){
  102e45:	eb 41                	jmp    102e88 <default_free_pages+0x229>
        if(p->property){
  102e47:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102e4a:	8b 40 08             	mov    0x8(%eax),%eax
  102e4d:	85 c0                	test   %eax,%eax
  102e4f:	74 20                	je     102e71 <default_free_pages+0x212>
          p->property += base->property;
  102e51:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102e54:	8b 50 08             	mov    0x8(%eax),%edx
  102e57:	8b 45 08             	mov    0x8(%ebp),%eax
  102e5a:	8b 40 08             	mov    0x8(%eax),%eax
  102e5d:	01 c2                	add    %eax,%edx
  102e5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102e62:	89 50 08             	mov    %edx,0x8(%eax)
          base->property = 0;
  102e65:	8b 45 08             	mov    0x8(%ebp),%eax
  102e68:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
          break;
  102e6f:	eb 20                	jmp    102e91 <default_free_pages+0x232>
  102e71:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102e74:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  102e77:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  102e7a:	8b 00                	mov    (%eax),%eax
        }
        le = list_prev(le);
  102e7c:	89 45 f4             	mov    %eax,-0xc(%ebp)
        p = le2page(le,page_link);
  102e7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102e82:	83 e8 0c             	sub    $0xc,%eax
  102e85:	89 45 f0             	mov    %eax,-0x10(%ebp)
      p->property = 0;
    }
    le = list_prev(&(base->page_link));
    p = le2page(le, page_link);
    if(le!=&free_list && p==base-1){
      while(le!=&free_list){
  102e88:	81 7d f4 b0 89 11 00 	cmpl   $0x1189b0,-0xc(%ebp)
  102e8f:	75 b6                	jne    102e47 <default_free_pages+0x1e8>
        le = list_prev(le);
        p = le2page(le,page_link);
      }
    }

    nr_free += n;
  102e91:	8b 15 b8 89 11 00    	mov    0x1189b8,%edx
  102e97:	8b 45 0c             	mov    0xc(%ebp),%eax
  102e9a:	01 d0                	add    %edx,%eax
  102e9c:	a3 b8 89 11 00       	mov    %eax,0x1189b8
    return ;
  102ea1:	90                   	nop
}
  102ea2:	c9                   	leave  
  102ea3:	c3                   	ret    

00102ea4 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
  102ea4:	55                   	push   %ebp
  102ea5:	89 e5                	mov    %esp,%ebp
    return nr_free;
  102ea7:	a1 b8 89 11 00       	mov    0x1189b8,%eax
}
  102eac:	5d                   	pop    %ebp
  102ead:	c3                   	ret    

00102eae <basic_check>:

static void
basic_check(void) {
  102eae:	55                   	push   %ebp
  102eaf:	89 e5                	mov    %esp,%ebp
  102eb1:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
  102eb4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  102ebb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102ebe:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102ec1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102ec4:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
  102ec7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  102ece:	e8 85 0e 00 00       	call   103d58 <alloc_pages>
  102ed3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  102ed6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  102eda:	75 24                	jne    102f00 <basic_check+0x52>
  102edc:	c7 44 24 0c 44 67 10 	movl   $0x106744,0xc(%esp)
  102ee3:	00 
  102ee4:	c7 44 24 08 f6 66 10 	movl   $0x1066f6,0x8(%esp)
  102eeb:	00 
  102eec:	c7 44 24 04 ad 00 00 	movl   $0xad,0x4(%esp)
  102ef3:	00 
  102ef4:	c7 04 24 0b 67 10 00 	movl   $0x10670b,(%esp)
  102efb:	e8 d1 dd ff ff       	call   100cd1 <__panic>
    assert((p1 = alloc_page()) != NULL);
  102f00:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  102f07:	e8 4c 0e 00 00       	call   103d58 <alloc_pages>
  102f0c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102f0f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  102f13:	75 24                	jne    102f39 <basic_check+0x8b>
  102f15:	c7 44 24 0c 60 67 10 	movl   $0x106760,0xc(%esp)
  102f1c:	00 
  102f1d:	c7 44 24 08 f6 66 10 	movl   $0x1066f6,0x8(%esp)
  102f24:	00 
  102f25:	c7 44 24 04 ae 00 00 	movl   $0xae,0x4(%esp)
  102f2c:	00 
  102f2d:	c7 04 24 0b 67 10 00 	movl   $0x10670b,(%esp)
  102f34:	e8 98 dd ff ff       	call   100cd1 <__panic>
    assert((p2 = alloc_page()) != NULL);
  102f39:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  102f40:	e8 13 0e 00 00       	call   103d58 <alloc_pages>
  102f45:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102f48:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  102f4c:	75 24                	jne    102f72 <basic_check+0xc4>
  102f4e:	c7 44 24 0c 7c 67 10 	movl   $0x10677c,0xc(%esp)
  102f55:	00 
  102f56:	c7 44 24 08 f6 66 10 	movl   $0x1066f6,0x8(%esp)
  102f5d:	00 
  102f5e:	c7 44 24 04 af 00 00 	movl   $0xaf,0x4(%esp)
  102f65:	00 
  102f66:	c7 04 24 0b 67 10 00 	movl   $0x10670b,(%esp)
  102f6d:	e8 5f dd ff ff       	call   100cd1 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
  102f72:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102f75:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  102f78:	74 10                	je     102f8a <basic_check+0xdc>
  102f7a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102f7d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  102f80:	74 08                	je     102f8a <basic_check+0xdc>
  102f82:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102f85:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  102f88:	75 24                	jne    102fae <basic_check+0x100>
  102f8a:	c7 44 24 0c 98 67 10 	movl   $0x106798,0xc(%esp)
  102f91:	00 
  102f92:	c7 44 24 08 f6 66 10 	movl   $0x1066f6,0x8(%esp)
  102f99:	00 
  102f9a:	c7 44 24 04 b1 00 00 	movl   $0xb1,0x4(%esp)
  102fa1:	00 
  102fa2:	c7 04 24 0b 67 10 00 	movl   $0x10670b,(%esp)
  102fa9:	e8 23 dd ff ff       	call   100cd1 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
  102fae:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102fb1:	89 04 24             	mov    %eax,(%esp)
  102fb4:	e8 96 f9 ff ff       	call   10294f <page_ref>
  102fb9:	85 c0                	test   %eax,%eax
  102fbb:	75 1e                	jne    102fdb <basic_check+0x12d>
  102fbd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102fc0:	89 04 24             	mov    %eax,(%esp)
  102fc3:	e8 87 f9 ff ff       	call   10294f <page_ref>
  102fc8:	85 c0                	test   %eax,%eax
  102fca:	75 0f                	jne    102fdb <basic_check+0x12d>
  102fcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102fcf:	89 04 24             	mov    %eax,(%esp)
  102fd2:	e8 78 f9 ff ff       	call   10294f <page_ref>
  102fd7:	85 c0                	test   %eax,%eax
  102fd9:	74 24                	je     102fff <basic_check+0x151>
  102fdb:	c7 44 24 0c bc 67 10 	movl   $0x1067bc,0xc(%esp)
  102fe2:	00 
  102fe3:	c7 44 24 08 f6 66 10 	movl   $0x1066f6,0x8(%esp)
  102fea:	00 
  102feb:	c7 44 24 04 b2 00 00 	movl   $0xb2,0x4(%esp)
  102ff2:	00 
  102ff3:	c7 04 24 0b 67 10 00 	movl   $0x10670b,(%esp)
  102ffa:	e8 d2 dc ff ff       	call   100cd1 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
  102fff:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103002:	89 04 24             	mov    %eax,(%esp)
  103005:	e8 2f f9 ff ff       	call   102939 <page2pa>
  10300a:	8b 15 c0 88 11 00    	mov    0x1188c0,%edx
  103010:	c1 e2 0c             	shl    $0xc,%edx
  103013:	39 d0                	cmp    %edx,%eax
  103015:	72 24                	jb     10303b <basic_check+0x18d>
  103017:	c7 44 24 0c f8 67 10 	movl   $0x1067f8,0xc(%esp)
  10301e:	00 
  10301f:	c7 44 24 08 f6 66 10 	movl   $0x1066f6,0x8(%esp)
  103026:	00 
  103027:	c7 44 24 04 b4 00 00 	movl   $0xb4,0x4(%esp)
  10302e:	00 
  10302f:	c7 04 24 0b 67 10 00 	movl   $0x10670b,(%esp)
  103036:	e8 96 dc ff ff       	call   100cd1 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
  10303b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10303e:	89 04 24             	mov    %eax,(%esp)
  103041:	e8 f3 f8 ff ff       	call   102939 <page2pa>
  103046:	8b 15 c0 88 11 00    	mov    0x1188c0,%edx
  10304c:	c1 e2 0c             	shl    $0xc,%edx
  10304f:	39 d0                	cmp    %edx,%eax
  103051:	72 24                	jb     103077 <basic_check+0x1c9>
  103053:	c7 44 24 0c 15 68 10 	movl   $0x106815,0xc(%esp)
  10305a:	00 
  10305b:	c7 44 24 08 f6 66 10 	movl   $0x1066f6,0x8(%esp)
  103062:	00 
  103063:	c7 44 24 04 b5 00 00 	movl   $0xb5,0x4(%esp)
  10306a:	00 
  10306b:	c7 04 24 0b 67 10 00 	movl   $0x10670b,(%esp)
  103072:	e8 5a dc ff ff       	call   100cd1 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
  103077:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10307a:	89 04 24             	mov    %eax,(%esp)
  10307d:	e8 b7 f8 ff ff       	call   102939 <page2pa>
  103082:	8b 15 c0 88 11 00    	mov    0x1188c0,%edx
  103088:	c1 e2 0c             	shl    $0xc,%edx
  10308b:	39 d0                	cmp    %edx,%eax
  10308d:	72 24                	jb     1030b3 <basic_check+0x205>
  10308f:	c7 44 24 0c 32 68 10 	movl   $0x106832,0xc(%esp)
  103096:	00 
  103097:	c7 44 24 08 f6 66 10 	movl   $0x1066f6,0x8(%esp)
  10309e:	00 
  10309f:	c7 44 24 04 b6 00 00 	movl   $0xb6,0x4(%esp)
  1030a6:	00 
  1030a7:	c7 04 24 0b 67 10 00 	movl   $0x10670b,(%esp)
  1030ae:	e8 1e dc ff ff       	call   100cd1 <__panic>

    list_entry_t free_list_store = free_list;
  1030b3:	a1 b0 89 11 00       	mov    0x1189b0,%eax
  1030b8:	8b 15 b4 89 11 00    	mov    0x1189b4,%edx
  1030be:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1030c1:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  1030c4:	c7 45 e0 b0 89 11 00 	movl   $0x1189b0,-0x20(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  1030cb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1030ce:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1030d1:	89 50 04             	mov    %edx,0x4(%eax)
  1030d4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1030d7:	8b 50 04             	mov    0x4(%eax),%edx
  1030da:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1030dd:	89 10                	mov    %edx,(%eax)
  1030df:	c7 45 dc b0 89 11 00 	movl   $0x1189b0,-0x24(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
  1030e6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1030e9:	8b 40 04             	mov    0x4(%eax),%eax
  1030ec:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  1030ef:	0f 94 c0             	sete   %al
  1030f2:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  1030f5:	85 c0                	test   %eax,%eax
  1030f7:	75 24                	jne    10311d <basic_check+0x26f>
  1030f9:	c7 44 24 0c 4f 68 10 	movl   $0x10684f,0xc(%esp)
  103100:	00 
  103101:	c7 44 24 08 f6 66 10 	movl   $0x1066f6,0x8(%esp)
  103108:	00 
  103109:	c7 44 24 04 ba 00 00 	movl   $0xba,0x4(%esp)
  103110:	00 
  103111:	c7 04 24 0b 67 10 00 	movl   $0x10670b,(%esp)
  103118:	e8 b4 db ff ff       	call   100cd1 <__panic>

    unsigned int nr_free_store = nr_free;
  10311d:	a1 b8 89 11 00       	mov    0x1189b8,%eax
  103122:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
  103125:	c7 05 b8 89 11 00 00 	movl   $0x0,0x1189b8
  10312c:	00 00 00 

    assert(alloc_page() == NULL);
  10312f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103136:	e8 1d 0c 00 00       	call   103d58 <alloc_pages>
  10313b:	85 c0                	test   %eax,%eax
  10313d:	74 24                	je     103163 <basic_check+0x2b5>
  10313f:	c7 44 24 0c 66 68 10 	movl   $0x106866,0xc(%esp)
  103146:	00 
  103147:	c7 44 24 08 f6 66 10 	movl   $0x1066f6,0x8(%esp)
  10314e:	00 
  10314f:	c7 44 24 04 bf 00 00 	movl   $0xbf,0x4(%esp)
  103156:	00 
  103157:	c7 04 24 0b 67 10 00 	movl   $0x10670b,(%esp)
  10315e:	e8 6e db ff ff       	call   100cd1 <__panic>

    free_page(p0);
  103163:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10316a:	00 
  10316b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10316e:	89 04 24             	mov    %eax,(%esp)
  103171:	e8 1a 0c 00 00       	call   103d90 <free_pages>
    free_page(p1);
  103176:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10317d:	00 
  10317e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103181:	89 04 24             	mov    %eax,(%esp)
  103184:	e8 07 0c 00 00       	call   103d90 <free_pages>
    free_page(p2);
  103189:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103190:	00 
  103191:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103194:	89 04 24             	mov    %eax,(%esp)
  103197:	e8 f4 0b 00 00       	call   103d90 <free_pages>
    assert(nr_free == 3);
  10319c:	a1 b8 89 11 00       	mov    0x1189b8,%eax
  1031a1:	83 f8 03             	cmp    $0x3,%eax
  1031a4:	74 24                	je     1031ca <basic_check+0x31c>
  1031a6:	c7 44 24 0c 7b 68 10 	movl   $0x10687b,0xc(%esp)
  1031ad:	00 
  1031ae:	c7 44 24 08 f6 66 10 	movl   $0x1066f6,0x8(%esp)
  1031b5:	00 
  1031b6:	c7 44 24 04 c4 00 00 	movl   $0xc4,0x4(%esp)
  1031bd:	00 
  1031be:	c7 04 24 0b 67 10 00 	movl   $0x10670b,(%esp)
  1031c5:	e8 07 db ff ff       	call   100cd1 <__panic>

    assert((p0 = alloc_page()) != NULL);
  1031ca:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1031d1:	e8 82 0b 00 00       	call   103d58 <alloc_pages>
  1031d6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1031d9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  1031dd:	75 24                	jne    103203 <basic_check+0x355>
  1031df:	c7 44 24 0c 44 67 10 	movl   $0x106744,0xc(%esp)
  1031e6:	00 
  1031e7:	c7 44 24 08 f6 66 10 	movl   $0x1066f6,0x8(%esp)
  1031ee:	00 
  1031ef:	c7 44 24 04 c6 00 00 	movl   $0xc6,0x4(%esp)
  1031f6:	00 
  1031f7:	c7 04 24 0b 67 10 00 	movl   $0x10670b,(%esp)
  1031fe:	e8 ce da ff ff       	call   100cd1 <__panic>
    assert((p1 = alloc_page()) != NULL);
  103203:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10320a:	e8 49 0b 00 00       	call   103d58 <alloc_pages>
  10320f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103212:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103216:	75 24                	jne    10323c <basic_check+0x38e>
  103218:	c7 44 24 0c 60 67 10 	movl   $0x106760,0xc(%esp)
  10321f:	00 
  103220:	c7 44 24 08 f6 66 10 	movl   $0x1066f6,0x8(%esp)
  103227:	00 
  103228:	c7 44 24 04 c7 00 00 	movl   $0xc7,0x4(%esp)
  10322f:	00 
  103230:	c7 04 24 0b 67 10 00 	movl   $0x10670b,(%esp)
  103237:	e8 95 da ff ff       	call   100cd1 <__panic>
    assert((p2 = alloc_page()) != NULL);
  10323c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103243:	e8 10 0b 00 00       	call   103d58 <alloc_pages>
  103248:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10324b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10324f:	75 24                	jne    103275 <basic_check+0x3c7>
  103251:	c7 44 24 0c 7c 67 10 	movl   $0x10677c,0xc(%esp)
  103258:	00 
  103259:	c7 44 24 08 f6 66 10 	movl   $0x1066f6,0x8(%esp)
  103260:	00 
  103261:	c7 44 24 04 c8 00 00 	movl   $0xc8,0x4(%esp)
  103268:	00 
  103269:	c7 04 24 0b 67 10 00 	movl   $0x10670b,(%esp)
  103270:	e8 5c da ff ff       	call   100cd1 <__panic>

    assert(alloc_page() == NULL);
  103275:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10327c:	e8 d7 0a 00 00       	call   103d58 <alloc_pages>
  103281:	85 c0                	test   %eax,%eax
  103283:	74 24                	je     1032a9 <basic_check+0x3fb>
  103285:	c7 44 24 0c 66 68 10 	movl   $0x106866,0xc(%esp)
  10328c:	00 
  10328d:	c7 44 24 08 f6 66 10 	movl   $0x1066f6,0x8(%esp)
  103294:	00 
  103295:	c7 44 24 04 ca 00 00 	movl   $0xca,0x4(%esp)
  10329c:	00 
  10329d:	c7 04 24 0b 67 10 00 	movl   $0x10670b,(%esp)
  1032a4:	e8 28 da ff ff       	call   100cd1 <__panic>

    free_page(p0);
  1032a9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1032b0:	00 
  1032b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1032b4:	89 04 24             	mov    %eax,(%esp)
  1032b7:	e8 d4 0a 00 00       	call   103d90 <free_pages>
  1032bc:	c7 45 d8 b0 89 11 00 	movl   $0x1189b0,-0x28(%ebp)
  1032c3:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1032c6:	8b 40 04             	mov    0x4(%eax),%eax
  1032c9:	39 45 d8             	cmp    %eax,-0x28(%ebp)
  1032cc:	0f 94 c0             	sete   %al
  1032cf:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
  1032d2:	85 c0                	test   %eax,%eax
  1032d4:	74 24                	je     1032fa <basic_check+0x44c>
  1032d6:	c7 44 24 0c 88 68 10 	movl   $0x106888,0xc(%esp)
  1032dd:	00 
  1032de:	c7 44 24 08 f6 66 10 	movl   $0x1066f6,0x8(%esp)
  1032e5:	00 
  1032e6:	c7 44 24 04 cd 00 00 	movl   $0xcd,0x4(%esp)
  1032ed:	00 
  1032ee:	c7 04 24 0b 67 10 00 	movl   $0x10670b,(%esp)
  1032f5:	e8 d7 d9 ff ff       	call   100cd1 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
  1032fa:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103301:	e8 52 0a 00 00       	call   103d58 <alloc_pages>
  103306:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  103309:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10330c:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  10330f:	74 24                	je     103335 <basic_check+0x487>
  103311:	c7 44 24 0c a0 68 10 	movl   $0x1068a0,0xc(%esp)
  103318:	00 
  103319:	c7 44 24 08 f6 66 10 	movl   $0x1066f6,0x8(%esp)
  103320:	00 
  103321:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
  103328:	00 
  103329:	c7 04 24 0b 67 10 00 	movl   $0x10670b,(%esp)
  103330:	e8 9c d9 ff ff       	call   100cd1 <__panic>
    assert(alloc_page() == NULL);
  103335:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10333c:	e8 17 0a 00 00       	call   103d58 <alloc_pages>
  103341:	85 c0                	test   %eax,%eax
  103343:	74 24                	je     103369 <basic_check+0x4bb>
  103345:	c7 44 24 0c 66 68 10 	movl   $0x106866,0xc(%esp)
  10334c:	00 
  10334d:	c7 44 24 08 f6 66 10 	movl   $0x1066f6,0x8(%esp)
  103354:	00 
  103355:	c7 44 24 04 d1 00 00 	movl   $0xd1,0x4(%esp)
  10335c:	00 
  10335d:	c7 04 24 0b 67 10 00 	movl   $0x10670b,(%esp)
  103364:	e8 68 d9 ff ff       	call   100cd1 <__panic>

    assert(nr_free == 0);
  103369:	a1 b8 89 11 00       	mov    0x1189b8,%eax
  10336e:	85 c0                	test   %eax,%eax
  103370:	74 24                	je     103396 <basic_check+0x4e8>
  103372:	c7 44 24 0c b9 68 10 	movl   $0x1068b9,0xc(%esp)
  103379:	00 
  10337a:	c7 44 24 08 f6 66 10 	movl   $0x1066f6,0x8(%esp)
  103381:	00 
  103382:	c7 44 24 04 d3 00 00 	movl   $0xd3,0x4(%esp)
  103389:	00 
  10338a:	c7 04 24 0b 67 10 00 	movl   $0x10670b,(%esp)
  103391:	e8 3b d9 ff ff       	call   100cd1 <__panic>
    free_list = free_list_store;
  103396:	8b 45 d0             	mov    -0x30(%ebp),%eax
  103399:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10339c:	a3 b0 89 11 00       	mov    %eax,0x1189b0
  1033a1:	89 15 b4 89 11 00    	mov    %edx,0x1189b4
    nr_free = nr_free_store;
  1033a7:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1033aa:	a3 b8 89 11 00       	mov    %eax,0x1189b8

    free_page(p);
  1033af:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1033b6:	00 
  1033b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1033ba:	89 04 24             	mov    %eax,(%esp)
  1033bd:	e8 ce 09 00 00       	call   103d90 <free_pages>
    free_page(p1);
  1033c2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1033c9:	00 
  1033ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1033cd:	89 04 24             	mov    %eax,(%esp)
  1033d0:	e8 bb 09 00 00       	call   103d90 <free_pages>
    free_page(p2);
  1033d5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1033dc:	00 
  1033dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1033e0:	89 04 24             	mov    %eax,(%esp)
  1033e3:	e8 a8 09 00 00       	call   103d90 <free_pages>
}
  1033e8:	c9                   	leave  
  1033e9:	c3                   	ret    

001033ea <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
  1033ea:	55                   	push   %ebp
  1033eb:	89 e5                	mov    %esp,%ebp
  1033ed:	53                   	push   %ebx
  1033ee:	81 ec 94 00 00 00    	sub    $0x94,%esp
    int count = 0, total = 0;
  1033f4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  1033fb:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
  103402:	c7 45 ec b0 89 11 00 	movl   $0x1189b0,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  103409:	eb 6b                	jmp    103476 <default_check+0x8c>
        struct Page *p = le2page(le, page_link);
  10340b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10340e:	83 e8 0c             	sub    $0xc,%eax
  103411:	89 45 e8             	mov    %eax,-0x18(%ebp)
        assert(PageProperty(p));
  103414:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103417:	83 c0 04             	add    $0x4,%eax
  10341a:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
  103421:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  103424:	8b 45 cc             	mov    -0x34(%ebp),%eax
  103427:	8b 55 d0             	mov    -0x30(%ebp),%edx
  10342a:	0f a3 10             	bt     %edx,(%eax)
  10342d:	19 c0                	sbb    %eax,%eax
  10342f:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
  103432:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  103436:	0f 95 c0             	setne  %al
  103439:	0f b6 c0             	movzbl %al,%eax
  10343c:	85 c0                	test   %eax,%eax
  10343e:	75 24                	jne    103464 <default_check+0x7a>
  103440:	c7 44 24 0c c6 68 10 	movl   $0x1068c6,0xc(%esp)
  103447:	00 
  103448:	c7 44 24 08 f6 66 10 	movl   $0x1066f6,0x8(%esp)
  10344f:	00 
  103450:	c7 44 24 04 e4 00 00 	movl   $0xe4,0x4(%esp)
  103457:	00 
  103458:	c7 04 24 0b 67 10 00 	movl   $0x10670b,(%esp)
  10345f:	e8 6d d8 ff ff       	call   100cd1 <__panic>
        count ++, total += p->property;
  103464:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  103468:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10346b:	8b 50 08             	mov    0x8(%eax),%edx
  10346e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103471:	01 d0                	add    %edx,%eax
  103473:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103476:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103479:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  10347c:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  10347f:	8b 40 04             	mov    0x4(%eax),%eax
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
  103482:	89 45 ec             	mov    %eax,-0x14(%ebp)
  103485:	81 7d ec b0 89 11 00 	cmpl   $0x1189b0,-0x14(%ebp)
  10348c:	0f 85 79 ff ff ff    	jne    10340b <default_check+0x21>
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    assert(total == nr_free_pages());
  103492:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  103495:	e8 28 09 00 00       	call   103dc2 <nr_free_pages>
  10349a:	39 c3                	cmp    %eax,%ebx
  10349c:	74 24                	je     1034c2 <default_check+0xd8>
  10349e:	c7 44 24 0c d6 68 10 	movl   $0x1068d6,0xc(%esp)
  1034a5:	00 
  1034a6:	c7 44 24 08 f6 66 10 	movl   $0x1066f6,0x8(%esp)
  1034ad:	00 
  1034ae:	c7 44 24 04 e7 00 00 	movl   $0xe7,0x4(%esp)
  1034b5:	00 
  1034b6:	c7 04 24 0b 67 10 00 	movl   $0x10670b,(%esp)
  1034bd:	e8 0f d8 ff ff       	call   100cd1 <__panic>

    basic_check();
  1034c2:	e8 e7 f9 ff ff       	call   102eae <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
  1034c7:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  1034ce:	e8 85 08 00 00       	call   103d58 <alloc_pages>
  1034d3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(p0 != NULL);
  1034d6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  1034da:	75 24                	jne    103500 <default_check+0x116>
  1034dc:	c7 44 24 0c ef 68 10 	movl   $0x1068ef,0xc(%esp)
  1034e3:	00 
  1034e4:	c7 44 24 08 f6 66 10 	movl   $0x1066f6,0x8(%esp)
  1034eb:	00 
  1034ec:	c7 44 24 04 ec 00 00 	movl   $0xec,0x4(%esp)
  1034f3:	00 
  1034f4:	c7 04 24 0b 67 10 00 	movl   $0x10670b,(%esp)
  1034fb:	e8 d1 d7 ff ff       	call   100cd1 <__panic>
    assert(!PageProperty(p0));
  103500:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103503:	83 c0 04             	add    $0x4,%eax
  103506:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
  10350d:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  103510:	8b 45 bc             	mov    -0x44(%ebp),%eax
  103513:	8b 55 c0             	mov    -0x40(%ebp),%edx
  103516:	0f a3 10             	bt     %edx,(%eax)
  103519:	19 c0                	sbb    %eax,%eax
  10351b:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
  10351e:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
  103522:	0f 95 c0             	setne  %al
  103525:	0f b6 c0             	movzbl %al,%eax
  103528:	85 c0                	test   %eax,%eax
  10352a:	74 24                	je     103550 <default_check+0x166>
  10352c:	c7 44 24 0c fa 68 10 	movl   $0x1068fa,0xc(%esp)
  103533:	00 
  103534:	c7 44 24 08 f6 66 10 	movl   $0x1066f6,0x8(%esp)
  10353b:	00 
  10353c:	c7 44 24 04 ed 00 00 	movl   $0xed,0x4(%esp)
  103543:	00 
  103544:	c7 04 24 0b 67 10 00 	movl   $0x10670b,(%esp)
  10354b:	e8 81 d7 ff ff       	call   100cd1 <__panic>

    list_entry_t free_list_store = free_list;
  103550:	a1 b0 89 11 00       	mov    0x1189b0,%eax
  103555:	8b 15 b4 89 11 00    	mov    0x1189b4,%edx
  10355b:	89 45 80             	mov    %eax,-0x80(%ebp)
  10355e:	89 55 84             	mov    %edx,-0x7c(%ebp)
  103561:	c7 45 b4 b0 89 11 00 	movl   $0x1189b0,-0x4c(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  103568:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  10356b:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  10356e:	89 50 04             	mov    %edx,0x4(%eax)
  103571:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  103574:	8b 50 04             	mov    0x4(%eax),%edx
  103577:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  10357a:	89 10                	mov    %edx,(%eax)
  10357c:	c7 45 b0 b0 89 11 00 	movl   $0x1189b0,-0x50(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
  103583:	8b 45 b0             	mov    -0x50(%ebp),%eax
  103586:	8b 40 04             	mov    0x4(%eax),%eax
  103589:	39 45 b0             	cmp    %eax,-0x50(%ebp)
  10358c:	0f 94 c0             	sete   %al
  10358f:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  103592:	85 c0                	test   %eax,%eax
  103594:	75 24                	jne    1035ba <default_check+0x1d0>
  103596:	c7 44 24 0c 4f 68 10 	movl   $0x10684f,0xc(%esp)
  10359d:	00 
  10359e:	c7 44 24 08 f6 66 10 	movl   $0x1066f6,0x8(%esp)
  1035a5:	00 
  1035a6:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
  1035ad:	00 
  1035ae:	c7 04 24 0b 67 10 00 	movl   $0x10670b,(%esp)
  1035b5:	e8 17 d7 ff ff       	call   100cd1 <__panic>
    assert(alloc_page() == NULL);
  1035ba:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1035c1:	e8 92 07 00 00       	call   103d58 <alloc_pages>
  1035c6:	85 c0                	test   %eax,%eax
  1035c8:	74 24                	je     1035ee <default_check+0x204>
  1035ca:	c7 44 24 0c 66 68 10 	movl   $0x106866,0xc(%esp)
  1035d1:	00 
  1035d2:	c7 44 24 08 f6 66 10 	movl   $0x1066f6,0x8(%esp)
  1035d9:	00 
  1035da:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
  1035e1:	00 
  1035e2:	c7 04 24 0b 67 10 00 	movl   $0x10670b,(%esp)
  1035e9:	e8 e3 d6 ff ff       	call   100cd1 <__panic>

    unsigned int nr_free_store = nr_free;
  1035ee:	a1 b8 89 11 00       	mov    0x1189b8,%eax
  1035f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nr_free = 0;
  1035f6:	c7 05 b8 89 11 00 00 	movl   $0x0,0x1189b8
  1035fd:	00 00 00 

    free_pages(p0 + 2, 3);
  103600:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103603:	83 c0 28             	add    $0x28,%eax
  103606:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  10360d:	00 
  10360e:	89 04 24             	mov    %eax,(%esp)
  103611:	e8 7a 07 00 00       	call   103d90 <free_pages>
    assert(alloc_pages(4) == NULL);
  103616:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  10361d:	e8 36 07 00 00       	call   103d58 <alloc_pages>
  103622:	85 c0                	test   %eax,%eax
  103624:	74 24                	je     10364a <default_check+0x260>
  103626:	c7 44 24 0c 0c 69 10 	movl   $0x10690c,0xc(%esp)
  10362d:	00 
  10362e:	c7 44 24 08 f6 66 10 	movl   $0x1066f6,0x8(%esp)
  103635:	00 
  103636:	c7 44 24 04 f8 00 00 	movl   $0xf8,0x4(%esp)
  10363d:	00 
  10363e:	c7 04 24 0b 67 10 00 	movl   $0x10670b,(%esp)
  103645:	e8 87 d6 ff ff       	call   100cd1 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
  10364a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10364d:	83 c0 28             	add    $0x28,%eax
  103650:	83 c0 04             	add    $0x4,%eax
  103653:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
  10365a:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  10365d:	8b 45 a8             	mov    -0x58(%ebp),%eax
  103660:	8b 55 ac             	mov    -0x54(%ebp),%edx
  103663:	0f a3 10             	bt     %edx,(%eax)
  103666:	19 c0                	sbb    %eax,%eax
  103668:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
  10366b:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
  10366f:	0f 95 c0             	setne  %al
  103672:	0f b6 c0             	movzbl %al,%eax
  103675:	85 c0                	test   %eax,%eax
  103677:	74 0e                	je     103687 <default_check+0x29d>
  103679:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10367c:	83 c0 28             	add    $0x28,%eax
  10367f:	8b 40 08             	mov    0x8(%eax),%eax
  103682:	83 f8 03             	cmp    $0x3,%eax
  103685:	74 24                	je     1036ab <default_check+0x2c1>
  103687:	c7 44 24 0c 24 69 10 	movl   $0x106924,0xc(%esp)
  10368e:	00 
  10368f:	c7 44 24 08 f6 66 10 	movl   $0x1066f6,0x8(%esp)
  103696:	00 
  103697:	c7 44 24 04 f9 00 00 	movl   $0xf9,0x4(%esp)
  10369e:	00 
  10369f:	c7 04 24 0b 67 10 00 	movl   $0x10670b,(%esp)
  1036a6:	e8 26 d6 ff ff       	call   100cd1 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
  1036ab:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  1036b2:	e8 a1 06 00 00       	call   103d58 <alloc_pages>
  1036b7:	89 45 dc             	mov    %eax,-0x24(%ebp)
  1036ba:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  1036be:	75 24                	jne    1036e4 <default_check+0x2fa>
  1036c0:	c7 44 24 0c 50 69 10 	movl   $0x106950,0xc(%esp)
  1036c7:	00 
  1036c8:	c7 44 24 08 f6 66 10 	movl   $0x1066f6,0x8(%esp)
  1036cf:	00 
  1036d0:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
  1036d7:	00 
  1036d8:	c7 04 24 0b 67 10 00 	movl   $0x10670b,(%esp)
  1036df:	e8 ed d5 ff ff       	call   100cd1 <__panic>
    assert(alloc_page() == NULL);
  1036e4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1036eb:	e8 68 06 00 00       	call   103d58 <alloc_pages>
  1036f0:	85 c0                	test   %eax,%eax
  1036f2:	74 24                	je     103718 <default_check+0x32e>
  1036f4:	c7 44 24 0c 66 68 10 	movl   $0x106866,0xc(%esp)
  1036fb:	00 
  1036fc:	c7 44 24 08 f6 66 10 	movl   $0x1066f6,0x8(%esp)
  103703:	00 
  103704:	c7 44 24 04 fb 00 00 	movl   $0xfb,0x4(%esp)
  10370b:	00 
  10370c:	c7 04 24 0b 67 10 00 	movl   $0x10670b,(%esp)
  103713:	e8 b9 d5 ff ff       	call   100cd1 <__panic>
    assert(p0 + 2 == p1);
  103718:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10371b:	83 c0 28             	add    $0x28,%eax
  10371e:	3b 45 dc             	cmp    -0x24(%ebp),%eax
  103721:	74 24                	je     103747 <default_check+0x35d>
  103723:	c7 44 24 0c 6e 69 10 	movl   $0x10696e,0xc(%esp)
  10372a:	00 
  10372b:	c7 44 24 08 f6 66 10 	movl   $0x1066f6,0x8(%esp)
  103732:	00 
  103733:	c7 44 24 04 fc 00 00 	movl   $0xfc,0x4(%esp)
  10373a:	00 
  10373b:	c7 04 24 0b 67 10 00 	movl   $0x10670b,(%esp)
  103742:	e8 8a d5 ff ff       	call   100cd1 <__panic>

    p2 = p0 + 1;
  103747:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10374a:	83 c0 14             	add    $0x14,%eax
  10374d:	89 45 d8             	mov    %eax,-0x28(%ebp)
    free_page(p0);
  103750:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103757:	00 
  103758:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10375b:	89 04 24             	mov    %eax,(%esp)
  10375e:	e8 2d 06 00 00       	call   103d90 <free_pages>
    free_pages(p1, 3);
  103763:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  10376a:	00 
  10376b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10376e:	89 04 24             	mov    %eax,(%esp)
  103771:	e8 1a 06 00 00       	call   103d90 <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
  103776:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103779:	83 c0 04             	add    $0x4,%eax
  10377c:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
  103783:	89 45 9c             	mov    %eax,-0x64(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  103786:	8b 45 9c             	mov    -0x64(%ebp),%eax
  103789:	8b 55 a0             	mov    -0x60(%ebp),%edx
  10378c:	0f a3 10             	bt     %edx,(%eax)
  10378f:	19 c0                	sbb    %eax,%eax
  103791:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
  103794:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
  103798:	0f 95 c0             	setne  %al
  10379b:	0f b6 c0             	movzbl %al,%eax
  10379e:	85 c0                	test   %eax,%eax
  1037a0:	74 0b                	je     1037ad <default_check+0x3c3>
  1037a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1037a5:	8b 40 08             	mov    0x8(%eax),%eax
  1037a8:	83 f8 01             	cmp    $0x1,%eax
  1037ab:	74 24                	je     1037d1 <default_check+0x3e7>
  1037ad:	c7 44 24 0c 7c 69 10 	movl   $0x10697c,0xc(%esp)
  1037b4:	00 
  1037b5:	c7 44 24 08 f6 66 10 	movl   $0x1066f6,0x8(%esp)
  1037bc:	00 
  1037bd:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
  1037c4:	00 
  1037c5:	c7 04 24 0b 67 10 00 	movl   $0x10670b,(%esp)
  1037cc:	e8 00 d5 ff ff       	call   100cd1 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
  1037d1:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1037d4:	83 c0 04             	add    $0x4,%eax
  1037d7:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
  1037de:	89 45 90             	mov    %eax,-0x70(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1037e1:	8b 45 90             	mov    -0x70(%ebp),%eax
  1037e4:	8b 55 94             	mov    -0x6c(%ebp),%edx
  1037e7:	0f a3 10             	bt     %edx,(%eax)
  1037ea:	19 c0                	sbb    %eax,%eax
  1037ec:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
  1037ef:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
  1037f3:	0f 95 c0             	setne  %al
  1037f6:	0f b6 c0             	movzbl %al,%eax
  1037f9:	85 c0                	test   %eax,%eax
  1037fb:	74 0b                	je     103808 <default_check+0x41e>
  1037fd:	8b 45 dc             	mov    -0x24(%ebp),%eax
  103800:	8b 40 08             	mov    0x8(%eax),%eax
  103803:	83 f8 03             	cmp    $0x3,%eax
  103806:	74 24                	je     10382c <default_check+0x442>
  103808:	c7 44 24 0c a4 69 10 	movl   $0x1069a4,0xc(%esp)
  10380f:	00 
  103810:	c7 44 24 08 f6 66 10 	movl   $0x1066f6,0x8(%esp)
  103817:	00 
  103818:	c7 44 24 04 02 01 00 	movl   $0x102,0x4(%esp)
  10381f:	00 
  103820:	c7 04 24 0b 67 10 00 	movl   $0x10670b,(%esp)
  103827:	e8 a5 d4 ff ff       	call   100cd1 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
  10382c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103833:	e8 20 05 00 00       	call   103d58 <alloc_pages>
  103838:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  10383b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10383e:	83 e8 14             	sub    $0x14,%eax
  103841:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  103844:	74 24                	je     10386a <default_check+0x480>
  103846:	c7 44 24 0c ca 69 10 	movl   $0x1069ca,0xc(%esp)
  10384d:	00 
  10384e:	c7 44 24 08 f6 66 10 	movl   $0x1066f6,0x8(%esp)
  103855:	00 
  103856:	c7 44 24 04 04 01 00 	movl   $0x104,0x4(%esp)
  10385d:	00 
  10385e:	c7 04 24 0b 67 10 00 	movl   $0x10670b,(%esp)
  103865:	e8 67 d4 ff ff       	call   100cd1 <__panic>
    free_page(p0);
  10386a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103871:	00 
  103872:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103875:	89 04 24             	mov    %eax,(%esp)
  103878:	e8 13 05 00 00       	call   103d90 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
  10387d:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  103884:	e8 cf 04 00 00       	call   103d58 <alloc_pages>
  103889:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  10388c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10388f:	83 c0 14             	add    $0x14,%eax
  103892:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  103895:	74 24                	je     1038bb <default_check+0x4d1>
  103897:	c7 44 24 0c e8 69 10 	movl   $0x1069e8,0xc(%esp)
  10389e:	00 
  10389f:	c7 44 24 08 f6 66 10 	movl   $0x1066f6,0x8(%esp)
  1038a6:	00 
  1038a7:	c7 44 24 04 06 01 00 	movl   $0x106,0x4(%esp)
  1038ae:	00 
  1038af:	c7 04 24 0b 67 10 00 	movl   $0x10670b,(%esp)
  1038b6:	e8 16 d4 ff ff       	call   100cd1 <__panic>

    free_pages(p0, 2);
  1038bb:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  1038c2:	00 
  1038c3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1038c6:	89 04 24             	mov    %eax,(%esp)
  1038c9:	e8 c2 04 00 00       	call   103d90 <free_pages>
    free_page(p2);
  1038ce:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1038d5:	00 
  1038d6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1038d9:	89 04 24             	mov    %eax,(%esp)
  1038dc:	e8 af 04 00 00       	call   103d90 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
  1038e1:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  1038e8:	e8 6b 04 00 00       	call   103d58 <alloc_pages>
  1038ed:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1038f0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  1038f4:	75 24                	jne    10391a <default_check+0x530>
  1038f6:	c7 44 24 0c 08 6a 10 	movl   $0x106a08,0xc(%esp)
  1038fd:	00 
  1038fe:	c7 44 24 08 f6 66 10 	movl   $0x1066f6,0x8(%esp)
  103905:	00 
  103906:	c7 44 24 04 0b 01 00 	movl   $0x10b,0x4(%esp)
  10390d:	00 
  10390e:	c7 04 24 0b 67 10 00 	movl   $0x10670b,(%esp)
  103915:	e8 b7 d3 ff ff       	call   100cd1 <__panic>
    assert(alloc_page() == NULL);
  10391a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103921:	e8 32 04 00 00       	call   103d58 <alloc_pages>
  103926:	85 c0                	test   %eax,%eax
  103928:	74 24                	je     10394e <default_check+0x564>
  10392a:	c7 44 24 0c 66 68 10 	movl   $0x106866,0xc(%esp)
  103931:	00 
  103932:	c7 44 24 08 f6 66 10 	movl   $0x1066f6,0x8(%esp)
  103939:	00 
  10393a:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
  103941:	00 
  103942:	c7 04 24 0b 67 10 00 	movl   $0x10670b,(%esp)
  103949:	e8 83 d3 ff ff       	call   100cd1 <__panic>

    assert(nr_free == 0);
  10394e:	a1 b8 89 11 00       	mov    0x1189b8,%eax
  103953:	85 c0                	test   %eax,%eax
  103955:	74 24                	je     10397b <default_check+0x591>
  103957:	c7 44 24 0c b9 68 10 	movl   $0x1068b9,0xc(%esp)
  10395e:	00 
  10395f:	c7 44 24 08 f6 66 10 	movl   $0x1066f6,0x8(%esp)
  103966:	00 
  103967:	c7 44 24 04 0e 01 00 	movl   $0x10e,0x4(%esp)
  10396e:	00 
  10396f:	c7 04 24 0b 67 10 00 	movl   $0x10670b,(%esp)
  103976:	e8 56 d3 ff ff       	call   100cd1 <__panic>
    nr_free = nr_free_store;
  10397b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10397e:	a3 b8 89 11 00       	mov    %eax,0x1189b8

    free_list = free_list_store;
  103983:	8b 45 80             	mov    -0x80(%ebp),%eax
  103986:	8b 55 84             	mov    -0x7c(%ebp),%edx
  103989:	a3 b0 89 11 00       	mov    %eax,0x1189b0
  10398e:	89 15 b4 89 11 00    	mov    %edx,0x1189b4
    free_pages(p0, 5);
  103994:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
  10399b:	00 
  10399c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10399f:	89 04 24             	mov    %eax,(%esp)
  1039a2:	e8 e9 03 00 00       	call   103d90 <free_pages>

    le = &free_list;
  1039a7:	c7 45 ec b0 89 11 00 	movl   $0x1189b0,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  1039ae:	eb 1d                	jmp    1039cd <default_check+0x5e3>
        struct Page *p = le2page(le, page_link);
  1039b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1039b3:	83 e8 0c             	sub    $0xc,%eax
  1039b6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        count --, total -= p->property;
  1039b9:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  1039bd:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1039c0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1039c3:	8b 40 08             	mov    0x8(%eax),%eax
  1039c6:	29 c2                	sub    %eax,%edx
  1039c8:	89 d0                	mov    %edx,%eax
  1039ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1039cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1039d0:	89 45 88             	mov    %eax,-0x78(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  1039d3:	8b 45 88             	mov    -0x78(%ebp),%eax
  1039d6:	8b 40 04             	mov    0x4(%eax),%eax

    free_list = free_list_store;
    free_pages(p0, 5);

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
  1039d9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1039dc:	81 7d ec b0 89 11 00 	cmpl   $0x1189b0,-0x14(%ebp)
  1039e3:	75 cb                	jne    1039b0 <default_check+0x5c6>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
    }
    assert(count == 0);
  1039e5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1039e9:	74 24                	je     103a0f <default_check+0x625>
  1039eb:	c7 44 24 0c 26 6a 10 	movl   $0x106a26,0xc(%esp)
  1039f2:	00 
  1039f3:	c7 44 24 08 f6 66 10 	movl   $0x1066f6,0x8(%esp)
  1039fa:	00 
  1039fb:	c7 44 24 04 19 01 00 	movl   $0x119,0x4(%esp)
  103a02:	00 
  103a03:	c7 04 24 0b 67 10 00 	movl   $0x10670b,(%esp)
  103a0a:	e8 c2 d2 ff ff       	call   100cd1 <__panic>
    assert(total == 0);
  103a0f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103a13:	74 24                	je     103a39 <default_check+0x64f>
  103a15:	c7 44 24 0c 31 6a 10 	movl   $0x106a31,0xc(%esp)
  103a1c:	00 
  103a1d:	c7 44 24 08 f6 66 10 	movl   $0x1066f6,0x8(%esp)
  103a24:	00 
  103a25:	c7 44 24 04 1a 01 00 	movl   $0x11a,0x4(%esp)
  103a2c:	00 
  103a2d:	c7 04 24 0b 67 10 00 	movl   $0x10670b,(%esp)
  103a34:	e8 98 d2 ff ff       	call   100cd1 <__panic>
}
  103a39:	81 c4 94 00 00 00    	add    $0x94,%esp
  103a3f:	5b                   	pop    %ebx
  103a40:	5d                   	pop    %ebp
  103a41:	c3                   	ret    

00103a42 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
  103a42:	55                   	push   %ebp
  103a43:	89 e5                	mov    %esp,%ebp
    return page - pages;
  103a45:	8b 55 08             	mov    0x8(%ebp),%edx
  103a48:	a1 c4 89 11 00       	mov    0x1189c4,%eax
  103a4d:	29 c2                	sub    %eax,%edx
  103a4f:	89 d0                	mov    %edx,%eax
  103a51:	c1 f8 02             	sar    $0x2,%eax
  103a54:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  103a5a:	5d                   	pop    %ebp
  103a5b:	c3                   	ret    

00103a5c <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
  103a5c:	55                   	push   %ebp
  103a5d:	89 e5                	mov    %esp,%ebp
  103a5f:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  103a62:	8b 45 08             	mov    0x8(%ebp),%eax
  103a65:	89 04 24             	mov    %eax,(%esp)
  103a68:	e8 d5 ff ff ff       	call   103a42 <page2ppn>
  103a6d:	c1 e0 0c             	shl    $0xc,%eax
}
  103a70:	c9                   	leave  
  103a71:	c3                   	ret    

00103a72 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
  103a72:	55                   	push   %ebp
  103a73:	89 e5                	mov    %esp,%ebp
  103a75:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
  103a78:	8b 45 08             	mov    0x8(%ebp),%eax
  103a7b:	c1 e8 0c             	shr    $0xc,%eax
  103a7e:	89 c2                	mov    %eax,%edx
  103a80:	a1 c0 88 11 00       	mov    0x1188c0,%eax
  103a85:	39 c2                	cmp    %eax,%edx
  103a87:	72 1c                	jb     103aa5 <pa2page+0x33>
        panic("pa2page called with invalid pa");
  103a89:	c7 44 24 08 6c 6a 10 	movl   $0x106a6c,0x8(%esp)
  103a90:	00 
  103a91:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  103a98:	00 
  103a99:	c7 04 24 8b 6a 10 00 	movl   $0x106a8b,(%esp)
  103aa0:	e8 2c d2 ff ff       	call   100cd1 <__panic>
    }
    return &pages[PPN(pa)];
  103aa5:	8b 0d c4 89 11 00    	mov    0x1189c4,%ecx
  103aab:	8b 45 08             	mov    0x8(%ebp),%eax
  103aae:	c1 e8 0c             	shr    $0xc,%eax
  103ab1:	89 c2                	mov    %eax,%edx
  103ab3:	89 d0                	mov    %edx,%eax
  103ab5:	c1 e0 02             	shl    $0x2,%eax
  103ab8:	01 d0                	add    %edx,%eax
  103aba:	c1 e0 02             	shl    $0x2,%eax
  103abd:	01 c8                	add    %ecx,%eax
}
  103abf:	c9                   	leave  
  103ac0:	c3                   	ret    

00103ac1 <page2kva>:

static inline void *
page2kva(struct Page *page) {
  103ac1:	55                   	push   %ebp
  103ac2:	89 e5                	mov    %esp,%ebp
  103ac4:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
  103ac7:	8b 45 08             	mov    0x8(%ebp),%eax
  103aca:	89 04 24             	mov    %eax,(%esp)
  103acd:	e8 8a ff ff ff       	call   103a5c <page2pa>
  103ad2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  103ad5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103ad8:	c1 e8 0c             	shr    $0xc,%eax
  103adb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103ade:	a1 c0 88 11 00       	mov    0x1188c0,%eax
  103ae3:	39 45 f0             	cmp    %eax,-0x10(%ebp)
  103ae6:	72 23                	jb     103b0b <page2kva+0x4a>
  103ae8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103aeb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103aef:	c7 44 24 08 9c 6a 10 	movl   $0x106a9c,0x8(%esp)
  103af6:	00 
  103af7:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  103afe:	00 
  103aff:	c7 04 24 8b 6a 10 00 	movl   $0x106a8b,(%esp)
  103b06:	e8 c6 d1 ff ff       	call   100cd1 <__panic>
  103b0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103b0e:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
  103b13:	c9                   	leave  
  103b14:	c3                   	ret    

00103b15 <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
  103b15:	55                   	push   %ebp
  103b16:	89 e5                	mov    %esp,%ebp
  103b18:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
  103b1b:	8b 45 08             	mov    0x8(%ebp),%eax
  103b1e:	83 e0 01             	and    $0x1,%eax
  103b21:	85 c0                	test   %eax,%eax
  103b23:	75 1c                	jne    103b41 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
  103b25:	c7 44 24 08 c0 6a 10 	movl   $0x106ac0,0x8(%esp)
  103b2c:	00 
  103b2d:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  103b34:	00 
  103b35:	c7 04 24 8b 6a 10 00 	movl   $0x106a8b,(%esp)
  103b3c:	e8 90 d1 ff ff       	call   100cd1 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
  103b41:	8b 45 08             	mov    0x8(%ebp),%eax
  103b44:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103b49:	89 04 24             	mov    %eax,(%esp)
  103b4c:	e8 21 ff ff ff       	call   103a72 <pa2page>
}
  103b51:	c9                   	leave  
  103b52:	c3                   	ret    

00103b53 <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
  103b53:	55                   	push   %ebp
  103b54:	89 e5                	mov    %esp,%ebp
    return page->ref;
  103b56:	8b 45 08             	mov    0x8(%ebp),%eax
  103b59:	8b 00                	mov    (%eax),%eax
}
  103b5b:	5d                   	pop    %ebp
  103b5c:	c3                   	ret    

00103b5d <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
  103b5d:	55                   	push   %ebp
  103b5e:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  103b60:	8b 45 08             	mov    0x8(%ebp),%eax
  103b63:	8b 55 0c             	mov    0xc(%ebp),%edx
  103b66:	89 10                	mov    %edx,(%eax)
}
  103b68:	5d                   	pop    %ebp
  103b69:	c3                   	ret    

00103b6a <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
  103b6a:	55                   	push   %ebp
  103b6b:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
  103b6d:	8b 45 08             	mov    0x8(%ebp),%eax
  103b70:	8b 00                	mov    (%eax),%eax
  103b72:	8d 50 01             	lea    0x1(%eax),%edx
  103b75:	8b 45 08             	mov    0x8(%ebp),%eax
  103b78:	89 10                	mov    %edx,(%eax)
    return page->ref;
  103b7a:	8b 45 08             	mov    0x8(%ebp),%eax
  103b7d:	8b 00                	mov    (%eax),%eax
}
  103b7f:	5d                   	pop    %ebp
  103b80:	c3                   	ret    

00103b81 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
  103b81:	55                   	push   %ebp
  103b82:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
  103b84:	8b 45 08             	mov    0x8(%ebp),%eax
  103b87:	8b 00                	mov    (%eax),%eax
  103b89:	8d 50 ff             	lea    -0x1(%eax),%edx
  103b8c:	8b 45 08             	mov    0x8(%ebp),%eax
  103b8f:	89 10                	mov    %edx,(%eax)
    return page->ref;
  103b91:	8b 45 08             	mov    0x8(%ebp),%eax
  103b94:	8b 00                	mov    (%eax),%eax
}
  103b96:	5d                   	pop    %ebp
  103b97:	c3                   	ret    

00103b98 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
  103b98:	55                   	push   %ebp
  103b99:	89 e5                	mov    %esp,%ebp
  103b9b:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
  103b9e:	9c                   	pushf  
  103b9f:	58                   	pop    %eax
  103ba0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
  103ba3:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
  103ba6:	25 00 02 00 00       	and    $0x200,%eax
  103bab:	85 c0                	test   %eax,%eax
  103bad:	74 0c                	je     103bbb <__intr_save+0x23>
        intr_disable();
  103baf:	e8 00 db ff ff       	call   1016b4 <intr_disable>
        return 1;
  103bb4:	b8 01 00 00 00       	mov    $0x1,%eax
  103bb9:	eb 05                	jmp    103bc0 <__intr_save+0x28>
    }
    return 0;
  103bbb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  103bc0:	c9                   	leave  
  103bc1:	c3                   	ret    

00103bc2 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
  103bc2:	55                   	push   %ebp
  103bc3:	89 e5                	mov    %esp,%ebp
  103bc5:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
  103bc8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  103bcc:	74 05                	je     103bd3 <__intr_restore+0x11>
        intr_enable();
  103bce:	e8 db da ff ff       	call   1016ae <intr_enable>
    }
}
  103bd3:	c9                   	leave  
  103bd4:	c3                   	ret    

00103bd5 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
  103bd5:	55                   	push   %ebp
  103bd6:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
  103bd8:	8b 45 08             	mov    0x8(%ebp),%eax
  103bdb:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
  103bde:	b8 23 00 00 00       	mov    $0x23,%eax
  103be3:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
  103be5:	b8 23 00 00 00       	mov    $0x23,%eax
  103bea:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
  103bec:	b8 10 00 00 00       	mov    $0x10,%eax
  103bf1:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
  103bf3:	b8 10 00 00 00       	mov    $0x10,%eax
  103bf8:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
  103bfa:	b8 10 00 00 00       	mov    $0x10,%eax
  103bff:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
  103c01:	ea 08 3c 10 00 08 00 	ljmp   $0x8,$0x103c08
}
  103c08:	5d                   	pop    %ebp
  103c09:	c3                   	ret    

00103c0a <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
  103c0a:	55                   	push   %ebp
  103c0b:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
  103c0d:	8b 45 08             	mov    0x8(%ebp),%eax
  103c10:	a3 e4 88 11 00       	mov    %eax,0x1188e4
}
  103c15:	5d                   	pop    %ebp
  103c16:	c3                   	ret    

00103c17 <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
  103c17:	55                   	push   %ebp
  103c18:	89 e5                	mov    %esp,%ebp
  103c1a:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
  103c1d:	b8 00 70 11 00       	mov    $0x117000,%eax
  103c22:	89 04 24             	mov    %eax,(%esp)
  103c25:	e8 e0 ff ff ff       	call   103c0a <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
  103c2a:	66 c7 05 e8 88 11 00 	movw   $0x10,0x1188e8
  103c31:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
  103c33:	66 c7 05 28 7a 11 00 	movw   $0x68,0x117a28
  103c3a:	68 00 
  103c3c:	b8 e0 88 11 00       	mov    $0x1188e0,%eax
  103c41:	66 a3 2a 7a 11 00    	mov    %ax,0x117a2a
  103c47:	b8 e0 88 11 00       	mov    $0x1188e0,%eax
  103c4c:	c1 e8 10             	shr    $0x10,%eax
  103c4f:	a2 2c 7a 11 00       	mov    %al,0x117a2c
  103c54:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  103c5b:	83 e0 f0             	and    $0xfffffff0,%eax
  103c5e:	83 c8 09             	or     $0x9,%eax
  103c61:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  103c66:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  103c6d:	83 e0 ef             	and    $0xffffffef,%eax
  103c70:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  103c75:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  103c7c:	83 e0 9f             	and    $0xffffff9f,%eax
  103c7f:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  103c84:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  103c8b:	83 c8 80             	or     $0xffffff80,%eax
  103c8e:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  103c93:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  103c9a:	83 e0 f0             	and    $0xfffffff0,%eax
  103c9d:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  103ca2:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  103ca9:	83 e0 ef             	and    $0xffffffef,%eax
  103cac:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  103cb1:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  103cb8:	83 e0 df             	and    $0xffffffdf,%eax
  103cbb:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  103cc0:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  103cc7:	83 c8 40             	or     $0x40,%eax
  103cca:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  103ccf:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  103cd6:	83 e0 7f             	and    $0x7f,%eax
  103cd9:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  103cde:	b8 e0 88 11 00       	mov    $0x1188e0,%eax
  103ce3:	c1 e8 18             	shr    $0x18,%eax
  103ce6:	a2 2f 7a 11 00       	mov    %al,0x117a2f

    // reload all segment registers
    lgdt(&gdt_pd);
  103ceb:	c7 04 24 30 7a 11 00 	movl   $0x117a30,(%esp)
  103cf2:	e8 de fe ff ff       	call   103bd5 <lgdt>
  103cf7:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("cli" ::: "memory");
}

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
  103cfd:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  103d01:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
  103d04:	c9                   	leave  
  103d05:	c3                   	ret    

00103d06 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
  103d06:	55                   	push   %ebp
  103d07:	89 e5                	mov    %esp,%ebp
  103d09:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
  103d0c:	c7 05 bc 89 11 00 50 	movl   $0x106a50,0x1189bc
  103d13:	6a 10 00 
    cprintf("memory management: %s\n", pmm_manager->name);
  103d16:	a1 bc 89 11 00       	mov    0x1189bc,%eax
  103d1b:	8b 00                	mov    (%eax),%eax
  103d1d:	89 44 24 04          	mov    %eax,0x4(%esp)
  103d21:	c7 04 24 ec 6a 10 00 	movl   $0x106aec,(%esp)
  103d28:	e8 1a c6 ff ff       	call   100347 <cprintf>
    pmm_manager->init();
  103d2d:	a1 bc 89 11 00       	mov    0x1189bc,%eax
  103d32:	8b 40 04             	mov    0x4(%eax),%eax
  103d35:	ff d0                	call   *%eax
}
  103d37:	c9                   	leave  
  103d38:	c3                   	ret    

00103d39 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
  103d39:	55                   	push   %ebp
  103d3a:	89 e5                	mov    %esp,%ebp
  103d3c:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
  103d3f:	a1 bc 89 11 00       	mov    0x1189bc,%eax
  103d44:	8b 40 08             	mov    0x8(%eax),%eax
  103d47:	8b 55 0c             	mov    0xc(%ebp),%edx
  103d4a:	89 54 24 04          	mov    %edx,0x4(%esp)
  103d4e:	8b 55 08             	mov    0x8(%ebp),%edx
  103d51:	89 14 24             	mov    %edx,(%esp)
  103d54:	ff d0                	call   *%eax
}
  103d56:	c9                   	leave  
  103d57:	c3                   	ret    

00103d58 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
  103d58:	55                   	push   %ebp
  103d59:	89 e5                	mov    %esp,%ebp
  103d5b:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
  103d5e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
  103d65:	e8 2e fe ff ff       	call   103b98 <__intr_save>
  103d6a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
  103d6d:	a1 bc 89 11 00       	mov    0x1189bc,%eax
  103d72:	8b 40 0c             	mov    0xc(%eax),%eax
  103d75:	8b 55 08             	mov    0x8(%ebp),%edx
  103d78:	89 14 24             	mov    %edx,(%esp)
  103d7b:	ff d0                	call   *%eax
  103d7d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
  103d80:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103d83:	89 04 24             	mov    %eax,(%esp)
  103d86:	e8 37 fe ff ff       	call   103bc2 <__intr_restore>
    return page;
  103d8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  103d8e:	c9                   	leave  
  103d8f:	c3                   	ret    

00103d90 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
  103d90:	55                   	push   %ebp
  103d91:	89 e5                	mov    %esp,%ebp
  103d93:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
  103d96:	e8 fd fd ff ff       	call   103b98 <__intr_save>
  103d9b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
  103d9e:	a1 bc 89 11 00       	mov    0x1189bc,%eax
  103da3:	8b 40 10             	mov    0x10(%eax),%eax
  103da6:	8b 55 0c             	mov    0xc(%ebp),%edx
  103da9:	89 54 24 04          	mov    %edx,0x4(%esp)
  103dad:	8b 55 08             	mov    0x8(%ebp),%edx
  103db0:	89 14 24             	mov    %edx,(%esp)
  103db3:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
  103db5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103db8:	89 04 24             	mov    %eax,(%esp)
  103dbb:	e8 02 fe ff ff       	call   103bc2 <__intr_restore>
}
  103dc0:	c9                   	leave  
  103dc1:	c3                   	ret    

00103dc2 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
  103dc2:	55                   	push   %ebp
  103dc3:	89 e5                	mov    %esp,%ebp
  103dc5:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
  103dc8:	e8 cb fd ff ff       	call   103b98 <__intr_save>
  103dcd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
  103dd0:	a1 bc 89 11 00       	mov    0x1189bc,%eax
  103dd5:	8b 40 14             	mov    0x14(%eax),%eax
  103dd8:	ff d0                	call   *%eax
  103dda:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
  103ddd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103de0:	89 04 24             	mov    %eax,(%esp)
  103de3:	e8 da fd ff ff       	call   103bc2 <__intr_restore>
    return ret;
  103de8:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  103deb:	c9                   	leave  
  103dec:	c3                   	ret    

00103ded <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
  103ded:	55                   	push   %ebp
  103dee:	89 e5                	mov    %esp,%ebp
  103df0:	57                   	push   %edi
  103df1:	56                   	push   %esi
  103df2:	53                   	push   %ebx
  103df3:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
  103df9:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
  103e00:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  103e07:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
  103e0e:	c7 04 24 03 6b 10 00 	movl   $0x106b03,(%esp)
  103e15:	e8 2d c5 ff ff       	call   100347 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
  103e1a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  103e21:	e9 15 01 00 00       	jmp    103f3b <page_init+0x14e>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  103e26:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  103e29:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103e2c:	89 d0                	mov    %edx,%eax
  103e2e:	c1 e0 02             	shl    $0x2,%eax
  103e31:	01 d0                	add    %edx,%eax
  103e33:	c1 e0 02             	shl    $0x2,%eax
  103e36:	01 c8                	add    %ecx,%eax
  103e38:	8b 50 08             	mov    0x8(%eax),%edx
  103e3b:	8b 40 04             	mov    0x4(%eax),%eax
  103e3e:	89 45 b8             	mov    %eax,-0x48(%ebp)
  103e41:	89 55 bc             	mov    %edx,-0x44(%ebp)
  103e44:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  103e47:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103e4a:	89 d0                	mov    %edx,%eax
  103e4c:	c1 e0 02             	shl    $0x2,%eax
  103e4f:	01 d0                	add    %edx,%eax
  103e51:	c1 e0 02             	shl    $0x2,%eax
  103e54:	01 c8                	add    %ecx,%eax
  103e56:	8b 48 0c             	mov    0xc(%eax),%ecx
  103e59:	8b 58 10             	mov    0x10(%eax),%ebx
  103e5c:	8b 45 b8             	mov    -0x48(%ebp),%eax
  103e5f:	8b 55 bc             	mov    -0x44(%ebp),%edx
  103e62:	01 c8                	add    %ecx,%eax
  103e64:	11 da                	adc    %ebx,%edx
  103e66:	89 45 b0             	mov    %eax,-0x50(%ebp)
  103e69:	89 55 b4             	mov    %edx,-0x4c(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
  103e6c:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  103e6f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103e72:	89 d0                	mov    %edx,%eax
  103e74:	c1 e0 02             	shl    $0x2,%eax
  103e77:	01 d0                	add    %edx,%eax
  103e79:	c1 e0 02             	shl    $0x2,%eax
  103e7c:	01 c8                	add    %ecx,%eax
  103e7e:	83 c0 14             	add    $0x14,%eax
  103e81:	8b 00                	mov    (%eax),%eax
  103e83:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
  103e89:	8b 45 b0             	mov    -0x50(%ebp),%eax
  103e8c:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  103e8f:	83 c0 ff             	add    $0xffffffff,%eax
  103e92:	83 d2 ff             	adc    $0xffffffff,%edx
  103e95:	89 c6                	mov    %eax,%esi
  103e97:	89 d7                	mov    %edx,%edi
  103e99:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  103e9c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103e9f:	89 d0                	mov    %edx,%eax
  103ea1:	c1 e0 02             	shl    $0x2,%eax
  103ea4:	01 d0                	add    %edx,%eax
  103ea6:	c1 e0 02             	shl    $0x2,%eax
  103ea9:	01 c8                	add    %ecx,%eax
  103eab:	8b 48 0c             	mov    0xc(%eax),%ecx
  103eae:	8b 58 10             	mov    0x10(%eax),%ebx
  103eb1:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
  103eb7:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  103ebb:	89 74 24 14          	mov    %esi,0x14(%esp)
  103ebf:	89 7c 24 18          	mov    %edi,0x18(%esp)
  103ec3:	8b 45 b8             	mov    -0x48(%ebp),%eax
  103ec6:	8b 55 bc             	mov    -0x44(%ebp),%edx
  103ec9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103ecd:	89 54 24 10          	mov    %edx,0x10(%esp)
  103ed1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  103ed5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  103ed9:	c7 04 24 10 6b 10 00 	movl   $0x106b10,(%esp)
  103ee0:	e8 62 c4 ff ff       	call   100347 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
  103ee5:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  103ee8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103eeb:	89 d0                	mov    %edx,%eax
  103eed:	c1 e0 02             	shl    $0x2,%eax
  103ef0:	01 d0                	add    %edx,%eax
  103ef2:	c1 e0 02             	shl    $0x2,%eax
  103ef5:	01 c8                	add    %ecx,%eax
  103ef7:	83 c0 14             	add    $0x14,%eax
  103efa:	8b 00                	mov    (%eax),%eax
  103efc:	83 f8 01             	cmp    $0x1,%eax
  103eff:	75 36                	jne    103f37 <page_init+0x14a>
            if (maxpa < end && begin < KMEMSIZE) {
  103f01:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103f04:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  103f07:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
  103f0a:	77 2b                	ja     103f37 <page_init+0x14a>
  103f0c:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
  103f0f:	72 05                	jb     103f16 <page_init+0x129>
  103f11:	3b 45 b0             	cmp    -0x50(%ebp),%eax
  103f14:	73 21                	jae    103f37 <page_init+0x14a>
  103f16:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
  103f1a:	77 1b                	ja     103f37 <page_init+0x14a>
  103f1c:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
  103f20:	72 09                	jb     103f2b <page_init+0x13e>
  103f22:	81 7d b8 ff ff ff 37 	cmpl   $0x37ffffff,-0x48(%ebp)
  103f29:	77 0c                	ja     103f37 <page_init+0x14a>
                maxpa = end;
  103f2b:	8b 45 b0             	mov    -0x50(%ebp),%eax
  103f2e:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  103f31:	89 45 e0             	mov    %eax,-0x20(%ebp)
  103f34:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
    uint64_t maxpa = 0;

    cprintf("e820map:\n");
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
  103f37:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
  103f3b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  103f3e:	8b 00                	mov    (%eax),%eax
  103f40:	3b 45 dc             	cmp    -0x24(%ebp),%eax
  103f43:	0f 8f dd fe ff ff    	jg     103e26 <page_init+0x39>
            if (maxpa < end && begin < KMEMSIZE) {
                maxpa = end;
            }
        }
    }
    if (maxpa > KMEMSIZE) {
  103f49:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  103f4d:	72 1d                	jb     103f6c <page_init+0x17f>
  103f4f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  103f53:	77 09                	ja     103f5e <page_init+0x171>
  103f55:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
  103f5c:	76 0e                	jbe    103f6c <page_init+0x17f>
        maxpa = KMEMSIZE;
  103f5e:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
  103f65:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
  103f6c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103f6f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  103f72:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  103f76:	c1 ea 0c             	shr    $0xc,%edx
  103f79:	a3 c0 88 11 00       	mov    %eax,0x1188c0
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
  103f7e:	c7 45 ac 00 10 00 00 	movl   $0x1000,-0x54(%ebp)
  103f85:	b8 c8 89 11 00       	mov    $0x1189c8,%eax
  103f8a:	8d 50 ff             	lea    -0x1(%eax),%edx
  103f8d:	8b 45 ac             	mov    -0x54(%ebp),%eax
  103f90:	01 d0                	add    %edx,%eax
  103f92:	89 45 a8             	mov    %eax,-0x58(%ebp)
  103f95:	8b 45 a8             	mov    -0x58(%ebp),%eax
  103f98:	ba 00 00 00 00       	mov    $0x0,%edx
  103f9d:	f7 75 ac             	divl   -0x54(%ebp)
  103fa0:	89 d0                	mov    %edx,%eax
  103fa2:	8b 55 a8             	mov    -0x58(%ebp),%edx
  103fa5:	29 c2                	sub    %eax,%edx
  103fa7:	89 d0                	mov    %edx,%eax
  103fa9:	a3 c4 89 11 00       	mov    %eax,0x1189c4

    for (i = 0; i < npage; i ++) {
  103fae:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  103fb5:	eb 2f                	jmp    103fe6 <page_init+0x1f9>
        SetPageReserved(pages + i);
  103fb7:	8b 0d c4 89 11 00    	mov    0x1189c4,%ecx
  103fbd:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103fc0:	89 d0                	mov    %edx,%eax
  103fc2:	c1 e0 02             	shl    $0x2,%eax
  103fc5:	01 d0                	add    %edx,%eax
  103fc7:	c1 e0 02             	shl    $0x2,%eax
  103fca:	01 c8                	add    %ecx,%eax
  103fcc:	83 c0 04             	add    $0x4,%eax
  103fcf:	c7 45 90 00 00 00 00 	movl   $0x0,-0x70(%ebp)
  103fd6:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  103fd9:	8b 45 8c             	mov    -0x74(%ebp),%eax
  103fdc:	8b 55 90             	mov    -0x70(%ebp),%edx
  103fdf:	0f ab 10             	bts    %edx,(%eax)
    extern char end[];

    npage = maxpa / PGSIZE;
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);

    for (i = 0; i < npage; i ++) {
  103fe2:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
  103fe6:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103fe9:	a1 c0 88 11 00       	mov    0x1188c0,%eax
  103fee:	39 c2                	cmp    %eax,%edx
  103ff0:	72 c5                	jb     103fb7 <page_init+0x1ca>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
  103ff2:	8b 15 c0 88 11 00    	mov    0x1188c0,%edx
  103ff8:	89 d0                	mov    %edx,%eax
  103ffa:	c1 e0 02             	shl    $0x2,%eax
  103ffd:	01 d0                	add    %edx,%eax
  103fff:	c1 e0 02             	shl    $0x2,%eax
  104002:	89 c2                	mov    %eax,%edx
  104004:	a1 c4 89 11 00       	mov    0x1189c4,%eax
  104009:	01 d0                	add    %edx,%eax
  10400b:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  10400e:	81 7d a4 ff ff ff bf 	cmpl   $0xbfffffff,-0x5c(%ebp)
  104015:	77 23                	ja     10403a <page_init+0x24d>
  104017:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  10401a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10401e:	c7 44 24 08 40 6b 10 	movl   $0x106b40,0x8(%esp)
  104025:	00 
  104026:	c7 44 24 04 db 00 00 	movl   $0xdb,0x4(%esp)
  10402d:	00 
  10402e:	c7 04 24 64 6b 10 00 	movl   $0x106b64,(%esp)
  104035:	e8 97 cc ff ff       	call   100cd1 <__panic>
  10403a:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  10403d:	05 00 00 00 40       	add    $0x40000000,%eax
  104042:	89 45 a0             	mov    %eax,-0x60(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
  104045:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  10404c:	e9 74 01 00 00       	jmp    1041c5 <page_init+0x3d8>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  104051:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  104054:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104057:	89 d0                	mov    %edx,%eax
  104059:	c1 e0 02             	shl    $0x2,%eax
  10405c:	01 d0                	add    %edx,%eax
  10405e:	c1 e0 02             	shl    $0x2,%eax
  104061:	01 c8                	add    %ecx,%eax
  104063:	8b 50 08             	mov    0x8(%eax),%edx
  104066:	8b 40 04             	mov    0x4(%eax),%eax
  104069:	89 45 d0             	mov    %eax,-0x30(%ebp)
  10406c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  10406f:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  104072:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104075:	89 d0                	mov    %edx,%eax
  104077:	c1 e0 02             	shl    $0x2,%eax
  10407a:	01 d0                	add    %edx,%eax
  10407c:	c1 e0 02             	shl    $0x2,%eax
  10407f:	01 c8                	add    %ecx,%eax
  104081:	8b 48 0c             	mov    0xc(%eax),%ecx
  104084:	8b 58 10             	mov    0x10(%eax),%ebx
  104087:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10408a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10408d:	01 c8                	add    %ecx,%eax
  10408f:	11 da                	adc    %ebx,%edx
  104091:	89 45 c8             	mov    %eax,-0x38(%ebp)
  104094:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
  104097:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  10409a:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10409d:	89 d0                	mov    %edx,%eax
  10409f:	c1 e0 02             	shl    $0x2,%eax
  1040a2:	01 d0                	add    %edx,%eax
  1040a4:	c1 e0 02             	shl    $0x2,%eax
  1040a7:	01 c8                	add    %ecx,%eax
  1040a9:	83 c0 14             	add    $0x14,%eax
  1040ac:	8b 00                	mov    (%eax),%eax
  1040ae:	83 f8 01             	cmp    $0x1,%eax
  1040b1:	0f 85 0a 01 00 00    	jne    1041c1 <page_init+0x3d4>
            if (begin < freemem) {
  1040b7:	8b 45 a0             	mov    -0x60(%ebp),%eax
  1040ba:	ba 00 00 00 00       	mov    $0x0,%edx
  1040bf:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  1040c2:	72 17                	jb     1040db <page_init+0x2ee>
  1040c4:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  1040c7:	77 05                	ja     1040ce <page_init+0x2e1>
  1040c9:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  1040cc:	76 0d                	jbe    1040db <page_init+0x2ee>
                begin = freemem;
  1040ce:	8b 45 a0             	mov    -0x60(%ebp),%eax
  1040d1:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1040d4:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
  1040db:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  1040df:	72 1d                	jb     1040fe <page_init+0x311>
  1040e1:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  1040e5:	77 09                	ja     1040f0 <page_init+0x303>
  1040e7:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
  1040ee:	76 0e                	jbe    1040fe <page_init+0x311>
                end = KMEMSIZE;
  1040f0:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
  1040f7:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
  1040fe:	8b 45 d0             	mov    -0x30(%ebp),%eax
  104101:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  104104:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  104107:	0f 87 b4 00 00 00    	ja     1041c1 <page_init+0x3d4>
  10410d:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  104110:	72 09                	jb     10411b <page_init+0x32e>
  104112:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  104115:	0f 83 a6 00 00 00    	jae    1041c1 <page_init+0x3d4>
                begin = ROUNDUP(begin, PGSIZE);
  10411b:	c7 45 9c 00 10 00 00 	movl   $0x1000,-0x64(%ebp)
  104122:	8b 55 d0             	mov    -0x30(%ebp),%edx
  104125:	8b 45 9c             	mov    -0x64(%ebp),%eax
  104128:	01 d0                	add    %edx,%eax
  10412a:	83 e8 01             	sub    $0x1,%eax
  10412d:	89 45 98             	mov    %eax,-0x68(%ebp)
  104130:	8b 45 98             	mov    -0x68(%ebp),%eax
  104133:	ba 00 00 00 00       	mov    $0x0,%edx
  104138:	f7 75 9c             	divl   -0x64(%ebp)
  10413b:	89 d0                	mov    %edx,%eax
  10413d:	8b 55 98             	mov    -0x68(%ebp),%edx
  104140:	29 c2                	sub    %eax,%edx
  104142:	89 d0                	mov    %edx,%eax
  104144:	ba 00 00 00 00       	mov    $0x0,%edx
  104149:	89 45 d0             	mov    %eax,-0x30(%ebp)
  10414c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
  10414f:	8b 45 c8             	mov    -0x38(%ebp),%eax
  104152:	89 45 94             	mov    %eax,-0x6c(%ebp)
  104155:	8b 45 94             	mov    -0x6c(%ebp),%eax
  104158:	ba 00 00 00 00       	mov    $0x0,%edx
  10415d:	89 c7                	mov    %eax,%edi
  10415f:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  104165:	89 7d 80             	mov    %edi,-0x80(%ebp)
  104168:	89 d0                	mov    %edx,%eax
  10416a:	83 e0 00             	and    $0x0,%eax
  10416d:	89 45 84             	mov    %eax,-0x7c(%ebp)
  104170:	8b 45 80             	mov    -0x80(%ebp),%eax
  104173:	8b 55 84             	mov    -0x7c(%ebp),%edx
  104176:	89 45 c8             	mov    %eax,-0x38(%ebp)
  104179:	89 55 cc             	mov    %edx,-0x34(%ebp)
                if (begin < end) {
  10417c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10417f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  104182:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  104185:	77 3a                	ja     1041c1 <page_init+0x3d4>
  104187:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  10418a:	72 05                	jb     104191 <page_init+0x3a4>
  10418c:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  10418f:	73 30                	jae    1041c1 <page_init+0x3d4>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
  104191:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  104194:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  104197:	8b 45 c8             	mov    -0x38(%ebp),%eax
  10419a:	8b 55 cc             	mov    -0x34(%ebp),%edx
  10419d:	29 c8                	sub    %ecx,%eax
  10419f:	19 da                	sbb    %ebx,%edx
  1041a1:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  1041a5:	c1 ea 0c             	shr    $0xc,%edx
  1041a8:	89 c3                	mov    %eax,%ebx
  1041aa:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1041ad:	89 04 24             	mov    %eax,(%esp)
  1041b0:	e8 bd f8 ff ff       	call   103a72 <pa2page>
  1041b5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  1041b9:	89 04 24             	mov    %eax,(%esp)
  1041bc:	e8 78 fb ff ff       	call   103d39 <init_memmap>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);

    for (i = 0; i < memmap->nr_map; i ++) {
  1041c1:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
  1041c5:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  1041c8:	8b 00                	mov    (%eax),%eax
  1041ca:	3b 45 dc             	cmp    -0x24(%ebp),%eax
  1041cd:	0f 8f 7e fe ff ff    	jg     104051 <page_init+0x264>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
                }
            }
        }
    }
}
  1041d3:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  1041d9:	5b                   	pop    %ebx
  1041da:	5e                   	pop    %esi
  1041db:	5f                   	pop    %edi
  1041dc:	5d                   	pop    %ebp
  1041dd:	c3                   	ret    

001041de <enable_paging>:

static void
enable_paging(void) {
  1041de:	55                   	push   %ebp
  1041df:	89 e5                	mov    %esp,%ebp
  1041e1:	83 ec 10             	sub    $0x10,%esp
    lcr3(boot_cr3);
  1041e4:	a1 c0 89 11 00       	mov    0x1189c0,%eax
  1041e9:	89 45 f8             	mov    %eax,-0x8(%ebp)
    asm volatile ("mov %0, %%cr0" :: "r" (cr0) : "memory");
}

static inline void
lcr3(uintptr_t cr3) {
    asm volatile ("mov %0, %%cr3" :: "r" (cr3) : "memory");
  1041ec:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1041ef:	0f 22 d8             	mov    %eax,%cr3
}

static inline uintptr_t
rcr0(void) {
    uintptr_t cr0;
    asm volatile ("mov %%cr0, %0" : "=r" (cr0) :: "memory");
  1041f2:	0f 20 c0             	mov    %cr0,%eax
  1041f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return cr0;
  1041f8:	8b 45 f4             	mov    -0xc(%ebp),%eax

    // turn on paging
    uint32_t cr0 = rcr0();
  1041fb:	89 45 fc             	mov    %eax,-0x4(%ebp)
    cr0 |= CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP;
  1041fe:	81 4d fc 2f 00 05 80 	orl    $0x8005002f,-0x4(%ebp)
    cr0 &= ~(CR0_TS | CR0_EM);
  104205:	83 65 fc f3          	andl   $0xfffffff3,-0x4(%ebp)
  104209:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10420c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile ("pushl %0; popfl" :: "r" (eflags));
}

static inline void
lcr0(uintptr_t cr0) {
    asm volatile ("mov %0, %%cr0" :: "r" (cr0) : "memory");
  10420f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104212:	0f 22 c0             	mov    %eax,%cr0
    lcr0(cr0);
}
  104215:	c9                   	leave  
  104216:	c3                   	ret    

00104217 <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
  104217:	55                   	push   %ebp
  104218:	89 e5                	mov    %esp,%ebp
  10421a:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
  10421d:	8b 45 14             	mov    0x14(%ebp),%eax
  104220:	8b 55 0c             	mov    0xc(%ebp),%edx
  104223:	31 d0                	xor    %edx,%eax
  104225:	25 ff 0f 00 00       	and    $0xfff,%eax
  10422a:	85 c0                	test   %eax,%eax
  10422c:	74 24                	je     104252 <boot_map_segment+0x3b>
  10422e:	c7 44 24 0c 72 6b 10 	movl   $0x106b72,0xc(%esp)
  104235:	00 
  104236:	c7 44 24 08 89 6b 10 	movl   $0x106b89,0x8(%esp)
  10423d:	00 
  10423e:	c7 44 24 04 04 01 00 	movl   $0x104,0x4(%esp)
  104245:	00 
  104246:	c7 04 24 64 6b 10 00 	movl   $0x106b64,(%esp)
  10424d:	e8 7f ca ff ff       	call   100cd1 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
  104252:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
  104259:	8b 45 0c             	mov    0xc(%ebp),%eax
  10425c:	25 ff 0f 00 00       	and    $0xfff,%eax
  104261:	89 c2                	mov    %eax,%edx
  104263:	8b 45 10             	mov    0x10(%ebp),%eax
  104266:	01 c2                	add    %eax,%edx
  104268:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10426b:	01 d0                	add    %edx,%eax
  10426d:	83 e8 01             	sub    $0x1,%eax
  104270:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104273:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104276:	ba 00 00 00 00       	mov    $0x0,%edx
  10427b:	f7 75 f0             	divl   -0x10(%ebp)
  10427e:	89 d0                	mov    %edx,%eax
  104280:	8b 55 ec             	mov    -0x14(%ebp),%edx
  104283:	29 c2                	sub    %eax,%edx
  104285:	89 d0                	mov    %edx,%eax
  104287:	c1 e8 0c             	shr    $0xc,%eax
  10428a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
  10428d:	8b 45 0c             	mov    0xc(%ebp),%eax
  104290:	89 45 e8             	mov    %eax,-0x18(%ebp)
  104293:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104296:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  10429b:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
  10429e:	8b 45 14             	mov    0x14(%ebp),%eax
  1042a1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1042a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1042a7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1042ac:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  1042af:	eb 6b                	jmp    10431c <boot_map_segment+0x105>
        pte_t *ptep = get_pte(pgdir, la, 1);
  1042b1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  1042b8:	00 
  1042b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  1042bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  1042c0:	8b 45 08             	mov    0x8(%ebp),%eax
  1042c3:	89 04 24             	mov    %eax,(%esp)
  1042c6:	e8 cc 01 00 00       	call   104497 <get_pte>
  1042cb:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
  1042ce:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  1042d2:	75 24                	jne    1042f8 <boot_map_segment+0xe1>
  1042d4:	c7 44 24 0c 9e 6b 10 	movl   $0x106b9e,0xc(%esp)
  1042db:	00 
  1042dc:	c7 44 24 08 89 6b 10 	movl   $0x106b89,0x8(%esp)
  1042e3:	00 
  1042e4:	c7 44 24 04 0a 01 00 	movl   $0x10a,0x4(%esp)
  1042eb:	00 
  1042ec:	c7 04 24 64 6b 10 00 	movl   $0x106b64,(%esp)
  1042f3:	e8 d9 c9 ff ff       	call   100cd1 <__panic>
        *ptep = pa | PTE_P | perm;
  1042f8:	8b 45 18             	mov    0x18(%ebp),%eax
  1042fb:	8b 55 14             	mov    0x14(%ebp),%edx
  1042fe:	09 d0                	or     %edx,%eax
  104300:	83 c8 01             	or     $0x1,%eax
  104303:	89 c2                	mov    %eax,%edx
  104305:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104308:	89 10                	mov    %edx,(%eax)
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
    assert(PGOFF(la) == PGOFF(pa));
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
    la = ROUNDDOWN(la, PGSIZE);
    pa = ROUNDDOWN(pa, PGSIZE);
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  10430a:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  10430e:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
  104315:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  10431c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  104320:	75 8f                	jne    1042b1 <boot_map_segment+0x9a>
        pte_t *ptep = get_pte(pgdir, la, 1);
        assert(ptep != NULL);
        *ptep = pa | PTE_P | perm;
    }
}
  104322:	c9                   	leave  
  104323:	c3                   	ret    

00104324 <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
  104324:	55                   	push   %ebp
  104325:	89 e5                	mov    %esp,%ebp
  104327:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
  10432a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104331:	e8 22 fa ff ff       	call   103d58 <alloc_pages>
  104336:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
  104339:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10433d:	75 1c                	jne    10435b <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
  10433f:	c7 44 24 08 ab 6b 10 	movl   $0x106bab,0x8(%esp)
  104346:	00 
  104347:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
  10434e:	00 
  10434f:	c7 04 24 64 6b 10 00 	movl   $0x106b64,(%esp)
  104356:	e8 76 c9 ff ff       	call   100cd1 <__panic>
    }
    return page2kva(p);
  10435b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10435e:	89 04 24             	mov    %eax,(%esp)
  104361:	e8 5b f7 ff ff       	call   103ac1 <page2kva>
}
  104366:	c9                   	leave  
  104367:	c3                   	ret    

00104368 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
  104368:	55                   	push   %ebp
  104369:	89 e5                	mov    %esp,%ebp
  10436b:	83 ec 38             	sub    $0x38,%esp
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
  10436e:	e8 93 f9 ff ff       	call   103d06 <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
  104373:	e8 75 fa ff ff       	call   103ded <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
  104378:	e8 66 04 00 00       	call   1047e3 <check_alloc_page>

    // create boot_pgdir, an initial page directory(Page Directory Table, PDT)
    boot_pgdir = boot_alloc_page();
  10437d:	e8 a2 ff ff ff       	call   104324 <boot_alloc_page>
  104382:	a3 c4 88 11 00       	mov    %eax,0x1188c4
    memset(boot_pgdir, 0, PGSIZE);
  104387:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  10438c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  104393:	00 
  104394:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  10439b:	00 
  10439c:	89 04 24             	mov    %eax,(%esp)
  10439f:	e8 a8 1a 00 00       	call   105e4c <memset>
    boot_cr3 = PADDR(boot_pgdir);
  1043a4:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  1043a9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1043ac:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
  1043b3:	77 23                	ja     1043d8 <pmm_init+0x70>
  1043b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1043b8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1043bc:	c7 44 24 08 40 6b 10 	movl   $0x106b40,0x8(%esp)
  1043c3:	00 
  1043c4:	c7 44 24 04 30 01 00 	movl   $0x130,0x4(%esp)
  1043cb:	00 
  1043cc:	c7 04 24 64 6b 10 00 	movl   $0x106b64,(%esp)
  1043d3:	e8 f9 c8 ff ff       	call   100cd1 <__panic>
  1043d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1043db:	05 00 00 00 40       	add    $0x40000000,%eax
  1043e0:	a3 c0 89 11 00       	mov    %eax,0x1189c0

    check_pgdir();
  1043e5:	e8 17 04 00 00       	call   104801 <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
  1043ea:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  1043ef:	8d 90 ac 0f 00 00    	lea    0xfac(%eax),%edx
  1043f5:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  1043fa:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1043fd:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
  104404:	77 23                	ja     104429 <pmm_init+0xc1>
  104406:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104409:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10440d:	c7 44 24 08 40 6b 10 	movl   $0x106b40,0x8(%esp)
  104414:	00 
  104415:	c7 44 24 04 38 01 00 	movl   $0x138,0x4(%esp)
  10441c:	00 
  10441d:	c7 04 24 64 6b 10 00 	movl   $0x106b64,(%esp)
  104424:	e8 a8 c8 ff ff       	call   100cd1 <__panic>
  104429:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10442c:	05 00 00 00 40       	add    $0x40000000,%eax
  104431:	83 c8 03             	or     $0x3,%eax
  104434:	89 02                	mov    %eax,(%edx)

    // map all physical memory to linear memory with base linear addr KERNBASE
    //linear_addr KERNBASE~KERNBASE+KMEMSIZE = phy_addr 0~KMEMSIZE
    //But shouldn't use this map until enable_paging() & gdt_init() finished.
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
  104436:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  10443b:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
  104442:	00 
  104443:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  10444a:	00 
  10444b:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
  104452:	38 
  104453:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
  10445a:	c0 
  10445b:	89 04 24             	mov    %eax,(%esp)
  10445e:	e8 b4 fd ff ff       	call   104217 <boot_map_segment>

    //temporary map: 
    //virtual_addr 3G~3G+4M = linear_addr 0~4M = linear_addr 3G~3G+4M = phy_addr 0~4M     
    boot_pgdir[0] = boot_pgdir[PDX(KERNBASE)];
  104463:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  104468:	8b 15 c4 88 11 00    	mov    0x1188c4,%edx
  10446e:	8b 92 00 0c 00 00    	mov    0xc00(%edx),%edx
  104474:	89 10                	mov    %edx,(%eax)

    enable_paging();
  104476:	e8 63 fd ff ff       	call   1041de <enable_paging>

    //reload gdt(third time,the last time) to map all physical memory
    //virtual_addr 0~4G=liear_addr 0~4G
    //then set kernel stack(ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
  10447b:	e8 97 f7 ff ff       	call   103c17 <gdt_init>

    //disable the map of virtual_addr 0~4M
    boot_pgdir[0] = 0;
  104480:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  104485:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
  10448b:	e8 0c 0a 00 00       	call   104e9c <check_boot_pgdir>

    print_pgdir();
  104490:	e8 99 0e 00 00       	call   10532e <print_pgdir>

}
  104495:	c9                   	leave  
  104496:	c3                   	ret    

00104497 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
  104497:	55                   	push   %ebp
  104498:	89 e5                	mov    %esp,%ebp
  10449a:	83 ec 38             	sub    $0x38,%esp
                          // (6) clear page content using memset
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
    pde_t *pdep = &pgdir[PDX(la)];
  10449d:	8b 45 0c             	mov    0xc(%ebp),%eax
  1044a0:	c1 e8 16             	shr    $0x16,%eax
  1044a3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  1044aa:	8b 45 08             	mov    0x8(%ebp),%eax
  1044ad:	01 d0                	add    %edx,%eax
  1044af:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!(*pdep & PTE_P)) {
  1044b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1044b5:	8b 00                	mov    (%eax),%eax
  1044b7:	83 e0 01             	and    $0x1,%eax
  1044ba:	85 c0                	test   %eax,%eax
  1044bc:	0f 85 af 00 00 00    	jne    104571 <get_pte+0xda>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
  1044c2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1044c6:	74 15                	je     1044dd <get_pte+0x46>
  1044c8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1044cf:	e8 84 f8 ff ff       	call   103d58 <alloc_pages>
  1044d4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1044d7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1044db:	75 0a                	jne    1044e7 <get_pte+0x50>
            return NULL;
  1044dd:	b8 00 00 00 00       	mov    $0x0,%eax
  1044e2:	e9 e6 00 00 00       	jmp    1045cd <get_pte+0x136>
        }
        set_page_ref(page, 1);
  1044e7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1044ee:	00 
  1044ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1044f2:	89 04 24             	mov    %eax,(%esp)
  1044f5:	e8 63 f6 ff ff       	call   103b5d <set_page_ref>
        uintptr_t pa = page2pa(page);
  1044fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1044fd:	89 04 24             	mov    %eax,(%esp)
  104500:	e8 57 f5 ff ff       	call   103a5c <page2pa>
  104505:	89 45 ec             	mov    %eax,-0x14(%ebp)
        memset(KADDR(pa), 0, PGSIZE);
  104508:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10450b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10450e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104511:	c1 e8 0c             	shr    $0xc,%eax
  104514:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  104517:	a1 c0 88 11 00       	mov    0x1188c0,%eax
  10451c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  10451f:	72 23                	jb     104544 <get_pte+0xad>
  104521:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104524:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104528:	c7 44 24 08 9c 6a 10 	movl   $0x106a9c,0x8(%esp)
  10452f:	00 
  104530:	c7 44 24 04 87 01 00 	movl   $0x187,0x4(%esp)
  104537:	00 
  104538:	c7 04 24 64 6b 10 00 	movl   $0x106b64,(%esp)
  10453f:	e8 8d c7 ff ff       	call   100cd1 <__panic>
  104544:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104547:	2d 00 00 00 40       	sub    $0x40000000,%eax
  10454c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  104553:	00 
  104554:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  10455b:	00 
  10455c:	89 04 24             	mov    %eax,(%esp)
  10455f:	e8 e8 18 00 00       	call   105e4c <memset>
        *pdep = pa | PTE_U | PTE_W | PTE_P;
  104564:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104567:	83 c8 07             	or     $0x7,%eax
  10456a:	89 c2                	mov    %eax,%edx
  10456c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10456f:	89 10                	mov    %edx,(%eax)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
  104571:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104574:	8b 00                	mov    (%eax),%eax
  104576:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  10457b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  10457e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104581:	c1 e8 0c             	shr    $0xc,%eax
  104584:	89 45 dc             	mov    %eax,-0x24(%ebp)
  104587:	a1 c0 88 11 00       	mov    0x1188c0,%eax
  10458c:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  10458f:	72 23                	jb     1045b4 <get_pte+0x11d>
  104591:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104594:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104598:	c7 44 24 08 9c 6a 10 	movl   $0x106a9c,0x8(%esp)
  10459f:	00 
  1045a0:	c7 44 24 04 8a 01 00 	movl   $0x18a,0x4(%esp)
  1045a7:	00 
  1045a8:	c7 04 24 64 6b 10 00 	movl   $0x106b64,(%esp)
  1045af:	e8 1d c7 ff ff       	call   100cd1 <__panic>
  1045b4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1045b7:	2d 00 00 00 40       	sub    $0x40000000,%eax
  1045bc:	8b 55 0c             	mov    0xc(%ebp),%edx
  1045bf:	c1 ea 0c             	shr    $0xc,%edx
  1045c2:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
  1045c8:	c1 e2 02             	shl    $0x2,%edx
  1045cb:	01 d0                	add    %edx,%eax
}
  1045cd:	c9                   	leave  
  1045ce:	c3                   	ret    

001045cf <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
  1045cf:	55                   	push   %ebp
  1045d0:	89 e5                	mov    %esp,%ebp
  1045d2:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
  1045d5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1045dc:	00 
  1045dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  1045e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  1045e4:	8b 45 08             	mov    0x8(%ebp),%eax
  1045e7:	89 04 24             	mov    %eax,(%esp)
  1045ea:	e8 a8 fe ff ff       	call   104497 <get_pte>
  1045ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
  1045f2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1045f6:	74 08                	je     104600 <get_page+0x31>
        *ptep_store = ptep;
  1045f8:	8b 45 10             	mov    0x10(%ebp),%eax
  1045fb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1045fe:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
  104600:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  104604:	74 1b                	je     104621 <get_page+0x52>
  104606:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104609:	8b 00                	mov    (%eax),%eax
  10460b:	83 e0 01             	and    $0x1,%eax
  10460e:	85 c0                	test   %eax,%eax
  104610:	74 0f                	je     104621 <get_page+0x52>
        return pa2page(*ptep);
  104612:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104615:	8b 00                	mov    (%eax),%eax
  104617:	89 04 24             	mov    %eax,(%esp)
  10461a:	e8 53 f4 ff ff       	call   103a72 <pa2page>
  10461f:	eb 05                	jmp    104626 <get_page+0x57>
    }
    return NULL;
  104621:	b8 00 00 00 00       	mov    $0x0,%eax
}
  104626:	c9                   	leave  
  104627:	c3                   	ret    

00104628 <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
  104628:	55                   	push   %ebp
  104629:	89 e5                	mov    %esp,%ebp
  10462b:	83 ec 28             	sub    $0x28,%esp
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
    if (*ptep & PTE_P) {
  10462e:	8b 45 10             	mov    0x10(%ebp),%eax
  104631:	8b 00                	mov    (%eax),%eax
  104633:	83 e0 01             	and    $0x1,%eax
  104636:	85 c0                	test   %eax,%eax
  104638:	74 4d                	je     104687 <page_remove_pte+0x5f>
        struct Page *page = pte2page(*ptep);
  10463a:	8b 45 10             	mov    0x10(%ebp),%eax
  10463d:	8b 00                	mov    (%eax),%eax
  10463f:	89 04 24             	mov    %eax,(%esp)
  104642:	e8 ce f4 ff ff       	call   103b15 <pte2page>
  104647:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (page_ref_dec(page) == 0) {
  10464a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10464d:	89 04 24             	mov    %eax,(%esp)
  104650:	e8 2c f5 ff ff       	call   103b81 <page_ref_dec>
  104655:	85 c0                	test   %eax,%eax
  104657:	75 13                	jne    10466c <page_remove_pte+0x44>
            free_page(page);
  104659:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104660:	00 
  104661:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104664:	89 04 24             	mov    %eax,(%esp)
  104667:	e8 24 f7 ff ff       	call   103d90 <free_pages>
        }
        *ptep = 0;
  10466c:	8b 45 10             	mov    0x10(%ebp),%eax
  10466f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la);
  104675:	8b 45 0c             	mov    0xc(%ebp),%eax
  104678:	89 44 24 04          	mov    %eax,0x4(%esp)
  10467c:	8b 45 08             	mov    0x8(%ebp),%eax
  10467f:	89 04 24             	mov    %eax,(%esp)
  104682:	e8 ff 00 00 00       	call   104786 <tlb_invalidate>
    }
}
  104687:	c9                   	leave  
  104688:	c3                   	ret    

00104689 <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
  104689:	55                   	push   %ebp
  10468a:	89 e5                	mov    %esp,%ebp
  10468c:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
  10468f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104696:	00 
  104697:	8b 45 0c             	mov    0xc(%ebp),%eax
  10469a:	89 44 24 04          	mov    %eax,0x4(%esp)
  10469e:	8b 45 08             	mov    0x8(%ebp),%eax
  1046a1:	89 04 24             	mov    %eax,(%esp)
  1046a4:	e8 ee fd ff ff       	call   104497 <get_pte>
  1046a9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
  1046ac:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1046b0:	74 19                	je     1046cb <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
  1046b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1046b5:	89 44 24 08          	mov    %eax,0x8(%esp)
  1046b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  1046bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  1046c0:	8b 45 08             	mov    0x8(%ebp),%eax
  1046c3:	89 04 24             	mov    %eax,(%esp)
  1046c6:	e8 5d ff ff ff       	call   104628 <page_remove_pte>
    }
}
  1046cb:	c9                   	leave  
  1046cc:	c3                   	ret    

001046cd <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
  1046cd:	55                   	push   %ebp
  1046ce:	89 e5                	mov    %esp,%ebp
  1046d0:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
  1046d3:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  1046da:	00 
  1046db:	8b 45 10             	mov    0x10(%ebp),%eax
  1046de:	89 44 24 04          	mov    %eax,0x4(%esp)
  1046e2:	8b 45 08             	mov    0x8(%ebp),%eax
  1046e5:	89 04 24             	mov    %eax,(%esp)
  1046e8:	e8 aa fd ff ff       	call   104497 <get_pte>
  1046ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
  1046f0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1046f4:	75 0a                	jne    104700 <page_insert+0x33>
        return -E_NO_MEM;
  1046f6:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  1046fb:	e9 84 00 00 00       	jmp    104784 <page_insert+0xb7>
    }
    page_ref_inc(page);
  104700:	8b 45 0c             	mov    0xc(%ebp),%eax
  104703:	89 04 24             	mov    %eax,(%esp)
  104706:	e8 5f f4 ff ff       	call   103b6a <page_ref_inc>
    if (*ptep & PTE_P) {
  10470b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10470e:	8b 00                	mov    (%eax),%eax
  104710:	83 e0 01             	and    $0x1,%eax
  104713:	85 c0                	test   %eax,%eax
  104715:	74 3e                	je     104755 <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
  104717:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10471a:	8b 00                	mov    (%eax),%eax
  10471c:	89 04 24             	mov    %eax,(%esp)
  10471f:	e8 f1 f3 ff ff       	call   103b15 <pte2page>
  104724:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
  104727:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10472a:	3b 45 0c             	cmp    0xc(%ebp),%eax
  10472d:	75 0d                	jne    10473c <page_insert+0x6f>
            page_ref_dec(page);
  10472f:	8b 45 0c             	mov    0xc(%ebp),%eax
  104732:	89 04 24             	mov    %eax,(%esp)
  104735:	e8 47 f4 ff ff       	call   103b81 <page_ref_dec>
  10473a:	eb 19                	jmp    104755 <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
  10473c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10473f:	89 44 24 08          	mov    %eax,0x8(%esp)
  104743:	8b 45 10             	mov    0x10(%ebp),%eax
  104746:	89 44 24 04          	mov    %eax,0x4(%esp)
  10474a:	8b 45 08             	mov    0x8(%ebp),%eax
  10474d:	89 04 24             	mov    %eax,(%esp)
  104750:	e8 d3 fe ff ff       	call   104628 <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
  104755:	8b 45 0c             	mov    0xc(%ebp),%eax
  104758:	89 04 24             	mov    %eax,(%esp)
  10475b:	e8 fc f2 ff ff       	call   103a5c <page2pa>
  104760:	0b 45 14             	or     0x14(%ebp),%eax
  104763:	83 c8 01             	or     $0x1,%eax
  104766:	89 c2                	mov    %eax,%edx
  104768:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10476b:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
  10476d:	8b 45 10             	mov    0x10(%ebp),%eax
  104770:	89 44 24 04          	mov    %eax,0x4(%esp)
  104774:	8b 45 08             	mov    0x8(%ebp),%eax
  104777:	89 04 24             	mov    %eax,(%esp)
  10477a:	e8 07 00 00 00       	call   104786 <tlb_invalidate>
    return 0;
  10477f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  104784:	c9                   	leave  
  104785:	c3                   	ret    

00104786 <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
  104786:	55                   	push   %ebp
  104787:	89 e5                	mov    %esp,%ebp
  104789:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
  10478c:	0f 20 d8             	mov    %cr3,%eax
  10478f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
  104792:	8b 45 f0             	mov    -0x10(%ebp),%eax
    if (rcr3() == PADDR(pgdir)) {
  104795:	89 c2                	mov    %eax,%edx
  104797:	8b 45 08             	mov    0x8(%ebp),%eax
  10479a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10479d:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
  1047a4:	77 23                	ja     1047c9 <tlb_invalidate+0x43>
  1047a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1047a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1047ad:	c7 44 24 08 40 6b 10 	movl   $0x106b40,0x8(%esp)
  1047b4:	00 
  1047b5:	c7 44 24 04 ec 01 00 	movl   $0x1ec,0x4(%esp)
  1047bc:	00 
  1047bd:	c7 04 24 64 6b 10 00 	movl   $0x106b64,(%esp)
  1047c4:	e8 08 c5 ff ff       	call   100cd1 <__panic>
  1047c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1047cc:	05 00 00 00 40       	add    $0x40000000,%eax
  1047d1:	39 c2                	cmp    %eax,%edx
  1047d3:	75 0c                	jne    1047e1 <tlb_invalidate+0x5b>
        invlpg((void *)la);
  1047d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  1047d8:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
  1047db:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1047de:	0f 01 38             	invlpg (%eax)
    }
}
  1047e1:	c9                   	leave  
  1047e2:	c3                   	ret    

001047e3 <check_alloc_page>:

static void
check_alloc_page(void) {
  1047e3:	55                   	push   %ebp
  1047e4:	89 e5                	mov    %esp,%ebp
  1047e6:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
  1047e9:	a1 bc 89 11 00       	mov    0x1189bc,%eax
  1047ee:	8b 40 18             	mov    0x18(%eax),%eax
  1047f1:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
  1047f3:	c7 04 24 c4 6b 10 00 	movl   $0x106bc4,(%esp)
  1047fa:	e8 48 bb ff ff       	call   100347 <cprintf>
}
  1047ff:	c9                   	leave  
  104800:	c3                   	ret    

00104801 <check_pgdir>:

static void
check_pgdir(void) {
  104801:	55                   	push   %ebp
  104802:	89 e5                	mov    %esp,%ebp
  104804:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
  104807:	a1 c0 88 11 00       	mov    0x1188c0,%eax
  10480c:	3d 00 80 03 00       	cmp    $0x38000,%eax
  104811:	76 24                	jbe    104837 <check_pgdir+0x36>
  104813:	c7 44 24 0c e3 6b 10 	movl   $0x106be3,0xc(%esp)
  10481a:	00 
  10481b:	c7 44 24 08 89 6b 10 	movl   $0x106b89,0x8(%esp)
  104822:	00 
  104823:	c7 44 24 04 f9 01 00 	movl   $0x1f9,0x4(%esp)
  10482a:	00 
  10482b:	c7 04 24 64 6b 10 00 	movl   $0x106b64,(%esp)
  104832:	e8 9a c4 ff ff       	call   100cd1 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
  104837:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  10483c:	85 c0                	test   %eax,%eax
  10483e:	74 0e                	je     10484e <check_pgdir+0x4d>
  104840:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  104845:	25 ff 0f 00 00       	and    $0xfff,%eax
  10484a:	85 c0                	test   %eax,%eax
  10484c:	74 24                	je     104872 <check_pgdir+0x71>
  10484e:	c7 44 24 0c 00 6c 10 	movl   $0x106c00,0xc(%esp)
  104855:	00 
  104856:	c7 44 24 08 89 6b 10 	movl   $0x106b89,0x8(%esp)
  10485d:	00 
  10485e:	c7 44 24 04 fa 01 00 	movl   $0x1fa,0x4(%esp)
  104865:	00 
  104866:	c7 04 24 64 6b 10 00 	movl   $0x106b64,(%esp)
  10486d:	e8 5f c4 ff ff       	call   100cd1 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
  104872:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  104877:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  10487e:	00 
  10487f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  104886:	00 
  104887:	89 04 24             	mov    %eax,(%esp)
  10488a:	e8 40 fd ff ff       	call   1045cf <get_page>
  10488f:	85 c0                	test   %eax,%eax
  104891:	74 24                	je     1048b7 <check_pgdir+0xb6>
  104893:	c7 44 24 0c 38 6c 10 	movl   $0x106c38,0xc(%esp)
  10489a:	00 
  10489b:	c7 44 24 08 89 6b 10 	movl   $0x106b89,0x8(%esp)
  1048a2:	00 
  1048a3:	c7 44 24 04 fb 01 00 	movl   $0x1fb,0x4(%esp)
  1048aa:	00 
  1048ab:	c7 04 24 64 6b 10 00 	movl   $0x106b64,(%esp)
  1048b2:	e8 1a c4 ff ff       	call   100cd1 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
  1048b7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1048be:	e8 95 f4 ff ff       	call   103d58 <alloc_pages>
  1048c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
  1048c6:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  1048cb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  1048d2:	00 
  1048d3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1048da:	00 
  1048db:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1048de:	89 54 24 04          	mov    %edx,0x4(%esp)
  1048e2:	89 04 24             	mov    %eax,(%esp)
  1048e5:	e8 e3 fd ff ff       	call   1046cd <page_insert>
  1048ea:	85 c0                	test   %eax,%eax
  1048ec:	74 24                	je     104912 <check_pgdir+0x111>
  1048ee:	c7 44 24 0c 60 6c 10 	movl   $0x106c60,0xc(%esp)
  1048f5:	00 
  1048f6:	c7 44 24 08 89 6b 10 	movl   $0x106b89,0x8(%esp)
  1048fd:	00 
  1048fe:	c7 44 24 04 ff 01 00 	movl   $0x1ff,0x4(%esp)
  104905:	00 
  104906:	c7 04 24 64 6b 10 00 	movl   $0x106b64,(%esp)
  10490d:	e8 bf c3 ff ff       	call   100cd1 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
  104912:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  104917:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  10491e:	00 
  10491f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  104926:	00 
  104927:	89 04 24             	mov    %eax,(%esp)
  10492a:	e8 68 fb ff ff       	call   104497 <get_pte>
  10492f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104932:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104936:	75 24                	jne    10495c <check_pgdir+0x15b>
  104938:	c7 44 24 0c 8c 6c 10 	movl   $0x106c8c,0xc(%esp)
  10493f:	00 
  104940:	c7 44 24 08 89 6b 10 	movl   $0x106b89,0x8(%esp)
  104947:	00 
  104948:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
  10494f:	00 
  104950:	c7 04 24 64 6b 10 00 	movl   $0x106b64,(%esp)
  104957:	e8 75 c3 ff ff       	call   100cd1 <__panic>
    assert(pa2page(*ptep) == p1);
  10495c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10495f:	8b 00                	mov    (%eax),%eax
  104961:	89 04 24             	mov    %eax,(%esp)
  104964:	e8 09 f1 ff ff       	call   103a72 <pa2page>
  104969:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  10496c:	74 24                	je     104992 <check_pgdir+0x191>
  10496e:	c7 44 24 0c b9 6c 10 	movl   $0x106cb9,0xc(%esp)
  104975:	00 
  104976:	c7 44 24 08 89 6b 10 	movl   $0x106b89,0x8(%esp)
  10497d:	00 
  10497e:	c7 44 24 04 03 02 00 	movl   $0x203,0x4(%esp)
  104985:	00 
  104986:	c7 04 24 64 6b 10 00 	movl   $0x106b64,(%esp)
  10498d:	e8 3f c3 ff ff       	call   100cd1 <__panic>
    assert(page_ref(p1) == 1);
  104992:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104995:	89 04 24             	mov    %eax,(%esp)
  104998:	e8 b6 f1 ff ff       	call   103b53 <page_ref>
  10499d:	83 f8 01             	cmp    $0x1,%eax
  1049a0:	74 24                	je     1049c6 <check_pgdir+0x1c5>
  1049a2:	c7 44 24 0c ce 6c 10 	movl   $0x106cce,0xc(%esp)
  1049a9:	00 
  1049aa:	c7 44 24 08 89 6b 10 	movl   $0x106b89,0x8(%esp)
  1049b1:	00 
  1049b2:	c7 44 24 04 04 02 00 	movl   $0x204,0x4(%esp)
  1049b9:	00 
  1049ba:	c7 04 24 64 6b 10 00 	movl   $0x106b64,(%esp)
  1049c1:	e8 0b c3 ff ff       	call   100cd1 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
  1049c6:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  1049cb:	8b 00                	mov    (%eax),%eax
  1049cd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1049d2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1049d5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1049d8:	c1 e8 0c             	shr    $0xc,%eax
  1049db:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1049de:	a1 c0 88 11 00       	mov    0x1188c0,%eax
  1049e3:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  1049e6:	72 23                	jb     104a0b <check_pgdir+0x20a>
  1049e8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1049eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1049ef:	c7 44 24 08 9c 6a 10 	movl   $0x106a9c,0x8(%esp)
  1049f6:	00 
  1049f7:	c7 44 24 04 06 02 00 	movl   $0x206,0x4(%esp)
  1049fe:	00 
  1049ff:	c7 04 24 64 6b 10 00 	movl   $0x106b64,(%esp)
  104a06:	e8 c6 c2 ff ff       	call   100cd1 <__panic>
  104a0b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104a0e:	2d 00 00 00 40       	sub    $0x40000000,%eax
  104a13:	83 c0 04             	add    $0x4,%eax
  104a16:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
  104a19:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  104a1e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104a25:	00 
  104a26:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  104a2d:	00 
  104a2e:	89 04 24             	mov    %eax,(%esp)
  104a31:	e8 61 fa ff ff       	call   104497 <get_pte>
  104a36:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  104a39:	74 24                	je     104a5f <check_pgdir+0x25e>
  104a3b:	c7 44 24 0c e0 6c 10 	movl   $0x106ce0,0xc(%esp)
  104a42:	00 
  104a43:	c7 44 24 08 89 6b 10 	movl   $0x106b89,0x8(%esp)
  104a4a:	00 
  104a4b:	c7 44 24 04 07 02 00 	movl   $0x207,0x4(%esp)
  104a52:	00 
  104a53:	c7 04 24 64 6b 10 00 	movl   $0x106b64,(%esp)
  104a5a:	e8 72 c2 ff ff       	call   100cd1 <__panic>

    p2 = alloc_page();
  104a5f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104a66:	e8 ed f2 ff ff       	call   103d58 <alloc_pages>
  104a6b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
  104a6e:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  104a73:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  104a7a:	00 
  104a7b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  104a82:	00 
  104a83:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  104a86:	89 54 24 04          	mov    %edx,0x4(%esp)
  104a8a:	89 04 24             	mov    %eax,(%esp)
  104a8d:	e8 3b fc ff ff       	call   1046cd <page_insert>
  104a92:	85 c0                	test   %eax,%eax
  104a94:	74 24                	je     104aba <check_pgdir+0x2b9>
  104a96:	c7 44 24 0c 08 6d 10 	movl   $0x106d08,0xc(%esp)
  104a9d:	00 
  104a9e:	c7 44 24 08 89 6b 10 	movl   $0x106b89,0x8(%esp)
  104aa5:	00 
  104aa6:	c7 44 24 04 0a 02 00 	movl   $0x20a,0x4(%esp)
  104aad:	00 
  104aae:	c7 04 24 64 6b 10 00 	movl   $0x106b64,(%esp)
  104ab5:	e8 17 c2 ff ff       	call   100cd1 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  104aba:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  104abf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104ac6:	00 
  104ac7:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  104ace:	00 
  104acf:	89 04 24             	mov    %eax,(%esp)
  104ad2:	e8 c0 f9 ff ff       	call   104497 <get_pte>
  104ad7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104ada:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104ade:	75 24                	jne    104b04 <check_pgdir+0x303>
  104ae0:	c7 44 24 0c 40 6d 10 	movl   $0x106d40,0xc(%esp)
  104ae7:	00 
  104ae8:	c7 44 24 08 89 6b 10 	movl   $0x106b89,0x8(%esp)
  104aef:	00 
  104af0:	c7 44 24 04 0b 02 00 	movl   $0x20b,0x4(%esp)
  104af7:	00 
  104af8:	c7 04 24 64 6b 10 00 	movl   $0x106b64,(%esp)
  104aff:	e8 cd c1 ff ff       	call   100cd1 <__panic>
    assert(*ptep & PTE_U);
  104b04:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104b07:	8b 00                	mov    (%eax),%eax
  104b09:	83 e0 04             	and    $0x4,%eax
  104b0c:	85 c0                	test   %eax,%eax
  104b0e:	75 24                	jne    104b34 <check_pgdir+0x333>
  104b10:	c7 44 24 0c 70 6d 10 	movl   $0x106d70,0xc(%esp)
  104b17:	00 
  104b18:	c7 44 24 08 89 6b 10 	movl   $0x106b89,0x8(%esp)
  104b1f:	00 
  104b20:	c7 44 24 04 0c 02 00 	movl   $0x20c,0x4(%esp)
  104b27:	00 
  104b28:	c7 04 24 64 6b 10 00 	movl   $0x106b64,(%esp)
  104b2f:	e8 9d c1 ff ff       	call   100cd1 <__panic>
    assert(*ptep & PTE_W);
  104b34:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104b37:	8b 00                	mov    (%eax),%eax
  104b39:	83 e0 02             	and    $0x2,%eax
  104b3c:	85 c0                	test   %eax,%eax
  104b3e:	75 24                	jne    104b64 <check_pgdir+0x363>
  104b40:	c7 44 24 0c 7e 6d 10 	movl   $0x106d7e,0xc(%esp)
  104b47:	00 
  104b48:	c7 44 24 08 89 6b 10 	movl   $0x106b89,0x8(%esp)
  104b4f:	00 
  104b50:	c7 44 24 04 0d 02 00 	movl   $0x20d,0x4(%esp)
  104b57:	00 
  104b58:	c7 04 24 64 6b 10 00 	movl   $0x106b64,(%esp)
  104b5f:	e8 6d c1 ff ff       	call   100cd1 <__panic>
    assert(boot_pgdir[0] & PTE_U);
  104b64:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  104b69:	8b 00                	mov    (%eax),%eax
  104b6b:	83 e0 04             	and    $0x4,%eax
  104b6e:	85 c0                	test   %eax,%eax
  104b70:	75 24                	jne    104b96 <check_pgdir+0x395>
  104b72:	c7 44 24 0c 8c 6d 10 	movl   $0x106d8c,0xc(%esp)
  104b79:	00 
  104b7a:	c7 44 24 08 89 6b 10 	movl   $0x106b89,0x8(%esp)
  104b81:	00 
  104b82:	c7 44 24 04 0e 02 00 	movl   $0x20e,0x4(%esp)
  104b89:	00 
  104b8a:	c7 04 24 64 6b 10 00 	movl   $0x106b64,(%esp)
  104b91:	e8 3b c1 ff ff       	call   100cd1 <__panic>
    assert(page_ref(p2) == 1);
  104b96:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104b99:	89 04 24             	mov    %eax,(%esp)
  104b9c:	e8 b2 ef ff ff       	call   103b53 <page_ref>
  104ba1:	83 f8 01             	cmp    $0x1,%eax
  104ba4:	74 24                	je     104bca <check_pgdir+0x3c9>
  104ba6:	c7 44 24 0c a2 6d 10 	movl   $0x106da2,0xc(%esp)
  104bad:	00 
  104bae:	c7 44 24 08 89 6b 10 	movl   $0x106b89,0x8(%esp)
  104bb5:	00 
  104bb6:	c7 44 24 04 0f 02 00 	movl   $0x20f,0x4(%esp)
  104bbd:	00 
  104bbe:	c7 04 24 64 6b 10 00 	movl   $0x106b64,(%esp)
  104bc5:	e8 07 c1 ff ff       	call   100cd1 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
  104bca:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  104bcf:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  104bd6:	00 
  104bd7:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  104bde:	00 
  104bdf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  104be2:	89 54 24 04          	mov    %edx,0x4(%esp)
  104be6:	89 04 24             	mov    %eax,(%esp)
  104be9:	e8 df fa ff ff       	call   1046cd <page_insert>
  104bee:	85 c0                	test   %eax,%eax
  104bf0:	74 24                	je     104c16 <check_pgdir+0x415>
  104bf2:	c7 44 24 0c b4 6d 10 	movl   $0x106db4,0xc(%esp)
  104bf9:	00 
  104bfa:	c7 44 24 08 89 6b 10 	movl   $0x106b89,0x8(%esp)
  104c01:	00 
  104c02:	c7 44 24 04 11 02 00 	movl   $0x211,0x4(%esp)
  104c09:	00 
  104c0a:	c7 04 24 64 6b 10 00 	movl   $0x106b64,(%esp)
  104c11:	e8 bb c0 ff ff       	call   100cd1 <__panic>
    assert(page_ref(p1) == 2);
  104c16:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104c19:	89 04 24             	mov    %eax,(%esp)
  104c1c:	e8 32 ef ff ff       	call   103b53 <page_ref>
  104c21:	83 f8 02             	cmp    $0x2,%eax
  104c24:	74 24                	je     104c4a <check_pgdir+0x449>
  104c26:	c7 44 24 0c e0 6d 10 	movl   $0x106de0,0xc(%esp)
  104c2d:	00 
  104c2e:	c7 44 24 08 89 6b 10 	movl   $0x106b89,0x8(%esp)
  104c35:	00 
  104c36:	c7 44 24 04 12 02 00 	movl   $0x212,0x4(%esp)
  104c3d:	00 
  104c3e:	c7 04 24 64 6b 10 00 	movl   $0x106b64,(%esp)
  104c45:	e8 87 c0 ff ff       	call   100cd1 <__panic>
    assert(page_ref(p2) == 0);
  104c4a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104c4d:	89 04 24             	mov    %eax,(%esp)
  104c50:	e8 fe ee ff ff       	call   103b53 <page_ref>
  104c55:	85 c0                	test   %eax,%eax
  104c57:	74 24                	je     104c7d <check_pgdir+0x47c>
  104c59:	c7 44 24 0c f2 6d 10 	movl   $0x106df2,0xc(%esp)
  104c60:	00 
  104c61:	c7 44 24 08 89 6b 10 	movl   $0x106b89,0x8(%esp)
  104c68:	00 
  104c69:	c7 44 24 04 13 02 00 	movl   $0x213,0x4(%esp)
  104c70:	00 
  104c71:	c7 04 24 64 6b 10 00 	movl   $0x106b64,(%esp)
  104c78:	e8 54 c0 ff ff       	call   100cd1 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  104c7d:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  104c82:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104c89:	00 
  104c8a:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  104c91:	00 
  104c92:	89 04 24             	mov    %eax,(%esp)
  104c95:	e8 fd f7 ff ff       	call   104497 <get_pte>
  104c9a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104c9d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104ca1:	75 24                	jne    104cc7 <check_pgdir+0x4c6>
  104ca3:	c7 44 24 0c 40 6d 10 	movl   $0x106d40,0xc(%esp)
  104caa:	00 
  104cab:	c7 44 24 08 89 6b 10 	movl   $0x106b89,0x8(%esp)
  104cb2:	00 
  104cb3:	c7 44 24 04 14 02 00 	movl   $0x214,0x4(%esp)
  104cba:	00 
  104cbb:	c7 04 24 64 6b 10 00 	movl   $0x106b64,(%esp)
  104cc2:	e8 0a c0 ff ff       	call   100cd1 <__panic>
    assert(pa2page(*ptep) == p1);
  104cc7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104cca:	8b 00                	mov    (%eax),%eax
  104ccc:	89 04 24             	mov    %eax,(%esp)
  104ccf:	e8 9e ed ff ff       	call   103a72 <pa2page>
  104cd4:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  104cd7:	74 24                	je     104cfd <check_pgdir+0x4fc>
  104cd9:	c7 44 24 0c b9 6c 10 	movl   $0x106cb9,0xc(%esp)
  104ce0:	00 
  104ce1:	c7 44 24 08 89 6b 10 	movl   $0x106b89,0x8(%esp)
  104ce8:	00 
  104ce9:	c7 44 24 04 15 02 00 	movl   $0x215,0x4(%esp)
  104cf0:	00 
  104cf1:	c7 04 24 64 6b 10 00 	movl   $0x106b64,(%esp)
  104cf8:	e8 d4 bf ff ff       	call   100cd1 <__panic>
    assert((*ptep & PTE_U) == 0);
  104cfd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104d00:	8b 00                	mov    (%eax),%eax
  104d02:	83 e0 04             	and    $0x4,%eax
  104d05:	85 c0                	test   %eax,%eax
  104d07:	74 24                	je     104d2d <check_pgdir+0x52c>
  104d09:	c7 44 24 0c 04 6e 10 	movl   $0x106e04,0xc(%esp)
  104d10:	00 
  104d11:	c7 44 24 08 89 6b 10 	movl   $0x106b89,0x8(%esp)
  104d18:	00 
  104d19:	c7 44 24 04 16 02 00 	movl   $0x216,0x4(%esp)
  104d20:	00 
  104d21:	c7 04 24 64 6b 10 00 	movl   $0x106b64,(%esp)
  104d28:	e8 a4 bf ff ff       	call   100cd1 <__panic>

    page_remove(boot_pgdir, 0x0);
  104d2d:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  104d32:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  104d39:	00 
  104d3a:	89 04 24             	mov    %eax,(%esp)
  104d3d:	e8 47 f9 ff ff       	call   104689 <page_remove>
    assert(page_ref(p1) == 1);
  104d42:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104d45:	89 04 24             	mov    %eax,(%esp)
  104d48:	e8 06 ee ff ff       	call   103b53 <page_ref>
  104d4d:	83 f8 01             	cmp    $0x1,%eax
  104d50:	74 24                	je     104d76 <check_pgdir+0x575>
  104d52:	c7 44 24 0c ce 6c 10 	movl   $0x106cce,0xc(%esp)
  104d59:	00 
  104d5a:	c7 44 24 08 89 6b 10 	movl   $0x106b89,0x8(%esp)
  104d61:	00 
  104d62:	c7 44 24 04 19 02 00 	movl   $0x219,0x4(%esp)
  104d69:	00 
  104d6a:	c7 04 24 64 6b 10 00 	movl   $0x106b64,(%esp)
  104d71:	e8 5b bf ff ff       	call   100cd1 <__panic>
    assert(page_ref(p2) == 0);
  104d76:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104d79:	89 04 24             	mov    %eax,(%esp)
  104d7c:	e8 d2 ed ff ff       	call   103b53 <page_ref>
  104d81:	85 c0                	test   %eax,%eax
  104d83:	74 24                	je     104da9 <check_pgdir+0x5a8>
  104d85:	c7 44 24 0c f2 6d 10 	movl   $0x106df2,0xc(%esp)
  104d8c:	00 
  104d8d:	c7 44 24 08 89 6b 10 	movl   $0x106b89,0x8(%esp)
  104d94:	00 
  104d95:	c7 44 24 04 1a 02 00 	movl   $0x21a,0x4(%esp)
  104d9c:	00 
  104d9d:	c7 04 24 64 6b 10 00 	movl   $0x106b64,(%esp)
  104da4:	e8 28 bf ff ff       	call   100cd1 <__panic>

    page_remove(boot_pgdir, PGSIZE);
  104da9:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  104dae:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  104db5:	00 
  104db6:	89 04 24             	mov    %eax,(%esp)
  104db9:	e8 cb f8 ff ff       	call   104689 <page_remove>
    assert(page_ref(p1) == 0);
  104dbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104dc1:	89 04 24             	mov    %eax,(%esp)
  104dc4:	e8 8a ed ff ff       	call   103b53 <page_ref>
  104dc9:	85 c0                	test   %eax,%eax
  104dcb:	74 24                	je     104df1 <check_pgdir+0x5f0>
  104dcd:	c7 44 24 0c 19 6e 10 	movl   $0x106e19,0xc(%esp)
  104dd4:	00 
  104dd5:	c7 44 24 08 89 6b 10 	movl   $0x106b89,0x8(%esp)
  104ddc:	00 
  104ddd:	c7 44 24 04 1d 02 00 	movl   $0x21d,0x4(%esp)
  104de4:	00 
  104de5:	c7 04 24 64 6b 10 00 	movl   $0x106b64,(%esp)
  104dec:	e8 e0 be ff ff       	call   100cd1 <__panic>
    assert(page_ref(p2) == 0);
  104df1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104df4:	89 04 24             	mov    %eax,(%esp)
  104df7:	e8 57 ed ff ff       	call   103b53 <page_ref>
  104dfc:	85 c0                	test   %eax,%eax
  104dfe:	74 24                	je     104e24 <check_pgdir+0x623>
  104e00:	c7 44 24 0c f2 6d 10 	movl   $0x106df2,0xc(%esp)
  104e07:	00 
  104e08:	c7 44 24 08 89 6b 10 	movl   $0x106b89,0x8(%esp)
  104e0f:	00 
  104e10:	c7 44 24 04 1e 02 00 	movl   $0x21e,0x4(%esp)
  104e17:	00 
  104e18:	c7 04 24 64 6b 10 00 	movl   $0x106b64,(%esp)
  104e1f:	e8 ad be ff ff       	call   100cd1 <__panic>

    assert(page_ref(pa2page(boot_pgdir[0])) == 1);
  104e24:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  104e29:	8b 00                	mov    (%eax),%eax
  104e2b:	89 04 24             	mov    %eax,(%esp)
  104e2e:	e8 3f ec ff ff       	call   103a72 <pa2page>
  104e33:	89 04 24             	mov    %eax,(%esp)
  104e36:	e8 18 ed ff ff       	call   103b53 <page_ref>
  104e3b:	83 f8 01             	cmp    $0x1,%eax
  104e3e:	74 24                	je     104e64 <check_pgdir+0x663>
  104e40:	c7 44 24 0c 2c 6e 10 	movl   $0x106e2c,0xc(%esp)
  104e47:	00 
  104e48:	c7 44 24 08 89 6b 10 	movl   $0x106b89,0x8(%esp)
  104e4f:	00 
  104e50:	c7 44 24 04 20 02 00 	movl   $0x220,0x4(%esp)
  104e57:	00 
  104e58:	c7 04 24 64 6b 10 00 	movl   $0x106b64,(%esp)
  104e5f:	e8 6d be ff ff       	call   100cd1 <__panic>
    free_page(pa2page(boot_pgdir[0]));
  104e64:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  104e69:	8b 00                	mov    (%eax),%eax
  104e6b:	89 04 24             	mov    %eax,(%esp)
  104e6e:	e8 ff eb ff ff       	call   103a72 <pa2page>
  104e73:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104e7a:	00 
  104e7b:	89 04 24             	mov    %eax,(%esp)
  104e7e:	e8 0d ef ff ff       	call   103d90 <free_pages>
    boot_pgdir[0] = 0;
  104e83:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  104e88:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
  104e8e:	c7 04 24 52 6e 10 00 	movl   $0x106e52,(%esp)
  104e95:	e8 ad b4 ff ff       	call   100347 <cprintf>
}
  104e9a:	c9                   	leave  
  104e9b:	c3                   	ret    

00104e9c <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
  104e9c:	55                   	push   %ebp
  104e9d:	89 e5                	mov    %esp,%ebp
  104e9f:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
  104ea2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  104ea9:	e9 ca 00 00 00       	jmp    104f78 <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
  104eae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104eb1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104eb4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104eb7:	c1 e8 0c             	shr    $0xc,%eax
  104eba:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104ebd:	a1 c0 88 11 00       	mov    0x1188c0,%eax
  104ec2:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  104ec5:	72 23                	jb     104eea <check_boot_pgdir+0x4e>
  104ec7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104eca:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104ece:	c7 44 24 08 9c 6a 10 	movl   $0x106a9c,0x8(%esp)
  104ed5:	00 
  104ed6:	c7 44 24 04 2c 02 00 	movl   $0x22c,0x4(%esp)
  104edd:	00 
  104ede:	c7 04 24 64 6b 10 00 	movl   $0x106b64,(%esp)
  104ee5:	e8 e7 bd ff ff       	call   100cd1 <__panic>
  104eea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104eed:	2d 00 00 00 40       	sub    $0x40000000,%eax
  104ef2:	89 c2                	mov    %eax,%edx
  104ef4:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  104ef9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104f00:	00 
  104f01:	89 54 24 04          	mov    %edx,0x4(%esp)
  104f05:	89 04 24             	mov    %eax,(%esp)
  104f08:	e8 8a f5 ff ff       	call   104497 <get_pte>
  104f0d:	89 45 e8             	mov    %eax,-0x18(%ebp)
  104f10:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  104f14:	75 24                	jne    104f3a <check_boot_pgdir+0x9e>
  104f16:	c7 44 24 0c 6c 6e 10 	movl   $0x106e6c,0xc(%esp)
  104f1d:	00 
  104f1e:	c7 44 24 08 89 6b 10 	movl   $0x106b89,0x8(%esp)
  104f25:	00 
  104f26:	c7 44 24 04 2c 02 00 	movl   $0x22c,0x4(%esp)
  104f2d:	00 
  104f2e:	c7 04 24 64 6b 10 00 	movl   $0x106b64,(%esp)
  104f35:	e8 97 bd ff ff       	call   100cd1 <__panic>
        assert(PTE_ADDR(*ptep) == i);
  104f3a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104f3d:	8b 00                	mov    (%eax),%eax
  104f3f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  104f44:	89 c2                	mov    %eax,%edx
  104f46:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104f49:	39 c2                	cmp    %eax,%edx
  104f4b:	74 24                	je     104f71 <check_boot_pgdir+0xd5>
  104f4d:	c7 44 24 0c a9 6e 10 	movl   $0x106ea9,0xc(%esp)
  104f54:	00 
  104f55:	c7 44 24 08 89 6b 10 	movl   $0x106b89,0x8(%esp)
  104f5c:	00 
  104f5d:	c7 44 24 04 2d 02 00 	movl   $0x22d,0x4(%esp)
  104f64:	00 
  104f65:	c7 04 24 64 6b 10 00 	movl   $0x106b64,(%esp)
  104f6c:	e8 60 bd ff ff       	call   100cd1 <__panic>

static void
check_boot_pgdir(void) {
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
  104f71:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  104f78:	8b 55 f4             	mov    -0xc(%ebp),%edx
  104f7b:	a1 c0 88 11 00       	mov    0x1188c0,%eax
  104f80:	39 c2                	cmp    %eax,%edx
  104f82:	0f 82 26 ff ff ff    	jb     104eae <check_boot_pgdir+0x12>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
  104f88:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  104f8d:	05 ac 0f 00 00       	add    $0xfac,%eax
  104f92:	8b 00                	mov    (%eax),%eax
  104f94:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  104f99:	89 c2                	mov    %eax,%edx
  104f9b:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  104fa0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  104fa3:	81 7d e4 ff ff ff bf 	cmpl   $0xbfffffff,-0x1c(%ebp)
  104faa:	77 23                	ja     104fcf <check_boot_pgdir+0x133>
  104fac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104faf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104fb3:	c7 44 24 08 40 6b 10 	movl   $0x106b40,0x8(%esp)
  104fba:	00 
  104fbb:	c7 44 24 04 30 02 00 	movl   $0x230,0x4(%esp)
  104fc2:	00 
  104fc3:	c7 04 24 64 6b 10 00 	movl   $0x106b64,(%esp)
  104fca:	e8 02 bd ff ff       	call   100cd1 <__panic>
  104fcf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104fd2:	05 00 00 00 40       	add    $0x40000000,%eax
  104fd7:	39 c2                	cmp    %eax,%edx
  104fd9:	74 24                	je     104fff <check_boot_pgdir+0x163>
  104fdb:	c7 44 24 0c c0 6e 10 	movl   $0x106ec0,0xc(%esp)
  104fe2:	00 
  104fe3:	c7 44 24 08 89 6b 10 	movl   $0x106b89,0x8(%esp)
  104fea:	00 
  104feb:	c7 44 24 04 30 02 00 	movl   $0x230,0x4(%esp)
  104ff2:	00 
  104ff3:	c7 04 24 64 6b 10 00 	movl   $0x106b64,(%esp)
  104ffa:	e8 d2 bc ff ff       	call   100cd1 <__panic>

    assert(boot_pgdir[0] == 0);
  104fff:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  105004:	8b 00                	mov    (%eax),%eax
  105006:	85 c0                	test   %eax,%eax
  105008:	74 24                	je     10502e <check_boot_pgdir+0x192>
  10500a:	c7 44 24 0c f4 6e 10 	movl   $0x106ef4,0xc(%esp)
  105011:	00 
  105012:	c7 44 24 08 89 6b 10 	movl   $0x106b89,0x8(%esp)
  105019:	00 
  10501a:	c7 44 24 04 32 02 00 	movl   $0x232,0x4(%esp)
  105021:	00 
  105022:	c7 04 24 64 6b 10 00 	movl   $0x106b64,(%esp)
  105029:	e8 a3 bc ff ff       	call   100cd1 <__panic>

    struct Page *p;
    p = alloc_page();
  10502e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  105035:	e8 1e ed ff ff       	call   103d58 <alloc_pages>
  10503a:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
  10503d:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  105042:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  105049:	00 
  10504a:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
  105051:	00 
  105052:	8b 55 e0             	mov    -0x20(%ebp),%edx
  105055:	89 54 24 04          	mov    %edx,0x4(%esp)
  105059:	89 04 24             	mov    %eax,(%esp)
  10505c:	e8 6c f6 ff ff       	call   1046cd <page_insert>
  105061:	85 c0                	test   %eax,%eax
  105063:	74 24                	je     105089 <check_boot_pgdir+0x1ed>
  105065:	c7 44 24 0c 08 6f 10 	movl   $0x106f08,0xc(%esp)
  10506c:	00 
  10506d:	c7 44 24 08 89 6b 10 	movl   $0x106b89,0x8(%esp)
  105074:	00 
  105075:	c7 44 24 04 36 02 00 	movl   $0x236,0x4(%esp)
  10507c:	00 
  10507d:	c7 04 24 64 6b 10 00 	movl   $0x106b64,(%esp)
  105084:	e8 48 bc ff ff       	call   100cd1 <__panic>
    assert(page_ref(p) == 1);
  105089:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10508c:	89 04 24             	mov    %eax,(%esp)
  10508f:	e8 bf ea ff ff       	call   103b53 <page_ref>
  105094:	83 f8 01             	cmp    $0x1,%eax
  105097:	74 24                	je     1050bd <check_boot_pgdir+0x221>
  105099:	c7 44 24 0c 36 6f 10 	movl   $0x106f36,0xc(%esp)
  1050a0:	00 
  1050a1:	c7 44 24 08 89 6b 10 	movl   $0x106b89,0x8(%esp)
  1050a8:	00 
  1050a9:	c7 44 24 04 37 02 00 	movl   $0x237,0x4(%esp)
  1050b0:	00 
  1050b1:	c7 04 24 64 6b 10 00 	movl   $0x106b64,(%esp)
  1050b8:	e8 14 bc ff ff       	call   100cd1 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
  1050bd:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  1050c2:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  1050c9:	00 
  1050ca:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
  1050d1:	00 
  1050d2:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1050d5:	89 54 24 04          	mov    %edx,0x4(%esp)
  1050d9:	89 04 24             	mov    %eax,(%esp)
  1050dc:	e8 ec f5 ff ff       	call   1046cd <page_insert>
  1050e1:	85 c0                	test   %eax,%eax
  1050e3:	74 24                	je     105109 <check_boot_pgdir+0x26d>
  1050e5:	c7 44 24 0c 48 6f 10 	movl   $0x106f48,0xc(%esp)
  1050ec:	00 
  1050ed:	c7 44 24 08 89 6b 10 	movl   $0x106b89,0x8(%esp)
  1050f4:	00 
  1050f5:	c7 44 24 04 38 02 00 	movl   $0x238,0x4(%esp)
  1050fc:	00 
  1050fd:	c7 04 24 64 6b 10 00 	movl   $0x106b64,(%esp)
  105104:	e8 c8 bb ff ff       	call   100cd1 <__panic>
    assert(page_ref(p) == 2);
  105109:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10510c:	89 04 24             	mov    %eax,(%esp)
  10510f:	e8 3f ea ff ff       	call   103b53 <page_ref>
  105114:	83 f8 02             	cmp    $0x2,%eax
  105117:	74 24                	je     10513d <check_boot_pgdir+0x2a1>
  105119:	c7 44 24 0c 7f 6f 10 	movl   $0x106f7f,0xc(%esp)
  105120:	00 
  105121:	c7 44 24 08 89 6b 10 	movl   $0x106b89,0x8(%esp)
  105128:	00 
  105129:	c7 44 24 04 39 02 00 	movl   $0x239,0x4(%esp)
  105130:	00 
  105131:	c7 04 24 64 6b 10 00 	movl   $0x106b64,(%esp)
  105138:	e8 94 bb ff ff       	call   100cd1 <__panic>

    const char *str = "ucore: Hello world!!";
  10513d:	c7 45 dc 90 6f 10 00 	movl   $0x106f90,-0x24(%ebp)
    strcpy((void *)0x100, str);
  105144:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105147:	89 44 24 04          	mov    %eax,0x4(%esp)
  10514b:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  105152:	e8 1e 0a 00 00       	call   105b75 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
  105157:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
  10515e:	00 
  10515f:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  105166:	e8 83 0a 00 00       	call   105bee <strcmp>
  10516b:	85 c0                	test   %eax,%eax
  10516d:	74 24                	je     105193 <check_boot_pgdir+0x2f7>
  10516f:	c7 44 24 0c a8 6f 10 	movl   $0x106fa8,0xc(%esp)
  105176:	00 
  105177:	c7 44 24 08 89 6b 10 	movl   $0x106b89,0x8(%esp)
  10517e:	00 
  10517f:	c7 44 24 04 3d 02 00 	movl   $0x23d,0x4(%esp)
  105186:	00 
  105187:	c7 04 24 64 6b 10 00 	movl   $0x106b64,(%esp)
  10518e:	e8 3e bb ff ff       	call   100cd1 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
  105193:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105196:	89 04 24             	mov    %eax,(%esp)
  105199:	e8 23 e9 ff ff       	call   103ac1 <page2kva>
  10519e:	05 00 01 00 00       	add    $0x100,%eax
  1051a3:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
  1051a6:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  1051ad:	e8 6b 09 00 00       	call   105b1d <strlen>
  1051b2:	85 c0                	test   %eax,%eax
  1051b4:	74 24                	je     1051da <check_boot_pgdir+0x33e>
  1051b6:	c7 44 24 0c e0 6f 10 	movl   $0x106fe0,0xc(%esp)
  1051bd:	00 
  1051be:	c7 44 24 08 89 6b 10 	movl   $0x106b89,0x8(%esp)
  1051c5:	00 
  1051c6:	c7 44 24 04 40 02 00 	movl   $0x240,0x4(%esp)
  1051cd:	00 
  1051ce:	c7 04 24 64 6b 10 00 	movl   $0x106b64,(%esp)
  1051d5:	e8 f7 ba ff ff       	call   100cd1 <__panic>

    free_page(p);
  1051da:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1051e1:	00 
  1051e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1051e5:	89 04 24             	mov    %eax,(%esp)
  1051e8:	e8 a3 eb ff ff       	call   103d90 <free_pages>
    free_page(pa2page(PDE_ADDR(boot_pgdir[0])));
  1051ed:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  1051f2:	8b 00                	mov    (%eax),%eax
  1051f4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1051f9:	89 04 24             	mov    %eax,(%esp)
  1051fc:	e8 71 e8 ff ff       	call   103a72 <pa2page>
  105201:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  105208:	00 
  105209:	89 04 24             	mov    %eax,(%esp)
  10520c:	e8 7f eb ff ff       	call   103d90 <free_pages>
    boot_pgdir[0] = 0;
  105211:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  105216:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
  10521c:	c7 04 24 04 70 10 00 	movl   $0x107004,(%esp)
  105223:	e8 1f b1 ff ff       	call   100347 <cprintf>
}
  105228:	c9                   	leave  
  105229:	c3                   	ret    

0010522a <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
  10522a:	55                   	push   %ebp
  10522b:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
  10522d:	8b 45 08             	mov    0x8(%ebp),%eax
  105230:	83 e0 04             	and    $0x4,%eax
  105233:	85 c0                	test   %eax,%eax
  105235:	74 07                	je     10523e <perm2str+0x14>
  105237:	b8 75 00 00 00       	mov    $0x75,%eax
  10523c:	eb 05                	jmp    105243 <perm2str+0x19>
  10523e:	b8 2d 00 00 00       	mov    $0x2d,%eax
  105243:	a2 48 89 11 00       	mov    %al,0x118948
    str[1] = 'r';
  105248:	c6 05 49 89 11 00 72 	movb   $0x72,0x118949
    str[2] = (perm & PTE_W) ? 'w' : '-';
  10524f:	8b 45 08             	mov    0x8(%ebp),%eax
  105252:	83 e0 02             	and    $0x2,%eax
  105255:	85 c0                	test   %eax,%eax
  105257:	74 07                	je     105260 <perm2str+0x36>
  105259:	b8 77 00 00 00       	mov    $0x77,%eax
  10525e:	eb 05                	jmp    105265 <perm2str+0x3b>
  105260:	b8 2d 00 00 00       	mov    $0x2d,%eax
  105265:	a2 4a 89 11 00       	mov    %al,0x11894a
    str[3] = '\0';
  10526a:	c6 05 4b 89 11 00 00 	movb   $0x0,0x11894b
    return str;
  105271:	b8 48 89 11 00       	mov    $0x118948,%eax
}
  105276:	5d                   	pop    %ebp
  105277:	c3                   	ret    

00105278 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
  105278:	55                   	push   %ebp
  105279:	89 e5                	mov    %esp,%ebp
  10527b:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
  10527e:	8b 45 10             	mov    0x10(%ebp),%eax
  105281:	3b 45 0c             	cmp    0xc(%ebp),%eax
  105284:	72 0a                	jb     105290 <get_pgtable_items+0x18>
        return 0;
  105286:	b8 00 00 00 00       	mov    $0x0,%eax
  10528b:	e9 9c 00 00 00       	jmp    10532c <get_pgtable_items+0xb4>
    }
    while (start < right && !(table[start] & PTE_P)) {
  105290:	eb 04                	jmp    105296 <get_pgtable_items+0x1e>
        start ++;
  105292:	83 45 10 01          	addl   $0x1,0x10(%ebp)
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
    if (start >= right) {
        return 0;
    }
    while (start < right && !(table[start] & PTE_P)) {
  105296:	8b 45 10             	mov    0x10(%ebp),%eax
  105299:	3b 45 0c             	cmp    0xc(%ebp),%eax
  10529c:	73 18                	jae    1052b6 <get_pgtable_items+0x3e>
  10529e:	8b 45 10             	mov    0x10(%ebp),%eax
  1052a1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  1052a8:	8b 45 14             	mov    0x14(%ebp),%eax
  1052ab:	01 d0                	add    %edx,%eax
  1052ad:	8b 00                	mov    (%eax),%eax
  1052af:	83 e0 01             	and    $0x1,%eax
  1052b2:	85 c0                	test   %eax,%eax
  1052b4:	74 dc                	je     105292 <get_pgtable_items+0x1a>
        start ++;
    }
    if (start < right) {
  1052b6:	8b 45 10             	mov    0x10(%ebp),%eax
  1052b9:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1052bc:	73 69                	jae    105327 <get_pgtable_items+0xaf>
        if (left_store != NULL) {
  1052be:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
  1052c2:	74 08                	je     1052cc <get_pgtable_items+0x54>
            *left_store = start;
  1052c4:	8b 45 18             	mov    0x18(%ebp),%eax
  1052c7:	8b 55 10             	mov    0x10(%ebp),%edx
  1052ca:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
  1052cc:	8b 45 10             	mov    0x10(%ebp),%eax
  1052cf:	8d 50 01             	lea    0x1(%eax),%edx
  1052d2:	89 55 10             	mov    %edx,0x10(%ebp)
  1052d5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  1052dc:	8b 45 14             	mov    0x14(%ebp),%eax
  1052df:	01 d0                	add    %edx,%eax
  1052e1:	8b 00                	mov    (%eax),%eax
  1052e3:	83 e0 07             	and    $0x7,%eax
  1052e6:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
  1052e9:	eb 04                	jmp    1052ef <get_pgtable_items+0x77>
            start ++;
  1052eb:	83 45 10 01          	addl   $0x1,0x10(%ebp)
    if (start < right) {
        if (left_store != NULL) {
            *left_store = start;
        }
        int perm = (table[start ++] & PTE_USER);
        while (start < right && (table[start] & PTE_USER) == perm) {
  1052ef:	8b 45 10             	mov    0x10(%ebp),%eax
  1052f2:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1052f5:	73 1d                	jae    105314 <get_pgtable_items+0x9c>
  1052f7:	8b 45 10             	mov    0x10(%ebp),%eax
  1052fa:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  105301:	8b 45 14             	mov    0x14(%ebp),%eax
  105304:	01 d0                	add    %edx,%eax
  105306:	8b 00                	mov    (%eax),%eax
  105308:	83 e0 07             	and    $0x7,%eax
  10530b:	89 c2                	mov    %eax,%edx
  10530d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105310:	39 c2                	cmp    %eax,%edx
  105312:	74 d7                	je     1052eb <get_pgtable_items+0x73>
            start ++;
        }
        if (right_store != NULL) {
  105314:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  105318:	74 08                	je     105322 <get_pgtable_items+0xaa>
            *right_store = start;
  10531a:	8b 45 1c             	mov    0x1c(%ebp),%eax
  10531d:	8b 55 10             	mov    0x10(%ebp),%edx
  105320:	89 10                	mov    %edx,(%eax)
        }
        return perm;
  105322:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105325:	eb 05                	jmp    10532c <get_pgtable_items+0xb4>
    }
    return 0;
  105327:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10532c:	c9                   	leave  
  10532d:	c3                   	ret    

0010532e <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
  10532e:	55                   	push   %ebp
  10532f:	89 e5                	mov    %esp,%ebp
  105331:	57                   	push   %edi
  105332:	56                   	push   %esi
  105333:	53                   	push   %ebx
  105334:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
  105337:	c7 04 24 24 70 10 00 	movl   $0x107024,(%esp)
  10533e:	e8 04 b0 ff ff       	call   100347 <cprintf>
    size_t left, right = 0, perm;
  105343:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  10534a:	e9 fa 00 00 00       	jmp    105449 <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  10534f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105352:	89 04 24             	mov    %eax,(%esp)
  105355:	e8 d0 fe ff ff       	call   10522a <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
  10535a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  10535d:	8b 55 e0             	mov    -0x20(%ebp),%edx
  105360:	29 d1                	sub    %edx,%ecx
  105362:	89 ca                	mov    %ecx,%edx
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  105364:	89 d6                	mov    %edx,%esi
  105366:	c1 e6 16             	shl    $0x16,%esi
  105369:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10536c:	89 d3                	mov    %edx,%ebx
  10536e:	c1 e3 16             	shl    $0x16,%ebx
  105371:	8b 55 e0             	mov    -0x20(%ebp),%edx
  105374:	89 d1                	mov    %edx,%ecx
  105376:	c1 e1 16             	shl    $0x16,%ecx
  105379:	8b 7d dc             	mov    -0x24(%ebp),%edi
  10537c:	8b 55 e0             	mov    -0x20(%ebp),%edx
  10537f:	29 d7                	sub    %edx,%edi
  105381:	89 fa                	mov    %edi,%edx
  105383:	89 44 24 14          	mov    %eax,0x14(%esp)
  105387:	89 74 24 10          	mov    %esi,0x10(%esp)
  10538b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  10538f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  105393:	89 54 24 04          	mov    %edx,0x4(%esp)
  105397:	c7 04 24 55 70 10 00 	movl   $0x107055,(%esp)
  10539e:	e8 a4 af ff ff       	call   100347 <cprintf>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
  1053a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1053a6:	c1 e0 0a             	shl    $0xa,%eax
  1053a9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  1053ac:	eb 54                	jmp    105402 <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  1053ae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1053b1:	89 04 24             	mov    %eax,(%esp)
  1053b4:	e8 71 fe ff ff       	call   10522a <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
  1053b9:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  1053bc:	8b 55 d8             	mov    -0x28(%ebp),%edx
  1053bf:	29 d1                	sub    %edx,%ecx
  1053c1:	89 ca                	mov    %ecx,%edx
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  1053c3:	89 d6                	mov    %edx,%esi
  1053c5:	c1 e6 0c             	shl    $0xc,%esi
  1053c8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1053cb:	89 d3                	mov    %edx,%ebx
  1053cd:	c1 e3 0c             	shl    $0xc,%ebx
  1053d0:	8b 55 d8             	mov    -0x28(%ebp),%edx
  1053d3:	c1 e2 0c             	shl    $0xc,%edx
  1053d6:	89 d1                	mov    %edx,%ecx
  1053d8:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  1053db:	8b 55 d8             	mov    -0x28(%ebp),%edx
  1053de:	29 d7                	sub    %edx,%edi
  1053e0:	89 fa                	mov    %edi,%edx
  1053e2:	89 44 24 14          	mov    %eax,0x14(%esp)
  1053e6:	89 74 24 10          	mov    %esi,0x10(%esp)
  1053ea:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  1053ee:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  1053f2:	89 54 24 04          	mov    %edx,0x4(%esp)
  1053f6:	c7 04 24 74 70 10 00 	movl   $0x107074,(%esp)
  1053fd:	e8 45 af ff ff       	call   100347 <cprintf>
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  105402:	ba 00 00 c0 fa       	mov    $0xfac00000,%edx
  105407:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10540a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  10540d:	89 ce                	mov    %ecx,%esi
  10540f:	c1 e6 0a             	shl    $0xa,%esi
  105412:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  105415:	89 cb                	mov    %ecx,%ebx
  105417:	c1 e3 0a             	shl    $0xa,%ebx
  10541a:	8d 4d d4             	lea    -0x2c(%ebp),%ecx
  10541d:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  105421:	8d 4d d8             	lea    -0x28(%ebp),%ecx
  105424:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  105428:	89 54 24 0c          	mov    %edx,0xc(%esp)
  10542c:	89 44 24 08          	mov    %eax,0x8(%esp)
  105430:	89 74 24 04          	mov    %esi,0x4(%esp)
  105434:	89 1c 24             	mov    %ebx,(%esp)
  105437:	e8 3c fe ff ff       	call   105278 <get_pgtable_items>
  10543c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  10543f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  105443:	0f 85 65 ff ff ff    	jne    1053ae <print_pgdir+0x80>
//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  105449:	ba 00 b0 fe fa       	mov    $0xfafeb000,%edx
  10544e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105451:	8d 4d dc             	lea    -0x24(%ebp),%ecx
  105454:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  105458:	8d 4d e0             	lea    -0x20(%ebp),%ecx
  10545b:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  10545f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  105463:	89 44 24 08          	mov    %eax,0x8(%esp)
  105467:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
  10546e:	00 
  10546f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  105476:	e8 fd fd ff ff       	call   105278 <get_pgtable_items>
  10547b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  10547e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  105482:	0f 85 c7 fe ff ff    	jne    10534f <print_pgdir+0x21>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
        }
    }
    cprintf("--------------------- END ---------------------\n");
  105488:	c7 04 24 98 70 10 00 	movl   $0x107098,(%esp)
  10548f:	e8 b3 ae ff ff       	call   100347 <cprintf>
}
  105494:	83 c4 4c             	add    $0x4c,%esp
  105497:	5b                   	pop    %ebx
  105498:	5e                   	pop    %esi
  105499:	5f                   	pop    %edi
  10549a:	5d                   	pop    %ebp
  10549b:	c3                   	ret    

0010549c <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  10549c:	55                   	push   %ebp
  10549d:	89 e5                	mov    %esp,%ebp
  10549f:	83 ec 58             	sub    $0x58,%esp
  1054a2:	8b 45 10             	mov    0x10(%ebp),%eax
  1054a5:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1054a8:	8b 45 14             	mov    0x14(%ebp),%eax
  1054ab:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  1054ae:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1054b1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1054b4:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1054b7:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  1054ba:	8b 45 18             	mov    0x18(%ebp),%eax
  1054bd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1054c0:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1054c3:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1054c6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  1054c9:	89 55 f0             	mov    %edx,-0x10(%ebp)
  1054cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1054cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1054d2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1054d6:	74 1c                	je     1054f4 <printnum+0x58>
  1054d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1054db:	ba 00 00 00 00       	mov    $0x0,%edx
  1054e0:	f7 75 e4             	divl   -0x1c(%ebp)
  1054e3:	89 55 f4             	mov    %edx,-0xc(%ebp)
  1054e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1054e9:	ba 00 00 00 00       	mov    $0x0,%edx
  1054ee:	f7 75 e4             	divl   -0x1c(%ebp)
  1054f1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1054f4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1054f7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1054fa:	f7 75 e4             	divl   -0x1c(%ebp)
  1054fd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  105500:	89 55 dc             	mov    %edx,-0x24(%ebp)
  105503:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105506:	8b 55 f0             	mov    -0x10(%ebp),%edx
  105509:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10550c:	89 55 ec             	mov    %edx,-0x14(%ebp)
  10550f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105512:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  105515:	8b 45 18             	mov    0x18(%ebp),%eax
  105518:	ba 00 00 00 00       	mov    $0x0,%edx
  10551d:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  105520:	77 56                	ja     105578 <printnum+0xdc>
  105522:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  105525:	72 05                	jb     10552c <printnum+0x90>
  105527:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  10552a:	77 4c                	ja     105578 <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
  10552c:	8b 45 1c             	mov    0x1c(%ebp),%eax
  10552f:	8d 50 ff             	lea    -0x1(%eax),%edx
  105532:	8b 45 20             	mov    0x20(%ebp),%eax
  105535:	89 44 24 18          	mov    %eax,0x18(%esp)
  105539:	89 54 24 14          	mov    %edx,0x14(%esp)
  10553d:	8b 45 18             	mov    0x18(%ebp),%eax
  105540:	89 44 24 10          	mov    %eax,0x10(%esp)
  105544:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105547:	8b 55 ec             	mov    -0x14(%ebp),%edx
  10554a:	89 44 24 08          	mov    %eax,0x8(%esp)
  10554e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  105552:	8b 45 0c             	mov    0xc(%ebp),%eax
  105555:	89 44 24 04          	mov    %eax,0x4(%esp)
  105559:	8b 45 08             	mov    0x8(%ebp),%eax
  10555c:	89 04 24             	mov    %eax,(%esp)
  10555f:	e8 38 ff ff ff       	call   10549c <printnum>
  105564:	eb 1c                	jmp    105582 <printnum+0xe6>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
  105566:	8b 45 0c             	mov    0xc(%ebp),%eax
  105569:	89 44 24 04          	mov    %eax,0x4(%esp)
  10556d:	8b 45 20             	mov    0x20(%ebp),%eax
  105570:	89 04 24             	mov    %eax,(%esp)
  105573:	8b 45 08             	mov    0x8(%ebp),%eax
  105576:	ff d0                	call   *%eax
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  105578:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  10557c:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  105580:	7f e4                	jg     105566 <printnum+0xca>
            putch(padc, putdat);
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  105582:	8b 45 d8             	mov    -0x28(%ebp),%eax
  105585:	05 4c 71 10 00       	add    $0x10714c,%eax
  10558a:	0f b6 00             	movzbl (%eax),%eax
  10558d:	0f be c0             	movsbl %al,%eax
  105590:	8b 55 0c             	mov    0xc(%ebp),%edx
  105593:	89 54 24 04          	mov    %edx,0x4(%esp)
  105597:	89 04 24             	mov    %eax,(%esp)
  10559a:	8b 45 08             	mov    0x8(%ebp),%eax
  10559d:	ff d0                	call   *%eax
}
  10559f:	c9                   	leave  
  1055a0:	c3                   	ret    

001055a1 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  1055a1:	55                   	push   %ebp
  1055a2:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  1055a4:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  1055a8:	7e 14                	jle    1055be <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
  1055aa:	8b 45 08             	mov    0x8(%ebp),%eax
  1055ad:	8b 00                	mov    (%eax),%eax
  1055af:	8d 48 08             	lea    0x8(%eax),%ecx
  1055b2:	8b 55 08             	mov    0x8(%ebp),%edx
  1055b5:	89 0a                	mov    %ecx,(%edx)
  1055b7:	8b 50 04             	mov    0x4(%eax),%edx
  1055ba:	8b 00                	mov    (%eax),%eax
  1055bc:	eb 30                	jmp    1055ee <getuint+0x4d>
    }
    else if (lflag) {
  1055be:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  1055c2:	74 16                	je     1055da <getuint+0x39>
        return va_arg(*ap, unsigned long);
  1055c4:	8b 45 08             	mov    0x8(%ebp),%eax
  1055c7:	8b 00                	mov    (%eax),%eax
  1055c9:	8d 48 04             	lea    0x4(%eax),%ecx
  1055cc:	8b 55 08             	mov    0x8(%ebp),%edx
  1055cf:	89 0a                	mov    %ecx,(%edx)
  1055d1:	8b 00                	mov    (%eax),%eax
  1055d3:	ba 00 00 00 00       	mov    $0x0,%edx
  1055d8:	eb 14                	jmp    1055ee <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
  1055da:	8b 45 08             	mov    0x8(%ebp),%eax
  1055dd:	8b 00                	mov    (%eax),%eax
  1055df:	8d 48 04             	lea    0x4(%eax),%ecx
  1055e2:	8b 55 08             	mov    0x8(%ebp),%edx
  1055e5:	89 0a                	mov    %ecx,(%edx)
  1055e7:	8b 00                	mov    (%eax),%eax
  1055e9:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  1055ee:	5d                   	pop    %ebp
  1055ef:	c3                   	ret    

001055f0 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  1055f0:	55                   	push   %ebp
  1055f1:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  1055f3:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  1055f7:	7e 14                	jle    10560d <getint+0x1d>
        return va_arg(*ap, long long);
  1055f9:	8b 45 08             	mov    0x8(%ebp),%eax
  1055fc:	8b 00                	mov    (%eax),%eax
  1055fe:	8d 48 08             	lea    0x8(%eax),%ecx
  105601:	8b 55 08             	mov    0x8(%ebp),%edx
  105604:	89 0a                	mov    %ecx,(%edx)
  105606:	8b 50 04             	mov    0x4(%eax),%edx
  105609:	8b 00                	mov    (%eax),%eax
  10560b:	eb 28                	jmp    105635 <getint+0x45>
    }
    else if (lflag) {
  10560d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  105611:	74 12                	je     105625 <getint+0x35>
        return va_arg(*ap, long);
  105613:	8b 45 08             	mov    0x8(%ebp),%eax
  105616:	8b 00                	mov    (%eax),%eax
  105618:	8d 48 04             	lea    0x4(%eax),%ecx
  10561b:	8b 55 08             	mov    0x8(%ebp),%edx
  10561e:	89 0a                	mov    %ecx,(%edx)
  105620:	8b 00                	mov    (%eax),%eax
  105622:	99                   	cltd   
  105623:	eb 10                	jmp    105635 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
  105625:	8b 45 08             	mov    0x8(%ebp),%eax
  105628:	8b 00                	mov    (%eax),%eax
  10562a:	8d 48 04             	lea    0x4(%eax),%ecx
  10562d:	8b 55 08             	mov    0x8(%ebp),%edx
  105630:	89 0a                	mov    %ecx,(%edx)
  105632:	8b 00                	mov    (%eax),%eax
  105634:	99                   	cltd   
    }
}
  105635:	5d                   	pop    %ebp
  105636:	c3                   	ret    

00105637 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  105637:	55                   	push   %ebp
  105638:	89 e5                	mov    %esp,%ebp
  10563a:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  10563d:	8d 45 14             	lea    0x14(%ebp),%eax
  105640:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
  105643:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105646:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10564a:	8b 45 10             	mov    0x10(%ebp),%eax
  10564d:	89 44 24 08          	mov    %eax,0x8(%esp)
  105651:	8b 45 0c             	mov    0xc(%ebp),%eax
  105654:	89 44 24 04          	mov    %eax,0x4(%esp)
  105658:	8b 45 08             	mov    0x8(%ebp),%eax
  10565b:	89 04 24             	mov    %eax,(%esp)
  10565e:	e8 02 00 00 00       	call   105665 <vprintfmt>
    va_end(ap);
}
  105663:	c9                   	leave  
  105664:	c3                   	ret    

00105665 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  105665:	55                   	push   %ebp
  105666:	89 e5                	mov    %esp,%ebp
  105668:	56                   	push   %esi
  105669:	53                   	push   %ebx
  10566a:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  10566d:	eb 18                	jmp    105687 <vprintfmt+0x22>
            if (ch == '\0') {
  10566f:	85 db                	test   %ebx,%ebx
  105671:	75 05                	jne    105678 <vprintfmt+0x13>
                return;
  105673:	e9 d1 03 00 00       	jmp    105a49 <vprintfmt+0x3e4>
            }
            putch(ch, putdat);
  105678:	8b 45 0c             	mov    0xc(%ebp),%eax
  10567b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10567f:	89 1c 24             	mov    %ebx,(%esp)
  105682:	8b 45 08             	mov    0x8(%ebp),%eax
  105685:	ff d0                	call   *%eax
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  105687:	8b 45 10             	mov    0x10(%ebp),%eax
  10568a:	8d 50 01             	lea    0x1(%eax),%edx
  10568d:	89 55 10             	mov    %edx,0x10(%ebp)
  105690:	0f b6 00             	movzbl (%eax),%eax
  105693:	0f b6 d8             	movzbl %al,%ebx
  105696:	83 fb 25             	cmp    $0x25,%ebx
  105699:	75 d4                	jne    10566f <vprintfmt+0xa>
            }
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
  10569b:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  10569f:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  1056a6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1056a9:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  1056ac:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  1056b3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1056b6:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  1056b9:	8b 45 10             	mov    0x10(%ebp),%eax
  1056bc:	8d 50 01             	lea    0x1(%eax),%edx
  1056bf:	89 55 10             	mov    %edx,0x10(%ebp)
  1056c2:	0f b6 00             	movzbl (%eax),%eax
  1056c5:	0f b6 d8             	movzbl %al,%ebx
  1056c8:	8d 43 dd             	lea    -0x23(%ebx),%eax
  1056cb:	83 f8 55             	cmp    $0x55,%eax
  1056ce:	0f 87 44 03 00 00    	ja     105a18 <vprintfmt+0x3b3>
  1056d4:	8b 04 85 70 71 10 00 	mov    0x107170(,%eax,4),%eax
  1056db:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  1056dd:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  1056e1:	eb d6                	jmp    1056b9 <vprintfmt+0x54>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  1056e3:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  1056e7:	eb d0                	jmp    1056b9 <vprintfmt+0x54>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  1056e9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  1056f0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1056f3:	89 d0                	mov    %edx,%eax
  1056f5:	c1 e0 02             	shl    $0x2,%eax
  1056f8:	01 d0                	add    %edx,%eax
  1056fa:	01 c0                	add    %eax,%eax
  1056fc:	01 d8                	add    %ebx,%eax
  1056fe:	83 e8 30             	sub    $0x30,%eax
  105701:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  105704:	8b 45 10             	mov    0x10(%ebp),%eax
  105707:	0f b6 00             	movzbl (%eax),%eax
  10570a:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  10570d:	83 fb 2f             	cmp    $0x2f,%ebx
  105710:	7e 0b                	jle    10571d <vprintfmt+0xb8>
  105712:	83 fb 39             	cmp    $0x39,%ebx
  105715:	7f 06                	jg     10571d <vprintfmt+0xb8>
            padc = '0';
            goto reswitch;

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  105717:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                precision = precision * 10 + ch - '0';
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
  10571b:	eb d3                	jmp    1056f0 <vprintfmt+0x8b>
            goto process_precision;
  10571d:	eb 33                	jmp    105752 <vprintfmt+0xed>

        case '*':
            precision = va_arg(ap, int);
  10571f:	8b 45 14             	mov    0x14(%ebp),%eax
  105722:	8d 50 04             	lea    0x4(%eax),%edx
  105725:	89 55 14             	mov    %edx,0x14(%ebp)
  105728:	8b 00                	mov    (%eax),%eax
  10572a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  10572d:	eb 23                	jmp    105752 <vprintfmt+0xed>

        case '.':
            if (width < 0)
  10572f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105733:	79 0c                	jns    105741 <vprintfmt+0xdc>
                width = 0;
  105735:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  10573c:	e9 78 ff ff ff       	jmp    1056b9 <vprintfmt+0x54>
  105741:	e9 73 ff ff ff       	jmp    1056b9 <vprintfmt+0x54>

        case '#':
            altflag = 1;
  105746:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  10574d:	e9 67 ff ff ff       	jmp    1056b9 <vprintfmt+0x54>

        process_precision:
            if (width < 0)
  105752:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105756:	79 12                	jns    10576a <vprintfmt+0x105>
                width = precision, precision = -1;
  105758:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10575b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10575e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  105765:	e9 4f ff ff ff       	jmp    1056b9 <vprintfmt+0x54>
  10576a:	e9 4a ff ff ff       	jmp    1056b9 <vprintfmt+0x54>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  10576f:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
  105773:	e9 41 ff ff ff       	jmp    1056b9 <vprintfmt+0x54>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
  105778:	8b 45 14             	mov    0x14(%ebp),%eax
  10577b:	8d 50 04             	lea    0x4(%eax),%edx
  10577e:	89 55 14             	mov    %edx,0x14(%ebp)
  105781:	8b 00                	mov    (%eax),%eax
  105783:	8b 55 0c             	mov    0xc(%ebp),%edx
  105786:	89 54 24 04          	mov    %edx,0x4(%esp)
  10578a:	89 04 24             	mov    %eax,(%esp)
  10578d:	8b 45 08             	mov    0x8(%ebp),%eax
  105790:	ff d0                	call   *%eax
            break;
  105792:	e9 ac 02 00 00       	jmp    105a43 <vprintfmt+0x3de>

        // error message
        case 'e':
            err = va_arg(ap, int);
  105797:	8b 45 14             	mov    0x14(%ebp),%eax
  10579a:	8d 50 04             	lea    0x4(%eax),%edx
  10579d:	89 55 14             	mov    %edx,0x14(%ebp)
  1057a0:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  1057a2:	85 db                	test   %ebx,%ebx
  1057a4:	79 02                	jns    1057a8 <vprintfmt+0x143>
                err = -err;
  1057a6:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  1057a8:	83 fb 06             	cmp    $0x6,%ebx
  1057ab:	7f 0b                	jg     1057b8 <vprintfmt+0x153>
  1057ad:	8b 34 9d 30 71 10 00 	mov    0x107130(,%ebx,4),%esi
  1057b4:	85 f6                	test   %esi,%esi
  1057b6:	75 23                	jne    1057db <vprintfmt+0x176>
                printfmt(putch, putdat, "error %d", err);
  1057b8:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  1057bc:	c7 44 24 08 5d 71 10 	movl   $0x10715d,0x8(%esp)
  1057c3:	00 
  1057c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  1057c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  1057cb:	8b 45 08             	mov    0x8(%ebp),%eax
  1057ce:	89 04 24             	mov    %eax,(%esp)
  1057d1:	e8 61 fe ff ff       	call   105637 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
  1057d6:	e9 68 02 00 00       	jmp    105a43 <vprintfmt+0x3de>
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
                printfmt(putch, putdat, "error %d", err);
            }
            else {
                printfmt(putch, putdat, "%s", p);
  1057db:	89 74 24 0c          	mov    %esi,0xc(%esp)
  1057df:	c7 44 24 08 66 71 10 	movl   $0x107166,0x8(%esp)
  1057e6:	00 
  1057e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  1057ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  1057ee:	8b 45 08             	mov    0x8(%ebp),%eax
  1057f1:	89 04 24             	mov    %eax,(%esp)
  1057f4:	e8 3e fe ff ff       	call   105637 <printfmt>
            }
            break;
  1057f9:	e9 45 02 00 00       	jmp    105a43 <vprintfmt+0x3de>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  1057fe:	8b 45 14             	mov    0x14(%ebp),%eax
  105801:	8d 50 04             	lea    0x4(%eax),%edx
  105804:	89 55 14             	mov    %edx,0x14(%ebp)
  105807:	8b 30                	mov    (%eax),%esi
  105809:	85 f6                	test   %esi,%esi
  10580b:	75 05                	jne    105812 <vprintfmt+0x1ad>
                p = "(null)";
  10580d:	be 69 71 10 00       	mov    $0x107169,%esi
            }
            if (width > 0 && padc != '-') {
  105812:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105816:	7e 3e                	jle    105856 <vprintfmt+0x1f1>
  105818:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  10581c:	74 38                	je     105856 <vprintfmt+0x1f1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  10581e:	8b 5d e8             	mov    -0x18(%ebp),%ebx
  105821:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105824:	89 44 24 04          	mov    %eax,0x4(%esp)
  105828:	89 34 24             	mov    %esi,(%esp)
  10582b:	e8 15 03 00 00       	call   105b45 <strnlen>
  105830:	29 c3                	sub    %eax,%ebx
  105832:	89 d8                	mov    %ebx,%eax
  105834:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105837:	eb 17                	jmp    105850 <vprintfmt+0x1eb>
                    putch(padc, putdat);
  105839:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  10583d:	8b 55 0c             	mov    0xc(%ebp),%edx
  105840:	89 54 24 04          	mov    %edx,0x4(%esp)
  105844:	89 04 24             	mov    %eax,(%esp)
  105847:	8b 45 08             	mov    0x8(%ebp),%eax
  10584a:	ff d0                	call   *%eax
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
                p = "(null)";
            }
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
  10584c:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  105850:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105854:	7f e3                	jg     105839 <vprintfmt+0x1d4>
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  105856:	eb 38                	jmp    105890 <vprintfmt+0x22b>
                if (altflag && (ch < ' ' || ch > '~')) {
  105858:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  10585c:	74 1f                	je     10587d <vprintfmt+0x218>
  10585e:	83 fb 1f             	cmp    $0x1f,%ebx
  105861:	7e 05                	jle    105868 <vprintfmt+0x203>
  105863:	83 fb 7e             	cmp    $0x7e,%ebx
  105866:	7e 15                	jle    10587d <vprintfmt+0x218>
                    putch('?', putdat);
  105868:	8b 45 0c             	mov    0xc(%ebp),%eax
  10586b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10586f:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  105876:	8b 45 08             	mov    0x8(%ebp),%eax
  105879:	ff d0                	call   *%eax
  10587b:	eb 0f                	jmp    10588c <vprintfmt+0x227>
                }
                else {
                    putch(ch, putdat);
  10587d:	8b 45 0c             	mov    0xc(%ebp),%eax
  105880:	89 44 24 04          	mov    %eax,0x4(%esp)
  105884:	89 1c 24             	mov    %ebx,(%esp)
  105887:	8b 45 08             	mov    0x8(%ebp),%eax
  10588a:	ff d0                	call   *%eax
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  10588c:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  105890:	89 f0                	mov    %esi,%eax
  105892:	8d 70 01             	lea    0x1(%eax),%esi
  105895:	0f b6 00             	movzbl (%eax),%eax
  105898:	0f be d8             	movsbl %al,%ebx
  10589b:	85 db                	test   %ebx,%ebx
  10589d:	74 10                	je     1058af <vprintfmt+0x24a>
  10589f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  1058a3:	78 b3                	js     105858 <vprintfmt+0x1f3>
  1058a5:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  1058a9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  1058ad:	79 a9                	jns    105858 <vprintfmt+0x1f3>
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
  1058af:	eb 17                	jmp    1058c8 <vprintfmt+0x263>
                putch(' ', putdat);
  1058b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  1058b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  1058b8:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  1058bf:	8b 45 08             	mov    0x8(%ebp),%eax
  1058c2:	ff d0                	call   *%eax
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
  1058c4:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  1058c8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1058cc:	7f e3                	jg     1058b1 <vprintfmt+0x24c>
                putch(' ', putdat);
            }
            break;
  1058ce:	e9 70 01 00 00       	jmp    105a43 <vprintfmt+0x3de>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  1058d3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1058d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  1058da:	8d 45 14             	lea    0x14(%ebp),%eax
  1058dd:	89 04 24             	mov    %eax,(%esp)
  1058e0:	e8 0b fd ff ff       	call   1055f0 <getint>
  1058e5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1058e8:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  1058eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1058ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1058f1:	85 d2                	test   %edx,%edx
  1058f3:	79 26                	jns    10591b <vprintfmt+0x2b6>
                putch('-', putdat);
  1058f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  1058f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  1058fc:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  105903:	8b 45 08             	mov    0x8(%ebp),%eax
  105906:	ff d0                	call   *%eax
                num = -(long long)num;
  105908:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10590b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10590e:	f7 d8                	neg    %eax
  105910:	83 d2 00             	adc    $0x0,%edx
  105913:	f7 da                	neg    %edx
  105915:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105918:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  10591b:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  105922:	e9 a8 00 00 00       	jmp    1059cf <vprintfmt+0x36a>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  105927:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10592a:	89 44 24 04          	mov    %eax,0x4(%esp)
  10592e:	8d 45 14             	lea    0x14(%ebp),%eax
  105931:	89 04 24             	mov    %eax,(%esp)
  105934:	e8 68 fc ff ff       	call   1055a1 <getuint>
  105939:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10593c:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  10593f:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  105946:	e9 84 00 00 00       	jmp    1059cf <vprintfmt+0x36a>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  10594b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10594e:	89 44 24 04          	mov    %eax,0x4(%esp)
  105952:	8d 45 14             	lea    0x14(%ebp),%eax
  105955:	89 04 24             	mov    %eax,(%esp)
  105958:	e8 44 fc ff ff       	call   1055a1 <getuint>
  10595d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105960:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  105963:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  10596a:	eb 63                	jmp    1059cf <vprintfmt+0x36a>

        // pointer
        case 'p':
            putch('0', putdat);
  10596c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10596f:	89 44 24 04          	mov    %eax,0x4(%esp)
  105973:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  10597a:	8b 45 08             	mov    0x8(%ebp),%eax
  10597d:	ff d0                	call   *%eax
            putch('x', putdat);
  10597f:	8b 45 0c             	mov    0xc(%ebp),%eax
  105982:	89 44 24 04          	mov    %eax,0x4(%esp)
  105986:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  10598d:	8b 45 08             	mov    0x8(%ebp),%eax
  105990:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  105992:	8b 45 14             	mov    0x14(%ebp),%eax
  105995:	8d 50 04             	lea    0x4(%eax),%edx
  105998:	89 55 14             	mov    %edx,0x14(%ebp)
  10599b:	8b 00                	mov    (%eax),%eax
  10599d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1059a0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  1059a7:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  1059ae:	eb 1f                	jmp    1059cf <vprintfmt+0x36a>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  1059b0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1059b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  1059b7:	8d 45 14             	lea    0x14(%ebp),%eax
  1059ba:	89 04 24             	mov    %eax,(%esp)
  1059bd:	e8 df fb ff ff       	call   1055a1 <getuint>
  1059c2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1059c5:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  1059c8:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
  1059cf:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  1059d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1059d6:	89 54 24 18          	mov    %edx,0x18(%esp)
  1059da:	8b 55 e8             	mov    -0x18(%ebp),%edx
  1059dd:	89 54 24 14          	mov    %edx,0x14(%esp)
  1059e1:	89 44 24 10          	mov    %eax,0x10(%esp)
  1059e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1059e8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1059eb:	89 44 24 08          	mov    %eax,0x8(%esp)
  1059ef:	89 54 24 0c          	mov    %edx,0xc(%esp)
  1059f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  1059f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  1059fa:	8b 45 08             	mov    0x8(%ebp),%eax
  1059fd:	89 04 24             	mov    %eax,(%esp)
  105a00:	e8 97 fa ff ff       	call   10549c <printnum>
            break;
  105a05:	eb 3c                	jmp    105a43 <vprintfmt+0x3de>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
  105a07:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a0a:	89 44 24 04          	mov    %eax,0x4(%esp)
  105a0e:	89 1c 24             	mov    %ebx,(%esp)
  105a11:	8b 45 08             	mov    0x8(%ebp),%eax
  105a14:	ff d0                	call   *%eax
            break;
  105a16:	eb 2b                	jmp    105a43 <vprintfmt+0x3de>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
  105a18:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a1b:	89 44 24 04          	mov    %eax,0x4(%esp)
  105a1f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  105a26:	8b 45 08             	mov    0x8(%ebp),%eax
  105a29:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
  105a2b:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  105a2f:	eb 04                	jmp    105a35 <vprintfmt+0x3d0>
  105a31:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  105a35:	8b 45 10             	mov    0x10(%ebp),%eax
  105a38:	83 e8 01             	sub    $0x1,%eax
  105a3b:	0f b6 00             	movzbl (%eax),%eax
  105a3e:	3c 25                	cmp    $0x25,%al
  105a40:	75 ef                	jne    105a31 <vprintfmt+0x3cc>
                /* do nothing */;
            break;
  105a42:	90                   	nop
        }
    }
  105a43:	90                   	nop
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  105a44:	e9 3e fc ff ff       	jmp    105687 <vprintfmt+0x22>
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  105a49:	83 c4 40             	add    $0x40,%esp
  105a4c:	5b                   	pop    %ebx
  105a4d:	5e                   	pop    %esi
  105a4e:	5d                   	pop    %ebp
  105a4f:	c3                   	ret    

00105a50 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  105a50:	55                   	push   %ebp
  105a51:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  105a53:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a56:	8b 40 08             	mov    0x8(%eax),%eax
  105a59:	8d 50 01             	lea    0x1(%eax),%edx
  105a5c:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a5f:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  105a62:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a65:	8b 10                	mov    (%eax),%edx
  105a67:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a6a:	8b 40 04             	mov    0x4(%eax),%eax
  105a6d:	39 c2                	cmp    %eax,%edx
  105a6f:	73 12                	jae    105a83 <sprintputch+0x33>
        *b->buf ++ = ch;
  105a71:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a74:	8b 00                	mov    (%eax),%eax
  105a76:	8d 48 01             	lea    0x1(%eax),%ecx
  105a79:	8b 55 0c             	mov    0xc(%ebp),%edx
  105a7c:	89 0a                	mov    %ecx,(%edx)
  105a7e:	8b 55 08             	mov    0x8(%ebp),%edx
  105a81:	88 10                	mov    %dl,(%eax)
    }
}
  105a83:	5d                   	pop    %ebp
  105a84:	c3                   	ret    

00105a85 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  105a85:	55                   	push   %ebp
  105a86:	89 e5                	mov    %esp,%ebp
  105a88:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  105a8b:	8d 45 14             	lea    0x14(%ebp),%eax
  105a8e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  105a91:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105a94:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105a98:	8b 45 10             	mov    0x10(%ebp),%eax
  105a9b:	89 44 24 08          	mov    %eax,0x8(%esp)
  105a9f:	8b 45 0c             	mov    0xc(%ebp),%eax
  105aa2:	89 44 24 04          	mov    %eax,0x4(%esp)
  105aa6:	8b 45 08             	mov    0x8(%ebp),%eax
  105aa9:	89 04 24             	mov    %eax,(%esp)
  105aac:	e8 08 00 00 00       	call   105ab9 <vsnprintf>
  105ab1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  105ab4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  105ab7:	c9                   	leave  
  105ab8:	c3                   	ret    

00105ab9 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  105ab9:	55                   	push   %ebp
  105aba:	89 e5                	mov    %esp,%ebp
  105abc:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  105abf:	8b 45 08             	mov    0x8(%ebp),%eax
  105ac2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105ac5:	8b 45 0c             	mov    0xc(%ebp),%eax
  105ac8:	8d 50 ff             	lea    -0x1(%eax),%edx
  105acb:	8b 45 08             	mov    0x8(%ebp),%eax
  105ace:	01 d0                	add    %edx,%eax
  105ad0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105ad3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  105ada:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  105ade:	74 0a                	je     105aea <vsnprintf+0x31>
  105ae0:	8b 55 ec             	mov    -0x14(%ebp),%edx
  105ae3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105ae6:	39 c2                	cmp    %eax,%edx
  105ae8:	76 07                	jbe    105af1 <vsnprintf+0x38>
        return -E_INVAL;
  105aea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  105aef:	eb 2a                	jmp    105b1b <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  105af1:	8b 45 14             	mov    0x14(%ebp),%eax
  105af4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105af8:	8b 45 10             	mov    0x10(%ebp),%eax
  105afb:	89 44 24 08          	mov    %eax,0x8(%esp)
  105aff:	8d 45 ec             	lea    -0x14(%ebp),%eax
  105b02:	89 44 24 04          	mov    %eax,0x4(%esp)
  105b06:	c7 04 24 50 5a 10 00 	movl   $0x105a50,(%esp)
  105b0d:	e8 53 fb ff ff       	call   105665 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  105b12:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105b15:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  105b18:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  105b1b:	c9                   	leave  
  105b1c:	c3                   	ret    

00105b1d <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  105b1d:	55                   	push   %ebp
  105b1e:	89 e5                	mov    %esp,%ebp
  105b20:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  105b23:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  105b2a:	eb 04                	jmp    105b30 <strlen+0x13>
        cnt ++;
  105b2c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
  105b30:	8b 45 08             	mov    0x8(%ebp),%eax
  105b33:	8d 50 01             	lea    0x1(%eax),%edx
  105b36:	89 55 08             	mov    %edx,0x8(%ebp)
  105b39:	0f b6 00             	movzbl (%eax),%eax
  105b3c:	84 c0                	test   %al,%al
  105b3e:	75 ec                	jne    105b2c <strlen+0xf>
        cnt ++;
    }
    return cnt;
  105b40:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  105b43:	c9                   	leave  
  105b44:	c3                   	ret    

00105b45 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  105b45:	55                   	push   %ebp
  105b46:	89 e5                	mov    %esp,%ebp
  105b48:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  105b4b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  105b52:	eb 04                	jmp    105b58 <strnlen+0x13>
        cnt ++;
  105b54:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  105b58:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105b5b:	3b 45 0c             	cmp    0xc(%ebp),%eax
  105b5e:	73 10                	jae    105b70 <strnlen+0x2b>
  105b60:	8b 45 08             	mov    0x8(%ebp),%eax
  105b63:	8d 50 01             	lea    0x1(%eax),%edx
  105b66:	89 55 08             	mov    %edx,0x8(%ebp)
  105b69:	0f b6 00             	movzbl (%eax),%eax
  105b6c:	84 c0                	test   %al,%al
  105b6e:	75 e4                	jne    105b54 <strnlen+0xf>
        cnt ++;
    }
    return cnt;
  105b70:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  105b73:	c9                   	leave  
  105b74:	c3                   	ret    

00105b75 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  105b75:	55                   	push   %ebp
  105b76:	89 e5                	mov    %esp,%ebp
  105b78:	57                   	push   %edi
  105b79:	56                   	push   %esi
  105b7a:	83 ec 20             	sub    $0x20,%esp
  105b7d:	8b 45 08             	mov    0x8(%ebp),%eax
  105b80:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105b83:	8b 45 0c             	mov    0xc(%ebp),%eax
  105b86:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  105b89:	8b 55 f0             	mov    -0x10(%ebp),%edx
  105b8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105b8f:	89 d1                	mov    %edx,%ecx
  105b91:	89 c2                	mov    %eax,%edx
  105b93:	89 ce                	mov    %ecx,%esi
  105b95:	89 d7                	mov    %edx,%edi
  105b97:	ac                   	lods   %ds:(%esi),%al
  105b98:	aa                   	stos   %al,%es:(%edi)
  105b99:	84 c0                	test   %al,%al
  105b9b:	75 fa                	jne    105b97 <strcpy+0x22>
  105b9d:	89 fa                	mov    %edi,%edx
  105b9f:	89 f1                	mov    %esi,%ecx
  105ba1:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  105ba4:	89 55 e8             	mov    %edx,-0x18(%ebp)
  105ba7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
  105baa:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  105bad:	83 c4 20             	add    $0x20,%esp
  105bb0:	5e                   	pop    %esi
  105bb1:	5f                   	pop    %edi
  105bb2:	5d                   	pop    %ebp
  105bb3:	c3                   	ret    

00105bb4 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  105bb4:	55                   	push   %ebp
  105bb5:	89 e5                	mov    %esp,%ebp
  105bb7:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  105bba:	8b 45 08             	mov    0x8(%ebp),%eax
  105bbd:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  105bc0:	eb 21                	jmp    105be3 <strncpy+0x2f>
        if ((*p = *src) != '\0') {
  105bc2:	8b 45 0c             	mov    0xc(%ebp),%eax
  105bc5:	0f b6 10             	movzbl (%eax),%edx
  105bc8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105bcb:	88 10                	mov    %dl,(%eax)
  105bcd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105bd0:	0f b6 00             	movzbl (%eax),%eax
  105bd3:	84 c0                	test   %al,%al
  105bd5:	74 04                	je     105bdb <strncpy+0x27>
            src ++;
  105bd7:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
  105bdb:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  105bdf:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
    char *p = dst;
    while (len > 0) {
  105be3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105be7:	75 d9                	jne    105bc2 <strncpy+0xe>
        if ((*p = *src) != '\0') {
            src ++;
        }
        p ++, len --;
    }
    return dst;
  105be9:	8b 45 08             	mov    0x8(%ebp),%eax
}
  105bec:	c9                   	leave  
  105bed:	c3                   	ret    

00105bee <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  105bee:	55                   	push   %ebp
  105bef:	89 e5                	mov    %esp,%ebp
  105bf1:	57                   	push   %edi
  105bf2:	56                   	push   %esi
  105bf3:	83 ec 20             	sub    $0x20,%esp
  105bf6:	8b 45 08             	mov    0x8(%ebp),%eax
  105bf9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105bfc:	8b 45 0c             	mov    0xc(%ebp),%eax
  105bff:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCMP
#define __HAVE_ARCH_STRCMP
static inline int
__strcmp(const char *s1, const char *s2) {
    int d0, d1, ret;
    asm volatile (
  105c02:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105c05:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105c08:	89 d1                	mov    %edx,%ecx
  105c0a:	89 c2                	mov    %eax,%edx
  105c0c:	89 ce                	mov    %ecx,%esi
  105c0e:	89 d7                	mov    %edx,%edi
  105c10:	ac                   	lods   %ds:(%esi),%al
  105c11:	ae                   	scas   %es:(%edi),%al
  105c12:	75 08                	jne    105c1c <strcmp+0x2e>
  105c14:	84 c0                	test   %al,%al
  105c16:	75 f8                	jne    105c10 <strcmp+0x22>
  105c18:	31 c0                	xor    %eax,%eax
  105c1a:	eb 04                	jmp    105c20 <strcmp+0x32>
  105c1c:	19 c0                	sbb    %eax,%eax
  105c1e:	0c 01                	or     $0x1,%al
  105c20:	89 fa                	mov    %edi,%edx
  105c22:	89 f1                	mov    %esi,%ecx
  105c24:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105c27:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  105c2a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
        "orb $1, %%al;"
        "3:"
        : "=a" (ret), "=&S" (d0), "=&D" (d1)
        : "1" (s1), "2" (s2)
        : "memory");
    return ret;
  105c2d:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  105c30:	83 c4 20             	add    $0x20,%esp
  105c33:	5e                   	pop    %esi
  105c34:	5f                   	pop    %edi
  105c35:	5d                   	pop    %ebp
  105c36:	c3                   	ret    

00105c37 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  105c37:	55                   	push   %ebp
  105c38:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  105c3a:	eb 0c                	jmp    105c48 <strncmp+0x11>
        n --, s1 ++, s2 ++;
  105c3c:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  105c40:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  105c44:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  105c48:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105c4c:	74 1a                	je     105c68 <strncmp+0x31>
  105c4e:	8b 45 08             	mov    0x8(%ebp),%eax
  105c51:	0f b6 00             	movzbl (%eax),%eax
  105c54:	84 c0                	test   %al,%al
  105c56:	74 10                	je     105c68 <strncmp+0x31>
  105c58:	8b 45 08             	mov    0x8(%ebp),%eax
  105c5b:	0f b6 10             	movzbl (%eax),%edx
  105c5e:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c61:	0f b6 00             	movzbl (%eax),%eax
  105c64:	38 c2                	cmp    %al,%dl
  105c66:	74 d4                	je     105c3c <strncmp+0x5>
        n --, s1 ++, s2 ++;
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  105c68:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105c6c:	74 18                	je     105c86 <strncmp+0x4f>
  105c6e:	8b 45 08             	mov    0x8(%ebp),%eax
  105c71:	0f b6 00             	movzbl (%eax),%eax
  105c74:	0f b6 d0             	movzbl %al,%edx
  105c77:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c7a:	0f b6 00             	movzbl (%eax),%eax
  105c7d:	0f b6 c0             	movzbl %al,%eax
  105c80:	29 c2                	sub    %eax,%edx
  105c82:	89 d0                	mov    %edx,%eax
  105c84:	eb 05                	jmp    105c8b <strncmp+0x54>
  105c86:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105c8b:	5d                   	pop    %ebp
  105c8c:	c3                   	ret    

00105c8d <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  105c8d:	55                   	push   %ebp
  105c8e:	89 e5                	mov    %esp,%ebp
  105c90:	83 ec 04             	sub    $0x4,%esp
  105c93:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c96:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  105c99:	eb 14                	jmp    105caf <strchr+0x22>
        if (*s == c) {
  105c9b:	8b 45 08             	mov    0x8(%ebp),%eax
  105c9e:	0f b6 00             	movzbl (%eax),%eax
  105ca1:	3a 45 fc             	cmp    -0x4(%ebp),%al
  105ca4:	75 05                	jne    105cab <strchr+0x1e>
            return (char *)s;
  105ca6:	8b 45 08             	mov    0x8(%ebp),%eax
  105ca9:	eb 13                	jmp    105cbe <strchr+0x31>
        }
        s ++;
  105cab:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
  105caf:	8b 45 08             	mov    0x8(%ebp),%eax
  105cb2:	0f b6 00             	movzbl (%eax),%eax
  105cb5:	84 c0                	test   %al,%al
  105cb7:	75 e2                	jne    105c9b <strchr+0xe>
        if (*s == c) {
            return (char *)s;
        }
        s ++;
    }
    return NULL;
  105cb9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105cbe:	c9                   	leave  
  105cbf:	c3                   	ret    

00105cc0 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  105cc0:	55                   	push   %ebp
  105cc1:	89 e5                	mov    %esp,%ebp
  105cc3:	83 ec 04             	sub    $0x4,%esp
  105cc6:	8b 45 0c             	mov    0xc(%ebp),%eax
  105cc9:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  105ccc:	eb 11                	jmp    105cdf <strfind+0x1f>
        if (*s == c) {
  105cce:	8b 45 08             	mov    0x8(%ebp),%eax
  105cd1:	0f b6 00             	movzbl (%eax),%eax
  105cd4:	3a 45 fc             	cmp    -0x4(%ebp),%al
  105cd7:	75 02                	jne    105cdb <strfind+0x1b>
            break;
  105cd9:	eb 0e                	jmp    105ce9 <strfind+0x29>
        }
        s ++;
  105cdb:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
    while (*s != '\0') {
  105cdf:	8b 45 08             	mov    0x8(%ebp),%eax
  105ce2:	0f b6 00             	movzbl (%eax),%eax
  105ce5:	84 c0                	test   %al,%al
  105ce7:	75 e5                	jne    105cce <strfind+0xe>
        if (*s == c) {
            break;
        }
        s ++;
    }
    return (char *)s;
  105ce9:	8b 45 08             	mov    0x8(%ebp),%eax
}
  105cec:	c9                   	leave  
  105ced:	c3                   	ret    

00105cee <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  105cee:	55                   	push   %ebp
  105cef:	89 e5                	mov    %esp,%ebp
  105cf1:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  105cf4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  105cfb:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  105d02:	eb 04                	jmp    105d08 <strtol+0x1a>
        s ++;
  105d04:	83 45 08 01          	addl   $0x1,0x8(%ebp)
strtol(const char *s, char **endptr, int base) {
    int neg = 0;
    long val = 0;

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  105d08:	8b 45 08             	mov    0x8(%ebp),%eax
  105d0b:	0f b6 00             	movzbl (%eax),%eax
  105d0e:	3c 20                	cmp    $0x20,%al
  105d10:	74 f2                	je     105d04 <strtol+0x16>
  105d12:	8b 45 08             	mov    0x8(%ebp),%eax
  105d15:	0f b6 00             	movzbl (%eax),%eax
  105d18:	3c 09                	cmp    $0x9,%al
  105d1a:	74 e8                	je     105d04 <strtol+0x16>
        s ++;
    }

    // plus/minus sign
    if (*s == '+') {
  105d1c:	8b 45 08             	mov    0x8(%ebp),%eax
  105d1f:	0f b6 00             	movzbl (%eax),%eax
  105d22:	3c 2b                	cmp    $0x2b,%al
  105d24:	75 06                	jne    105d2c <strtol+0x3e>
        s ++;
  105d26:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  105d2a:	eb 15                	jmp    105d41 <strtol+0x53>
    }
    else if (*s == '-') {
  105d2c:	8b 45 08             	mov    0x8(%ebp),%eax
  105d2f:	0f b6 00             	movzbl (%eax),%eax
  105d32:	3c 2d                	cmp    $0x2d,%al
  105d34:	75 0b                	jne    105d41 <strtol+0x53>
        s ++, neg = 1;
  105d36:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  105d3a:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  105d41:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105d45:	74 06                	je     105d4d <strtol+0x5f>
  105d47:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  105d4b:	75 24                	jne    105d71 <strtol+0x83>
  105d4d:	8b 45 08             	mov    0x8(%ebp),%eax
  105d50:	0f b6 00             	movzbl (%eax),%eax
  105d53:	3c 30                	cmp    $0x30,%al
  105d55:	75 1a                	jne    105d71 <strtol+0x83>
  105d57:	8b 45 08             	mov    0x8(%ebp),%eax
  105d5a:	83 c0 01             	add    $0x1,%eax
  105d5d:	0f b6 00             	movzbl (%eax),%eax
  105d60:	3c 78                	cmp    $0x78,%al
  105d62:	75 0d                	jne    105d71 <strtol+0x83>
        s += 2, base = 16;
  105d64:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  105d68:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  105d6f:	eb 2a                	jmp    105d9b <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
  105d71:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105d75:	75 17                	jne    105d8e <strtol+0xa0>
  105d77:	8b 45 08             	mov    0x8(%ebp),%eax
  105d7a:	0f b6 00             	movzbl (%eax),%eax
  105d7d:	3c 30                	cmp    $0x30,%al
  105d7f:	75 0d                	jne    105d8e <strtol+0xa0>
        s ++, base = 8;
  105d81:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  105d85:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  105d8c:	eb 0d                	jmp    105d9b <strtol+0xad>
    }
    else if (base == 0) {
  105d8e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105d92:	75 07                	jne    105d9b <strtol+0xad>
        base = 10;
  105d94:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  105d9b:	8b 45 08             	mov    0x8(%ebp),%eax
  105d9e:	0f b6 00             	movzbl (%eax),%eax
  105da1:	3c 2f                	cmp    $0x2f,%al
  105da3:	7e 1b                	jle    105dc0 <strtol+0xd2>
  105da5:	8b 45 08             	mov    0x8(%ebp),%eax
  105da8:	0f b6 00             	movzbl (%eax),%eax
  105dab:	3c 39                	cmp    $0x39,%al
  105dad:	7f 11                	jg     105dc0 <strtol+0xd2>
            dig = *s - '0';
  105daf:	8b 45 08             	mov    0x8(%ebp),%eax
  105db2:	0f b6 00             	movzbl (%eax),%eax
  105db5:	0f be c0             	movsbl %al,%eax
  105db8:	83 e8 30             	sub    $0x30,%eax
  105dbb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105dbe:	eb 48                	jmp    105e08 <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
  105dc0:	8b 45 08             	mov    0x8(%ebp),%eax
  105dc3:	0f b6 00             	movzbl (%eax),%eax
  105dc6:	3c 60                	cmp    $0x60,%al
  105dc8:	7e 1b                	jle    105de5 <strtol+0xf7>
  105dca:	8b 45 08             	mov    0x8(%ebp),%eax
  105dcd:	0f b6 00             	movzbl (%eax),%eax
  105dd0:	3c 7a                	cmp    $0x7a,%al
  105dd2:	7f 11                	jg     105de5 <strtol+0xf7>
            dig = *s - 'a' + 10;
  105dd4:	8b 45 08             	mov    0x8(%ebp),%eax
  105dd7:	0f b6 00             	movzbl (%eax),%eax
  105dda:	0f be c0             	movsbl %al,%eax
  105ddd:	83 e8 57             	sub    $0x57,%eax
  105de0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105de3:	eb 23                	jmp    105e08 <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  105de5:	8b 45 08             	mov    0x8(%ebp),%eax
  105de8:	0f b6 00             	movzbl (%eax),%eax
  105deb:	3c 40                	cmp    $0x40,%al
  105ded:	7e 3d                	jle    105e2c <strtol+0x13e>
  105def:	8b 45 08             	mov    0x8(%ebp),%eax
  105df2:	0f b6 00             	movzbl (%eax),%eax
  105df5:	3c 5a                	cmp    $0x5a,%al
  105df7:	7f 33                	jg     105e2c <strtol+0x13e>
            dig = *s - 'A' + 10;
  105df9:	8b 45 08             	mov    0x8(%ebp),%eax
  105dfc:	0f b6 00             	movzbl (%eax),%eax
  105dff:	0f be c0             	movsbl %al,%eax
  105e02:	83 e8 37             	sub    $0x37,%eax
  105e05:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  105e08:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105e0b:	3b 45 10             	cmp    0x10(%ebp),%eax
  105e0e:	7c 02                	jl     105e12 <strtol+0x124>
            break;
  105e10:	eb 1a                	jmp    105e2c <strtol+0x13e>
        }
        s ++, val = (val * base) + dig;
  105e12:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  105e16:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105e19:	0f af 45 10          	imul   0x10(%ebp),%eax
  105e1d:	89 c2                	mov    %eax,%edx
  105e1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105e22:	01 d0                	add    %edx,%eax
  105e24:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
  105e27:	e9 6f ff ff ff       	jmp    105d9b <strtol+0xad>

    if (endptr) {
  105e2c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  105e30:	74 08                	je     105e3a <strtol+0x14c>
        *endptr = (char *) s;
  105e32:	8b 45 0c             	mov    0xc(%ebp),%eax
  105e35:	8b 55 08             	mov    0x8(%ebp),%edx
  105e38:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  105e3a:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  105e3e:	74 07                	je     105e47 <strtol+0x159>
  105e40:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105e43:	f7 d8                	neg    %eax
  105e45:	eb 03                	jmp    105e4a <strtol+0x15c>
  105e47:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  105e4a:	c9                   	leave  
  105e4b:	c3                   	ret    

00105e4c <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  105e4c:	55                   	push   %ebp
  105e4d:	89 e5                	mov    %esp,%ebp
  105e4f:	57                   	push   %edi
  105e50:	83 ec 24             	sub    $0x24,%esp
  105e53:	8b 45 0c             	mov    0xc(%ebp),%eax
  105e56:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  105e59:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  105e5d:	8b 55 08             	mov    0x8(%ebp),%edx
  105e60:	89 55 f8             	mov    %edx,-0x8(%ebp)
  105e63:	88 45 f7             	mov    %al,-0x9(%ebp)
  105e66:	8b 45 10             	mov    0x10(%ebp),%eax
  105e69:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  105e6c:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  105e6f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  105e73:	8b 55 f8             	mov    -0x8(%ebp),%edx
  105e76:	89 d7                	mov    %edx,%edi
  105e78:	f3 aa                	rep stos %al,%es:(%edi)
  105e7a:	89 fa                	mov    %edi,%edx
  105e7c:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  105e7f:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
  105e82:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  105e85:	83 c4 24             	add    $0x24,%esp
  105e88:	5f                   	pop    %edi
  105e89:	5d                   	pop    %ebp
  105e8a:	c3                   	ret    

00105e8b <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  105e8b:	55                   	push   %ebp
  105e8c:	89 e5                	mov    %esp,%ebp
  105e8e:	57                   	push   %edi
  105e8f:	56                   	push   %esi
  105e90:	53                   	push   %ebx
  105e91:	83 ec 30             	sub    $0x30,%esp
  105e94:	8b 45 08             	mov    0x8(%ebp),%eax
  105e97:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105e9a:	8b 45 0c             	mov    0xc(%ebp),%eax
  105e9d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105ea0:	8b 45 10             	mov    0x10(%ebp),%eax
  105ea3:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  105ea6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105ea9:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  105eac:	73 42                	jae    105ef0 <memmove+0x65>
  105eae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105eb1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  105eb4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105eb7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  105eba:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105ebd:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  105ec0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105ec3:	c1 e8 02             	shr    $0x2,%eax
  105ec6:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
  105ec8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  105ecb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105ece:	89 d7                	mov    %edx,%edi
  105ed0:	89 c6                	mov    %eax,%esi
  105ed2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  105ed4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  105ed7:	83 e1 03             	and    $0x3,%ecx
  105eda:	74 02                	je     105ede <memmove+0x53>
  105edc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  105ede:	89 f0                	mov    %esi,%eax
  105ee0:	89 fa                	mov    %edi,%edx
  105ee2:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  105ee5:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  105ee8:	89 45 d0             	mov    %eax,-0x30(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
  105eeb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105eee:	eb 36                	jmp    105f26 <memmove+0x9b>
    asm volatile (
        "std;"
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  105ef0:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105ef3:	8d 50 ff             	lea    -0x1(%eax),%edx
  105ef6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105ef9:	01 c2                	add    %eax,%edx
  105efb:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105efe:	8d 48 ff             	lea    -0x1(%eax),%ecx
  105f01:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105f04:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
        return __memcpy(dst, src, n);
    }
    int d0, d1, d2;
    asm volatile (
  105f07:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105f0a:	89 c1                	mov    %eax,%ecx
  105f0c:	89 d8                	mov    %ebx,%eax
  105f0e:	89 d6                	mov    %edx,%esi
  105f10:	89 c7                	mov    %eax,%edi
  105f12:	fd                   	std    
  105f13:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  105f15:	fc                   	cld    
  105f16:	89 f8                	mov    %edi,%eax
  105f18:	89 f2                	mov    %esi,%edx
  105f1a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  105f1d:	89 55 c8             	mov    %edx,-0x38(%ebp)
  105f20:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
        : "memory");
    return dst;
  105f23:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  105f26:	83 c4 30             	add    $0x30,%esp
  105f29:	5b                   	pop    %ebx
  105f2a:	5e                   	pop    %esi
  105f2b:	5f                   	pop    %edi
  105f2c:	5d                   	pop    %ebp
  105f2d:	c3                   	ret    

00105f2e <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  105f2e:	55                   	push   %ebp
  105f2f:	89 e5                	mov    %esp,%ebp
  105f31:	57                   	push   %edi
  105f32:	56                   	push   %esi
  105f33:	83 ec 20             	sub    $0x20,%esp
  105f36:	8b 45 08             	mov    0x8(%ebp),%eax
  105f39:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105f3c:	8b 45 0c             	mov    0xc(%ebp),%eax
  105f3f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105f42:	8b 45 10             	mov    0x10(%ebp),%eax
  105f45:	89 45 ec             	mov    %eax,-0x14(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  105f48:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105f4b:	c1 e8 02             	shr    $0x2,%eax
  105f4e:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
  105f50:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105f53:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105f56:	89 d7                	mov    %edx,%edi
  105f58:	89 c6                	mov    %eax,%esi
  105f5a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  105f5c:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  105f5f:	83 e1 03             	and    $0x3,%ecx
  105f62:	74 02                	je     105f66 <memcpy+0x38>
  105f64:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  105f66:	89 f0                	mov    %esi,%eax
  105f68:	89 fa                	mov    %edi,%edx
  105f6a:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  105f6d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  105f70:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
  105f73:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  105f76:	83 c4 20             	add    $0x20,%esp
  105f79:	5e                   	pop    %esi
  105f7a:	5f                   	pop    %edi
  105f7b:	5d                   	pop    %ebp
  105f7c:	c3                   	ret    

00105f7d <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  105f7d:	55                   	push   %ebp
  105f7e:	89 e5                	mov    %esp,%ebp
  105f80:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  105f83:	8b 45 08             	mov    0x8(%ebp),%eax
  105f86:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  105f89:	8b 45 0c             	mov    0xc(%ebp),%eax
  105f8c:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  105f8f:	eb 30                	jmp    105fc1 <memcmp+0x44>
        if (*s1 != *s2) {
  105f91:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105f94:	0f b6 10             	movzbl (%eax),%edx
  105f97:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105f9a:	0f b6 00             	movzbl (%eax),%eax
  105f9d:	38 c2                	cmp    %al,%dl
  105f9f:	74 18                	je     105fb9 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  105fa1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105fa4:	0f b6 00             	movzbl (%eax),%eax
  105fa7:	0f b6 d0             	movzbl %al,%edx
  105faa:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105fad:	0f b6 00             	movzbl (%eax),%eax
  105fb0:	0f b6 c0             	movzbl %al,%eax
  105fb3:	29 c2                	sub    %eax,%edx
  105fb5:	89 d0                	mov    %edx,%eax
  105fb7:	eb 1a                	jmp    105fd3 <memcmp+0x56>
        }
        s1 ++, s2 ++;
  105fb9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  105fbd:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
  105fc1:	8b 45 10             	mov    0x10(%ebp),%eax
  105fc4:	8d 50 ff             	lea    -0x1(%eax),%edx
  105fc7:	89 55 10             	mov    %edx,0x10(%ebp)
  105fca:	85 c0                	test   %eax,%eax
  105fcc:	75 c3                	jne    105f91 <memcmp+0x14>
        if (*s1 != *s2) {
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
    }
    return 0;
  105fce:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105fd3:	c9                   	leave  
  105fd4:	c3                   	ret    
