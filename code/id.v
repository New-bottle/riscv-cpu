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

	input wire [`AluOpBus]    ex_aluop_i,

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
	output wire[`RegBus]      inst_o, // (for load/store)

	// jump & branch operation
	output reg                branch_flag_o,
	output reg[`RegBus]       branch_target_address_o,
	output reg[`RegBus]       link_addr_o,

	// stall
	output wire               stallreq
);

reg stallreq_for_reg1_loadrelate;
reg stallreq_for_reg2_loadrelate;
wire pre_inst_is_load;
assign pre_inst_is_load = ((ex_aluop_i == `EXE_LB_OP)  ||
						   (ex_aluop_i == `EXE_LBU_OP) ||
						   (ex_aluop_i == `EXE_LH_OP)  ||
                           (ex_aluop_i == `EXE_LHU_OP) ||
						   (ex_aluop_i == `EXE_LW_OP)) ? 1'b1 : 1'b0;

always @ (*) begin
	stallreq_for_reg1_loadrelate <= `NoStop;
	if (rst == `RstEnable) begin
		stallreq_for_reg1_loadrelate <= `NoStop;
	end else if (pre_inst_is_load == 1'b1 && ex_wd_i == reg1_addr_o
		&& reg1_read_o == 1'b1) begin
		stallreq_for_reg1_loadrelate <= `Stop;
	end else begin
		stallreq_for_reg1_loadrelate <= `NoStop;
	end
end

always @ (*) begin
	stallreq_for_reg2_loadrelate <= `NoStop;
	if (rst == `RstEnable) begin
		stallreq_for_reg2_loadrelate <= `NoStop;
	end else if (pre_inst_is_load == 1'b1 && ex_wd_i == reg2_addr_o
		&& reg2_read_o == 1'b1) begin
		stallreq_for_reg2_loadrelate <= `Stop;
	end else begin
		stallreq_for_reg2_loadrelate <= `NoStop;
	end
end
assign inst_o = inst_i;

// 取得指令的指令码，功能码
wire [6:0] op = inst_i[6:0];
wire [2:0] funct3 = inst_i[14:12];
wire [6:0] funct7 = inst_i[31:25];

// 保存指令执行需要的立即数
reg[`RegBus]   imm;

// 指示指令是否有效
reg instvalid;

reg [`ALU_OP_WIDTH-1:0] opcode;
wire [`RegBus]          answer;
alu alu0(opcode, reg1_o, reg2_o, answer);

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
		imm         <= 32'b0;
	end else begin
		branch_target_address_o <= `ZeroWord;
		branch_flag_o <= 1'b0;
		case (op)

			`OP_OP_IMM:begin // can't deal with undefined behavior
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
				alusel_o <= `EXE_RES_ARITH;
				reg1_read_o <= 1'b0;
				reg2_read_o <= 1'b0;
				reg1_addr_o <= `NOPRegAddr;
				reg2_addr_o <= `NOPRegAddr;
				wreg_o <= `WriteEnable;
				wd_o <= inst_i[11:7];
				instvalid <= `InstValid;
				imm <= {inst_i[31:12], 12'b0};
			end

			`OP_JAL:begin
				aluop_o <= `EXE_JAL_OP;
				alusel_o <= `EXE_RES_JUMP;
				wd_o <= inst_i[11:7];
				wreg_o <= `WriteEnable;
				instvalid <= `InstValid;
				reg1_read_o <= 1'b0;
				reg2_read_o <= 1'b0;
				reg1_addr_o <= `NOPRegAddr;
				reg2_addr_o <= `NOPRegAddr;
				link_addr_o <= pc_i + 4;
				imm <= `ZeroWord;
				branch_target_address_o <= 
//					{{12{inst_i[31]}},inst_i[30:12],{1'b0}};
					pc_i + {{12{inst_i[31]}},inst_i[19:12],inst_i[20],inst_i[30:21],{1'b0}};
				branch_flag_o <= 1'b1;
			end

			`OP_JALR:begin
				aluop_o <= `EXE_JALR_OP;
				alusel_o <= `EXE_RES_JUMP;
				wd_o <= inst_i[11:7];
				wreg_o <= `WriteEnable;
				instvalid <= `InstValid;
				reg1_read_o <= 1'b1;
				reg2_read_o <= 1'b0;
				reg1_addr_o <= inst_i[19:15];
				reg2_addr_o <= `NOPRegAddr;
				link_addr_o <= pc_i + 4;
				imm <= `ZeroWord;
				branch_target_address_o <= 
					reg1_o + {{21{inst_i[31]}}, inst_i[30:20]};
				branch_flag_o <= 1'b1;
			end

			`OP_BRANCH:begin
				alusel_o <= `EXE_RES_JUMP;
				wd_o <= `NOPRegAddr;
				wreg_o <= `WriteDisable;
				instvalid <= `InstValid;
				reg1_read_o <= 1'b1;
				reg2_read_o <= 1'b1;
				reg1_addr_o <= inst_i[19:15];
				reg2_addr_o <= inst_i[24:20];
				imm <= {{19{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
				link_addr_o <= `ZeroWord;
				branch_flag_o <= 1'b0;
				case (funct3)
					`FUNCT3_BEQ:begin
						aluop_o <= `EXE_BEQ_OP;
						opcode <= `ALU_OP_SEQ;
						if (answer == `TRUE32) begin
							branch_target_address_o <= pc_i + imm;
							branch_flag_o <= 1'b1;
						end
					end
					`FUNCT3_BNE:begin
						aluop_o <= `EXE_BNE_OP;
						opcode <= `ALU_OP_SNE;
						if (answer == `TRUE32) begin
							branch_target_address_o <= pc_i + imm;
							branch_flag_o <= 1'b1;
						end
					end
					`FUNCT3_BLT:begin
						aluop_o <= `EXE_BLT_OP;
						opcode <= `ALU_OP_SLT;
						if (answer == `TRUE32) begin
							branch_target_address_o <= pc_i + imm;
							branch_flag_o <= 1'b1;
						end
					end
					`FUNCT3_BGE:begin
						aluop_o <= `EXE_BGE_OP;
						opcode <= `ALU_OP_SGE;
						if (answer == `TRUE32) begin
							branch_target_address_o <= pc_i + imm;
							branch_flag_o <= 1'b1;
						end
					end
					`FUNCT3_BLTU:begin
						aluop_o <= `EXE_BLTU_OP;
						opcode <= `ALU_OP_SLTU;
						if (answer == `TRUE32) begin
							branch_target_address_o <= pc_i + imm;
							branch_flag_o <= 1'b1;
						end
					end
					`FUNCT3_BGEU:begin
						aluop_o <= `EXE_BGEU_OP;
						opcode <= `ALU_OP_SGEU;
						if (answer == `TRUE32) begin
							branch_target_address_o <= pc_i + imm;
							branch_flag_o <= 1'b1;
						end
					end
					default:begin
					end
				endcase
			end

			`OP_LOAD:begin
				reg1_read_o <= 1'b1;
				reg2_read_o <= 1'b0;
				reg1_addr_o <= inst_i[19:15];
				reg2_addr_o <= `NOPRegAddr;
				wreg_o <= `WriteEnable;
				wd_o <= inst_i[11:7];
				instvalid <= `InstValid;
				imm <= {{21{inst_i[31]}}, inst_i[30:20]};
				alusel_o <= `EXE_RES_LOAD_STORE;
				case (funct3)
					`FUNCT3_LB:  begin
						aluop_o <= `EXE_LB_OP;
					end
					`FUNCT3_LH:  begin
						aluop_o <= `EXE_LH_OP;
					end
					`FUNCT3_LW:  begin
						aluop_o <= `EXE_LW_OP;
					end
					`FUNCT3_LBU: begin
						aluop_o <= `EXE_LBU_OP;
					end
					`FUNCT3_LHU: begin
						aluop_o <= `EXE_LHU_OP;
					end
				endcase
			end

			`OP_STORE:begin
				reg1_read_o <= 1'b1;
				reg2_read_o <= 1'b1;
				reg1_addr_o <= inst_i[19:15];
				reg2_addr_o <= inst_i[24:20];
				wreg_o <= `WriteDisable;
				wd_o <= `NOPRegAddr;
				instvalid <= `InstValid;
//				imm <= {{21{inst_i[31]}}, inst_i[30:25], inst_i[11:7]}; // ex阶段另算
				alusel_o <= `EXE_RES_LOAD_STORE;
				case (funct3)
					`FUNCT3_SB:  begin
						aluop_o <= `EXE_SB_OP;
					end
					`FUNCT3_SH:  begin
						aluop_o <= `EXE_SH_OP;
					end
					`FUNCT3_SW:  begin
						aluop_o <= `EXE_SW_OP;
					end
				endcase
			end
			default:begin
				aluop_o <= `EXE_NOP_OP;
				alusel_o <= `EXE_RES_NOP;
				wd_o <= `NOPRegAddr;
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
				  && (ex_wd_i == reg1_addr_o) && ex_wd_i != `RegNumLog2'b0) begin
		reg1_o <= ex_wdata_i;
	end else if ((reg1_read_o == 1'b1) && (mem_wreg_i == 1'b1)
				  && (mem_wd_i == reg1_addr_o) && mem_wd_i != `RegNumLog2'b0) begin
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
	end else if (op == `OP_AUIPC) begin
		reg2_o <= pc_i;
	end else if ((reg2_read_o == 1'b1) && (ex_wreg_i == 1'b1)
				  && (ex_wd_i == reg2_addr_o) && ex_wd_i != `RegNumLog2'b0) begin
		reg2_o <= ex_wdata_i;
	end else if ((reg2_read_o == 1'b1) && (mem_wreg_i == 1'b1)
				  && (mem_wd_i == reg2_addr_o) && mem_wd_i != `RegNumLog2'b0) begin
		reg2_o <= mem_wdata_i;
	end else if (reg2_read_o == 1'b1) begin
		reg2_o <= reg2_data_i;
	end else if (reg2_read_o == 1'b0) begin
		reg2_o <= imm;
	end else begin
		reg2_o <= `ZeroWord;
	end
end

assign stallreq = stallreq_for_reg1_loadrelate | stallreq_for_reg2_loadrelate;

endmodule
