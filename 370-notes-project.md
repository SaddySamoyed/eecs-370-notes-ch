# 370 Project notes

## Project 2

### 2a - Assembler

#### Output format

第 1 行是 Header：记载 Text, Data, Symbol, Relocation Table 的行数

第 2 行 ~ 第 n 行是 Text. 和 project 1 一样. 抄过来就可以.

第 n+1 行 ~ 第 m 行是 data. 和 project 1 一样，抄过来就可以.

第 m+1 行 ~ 第 k 行是 Symbol table，记录所有的 global variables 和 function name. 本地的使用 T/D，extern 的使用 U 表示 undefined

第 k+1 行 ~ 最后是 relocation table，relocate 所有 used in a non relative way (即 access memory) 的 instructions



#### Symbol Table/Relocation Table

关于什么东西要放到 symbol table 以及 relocation table:

在 LC2K 中，我们用小写  label 表示 static 的变量，用大写 label 表示 global 的变量（函数内自己的 local variable 并不会 .flll 储存，而是运行时通过在 memory 的 stack frame 上的 LDUR, SDUR 交互来完成）

(Note: 我们称小写 label 为 local label，它对应 C 中 static 的变量，不是 local 的变量.)

所以：

Symbol Table: 所有其他文件也能看到的东西：global var，函数名（总之就是所有的 global label）

Symbol Table 并不检查 Global Label 的使用，而是只检查 Global Label 的 def，除了在 offsetField 中如果出现 undefined global var

Relocation Table: 所有 static, global label 的相关行为。其实就是除了 beq (relative) 外所有涉及标签的指令.



#### Label 的处理

虽然因为这一次是多文件处理，label 实际上并不能代表绝对地址，但是我们还是把它当绝对地址处理。

undefined label 全部作 0 处理。

其他的和 p1 一模一样。（感觉 linker 要做的事情因此会很多。。。



#### 流程

1. 读一遍，确定 Defined Labels 和 每个区的长度；

2. 读第二遍，转换 Opcode。

   期间读到使用 label（offsetfield 上）则判断：

   如果是大写 Label 则放到

   如果是 beq 则无所谓，如果不是则把这个指令和右边 offsetfield 上使用的 label 放到 Relocation Table 成为一个 entry

#### bug 5678

这里我的 test case 发现了两个 Bug:

1. 计算 line 到达 text 和 data 分割点的方法有问题。一个是没考虑纯 text 和 纯 data，另一个上很长的 data 会导致循环（这里犯了一个低级错误，一旦行数积累到 text 数量 line 就清零了）

   解决方法是使用 lebron 的做法，设一个 partition line 表示在哪一行 partition，然后 line 追踪

2. 很多人都有的一个问题：对于出现两次的 extern label 处理并不好。出现 label 时我们都搜索，如果找到了就直接转换，如果没找到则 {if 大写，是 extern，写成0；if 小写，是 undefined 报错}

   但这里发现问题：没有处理同时出现两次的 extern label.

   解决方法：发现 extern 时也查一遍 symbol 表.

解决这两个问题之后结束了。 test case 还差四个

整理 test case:

A: test1fill

B: test5

D: test1fill

E: test14zf

F: test1fill

I: test1fill

J: test10-duplicate

(test1像个战神。。)
