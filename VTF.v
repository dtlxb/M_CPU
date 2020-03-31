`timescale 1ns/1ps
`include"headfile.v"

module VTF;

	reg reset;
	reg clk;
	reg mem_clk;

	M_CPU mcpu(
		.reset(reset),
		.clk(clk),
		.mem_clk(mem_clk)
	);

	initial begin
		reset = 0;
		clk = 0;
		mem_clk = 0;

	#10
	#10 reset = 1;
	#10 reset = 0;
	end

	always #10 clk = ~clk;
	always #25 mem_clk = ~mem_clk;

endmodule
	