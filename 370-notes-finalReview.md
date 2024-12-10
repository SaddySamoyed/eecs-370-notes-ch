# 期末复习

此条为做题目的时候碰到的错误以及注意点汇总



## 1. Binary

一个2's complement num 取负: nor 自身之后再 +1; 相对地, nor 自身的行为等价于取负后 -1.

两个数的 nor 在二进制表示位宽足够的情况下不受位宽影响.















## 2. Assembly

















## 3. Linking









## 4. Digital Logic

#### Float num

mux: 0上1下

表示 float num: 

1. most sig 0表示+, 1表示-; 

2. exponential bits 表示 数字乘以 2 的多少次方. 偏移量 -127

   ex: 1000101 = 133, exponential = 133-127 = 6

3. 后面 Bits 表示 1.xxxx 的 xxxx 

   ex: 6.67，6 = 110, 67= 101...

   0.67 × 2 = 1.34 → 1，余 0.34 

   0.34 × 2 = 0.68 → 0，余 0.68 

   0.68 × 2 = 1.36 → 1，余 0.36

   因而得到 110.101....., = 1.10101 * 2^2

   因而需要用 exponential bits 表示 129, 129-127=2

   







## 5. Single/MultiCycle Datapath











## 6. Pipelining



Stage 1 Fetch: (1) index memory by PC address; (2) PC++; (3) 把 PC和 instruction 写入 IF/ID

Stage 2 Decode: (1)



Data Hazard





















Control Hazard: 

predict and speculate，错误停 3 cycles. 策略会记住某个指令的地址, 针对过去的回答 predict

branch predictor: in lec, discussed direction predicter, predict take or not; 针对 functions 还有 target predicter, predict function return 的 target











## 7. Cache

speed: flip flop(reg) > SRAM(cache) > DRAM(memory) > disk

计算 latency: aver latency = cache latency + mem latecy * missrate
temporal locality: 变量在同一段时间会多次使用;

spatial locality: 离得近的变量很可能接连被使用

#### 7.1 write back & allocation

overhead: non-data in a block / block size

write back: sw 不直接 save 而是取所在 block, 如果期间被使用则更改则加上 dirty bit, 被 evict 时有 dirty bit 则放回 memory; write through m

write back 的劣势: overhead +1 dirty bit; 在 spatial, temporal locality 不好的 program 上 memory access 反而多于 write through





tag, set index, offset. 

如果 inf length fully asso 仍 Miss: compulsory

Else: 如果 fully asso 仍 Miss: capacity；Else: Conflict

**Note: 更换 inf length 和 fully asso 时 set index 无, tag 长度改变.**







## 8. VM (finished)

address: virtual L1 index, virtual L2 index, page offset

Page table Base reg: 指向 L1 Start 所在 PAddress

L1 n^th^ entry: virtual n^th^ L1 index 对应的 L2 table 的 physical page num

找到这一 page num 上的 L2 table 后: 

L2 m^th^ entry: virtual m^th^ L2 index 对应的 page 的 physical page num

这一 physical page num 对应 page 上的 offset^th^ entry 就是 PAddress of this address

上面内容是这一 VAddress 对应的真实内容



page offset: log_2(pageSize)

Virtual Page num bits: rest address

Physical Page num: physicalMemory / PageSize

Physical Page num index range: log_2(Physical Page num)

