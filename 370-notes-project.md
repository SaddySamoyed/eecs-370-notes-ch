# 370 Project notes

## Project 1

## 1a - Assembler

一个巨大的惨痛经验：一定不要吝惜时间写 test files，写 test files 的时间都是微不足道并且值得的。。。。自己的 test file 就是可以检验程序写的对不对

Specifically: p1a 花了大量时间的主要理由就是：一直没找到读 int 的那个问题，，，一定要 `& 0xFFFF` ！！！因为系统的 int 不是 16 位的，而我们这里 16 位，碰到二补码前面全是 F 就老实了。一定要注意每个数字的格式！！



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
计算 line 到达 text 和 data 分割点的方法有问题。一个是没考虑纯 text 和 纯 data，另一个上很长的 data 会导致循环（这里犯了一个低级错误，一旦行数积累到 text 数量 line 就清零了）
解决方法是使用 lebron 的做法，设一个 partition line 表示在哪一行 partition，然后 line 追踪
很多人都有的一个问题：对于出现两次的 extern label 处理并不好。出现 label 时我们都搜索，如果找到了就直接转换，如果没找到则 {if 大写，是 extern，写成0；if 小写，是 undefined 报错}
但这里发现问题：没有处理同时出现两次的 extern label.
解决方法：发现 extern 时也查一遍 symbol 表.
解决这两个问题之后结束了。test case 还差四个

整理 test case:

A: test1fill

B: test5

D: test1fill

E: test14zf

F: test1fill

I: test1fill

J: test10-duplicate

(test1像个战神。。)







### 2l - Linker

这个 project 的任务就是：把一堆 object files 连接成一个 .mc

```sh
./linker file_0.obj file_1.obj ... file_N.obj machine_code.mc
```



.mc 也很简单，就是所有的 texts 和所有的 data；最后的 .exe 理论上可以用 p1 中的 simulator 跑



我们假设：main 总是在第一个 file 里。这就合理多了



所以这个 project 实际上就是做这件事：我们对于其他指令只需要暴力叠加就可以，





我的观点：

1. 首先统计每个文件的 D, T 数量，起一个2d array 表示 第 i 个 obj 的 D/T 从何开始

2. 起两个 Symbol array：一个 defined 一个 undefined

   遍历所有 obj 的 Symbol Table。这个 Symbol array 获取 Symbol Tables 的信息，就是原本的 Symbol Table的 concatenate，加上这个 Symbol 应该在哪个文件里。这个“应该在哪个文件”的变量初始值：

   非 U 的放进 defined array，U 的放进 undefined array.

   然后：

   (1) defined 里有多个定义：error

   (2) 在结束后，我们遍历 undefined array: 除了 Stack 每个都能在 defined 里找到吗？否，error；

   这里，Stack 这个特殊 Label 的起始时 M+N，就是所有D，T 的数量的位置，而其他 Label 都应该 defined.

   





做完这件事情之后，暴力链接。然后我们根据位置 array 和 relocation table，对于每个变量的绝对位置进行修改。

也就是说，我们需要解码，修改，再编码

Note：relocation table 也需要全部遍历并读取一次，在最后加上 Stack。

没了。这个 project 就这么点，但是细节绝对复杂。。。



打开 starter 泪流满面。。。他已经把这些 initialization 都写好了，大概两百行差不多最多了





意外的快，三个小时就只剩 error checking 了

error checking 和 test files 写完就结束。预计两点左右？大约可以开始写 2r 了。写到四点收工吧，学 454



又是经典操作之写错了一个 i/j。。。







### 2r - Recursive Function

就是用 lc2k 写一个 Fibonacci 

 C version 如下:

```c
int fibonacci(int n)
{
    if (n == 0 | n == 1) {
        return n;
    } else {
        return fibonacci(n-1) + fibonacci(n-2);
    }
}
```





注意以下几个要点:

1. 首先 pass input n 进入 reg1
   lw         0        1      input        r1 = memory[input]
2. 我们使用 Stack 这个 Label 表示 Text 和 Data 之后紧接的 memory. 不需要定义它, 可以直接使用. 使用例:
       sw          5       7       Stack       save return address on stack
       add         5       6       5           increment stack pointer
       sw          5       1       Stack       save input on stack
       add         5       6       5           increment stack pointer
       add         1       1       1           compute 2*input
       add         5       6       5           decrement stack pointer



### 特殊 regs

3. 有些 regs 有特殊的用处:
   r0  value 0
   r1  n input to function - ENFORCED
   r2  local variable for function
   r3  return value of function - ENFORCED
   r4  local variable for function
   r5  stack pointer
   r6  temporary value (can hold different values at different times, e.g., +1, -1, function address)
   r7  return address - ENFORCED



框架是: 

````assembly
    lw          0       1       n
    lw          0       4       Faddr        //load function address
    jalr        4       7                    //call function
    halt
    <add your code here>
n   .fill       7
    <add your data here>
````



步骤是:

1. Accept n as an argument passed in register 1
2. Store the starting line of your combination function by including the following line in data:
    Faddr .fill <label_at_start_of_function>
    <start_of_function> is a label at the start of your function
3. Use recursion by building a stack frame for each function called
4. Return the result in register 3
5. Use register 7 as the return address
6. DO NOT use a global register
  A global register is one that all recursive calls to a function use. We should be utilizing the stack to keep track of our computed values.



我的想法：每个栈都存储一个 这个栈的 n 是多少，对于在 stack pointer 最前面的 stack，如果 n 不是 1 或者 0，那么就拆分 n 变成 n-1, n-2；如果 n 是 0，1，，那么就进入 base case 并把结果加到 r3 上，并且 -- stackpointer. 



所以思路就是：

并不需要两个 recursive call，而是只需要一次：每一次 recursive call，我们都将 stack pointer 上的 n 和 1，0进行对比，如果是1，0则进入 basecase (add 1/0 到 r3 上) 并 --sp；如果不是1，0 则先--sp 相当于把当前的 n pop 掉，然后再 sp++两次把 n-1, n-2 push 到 sp 上，



所以我的 FIbo 的逻辑：

1. 如果 sp ==0: halt

2. 比较 n 和 1, 0: 是否进入 base case

   base case: sp--; 

   r3 += n; 

   jalr;

3. 没有 beq: 

   sp--, 

   mem[sp] = n-1; 

   sp++; 

   mem[sp] = n-2; 

   sp++;

   Jalr;
