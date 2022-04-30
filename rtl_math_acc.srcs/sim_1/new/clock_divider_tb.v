`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/30/2022 03:35:06 PM
// Design Name: 
// Module Name: clock_divider_tb
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


module clock_divider_tb;

reg clk_i;
wire qclk_o;
clock_divider divider(
    .clk( clk_i ),
    .quotient_clk( qclk_o )
);

always #10 clk_i = ~clk_i;

initial begin
    clk_i = 1;
    $stop;
end
endmodule
