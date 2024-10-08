# ·Note Part2: Digital Logic

## Lec 8 (1): 表示 float nums

digital logic 前的最后一个主题：如何表示 float numbers

float number 的表示方法是使用 IEEE floating point format，和 2's complement 完全不同.

single precision 单精度 (float in c++)：
32位数字，其中 

1. Most significant 是第 31 位表示正负：0 表示正，1 表示 负

2. **exponent**: 第 23-30 这 8 位是一个 exponential 数字，表示这个数字乘以二的多少次方。它**以 -127 为偏移量**，也就是说这八位数字从 0-255 的范围，可以表示从 -127 到 128. 所以它的范围是 $2^{-127}$ 到 $2^{128}$ 次方。所以可以表示很接近 0 到很大的数

   比如 `10000101` 就是 133，于是 exponential = 133-127 = 6，

3. **Mantissa**: 第 22 到 0 个 Bits 是 23 个有效数字. 它代表 1 后面的小数部分（隐含了最前面的一个 1， 所以其实是 24 位有效数字）

   $M$ 可以表示 $2^{-23}$ 到 $1 - 2^{-24}$ 的 $(0,1)$ 之间的精度.

所以最后的结果是 $\pm 1.M \times 2^{exp}$ .

并且我们发现其实 **exponential 就代表了把小数点后移多少位。**

起始的地方在 1.0，第零位是 $2^0 = 1$，第一位是 $2^-1$，第二位是 $2^{-2}$，。。。如果 exponential = 133-127 = 6，那么第一位就变成了 $2^{0+6} = 2^6$，第一位变成了 $2^5$

我们不难发现一件事情就是：当 exponential 变大的时候，我们能表示的两个数之间的间隔就变大了，精度就变小了。比如当 exponential = 23 的时候，我们就无法精确表示小数了；当 exponent > 23 的时候，我们甚至无法表示一些整数了。

双精度浮点数 (double in C++) 有 64 位，其中有 53 bits of precision。所以它在 exp > 53 时也会无法表示整数

也就是说如果我们 declare `double x = pow(2, 55) + 0.23332131;`，我们并无法得到我们想要的数而是被迫只留下 $2^{53}$...... 即便使用 long double，还是有同样的问题

解决办法是我们自己写一个数据结构，通过算法来实现无限大精度。（其实不需要，因为现在有很多这样的 library 比如 GMP 等）



## Lec 8 (2): Combinatorial Logic

一些小 trick:

XOR = not (A nor (A nor B) nor (B nor (A nor B)))

not(A) = nor(A, A) = nand(A, A)

### Mux(multiplexor)

Mux: S = 0 时选择 A(上) 的值，S = 1 时选择 B(下) 的值

mux 和 nor, nand 一样都是 universal 的！一个 2^N entry 的全 truth table 可以通过 N

**mux: S ? B : A**

即 **(A and notS) or (B and S)**

我们可以通过嵌套 mux 来达成多个 Input 的 mux.

(programmable hardware)



### Decoder

一个 decoder 获取一个 n-bit binary 作为 input，并且 output $2^n$ 个 Bits. 其中有且仅有一个 bit 是 1，其他都是 0

比如一个 3x8 的 decoder，获取一个 3 位的 binary 作为 Input，这个 binary 的范围是 0-7 (0-indexed)，于是我们的 8 位输出中对应这个数字大小的一位是 1，其他是 0.

ex: 0b101 = 5，所以 decoder 的第六位 (b5) 是 1.

<img src="note-assets-370/Screenshot 2024-10-08 at 16.45.10111.png" alt="Screenshot 2024-10-08 at 16.45.10" style="zoom:50%;" />





### Adder

#### half-adder

half-adder 不考虑先前的进位，是一个简化的计算一个 bit 和一个 bit 相加的工具。我们获取两个 bits，算它们相加后这一位的结果和是否有进位 （一共也就 0, 1, 2）

<img src="note-assets-370\{E165222C-CC3F-474A-8032-F9580E205A42}.png" alt="{E165222C-CC3F-474A-8032-F9580E205A42}" style="zoom: 80%;" />

#### full-adder

我们可以增加一个 Input：上一位的 carry bit，这样就可以得到一个 full adder.

<img src="note-assets-370\{0023C04C-ECF3-4A1B-B9DB-DA6CA9379A31}.png" alt="{0023C04C-ECF3-4A1B-B9DB-DA6CA9379A31}" style="zoom: 80%;" />

通过连接 n 个 full adder，我们可以得到一个 n-bit adder

<img src="note-assets-370\{A63FC22E-91F0-46E9-9449-0DCBED291405}.png" alt="{A63FC22E-91F0-46E9-9449-0DCBED291405}" style="zoom:80%;" />

#### 从 n-adder 得到 n-substracter

我们知道 A - B = A + (-B)，

并且 2'complement 下，-B = ~B + 1

于是我们发现了一件巧妙的事情：一般情况下，我们把第 0 个 bit 的 input carry bit 设置为 0；而**我们只需要把这个第 0 位 carry bit 设置为 1，然后 invert B，就可以得到 A - B**

我们可以在 B 上加一个 mux，这样就可以通过控制是否 flip B 来控制这个 adder 和 subtracter 之间的转化，让其多功能。

<img src="note-assets-370\{0CCFCF5C-8167-4537-9228-2DDF6AC77A27}.png" alt="{0CCFCF5C-8167-4537-9228-2DDF6AC77A27}" style="zoom:80%;" />



### ALU design

我们需要一个计算单元把 full adder 和 nor 结合起来，这样它就可以用来做到任何的基础运算。

ALU 就是  Arithmetic Logic Unit。我们很自然想到把一个 32-bit full adder 和一个 32 位 input 的复合 nor gate 的输出用一个 mux 连接起来就可以实现一个 ALU.

(这只是对于 LC2K，其他更复杂的 processor 融合了更多函数)

<img src="note-assets-370\{EA817860-A522-4A95-B421-41C33B99889A}.png" alt="{EA817860-A522-4A95-B421-41C33B99889A}" style="zoom:80%;" />

当 S = 1 时这是个 nor，当 S = 0 时这是个 32-bit adder. 





## Propagation delay

当 gate 的 input 变化时，output 不是立刻变化的。gate 的处理需要一定时间。因为 speed of light 也是有限的，transmit through wires 需要一定时间；并且电压变化也不是一瞬间的，电压变化到一定值使得 transistor switch 也需要一定时间。

所以有了 Propagation delay. 也就是对于每个逻辑门（可以忽略 wires 的电速传输导致的 delay），我们都要考虑它接受 Input 到输出 output 之间，逻辑门处理的 delay.

**overall delay 就是 delay 最大的一个串联路线的 delay.** 

我们需要考虑 delay，因为我们需要保证我们留下了充足的时间让它 propagate，以至于我们得到的值确实是逻辑结果而不是误差导致的中间结果



## Lec 9: Sequantial Logic

Combinatorial Logic 指的就是 circuits whose input 只取决于 current input. 即不关心时间，只需要 operands 就能产生结果

但是 combinatorial logic 并不能形成一个 computer. computer 会 remember previous inputs 并根据 history 对相同的 inputs 有不同的表现。

具体的理解是：

我们的 program 有 state. states 就是当前程序的状态：比如各个变量的值，PC 在哪一条指令上，regs 的内容以及 memory 上的内容等等。

而 input 则是外部的数据输入：比如 cin 等等

对于不同的指令，以及变量值得不同，计算机处理相同的输入内容的行为不同。





我们可以用 gates 来建立 seq logic. 关键在于 feedback: 一个 gate 的 output 会 fed back into its own inputs.





<img src="note-assets-370\{77A64046-015D-4B57-B328-73A69C2CE1DA}.png" alt="{77A64046-015D-4B57-B328-73A69C2CE1DA}" style="zoom:50%;" />

一个这样的 cell 会记住初始值，一直停留在初始值上。但是我们无法再改变它。所以我们需要一些输入来控制一个单元，让它能够变成这个 cell，但是也可以控制它变化。





### SR latch

latch 即一个触发器

SR 用来 implement memory，表示要不要把一个 bit 设成 0/1

S, R 是两个 bit input。S 代表 set，R 代表 reset

S = 0, R = 0：什么都不做，Q 保持原先状态（本来是1就是1，本来是0就是0），因为这个时候被转化成了这个稳定的

S = 1, R = 0 (set)：输出 Q = 1（Q reverse = 0）

S = 0, R = 1(reset)：输出  Q= 0（Q reverse = 1）

<img src="note-assets-370\{AE5E375F-8B77-4DC8-8AEB-424CA6143821}.png" alt="{AE5E375F-8B77-4DC8-8AEB-424CA6143821}" style="zoom:80%;" />



S, R = 1: undefined behavior. 这个时候输出 Q 和 Q^ 都变成了 0，暂时稳定，但是问题是：**如果我们这个时候调整 S, R 都变成 0，那么 Q 和 Q^ 都会不停 rapidly osilating between 0 and 1**，circuit unstable 且不可预测.

<img src="note-assets-370\{1390C8BD-309D-41D9-A1E1-C95B99D0EF31}.png" alt="{1390C8BD-309D-41D9-A1E1-C95B99D0EF31}" style="zoom:80%;" />



### D latch (improved SR latch)

D 表示 Data

G 表示 Gate.

这个改进版本的好处就是不会再出现 undefined behavior，保证了数据安全。

<img src="note-assets-370\{4B112829-80DE-4DBF-AF80-7023B81A801E}.png" alt="{4B112829-80DE-4DBF-AF80-7023B81A801E}" style="zoom: 67%;" />

**现在设置 G = 1：允许改写 data，Q = D。我们称这个状态下 latch 是 transparent 的（允许修改**

**设置 G = 0：不允许改写 data，不论 D 是多少，Q 都保持原状**



#### 画 D-latch Timing Diagram

<img src="note-assets-370\{3BB04FF8-79E6-495A-B25A-840D07346389}.png" alt="{3BB04FF8-79E6-495A-B25A-840D07346389}" style="zoom:80%;" />

在刚开始的时间：G low，Q 保持之前的状态（不知道），所以画两条线表示 Uncertainty.

之后，我们的原则：只有 G 开时改写，G 关上时保持状态。





### D flip flop (improved D latch)

D latch 的 problem: G 必须被 set very precisely

<img src="note-assets-370\{A046B635-612B-460D-906C-E0A7FC2D231B}.png" alt="{A046B635-612B-460D-906C-E0A7FC2D231B}" style="zoom:80%;" />

我们可以尝试用 32 个 D latches 来储存 PC，并且通过这样的循环，每次当 ready to 执行下一个 instruction 的时候就 open gate 来控制 PC++

但是问题是这个电路太过敏感。我们需要 PC 恰好被 ++ 一次（或者特定数量）

如果 G 设置的时间过长了那么信号可能会 propagate round 两次以至于 PC 被 increment twice；如果 G 设置的时间过短可能 latch 没有 stabilize，使得 PC 没来得及 imcrement

（FYI: set 一个 frequency 很高的 signal 是很难的）

所以 timing 很难。





所以我们添加一个 clock：一个在 0 和 1 之间 alternating 的固定 frequency 的 signal.

只在 clock 的 edge 上 write data.

<img src="note-assets-370\{3F233E00-6E67-484B-8E54-275C72FC31A4}.png" alt="{3F233E00-6E67-484B-8E54-275C72FC31A4}" style="zoom:80%;" />

this class 只考虑在 rising edge 上写入 data 的固定的 Clock 接入方式. (Dually)

<img src="note-assets-370\{7B17D1F4-2BFD-4025-B56F-F3C1DBE1AA78}.png" alt="{7B17D1F4-2BFD-4025-B56F-F3C1DBE1AA78}" style="zoom:80%;" />

就是这样的接入方式。我们可以验证它只在 clock 从 0 变成 1 的 rising edge 上使得数据被写入 Q（可以但没必要

<img src="note-assets-370\{C7FC4C78-FE34-490F-A733-7BF53B659186}.png" alt="{C7FC4C78-FE34-490F-A733-7BF53B659186}" style="zoom:67%;" />

<img src="note-assets-370\{DDA65FF7-E0C0-40D6-8A8B-1721E70AE816}.png" alt="{DDA65FF7-E0C0-40D6-8A8B-1721E70AE816}" style="zoom:67%;" />

D flip flop 并不是无懈可击的，如果恰好，data 改写的时间就在 clock 的 rising edge 上，那就 bad. (reason: will know it if you take 270)



标识：普通 D latch，D flip-flop 和 Enabled D Flip-Flop （多加入 enable 信号，只有 enabled 时才会接收更改，

<img src="note-assets-370\{3AEBC69D-479A-4D24-ACCE-E8492DE52134}.png" alt="{3AEBC69D-479A-4D24-ACCE-E8492DE52134}" style="zoom:50%;" />

#### 为什么 Flip Flop 可以避免PC被 increase 多次的问题

假设 PC 在一个时钟周期内需要递增一次，而在时钟高电平期间，递增信号传递到 D Latch。由于 D Latch 在高电平期间对输入开放，如果递增信号持续存在，PC 可能被递增多次，因为每次输入 D 变化时都会更新输出 Q。

当使用 D Flip-Flop 来存储 PC 时，即使 PC 的递增信号在时钟周期的高电平持续时间内保持有效，D Flip-Flop 只会在时钟的边沿时刻更新 PC 的值。因此，即使递增信号在时钟高电平期间存在很长时间，PC 也只会被递增一次。

（my question: 如果同一个 pc 递增信号经历了两个 clock edge 怎么办？如果一个 pc 递增信号在 clock edge 来到之前就消失怎么办？

答：不考虑。假设一个信号一定正好经历一次 clock edge.



## Lec 10: Finite State Machine

combinatorial logic：用来 implement 布尔表达式

sequential logic: 用来存储状态



现在我们学习如何

一个 FSM 的组成是

1. 有限个状态
2. N 个 inputs
3. M 个 outputs
4. Transition function $T(S,I): states \times inputs\rightarrow states$，把每个状态下的每个 input 都映射到一个新的状态
5. Output function: 分为两种：如果只取决于 State，那么就是 Moore Machine；如果取决于 state 和 input，那么就是 Mealy Machine

计算机中的 一个state 就是 memory, reg files 和 regs 的值. 我们使用 Read Only Memory 来 implement （对于一个ISA的）transition function：即操作指令如何和 memory 进行交互



和 376 的 FSA 基本一样。区别是：FSA 只在 final state 产生 output 而 FSM 一直在产生 output；FSA will eventually stop，但是 FSM 会有不停的 (ideally) input，不会 stop.

FSM 就是一个每时每刻都接受 input，并马上通过 input 来到 next state 并产生 output 的机器。



### ROM(read only memory)

我们使用 programmable read only memory （每个 bit 只能修改第一次）针对我们的 ISA 来 implement 出它的 FSM（即读写数据以及计算数据的 data path）

<img src="note-assets-370/Screenshot 2024-10-08 at 05.15.36.png" alt="Screenshot 2024-10-08 at 05.15.36" style="zoom:50%;" />



Idea: 由于有很多变量和输出结果不同，我们用 logic gates 来实现真值表太过于耗时间。

所以我们考虑直接把整个真值表储存进某个 Read Only memory 里。可以直接买一个 read only memory bar 来实现。

<img src="note-assets-370/Screenshot 2024-10-08 at 09.45.56.png" alt="Screenshot 2024-10-08 at 09.45.56" style="zoom:50%;" />



ROM 的使用是这样的：

这是一个 8 entry 4 bit 的 ROM.

我们输入一个 3 位的 bits 用 3x8 decoder 把它的输出转化为 8 位只有一位是 1 的 bits，于是每一个输入就对应了 decoder 的一个 horizontal line.

我们可以通过调整 data output 和 horizontal line 交线上的 diodes 来编辑 ROM（只能编一次，因为调整就是把它烧掉），控制这一条 horizontal line 对应的输出。

这就实现了每个 state 的不同输出



![Screenshot 2024-10-08 at 09.50.33](/Users/fanqiulin/Library/Application Support/typora-user-images/Screenshot 2024-10-08 at 09.50.33.png)

这种存储 state output 的方式很常见，也有缺点：如果我们要多加入一个 bit 的 input，我们就要 double the size of ROM. 所以储存大小的需求是 exponential 的




#### 计算 size of ROM

Size of ROM = #of ROM entries * size of each entry. 	

其中 #size of ROm entries = $2^\text{input size}$， size of each entry = outputsize

所以
$$ { }
\text{sizeROM} = 2^{input size} * \text{outputsize}
$$
对于 24 位地址的输入，假设我们 ROM memory 宽度是 13 bit，那么我们需要 2^24 * 13 =218,103,808 bits = 26 MB ROM. 如果我们买 六美元 4mb 的 ROM，我们需要大改 42 美元才可以实现

（并且我们需要编辑这些 ROM，显然不太可行



所以我们需要结合 combinatorial logic 和 ROM 来实现 transition 来优化我们需要的 ROM 大小



ex：

优化前：ROM = 2^24 * 13 bits

<img src="note-assets-370/Screenshot 2024-10-08 at 11.24.29.png" alt="Screenshot 2024-10-08 at 11.24.29" style="zoom:67%;" />

优化后：ROM = 2^5 * 4 bits

<img src="note-assets-370/Screenshot 2024-10-08 at 11.24.45.png" alt="Screenshot 2024-10-08 at 11.24.45" style="zoom:67%;" />





## Lec 11: Single-Cycle Datapath

我们需要设计一个 General purpose processor. 

它需要做的：

1. fetch instructions 

2. decode instructions (即把 instructions 输入给 control ROM)

3. 通过 ROM 来控制 data movement

   包括 pc++，reading regs，ALU control 等

   LC2K 中，ROM 接受一个 3x8 decoder，把 3 位的 opcode decode 为 00000001 - 10000000，对应八个不同的八个 bits. ，放在合适的地方（比如作为某个 mux 的选择 bit 等）来实现不同的操作

4. 用 clock 来 drive all

<img src="note-assets-370/Screenshot 2024-10-08 at 16.38.18.png" alt="Screenshot 2024-10-08 at 16.38.18" style="zoom:67%;" />

Note: 我们 assume 任何 memory 都是一个 array of D flip flops，实际情况更复杂，但是我们这样假设

Note2: sign extension 运算<img src="note-assets-370/Screenshot 2024-10-08 at 16.47.15.png" alt="Screenshot 2024-10-08 at 16.47.15" style="zoom:50%;" />



### State Building Blocks: reg files, memory 

<img src="note-assets-370/Screenshot 2024-10-08 at 16.56.26.png" alt="Screenshot 2024-10-08 at 16.56.26" style="zoom:67%;" />

Reg file 就是所有 regs 的集合。

我们使用这样的一个 reg file memory block 来储存 memory，通过逻辑门取其中的第 R1 个和第 R2 个以及第 D 个：R1，R2 表示读取的两个 regs，D 表示要写入的 reg

W 表示要写入的数据

还有组合进它的逻辑的是一个 enable bit，用 mux 来控制是否要打开 write. 不需要改写 reg value 的指令可以不 enable 它，使得速度更快



<img src="note-assets-370/Screenshot 2024-10-08 at 17.06.28.png" alt="Screenshot 2024-10-08 at 17.06.28" style="zoom:67%;" />

data memory：更慢的 memory。这是因为我们总是先处理 reg file，然后 reg file 中输出的 reg values 再才可能输入到 data memory 里，用以交互，储存 regs 里放不下的值

同样支持读写，需要一个 enable bit 和一个 mux 控制 enable





现在我们做一个 single-cycle datapath for LC2K: **任意 instruction 都在一个 clock cycle 内完成**

### ADD/NOR













## Lec 12 Multi-Cycle Datapath & Pipelining

