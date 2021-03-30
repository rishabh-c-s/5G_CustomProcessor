`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: IIT Madras
// Engineer: Rishabh C S
// 
// Create Date:    16:48:32 10/01/2019 
// Design Name: CPU for RISCV ISa
// Module Name:    CPU 
// Project Name: CPU
// Target Devices: Spartan3E FSG320 Xilinx FPGA
// Tool versions: 
// Description: 
//
// Dependencies: Needs the IMEM and DMEM from the testbench/VIO
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module CPU
(
    input clk,
    input reset,
    output [31:0] iaddr,  // address to instruction memory
    input [31:0] idata,   // data from instruction memory
    output [31:0] daddr,  // address to data memory
    input [31:0] drdata,  // data read from data memory
    output [31:0] dwdata, // data to be written to data memory
    output [3:0] we,      // write enable signal for each byte of 32-b word
    
    input external_stall
);

// -----------------
// Registers and Wires
// -----------------

reg [31:0]  pc_r;

reg [31:0]  rf_indata; // actually a wire

wire [3:0]  alu_op;
wire [4:0]  rs1;
wire [4:0]  rs2;
wire [4:0]  rd;
wire [31:0] immediate;

// All these for decoder
wire 			reg_write_control;
wire 			mux_rs2_immediate_control;
wire 			mux_alu_or_dmem_control;
wire 			mux_jalr_rs1offset_control;
wire [1:0]  mux_4x1_mux_control;

// All these for RF
wire [31:0] rv1;
wire [31:0] rv2;

// All these for the ALU
wire [31:0] alu_out;
wire [31:0] alu_in_2;

// All these local to the CPU
wire [31:0] alu_slash_memory;
wire [31:0] next_pc_add_4_or_offset;
wire [31:0] pc_jump;
wire [31:0] pc_jump_value;

// Local reg/wires for DMEM
reg  [31:0] drdata_final; // actually a wire
wire  [31:0] daddr_w;      // actually a wire
reg  [31:0] dwdata_r;  	  // actually a wire
reg  [3:0]  we_r;			  // actually a wire

reg stall_done_r;
wire stall_w;

wire mem_op;

// --------------------
// Setting Stall Cycle
// --------------------

assign stall_w = ((idata[6:2] == 5'b00000 && stall_done_r == 'b0) || (external_stall == 'b1)) ? 'b1 : 'b0;
always @(posedge clk)
begin
    if(reset == 'b1)
    begin
        stall_done_r <= 'b0;
    end
    else
    begin
        if(idata[6:2] == 5'b00000)
        begin
            stall_done_r <= 'b1;
        end
        else
        begin
            stall_done_r <= 'b0;
        end
    end
end

// -----------------
// Setting Alu input 2
// -----------------

assign alu_in_2 = mux_rs2_immediate_control ? immediate : rv2;

// -----------------
// Setting Alu or DMEM
// -----------------

assign alu_slash_memory = mux_alu_or_dmem_control ? alu_out : drdata_final;

// -----------------
// Setting 4x1 MUX
// -----------------

always @(*)
begin
	case(mux_4x1_mux_control)
	2'b00: rf_indata = immediate;
	2'b01: rf_indata = pc_r + immediate;
	2'b10: rf_indata = pc_r + 32'h00000004;
	2'b11: rf_indata = alu_slash_memory;
	default: rf_indata = 'b0;
	endcase
end

// -----------------
// to add 4 or offset to PC
// -----------------

assign next_pc_add_4_or_offset = (idata[6:2] == 5'b11011) || ( (idata[6:2] == 5'b11000) && (alu_out == 'b1) ) ? immediate : 32'h00000004;
assign pc_jump_value = (stall_w == 1'b1) ? 'b0 : next_pc_add_4_or_offset;
assign pc_jump = pc_jump_value + pc_r;

// -----------------
// is it jalr or not, and then setting PC
// -----------------

always @(posedge clk)
begin
	if(reset)
	begin
		pc_r = 'b0;
	end
	else
	begin
	   	case(mux_jalr_rs1offset_control)
		1'b0: pc_r = alu_out & 32'hfffffffc;
		1'b1: pc_r = pc_jump & 32'hfffffffc;
		default: pc_r = 'b0;
		endcase
	end
end
assign pc = pc_r;

// -----------------
// Assigning IADDR
// -----------------

assign iaddr = pc_r;

// -----------------
// Setting DMEM controls
// -----------------

// Setting DMEM Address
assign daddr = (mem_op) ? alu_out : 'b0;
assign daddr_w = alu_out;

// Setting correct data read from DMEM
always @(*)
begin
	case(idata[13:12])
	2'b00:
			begin
				case(daddr_w[1:0])
				2'b00: drdata_final = {(1<<24)-drdata[7],drdata[7:0]};
				2'b01: drdata_final = {(1<<24)-drdata[15],drdata[15:8]};
				2'b10: drdata_final = {(1<<24)-drdata[23],drdata[23:16]};
				2'b11: drdata_final = {(1<<24)-drdata[31],drdata[31:24]};
				default: drdata_final = 'b0;
				endcase
			end
	2'b01:
			begin
				case(daddr_w[1:0])
				2'b00: drdata_final = {(1<<16)-drdata[15],drdata[15:0]};
				2'b10: drdata_final = {(1<<24)-drdata[31],drdata[31:16]};
				default: drdata_final = 'b0;
				endcase
			end
	2'b10: drdata_final = drdata;
	default: drdata_final = 'b0;
	endcase
end

// Setting correct data written to DMEM with alignment
always @(*)
begin
	case(idata[13:12])
	2'b00: dwdata_r = {rv2[7:0],rv2[7:0],rv2[7:0],rv2[7:0]};			
	2'b01: dwdata_r = {rv2[15:8],rv2[15:8]};	
	2'b10: dwdata_r = rv2;
	default: dwdata_r = 'b0;
	endcase
end
assign dwdata = dwdata_r;

// Setting the write enable for DMEM
always @(*)
begin
	if(idata[6:2] == 5'b01000)
	begin
		case(idata[13:12])
		2'b00:
			begin
				case(daddr_w[1:0])
				2'b00: we_r = 4'b0001;
				2'b01: we_r = 4'b0010;
				2'b10: we_r = 4'b0100;
				2'b11: we_r = 4'b1000;
				default: we_r = 'b0; // doesn't write if error
				endcase
			end
		2'b01:
			begin
				case(daddr_w[1:0])
				2'b00: we_r = 4'b0011;
				2'b10: we_r = 4'b1100;
				default: we_r = 'b0; // doesn't write if error
				endcase
			end
		2'b10: we_r = 4'b1111;
		default: we_r = 'b0;
		endcase
	end
	else
	begin
		we_r = 'b0;
	end
end
assign we = we_r;

// ----------------------------
// 		Module Instantiations
// ----------------------------

complete_decoder decoder_inst (
    .instr_i(idata), 
    .alu_op_o(alu_op), 
    .stall_i(stall_w),
    .rs1_o(rs1), 
    .rs2_o(rs2), 
    .rd_o(rd), 
    .immediate_o(immediate), 
    .reg_write_control_o(reg_write_control), 
    .mux_rs2_immediate_control_o(mux_rs2_immediate_control), 
    .mux_alu_or_dmem_control_o(mux_alu_or_dmem_control), 
    .mux_jalr_rs1offset_control_o(mux_jalr_rs1offset_control), 
    .mux_4x1_mux_control_o(mux_4x1_mux_control),
    .mem_op_o(mem_op)
    );

// ----------------------------

alu_32_bit alu_inst (
    .in1(rv1), 
    .in2(alu_in_2), 
    .op(alu_op), 
    .out(alu_out)
    );

// -----------------------------

rf_module register_file_inst (
    .clk(clk), 
    .rs1(rs1), 
    .rs2(rs2), 
    .rd(rd), 
    .we(reg_write_control), 
    .rv1(rv1), 
    .rv2(rv2), 
    .indata(rf_indata)
    );
	 	 
endmodule 