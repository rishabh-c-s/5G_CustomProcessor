`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.03.2021 11:21:43
// Design Name: 
// Module Name: memory_mapper
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module memory_mapper(
    input [31:0] daddr,
    input [3:0]  we_i,
    output [3:0] we_o,
    output       en_SLAVE,
    output       en_MASTER,
    output       choose_drdata, // 1 means dmem, 0 means slave
    
    input done_slave,
    input done_master,
    output external_stall_to_cpu
    );
    
    assign choose_drdata = (daddr < 'd10000) ? 'b1 : 'b0;
    assign en_SLAVE = (daddr < 'd11000 && daddr > 'd10000) ? 'b1 : 'b0;
    assign en_MASTER = (daddr > 'd11000) ? 'b1 : 'b0;
    assign we_o = (daddr < 'd10000) ? we_i : 'b0000;
    
    reg external_stall_to_cpu_r;
    
    always @(*)
    begin
        if(daddr > 'd10000 && done_master == 'b0 && done_slave == 'b0)
        begin
            external_stall_to_cpu_r = 'b1;
        end
        else
        begin
            external_stall_to_cpu_r = 'b0;
        end
    end
    
    assign external_stall_to_cpu = external_stall_to_cpu_r;
        
endmodule
