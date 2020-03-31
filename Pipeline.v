`timescale 1ns/1ps
`include"headfile.v"

module Pipeline(
	input reset,

	input clk,
	input [15:0] ir,
	input [15:0] dr,

	output wire [15:0] i_addr,

        output wire [15:0] d_addr,
	output rw,
	output wire [15:0] dw_data
);
	
	// reg
	reg [15:0] pc;
	reg [15:0] if_ir, id_ir, ie_ir, im_ir, iw_ir;
	reg [15:0] regs [0:7];
	
	reg if_bubble_flag;
	reg if_bubble, id_bubble, ie_bubble, im_bubble, iw_bubble;

	reg [2:0]  regA, regB, regC;
	reg [7:0]  instant;
	reg [15:0] dval1, dval2;

	reg [15:0] ALU1, ALU2, ALUo;
	reg        oddflag;

	reg [15:0] m_dw_data;
	reg [15:0] m_dr_data;
	reg [15:0] m_d_addr;
	reg m_rw;
	reg [15:0] m_ALUo;

	reg [15:0] w_ALUo;
	reg [15:0] wb_data;
	reg [15:0] w_dr_data;
	

	assign i_addr = pc;

	assign dw_data = m_dw_data;
	assign rw = m_rw;
	assign d_addr = m_d_addr;

	always @(posedge reset)
	begin
		regs[0] <= 16'b0000000000000000;
		regs[1] <= 16'b0000000000000000;
		regs[2] <= 16'b0000000000000000;
		regs[3] <= 16'b0000000000000000;
		regs[4] <= 16'b0000000000000000;
		regs[5] <= 16'b0000000000000000;
		regs[6] <= 16'b0000000000000000;
		regs[7] <= 16'b0000000000000000;
	end

	// fetch
	always @(posedge clk or posedge reset)
	begin
		if (reset)
		begin
			pc = 16'b0000000000000000;
			//if_ir = 16'b0000000000000000;
			//if_bubble_flag = 1'b0;
			//if_bubble = 1'b0;
		end
		else 
		begin 
			//clock
			if_ir <= ir;
			id_bubble <= if_bubble; // 
						// first immediately update clock.
						// then do combinational logics slowly.


			// combinational (next clock)
			if ((ir[15:11] == `JZ ) && (if_bubble_flag == 0)) // control hazard
			begin
				pc = pc;
				if_bubble_flag = 1;
				if_bubble <= 1;
			end
			else if ((ir[15:11] == `JZ ) && (if_bubble_flag == 1))
			begin
				if (oddflag == 1) 
				begin
					pc = ir[7:0];
				end
				else 
				begin
					pc = pc + 1'b1;
				end
				if_bubble_flag = 0;
				if_bubble = 0;
				end
			else begin
				if_bubble_flag = 0;
				if_bubble = 0;
				pc = pc + 1'b1;
			end
		
			
		end
	end

	always @(if_ir)
	begin
		
	end

	// decode

	always @(posedge clk or posedge reset)
	begin
		if (reset)
		begin
			id_ir <= 16'b0000000000000000;
			regA <= 3'b000;
			regB <= 3'b000;
			regC <= 3'b000;
			instant <= 8'b00000000;
			dval1 <= 16'b0000000000000000;
			dval2 <= 16'b0000000000000000;
			
			id_bubble <= 0;
		end
		else begin
			//id_bubble <= if_bubble; // don't wait (register)
			id_ir <= if_ir;
			ie_bubble <= id_bubble;
		end
	end

	always @(id_bubble or id_ir)
	begin
		if (id_bubble == 0)
		begin
				// combination (wire)
			if (id_ir[15:11] == `ADD)
			begin
				regA = id_ir[6:4];
				regB = id_ir[2:0];
				regC = id_ir[10:8];
				dval1 = regs[regA];
				dval2 = regs[regB];
				end
			else if (id_ir[15:11] == `ADDI)
			begin
				regA = id_ir[10:8];
				instant = id_ir[7:0];
				dval1 = regs[regA];
				dval2 = instant;
			end
		end
	end
	

	// execute //get regval here
	
	always @(posedge clk or posedge reset)
	begin
		if (reset)
		begin
			ie_ir <= 16'b0000000000000000;
			ALU1 <= 16'b0000000000000000;
			ALU2 <= 16'b0000000000000000;	
			oddflag <= 0;
			ie_bubble <= 0;
		end
		else begin
			//ie_bubble <= id_bubble;
			ie_ir <= id_ir;
			ALU1 <= dval1;
			ALU2 <= dval2;	

			im_bubble <= ie_bubble;
		end
	end

	always @(ie_ir or ie_bubble or ALU1 or ALU2)
	begin
		if (ie_bubble == 0)
		begin
			if ((ie_ir[15:11] == `ADD) || (ie_ir[15:11] == `ADDI))
			begin
				ALUo = ALU1 + ALU2;
		
				if (ALUo[0] == 1'b1) oddflag = 1; 
			end
			else begin
				ALUo = ALU1;
				oddflag = oddflag; // used for testing, keep the value
			end
		end
		else begin
			
		end
	end

	// memory

	always @(posedge clk or posedge reset)
	begin
		if (reset)
		begin
			im_ir <= 16'bxxxxxxxxxxxxxxxx;
			m_dw_data <= 16'bxxxxxxxxxxxxxxxx;
			m_dr_data <= 16'bxxxxxxxxxxxxxxxx;
			m_d_addr <= 16'bxxxxxxxxxxxxxxxx;
			m_rw <= 0;
			//dr <= 16'bxxxxxxxxxxxxxxxx;
			m_ALUo <= 16'bxxxxxxxxxxxxxxxx;

			im_bubble <= 0;
		end
		else begin
			//im_bubble <= ie_bubble;
			im_ir <= ie_ir;
			m_ALUo <= ALUo;

			iw_bubble <= im_bubble;
		end
	end

	always @(im_bubble or im_ir or m_ALUo)
	begin
		if (im_bubble == 0)
		begin
			if (im_ir[15:11] == `LOAD) // LOAD & STORE not tested. How does mem_clk behave in real PC?
			begin
				m_d_addr = im_ir[7:0];
				m_dr_data = dr;
			end
			else if (im_ir[15:11] == `STORE)
			begin
				m_dw_data = regs[im_ir[10:8]];
				m_rw = 1;
				m_d_addr = im_ir[7:0];
			end
		end
		else begin
			// every clock awaits for _bubble to refresh the correct result.
		end
	end
	
	// write back

	always @(posedge clk or posedge reset)
	begin
		if (reset)
		begin
			iw_ir = 16'bxxxxxxxxxxxxxxxx;
			wb_data = 16'bxxxxxxxxxxxxxxxx;
			w_ALUo = 16'bxxxxxxxxxxxxxxxx;
			w_dr_data = 16'bxxxxxxxxxxxxxxxx;

			iw_bubble = 0;
		end
		else begin
			//iw_bubble <= im_bubble;
			iw_ir <= im_ir;
			w_ALUo <= m_ALUo;
			w_dr_data <= m_dr_data;

		end
	end

	always @(iw_bubble or iw_ir or w_ALUo or w_dr_data)
	begin
		if (iw_bubble == 0) //how to make sure iw_bubble always update before iw_ir?
		begin
			if ((iw_ir[15:11] == `ADD ) || (iw_ir[15:11] == `ADDI))
			begin
				wb_data = w_ALUo;
				regs[iw_ir[10:8]] = wb_data;
			end
			else if (iw_ir[15:11] == `LOAD)
			begin
				regs[iw_ir[10:8]] = w_dr_data; // use <= for cross-stage data paths.
			end
		end
	end

endmodule
