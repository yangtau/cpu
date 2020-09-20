`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    15:00:09 05/25/2019
// Design Name:
// Module Name:    exe_mem_register
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
module exe_mem_register_withWZ(exe_z,
                               clk, clrn,
                               exe_wreg, exe_m2reg, exe_wmem, exe_alu, exe_b, exe_rn,
                               exe_is_beq, exe_is_bne, exe_bpc,
                               mem_branch, mem_bpc,
                               mem_wreg, mem_m2reg, mem_wmem, mem_alu, mem_b, mem_rn);
input exe_z;
input clk, clrn;
input exe_wreg, exe_m2reg, exe_wmem;
input [31:0] exe_alu, exe_b;
input [4:0] exe_rn;
input exe_is_bne, exe_is_beq;
input [31:0] exe_bpc;

output mem_wreg, mem_m2reg, mem_wmem, mem_branch;
output [31:0] mem_bpc;
output [31:0] mem_alu, mem_b;
output [4:0] mem_rn;

wire branch = (exe_is_beq&exe_z) | (exe_is_bne&~exe_z);

exe_mem_register EXE_MEM (.clk(clk), .clrn(clrn),
                          .branch(branch),
                          .exe_wreg(exe_wreg), .exe_m2reg(exe_m2reg), .exe_wmem(exe_wmem),
                          .exe_alu(exe_alu), .exe_b(exe_b), .exe_rn(exe_rn),
						  .exe_bpc(exe_bpc),
                          .mem_wreg(mem_wreg), .mem_m2reg(mem_m2reg), .mem_wmem(mem_wmem),
                          .mem_alu(mem_alu), .mem_b(mem_b), .mem_rn(mem_rn),
						  .mem_bpc(mem_bpc),
                          .mem_branch(mem_branch));






endmodule
