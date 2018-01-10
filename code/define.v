//************************** global define ****************************
`define RstEnable         1'b1            // enable reset signal
`define RstDisable        1'b0            // disable reset signal
`define ZeroWord          32'h00000000    // 32-bit value 0
`define WriteEnable       1'b1            // enable writting
`define WriteDisable      1'b0            // disable writting
`define ReadEnable        1'b1            // enable reading
`define ReadDisable       1'b0            // disable reading
`define AluOpBus          8:0             // 译码阶段的输出aluop_o的宽度
`define AluSelBus         2:0             // 译码阶段的输出alusel_o的宽度
`define InstValid         1'b0            // 指令有效
`define InstInvalid       1'b1            // 指令无效
`define True_v            1'b1            // logical true
`define False_v           1'b0            // logical false
`define ChipEnable        1'b1            // 芯片使能
`define ChipDisable       1'b0            // 芯片禁止
`define Stop              1'b1            // 流水线暂停
`define NoStop            1'b0            // 流水线继续
`define TRUE32            {31'b0,1'b1}
`define FALSE32           32'b0

`define DataAddrBus       31:0
`define DataBus           31:0
`define DataMemNum        256
`define DataMemNumLog2    8
`define ByteWidth         7:0

`define ALU_OP_WIDTH      4
`define XPR_LEN           32
`define SHAMT_WIDTH       5
//***********************     ALU op code     *************************
`define ALU_OP_NOP        4'b0000
`define ALU_OP_ADD        4'b0001
`define ALU_OP_SUB        4'b0010
`define ALU_OP_AND        4'b0011
`define ALU_OP_OR         4'b0100
`define ALU_OP_XOR        4'b0101
`define ALU_OP_SLL        4'b0110
`define ALU_OP_SRL        4'b0111
`define ALU_OP_SRA        4'b1000
`define ALU_OP_SEQ        4'b1001
`define ALU_OP_SNE        4'b1010
`define ALU_OP_SLT        4'b1011
`define ALU_OP_SGE        4'b1100
`define ALU_OP_SLTU       4'b1101
`define ALU_OP_SGEU       4'b1110
//***********************  Inst related define  ***********************
// 1. AluOp
// a.IMM-OP
`define EXE_ADDI_OP      9'b001000000
`define EXE_SUBI_OP      9'b001000001
`define EXE_SLLI_OP      9'b001000010
`define EXE_SLTI_OP      9'b001000100
`define EXE_SLTIU_OP     9'b001000110
`define EXE_XORI_OP      9'b001001000
`define EXE_SRLI_OP      9'b001001010
`define EXE_SRAI_OP      9'b001001011
`define EXE_ORI_OP       9'b001001100
`define EXE_ANDI_OP      9'b001001110
`define EXE_JAL_OP       9'b110110000
`define EXE_JALR_OP      9'b110010000 
`define EXE_BEQ_OP       9'b110000000
`define EXE_BNE_OP       9'b110000010
`define EXE_BLT_OP       9'b110001000
`define EXE_BGE_OP       9'b110001010
`define EXE_BLTU_OP      9'b110001100
`define EXE_BGEU_OP      9'b110001110

// b.OP-OP
`define EXE_ADD_OP        9'b011000000
`define EXE_SUB_OP        9'b011000001
`define EXE_SLL_OP        9'b011000010
`define EXE_SLT_OP        9'b011000100
`define EXE_SLTU_OP       9'b011000110
`define EXE_XOR_OP        9'b011001000
`define EXE_SRL_OP        9'b011001010
`define EXE_SRA_OP        9'b011001011
`define EXE_OR_OP         9'b011001100
`define EXE_AND_OP        9'b011001110

// c.LUI & AUIPC
`define EXE_LUI_OP        9'b011010000
`define EXE_AUIPC_OP      9'b001010000

// d.LOAD & STORE
`define EXE_LB_OP          9'b000000001
`define EXE_LH_OP          9'b000000010
`define EXE_LW_OP          9'b000000100
`define EXE_LBU_OP         9'b000001000
`define EXE_LHU_OP         9'b000001010
`define EXE_SB_OP          9'b010000000
`define EXE_SH_OP          9'b010000010
`define EXE_SW_OP          9'b010000100

//`define EXE_OR_OP         8'b00100101
`define EXE_NOP_OP        9'b000000000

// 2. AluSel
`define EXE_RES_NOP        3'b000
`define EXE_RES_LOGIC      3'b001
`define EXE_RES_ARITH      3'b010
`define EXE_RES_SHIFT      3'b011
`define EXE_RES_JUMP       3'b100
`define EXE_RES_LOAD_STORE 3'b101


//********************** ROM related define ***************************
`define InstAddrBus       31:0            // ROM 的地址总线宽度
`define InstBus           31:0            // ROM 的数据总线宽度
`define InstMemNum        128             // ROM 的实际大小为<del>32KB<\del>
`define InstMemNumLog2    7               // ROM 实际使用的地址线宽度


//****************** global REG regfile related define ****************
`define RegAddrBus        4:0             // Regfile 模块的地址线宽度
`define RegBus            31:0            // Regfile 模块的数据线宽度
`define RegWidth          32              // 通用寄存器的宽度
`define DoubleRegWidth    64              // 两倍的通用寄存器的宽度
`define DoubleRegBus      63:0            // 两倍的通用寄存器的数据线宽度
`define RegNum            32              // 通用寄存器的数量
`define RegNumLog2        5               // 寻址通用寄存器使用的地址位数
`define NOPRegAddr        5'b00000

//==================  Instruction opcode in RISC-V ================== 
`define OP_LUI      7'b0110111
`define OP_AUIPC    7'b0010111
`define OP_JAL      7'b1101111
`define OP_JALR     7'b1100111
`define OP_BRANCH   7'b1100011
`define OP_LOAD     7'b0000011
`define OP_STORE    7'b0100011
`define OP_OP_IMM   7'b0010011
`define OP_OP       7'b0110011
`define OP_MISC_MEM 7'b0001111

//================== Instruction funct3 in RISC-V ================== 
// JALR
`define FUNCT3_JALR 3'b000
// BRANCH
`define FUNCT3_BEQ  3'b000
`define FUNCT3_BNE  3'b001
`define FUNCT3_BLT  3'b100
`define FUNCT3_BGE  3'b101
`define FUNCT3_BLTU 3'b110
`define FUNCT3_BGEU 3'b111
// LOAD
`define FUNCT3_LB   3'b000
`define FUNCT3_LH   3'b001
`define FUNCT3_LW   3'b010
`define FUNCT3_LBU  3'b100
`define FUNCT3_LHU  3'b101
// STORE
`define FUNCT3_SB   3'b000
`define FUNCT3_SH   3'b001
`define FUNCT3_SW   3'b010
// OP-IMM
`define FUNCT3_ADDI      3'b000
`define FUNCT3_SLLI      3'b001
`define FUNCT3_SLTI      3'b010
`define FUNCT3_SLTIU     3'b011
`define FUNCT3_XORI      3'b100
`define FUNCT3_SRLI_SRAI 3'b101
`define FUNCT3_ORI       3'b110
`define FUNCT3_ANDI      3'b111
// OP
`define FUNCT3_ADD     3'b000
`define FUNCT3_SLL     3'b001
`define FUNCT3_SLT     3'b010
`define FUNCT3_SLTU    3'b011
`define FUNCT3_XOR     3'b100
`define FUNCT3_SRL_SRA 3'b101
`define FUNCT3_OR      3'b110
`define FUNCT3_AND     3'b111
// MISC-MEM
`define FUNCT3_FENCE  3'b000
`define FUNCT3_FENCEI 3'b001

//================== Instruction funct7 in RISC-V ================== 
`define FUNCT7_SLLI 7'b0000000
// SRLI_SRAI
`define FUNCT7_SRLI 7'b0000000
`define FUNCT7_SRAI 7'b0100000
// ADD_SUB
`define FUNCT7_ADD  7'b0000000
`define FUNCT7_SUB  7'b0100000
`define FUNCT7_SLL  7'b0000000
`define FUNCT7_SLT  7'b0000000
`define FUNCT7_SLTU 7'b0000000
`define FUNCT7_XOR  7'b0000000
// SRL_SRA
`define FUNCT7_SRL 7'b0000000
`define FUNCT7_SRA 7'b0100000
`define FUNCT7_OR  7'b0000000
`define FUNCT7_AND 7'b0000000
