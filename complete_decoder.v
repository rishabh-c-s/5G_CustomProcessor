`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: IIT Madras
// Engineer: Rishabh C S
// 
// Create Date:    19:17:23 10/27/2019 
// Design Name: Complete Decoder
// Module Name:    complete_decoder 
// Project Name: RISCV Processor
// Target Devices: Xilinx Spartan 3E
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: This is the complete decoder for the riscv microprocessor
//
//////////////////////////////////////////////////////////////////////////////////

module complete_decoder (
    input  wire [31:0] instr_i,
	 
    output wire [3:0]  alu_op_o,
    input  wire         stall_i,
	 output wire [4:0]  rs1_o,
	 output wire [4:0]  rs2_o,
	 output wire [4:0]  rd_o,
	 output wire [31:0] immediate_o, // goes to both ALU and the 4x1 MUX
	 
	 output wire 		  reg_write_control_o,
	 output wire 		  mux_rs2_immediate_control_o,
	 output wire 		  mux_alu_or_dmem_control_o,
	 output wire 		  mux_jalr_rs1offset_control_o,
	 output wire [1:0]  mux_4x1_mux_control_o,
	 output wire        mem_op_o
);

// -------------------------
// Defining registers/wires
// -------------------------

	reg [3:0] alu_op_w;
	reg [31:0] immediate_temp_w;
	reg [1:0] mux_4x1_mux_control_r;

// ---------------------------------
// Assigning rs1, rs2, rd
// ---------------------------------

assign rs1_o = instr_i[19:15];
assign rs2_o = instr_i[24:20];
assign rd_o = instr_i[11:7];

// --------------------------------------------------------
// Setting alu opcode
// --------------------------------------------------------

	always @(*)
	begin
	   alu_op_w = 'b0;
		case(instr_i[6:2])
		5'b00000, // Load and Store and JALR
		5'b01000, // for JALR, need to add rs1 to offset and then jump PC
		5'b11001: alu_op_w = 4'b0000;
		5'b00100, // ALU Immediate and Non Immediate
		5'b01100:
					begin
						alu_op_w[2:0] = instr_i[14:12];
						if( ({instr_i[14:12],instr_i[5]}==4'b0001) || ({instr_i[14:12],instr_i[5]}==4'b1010) || ({instr_i[14:12],instr_i[5]}==4'b1011) )
						begin
							alu_op_w[3] = instr_i[30];
						end
						else
						begin
							alu_op_w[3] = 1'b0;
						end
					end
		5'b11000: // Branch
					begin
						case(instr_i[14:12])
						3'b000: alu_op_w = 4'b1001; // BEQ
						3'b001: alu_op_w = 4'b1010; // BNE
						3'b100: alu_op_w = 4'b1011; // BLT
						3'b101: alu_op_w = 4'b1100; // BGE
						3'b110: alu_op_w = 4'b1110; // BLTU
						3'b111: alu_op_w = 4'b1111; // BGEU
						endcase
					end
		default: alu_op_w = 4'b0000;
		endcase
	end	
	assign alu_op_o = alu_op_w;
	
// ----------------------------------------------
// Assigning the immediate with sign extension
// ----------------------------------------------

	always @(*)
	begin
		case(instr_i[6:2])
		5'b00000: // Load
					begin
						immediate_temp_w = {(1<<20)-instr_i[31],instr_i[31:20]};
					end
		5'b01000: // Store
					begin
						immediate_temp_w = {(1<<20)-instr_i[31],instr_i[31:25],instr_i[11:7]}; 
					end
		5'b00100: // ALU Immediate
					begin
						immediate_temp_w = {(1<<20)-instr_i[31],instr_i[31:20]};
					end
//		5'b01100: // ALU Non Immediate
//					begin
//						ALU non immediate doesn't have any immediate
//					end
		5'b11000: // Branch
					begin
						immediate_temp_w = {(1<<19)-instr_i[31],instr_i[31],instr_i[7],instr_i[30:25],instr_i[11:8],1'b0}; 
					end
		5'b01101: immediate_temp_w = {instr_i[31:12],12'h000}; // LUI
		5'b00101: immediate_temp_w = {instr_i[31:12],12'h000}; // AUIPC
		5'b11011: immediate_temp_w = {(1<<11)-instr_i[31],instr_i[31],instr_i[19:12],instr_i[20],instr_i[30:21],1'b0}; // JAL
		5'b11001: immediate_temp_w = {(1<<20)-instr_i[31],instr_i[31:20]}; // JALR
		default: immediate_temp_w = 'b0;
		endcase
	end
	assign immediate_o = immediate_temp_w;

// -----------------------------------------
// Assigning rf_write (reg_write)
// -----------------------------------------

assign reg_write_control_o = (stall_i == 'b1) || (instr_i[6:2] == 5'b01000) || (instr_i[6:2] == 5'b11000) ? 1'b0 : 1'b1;

// ---------------------------------
// Assigning mux for rs2 or immediate
// ---------------------------------

assign mux_rs2_immediate_control_o = (instr_i[6:2] == 5'b01100) || (instr_i[6:2] == 5'b11000) ? 1'b0 : 1'b1;

// ------------------------------------
// Assigning ALU or DMEM
// ------------------------------------

assign mux_alu_or_dmem_control_o = instr_i[6:2] == 5'b00000 ? 1'b0 : 1'b1;

// ------------------------------------
// Assigning ALU or DMEM
// ------------------------------------

assign mem_op_o = (instr_i[6:2] == 5'b00000) || (instr_i[6:2] == 5'b01000) ? 'b1 : 'b0;

// ------------------------------------
// Whether we should increase PC by 4 or offset
// ------------------------------------

// assign mux_add_4_or_offset_control_o = (instr_i[6:2] == 5'b11000) || (instr_i[6:2] == 5'b11011) ? 1'b1 : 1'b0;
// taken care in CPU

// -----------------------------------
// Whether JALR or normal
// -----------------------------------
	
assign mux_jalr_rs1offset_control_o = instr_i[6:2] == 5'b11001 ? 1'b0 : 1'b1;

// -------------------
// Setting 4x1 MUX
// -------------------

always @(*)
begin
	case(instr_i[6:2])
	5'b01101: mux_4x1_mux_control_r = 2'b00; // LUI
	5'b00101: mux_4x1_mux_control_r = 2'b01; // AUIPC
	5'b11011, // JAL and JALR
	5'b11001: mux_4x1_mux_control_r = 2'b10;
	default: mux_4x1_mux_control_r = 2'b11; // ALU, Load/Store, etc.
	endcase
end

assign mux_4x1_mux_control_o = mux_4x1_mux_control_r;

endmodule