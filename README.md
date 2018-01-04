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

- [ ] Control Transfer Instructions

     - [ ] Unconditional Jumps
          - [ ] JAL
          - [ ] JALR
     - [ ] Conditional Branches
          - [ ] BEQ
          - [ ] BNE
          - [ ] BLT(U)
          - [ ] BGE(U)

- [ ] Load and Store

     - [ ] LOAD
     - [ ] STORE

- [ ] Control and Status Register Instructions (System)

     - [ ] CSR Instructoins
          - [ ] CSRRW
          - [ ] CSRRS
          - [ ] CSRRC
          - [ ] CSRRWI
          - [ ] CSRRSI
          - [ ] CSRRCI
     - [ ] Timers and Counters
          - [ ] RDCYCLE
          - [ ] RDTIME
          - [ ] RDINSTRET
     - [ ] Environment Call and Breakpoints
          - [ ] ECALL
          - [ ] EBREAK


---

## References:

http://www.asic-world.com/systemverilog/tutorial.html

---

## 2. Forwarding

​	将EX和MEM阶段的结果直接送回decode阶段，从时序上来讲，EX的指令在MEM指令之后，所以最后会是EX的结果覆盖掉MEM的结果。所以优先将EX的结果forwarding回去，然后是MEM。



## Log :

### 2017-12-27 21:01:04 ori 指令运行成功
