`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    21:46:17 05/22/2019
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
module exe_mem_register(clk,clrn,
                        branch,
                        exe_wreg,exe_m2reg,exe_wmem,exe_alu,exe_b,exe_rn,
                        exe_bpc,
                        mem_wreg,mem_m2reg,mem_wmem,mem_alu,mem_b,mem_rn,
                        mem_bpc,
                        mem_branch
                       );
input [31:0] exe_alu,exe_b;		//exe_b-在store指令的情况下需要将rt写入存储器
input [4:0] exe_rn;
input branch;
input exe_wreg,exe_m2reg,exe_wmem;
input clk,clrn;
input [31:0] exe_bpc;
output reg [31:0] mem_alu,mem_b;
output reg [4:0] mem_rn;
output reg mem_wreg,mem_m2reg,mem_wmem;		//EXE级输入信号-exe_z
output reg mem_branch;
output reg [31:0] mem_bpc;

//请在下方补充代码以完成流水线寄存器
//////////////////////////////////////////////////////////////////////////////

always @(posedge clk or negedge clrn) begin
    if (clrn == 0)	begin
        mem_alu <= 0;
        mem_b <= 0;
        mem_rn <= 0;
        mem_wreg <= 0;
        mem_m2reg <= 0;
        mem_wmem <= 0;
        mem_branch <= 0;
        mem_bpc <= 0;
    end
    else begin
        mem_alu <= exe_alu;
        mem_b <= exe_b;
        mem_rn <= exe_rn;
        mem_wreg <= exe_wreg;
        mem_m2reg <= exe_m2reg;
        mem_wmem <= exe_wmem;
        mem_branch <= branch;
        mem_bpc <= exe_bpc;
    end
end

endmodule
