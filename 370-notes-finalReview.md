# 期末复习

此条为做题目的时候碰到的错误以及注意点汇总



## 1. Binary

一个2's complement num 取负: nor 自身之后再 +1; 相对地, nor 自身的行为等价于取负后 -1.

两个数的 nor 在二进制表示位宽足够的情况下不受位宽影响.















## 2. Assembly

















## 3. Linking










## 4. Digital Logic







## 5. Single/MultiCycle Datapath











## 6. Pipelining







Control Hazard: 

predict and speculate，错误停 3 cycles. 策略会记住某个指令的地址, 针对过去的回答 predict













## 7. Cache





tag, set index, offset. 

如果 inf length fully asso 仍 Miss: compulsory

Else: 如果 fully asso 仍 Miss: capacity；Else: Conflict

**Note: 更换 inf length 和 fully asso 时 set index 无, tag 长度改变.**







## 8. VM

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

