`include "define.v"
module ex (
	input wire             rst,
	// from id to ex
	input wire[`AluOpBus]  aluop_i,
	input wire[`AluSelBus] alusel_i,
	input wire[`RegBus]    reg1_i,
	input wire[`RegBus]    reg2_i,
	input wire[`RegAddrBus] wd_i,
	input wire              wreg_i,

	input wire[`RegBus]     link_addr_i,

	// result of ex
	output reg[`RegAddrBus] wd_o,
	output reg              wreg_o,
	output reg[`RegBus]     wdata_o,

	// forwarding to id
	output reg              ex_wreg_o,
	output reg[`RegBus]     ex_wdata_o,
	output reg[`RegAddrBus] ex_wd_o,
	
	output reg[5:0]         stallreq
);

	reg [`ALU_OP_WIDTH-1:0] opcode;
	wire [`RegBus]           answer;
	alu alu0(opcode, reg1_i, reg2_i, answer);

	always @ (*) begin
		if (rst == `RstEnable) begin
			opcode <= `ALU_OP_NOP;
		end else begin
			opcode <= `ALU_OP_NOP;
			case (aluop_i)
				`EXE_AUIPC_OP             :  opcode <= `ALU_OP_ADD;
				`EXE_ADDI_OP,  `EXE_ADD_OP:  opcode <= `ALU_OP_ADD;
				`EXE_SUBI_OP,  `EXE_SUB_OP:  opcode <= `ALU_OP_SUB;
				`EXE_SLLI_OP,  `EXE_SLL_OP:  opcode <= `ALU_OP_SLL;
				`EXE_SRLI_OP,  `EXE_SRL_OP:  opcode <= `ALU_OP_SRL;
				`EXE_SRAI_OP,  `EXE_SRA_OP:  opcode <= `ALU_OP_SRA;
				`EXE_SLTI_OP,  `EXE_SLT_OP:  opcode <= `ALU_OP_SLT;
				`EXE_SLTIU_OP, `EXE_SLTU_OP: opcode <= `ALU_OP_SLTU;
				`EXE_ANDI_OP,  `EXE_AND_OP:  opcode <= `ALU_OP_AND;
				`EXE_ORI_OP ,  `EXE_OR_OP :  opcode <= `ALU_OP_OR;
				`EXE_XORI_OP,  `EXE_XOR_OP:  opcode <= `ALU_OP_XOR;
				default:begin
				end
			endcase
		end
	end

	always @ (*) begin
		if (rst == `RstEnable) begin
			wd_o <= `NOPRegAddr;
			wreg_o <= 1'b0;
			wdata_o <= `ZeroWord;
			ex_wreg_o <= `NOPRegAddr;
			ex_wd_o <= 1'b0;
			ex_wdata_o <= `ZeroWord;
		end else begin
			wd_o <= `NOPRegAddr;
			wreg_o <= 1'b0;
			wdata_o <= `ZeroWord;
			ex_wreg_o <= `NOPRegAddr;
			ex_wd_o <= 1'b0;
			ex_wdata_o <= `ZeroWord;
			case (alusel_i)
				`EXE_RES_LOGIC, `EXE_RES_ARITH,`EXE_RES_SHIFT:begin
					wd_o <= wd_i;
					wreg_o <= wreg_i;
					ex_wd_o <= wd_i;
					ex_wreg_o <= wreg_i;
					wdata_o <= answer;
					ex_wdata_o <= answer;
				end
				`EXE_RES_NOP:begin
					wd_o <= wd_i;
					wreg_o <= wreg_i;
					ex_wd_o <= wd_i;
					ex_wreg_o <= wreg_i;
					wdata_o <= reg1_i;
					ex_wdata_o <= reg1_i;
				end
				`EXE_RES_JUMP:begin
					wd_o <= wd_i;
					wreg_o <= wreg_i;
					ex_wreg_o <= wreg_i;
					ex_wd_o <= wd_i;
					wdata_o <= link_addr_i;
					ex_wdata_o <= link_addr_i;
				end
				default: begin
					wdata_o <= `ZeroWord;
					ex_wdata_o <= `ZeroWord;
				end
			endcase
		end
	end

endmodule
