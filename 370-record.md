## Lab 1

### `<<`, `>>` 运算符

`>>` 表示全体 bit 向右移一位，最高位自动补上 0/1. 

关于最高位的处理：如果是 signed (二补码)，那么最高位补上 0 还是 1 取决于最高位是 0 还是 1. 最高位如果是 0 就补上0（让正数变小）；最高位如果是 1 就补上 1（让负数变大）.

**note: 往绝对值变小的方向变化！**

如果是 unsigned 则最高位自动补 0. 

ex: signed `1000 >> 2 ` = `1110`. unsigned 则 `1000 >> 2` = `0010`

至于 `<<` 左移，不管 signed 还是 unsigned 都是在右边自动补 0. （**note: 往绝对值变大的方向上变化.**）



所以：

```c
// 一个 int 中 bit 1 的数量
int numHighBits(int input){
    int count = 0;
    while (input != 0) {
        count += input & 1;
        input >>= 1;	// 正数则正常,负数则死循环
    }
    return count;
}
```

这个程序是错的. 因为当取负数时，这个 `input >>= 1` 会让 input 永远停在 -1. 它会变成 1,11,111,1111,11111,111111,...

```c
// 只能这么写:
int numHighBits(int input){
    int count = 0;
    for (int i = 0; i < sizeof(input)*8; ++i){
        if(input & 1) {
          	++count;
        }
        mask = mask << 1;
    }
    return count;
}
```

### `sizeof`

`sizeof(n)` 表示这个 `n` 的 **datatype 占的 bytes 数**（而不是 `n` 这个值本身占用的字节数）

比如 `n` 为 int，那么 `sizeof(n)` = 32 或 64，取决于语言. 

所以拿 `sizeof(n)*8` 就是这个 datatype 占的 bytes 数.

```c
int numHighBits(int input){
    int count = 0;
    for (int i = 0; i < sizeof(input)*8; ++i){
        if(input & 1) {
          	++count;
        }
        mask = mask << 1;
    }
    return count;
}
```



## p1a

一个巨大的惨痛经验：一定不要吝惜时间写 test files，写 test files 的时间都是微不足道并且值得的。。。。自己的 test file 就是可以检验程序写的对不对

Specifically: p1a 花了大量时间的主要理由就是：一直没找到读 int 的那个问题，，，一定要 `& 0xFFFF` ！！！因为系统的 int 不是 16 位的，而我们这里 16 位，碰到二补码前面全是 F 就老实了。一定要注意每个数字的格式！！





## Lec 4 - ARM (LEG subset)

### ARM logical instructions

（bitwise）

1. ADD, ORR(inclusive), EOR(exclusive) 都是 x1 = x2 + x3

2. ADDI, ORRI, EORI 是对应的 I-instructions (第三个 field 是常数): x1 = x2 + #immediate(3)

3. LSL, LSR: logical shift left/right

   语法：x1 = x2 <</>> #immediate(3)

   这个太重要了（悲），LSL 还简单就是自己加自己，LSR 就难 implement 了，有一个现成的 instruction 好多了

逻辑运算都是把 x2(reg) 和第 3 个 field(reg/immediate) 的运算结果存到 x1 (reg)

### ARM memory instructions

我们的便宜 ISA LC2K 的 addressing 方式是 by word (4 bytes in IC2K)，意思是每次 PC+1，实际上 PC 移动的是向前 4 个 bytes。这意味着我们无法处理 char 等长度小于 4 bytes 的数据类型。（因而我们的 LC2K 不是功能完备的 ISA）

word 的大小就是一个 instruction 的大小，也就是 ISA 的数据宽度（

#### 64-bit addressing

64-bit ISA 表示**寻址范围是第 0 - 2^64 个 bytes**:

 (0x0000 0000 0000 0000 - 0xFFFF FFFF FFFF FFFF)

（**Note: 这里这个 8 位 hex 数里面的 1 并不是 bit 而是 byte**！！

如果要存储一个 4 bytes 的 int，那么就是 for example 地址 0x0000 0000 1000 0001 - 0x0000 0000 1000 0004 都是这个 int）

note: 2^64 个 bytes 是理论上可达到的 addressing 范围，但是实际上受到内存条等具体硬件的限制。



而  **ARM 中一个 instruction 和一个 word 的长度是 4 bytes，也就是 32-bits**，并不是 64 bits！64 bits 仅仅代表地址编码的长度，而这个长度和 word 的长度毫无关系。（一个 half word 是 16 bits，一个 double word 是 64 bits）；

**一个 word / instruction / 其他数据类型的长度，代表它们占据几个 bytes**，即一个 object 占据多长的一块地址。

因而如果我们需要往前移动 a int，我们就要 increment address by 4；如果要往前移动一个 char，我们就要 increment address by 1。移动的单位都为 byte.



#### ARM 中的 regs

ARM 一共有 32 个 regs，因而在一条 instruction 中要以 5 个 bits 来 encode 一个 reg.

ZXR 表示 R31 寄存器，这是一个零寄存器，存储的值总是 0.

R15 是 PC 寄存器

#### memory instructions (data transfer)

1. `LDUR，LDURSW，LDURH，LDURB`: 

   语法：x1, [x2, #simm9]

   把 (1) double word；(2) word；(3) half word；(4) 一个 byte 从 **[x2 + #simm9]** 的 memory 中复制到 x1 reg 上

   其中 x2 是一个 地址，**#simm9 是一个 9-bit signed immediate value (-256~255) 作为 offset**，x1 是一个 reg

   注意：**LDUR 复制  8 bytes，LDURSW 复制 4 bytes，LDURH 复制 2 bytes，LDURB 复制 1 byte。**

2. `STUR，STURW，STURH，STURB`

   同理，只不过是反向复制，把 x1 reg 上的复制到 [x2 + #simm9] 上

   note: 唯一的区别是 LDURSW 的对应是 STURW 没有 S.

3. `MOVZ，MOVK`

   语法：x1, #m, LSL #n

   把 **某个 4 bytes 的 constant #m** 放进寄存器 x1 **从 第 n 位起左数的 16 位上**。

   比如 n = 16，那么会把 constant 放到 x1 的 [16,31] 位上.

   **`MOVZ` 表示把 x1 的其他 48 位全部清零，`MOVK` 表示保持其他 48 位不变.**

   note: **n 只能是 0，16，32，48 中的一个.**

#### 处理 load signed/ unsigned word

`LDUR` load 的是完整的一个 8 bytes (64 bit) 和 register 一样长的 word，所以直接 load 不用管 sign。

`LDURH`，`LDURB` 只处理 Unsigned，前面全部填上 0.

`LDURSW` 进行了一个 **signed extension**: 对于这个 word 的第 31 位，如果是 1 那么就前面 32~63 位上全都填上 F，如果是 0 那么前面 32~63 位上全部填上 0.

> ex: 0x7654 3210 被 LDURSW 后是 0x0000 0000 7665 3210
>
> 0xF654 3210 被 LDURSW 后则是 0xFFFF FFFF F654 3210

**至于 save word: 直接去掉 reg 前面 32~63 位，自动蕴含了 sign.**

所以只有 `LDURSW` 需要考虑 sign.



#### Big Endian && Small Endian

Endian 表示在一个 half/double/standard word 内，bytes 的 ordering: **significant bits 的地址在前面还是后面**

Little Endian 表示 word 的 4 个 bytes 中从前到后是 insignificant 到 significant；big endian 反过来

<img src="note-assets\{88DDE483-BA5F-43F7-ADF0-F64DE5B5ACF3}.png" alt="{88DDE483-BA5F-43F7-ADF0-F64DE5B5ACF3}" style="zoom: 67%;" />

ARM 中两种都可以使用，只是要 consistent，我们默认使用 little

比如现在我们有两个 word 0xABCDEF12，0x12345678

那么:

| 0x1001 | 0x1002 | 0x1003 | 0x1004 | 0x1005 | 0x1006 | 0x1007 | 0x1008 |      |
| :----: | :----: | :----: | :----: | :----: | :----: | :----: | :----: | :--: |
|   12   |   EF   |   CD   |   AB   |   78   |   56   |   34   |   12   |      |





## Lec 5 - C to Assembly

为了方便（且迅速） read from memory，现代 ISA 要求变量必须是 aligned 的。

### Padding for alignment

#### 对于 Primitive object (int, char, etc)

Golden Rule: 对于一个 size 为 N bytes 的 primitive object，只需要**存到下一个 mod N = 0 的 address 上就可以了。**

比如现在在 0x1001，下一个 object 是个 int， 就要跳到 0x1004 上，中间的 3 格作为 padding 空出来。

#### 对于 sequential object

array：只需要 treat 每个元素 as independent object 就可以，一共只需要 padding 一次

#### 对于 non-sequential object

如果只有一个 struct object，那么看起来只要每个 primitive 成分分开 padding 一下就可以了，但是我们发现如果我们想要一个 array of struct objects 就会有问题。**因为 beginning address 的不同会导致这个 struct array 中相邻的两个元素之间的 Padding 不同，这样这个 struct array 就很难 loop.**

<img src="note-assets\{49551745-506D-4341-B6AA-9A8D24986C1B}.png" alt="{49551745-506D-4341-B6AA-9A8D24986C1B}" style="zoom:75%;" />

解决方法：

除了正常的 Padding 外，再保证

1. struct 的 starting address 是 struct 中的 largest primitive 的倍数
2. 整个 struct 的 total size 是 struct 中的 largest primitive 的倍数

<img src="note-assets\{CD8E3D6A-43BB-4CD0-B29C-55CFD7117FCF}.png" alt="{CD8E3D6A-43BB-4CD0-B29C-55CFD7117FCF}" style="zoom:75%;" />

note: data padding 是 C compiler 把 C 翻译成 assembly 的时候做的事情。在 struct 外面，有的 compiler 会 reorder variables to avoid padding，但是 在 struct 里面任何 compiler 都不会（C99 has forbidden it.)

因而 object 在 struct 内的排布顺序是根据 declare 顺序排序的。所以我们为了省 padding 的空间需要在写 C code 的时候留意一下变量排布。



### Control flow (branching)

Sequencing instructions change the flow of instructions being excuted.

这是通过用 branching 调整 PC reg 实现的。



