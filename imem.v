`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:40:27 10/28/2019 
// Design Name: 
// Module Name:    imem 
// Project Name: 
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
module imem(
    input [31:0] iaddr,
    output [31:0] idata
);
    reg [31:0] mi[0:31];
    initial begin $readmemh("imem_testcase7.mem",mi); end

    assign idata = mi[iaddr[31:2]];
	 
endmodule 