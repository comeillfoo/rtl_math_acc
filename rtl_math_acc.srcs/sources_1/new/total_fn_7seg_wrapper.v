`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.04.2022 22:57:15
// Design Name: 
// Module Name: total_fn_7seg_wrapper
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

module total_fn_7seg_wrapper(
    input clk_i,
    input rst_i,
    input start_i,
    input [7:0] a_bi,
    input [7:0] b_bi,
    output wire busy_o,
    output [2:0] end_step_bo,
    output reg [4:0] anodes_bo,  // [ AN4, AN3, AN2, AN1, AN0 ]
    output reg [7:0] cathodes_bo // [ DP, CG, CF, CE, CD, CC, CB, CA ]
);
// 7 Segmeng Indicator
//      CA
//     ___
//    |   | CB
// CF |___|
//    | CG| CC
// CE |___|o DP
//      CD
// The active signal is low 0
wire [15:0] y_bo;

func fn(
    .clk(clk_i),
    .rst(rst_i),
    .start(start_i),
    .a_b(a_bi),
    .b_b(b_bi),
    .y_b(y_bo),
    .busy(busy_o),
    .end_step_b(end_step_bo)
);

wire [3:0] decimal_y [4:0];

word2dec dc_y(
    .word(y_bo),
    .n0(decimal_y[0]),
    .n1(decimal_y[1]),
    .n2(decimal_y[2]),
    .n3(decimal_y[3]),
    .n4(decimal_y[4])
);

wire [7:0] ctrl [4:0];

bcd_dc dc0(
    .digit_bi(decimal_y[0]),
    .cathodes_bo(ctrl[0])
);

bcd_dc dc1(
    .digit_bi(decimal_y[1]),
    .cathodes_bo(ctrl[1])
);

bcd_dc dc2(
    .digit_bi(decimal_y[2]),
    .cathodes_bo(ctrl[2])
);

bcd_dc dc3(
    .digit_bi(decimal_y[3]),
    .cathodes_bo(ctrl[3])
);

bcd_dc dc4(
    .digit_bi(decimal_y[4]),
    .cathodes_bo(ctrl[4])
);

// counter aka digit selector
reg [2:0] counter;
wire [2:0] counter_next = counter + 1;
always @(posedge clk_i)
    if ( rst_i || counter == 3'd4 )
        counter <= 3'd0;
    else
        counter <= counter_next;
        
// select digit according to counter
always @(posedge clk_i)
    case (counter)
        3'b000:
            anodes_bo <= 5'b11110;
        3'b001:
            anodes_bo <= 5'b11101;
        3'b010:
            anodes_bo <= 5'b11011;
        3'b011:
            anodes_bo <= 5'b10111;
        3'b100:
            anodes_bo <= 5'b01111;
        default:
            anodes_bo <= 5'b11110;
    endcase

// out the according signals for cathod for selected digit
always @(posedge clk_i)
    cathodes_bo <= ctrl[counter];

endmodule
