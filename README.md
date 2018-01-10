# RISC-V cpu

Computer Architecture homework

---
Instructions : (0/39)

- [x] Integer Register-Immediate Instructions

     - [x] ADDI
     - [x] ANDI
     - [x] ORI
     - [x] XORI
     - [x] SLTI (set less than integer)
     - [x] SLLI (logical left shift)
     - [x] SRLI (logical right shift)
     - [x] SRAI (arithmetic right shift)
     - [x] LUI (load upper immediate)
     - [x] AUIPC (add upper immediate to pc)

- [x] Integer Register-Register Operations

     - [x] ADD
     - [x] SUB
     - [x] AND
     - [x] OR
     - [x] XOR

     - [x] SLL
     - [x] SRL
     - [x] SRA

     - [x] SLT
     - [x] SLTU

- [x] Control Transfer Instructions

     - [x] Unconditional Jumps
          - [x] JAL
          - [x] JALR
     - [x] Conditional Branches
          - [x] BEQ
          - [x] BNE
          - [x] BLT(U)
          - [x] BGE(U)

- [x] Load and Store

     - [x] LOAD
     - [x] STORE

- [x] Control and Status Register Instructions (System)

     - [x] CSR Instructoins
          - [x] CSRRW
          - [x] CSRRS
          - [x] CSRRC
          - [x] CSRRWI
          - [x] CSRRSI
          - [x] CSRRCI
     - [x] Timers and Counters
          - [x] RDCYCLE
          - [x] RDTIME
          - [x] RDINSTRET
     - [x] Environment Call and Breakpoints
          - [x] ECALL
          - [x] EBREAK


---

## References:

http://www.asic-world.com/systemverilog/tutorial.html

---

## 2. Forwarding

​	将EX和MEM阶段的结果直接送回decode阶段，从时序上来讲，EX的指令在MEM指令之后，所以最后会是EX的结果覆盖掉MEM的结果。所以优先将EX的结果forwarding回去，然后是MEM。



## Log :

### 2017-12-27 21:01:04 ori 指令运行成功

## 可能的优化

1. LUI实现成0寄存器与立即数取或，可以节约一点空间（元件）。

## 可能出现的问题：

1. PC寄存器的时序。

   JALR读到的是当前PC还是已经+4的PC还是+8的PC？

   要不把PC+4放在时钟下降沿来做？
