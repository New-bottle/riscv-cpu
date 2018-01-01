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
	output reg[`RegBus]     wdata_o
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
	reg [`RegBus] reg2_i_mux;
	reg [`RegBus] result_sum;
	assign reg2_i_mux = ((sel2_i == `FUNCT7_SUB) || 
						 (aluop_i == `FUNCT3_SLT)) ? 
						 (~reg2_i) + 1 : reg2_i;
	assign result_sum = reg1_i + reg2_i_mux;
	assign 
	always @ (*) begin
		if (rst == `RstEnable) begin
			arithout <= `ZeroWord;
		end else begin
			case (aluop_i)
				`FUNCT3_ADDI:begin
					arithout <= reg1_i + reg2_i;
				end
				`FUNCT3_SLLI:begin
					arithout <= reg1_i << reg2_i;
				end
				`FUNCT3_SLTI:begin
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
					shiftres <= reg1_o >> reg2_i[4:0];
				end
				`EXE_SRAI_OP, `EXE_SRA_OP:begin
					shiftres <= ({32{reg2_i[31]}}<<(6'd32-{1'b0,reg1_i[5:0]}))
								| reg2_i >> reg1_i[4:0];
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
		case (alusel_i)
			`EXE_:begin
				wdata_o <= 
			end
			`OP_OP: begin
				wdata_o <= logicout;
			end
			default: begin
				wdata_o <= `ZeroWord;
			end
		endcase
	end

endmodule
