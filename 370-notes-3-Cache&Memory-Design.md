# Note Part 3: Cache and Memory Design

## Lec 16 - Cache

By complexity 左右两边是一样的. 但是考虑到实际的 cache，左边的代码远比右边快

<img src="note-assets-370/Screenshot 2024-11-03 at 21.42.12.png" alt="Screenshot 2024-11-03 at 21.42.12" style="zoom: 67%;" />



目前我们 discuees 了两种 hold data 的 structures: reg file; memory

Reg file 和 memory 都是 array of words.

其中每个 word 都是一堆 32 个 bits(for LC2K, 64 for ARM) 组成. 

所以我们储存数据的最底层结构是：我们如何储存一个 bit?

根据之前学的，一个 bit 可以由一个 flip-flop 来表示

但是这显然不 practical 因为一个 flip-flop 里面的 transistor 太多了，而我们需要 2^18/32/64 个这样的单位.



### Options to represent a bit

reg files，数量极少（就几十个 regs）

由最贵最大的 D flip-flops 组成. 

其他的 memory: 有下面几个由快到慢的 options



#### Option 1: SRAM(Static Ramdom Access Memory)

用 SRAM 来表示的一个 bit 由 6 个 transistors 组成

它的优点是很快：1 ns read time，只慢于 flip flop.

虽然显著比 D flip-flop 小，但它仍然很大. 我们可以在一个 chip 上放 ~MB 个这样的东西；但是 ~GB 级别的 memory array 不可以用它表示

当然它需要 constant power 来 keep data.

<img src="note-assets-370/Screenshot 2024-11-03 at 21.51.07.png" alt="Screenshot 2024-11-03 at 21.51.07"  />

主要用于：caches.



#### Option 2: DARM(Dynamic Ramdom Access Memory)

用 DRAM 来表示的一个 bit 由 1 个 transistor 和 1 个 capacitor (电容器) 组成

transistor 负责电荷进出，capacitor 负责储存电荷.

capacitor 的电荷会随着时间逐渐流失，因而需要周期性刷新来保持电荷. 所以它也是需要通电才能储存，断电后数据会流失.

<img src="note-assets-370/Screenshot 2024-11-03 at 21.54.42.png" alt="Screenshot 2024-11-03 at 21.54.42" style="zoom:80%;" />

慢于 SRAM. 50 ns read time (因为它使用了 capcacitor，refill 需要时间. 不像 SRAM 是纯粹靠 transistor 来维持 0/1 的. )



比 SRAM 更便宜. (transistor 是耗费大头，这里只有一个 transistor)

可以在 current machine 上放 ~16-64 GB 个.

对于 32 bit systems 是好的选择，但是对于 64 bit systems 则不是.

主要用于：main memory 以及显存等



#### Option 3: Disks

Disks，古早的是机械硬盘，使用 megnetic charges 来储存数据. 它的储存介质是通过 spinning disks 来完成.

##### HDD(Hard Disk Drive)

disk 的盘片表面有磁性材料，通过磁性的改变来表示 0/1

读写磁头由机械臂控制（所以叫机械硬盘），通过移动它到盘片的不同位置来进行数据读写.

disk 上有spinning 的电机，带动磁盘高速旋转，使得磁头可以快速定位到需要的数据上（这个"快速"相对于 DRAM 是非常非常非常非常慢的

速度：3000000 ns access time. 慢.



##### SSD(Solid State Drive)

固态硬盘. 无机械部件. 通过 NAND 闪存来存储数据.

机制比较复杂。使用浮动栅极晶体管，能够锁定电荷，用电荷是否存在表示 0/1.

寿命也有限。所以硬盘老了得换。

现在应该没人用机械硬盘了. SSD 的储存范围更大，可以 scale up to terabytes，单个 MB 的价格只需要 0.0001 刀.

SSD 的速度比 HDD 快很多. 但是仍然远远慢于 DRAM.









### Memory Hierarchy

我们想要一个尽量 fast (Ideally run at processor clock speed) 且 less expensive 的 memory system.

DRAM 和 Disks 太慢，SRAM 太贵/大.

所以我们需要 memory hierarchy.

Idea: 对于 main memory，介于大小的需求(GB级别)，我们只能使用 DRAM.  但是，**我们实际上在一段时间内只需要 access a small amount of data** 而不是整个 memory.

所以：我们可以用 a small array of SRAM to hold data we need now. 这个 small array of SRAM 就叫做 cache (缓存).



所以最后我们的 hirarchy 是：

regfiles: D flip-flop

~Kb 的 cache, 由 SRAM 组成

~Gb 的 memory, 由 DRAM 组成

Everything else, stored on disk (现在有 Virtual memory，允许计算机使用 disk 作为扩展内存，以在 RAM 不足时提供更大的可用内存空间。VM 的主要目的是让程序认为自己有足够的连续内存，即使实际的物理内存可能不够，从而增强系统的多任务处理能力和程序运行的稳定性。)

<img src="note-assets-370/Screenshot 2024-11-03 at 23.05.19.png" alt="Screenshot 2024-11-03 at 23.05.19" style="zoom:50%;" />



一个 analogy: memory, cache, reg

<img src="note-assets-370/Screenshot 2024-11-03 at 23.06.59.png" alt="Screenshot 2024-11-03 at 23.06.59" style="zoom: 67%;" />





### Function of the Cache

我们使用 cache 来把 memory 中常用的数据放进其中，这部分数据之后在 cache 里和 pipeline processor 之间进行交互，而不是在 memory 里和 pipeline processor 之间进行交互，大大提高了速度。

实际上 Cache 也分为 L1, L2, L3 级别，和 cpu core 距离由近到远，大小由小到大，速度由快到慢。越常用的数据和指令放在越靠前的 cache.

<img src="note-assets-370/Screenshot 2024-11-03 at 23.08.05.png" alt="Screenshot 2024-11-03 at 23.08.05" style="zoom:67%;" />







Cache holds the data we think is most likely to be referenced.

我们首先考虑 LC2K 中最简单的 cache: 只用于 load instructions 的 cache: 

这个 cache 是一个 word addressable address space. 

当我们 lw 时，memory 会 return 一个 data。我们

1. 把 memory return 的 data 存进 cache，
2. 同时 together with 一个 tag: 储存这个 data 在 memory 中的地址，以便下次查找
3. 同时 together with 一个 one bit status: 表示这个data 是否 valid.

由这几个东西构成一个 word. 作为 cache 中一个位置上的 word.



<img src="note-assets-370/Screenshot 2024-11-04 at 01.28.29.png" alt="Screenshot 2024-11-04 at 01.28.29"  />





### Locality

我们在 cache 中储存的时候需要考虑这些问题

1. cache 是否足够大，以每次遇到需要储存的东西都能够有空储存？
2. 如何选择 what to keep in cache?

我们有一个 locality 的原则，分为 temporal locality 和 spatial locality



#### temporal locality

temporal locality 即：如果一个 given memory location is referenced now, it will probably be used again in the near future.

（显然的，因为我们写代码肯定会用一个 variable multiple times）

并且由此可 corollary：如果我们很长时间不用一个 variable 了，说明它很可能任务完成了（之后不会再出现



因而我们的 cache ：

1. 对于 just accessed 的 data 应该 place into cache
2. 当我们必须要 evict something 的时候，我们 evict whatever data was **Least Recently Used(LRU)**



Example: 我们采用一个简化的模型. 这里 Cache 的容量一共就 2 lines，每个 line 由 1 bit status,  4 bit tag, 8 bit data 组成

每当 lw 时，我们首先遍历 cache，找不到的话：

1. 记录一个 Cache miss；
2. 在 memory 找，并且把找到的数据的 位置作为 tag，内容作为 data 放进 Cache 的 LRU 的地方，Status 设置为 1
3. 从 Cache 中数据进入 reg.



<img src="note-assets-370/Screenshot 2024-11-04 at 11.27.21.png" alt="Screenshot 2024-11-04 at 11.27.21" style="zoom:67%;" />

<img src="note-assets-370/Screenshot 2024-11-04 at 11.28.24.png" alt="Screenshot 2024-11-04 at 11.28.24" style="zoom: 67%;" />

<img src="note-assets-370/Screenshot 2024-11-04 at 11.30.39.png" alt="Screenshot 2024-11-04 at 11.30.39" style="zoom:67%;" />



遍历这块 Cache，找到的话：

1. 记录一个 Cache hit
2. 直接从 Cache 里把数据导进 reg

<img src="note-assets-370/Screenshot 2024-11-04 at 11.32.03.png" alt="Screenshot 2024-11-04 at 11.32.03" style="zoom:67%;" />





#### 如果 Cache filled

当 Cache 被填满的时候，我们如果遇到一个新的 Cache miss，意味着又要放数据进来。我们只能 kick out 一个相对 LRU 的数据

<img src="note-assets-370/Screenshot 2024-11-04 at 11.34.26.png" alt="Screenshot 2024-11-04 at 11.34.26" style="zoom:67%;" />

这一块的逻辑应该是：这里的模型过于简单，实际上 status bit 会不止一个，最后从头到尾遍历比较 status bits 来找出最 LRU 的数据

这一部分在 next lecture



### Hit/Miss rate

HIt 指 data for a memory access 在 cache 中被找到

Miss 指 data for a memory access 在 cache 中没被找到

我们想要一个比较高的 Hit/Miss rate 



Ex: 

假设 Cache 的 access time 是 1 cycle

Main Memory 的 access time 是 100 cycles.

如果我们有 90% 的 Hit/Miss rate，那么 average memory latency 是多少？

$1*0.9 + (1+100)*0.1 = 11.0$



使用公式：

average latency = cache latency  + memory latency * miss rate

$1 + 100*0.1 = 11.0$



因而要优化 average latency，我们可以选择

1. 优化 memory latency
2. 优化 cache latency
3. 降低 miss rate













## Lec 17 - Improving Caches     





