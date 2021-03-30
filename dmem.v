`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:40:39 10/28/2019 
// Design Name: 
// Module Name:    dmem 
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
module dmem(
    input clk,
    input [31:0] daddr,
    input [31:0] dwdata,
    input [3:0] we,
    output [31:0] drdata
);
   
   
  wire [6:0] main_addr;
  assign main_addr = daddr[6:0] & 7'b1111100;
    
blk_mem_gen_0 main_bram (
  .clka(clk),    // input wire clka
  .wea(we),      // input wire [3 : 0] wea
  .addra(main_addr),  // input wire [6 : 0] addra
  .dina(dwdata),    // input wire [31 : 0] dina
  .clkb(clk),    // input wire clkb
  .addrb(main_addr),  // input wire [6 : 0] addrb
  .doutb(drdata)  // output wire [31 : 0] doutb
);
	 
endmodule 