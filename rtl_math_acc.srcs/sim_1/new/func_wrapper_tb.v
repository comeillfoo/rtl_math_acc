`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/30/2022 04:16:00 PM
// Design Name: 
// Module Name: func_wrapper_tb
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


module func_wrapper_tb;

reg clk, start, rst;

reg [7:0] a_b;
reg [7:0] b_b;

wire busy, end_step;

wire [7:0] anodes;
wire [7:0] cathodes;
func_wrapper wrap(
    .clk_i( clk ),
    .rst_i( rst ),
    .start_i( start ),
    .a_bi( a_b ),
    .b_bi( b_b ),
    .busy_o( busy ),
    .end_step_o( end_step ),
    .anodes_bo( anodes ),  // [ AN7, AN6, AN5, AN4, AN3, AN2, AN1, AN0 ]
    .cathodes_bo( cathodes ) // [ DP, CG, CF, CE, CD, CC, CB, CA ]
);

defparam wrap.FN_DIVISOR = 10;

always #10 clk = ~clk;

initial begin
    clk = 1;
    rst = 1;
    start = 0;
    
    a_b = 215;
    b_b = 169;
    
    #20
    rst = 0;
    start = 1;
    
    #10
    start = 0;
    
    #640 $stop;
end
endmodule
