`timescale 1ns/1ps
`include"headfile.v"

module M_CPU(
	input reset,
	input clk,
	input mem_clk
);

	wire [15:0] ir;
	wire [15:0] dr;
	wire [15:0] i_addr;
	wire [15:0] d_addr;
	wire rw;
	wire dw_data;
	

	Pipeline p(
		.reset(reset),
		.clk(clk),
		.ir(ir),
		.dr(dr),
		
		.i_addr(i_addr),
		.d_addr(d_addr),
		.rw(rw),
		.dw_data(dw_data)
	);

	Memory m(
		.reset(reset),
		.mem_clk(mem_clk),
		.i_addr(i_addr),
		.d_addr(d_addr),
		.rw(rw),
		.dw_data(dw_data),

		.ir(ir),
		.dr(dr)
	);

endmodule

