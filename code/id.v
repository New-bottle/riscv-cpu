`include "define.v"

module id (
	input wire                rst,
	input wire [`InstAddrBus] pc_i,
	input wire [`InstBus]     inst_i,

	// 读取的Regfile的值
	input wire [`RegBus]      reg1_data_i,
	input wire [`RegBus]      reg2_data_i,

	// EX-forwarding
	input wire                ex_wreg_i,
	input wire [`RegBus]      ex_wdata_i,
	input wire [`RegAddrBus]  ex_wd_i,

	// MEM-forwarding
	input wire                mem_wreg_i,
	input wire [`RegBus]      mem_wdata_i,
	input wire [`RegAddrBus]  mem_wd_i,

	// 输出到Regfile的信息
	output reg                reg1_read_o,
	output reg                reg2_read_o,
	output reg[`RegAddrBus]   reg1_addr_o,
	output reg[`RegAddrBus]   reg2_addr_o,

	// 送到执行阶段的信息
	output reg[`AluOpBus]     aluop_o,
	output reg[`AluSelBus]    alusel_o,
	output reg[`RegBus]       reg1_o,
	output reg[`RegBus]       reg2_o,
	output reg[`RegAddrBus]   wd_o,
	output reg                wreg_o,

	output wire               stallreq
);

// 取得指令的指令码，功能码
wire [6:0] op = inst_i[6:0];
wire [2:0] funct3 = inst_i[14:12];
wire [6:0] funct7 = inst_i[31:25];

// 保存指令执行需要的立即数
reg[`RegBus]   imm;

// 指示指令是否有效
reg instvalid;

assign stallreq = `NoStop;

// Part1: Instruction Decode
always @ (*) begin
	if (rst == `RstEnable) begin
		aluop_o <= `EXE_NOP_OP;
		alusel_o <= `EXE_RES_NOP;
		wd_o <= `NOPRegAddr;
		wreg_o <=`WriteDisable;
		instvalid <= `InstValid;
		reg1_read_o <= 1'b0;
		reg2_read_o <= 1'b0;
		reg1_addr_o <= `NOPRegAddr;
		reg2_addr_o <= `NOPRegAddr;
		imm         <= 32'h0;
	end else begin
		case (op)
			`OP_OP_IMM:begin
				reg1_read_o <= 1'b1;
				reg2_read_o <= 1'b0;
				reg1_addr_o <= inst_i[19:15];
				reg2_addr_o <= `NOPRegAddr;
				wreg_o <= `WriteEnable;
				wd_o <= inst_i[11:7];
				instvalid <= `InstValid;
				imm <= {{21{inst_i[31]}}, inst_i[30:20]};
				case (funct3)
					`FUNCT3_ADDI:begin
						case (funct7)
							`FUNCT7_ADD:begin
								aluop_o <= `EXE_ADDI_OP;
								alusel_o <= `EXE_RES_ARITH;
							end
							`FUNCT7_SUB:begin
								aluop_o <= `EXE_SUBI_OP;
								alusel_o <= `EXE_RES_ARITH;
							end
							default:begin
							end
						endcase
					end
					`FUNCT3_SLTI:begin
						aluop_o <= `EXE_SLTI_OP;
						alusel_o <= `EXE_RES_ARITH;
					end
					`FUNCT3_SLTIU:begin
						aluop_o <= `EXE_SLTIU_OP;
						alusel_o <= `EXE_RES_ARITH;
					end
					`FUNCT3_XORI:begin
						aluop_o <= `EXE_XORI_OP;
						alusel_o <= `EXE_RES_LOGIC;
					end
					`FUNCT3_ORI:begin
						aluop_o <= `EXE_ORI_OP;
						alusel_o <= `EXE_RES_LOGIC;
					end
					`FUNCT3_ANDI:begin
						aluop_o <= `EXE_ANDI_OP;
						alusel_o <= `EXE_RES_LOGIC;
					end
					`FUNCT3_SLLI:begin
						aluop_o <= `EXE_SLLI_OP;
						alusel_o <= `EXE_RES_SHIFT;
					end
					`FUNCT3_SRLI_SRAI:begin
						case (funct7)
							`FUNCT7_SRL:begin
								aluop_o <= `EXE_SRLI_OP;
								alusel_o <= `EXE_RES_SHIFT;
							end
							`FUNCT7_SRA:begin
								aluop_o <= `EXE_SRAI_OP;
								alusel_o <= `EXE_RES_SHIFT;
							end
						endcase
					end
					default:begin
					end
				endcase
			end

			`OP_OP:begin
				reg1_read_o <= 1'b1;
				reg2_read_o <= 1'b1;
				reg1_addr_o <= inst_i[19:15];
				reg2_addr_o <= inst_i[24:20];
				wreg_o <= `WriteEnable;
				wd_o <= inst_i[11:7];
				instvalid <= `InstValid;
				imm <= `ZeroWord;
				case (funct3)
					`FUNCT3_ADD:begin
						case (funct7)
							`FUNCT7_ADD:begin
								aluop_o <= `EXE_ADD_OP;
								alusel_o <= `EXE_RES_ARITH;
							end
							`FUNCT7_SUB:begin
								aluop_o <= `EXE_SUB_OP;
								alusel_o <= `EXE_RES_ARITH;
							end
							default:begin
							end
						endcase
					end
					`FUNCT3_SLT:begin
						aluop_o <= `EXE_SLT_OP;
						alusel_o <= `EXE_RES_ARITH;
					end
					`FUNCT3_SLTU:begin
						aluop_o <= `EXE_SLTIU_OP;
						alusel_o <= `EXE_RES_ARITH;
					end
					`FUNCT3_XOR:begin
						aluop_o <= `EXE_XOR_OP;
						alusel_o <= `EXE_RES_LOGIC;
					end
					`FUNCT3_OR:begin
						aluop_o <= `EXE_OR_OP;
						alusel_o <= `EXE_RES_LOGIC;
					end
					`FUNCT3_AND:begin
						aluop_o <= `EXE_AND_OP;
						alusel_o <= `EXE_RES_LOGIC;
					end
					`FUNCT3_SLL:begin
						aluop_o <= `EXE_SLL_OP;
						alusel_o <= `EXE_RES_SHIFT;
					end
					`FUNCT3_SRL_SRA:begin
						case (funct7)
							`FUNCT7_SRL:begin
								aluop_o <= `EXE_SRL_OP;
								alusel_o <= `EXE_RES_SHIFT;
							end
							`FUNCT7_SRA:begin
								aluop_o <= `EXE_SRA_OP;
								alusel_o <= `EXE_RES_SHIFT;
							end
						endcase
					end
					default:begin
					end
				endcase
			end
			`OP_LUI:begin
				aluop_o <= `EXE_LUI_OP;
				alusel_o <= `EXE_RES_NOP;
				reg1_read_o <= 1'b0;
				reg2_read_o <= 1'b0;
				reg1_addr_o <= `NOPRegAddr;
				reg2_addr_o <= `NOPRegAddr;
				wreg_o <= `WriteEnable;
				wd_o <= inst_i[11:7];
				instvalid <= `InstValid;
				imm <= {inst_i[31:12], 12'b0};
			end
			`OP_AUIPC:begin
				aluop_o <= `EXE_AUIPC_OP;
				alusel_o <= `EXE_RES_NOP;
				reg1_read_o <= 1'b0;
				reg2_read_o <= 1'b0;
				reg1_addr_o <= `NOPRegAddr;
				reg2_addr_o <= `NOPRegAddr;
				wreg_o <= `WriteEnable;
				wd_o <= inst_i[11:7];
				instvalid <= `InstValid;
				imm <= {inst_i[31:12], 12'b0};
			end


			default:begin
				aluop_o <= `EXE_NOP_OP;
				alusel_o <= `EXE_RES_NOP;
				wd_o <= `NOP_RegAddr;
				wreg_o <= `WriteDisable;
				instvalid <= `InstValid;
				reg1_read_o <= 1'b0;
				reg2_read_o <= 1'b0;
				reg1_addr_o <= `NOPRegAddr;
				reg2_addr_o <= `NOPRegAddr;
				imm         <= `ZeroWord;
			end
		endcase
	end
end // always

// Part2: get op number 1
always @ (*) begin
	if (rst == `RstEnable) begin
		reg1_o <= `ZeroWord;
	end else if ((reg1_read_o == 1'b1) && (ex_wreg_i == 1'b1)
				  && (ex_wd_i == reg1_addr_o)) begin
		reg1_o <= ex_wdata_i;
	end else if ((reg1_read_o == 1'b1) && (mem_wreg_i == 1'b1)
				  && (mem_wd_i == reg1_addr_o)) begin
		reg1_o <= mem_wdata_i;
	end else if (reg1_read_o == 1'b1) begin
		reg1_o <= reg1_data_i;
	end else if (reg1_read_o == 1'b0) begin
		reg1_o <= imm;
	end else begin
		reg1_o <= `ZeroWord;
	end
end


// Part3: get op number 2
always @ (*) begin
	if (rst == `RstEnable) begin
		reg2_o <= `ZeroWord;
	end else if ((reg2_read_o == 1'b1) && (ex_wreg_i == 1'b1)
				  && (ex_wd_i == reg2_addr_o)) begin
		reg2_o <= ex_wdata_i;
	end else if ((reg2_read_o == 1'b1) && (mem_wreg_i == 1'b1)
				  && (mem_wd_i == reg2_addr_o)) begin
		reg2_o <= mem_wdata_i;
	end else if (reg2_read_o == 1'b1) begin
		reg2_o <= reg2_data_i;
	end else if (reg2_read_o == 1'b0) begin
		reg2_o <= imm;
	end else begin
		reg2_o <= `ZeroWord;
	end
end

endmodule
