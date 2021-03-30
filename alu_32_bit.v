`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: IIT Madras
// Engineer: Rishabh C S
// 
// Create Date:    19:22:05 10/27/2019 
// Design Name: ALU
// Module Name:    alu_32_bit 
// Project Name: RISCV Microprocessor
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module alu_32_bit (
	input  wire [31:0]   in1,
	input  wire [31:0]   in2, 
	input  wire [3:0] op, 
	output wire [31:0]   out
);
	reg [31:0] out_w;
    	
	always @(in1 or in2 or op) 
	begin
     	case(op)
		4'b0000: out_w = in1 + in2;
		4'b0001: out_w = in1<<in2[3:0];
		4'b0010: out_w = $signed(in1) < $signed(in2);		
		4'b0011: out_w = in1 < in2;
		4'b0100: out_w = in1 ^ in2;
		4'b0101: out_w = in1 >> in2[3:0];
		4'b0110: out_w = in1 | in2;
		4'b0111: out_w = in1 & in2;
		4'b1000: out_w = in1 - in2;
		4'b1101: out_w = $signed(in1) >>> in2[3:0];
		// Branch instructions to follow, 'b1 means should branch, else shouldn't branch
		4'b1001: 
					begin
						if(in1 == in2)
						begin
							out_w = 'b1;
						end
						else
						begin
							out_w = 'b0;
						end
					end
		4'b1010:
					begin
						if(in1 != in2)
						begin
							out_w = 'b1;
						end
						else
						begin
							out_w = 'b0;
						end
					end
		4'b1011:
					begin
						if($signed(in1) < $signed(in2))
						begin
							out_w = 'b1;
						end
						else
						begin
							out_w = 'b0;
						end
					end
		4'b1100:
					begin
						if($signed(in1) >= $signed(in2))
						begin
							out_w = 'b1;
						end
						else
						begin
							out_w = 'b0;
						end
					end
		4'b1110:
					begin
						if(in1 < in2)
						begin
							out_w = 'b1;
						end
						else
						begin
							out_w = 'b0;
						end
					end
		4'b1111:
					begin
						if(in1 >= in2)
						begin
							out_w = 'b1;
						end
						else
						begin
							out_w = 'b0;
						end
					end
		default: out_w = 32'bx;
		endcase
	end
	
	assign out = out_w;

endmodule