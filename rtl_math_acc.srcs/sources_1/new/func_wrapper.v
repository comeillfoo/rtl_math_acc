`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/30/2022 03:06:15 AM
// Design Name: 
// Module Name: func_wrapper
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


module func_wrapper
    #( FN_DIVISOR = 50_000 ) (
    input clk_i,
    input rst_i,
    input start_i,
    input [7:0] a_bi,
    input [7:0] b_bi,
    output busy_o,
    output end_step_o,
    output [7:0] anodes_bo,  // [ AN7, AN6, AN5, AN4, AN3, AN2, AN1, AN0 ]
    output [7:0] cathodes_bo // [ DP, CG, CF, CE, CD, CC, CB, CA ]
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


// stage 1: calculate function
wire [15:0] y_bo;
wire fn_busy_o, fn_end_step_o;

func fn(
    .clk( clk_i ),
    .rst( rst_i ),
    .start( start_i ),
    .a_b( a_bi ),
    .b_b( b_bi ),
    .y_b( y_bo ),
    .busy( fn_busy_o ),
    .end_step( fn_end_step_o )
);


// stage 2: convert result to bcd
wire [3:0] digits_bo[7:0];
wire converter_busy_o;

bcd_converter converter(
    .clk( clk_i ),
    .start( fn_end_step_o ),
    .rst( rst_i ),
    .half_word_b( y_bo ),
    .d0_b( digits_bo[0] ),
    .d1_b( digits_bo[1] ),
    .d2_b( digits_bo[2] ),
    .d3_b( digits_bo[3] ),
    .d4_b( digits_bo[4] ),
    .d5_b( digits_bo[5] ),
    .d6_b( digits_bo[6] ),
    .d7_b( digits_bo[7] ),
    .end_step( end_step_o ), // to output end_step
    .busy( converter_busy_o )
);


// stage 3: select render digit
wire qclk_o;
clock_divider divider(
    .clk( clk_i ),
    .quotient_clk( qclk_o )   
);

defparam divider.DIVISOR = FN_DIVISOR;

wire [2:0] nr_digit_bo;
digit_selector selector(
    .clk( qclk_o ),
    .nr_digit_b( nr_digit_bo )
);

wire [3:0] render_digit_bo;
bcd_control controller(
    .nr_digit_b( nr_digit_bo ),
    .d0_b( digits_bo[0] ),
    .d1_b( digits_bo[1] ),
    .d2_b( digits_bo[2] ),
    .d3_b( digits_bo[3] ),
    .d4_b( digits_bo[4] ),
    .d5_b( digits_bo[5] ),
    .d6_b( digits_bo[6] ),
    .d7_b( digits_bo[7] ),
    .digit_b( render_digit_bo )
);


// stage 4: form control signals to anodes and cathodes
bcd_to_cathodes cathodes_controller(
    .digit_b( render_digit_bo ),
    .cathodes_b( cathodes_bo ) // [ DP, CG, CF, CE, CD, CC, CB, CA ]
);

bcd_to_anodes anodes_controller(
    .nr_digit_b( nr_digit_bo ),
    .anodes_b( anodes_bo )
);

assign busy_o = converter_busy_o | fn_busy_o;
endmodule