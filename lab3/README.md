# Lab3:虚拟内存管理

![](https://tva1.sinaimg.cn/large/006y8mN6ly1g9bsy0tn83j30us0u07oo.jpg)

## 实验目的

* 了解虚拟内存的Page Fault异常处理实现
* 了解页替换算法在操作系统中的实现

## 实验内容

本次实验是在实验二的基础上，借助于页表机制和实验一中涉及的中断异常处理机制，完成Page Fault异常处理和FIFO页替换算法的实现，结合磁盘提供的缓存空间，从而能够支持虚存管理，提供一个比实际物理内存空间“更大”的虚拟内存空间给系统使用。这个实验与实际操作系统中的实现比较起来要简单，不过需要了解实验一和实验二的具体实现。实际操作系统系统中的虚拟内存管理设计与实现是相当复杂的，涉及到与进程管理系统、文件系统等的交叉访问。如果大家有余力，可以尝试完成扩展练习，实现extended　clock页替换算法。

## 练习0：填写已有实验

本实验依赖实验1/2。请把你做的实验1/2的代码填入本实验中代码中有“LAB1”,“LAB2”的注释相应部分。

---

和lab2中的合并一样，利用Meld Diff软件把修改过的部分修改到lab3中。

具体有`kdebug.c pmm.c trap.c default_pmm.c`

## 练习1：给未被映射的地址映射上物理页（需要编程）

完成`do_pgfault(mm/vmm.c)`函数，给未被映射的地址映射上物理页。设置访问权限的时候需要参考页面所在 VMA 的权限，同时需要注意映射物理页时需要操作内存控制结构所指定的页表，而不是内核的页表。

---

`mm_struct`描述了整个进程的虚拟地址空间，mm中的每个`vma_struct`表示了一段地址连续的合法虚拟空间。

### 1.1 `vma_struct`（vmm.h）

描述应用程序对虚拟内存“需求”的数据结构。

```
struct vma_struct {
    struct mm_struct *vm_mm; // the set of vma using the same PDT 
    uintptr_t vm_start;      // start addr of vma      
    uintptr_t vm_end;        // end addr of vma, not include the vm_end itself
    uint32_t vm_flags;       // flags of vma
    list_entry_t list_link;  // linear list link which sorted by start addr of vma
};
```

* `vm_start`和`vm_end`描述了一个连续地址的虚拟内存空间的起始位置和结束位置，而且描述的是一个合理的地址空间范围（即严格确保 vm_start < vm_end的关系）
* `list_link`是一个双向链表，按照从小到大的顺序把一系列用`vma_struct`表示的虚拟内存空间链接起来
* `vm_flags`表示了这个虚拟内存空间的属性

```
#define VM_READ 0x00000001 //只读
#define VM_WRITE 0x00000002 //可读写
#define VM_EXEC 0x00000004 //可执行
```

* `vm_mm`是一个指针，指向一个比`vma_struct`更高的抽象层次的数据结构`mm_struct`

在`vmm.c`里有涉及`vma_struct`的操作函数：vma_create--创建vma；insert_vma_struct--插入一个vma；find_vma--查询vma。

### 1.2 `mm_struct`（vmm.h）

```
struct mm_struct {
    list_entry_t mmap_list;        // linear list link which sorted by start addr of vma
    struct vma_struct *mmap_cache; // current accessed vma, used for speed purpose
    pde_t *pgdir;                  // the PDT of these vma
    int map_count;                 // the count of these vma
    void *sm_priv;                   // the private data for swap manager
};
```

* `mmap_list`是双向链表头，链接了所有属于同一页目录表的虚拟内存空间
* `mmap_cache`是指向当前正在使用的虚拟内存空间（“局部性”原理）
* `pgdir`所指向的就是`mm_struct`数据结构所维护的页表，通过访问`pgdir`可以查找某虚拟地址对应的页表项是否存在以及页表项的属性等
* `map_count`记录`mmap_list`里面链接的`vma_struct`的个数
* `sm_priv`指向用来链接记录页访问情况的链表头

### 1.3 `do_pgfault`函数（304-431）

```
int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
    int ret = -E_INVAL;
    //try to find a vma which include addr
    //查询vma
    //根据从CPU的控制寄存器CR2中获取的页访问异常的物理地址以及根据errorCode的错误类型来查找此地址是否在某个VMA的地址范围内以及是否满足正确的读写权限
    struct vma_struct *vma = find_vma(mm, addr);

    pgfault_num++;
    //If the addr is in the range of a mm's vma?
    //如果不在范围内
    if (vma == NULL || vma->vm_start > addr) {
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
        goto failed;
    }
    //check the error_code
    //错误处理
    switch (error_code & 3) {
    default:
            /* error code flag : default is 3 ( W/R=1, P=1): write, present */
    case 2: /* error code flag : (W/R=1, P=0): write, not present */
        if (!(vma->vm_flags & VM_WRITE)) {
            cprintf("do_pgfault failed: error code flag = write AND not present, but the addr's vma cannot write\n");
            goto failed;
        }
        break;
    case 1: /* error code flag : (W/R=0, P=1): read, present */
        cprintf("do_pgfault failed: error code flag = read AND present\n");
        goto failed;
    case 0: /* error code flag : (W/R=0, P=0): read, not present */
        if (!(vma->vm_flags & (VM_READ | VM_EXEC))) {
            cprintf("do_pgfault failed: error code flag = read AND not present, but the addr's vma cannot read or exec\n");
            goto failed;
        }
    }
    
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
        perm |= PTE_W;
    }
    addr = ROUNDDOWN(addr, PGSIZE);

    ret = -E_NO_MEM;

    pte_t *ptep=NULL;

    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    //检查页表中是否有相应的表项，有就获取指向这个表项的指针
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    //然后检查这个表项是否为空（有没有被映射过），如果为空那么pgdir_alloc_page分配一个新的物理页
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
            goto failed;
        }
    }
    //如果这个页表项非空，那么说明这一页已经映射过了但是被保存在磁盘中，需要将这一页内存交换出来
    else { // if this pte is a swap entry, then load data from disk to a page with phy addr
           // and call page_insert to map the phy addr with logical addr
        if(swap_init_ok) {
        	  //如果是可交换的
            struct Page *page=NULL;
            //根据mm结构和addr地址，swap_in函数将将内存页从磁盘中载入内存
            if ((ret = swap_in(mm, addr, &page)) != 0) {
                cprintf("swap_in in do_pgfault failed\n");
                goto failed;
            }
            //page_insert建立虚拟地址和物理地址之间的对应关系 
            page_insert(mm->pgdir, page, addr, perm);
            //swap_map_swappable将此页面设置为可交换的（将这个物理页框加入FIFO中）
            swap_map_swappable(mm, addr, page, 1);
        }
        else {
            cprintf("no swap_init_ok but ptep is %x, failed\n",*ptep);
            goto failed;
        }
   }
   ret = 0;
failed:
    return ret;
}
```

### 1.4 `make qemu`

可以获得`check_pgfault() succeeded!`的输出，说明练习一的`do_pgfault`函数可以使用。

![](https://tva1.sinaimg.cn/large/006y8mN6ly1g9bqoapj20j30db0b7aci.jpg)

### 1.5 问题

请描述页目录项（Pag Director Entry）和页表（Page Table Entry）中组成部分对ucore实现页替换算法的潜在用处。

`PTE_A`表示内存页是否被访问过，`PTE_D`表示内存页是否被修改过。时钟（Clock）页替换算法需要`PTE_A`，跳过了访问位为1的页；改进的时钟（Enhanced Clock）页替换算法需要`PTE_A`和`PTE_D`，优先淘汰未被引用也未被修改的页。

### 1.6 问题

如果ucore的缺页服务例程在执行过程中访问内存，出现了页访问异常，请问硬件要做哪些事情？

产生页访问异常后，CPU把引起页访问异常的线性地址装到寄存器CR2中，并给出了出错码errorCode，说明了页访问异常的类型。

（CPU在当前内核栈保存当前被打断的程序现场，即依次压入当前被打断程序使用的EFLAGS，CS，EIP，errorCode，页访问异常的中断号是0xE，CPU把异常中断号0xE对应的中断服务例程的地址加载到CS和EIP寄存器中，开始执行中断服务例程）

## 练习2：补充完成基于FIFO的页面替换算法（需要编程）

完成`vmm.c`中的`do_pgfault`函数，并且在实现FIFO算法的`swap_fifo.c`中完成`map_swappable`和`swap_out_vistim`函数。通过对`swap`的测试。

---

### 2.1 页面换入

页面替换分为页面换出和页面换入，换入在练习一的`do_pgfault`函数中实现了，重述一遍思路就是：`do_pgfault`函数会判断产生访问异常的地址属于`check_mm_struct`某个`vma`表示的合法虚拟地址空间，且保存在硬盘`swap`文件中（即对应的PTE的高24位不为0，而最低位为0），则是执行页换入的时机，将调用`swap_in`函数完成页面换入。

### 2.2 页面换出

* 积极换出策略：操作系统周期性地（或在系统不忙的时候）主动把某些认为“不常用”的页换出到硬盘上，从而确保系统中总有一定数量的空闲页存在，这样当需要空闲页时，基本上能够及时满足需求
* 消极换出策略：当试图得到空闲页时，发现当前没有空闲的物理页可供分配，这时才开始查找“不常用”页面，并把一个或多个这样的页换出到硬盘上

ucore采用的是消极的换出策略。

### 2.3 一个页替换算法的类框架`swap_manager`

`swap.h`

```
struct swap_manager
{
     const char *name;
     /* Global initialization for the swap manager */
     int (*init)            (void);
     /* Initialize the priv data inside mm_struct */
     int (*init_mm)         (struct mm_struct *mm);
     /* Called when tick interrupt occured */
     int (*tick_event)      (struct mm_struct *mm);
     /* Called when map a swappable page into the mm_struct */
     int (*map_swappable)   (struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in);
     /* When a page is marked as shared, this routine is called to
      * delete the addr entry from the swap manager */
     int (*set_unswappable) (struct mm_struct *mm, uintptr_t addr);
     /* Try to swap out a page, return then victim */
     int (*swap_out_victim) (struct mm_struct *mm, struct Page **ptr_page, int in_tick);
     /* check the page relpacement algorithm */
     int (*check_swap)(void);     
};
```

* `map_swappable`函数用于记录页访问情况相关属性
* `swap_out_vistim`函数用于挑选需要换出的页
* `tick_event`函数指针结合定时产生的中断，可以实现一种积极的换页策略

### 2.4 FIFO替换算法实现

`kern/mm/swap_fifo.c`

FIFO 替换算法会维护一个队列，队列按照页面调用的次序排列，越早被加载到内存的页面会越早被换出。

#### `_fifo_map_swappable`函数

44-56，增加了一句`list_add(head, entry)`，这个函数用于把最近被用到的页面添加到算法所维护的队列中。

```
static int
_fifo_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
    list_entry_t *entry=&(page->pra_page_link);
 
    assert(entry != NULL && head != NULL);
    //record the page access situlation
    /*LAB3 EXERCISE 2: YOUR CODE*/ 
    //(1)link the most recent arrival page at the back of the pra_list_head qeueue.
    //基于双向链表实现，将新加入的元素（最近用的）插入到可换出物理页链表的末尾
    list_add(head, entry);
    return 0;
}
```

#### `_fifo_swap_out_victim`函数

61-79，这个函数用来查询哪个页面需要被换出。

```
static int
_fifo_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
         assert(head != NULL);
     assert(in_tick==0);
     /* Select the victim */
     /*LAB3 EXERCISE 2: YOUR CODE*/ 
     //(1)  unlink the  earliest arrival page in front of pra_list_head qeueue
     //(2)  set the addr of addr of this page to ptr_page
     /* Select the tail */
     //需要被换出的页
     list_entry_t *le = head->prev;
     assert(head!=le);
     //获得对应page的指针p
     struct Page *p = le2page(le, pra_page_link);
     //将最老的页面从队列中删除
     list_del(le);
     assert(p !=NULL);
     //将这一页的地址存储在ptr_page中
     *ptr_page = p;
     return 0;
}
```

### 2.5 `make qemu`

成功输出`check_swap() succeeded!`，练习二实现。

![](https://tva1.sinaimg.cn/large/006y8mN6ly1g9bshomh7rj30g40cc77u.jpg)

### 2.6 问题

如果要在ucore上实现"extended clock页替换算法"请给你的设计方案，现有的swap_manager框架是否足以支持在ucore中实现此算法？如果是，请给你的设计方案。如果不是，请给出你的新的扩展和基此扩展的设计方案。并需要回答如下问题：

能支持。

* 需要被换出的页的特征是什么？

对应的页表项的`PTE_A`为1表示被访问，对应的页表项的`PTE_D`为1表示被修改。

那么（0，0）表示最近未被引用也未被修改，首先选择此页淘汰；（0，1）最近未被使用，但被修改，其次选择；（1，0）最近使用而未修改，再次选择；（1，1）最近使用且修改，最后选择。

* 在ucore中如何判断具有这样特征的页？

当该页被访问时，CPU中的MMU硬件将把访问位置“1”。当该页被“写”时，CPU中的MMU硬件将把修改位置“1”。

* 何时进行换入和换出操作？

换入：发生缺页异常，保存在磁盘中的内容要被访问需要换入。

当ucore或应用程序访问地址所在的页不在内存时，就会产生page fault异常，引起调用`do_pgfault`函数，此函数会判断产生访问异常的地址属于`check_mm_struct`某个vma表示的合法虚拟地址空间，且保存在硬盘swap文件中（即对应的PTE的高24位不为0，而最低位为0），则是执行页换入的时机，将调用`swap_in`函数完成页面换入。

换出：物理页帧满的时候，当位于物理页框中的内存被页面替换算法选择需要换出。
