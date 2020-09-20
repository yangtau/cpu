`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    18:33:59 05/14/2019
// Design Name:
// Module Name:    PPCPU
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
module PPCPU(Clock, Resetn, PC, IF_Inst, ID_Inst, EXE_Alu, MEM_Alu, WB_Alu);
input Clock, Resetn;
output [31:0] PC, IF_Inst, ID_Inst;
output [31:0] EXE_Alu, MEM_Alu, WB_Alu;

wire [31:0] npc;
wire [1:0] pcsource;
// wire [31:0] bpc, jpc, if_pc4, id_pc4;
wire [31:0] jpc, if_pc4, id_pc4;

wire [31:0] wdi;
wire id_m2reg, exe_m2reg, mem_m2reg, wb_m2reg;
wire id_wmem, exe_wmem, mem_wmem;
wire [2:0] id_aluc, exe_aluc;

wire [1:0] id_alu_a_select, id_alu_b_select;
wire [1:0] exe_alu_a_select, exe_alu_b_select;

wire [31:0] id_a, exe_a;
wire [31:0] id_b, exe_b, mem_b;
wire [31:0] id_imm, exe_imm;
wire exe_z, mem_z; // exe_z-由EXE级的ALU计算得出的z信号；mem_z-由EXE_MEM寄存器出来的z信号
wire id_wz, exe_wz;
wire id_wreg, exe_wreg, mem_wreg, wb_wreg;
wire [4:0] id_rn, exe_rn, mem_rn, wb_rn;
wire [31:0] mem_mo, wb_mo;
wire stall; // stall

wire [31:0]  exe_bpc, id_bpc, mem_bpc;

wire id_is_beq, id_is_bne, id_is_jump;
wire exe_is_beq, exe_is_bne, exe_is_jump;
wire mem_branch, wb_branch;


program_counter PCR (Clock, Resetn, npc,
                     ~stall, // wpc
                     PC);

instruction_fetch IF_STAGE (
                      pcsource, PC, mem_bpc, jpc, if_pc4, npc,
                      IF_Inst);

instruction_register IR(if_pc4, IF_Inst, Clock, Resetn,
                        ~stall, // wir
                        id_pc4, ID_Inst);

instruction_decode ID_STAGE (id_pc4, ID_Inst,
                             wdi, Clock, Resetn, id_bpc, jpc, pcsource,
                             id_m2reg, id_wmem, id_aluc, id_a, id_b, id_imm,
                             exe_rn, exe_wreg, mem_rn, mem_wreg, wb_rn, wb_wreg,
                             exe_m2reg,
                             exe_is_jump,
                             exe_is_beq,
                             exe_is_bne,
                             mem_branch,
                             wb_branch,
                             stall,
                             id_alu_a_select, id_alu_b_select,
                             mem_z , id_wreg,  id_rn,  id_wz,
                             id_is_jump, id_is_beq, id_is_bne);

id_exe_register ID_EXE (.clk(Clock), .clrn(Resetn),
                        .id_wreg(id_wreg), .id_m2reg(id_m2reg),
                        .id_wmem(id_wmem), .id_aluc(id_aluc), .id_alu_b_select(id_alu_b_select),
                        .id_a(id_a), .id_b(id_b), .id_imm(id_imm), .id_rn(id_rn),
                        .id_alu_a_select(id_alu_a_select), .id_wz(id_wz),
                        .id_is_beq(id_is_beq), .id_is_bne(id_is_bne), .id_is_jump(id_is_jump),
                        .id_bpc(id_bpc),
                        .exe_is_beq(exe_is_beq), .exe_is_bne(exe_is_bne), .exe_is_jump(exe_is_jump),
                        .exe_bpc(exe_bpc),
                        .exe_wreg(exe_wreg), .exe_m2reg(exe_m2reg),
                        .exe_wmem(exe_wmem), .exe_aluc(exe_aluc), .exe_alu_b_select(exe_alu_b_select),
                        .exe_a(exe_a), .exe_b(exe_b), .exe_imm(exe_imm),
                        .exe_rn(exe_rn), .exe_alu_a_select(exe_alu_a_select), .exe_wz(exe_wz));

execute EXE_STAGE (exe_aluc, exe_a, exe_b, exe_imm,
                   exe_alu_a_select, exe_alu_b_select,
                   MEM_Alu, WB_Alu, wb_mo, wb_m2reg,
                   EXE_Alu, exe_z);

exe_mem_register_withWZ EXE_MEM (.clk(Clock),.clrn(Resetn),
                                 .exe_z(exe_z),.exe_wz(exe_wz),
                                 .exe_wreg(exe_wreg),.exe_m2reg(exe_m2reg),.exe_wmem(exe_wmem),.exe_alu(EXE_Alu),.exe_b(exe_b),.exe_rn(exe_rn),
                                 .exe_is_beq(exe_is_beq), .exe_is_bne(exe_is_bne),
                                 .exe_bpc(exe_bpc),
                                 .mem_branch(mem_branch),
                                 .mem_bpc(mem_bpc),
                                 .mem_wreg(mem_wreg),.mem_m2reg(mem_m2reg),.mem_wmem(mem_wmem),.mem_alu(MEM_Alu),.mem_b(mem_b),.mem_rn(mem_rn),.mem_z(mem_z));

memory MEM_STAGE (mem_wmem, MEM_Alu[4:0], mem_b, Clock, mem_mo);		//存储器以字节为单位进行寻址，1个存储器字为4字节；

mem_wb_register MEM_WB (mem_wreg, mem_m2reg, mem_mo, MEM_Alu, mem_rn, Clock, Resetn,
                        wb_wreg, wb_m2reg, wb_mo, WB_Alu, wb_rn, 
                        mem_branch, wb_branch);

write_back WB_STAGE (WB_Alu, wb_mo, wb_m2reg, wdi);

endmodule
