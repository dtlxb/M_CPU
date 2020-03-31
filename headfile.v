
`ifndef HEADFILE_H_

//State for CPU
`define idle        1'b0
`define exec        1'b1

//Data transfer & Arithmetic
`define  NOP        5'b00000
`define  HALT       5'b00001

`define  LOAD       5'b00010
`define  STORE      5'b00011
`define  ADD        5'b01000
`define ADDI        5'b01001
// other logistic|arth ops


//Control
`define JUMP        5'b11000
`define JZ	    5'b10111  //jump zero, implemented as jump odd


//gr
`define gr0 3'b000
`define gr1 3'b001
`define gr2 3'b010
`define gr3 3'b011

`endif