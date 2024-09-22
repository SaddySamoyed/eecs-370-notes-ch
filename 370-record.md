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

