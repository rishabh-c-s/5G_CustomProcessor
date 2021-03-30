`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: IIT Madras
// Engineer: Rishabh C S
// 
// Create Date:    10:28:34 11/03/2019 
// Design Name: 
// Module Name:    top 
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
module top(
    input clk,
    input reset,
    
    // from Master
    input [31:0] message_from_master,
    input valid_i,
    output ready_o,
    
    // to modules
    output [31:0] message_to_modules,
    input ready_i,
    output valid_o
     
    );
	 
    wire [31:0] iaddr, idata;
    wire [31:0] daddr, drdata_main, drdata_AXI, drdata_DMEM, dwdata;
    wire [3:0] we, we_DMEM;
    wire en_SLAVE, en_MASTER, choose_drdata, done_slave, done_master, ext_stall_to_cpu;
     
    assign drdata_main = (choose_drdata) ? drdata_DMEM : drdata_AXI;

    CPU dut (
        .clk(clk),
        .reset(reset),
        .iaddr(iaddr),
        .idata(idata),
        .daddr(daddr),
        .drdata(drdata_main),
        .dwdata(dwdata),
        .we(we),
        
        .external_stall(ext_stall_to_cpu)
    );
	 
	 imem imem_main (
        .iaddr(iaddr), 
        .idata(idata)
    );
	 
	 dmem dmem_main (
        .clk(clk), 
        .daddr(daddr), 
        .dwdata(dwdata), 
        .we(we_DMEM), 
        .drdata(drdata_DMEM)
    ); 
    
    axi_slave from_higher_layer (
        .clk_i(clk),
        .reset_i(reset),
        .ready_o(ready_o),
        .valid_i(valid_i),    
        .message_i(message_from_master),
        .message_o(drdata_AXI),    
        .enable_i(en_SLAVE),
        .done_o(done_slave)
    );
    
    axi_master to_modules (
        .clk_i(clk),    
        .reset_i(reset),
        .ready_i(ready_i),
        .valid_o(valid_o),    
        .message_i(dwdata),
        .message_o(message_to_modules),    
        .enable_i(en_MASTER),
        .done_o(done_master)
    );
    
    memory_mapper mem_map (
        .daddr(daddr),
        .we_i(we),
        .we_o(we_DMEM),
        .en_SLAVE(en_SLAVE),
        .en_MASTER(en_MASTER),
        .choose_drdata(choose_drdata),
        .done_master(done_master),
        .done_slave(done_slave),
        .external_stall_to_cpu(ext_stall_to_cpu)
    );

endmodule