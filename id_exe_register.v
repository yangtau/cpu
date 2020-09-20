`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    21:01:40 05/22/2019
// Design Name:
// Module Name:    id_exe_register
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
module id_exe_register(clk,clrn,
                       id_wreg,id_m2reg,id_wmem,id_aluc,id_alu_b_select,id_a,id_b,id_imm,id_rn,id_alu_a_select,id_wz,
                       id_is_beq, id_is_bne, id_is_jump, id_bpc,
                       exe_is_beq, exe_is_bne, exe_is_jump, exe_bpc,
                       exe_wreg,exe_m2reg,exe_wmem,exe_aluc,exe_alu_b_select,exe_a,exe_b,exe_imm,exe_rn,exe_alu_a_select,exe_wz);
input [31:0] id_a,id_b,id_imm;
input [4:0] id_rn;
input [2:0] id_aluc;
input id_wreg,id_m2reg,id_wmem,id_wz;
input [1:0] id_alu_b_select,id_alu_a_select;
input clk,clrn;
input id_is_beq, id_is_bne, id_is_jump;
input [31:0] id_bpc;

output reg [31:0] exe_bpc;
output reg exe_is_beq, exe_is_bne, exe_is_jump;

output reg [31:0] exe_a,exe_b,exe_imm;
output reg [4:0] exe_rn;
output reg [2:0] exe_aluc;
output reg exe_wreg,exe_m2reg,exe_wmem,exe_wz;
output reg [1:0] exe_alu_a_select,exe_alu_b_select;

//请在下方补充代码以完成流水线寄存器
//////////////////////////////////////////////////////////////////////////////

always @(posedge clk or negedge clrn) begin
    if (clrn == 0) begin
        exe_a <= 0;
        exe_b <= 0;
        exe_imm <= 0;
        exe_rn <= 0;
        exe_aluc <= 0;

        exe_wreg <= 0;
        exe_m2reg <= 0;
        exe_wmem <= 0;
        exe_alu_a_select <= 0;
        exe_alu_b_select <= 0;
        exe_wz <= 0;
        exe_is_jump <= 0;
        exe_is_beq <= 0;
        exe_is_bne <= 0;
        exe_bpc <= 0;
    end
    else begin
        exe_a <= id_a;
        exe_b <= id_b;
        exe_imm <= id_imm;
        exe_rn <= id_rn;
        exe_aluc <= id_aluc;

        exe_wreg <= id_wreg;
        exe_wz <= id_wz;
        exe_wmem <= id_wmem;

        exe_m2reg <= id_m2reg;
        exe_alu_a_select <= id_alu_a_select;
        exe_alu_b_select <= id_alu_b_select;

        exe_is_jump <= id_is_jump;
        exe_is_beq <= id_is_beq;
        exe_is_bne <= id_is_bne;
        exe_bpc <= id_bpc;
    end
end

endmodule
