# Lab2:物理内存管理

在学习中发现了一个非常有用的网站：<https://wiki.osdev.org>，可以找到各种关于操作系统的知识。

## 实验内容

本次实验包含三个部分。首先了解如何发现系统中的物理内存；然后了解如何建立对物理内存的初步管理，即了解连续物理内存管理；最后了解页表相关的操作，即如何建立页表来实现虚拟内存到物理内存之间的映射，对段页式内存管理机制有一个比较全面的了解。本实验里面实现的内存管理还是非常基本的，并没有涉及到对实际机器的优化，比如针对 cache 的优化等。如果大家有余力，尝试完成扩展练习。

## 练习0：填写已有实验

本实验依赖实验1。请把你做的实验1的代码填入本实验中代码中有“LAB1”的注释相应部分。提示：可采用`diff`和`patch`工具进行半自动的合并（merge），也可用一些图形化的比较`/merge`工具来手动合并，比如`meld`，`eclipse`中的`diff/merge`工具，`understand`中的`diff/merge`工具等。

---

利用`meld diff`实现lab1和lab2的合并，新建一个比较

![](https://tva1.sinaimg.cn/large/006y8mN6ly1g8k22do6ttj30h9084q42.jpg)

选择lab1中修改过的如下三个文件比较，然后修改lab2中对应的内容

```
kern/debug/kdebug.c
kern/init/init.c
kern/trap/trap.c
```

![](https://tva1.sinaimg.cn/large/006y8mN6ly1g8k259fq7mj30lk0enmzt.jpg)

## 练习1：实现 first-fit 连续物理内存分配算法（需要编程）

在实现`first fit`内存分配算法的回收函数时，要考虑地址连续的空闲块之间的合并操作。提示:在建立空闲页块链表时，需要按照空闲页块起始地址来排序，形成一个有序的链表。可能会修改`default_pmm.c`中的`default_init`，`default_init_memmap`，`default_alloc_pages`， `default_free_pages`等相关函数。请仔细查看和理解`default_pmm.c`中的注释。

---

### 1.1 数据结构

kern/mm/memlayout.h

#### 99-104，物理页Page

```
struct Page {
    int ref;                        // page frame's reference counter
    uint32_t flags;                 // array of flags that describe the status of the page frame
    unsigned int property;          // the num of free block, used in first fit pm manager
    list_entry_t page_link;         // free list link
};
```

* `ref`是映射此物理页的虚拟页个数
* `flags`是物理页的状态标记
* `property`记录在此块内的空闲页的个数
* `page_link`链接比它地址小和大的其他连续内存空闲块

用到后两个成员变量的都是这个连续内存空闲块地址最小的一页（Head Page）。

根据接下去几行对flag的描述可知：bit 0表示此页是否被保留（reserved），如果是被保留的页，则bit 0会设置为1，且不能放到空闲页链表中，即这样的页不是空闲页，不能动态分配与释放。bit 1表示此页是否是free的，如果设置为1，表示这页是free的，可以被分配；如果设置为0，表示这页已经被分配出去了，不能被再二次分配。

```
/* Flags describing the status of a page frame */
#define PG_reserved                 0       // if this bit=1: the Page is reserved for kernel, cannot be used in alloc/free_pages; otherwise, this bit=0 
#define PG_property                 1       // if this bit=1: the Page is the head page of a free memory block(contains some continuous_addrress pages), and can be used in alloc_pages; if this bit=0: if the Page is the the head page of a free memory block, then this Page and the memory block is alloced. Or this Page isn't the head page.
```

#### 122-125，`free_area_t`数据结构

```
typedef struct {
    list_entry_t free_list;         // the list header
    unsigned int nr_free;           // # of free pages in this free list
} free_area_t;
```

包含了一个`list_entry`结构的双向链表指针和记录当前空闲页的个数的无符号整型变量`nr_free`，其中的链表指针指向了空闲的物理页。

### 1.2 `default_pmm.c`

#### `default_init`函数

62-66，无需修改。

```
static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
}
```

这个函数用于初始化`free_list`并将`nr_free`置0

#### `default_init_memmap`函数

68-81，无需修改。

```
static void
default_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
    SetPageProperty(base);
    nr_free += n;
    list_add(&free_list, &(base->page_link));
}
```

对应的描述在24-33，这个函数的功能是根据每个物理页帧的情况来建立空闲页链表（按照地址高低），循环把空闲物理页对应的`Page`结构中的`flags`和引用计数`ref`清零，`PageReserved(p)`用来判断该页是否为保留页，循环结束后把`Head Page`的property设为n，来记录在此块内的空闲页的个数，最后`list_add`用于把这个连续内存空闲块加到`free_area.free_list`指向的双向列表中，为将来的空闲页管理做好初始化准备工作。

#### `default_alloc_pages`函数

`first-fit`是最先匹配算法，思路是：从空闲块链表头开始找，找到一个满足大小的空闲块就分配出来。

* 优点：更多的使用低地址部分的空闲块，高地址部分有大空闲块被保留。
* 缺点：低地址部分不断被划分，留下很多小空闲块，使查询变慢。

83-114，需要补充。

```
static struct Page *
default_alloc_pages(size_t n) {
    assert(n > 0);
    if (n > nr_free) {
        return NULL;
    }
    list_entry_t *le, *len;
    le = &free_list;

    while((le=list_next(le)) != &free_list) {
      struct Page *p = le2page(le, page_link);
      if(p->property >= n){
        int i;
        for(i=0;i<n;i++){
          len = list_next(le);
          struct Page *pp = le2page(le, page_link);
          SetPageReserved(pp);
          ClearPageProperty(pp);
          list_del(le);
          le = len;
        }
        if(p->property>n){
          (le2page(le,page_link))->property = p->property - n;
        }
        ClearPageProperty(p);
        SetPageReserved(p);
        nr_free -= n;
        return p;
      }
    }
    return NULL;
}
```

对应的描述在34-50，这个函数功能是根据`first-fit`从空闲块链表表头开始查找找到第一块大小不小于n的块，然后分配出n个页。

首先如果所有空闲块的空闲页总数都没有n个，那么无法分配，直接return。通过`list_next`遍历空闲块链表。通过`le2page`宏（定义在`memlayout.h`中）可以获得对应的指向Page的指针p。然后通过`p->property`得到此空闲块的大小，如果`≥n`，就开始重新组织空闲块。循环把这个空闲块中的每一个页初始化，`SetPageReserved`把对应的`Page`结构中的`flags`标志设置为`PG_reserved` ，表示这些页已经被使用了，将来不能被用于分配。如果选中的块大于n，那么只取n个页，就需要修改剩下的块对应的`property`。最后在空闲块链表中删除掉分配出去的块。

### 1.5 `default_free_pages`函数

116-160，需要补充。

```
static void
default_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    assert(PageReserved(base));

    list_entry_t *le = &free_list;
    struct Page * p;
    while((le=list_next(le)) != &free_list) {
      p = le2page(le, page_link);
      if(p>base){
        break;
      }
    }
    //list_add_before(le, base->page_link);
    for(p=base;p<base+n;p++){
      list_add_before(le, &(p->page_link));
    }
    base->flags = 0;
    set_page_ref(base, 0);
    ClearPageProperty(base);
    SetPageProperty(base);
    base->property = n;
    
    p = le2page(le,page_link) ;
    if( base+n == p ){
      base->property += p->property;
      p->property = 0;
    }
    le = list_prev(&(base->page_link));
    p = le2page(le, page_link);
    if(le!=&free_list && p==base-1){
      while(le!=&free_list){
        if(p->property){
          p->property += base->property;
          base->property = 0;
          break;
        }
        le = list_prev(le);
        p = le2page(le,page_link);
      }
    }

    nr_free += n;
    return ;
}
```

对应的描述在52-55，`default_free_pages`函数的实现是`default_alloc_pages`的逆过程，将释放掉的空闲块放回空闲块链表中，如果按照地址从小到大插入后和旁边的空闲块地址连续，就需要考虑空闲块的合并问题。

首先检查需要释放的块是否是被分配的，然后遍历按地址从小到大的顺序寻找空闲块要插入链表中的位置，循环将要被释放块的所有页插入空闲链表中，然后修改页的各个属性。`base+n == p`用来判断如果和下一个（高位方向）内存块的地址连续，那么就向高位地址合并，如果不是的话把le指针指向前一个内存块，`le!=&free_list && p==base-1`判断新加入的块是否能和低位的内存块合并，最后更新空闲页总数`nr_free`。

### 1.3 first-fit的改进&其他内存分配算法

#### first-fit优化

可以从数据结构的角度考虑优化`first-fit`，利用线段树可以使`alloc`和`free`的复杂度由O(n)变为O(logn)。

#### next-fit

`next-fit`是循环首次匹配算法，思路是：不从链表头开始找，找到哪里下次就从那开始。

* 优点：内存中的空闲块分布更均匀，查询效率稳定
* 缺点：没有保留大空闲块
* 适用情况：不需要大空闲块的情况

#### best-fit

`best-fit`是最佳匹配算法，思路是：所有空闲块从小到大排序，这样每次分配出去的内存块都是当前能达到的最优的。

* 优点：每次都最优
* 缺点：留下许多小空闲块，排序耗时
* 适用情况：需要的大都为小空闲块的情况

#### worse-fit

`worse-fit`是最差匹配算法，思路是：所有空闲块从大到小排列。

* 优点：不容易留下许多小空闲块
* 缺点：没有保留大空闲块
* 适用情况：不需要大空闲块的情况

## 练习2：实现寻找虚拟地址对应的页表项（需要编程）

通过设置页表和对应的页表项，可建立虚拟内存地址和物理内存地址的对应关系。其中的`get_pte`函数是设置页表项环节中的一个重要步骤。此函数找到一个虚地址对应的二级页表项的内核虚地址，如果此二级页表项不存在，则分配一个包含此项的二级页表。本练习需要补全`get_pte`函数`kern/mm/pmm.c`，实现其功能。请仔细查看和理解`get_pte`函数中的注释。`get_pte`函数的调用关系图如下所示：(`get_pte`函数的调用关系图)

![](https://tva1.sinaimg.cn/large/006y8mN6ly1g8l6vuc5b5j30aq050wew.jpg)

请在实验报告中简要说明你的设计实现过程。请回答如下问题：

* 请描述页目录项`（Pag Director Entry）`和页表`（Page Table Entry）`中每个组成部分的含义和以及对`ucore`而言的潜在用处。
* 如果`ucore`执行过程中访问内存，出现了页访问异常，请问硬件要做哪些事情？

---

### 2.1 `get_pte`调用关系图

![](https://tva1.sinaimg.cn/large/006y8mN6ly1g8mdmr39d3j30cx07swf1.jpg)

`get_pte`给定一个虚拟地址，找出这个虚拟地址在二级页表中对应的项，如果此二级页表项不存在，则分配一个包含此项的二级页表。

`pte_t  *get_pte (pde_t *pgdir,  uintptr_t la, bool  create)`涉及到下面三个类型。

`pde_t`：一级页表的表项。而`pgdir`是一级页表本身，给出页表起始地址。
`pte_t`：二级页表的表项。
`uintptr_t`：线性地址，由于段式管理只做直接映射，所以它也是逻辑地址。

目前只有`boot_pgdir`一个页表，引入进程的概念之后每个进程都会有自己的页表。

### 2.2 `get_pte`函数

`PDX(la)`通过虚拟地址la得到一级页表项的入口地址。

`KADDR(pa)`由物理地址得到虚拟地址。

通过`alloc_page`函数获得一个空闲物理页作为页目录表（Page Directory Table，PDT），页目录表占4KB空间。宏定义在`kern/mm/pmm.h`中：

```
struct Page *alloc_pages(size_t n);
#define alloc_page() alloc_pages(1)
```

`alloc_page()`分配的页的地址并不是真正的页分配的地址，而是`Page`这个结构体所在的地址，需要通过`page2pa()`将`Page`结构体的地址转换为物理页地址的线性地址

PTE 页表

```
填写页目录项的内容为：页目录项内容 = (页表起始物理地址 &0x0FFF) | PTE_U | PTE_W | PTE_P
PTE_U：位3，表示用户态的软件可以读取对应地址的物理内存页内容
PTE_W：位2，表示物理内存页内容可写
PTE_P：位1，表示物理内存页存在
```

`kern/mm/pmm.c`

```
//get_pte - get pte and return the kernel virtual address of this pte for la
//        - if the PT contians this pte didn't exist, alloc a page for PT
// parameter:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
    pde_t *pdep = &pgdir[PDX(la)];
    if (!(*pdep & PTE_P)) {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
        *pdep = pa | PTE_U | PTE_W | PTE_P;
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
}
```

首先获取一级页表项，`PDX(la)`可以得到一级页表项对应的入口地址（`kern/mm/mmu.h`）。

如果`!(*pdep & PTE_P)`表示物理页不存在，那么需要根据`create`参数的值来处理是否创建新的二级页表。如果`create`参数为0，则`get_pte`返回`NULL`；如果`create`参数不为0，则`get_pte`需要申请一个新的物理页（通过`alloc_page`来实现）。

`set_page_ref`这个页被页表引用，引用次数加一。然后通过`page2pa`得到`page`的物理地址。`memset`把新申请的`PGSIZE`个页全部设定为零，因为这个页所代表的虚拟地址都没有被映射。设置`PTE_U 0x001| PTE_W 0x002| PTE_P 0x004`三个控制位，（对应的宏定义在`mmu.h`中），分别代表：物理页内存存在/物理内存页内容可写/用户态的软件可以读取对应地址的物理内存页内容。

最后返回页表地址。

### 2.3 请描述页目录项PDE和页表PTE中每个组成部分的含义和以及对`ucore`而言的潜在用处

查看`mmu.h`中相关的宏定义：

对应物理页面是否存在/对应物理页面是否可写/对应物理页面用户态是否可以访问/对应物理页面在写入时是否写透(可以直写回内存)/对应物理页面是否能被放入高速缓存/对应物理页面是否被访问/对应物理页面是否被写入/对应物理页面的页面大小/必须为零的部分/用户可自定义的部分。

```
/* page table/directory entry flags */
#define PTE_P           0x001                   // Present
#define PTE_W           0x002                   // Writeable
#define PTE_U           0x004                   // User
#define PTE_PWT         0x008                   // Write-Through
#define PTE_PCD         0x010                   // Cache-Disable
#define PTE_A           0x020                   // Accessed
#define PTE_D           0x040                   // Dirty
#define PTE_PS          0x080                   // Page Size
#define PTE_MBZ         0x180                   // Bits must be zero
#define PTE_AVAIL       0xE00                   // Available for software use
```

PDE高20位是页表地址，剩下的12位都为标志位，其中PDE的0，1，2，...，8，9-11位分别对应`PTE_P,PTE_W,PTE_U,PTE_PWT,PTE_PCD,PTE_A,PTE_MBZ=0,PTE_PS,PTE_AVAIL`。

在<https://wiki.osdev.org/Paging>可以得到PDE的组成示意图：

![](https://tva1.sinaimg.cn/large/006y8mN6ly1g8mju99f1dj30c0073dgf.jpg)

PTE高20位是物理页地址，PTE的0，1，2，...，8，9-11位分别对应`PTE_P,PTE_W,PTE_U,PTE_PWT,PTE_PCD,PTE_A,PTE_D,PTE_MBZ=0,Global,PTE_AVAIL`。

![](https://tva1.sinaimg.cn/large/006y8mN6ly1g8mjvxzceoj30c0074mxo.jpg)

### 2.4 如果`ucore`执行过程中访问内存，出现了页访问异常，请问硬件要做哪些事情？

1. 把引起页访问异常的线性地址放到CR2寄存器中
2. CPU将错误代码压入堆栈，因为错误代码必须由异常处理程序进行分析，以确定如何处理异常
3. 中断服务例程会调用页访问异常处理函数do_pgfault进行具体处理

## 练习3：释放某虚地址所在的页并取消对应二级页表项的映射（需要编程）

当释放一个包含某虚地址的物理内存页时，需要让对应此物理内存页的管理数据结构Page做相关的清除处理，使得此物理内存页成为空闲；另外还需把表示虚地址与物理地址对应关系的二级页表项清除。请仔细查看和理解page_remove_pte函数中的注释。为此，需要补全在 kern/mm/pmm.c中的page_remove_pte函数。page_remove_pte函数的调用关系图如下所示：

![](https://tva1.sinaimg.cn/large/006y8mN6ly1g8mkb63r1aj309o023q34.jpg)

（page_remove_pte函数的调用关系图）

请在实验报告中简要说明你的设计实现过程。请回答如下问题：

* 数据结构Page的全局变量（其实是一个数组）的每一项与页表中的页目录项和页表项有无对应关系？如果有，其对应关系是啥？
* 如果希望虚拟地址与物理地址相等，则需要如何修改lab2，完成此事？ 鼓励通过编程来具体完成这个问题

---

### 3.1 `page_remove_pte`函数

`page_remove_pte`函数用于释放某虚地址所在的页并取消对应二级页表项的映射。

`pmm.c`413-447

```
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
    if (*ptep & PTE_P) {
        struct Page *page = pte2page(*ptep);
        if (page_ref_dec(page) == 0) {
            free_page(page);
        }
        *ptep = 0;
        tlb_invalidate(pgdir, la);
    }
}
```

首先判断页表中该表项是否存在，`pte2page`获得相应的`page`，如果引用次数减一后为0，（即该页表只被引用了一次），就释放改物理页，否则不能释放，`PTE置零`，刷新`TLB`。

`make qemu`结果如图：物理内存分配器初始化成功，并且页表建立成功

![](https://tva1.sinaimg.cn/large/006y8mN6ly1g8n5b0ig43j30k10buwf4.jpg)

### 3.2 数据结构Page的全局变量（其实是一个数组）的每一项与页表中的页目录项和页表项有无对应关系？如果有，其对应关系是啥？

数组中每一个Page对应物理内存中的一个页，由`mmu.h`190-201的描述可知线性地址的高20位是页目录项索引PDX与页表项索引PTX的组合PPN。所以高20位可以对应page中的一项。

```
// A linear address 'la' has a three-part structure as follows:
//
// +--------10------+-------10-------+---------12----------+
// | Page Directory |   Page Table   | Offset within Page  |
// |      Index     |     Index      |                     |
// +----------------+----------------+---------------------+
//  \--- PDX(la) --/ \--- PTX(la) --/ \---- PGOFF(la) ----/
//  \----------- PPN(la) -----------/
//
// The PDX, PTX, PGOFF, and PPN macros decompose linear addresses as shown.
// To construct a linear address la from PDX(la), PTX(la), and PGOFF(la),
// use PGADDR(PDX(la), PTX(la), PGOFF(la)).
```


### 3.3 如果希望虚拟地址与物理地址相等，则需要如何修改lab2，完成此事？ 鼓励通过编程来具体完成这个问题

#### 系统执行中地址映射的四个阶段

在bootloader阶段：

```
virt addr = linear addr = phy addr
```

从`kern_entry`函数开始（完成新的段映射关系）后到执行`enable_page`函数（页映射机制启动）之前：

```
virt addr - 0xC0000000 = linear addr = phy addr
```

从`enable_page`函数开始，到执行`gdt_init`函数之前：

```
virt addr - 0xC0000000 = linear addr  = phy addr + 0xC0000000 # 物理地址在0~4MB之外的三者映射关系
virt addr - 0xC0000000 = linear addr  = phy addr # 物理地址在0~4MB之内的三者映射关系
```

从`gdt_init`函数开始，第三次更新了段映射，形成了新的段页式映射机制，并且取消了临时映射关系，得到最终的段页式映射关系：：

```
virt addr = linear addr = phy addr + 0xC0000000
```

#### 建立段页式管理中需要考虑的关键问题

* 如何在建立页表的过程中维护全局段描述符表（GDT）和页表的关系，确保ucore能够在各个时间段上都能正常寻址？

建立页表完成后需要更新全局GDT，才真正开启了分页机制。

* 对于哪些物理内存空间需要建立页映射关系？

![](https://tva1.sinaimg.cn/large/006y8mN6ly1g8n9xxe8l1j30790ahjs6.jpg)
（计算机系统的内存布局）

BBS段结束处以上的物理内存空间需要建立页映射关系。

* 具体的页映射关系是什么？

![](https://tva1.sinaimg.cn/large/006y8mN6ly1g8na9tsohsj30cl027t8t.jpg)

`ucore`的页式管理通过一个二级的页表实现。一级页表的起始物理地址存放在`cr3`寄存器中，这个地址必须是一个页对齐的地址，也就是低12位必须为 0。

![](https://tva1.sinaimg.cn/large/006y8mN6ly1g8na0y3iv7j30dt07hjs1.jpg)
(分页机制管理)

* 页目录表的起始地址设置在哪里？

查看`memlayout.h`60-66:

```
/* *
 * Virtual page table. Entry PDX[VPT] in the PD (Page Directory) contains
 * a pointer to the page directory itself, thereby turning the PD into a page
 * table, which maps all the PTEs (Page Table Entry) containing the page mappings
 * for the entire virtual address space into that 4 Meg region starting at VPT.
 * */
#define VPT                 0xFAC00000
```

起始地址为0xFAC00000。

* 页表的起始地址设置在哪里，需要多大空间？（不确定）

整个页目录表和页表所占空间大小取决与二级页表要管理和映射的物理页数。
假定当前物理内存0~4MB，每物理页大小为4KB，则有1024个物理页，意味着有1个页目录项和1024个页表项需要设置。一个页目录项(PDE)和一个页表项(PTE)占4B。1个页目录项也需要一个完整的页目录表（占4KB）。而1024个页表项需要4KB的空间。所以对4MB物理页建立一一映射的4MB虚拟页，需要2个物理页，即8KB的空间来形成二级页表。

* 如何设置页目录表项的内容？

```
boot_pgdir[PDX(la)] = PADDR (页表物理地址) | PTE_P | PTE_W
```

* 如何设置页表项的内容？

如`get_pte`函数中的方法设置。

```
pde_t *pdep = &pgdir[PDX(la)];
*pdep = pa | PTE_U | PTE_W | PTE_P;
```

#### 实现

如果要使虚拟地址与物理地址相等。

回顾上面的系统执行中地址映射的四个阶段，第一阶段虚拟地址等于物理地址。

第二阶段，物理地址由虚拟地址加上一个基地址得到，把基地址修改为0。

`kern/mm/memlayout.h`56

```
#define KERNBASE            0xC0000000
修改为：
#define KERNBASE            0x00000000
```

第三阶段`boot_pgdir[0] = boot_pgdir[PDX(KERNBASE)]`用来建立物理地址在0~4MB之内的三个地址间的临时映射关系，第四阶段从`gdt_init`函数开始，第三次更新了段映射，形成了新的段页式映射机制。

`pmm.c`330-331

因此注释掉331行，331行原先功能为取消了0~4MB之内的临时映射关系。

```
//disable the map of virtual_addr 0~4M
//boot_pgdir[0] = 0;
```

这样虚拟地址就都等于物理地址了。

