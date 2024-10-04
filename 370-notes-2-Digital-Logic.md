# Note Part2: Digital Logic

## Lec 8 (2): Combinatorial Logic

### Mux(multiplexor)

Mux: S = 0 时选择 A(上) 的值，S = 1 时选择 B(下) 的值

mux 和 nor, nand 一样都是 universal 的！一个 2^N entry 的全 truth table 可以通过 N



### Decoder



### Adder



### ALU design





## Lec 9: Sequantial Logic

### SR latch

SR 用来 implement memory，表示要不要把一个 bit 设成 0/1

S, R 是两个 bit input。S 代表 set，R 代表 reset

S = 0, R = 0：什么都不做，Q 保持原先状态（本来是1就是1，本来是0就是0），因为这个时候被转化成了这个稳定的

S = 1, R = 0 (set)：输出 Q = 1（Q reverse = 0）

S = 0, R = 1(reset)：输出  Q= 0（Q reverse = 1）

S, R = 1: undefined behavior，因为 Q 和 Q^ 都 osilating between 0 and 1，circuit unstable.



### D latch (improved SR latch)

D 表示 Data

G 表示 Gate.

这个改进版本的好处就是不会再出现 undefined behavior，保证了数据安全。

现在设置 G = 1：允许改写 data，Q = D

设置 G = 0：不允许改写 data，不论 D 是多少，Q 都保持原状



### D flip flop (improved D latch)

D latch 的 problem: G 必须被 set very precisely

比如下面的例子里，如果 G 设置的时间过长了那么信号可能会 propagate round 两次以至于 PC 被 increment twice；如果 G 设置的时间过短可能 latch 没有 stabilize，使得 PC 没来得及 imcrement



（FYI: set 一个 frequency 很高的 signal 是很难的）



所以我们添加一个 clock：一个 frequency 在 0 和 1 之间 alternating 的 signal.

只在 clock 的 edge 上 write data.

this class 只考虑在 rising edge 上写入 data 的固定的 Clock 接入方式. (Dually)

但是 problem: 如果恰好，data 改写的时间就在 clock 的 rising edge 上，那就 bad. (reason: will know it if you take 270)



## Lec 10: Finite State Machine

和 376 的 FSA 基本一样。区别是：FSA 只在 final state 产生 output 而 FSM 一直在产生 output；FSA will eventually stop，但是 FSM 会有不停的 (ideally) input，不会 stop.



如果没有 state transition: 总是在同一个 state.

### ROM(read only memory)







## Lec 11: Single-Cycle Datapath

