`include "define.v"
module mem_wb (
	input wire clk,
	input wire rst,

	// from mem
	input wire[`RegAddrBus]  mem_wd,
	input wire               mem_wreg,
	input wire[`RegBus]      mem_wdata,

	// from ctrl (stall)
	input wire[5:0]          stall,

	// to wb
	output reg[`RegAddrBus]  wb_wd,
	output reg               wb_wreg,
	output reg[`RegBus]      wb_wdata
);

	always @ (posedge clk) begin
		if (rst == `RstEnable) begin
			wb_wd <= `NOPRegAddr;
			wb_wreg <= `WriteDisable;
			wb_wdata <= `ZeroWord;
		end else if (stall[4] == `Stop && stall[5] == `NoStop) begin
			wb_wd <= `NOPRegAddr;
			wb_wreg <= `WriteDisable;
			wb_wdata <= `ZeroWord;
		end else if (stall[4] == `NoStop) begin
			wb_wd <= mem_wd;
			wb_wreg <= mem_wreg;
			wb_wdata <= mem_wdata;
		end
	end
endmodule
