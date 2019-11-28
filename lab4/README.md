# Lab4:内核线程管理

![](https://tva1.sinaimg.cn/large/006y8mN6ly1g9d4l4k8lcj311m0u07eo.jpg)

## 实验目的

* 了解内核线程创建/执行的管理过程
* 了解内核线程的切换和基本调度过程

## 实验内容

实验2/3完成了物理和虚拟内存管理，这给创建内核线程（内核线程是一种特殊的进程）打下了提供内存管理的基础。当一个程序加载到内存中运行时，首先通过ucore OS的内存管理子系统分配合适的空间，然后就需要考虑如何分时使用CPU来“并发”执行多个程序，让每个运行的程序（这里用线程或进程表示）“感到”它们各自拥有“自己”的CPU。

本次实验将首先接触的是内核线程的管理。内核线程是一种特殊的进程，内核线程与用户进程的区别有两个：

* 内核线程只运行在内核态
* 用户进程会在在用户态和内核态交替运行
* 所有内核线程共用ucore内核内存空间，不需为每个内核线程维护单独的内存空间
* 而用户进程需要维护各自的用户内存空间

## 练习0：填写已有实验

本实验依赖实验1/2/3。请把你做的实验1/2/3的代码填入本实验中代码中有“LAB1”,“LAB2”,“LAB3”的注释相应部分。

---

利用Meld Diff软件把修改过的部分修改到lab4中。

具体有`vmm.c trap.c default_pmm.c pmm.c swap_fifo.c`

## 练习1：分配并初始化一个进程控制块（需要编码）

`alloc_proc`函数（位于`kern/process/proc.c`中）负责分配并返回一个新的`struct proc_struct`结构，用于存储新建立的内核线程的管理信息。ucore需要对这个结构进行最基本的初始化，你需要完成这个初始化过程。

>【提示】在`alloc_proc`函数的实现中，需要初始化的`proc_struct`结构中的成员变量至少包括：`state/pid/runs/kstack/need_resched/parent/mm/context/tf/cr3/flags/name`。

---

### 1.1 当前流程总结

* `pmm_init()`：初始化物理内存管理器；初始化空闲页，主要是初始化物理页的Page数据结构，以及建立页目录表和页表；初始化`boot_cr3`使之指向了ucore内核虚拟空间的页目录表首地址，即一级页表的起始物理地址；初始化第一个页表`boot_pgdir`；初始化GDT（全局描述符表）
* `pic_init()`：初始化中断控制器
* `idt_init()`：初始化`IDT`（中断描述符表）
* `vmm_init()`：实验一个`do_pgfault()`函数达到页错误异常处理功能，以及虚拟内存相关的`mm`、`vma`结构数据的创建/销毁/查找/插入等函数
* `proc_init()`：启动了创建内核线程的步骤，完成了`idleproc`内核线程和`initproc`内核线程的创建或复制工作
* `ide_init()`：完成对用于页换入换出的硬盘(简称 swap 硬盘)的初始化工作
* `swap_init()`：建立完成页面替换过程的主要功能模块，即 `swap_manager`，其中包含了页面置换算法的实现

### 1.2 `proc_struct`

`kern/process/proc.h`42-57

```
struct proc_struct {
    enum proc_state state;                      // Process state
    int pid;                                    // Process ID
    int runs;                                   // the running times of Proces
    uintptr_t kstack;                           // Process kernel stack
    volatile bool need_resched;                 // bool value: need to be rescheduled to release CPU?
    struct proc_struct *parent;                 // the parent process
    struct mm_struct *mm;                       // Process's memory management field
    struct context context;                     // Switch here to run process
    struct trapframe *tf;                       // Trap frame for current interrupt
    uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
    uint32_t flags;                             // Process flag
    char name[PROC_NAME_LEN + 1];               // Process name
    list_entry_t list_link;                     // Process link list 
    list_entry_t hash_link;                     // Process hash list
};
```

* `state`：进程所处的状态
* `kstack`: 每个线程都有一个内核栈，并且位于内核地址空间的不同位置
* `parent`：用户进程的父进程（创建它的进程）。在所有进程中，只有一个进程没有父进程，就是内核创建的第一个内核线程`idleproc`。内核根据这个父子关系建立一个树形结构，用于维护一些特殊的操作，例如确定某个进程是否可以对另外一个进程进行某种操作等等
* `mm`：内存管理的信息，包括内存映射列表、页表指针等。`mm`成员变量在lab3中用于虚存管理。但在实际OS中，内核线程常驻内存，不需要考虑swap page问题，在lab5中涉及到了用户进程，才考虑进程用户内存空间的swap page问题，mm才会发挥作用。所以在lab4中，内核线程的`proc_struct`的成员变量`*mm=0`
* `context`：进程的上下文，用于进程切换（参见switch.S），在 ucore中，所有的进程在内核中也是相对独立的，使用 `context` 保存寄存器的目的就在于在内核态中能够进行上下文之间的切换。实际利用`context`进行上下文切换的函数是在`kern/process/switch.S`中定义`switch_to`
* `tf`：中断帧的指针，总是指向内核栈的某个位置。当进程从用户空间跳到内核空间时，中断帧记录了进程在被中断前的状态，当内核需要跳回用户空间时，需要调整中断帧以恢复让进程继续执行的各寄存器值。ucore内核允许嵌套中断，因此为了保证嵌套中断发生时tf 总是能够指向当前的`trapframe`，ucore 在内核栈上维护了`tf`的链
* `cr3`：保存页表的物理地址。由于`*mm=NULL`，所以在`proc_struct`数据结构中需要有一个代替`pgdir`项来记录页表起始地址，这就是`proc_struct`数据结构中的`cr3`成员变量

### 1.3 `alloc_proc`函数

功能是分配一个新的`struct proc_struct`结构，初始化一些变量。

`kern/process/proc.c`85-119

```
static struct proc_struct *
alloc_proc(void) {
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
    if (proc != NULL) {
    //LAB4:EXERCISE1 YOUR CODE
    /*
     * below fields in proc_struct need to be initialized
     *       enum proc_state state;                      // Process state
     *       int pid;                                    // Process ID
     *       int runs;                                   // the running times of Proces
     *       uintptr_t kstack;                           // Process kernel stack
     *       volatile bool need_resched;                 // bool value: need to be rescheduled to release CPU?
     *       struct proc_struct *parent;                 // the parent process
     *       struct mm_struct *mm;                       // Process's memory management field
     *       struct context context;                     // Switch here to run process
     *       struct trapframe *tf;                       // Trap frame for current interrupt
     *       uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
     *       uint32_t flags;                             // Process flag
     *       char name[PROC_NAME_LEN + 1];               // Process name
     */
        //设置进程为未初始化状态
        proc->state = PROC_UNINIT;
        //未初始化的的进程id为-1
        proc->pid = -1;
        //初始化时间片
        proc->runs = 0;
        //内存栈的地址
        proc->kstack = 0;
        //是否需要调度设为不需要
        proc->need_resched = 0;
        //父节点设为空
        proc->parent = NULL;
        //内核线程常驻内存，虚拟内存设为空
        proc->mm = NULL;
        //上下文的初始化
        memset(&(proc->context), 0, sizeof(struct context));
        //中断帧指针置为空
        proc->tf = NULL;
        //页目录设为内核页目录表的基址
        proc->cr3 = boot_cr3;
        //标志位
        proc->flags = 0;
        //进程名
        memset(proc->name, 0, PROC_NAME_LEN);
    }
    return proc;
}
```

### 1.4 问题

请说明`proc_struct`中`struct context context`和`struct trapframe *tf`成员变量含义和在本实验中的作用是啥？（提示通过看代码和编程调试可以判断出来）

#### `struct context context`

在 ucore中，所有的进程在内核中也是相对独立的，使用`context`保存寄存器的目的就在于在内核态中能够进行上下文之间的切换。

`proc.h`25-34

```
struct context {
    uint32_t eip;
    uint32_t esp;
    uint32_t ebx;
    uint32_t ecx;
    uint32_t edx;
    uint32_t esi;
    uint32_t edi;
    uint32_t ebp;
};
```

存储了除了`eax`之外的所有通用寄存器以及`eip`的数值。

#### `kern/process/switch.S`中`switch_to`函数

```
.text
.globl switch_to
switch_to:                      # switch_to(from, to)

    # save from's registers
    movl 4(%esp), %eax          # eax points to from
    popl 0(%eax)                # save eip !popl
    movl %esp, 4(%eax)
    movl %ebx, 8(%eax)
    movl %ecx, 12(%eax)
    movl %edx, 16(%eax)
    movl %esi, 20(%eax)
    movl %edi, 24(%eax)
    movl %ebp, 28(%eax)

    # restore to's registers
    movl 4(%esp), %eax          # not 8(%esp): popped return address already
                                # eax now points to to
    movl 28(%eax), %ebp
    movl 24(%eax), %edi
    movl 20(%eax), %esi
    movl 16(%eax), %edx
    movl 12(%eax), %ecx
    movl 8(%eax), %ebx
    movl 4(%eax), %esp

    pushl 0(%eax)               # push eip

    ret
```

* 首先，保存前一个进程的执行现场，保存了进程在返回`switch_to`函数后的指令地址到`context.eip`中
* 保存前一个进程的其他7个寄存器到`context`中的相应成员变量中
* 再往后是恢复向一个进程的执行现场，这其实就是上述保存过程的逆执行过程，即从`context`的高地址的成员变量`ebp`开始，逐一把相关成员变量的值赋值给对应的寄存器
* 把`context`中保存的下一个进程要执行的指令地址`context.eip`放到了堆栈顶，这样接下来执行最后一条指令`ret`时，会把栈顶的内容赋值给EIP寄存器，这样就切换到下一个进程执行了

#### `struct trapframe *tf`

`kern/trap/trap.h`62-83

```
struct trapframe {
    struct pushregs tf_regs;
    uint16_t tf_gs;
    uint16_t tf_padding0;
    uint16_t tf_fs;
    uint16_t tf_padding1;
    uint16_t tf_es;
    uint16_t tf_padding2;
    uint16_t tf_ds;
    uint16_t tf_padding3;
    uint32_t tf_trapno;
    /* below here defined by x86 hardware */
    uint32_t tf_err;
    uintptr_t tf_eip;
    uint16_t tf_cs;
    uint16_t tf_padding4;
    uint32_t tf_eflags;
    /* below here only when crossing rings, such as from user to kernel */
    uintptr_t tf_esp;
    uint16_t tf_ss;
    uint16_t tf_padding5;
} __attribute__((packed));
```

`tf`：中断帧的指针，总是指向内核栈的某个位置（用于特权级转换）。当进程从用户空间跳到内核空间时，中断帧记录了进程在被中断前的状态。当内核需要跳回用户空间时，需要调整中断帧以恢复让进程继续执行的各寄存器值。ucore内核允许嵌套中断，因此为了保证嵌套中断发生时`tf`总是能够指向当前的`trapframe`，`ucore`在内核栈上维护了`tf`的链。

#### 二者区别

* 从内容上看：`trap_frame`包含了`context`的信息，除此之外，`trap_frame`还保存有段寄存器、中断号、错误码和状态寄存器等信息
* 从作用时机来看：`context`主要用于进程切换时保存进程上下文，`trap_frame`主要用于发生中断或异常时保存进程状态
* 当进程进行系统调用或发生中断时，会发生特权级转换，这时也会切换栈，因此需要保存栈信息到`trap_frame`，但不需要更新`context`

如果是在特权态3发生了中断/异常/系统调用，则CPU会从特权态3-->特权态0，且CPU从此栈顶（当前被打断进程的内核栈顶）开始压栈来保存被中断/异常/系统调用打断的用户态执行现场。如果是在特权态0发生了中断/异常/系统调用，则CPU会从从当前内核栈指针esp所指的位置开始压栈保存被中断/异常/系统调用打断的内核态执行现场。

## 练习2：为新创建的内核线程分配资源（需要编码）

创建一个内核线程需要分配和设置好很多资源。`kernel_thread`函数通过调用`do_fork`函数完成具体内核线程的创建工作。`do_kernel`函数会调用`alloc_proc`函数来分配并初始化一个进程控制块，但`alloc_proc`只是找到了一小块内存用以记录进程的必要信息，并没有实际分配这些资源。ucore一般通过`do_fork`实际创建新的内核线程。`do_fork`的作用是，创建当前内核线程的一个副本，它们的执行上下文、代码、数据都一样，但是存储位置不同。在这个过程中，需要给新内核线程分配资源，并且复制原进程的状态。你需要完成在`kern/process/proc.c`中的`do_fork`函数中的处理过程。它的大致执行步骤包括：

* 调用`alloc_proc`，首先获得一块用户信息块。
* 为进程分配一个内核栈。
* 复制原进程的内存管理信息到新进程（但内核线程不必做此事）
* 复制原进程上下文到新进程
* 将新进程添加到进程列表
* 唤醒新进程
* 返回新进程号

---

### 2.1 `do_fork`函数

`proc.h`278-346

```
int
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
	 //尝试为进程分配内存
    int ret = -E_NO_FREE_PROC;
    //新进程
    struct proc_struct *proc;
    if (nr_process >= MAX_PROCESS) {
        goto fork_out;
    }
    //内存不足而分配失败
    ret = -E_NO_MEM;
    //LAB4:EXERCISE2 YOUR CODE
    /*
     * Some Useful MACROs, Functions and DEFINEs, you can use them in below implementation.
     * MACROs or Functions:
     *   alloc_proc:   create a proc struct and init fields (lab4:exercise1)
     *   setup_kstack: alloc pages with size KSTACKPAGE as process kernel stack
     *   copy_mm:      process "proc" duplicate OR share process "current"'s mm according clone_flags
     *                 if clone_flags & CLONE_VM, then "share" ; else "duplicate"
     *   copy_thread:  setup the trapframe on the  process's kernel stack top and
     *                 setup the kernel entry point and stack of process
     *   hash_proc:    add proc into proc hash_list
     *   get_pid:      alloc a unique pid for process
     *   wakup_proc:   set proc->state = PROC_RUNNABLE
     * VARIABLES:
     *   proc_list:    the process set's list
     *   nr_process:   the number of process set
     */

    //    1. call alloc_proc to allocate a proc_struct
    //    2. call setup_kstack to allocate a kernel stack for child process
    //    3. call copy_mm to dup OR share mm according clone_flag
    //    4. call copy_thread to setup tf & context in proc_struct
    //    5. insert proc_struct into hash_list && proc_list
    //    6. call wakup_proc to make the new child process RUNNABLE
    //    7. set ret vaule using child proc's pid
    //调用 alloc_proc() 函数申请内存块
    if ((proc = alloc_proc()) == NULL) {
        goto fork_out;
    }
    //将子进程的父节点设置为当前进程
    proc->parent = current;
    //调用 setup_stack() 函数为进程分配一个内核栈
    if (setup_kstack(proc) != 0) {
        //分配内核栈失败
        goto bad_fork_cleanup_proc;
    }
    //调用 copy_mm() 函数复制父进程的内存信息到子进程
    if (copy_mm(clone_flags, proc) != 0) {
        goto bad_fork_cleanup_kstack;
    }
    //调用 copy_thread() 函数复制父进程的中断帧和上下文信息
    copy_thread(proc, stack, tf);

    bool intr_flag;
    //将新进程添加到进程的 hash 列表中
    //全局变量static list_entry_t hash_list[HASH_LIST_SIZE]（所有进程控制块的哈希表）
    //屏蔽中断，intr_flag 置为 1
    local_intr_save(intr_flag);
    {
        //获取当前进程 PID
        proc->pid = get_pid();
        //建立 hash 映射
        hash_proc(proc);
        //将进程加入到进程的链表中
        list_add(&proc_list, &(proc->list_link));
        //进程数加 1
        nr_process ++;
    }
    //恢复中断
    local_intr_restore(intr_flag);
    //唤醒子进程
    wakeup_proc(proc);
    //返回子进程的 pid
    ret = proc->pid;
fork_out:
    return ret;

bad_fork_cleanup_kstack:
    put_kstack(proc);
bad_fork_cleanup_proc:
    kfree(proc);
    goto fork_out;
}
```

### 2.2 问题

请说明ucore是否做到给每个新fork的线程一个唯一的id？请说明你的分析和理由。

做到了。可以看`get_pid()`函数。

`proc.h`137-169

```
static int
get_pid(void) {
    static_assert(MAX_PID > MAX_PROCESS);
    struct proc_struct *proc;
    list_entry_t *list = &proc_list, *le;
    //两个静态变量last_pid以及next_safe
    //last_pid变量保存上一次分配的PID，而next_safe和last_pid一起表示一段可以使用的PID取值范围(last_pid,next_safe)
    static int next_safe = MAX_PID, last_pid = MAX_PID;
    //同时要求PID的取值范围为[1,MAX_PID]
    if (++ last_pid >= MAX_PID) {
        last_pid = 1;
        goto inside;
    }
    //每次调用 get_pid 时，除了确定一个可以分配的 PID 外，还需要确定 next_safe 来实现均摊以此优化时间复杂度
    if (last_pid >= next_safe) {
    inside:
        next_safe = MAX_PID;
    repeat:
        le = list;
        //PID 的确定过程中会检查所有进程的 PID，来确保 PID 是唯一的
        while ((le = list_next(le)) != list) {
            proc = le2proc(le, list_link);
            if (proc->pid == last_pid) {
                if (++ last_pid >= next_safe) {
                    if (last_pid >= MAX_PID) {
                        last_pid = 1;
                    }
                    next_safe = MAX_PID;
                    goto repeat;
                }
            }
            else if (proc->pid > last_pid && next_safe > proc->pid) {
                next_safe = proc->pid;
            }
        }
    }
    return last_pid;
}
```

## 练习3：阅读代码，理解`proc_run`函数和它调用的函数如何完成进程切换的。（无编码工作）

请在实验报告中简要说明你对`proc_run`函数的分析。并回答如下问题：

* 在本实验的执行过程中，创建且运行了几个内核线程？
* 语句`local_intr_save(intr_flag);....local_intr_restore(intr_flag);`在这里有何作用?请说明理由

完成代码编写后，编译并运行代码：`make qemu`

如果可以得到如 附录A所示的显示内容（仅供参考，不是标准答案输出），则基本正确。

---

### 3.1 `proc_run`函数

`proc.h`173-187

```
void
proc_run(struct proc_struct *proc) {
    // 判断需要运行的线程是否已经运行
    if (proc != current) {
        bool intr_flag;
        struct proc_struct *prev = current, *next = proc;
        //关闭中断，避免在进程切换过程中出现中断
        local_intr_save(intr_flag);
        {
            //将当前进程换为要切换到的进程
            current = proc;
            //设置任务状态段tss中的特权级0下的esp0指针为next内核线程的内核栈的栈顶
            load_esp0(next->kstack + KSTACKSIZE);
            //重新加载cr3寄存器(页目录表基址) 进行进程间的页表切换，修改当前的cr3寄存器成需要运行线程（进程）的页目录表
            lcr3(next->cr3);
        }
            //调用switch_to进行上下文的保存与切换，切换到新的线程
            switch_to(&(prev->context), &(next->context));
        }
        //恢复中断
        local_intr_restore(intr_flag);
    }
}
```

### 3.2 问题

#### 在本实验的执行过程中，创建且运行了几个内核线程？

两个。

* 第 0 个内核线程 idleproc：在完成新的内核线程的创建以及各种初始化工作之后，用于调度其他进程或线程。
* 第 1 个内核线程 initproc：只用来打印字符串。

#### 语句`local_intr_save(intr_flag);....local_intr_restore(intr_flag);`在这里有何作用?请说明理由

在进行进程切换的时候，需要避免出现中断干扰这个过程，所以需要在上下文切换期间清除`intr_flag`位屏蔽中断，并且在进程恢复执行后恢复`intr_flag`位。

### 3.3 运行结果

```
make qemu
```

显示`check_swap() succeded!`

![](https://tva1.sinaimg.cn/large/006y8mN6ly1g9dxzk1scaj30fw0blqde.jpg)

## 4 本次遇到的问题

### 4.1 swap交换空间不足

![](https://tva1.sinaimg.cn/large/006y8mN6ly1g9d4ml3i4yj30dj08wtbi.jpg)

解决方法：删除一些没用或冗余的文件，并且在virtual box中设置内存大小。

![](https://tva1.sinaimg.cn/large/006y8mN6ly1g9d4obcstej30ig0dumym.jpg)

但是治标不治本，需要研究新建未分配空间然后挂载磁盘的方法。

### 4.2 swap.img文件过大无法push

![](https://tva1.sinaimg.cn/large/006y8mN6ly1g9d5cncv3uj30nh0ak428.jpg)

查看日志，`git reset`回之前的版本，然后把`make clean`后的文件提交上去
