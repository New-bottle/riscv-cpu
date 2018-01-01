`include "define.v"
module mem (
	input wire          rst,

	// ex -> mem
	input wire[`RegAddrBus] wd_i,
	input wire              wreg_i,
	input wire[`RegBus]     wdata_i,

	// mem -> wb
	output reg[`RegAddrBus] wd_o,
	output reg              wreg_o,
	output reg[`RegBus]     wdata_o,

	// forwarding -> id
	output reg[`RegAddrBus] mem_wd_o,
	output reg              mem_wreg_o,
	output reg[`RegBus]     mem_wdata_o
);

	always @ (*) begin
		if (rst == `RstEnable) begin
			wd_o <= `NOPRegAddr;
			wreg_o <= `WriteDisable;
			wdata_o <= `ZeroWord;
			mem_wd_o <= `NOPRegAddr;
			mem_wreg_o <= `WriteDisable;
			mem_wdata_o <= `ZeroWord;
		end else begin
			wd_o <= wd_i;
			wreg_o <= wreg_i;
			wdata_o <= wdata_i;
			mem_wd_o <= wd_i;
			mem_wreg_o <= wreg_i;
			mem_wdata_o <= wdata_i;
		end
	end

endmodule
