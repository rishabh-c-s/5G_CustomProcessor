`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: IIT Madras  
// Engineer: Rishabh C S
// 
// Create Date: 07.03.2021 15:42:03
// Design Name: 
// Module Name: axi_slave
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


module axi_slave(
    input clk_i,
    input reset_i,
    
    output ready_o,
    input valid_i,
    
    input [31:0] message_i,
    output [31:0] message_o,
    
    input enable_i,
    output done_o // stall till done
    );
    
    reg ready_r;
    reg valid_r;
    
    always @(posedge clk_i)
    begin
        if(reset_i)
        begin
            ready_r <= 'b0;
        end
        else
        begin
            if(enable_i)
            begin
                ready_r <= 'b1;
            end
            if(valid_r && ready_r)
            begin
                ready_r <= 'b0;
            end
        end
    end
    
    always @(posedge clk_i)
    begin
        if(reset_i)
        begin
            valid_r <= 'b0;
        end
        else
        begin
            valid_r <= valid_i;
        end
    end
    
    assign ready_o = ready_r;
    assign message_o = (valid_i && ready_r) ? message_i : 'b0;
    assign done_o = (valid_i && ready_r) ? 'b1 : 'b0;
    
endmodule