`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    13:35:39 09/06/2020
// Design Name:
// Module Name:    dff
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
module dff(d,clk,clrn,q
          );
input d;
input clk,clrn;
output q;
reg q;
always @ (negedge clrn or posedge clk)
    if(clrn==0) begin
        q<=0;
    end
    else begin
        q<=d;
    end
endmodule
