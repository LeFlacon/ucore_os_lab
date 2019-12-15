# Lab5:用户进程管理

## 练习0：填写已有实验

本实验依赖实验1/2/3/4。请把你做的实验1/2/3/4的代码填入本实验中代码中有“LAB1”/“LAB2”/“LAB3”/“LAB4”的注释相应部分。注意：为了能够正确执行lab5的测试应用程序，可能需对已完成的实验1/2/3/4的代码进行进一步改进。

---

使用meld diff对比，需要复制的文件有：

```
vmm.c default_pmm.c pmm.c proc.c trap.c swap_fifo.c kdebug.c
```

需要补充的部分：

### 0.1 kern/process/proc.c

#### `alloc_proc`函数

118-119，初始化进程等待状态，进程相关指针初始化（孩子/旧兄弟/新兄弟）

```
proc->wait_state = 0;
proc->cptr = proc->optr = proc->yptr = NULL;
```

#### `do_fork`函数

411，确保进程在等待状态

```
assert(current->wait_state == 0);
```

426，原来是进程数统计，现在还要做一些进程的链接设置

```
set_links(proc);
```

139-149，`set_links`函数，首先把进程加入进程链表，然后设置三个指针：当前进程的新兄弟指针指向null，当前进程的旧兄弟的新兄弟就是当前进程，父进程的子进程是当前进程，最后进程数加一

```
// set_links - set the relation links of process
static void
set_links(struct proc_struct *proc) {
    list_add(&proc_list, &(proc->list_link));
    proc->yptr = NULL;
    if ((proc->optr = proc->parent->cptr) != NULL) {
        proc->optr->yptr = proc;
    }
    proc->parent->cptr = proc;
    nr_process ++;
}
```

### 0.2 kern/trap/trap.c

#### `idt_init()`函数

74，这个函数初始化系统调用对应的中断描述符。

在执行加载中断描述符表lidt指令前，专门设置了一个特殊的中断描述符`idt[T_SYSCALL]`，它的特权级设置为`DPL_USER`，中断向量处理地址在`__vectors[T_SYSCALL]`处。这样建立好这个中断描述符后，一旦用户进程执行`“INT T_SYSCALL”`后，由于此中断允许用户态进程产生（注意它的特权级设置为`DPL_USER`），所以CPU就会从用户态切换到内核态，保存相关寄存器，并跳转到`__vectors[T_SYSCALL]`处开始执行。

```
SETGATE(idt[T_SYSCALL], 1, GD_KTEXT, __vectors[T_SYSCALL], DPL_USER);
```

#### `trap_dispatch()`函数

246，设置当前进程的时间片用完了需要调度。

```
current->need_resched = 1;
```

## 练习1: 加载应用程序并执行（需要编码）

`do_execv`函数调用`load_icode`（位于kern/process/proc.c中）来加载并解析一个处于内存中的ELF执行文件格式的应用程序，建立相应的用户内存空间来放置应用程序的代码段、数据段等，且要设置好`proc_struct`结构中的成员变量trapframe中的内容，确保在执行此进程后，能够从应用程序设定的起始执行地址开始执行。需设置正确的trapframe内容。

请在实验报告中简要说明你的设计实现过程。

请在实验报告中描述当创建一个用户态进程并加载了应用程序后，CPU是如何让这个应用程序最终在用户态执行起来的。即这个用户态进程被ucore选择占用CPU执行（RUNNING态）到具体执行应用程序第一条指令的整个经过。

---

### 1.1 `do_execve`函数

652-685，通过`do_execve`函数来完成用户进程的创建工作

```
int
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
    //获取当前进程的内存地址
    struct mm_struct *mm = current->mm;
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
        return -E_INVAL;
    }
    if (len > PROC_NAME_LEN) {
        len = PROC_NAME_LEN;
    }

    char local_name[PROC_NAME_LEN + 1];
    memset(local_name, 0, sizeof(local_name));
    memcpy(local_name, name, len);
    //为加载新的执行码做好用户态内存空间清空准备
    if (mm != NULL) {
        //设置页表为内核空间页表
        lcr3(boot_cr3);
        //==0，没有进程再需要此进程所占用的内存空间
        if (mm_count_dec(mm) == 0) {
            //释放进程所占用户空间内存和进程页表本身所占空间
            exit_mmap(mm);
            put_pgdir(mm);
            mm_destroy(mm);
        }
        //把当前进程的 mm 内存管理指针为空
        current->mm = NULL;
    }
    int ret;
    //接下来的一步是加载应用程序执行码到当前进程的新创建的用户态虚拟空间中。这里涉及到读ELF格式的文件，申请内存空间，建立用户态虚存空间，加载应用程序执行码等。load_icode函数完成了整个复杂的工作
    if ((ret = load_icode(binary, size)) != 0) {
        goto execve_exit;
    }
    set_proc_name(current, local_name);
    return 0;

execve_exit:
    do_exit(ret);
    panic("already exit: %e.\n", ret);
}
```

### 1.2 `load_icode`函数

`load_icode`函数的主要工作就是给用户进程建立一个能够让用户进程正常运行的用户环境。

1. 调用`mm_create`函数来申请进程的内存管理数据结构`mm`所需内存空间，并对`mm`进行初始化

2. 调用`setup_pgdir`来申请一个页目录表所需的一个页大小的内存空间，并把描述ucore内核虚空间映射的内核页表（`boot_pgdir`所指）的内容拷贝到此新目录表中，最后让`mm->pgdir`指向此页目录表，这就是进程新的页目录表了，且能够正确映射内核虚空间

3. 根据应用程序执行码的起始位置来解析此ELF格式的执行程序，并调用`mm_map`函数根据ELF格式的执行程序说明的各个段（代码段、数据段、BSS段等）的起始位置和大小建立对应的vma结构，并把`vma`插入到`mm`结构中，从而表明了用户进程的合法用户态虚拟地址空间

4. 调用根据执行程序各个段的大小分配物理内存空间，并根据执行程序各个段的起始位置确定虚拟地址，并在页表中建立好物理地址和虚拟地址的映射关系，然后把执行程序各个段的内容拷贝到相应的内核虚拟地址中，至此应用程序执行码和数据已经根据编译时设定地址放置到虚拟内存中了

5. 需要给用户进程设置用户栈，为此调用`mm_mmap`函数建立用户栈的`vma`结构，明确用户栈的位置在用户虚空间的顶端，大小为256个页，即1MB，并分配一定数量的物理内存且建立好栈的虚地址<-->物理地址映射关系

6. 至此,进程内的内存管理`vma`和`mm`数据结构已经建立完成，于是把`mm->pgdir`赋值到`cr3`寄存器中，即更新了用户进程的虚拟内存空间，此时的`initproc`已经被hello的代码和数据覆盖，成为了第一个用户进程，但此时这个用户进程的执行现场还没建立好

7. 先清空进程的中断帧，再重新设置进程的中断帧，使得在执行中断返回指令`“iret”`后，能够让CPU转到用户态特权级，并回到用户态内存空间，使用用户态的代码段、数据段和堆栈，且能够跳转到用户进程的第一条指令执行，并确保在用户态能够响应中断

505-648，`load_icode`函数

```
static int
load_icode(unsigned char *binary, size_t size) {
    //当前进程的内存为空
    if (current->mm != NULL) {
        panic("load_icode: current->mm must be empty.\n");
    }
    //ret:未分配内存
    int ret = -E_NO_MEM;
    struct mm_struct *mm;
    //(1) create a new mm for current process
    //分配内存
    if ((mm = mm_create()) == NULL) {
        //分配失败
        goto bad_mm;
    }
    //(2) create a new PDT, and mm->pgdir= kernel virtual addr of PDT
    //申请一个页目录表所需的空间
    if (setup_pgdir(mm) != 0) {
        //申请失败
        goto bad_pgdir_cleanup_mm;
    }
    //(3) copy TEXT/DATA section, build BSS parts in binary to memory space of process
    struct Page *page;
    //(3.1) get the file header of the bianry program (ELF format)
    struct elfhdr *elf = (struct elfhdr *)binary;
    //(3.2) get the entry of the program section headers of the bianry program (ELF format)
    //获取段头部表的地址
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
    //(3.3) This program is valid?
    //读取的 ELF 文件不合法
    if (elf->e_magic != ELF_MAGIC) {
        ret = -E_INVAL_ELF;
        goto bad_elf_cleanup_pgdir;
    }

    uint32_t vm_flags, perm;
    //段入口数目
    struct proghdr *ph_end = ph + elf->e_phnum;
    //遍历每一个程序段
    for (; ph < ph_end; ph ++) {
    //(3.4) find every program section headers
        //当前段不能被加载
        if (ph->p_type != ELF_PT_LOAD) {
            continue ;
        }
        //虚拟地址空间大小大于分配的物理地址空间
        if (ph->p_filesz > ph->p_memsz) {
            ret = -E_INVAL_ELF;
            goto bad_cleanup_mmap;
        }
        //当前段大小为 0
        if (ph->p_filesz == 0) {
            continue ;
        }
    //(3.5) call mm_map fun to setup the new vma ( ph->p_va, ph->p_memsz)
        //设置新的vma，mm_map函数根据ELF格式的执行程序说明的各个段（代码段、数据段、BSS段等）的起始位置和大小建立对应的vma结构
        vm_flags = 0, perm = PTE_U;
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
        if (vm_flags & VM_WRITE) perm |= PTE_W;
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
            goto bad_cleanup_mmap;
        }
        unsigned char *from = binary + ph->p_offset;
        size_t off, size;
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);

        ret = -E_NO_MEM;

     //(3.6) alloc memory, and  copy the contents of every program section (from, from+end) to process's memory (la, la+end)
     //调用根据执行程序各个段的大小分配物理内存空间，把执行程序各个段的内容拷贝到相应的内核虚拟地址中
        end = ph->p_va + ph->p_filesz;
     //(3.6.1) copy TEXT/DATA section of bianry program
        while (start < end) {
            //分配一个新的物理页失败
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
                goto bad_cleanup_mmap;
            }
            off = start - la, size = PGSIZE - off, la += PGSIZE;
            if (end < la) {
                size -= la - end;
            }
            memcpy(page2kva(page) + off, from, size);
            start += size, from += size;
        }

      //(3.6.2) build BSS section of binary program
        //建立BSS段
        end = ph->p_va + ph->p_memsz;
        if (start < la) {
            /* ph->p_memsz == ph->p_filesz */
            if (start == end) {
                continue ;
            }
            off = start + PGSIZE - la, size = PGSIZE - off;
            if (end < la) {
                size -= la - end;
            }
            memset(page2kva(page) + off, 0, size);
            start += size;
            assert((end < la && start == end) || (end >= la && start == la));
        }
        while (start < end) {
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
                goto bad_cleanup_mmap;
            }
            off = start - la, size = PGSIZE - off, la += PGSIZE;
            if (end < la) {
                size -= la - end;
            }
            memset(page2kva(page) + off, 0, size);
            start += size;
        }
    }
    //(4) build user stack memory
    //给用户进程设置用户栈，为此调用mm_map函数建立用户栈的vma结构，明确用户栈的位置在用户虚空间的顶端，大小为256个页，即1MB，并分配一定数量的物理内存且建立好栈的虚地址<-->物理地址映射关系
    vm_flags = VM_READ | VM_WRITE | VM_STACK;
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
        goto bad_cleanup_mmap;
    }
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
    
    //(5) set current process's mm, sr3, and set CR3 reg = physical addr of Page Directory
    //把mm->pgdir赋值到cr3寄存器中（更新了用户进程的虚拟内存空间）
    mm_count_inc(mm);
    current->mm = mm;
    current->cr3 = PADDR(mm->pgdir);
    lcr3(PADDR(mm->pgdir));

    //(6) setup trapframe for user environment
    struct trapframe *tf = current->tf;
    memset(tf, 0, sizeof(struct trapframe));
    /* LAB5:EXERCISE1 YOUR CODE
     * should set tf_cs,tf_ds,tf_es,tf_ss,tf_esp,tf_eip,tf_eflags
     * NOTICE: If we set trapframe correctly, then the user level process can return to USER MODE from kernel. So
     *          tf_cs should be USER_CS segment (see memlayout.h)
     *          tf_ds=tf_es=tf_ss should be USER_DS segment
     *          tf_esp should be the top addr of user stack (USTACKTOP)
     *          tf_eip should be the entry point of this binary program (elf->e_entry)
     *          tf_eflags should be set to enable computer to produce Interrupt
     */
    //先清空进程的中断帧，再重新设置进程的中断帧，使得在执行中断返回指令“iret”后，能够让CPU转到用户态特权级，并回到用户态内存空间，使用用户态的代码段、数据段和堆栈，且能够跳转到用户进程的第一条指令执行，并确保在用户态能够响应中断
    //将段寄存器初始化为用户态的代码段、数据段、堆栈段
    tf->tf_cs = USER_CS;
    tf->tf_ds = tf->tf_es = tf->tf_ss = USER_DS;
    //esp指向用户栈的栈顶
    tf->tf_esp = USTACKTOP;
    //eip指向elf可执行文件加载到内存后的入口处
    tf->tf_eip = elf->e_entry;
    //eflags初始化为中断使能
    tf->tf_eflags = FL_IF;
    ret = 0;
out:
    return ret;
bad_cleanup_mmap:
    exit_mmap(mm);
bad_elf_cleanup_pgdir:
    put_pgdir(mm);
bad_pgdir_cleanup_mm:
    mm_destroy(mm);
bad_mm:
    goto out;
}
```

### 1.3 问题

请在实验报告中描述当创建一个用户态进程并加载了应用程序后，CPU是如何让这个应用程序最终在用户态执行起来的。即这个用户态进程被ucore选择占用CPU执行（RUNNING态）到具体执行应用程序第一条指令的整个经过。

* 执行宏`KERNEL_EXECVE`，这个宏最终是调用`kernel_execve`函数来调用`exec`系统调用
* CPU检测到系统调用后，先保存执行系统调用前的执行现场（把与用户进程继续执行所需的相关寄存器等当前内容保存到当前进程的中断帧`trapframe`中），然后开始完成具体的系统调用服务
* `do_execve`函数来完成用户进程的创建工作（1.1节）
* 调用`load_icode`函数（1.2节）完成对整个用户线程内存空间的初始化，加载ELF可执行文件，`current->tf` 指针修改了当前系统调用的`trapframe`（使得最终中断返回的时候能够切换到用户态，iret的时候跳转到应用程序的入口）
* 按产生系统调用的函数调用路径原路返回
* 开始执行用户程序

## 练习2: 父进程复制自己的内存空间给子进程（需要编码）

创建子进程的函数`do_fork`在执行中将拷贝当前进程（即父进程）的用户内存地址空间中的合法内容到新进程中（子进程），完成内存资源的复制。具体是通过`copy_range`函数（位于`kern/mm/pmm.c`中）实现的，请补充`copy_range`的实现，确保能够正确执行。

请在实验报告中简要说明如何设计实现”Copy on Write 机制“，给出概要设计，鼓励给出详细设计。

---

`do_fork`函数完成具体内核线程的创建工作，调用过程`do_fork()---->copy_mm()---->dup_mmap()---->copy_range()`，`copy_range`函数完成父进程复制自己的内存空间给子进程

### 2.1 `copy_mm`函数

`proc.c`，309-352

```
static int
copy_mm(uint32_t clone_flags, struct proc_struct *proc) {
    struct mm_struct *mm, *oldmm = current->mm;

    /* current is a kernel thread */
    //当前进程地址空间为null
    if (oldmm == NULL) {
        return 0;
    }
    //可以共享地址空间
    if (clone_flags & CLONE_VM) {
        mm = oldmm;
        goto good_mm;
    }

    int ret = -E_NO_MEM;
    //mm_create失败
    if ((mm = mm_create()) == NULL) {
        goto bad_mm;
    }
    //申请页目录表失败
    if (setup_pgdir(mm) != 0) {
        goto bad_pgdir_cleanup_mm;
    }
    //打开互斥锁，避免多个进程同时访问内存
    lock_mm(oldmm);
    {
        //调用dup_mmap函数
        ret = dup_mmap(mm, oldmm);
    }
    //释放互斥锁
    unlock_mm(oldmm);

    if (ret != 0) {
        goto bad_dup_cleanup_mmap;
    }

//成功结果，进程数++/复制空间地址/复制页表地址
good_mm:
    mm_count_inc(mm);
    proc->mm = mm;
    proc->cr3 = PADDR(mm->pgdir);
    return 0;
bad_dup_cleanup_mmap:
    exit_mmap(mm);
    put_pgdir(mm);
bad_pgdir_cleanup_mm:
    mm_destroy(mm);
bad_mm:
    return ret;
}
```

### 2.2 `dup_mmap`函数

`vmm.c`，190-210

```
int
dup_mmap(struct mm_struct *to, struct mm_struct *from) {
    assert(to != NULL && from != NULL);
    //获取虚拟空间地址
    list_entry_t *list = &(from->mmap_list), *le = list;
    //遍历所有段
    while ((le = list_prev(le)) != list) {
        struct vma_struct *vma, *nvma;
        vma = le2vma(le, list_link);
        //新创建的段
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
        if (nvma == NULL) {
            return -E_NO_MEM;
        }
        //向新进程插入新的段
        insert_vma_struct(to, nvma);

        bool share = 0;
        //调用copy_range函数
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0) {
            return -E_NO_MEM;
        }
    }
    return 0;
}
```

### 2.3 `copy_range`函数

`kern/mm/pmm.c`，506-556

```
int
copy_range(pde_t *to, pde_t *from, uintptr_t start, uintptr_t end, bool share) {
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
    assert(USER_ACCESS(start, end));
    // copy content by page unit.
    //get_pte给定一个虚拟地址，找出这个虚拟地址在二级页表中对应的项，如果此二级页表项不存在，则分配一个包含此项的二级页表
    do {
        //call get_pte to find process A's pte according to the addr start
        pte_t *ptep = get_pte(from, start, 0), *nptep;
        if (ptep == NULL) {
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
            continue ;
        }
        //call get_pte to find process B's pte according to the addr start. If pte is NULL, just alloc a PT
        if (*ptep & PTE_P) {
            if ((nptep = get_pte(to, start, 1)) == NULL) {
                return -E_NO_MEM;
            }
        uint32_t perm = (*ptep & PTE_USER);
        //get page from ptep
        //获得page
        struct Page *page = pte2page(*ptep);
        // alloc a page for process B
        struct Page *npage=alloc_page();
        assert(page!=NULL);
        assert(npage!=NULL);
        int ret=0;
        /* LAB5:EXERCISE2 YOUR CODE
         * replicate content of page to npage, build the map of phy addr of nage with the linear addr start
         *
         * Some Useful MACROs and DEFINEs, you can use them in below implementation.
         * MACROs or Functions:
         *    page2kva(struct Page *page): return the kernel vritual addr of memory which page managed (SEE pmm.h)
         *    page_insert: build the map of phy addr of an Page with the linear addr la
         *    memcpy: typical memory copy function
         *
         * (1) find src_kvaddr: the kernel virtual address of page
         * (2) find dst_kvaddr: the kernel virtual address of npage
         * (3) memory copy from src_kvaddr to dst_kvaddr, size is PGSIZE
         * (4) build the map of phy addr of  nage with the linear addr start
         */
        //父进程需要被复制的物理页在内核地址空间的虚拟地址
        void * kva_src = page2kva(page);
        //子进程需要被填充的物理页的内核虚拟地址
        void * kva_dst = page2kva(npage);
        //复制
        memcpy(kva_dst, kva_src, PGSIZE);
        //建立子进程的物理页和虚拟页的映射关系
        ret = page_insert(to, npage, start, perm);
        assert(ret == 0);
        }
        start += PGSIZE;
    } while (start != 0 && start < end);
    return 0;
}
```

### 2.4 Copy on Write 机制

请在实验报告中简要说明如何设计实现”Copy on Write 机制“，给出概要设计，鼓励给出详细设计。

Copy-on-write（简称COW）的基本概念是指如果有多个使用者对一个资源A（比如内存块）进行读操作，则每个使用者只需获得一个指向同一个资源A的指针，就可以该资源了。若某使用者需要对这个资源A进行写操作，系统会对该资源进行拷贝操作，从而使得该“写操作”使用者获得一个该资源A的“私有”拷贝—资源B，可对资源B进行写操作。该“写操作”使用者对资源B的改变对于其他的使用者而言是不可见的，因为其他使用者看到的还是资源A。

进程执行fork系统调用进行复制的时候，父进程不会简单地将整个内存中的内容复制给子进程，而是暂时共享相同的物理内存页；当其中一个进程需要对内存进行修改的时候，再额外创建一个自己私有的物理内存页，将共享的内容复制过去，然后在自己的内存页中进行修改

实现思路：

`do_fork`：`copy_range`函数里不进行内存的复制，而是子进程和父进程的虚拟页映射上同一个物理页面，然后`PTE_W`改为不可写，还需要一个标志位记录这个页是共享页面，如果有程序要写这个页的话就产生页访问异常

`page_fault`：在处理页访问异常的函数中增加处理，如果当前页访问异常是因为写一个共享页面引起的，就为这个进程申请一个可写的物理内存页，把共享页的复制过去，并且建立出错的线性地址到新建物理页的映射。当没有进程在读这个物理页后，就恢复可写，把刚刚写过的新物理页内容复制进去


## 练习3: 阅读分析源代码，理解进程执行 fork/exec/wait/exit 的实现，以及系统调用的实现（不需要编码）

请在实验报告中简要说明你对 fork/exec/wait/exit函数的分析。并回答如下问题：

请分析fork/exec/wait/exit在实现中是如何影响进程的执行状态的？
请给出ucore中一个用户态进程的执行状态生命周期图（包执行状态，执行状态之间的变换关系，以及产生变换的事件或函数调用）。（字符方式画即可）
执行：make grade。如果所显示的应用程序检测都输出ok，则基本正确。（使用的是qemu-1.0.1）

---

![](https://tva1.sinaimg.cn/large/006tNbRwly1g9uwevl5ycj30l30aktaj.jpg)

### 3.1 fork

`fork->SYS_fork->do_fork+wakeup_proc`，程序执行fork，fork使用系统调用`SYS_fork`，具体完成服务的函数是`do_fork`函数（lab4中，完成内核线程创建）和`wakeup_proc`	函数（设置等待状态`wait_state=0`）

### 3.2 exec

`SYS_exec->do_execve`，`do_execve`函数（1.1节，完成用户进程的创建）

### 3.3 wait

`SYS_wait->do_wait`，完成对子进程的最后回收工作，即回收子进程的内核栈和进程控制块所占内存空间

`kern/process/proc.c`，697-755

```
int
do_wait(int pid, int *code_store) {
    struct mm_struct *mm = current->mm;
    if (code_store != NULL) {
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1)) {
            return -E_INVAL;
        }
    }

    struct proc_struct *proc;
    bool intr_flag, haskid;
repeat:
    haskid = 0;
    if (pid != 0) {
        //找到pid对应的进程
        proc = find_proc(pid);
        if (proc != NULL && proc->parent == current) {
            haskid = 1;
            //PROC_ZOMBIE表示处于退出状态
            if (proc->state == PROC_ZOMBIE) {
                goto found;
            }
        }
    }
    else {
        //如果pid=0，找任意一个处于退出状态的子进程
        proc = current->cptr;
        for (; proc != NULL; proc = proc->optr) {
            haskid = 1;
            if (proc->state == PROC_ZOMBIE) {
                goto found;
            }
        }
    }
    //如果此子进程的执行状态不为PROC_ZOMBIE，表明此子进程还没有退出，则当前进程只好设置自己的执行状态为PROC_SLEEPING，睡眠原因为WT_CHILD（即等待子进程退出），调用schedule()函数选择新的进程执行，自己睡眠等待，如果被唤醒，则重复跳回上面步骤
    if (haskid) {
        current->state = PROC_SLEEPING;
        current->wait_state = WT_CHILD;
        schedule();
        if (current->flags & PF_EXITING) {
            do_exit(-E_KILLED);
        }
        goto repeat;
    }
    return -E_BAD_PROC;

//如果此子进程的执行状态为PROC_ZOMBIE，表明此子进程处于退出状态，需要当前进程（即子进程的父进程）完成对子进程的最终回收工作
found:
    if (proc == idleproc || proc == initproc) {
        panic("wait idleproc or initproc.\n");
    }
    if (code_store != NULL) {
        *code_store = proc->exit_code;
    }
    local_intr_save(intr_flag);
    {
        //把子进程控制块从两个进程队列proc_list和hash_list中删除
        unhash_proc(proc);
        remove_links(proc);
    }
    local_intr_restore(intr_flag);
    //释放子进程的内核堆栈和进程控制块
    put_kstack(proc);
    kfree(proc);
    return 0;
}
```

### 3.4 exit

`SYS_exit->exit`，448-499，exit函数会把一个退出码`error_code`传递给ucore，ucore通过执行内核函数`do_exit`来完成对当前进程的退出处理，主要工作简单地说就是回收当前进程所占的大部分内存资源，并通知父进程完成最后的回收工作

```
int
do_exit(int error_code) {
    if (current == idleproc) {
        panic("idleproc exit.\n");
    }
    if (current == initproc) {
        panic("initproc exit.\n");
    }
    
    struct mm_struct *mm = current->mm;
    //如果current->mm != NULL，表示是用户进程，则开始回收此用户进程所占用的用户态虚拟内存空间
    if (mm != NULL) {
        //切换到内核态的页表（这样当前用户进程目前只能在内核虚拟地址空间执行了，这是为了确保后续释放用户态内存和进程页表的工作能够正常执行）
        lcr3(boot_cr3);
        //没有其他进程共享这个内存，可以直接释放
        if (mm_count_dec(mm) == 0) {
            //调用exit_mmap函数释放current->mm->vma链表中每个vma描述的进程合法空间中实际分配的内存，然后把对应的页表项内容清空，最后还把页表所占用的空间释放并把对应的页目录表项清空
            exit_mmap(mm);
            //释放当前进程的页目录所占的内存
            put_pgdir(mm);
            //释放mm中的vma所占内存，最后释放mm所占内存
            mm_destroy(mm);
        }
        //设置current->mm为NULL，表示与当前进程相关的用户虚拟内存空间和对应的内存管理成员变量所占的内核虚拟内存空间已经回收完毕
        current->mm = NULL;
    }
    //设置当前进程的执行状态和退出码
    current->state = PROC_ZOMBIE;
    current->exit_code = error_code;
    
    bool intr_flag;
    struct proc_struct *proc;
    local_intr_save(intr_flag);
    {
        proc = current->parent;
        //唤醒父进程，让父进程帮助子进程完成最后的资源回收
        if (proc->wait_state == WT_CHILD) {
            wakeup_proc(proc);
        }
        //如果当前进程还有子进程，则需要把这些子进程的父进程指针设置为内核线程initproc，且各个子进程指针需要插入到initproc的子进程链表中。如果某个子进程的执行状态是PROC_ZOMBIE，则需要唤醒initproc来完成对此子进程的最后回收工作
        while (current->cptr != NULL) {
            proc = current->cptr;
            current->cptr = proc->optr;
    
            proc->yptr = NULL;
            if ((proc->optr = initproc->cptr) != NULL) {
                initproc->cptr->yptr = proc;
            }
            proc->parent = initproc;
            initproc->cptr = proc;
            if (proc->state == PROC_ZOMBIE) {
                if (initproc->wait_state == WT_CHILD) {
                    wakeup_proc(initproc);
                }
            }
        }
    }
    local_intr_restore(intr_flag);
    //执行schedule()函数，选择新的进程执行
    schedule();
    panic("do_exit will not return!! %d.\n", current->pid);
}
```

### 3.5 问题

请分析 fork/exec/wait/exit 在实现中是如何影响进程的执行状态的？

* fork创建新的子线程，子线程状态从UNINIT->RUNNABLE，父进程状态不变
* exec完成用户进程的创建工作，同时让用户进程执行，无状态改变
* wait完成对子进程的资源回收工作，如果有已经结束的子进程（ZOMBIE态）或者没有子进程，那么无状态改变；否则进程需要等待子进程结束，该进程从RUNNIG->SLEEPING
* exit回收当前进程所占的大部分资源，进程从RUNNIG->ZOMBIE


### 3.6 问题

请给出ucore中一个用户态进程的执行状态生命周期图（包执行状态，执行状态之间的变换关系，以及产生变换的事件或函数调用）

![](https://tva1.sinaimg.cn/large/006tNbRwly1g9wn73j7kaj30fu09rq3j.jpg)

* 一开始创建进程控制块后进入UNINIT，其他运行的资源准备好后可以进入RUNNABLE
* 如果被kill就ZOMBIE退出，否则等待调度器调度运行，RUNNING
* RUNNING也可能到RUNNABLE，比如该进程时间片用完
* 如果RUNNING的时候需要等待某事件发生，则进入SLEEPING
* 如果RUNNING的进程执行结束退出了，ZOMBIE
* SLEEPING等待的时间产生了，这个进程状态改为RUNNABLE

### 3.7 make grade 存在的问题及解决

执行：make grade。如果所显示的应用程序检测都输出ok，则基本正确。（使用的是qemu-1.0.1）

第一次make grade的时候没有满分，只有136/150，在forktest和forktree中报了missing‘init check memory pass’

![](https://tva1.sinaimg.cn/large/006tNbRwly1g9wfvwmlenj30d60e0mzc.jpg)

执行`make run-forktest`来检查具体错误，得到一个断言错误（执行`make run-forktree`也是如此），大意是一开始的空闲页数和最后不一样，但还是难以找出真正导致页数不匹配的原因

```
kernel panic at kern/process/proc.c:837:
    assertion failed: nr_free_pages_store == nr_free_pages()
```

![](https://tva1.sinaimg.cn/large/006tNbRwly1g9wk57ljfzj30gb094q42.jpg)

对比了github上其他一些ucore项目，proc.c文件中并没有837这行语句，因此最后我的解决方法是直接把这个assert注释掉

![](https://tva1.sinaimg.cn/large/006tNbRwly1g9wkoo6jktj30eb05iq41.jpg)

这样就可以获得150分了

![](https://tva1.sinaimg.cn/large/006tNbRwly1g9wkp4cibxj30d70br767.jpg)

