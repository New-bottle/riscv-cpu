//************************** global define ****************************
`define RstEnable         1'b1            // enable reset signal
`define RstDisable        1'b0            // disable reset signal
`define ZeroWord          32'h00000000    // 32-bit value 0
`define WriteEnable       1'b1            // enable writting
`define WriteDisable      1'b0            // disable writting
`define ReadEnable        1'b1            // enable reading
`define ReadDisable       1'b0            // disable reading
`define AluOpBus          7:0             // 译码阶段的输出aluop_o的宽度
`define AluSelBus         2:0             // 译码阶段的输出alusel_o的宽度
`define InstValid         1'b0            // 指令有效
`define InstInvalid       1'b1            // 指令无效
`define True_v            1'b1            // logical true
`define False_v           1'b0            // logical false
`define ChipEnable        1'b1            // 芯片使能
`define ChipDisable       1'b0            // 芯片禁止


//***********************  Inst related define  ***********************
`define EXE_ORI           6'b001101       // 指令ori的指令码
`define EXE_NOP           6'b000000       // NOP inst

//AluOp
`define EXE_OR_OP         8'b00100101
`define EXE_NOP_OP        8'b00000000

//AluSel
`define EXE_RES_LOGIC     3'b001

`define EXE_RES_NOP       3'b000


//********************** ROM related define ***************************
`define InstAddrBus       31:0            // ROM 的地址总线宽度
`define InstBus           31:0            // ROM 的数据总线宽度
`define InstMemNum        4               // ROM 的实际大小为<del>32KB<\del>
`define InstMemNumLog2    2               // ROM 实际使用的地址线宽度


//****************** global REG regfile related define ****************
`define RegAddrBus        4:0             // Regfile 模块的地址线宽度
`define RegBus            31:0            // Regfile 模块的数据线宽度
`define RegWidth          32              // 通用寄存器的宽度
`define DoubleRegWidth    64              // 两倍的通用寄存器的宽度
`define DoubleRegBus      63:0            // 两倍的通用寄存器的数据线宽度
`define RegNum            32              // 通用寄存器的数量
`define RegNumLog2        5               // 寻址通用寄存器使用的地址位数
`define NOPRegAddr        5'b00000
