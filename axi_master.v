`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: IIT Madras  
// Engineer: Rishabh C S
// 
// Create Date: 07.03.2021 15:42:03
// Design Name: 
// Module Name: axi_master
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


module axi_master(
    input clk_i,
    input reset_i,
    
    input ready_i,
    output valid_o,
    
    input [31:0] message_i,
    output [31:0] message_o,
    
    input enable_i,
    output done_o // stall till done
    );
    
    reg [31:0] message_r;
    reg valid_r, ready_r;
    
    always @(posedge clk_i)
    begin
        if(reset_i)
        begin
            message_r <= 'b0;
            valid_r <= 'b0;
        end
        else
        begin
            if(enable_i)
            begin
                message_r <= message_i;
                valid_r <= 'b1;
            end
            if(valid_r && ready_r)
            begin
                valid_r <= 'b0;
            end
        end
    end
    
    always @(posedge clk_i)
    begin
        if(reset_i)
        begin
            ready_r <= 'b0;
        end
        else
        begin
            ready_r <= ready_i;
        end
    end
    
    assign message_o = message_r;
    assign done_o = (valid_r && ready_i) ? 'b1 : 'b0;
    assign valid_o = valid_r;
    
endmodule