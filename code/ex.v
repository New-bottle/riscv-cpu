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

	// result of ex
	output reg[`RegAddrBus] wd_o,
	output reg              wreg_o,
	output reg[`RegBus]     wdata_o,

	// forwarding to id
	output reg              ex_wreg_o,
	output reg[`RegBus]     ex_wdata_o,
	output reg[`RegAddrBus] ex_wd_o
);

	reg[`RegBus]            logicout;
	reg[`RegBus]            arithout;
	reg[`RegBus]            shiftres;


	// logic
	always @ (*) begin
		if (rst == `RstEnable) begin
			logicout <= `ZeroWord;
		end else begin
			case (aluop_i)
				`EXE_ANDI_OP, `EXE_AND_OP:begin
					logicout <= reg1_i & reg2_i;
				end
				`EXE_ORI_OP, `EXE_OR_OP:begin
					logicout <= reg1_i | reg2_i;
				end
				`EXE_XORI_OP, `EXE_XOR_OP:begin
					logicout <= reg1_i ^ reg2_i;
				end
				default:   begin
					logicout <= `ZeroWord;
				end
			endcase
		end
	end

	// arithmetic
	wire [`RegBus] reg2_i_mux;
	wire [`RegBus] result_sum;
	wire reg1_lt_reg2;
	assign reg2_i_mux = ((aluop_i == `EXE_SUB_OP) || 
						 (aluop_i == `EXE_SUBI_OP) ||
						 (aluop_i == `EXE_SLT_OP)) ? 
						 (~reg2_i)+1 : reg2_i;
	assign result_sum = reg1_i + reg2_i_mux;
	assign reg1_lt_reg2 = ((aluop_i == `EXE_SLT_OP) || aluop_i == `EXE_SLTI_OP) ? 
						((reg1_i[31] && !reg2_i[31]) ||
						(!reg1_i[31] && !reg2_i[31] && result_sum[31]) ||
						(reg1_i[31] && reg2_i[31] && result_sum[31]))
						:(reg1_i < reg2_i);
	always @ (*) begin
		if (rst == `RstEnable) begin
			arithout <= `ZeroWord;
		end else begin
			case (aluop_i)
				`EXE_ADDI_OP, `EXE_ADD_OP:begin
					arithout <= result_sum;
				end
				`EXE_SUBI_OP, `EXE_SUB_OP:begin
					arithout <= result_sum;
				end
				`EXE_SLTI_OP, `EXE_SLT_OP, `EXE_SLTIU_OP:begin
					arithout <= reg1_lt_reg2;
				end
				default:begin
				end
			endcase
		end
	end

	// shift
	always @ (*) begin 
		if (rst == `RstEnable) begin
			shiftres <= `ZeroWord;
		end else begin
			case (aluop_i)
				`EXE_SLLI_OP, `EXE_SLL_OP:begin
					shiftres <= reg1_i << reg2_i[4:0];
				end
				`EXE_SRLI_OP, `EXE_SRL_OP:begin
					shiftres <= reg1_i >> reg2_i[4:0];
				end
				`EXE_SRAI_OP, `EXE_SRA_OP:begin
					shiftres <= ({32{reg1_i[31]}}<<(6'd32-{1'b0,reg2_i[5:0]}))
								| reg1_i >> reg2_i[4:0];
				end
				default:begin
					shiftres <= `ZeroWord;
				end
			endcase
		end
	end

	always @ (*) begin
		wd_o <= wd_i;
		wreg_o <= wreg_i;
		ex_wreg_o <= wreg_i;
		ex_wd_o <= wd_i;
		case (alusel_i)
			`EXE_RES_LOGIC:begin
				wdata_o <= logicout;
				ex_wdata_o <= logicout;
			end
			`EXE_RES_ARITH:begin
				wdata_o <= arithout;
				ex_wdata_o <= arithout;
			end
			`EXE_RES_SHIFT:begin
				wdata_o <= shiftres;
				ex_wdata_o <= shiftres;
			end
			`EXE_RES_NOP:begin
				wdata_o <= reg1_i;
				ex_wdata_o <= reg1_i;
			end
			default: begin
				wdata_o <= `ZeroWord;
				ex_wdata_o <= `ZeroWord;
			end
		endcase
	end

endmodule
