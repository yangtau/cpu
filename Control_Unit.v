`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    19:46:15 05/15/2019
// Design Name:
// Module Name:    Control_Unit
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
module Control_Unit(func,
                    op,wreg,m2reg,wmem,aluc,regrt,
                    rs1, rs2, // rs, st
                    mem_rd, mem_wreg,
                    exe_rd, exe_wreg,
                    exe_m2reg,
                    exe_is_jump,
                    exe_is_beq,
                    exe_is_bne,
                    mem_branch,
                    wb_branch,
                    stall_en,
                    alu_a_select, alu_b_select,
                    sext,pcsource,
                    is_jump, is_beq, is_bne
                   );
input [5:0] func,op;		//指令中相应控制码字段

// 用于 stall 信号生成
input wire [4:0] rs1, rs2; // 译码阶段需要读的寄存器
input wire [4:0] exe_rd; // 处于wb阶段的指令的目标寄存器
input wire [4:0] mem_rd; // 处于mem阶段的指令的目标寄存器
input wire exe_wreg, mem_wreg; // 上两者的写信号
input wire exe_m2reg;
input wire exe_is_jump, exe_is_beq, exe_is_bne;

 // mem 阶段跳转信号, wb 阶段跳转信号
input wire mem_branch,wb_branch;

output wire stall_en;
output wire [1:0] alu_a_select, alu_b_select;
output wreg,m2reg,wmem,regrt,sext;
output reg [2:0] aluc;		//ALU控制码
output wire [1:0] pcsource;		//PC多路选择器控制码
output is_jump, is_bne, is_beq; // 输出指令类型

wire i_add,i_and,i_or,i_xor,i_sll,i_srl;            //寄存器运算标志
wire i_addi,i_andi,i_ori,i_xori;		//立即数运算标志
wire i_lw,i_sw;		//存储器运算标志
wire i_beq,i_bne;		//branch运算标志
wire i_j;		//jump运算标志

////////////////////////////////////////////运算标志的生成/////////////////////////////////////////////////////////
and(i_add,~op[5],~op[4],~op[3],~op[2],~op[1],~op[0],~func[2],~func[1],func[0]);		//add运算标志
and(i_and,~op[5],~op[4],~op[3],~op[2],~op[1],op[0],~func[2],~func[1],func[0]);		//and运算标志
and(i_or,~op[5],~op[4],~op[3],~op[2],~op[1],op[0],~func[2],func[1],~func[0]);		//or运算标志
and(i_xor,~op[5],~op[4],~op[3],~op[2],~op[1],op[0],func[2],~func[1],~func[0]);		//xor运算标志

and(i_srl,~op[5],~op[4],~op[3],~op[2],op[1],~op[0],~func[2],func[1],~func[0]);		//srl运算标志
and(i_sll,~op[5],~op[4],~op[3],~op[2],op[1],~op[0],~func[2],func[1],func[0]);		//sll运算标志

and(i_addi,~op[5],~op[4],~op[3],op[2],~op[1],op[0]);		//addi运算标志
and(i_andi,~op[5],~op[4],op[3],~op[2],~op[1],op[0]);		//andi运算标志
and(i_ori,~op[5],~op[4],op[3],~op[2],op[1],~op[0]);		//ori运算标志
and(i_xori,~op[5],~op[4],op[3],op[2],~op[1],~op[0]);		//xori运算标志

and(i_lw,~op[5],~op[4],op[3],op[2],~op[1],op[0]);		//load运算标志
and(i_sw,~op[5],~op[4],op[3],op[2],op[1],~op[0]);		//store运算标志

and(i_beq,~op[5],~op[4],op[3],op[2],op[1],op[0]);		//beq运算标志
and(i_bne,~op[5],op[4],~op[3],~op[2],~op[1],~op[0]);		//bne运算标志

and(i_j,~op[5],op[4],~op[3],~op[2],op[1],~op[0]);		//jump运算标志

// rs1, rs2 是否需要读
wire rs1_is_reg = i_add|i_and|i_and|i_or|i_xor|i_addi|i_andi|i_ori|i_xori|i_lw|i_sw|i_beq|i_bne;
wire rs2_is_reg = i_add|i_and|i_and|i_or|i_xor|i_srl|i_sll|i_sw|i_beq|i_bne;
wire shift=i_sll|i_srl;//ALUa数据输入选择：为1时ALUa输入端使用移位位数字段inst[19:15]
wire aluimm=i_addi|i_andi|i_ori|i_xori|i_lw|i_sw;//ALUb数据输入选择：为1时ALUb输入端使用立即数

// exe 阶段正在执行 load 指令且数据冒险，暂停流水线
// 或者 exe 阶段是 beq/bnq 指令
assign stall_en = (exe_m2reg & ((rs1_is_reg & exe_wreg & (exe_rd == rs1)) | (rs2_is_reg & exe_wreg & (exe_rd == rs2))))
       | exe_is_bne | exe_is_beq;

// 是否无效化写信号
// exe 阶段是 jump,或者应该暂停流水线, 或者mem/wb阶段的branch指令需要跳转
wire discard_w =  exe_is_jump | mem_branch | wb_branch | stall_en; 

// mem 阶段的指令应该跳转,则在本条指令的pcsource 中输出信号
// 如果是jump的情况,需要判断wb阶段是否需要跳转,如果需要,则要让当前的jump无效化
assign pcsource = (mem_branch ? 2'b01 :
                   (i_j&(~wb_branch) ? 2'b10 :
                    2'b00
                   ));

assign is_jump = i_j;

// 无效化 branch 指令
assign is_beq = i_beq&(~discard_w);
assign is_bne = i_bne&(~discard_w);

////////////////////////////////////////////控制信号的生成/////////////////////////////////////////////////////////
assign wreg=(i_add|i_and|i_or|i_xor|i_sll|i_srl|i_addi|i_andi|i_ori|i_xori|i_lw) & (~discard_w)  ;		//寄存器写信号
assign regrt=i_addi|i_andi|i_ori|i_xori|i_lw;    //regrt为1时目的寄存器是rt，否则为rd
assign m2reg=i_lw;  //运算结果写回寄存器：为1时将存储器数据写入寄存器，否则将ALU结果写入寄存器
assign sext=i_addi|i_lw|i_sw|i_beq|i_bne;//为1时符号拓展，否则零拓展
assign wmem=i_sw&(~discard_w);//存储器写信号：为1时写存储器，否则不写


/*
mem 和 wb 同时数据相关时，优先选择 mem 中的数据
因为 mem 中的结果是最新的结果
 
!!数据冒险检测在 ID 阶段，所以使用 mem 的数据应该对应 exe 的检测结果
即检查的内容需要前置一个阶段
*/
assign alu_a_select = (shift? 2'b01:
                       (rs1_is_reg && exe_wreg && (exe_rd == rs1) ? 2'b10 :
                        (rs1_is_reg && mem_wreg && (mem_rd == rs1) ? 2'b11 :
                         2'b00
                        )));

assign alu_b_select = (aluimm? 2'b01:
                       (rs2_is_reg && exe_wreg && (exe_rd == rs2) ? 2'b10 :
                        (rs2_is_reg && mem_wreg && (mem_rd == rs2) ? 2'b11 :
                         2'b00
                        )));

always @(op or func)
case (op)
    6'b000000: begin
        aluc<=3'b000;
    end		//+;
    6'b000001:
    case (func[5:0])
        6'b000001: begin
            aluc<=3'b001;
        end		//and;
        6'b000010: begin
            aluc<=3'b010;
        end		//or;
        6'b000100: begin
            aluc<=3'b011;
        end		//xor;
        default: begin
            aluc<=3'b111;
        end
    endcase
    6'b000010:
    case (func[5:0])
        6'b000010: begin
            aluc<=3'b100;
        end		//srl;
        6'b000011: begin
            aluc<=3'b101;
        end		//sll;
        default: begin
            aluc<=3'b111;
        end
    endcase
    6'b000101: begin
        aluc<=3'b000;
    end		//addi;
    6'b001001: begin
        aluc<=3'b001;
    end		//andi;
    6'b001010: begin
        aluc<=3'b010;
    end		//ori;
    6'b001100: begin
        aluc<=3'b011;
    end		//xori;
    6'b001101: begin
        aluc<=3'b000;
    end
    6'b001110: begin
        aluc<=3'b000;
    end
    6'b001111: begin
        aluc<=3'b110;        
    end
    6'b010000: begin
        aluc<=3'b110;
    end
    6'b010010: begin
        aluc<=3'b111;
    end
    default: begin
        aluc<=3'b111;
    end
endcase

endmodule
