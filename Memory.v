`timescale 1ns/1ps
`include"headfile.v"

module Memory(
	input reset,
	input mem_clk,

	input [7:0] i_addr,
        output wire [15:0] ir,

        input [7:0] d_addr,
	input rw,
	input [16:0] dw_data,
	output wire [15:0] dr
	);

	reg [15:0] i_mem [0:63];	
	reg [15:0] d_mem [0:255];
	reg [15:0] dw_buf;

	// instruction read
	assign ir = i_mem[i_addr];

	// instruction list
	always @(posedge reset)
	begin
		i_mem[0] <= {`ADDI, `gr1, 4'b0000, 4'b0100}; 		//g1 = 4
		i_mem[1] <= {`ADDI, `gr2, 4'b0000, 4'b0101}; 		//g2 = 5
		i_mem[2] <= {`ADDI, `gr0, 4'b0000, 4'b0000}; 		//g0 = 0
		i_mem[3] <= {`ADDI, `gr0, 4'b0000, 4'b0000}; 		// (4 bubbles)
		i_mem[4] <= {`ADDI, `gr0, 4'b0000, 4'b0000};  		//
		i_mem[5] <= {`ADDI, `gr0, 4'b0000, 4'b0000}; 		// 
		i_mem[6] <= {`ADD, `gr3, 1'b0, `gr1, 1'b0, `gr2};	//g3 = g1 + g2
		i_mem[7] <= {`JZ, `gr3, 4'b0000, 4'b0000}; 		//goto 0
		i_mem[8] <= {`ADDI, `gr0, 4'b0000, 4'b0000}; 		// (4 bubbles)
		i_mem[9] <= {`ADDI, `gr0, 4'b0000, 4'b0000};  		//
		i_mem[10] <= {`ADDI, `gr0, 4'b0000, 4'b0000}; 		//


	end

	// memory read
	assign dr = d_mem[d_addr];	// CPU have to wait when instant read not available.

	//memory write
	always @(posedge mem_clk)
	begin
		dw_buf = dw_data;	//
		if (rw)
			d_mem[d_addr] <= dw_buf;
	end


endmodule
