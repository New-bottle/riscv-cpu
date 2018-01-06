`include "define.v"
`include "openmips.v"
`include "inst_rom.v"

module openmips_min_sopc (
	input wire       clk,
	input wire       rst
);

	wire [`InstAddrBus] inst_addr;
	wire [`InstBus]     inst_o, inst_i;
	wire                rom_ce;

	wire[`RegBus] mem_addr_i;
	wire[`RegBus] mem_data_i;
	wire[`RegBus] mem_data_o;
	wire[3:0] mem_sel_i;
	wire mem_ce_i;

	assign inst_i[7:0] = inst_o[31:24];
	assign inst_i[15:8] = inst_o[23:16];
	assign inst_i[23:16] = inst_o[15:8];
	assign inst_i[31:24] = inst_o[7:0];
	/*
	assign inst_i[`InstBus/4*1-1:`InstBus/4*0] = inst_o[`InstBus/4*4-1:`InstBus/4*3];
	assign inst_i[`InstBus/4*2-1:`InstBus/4*1] = inst_o[`InstBus/4*3-1:`InstBus/4*2];
	assign inst_i[`InstBus/4*3-1:`InstBus/4*2] = inst_o[`InstBus/4*2-1:`InstBus/4*1];
	assign inst_i[`InstBus/4*4-1:`InstBus/4*3] = inst_o[`InstBus/4*1-1:`InstBus/4*0];
	*/

	openmips openmips0 (
		.clk(clk), .rst(rst),

		.rom_addr_o(inst_addr),
		.rom_data_i(inst_i),
		.rom_ce_o(rom_ce),

		.ram_we_o(mem_we_i),
		.ram_addr_o(mem_addr_i),
		.ram_sel_o(mem_sel_i),
		.ram_data_o(mem_data_i),
		.ram_data_i(mem_data_o),
		.ram_ce_o(mem_ce_i)	
	);

	inst_rom inst_rom0 (
		.ce(rom_ce),
		.addr(inst_addr), .inst(inst_o)
	);

	data_ram data_ram0(
		.clk(clk),
		.ce(mem_ce_i),
		.we(mem_we_i),
		.addr(mem_addr_i),
		.sel(mem_sel_i),
		.data_i(mem_data_i),
		.data_o(mem_data_o)	
	);
endmodule
