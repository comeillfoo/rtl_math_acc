`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/30/2022 03:04:13 AM
// Design Name: 
// Module Name: display_wrappers
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

// divides main clock of 100 MHz to 2 Hz for 7 segment display refreshment rate
module clock_divider
    #(parameter DIVISOR = 50_000_000) (
    input clk,
    output reg quotient_clk = 0   
);
localparam divisor = DIVISOR - 1; // 2 Hz

integer counter = 0;

always @( posedge clk )
    if ( counter == divisor )
        counter <= 0;
    else
        counter <= counter + 1;

always @( posedge clk )
    if ( counter == divisor )
        quotient_clk <= ~quotient_clk;

endmodule


// counter to select digit
module digit_selector(
    input clk,
    output reg [2:0] nr_digit_b = 0
);

always @( posedge clk )
    nr_digit_b <= nr_digit_b + 1;

endmodule


// converts binary to BCD using Double Dabble Algorithm
module bcd_converter(
    input clk,
    input start,
    input rst,
    input [15:0] half_word_b,
    output [3:0] d0_b,
    output [3:0] d1_b,
    output [3:0] d2_b,
    output [3:0] d3_b,
    output [3:0] d4_b,
    output [3:0] d5_b,
    output [3:0] d6_b,
    output [3:0] d7_b,
    output end_step,
    output busy
); // yeap 8 digits contains 7 segment display

localparam ST_IDLE = 2'b00;
localparam ST_WORK = 2'b01;
localparam CTR_LIMIT = 15;

reg [1:0] state;
reg [4:0] ctr;
reg [31:0] bcd_actual; 
reg [3:0] digits [7:0];
wire [31:0] bcd_shifted; assign bcd_shifted = {bcd_actual[30:0], half_word_b[15 - ctr]};
wire [31:0] bcd_increased;

assign bcd_increased[ 3: 0] = ( ctr < CTR_LIMIT && bcd_shifted[ 3: 0] > 4 )? bcd_shifted[ 3: 0] + 3 : bcd_shifted[ 3: 0];
assign bcd_increased[ 7: 4] = ( ctr < CTR_LIMIT && bcd_shifted[ 7: 4] > 4 )? bcd_shifted[ 7: 4] + 3 : bcd_shifted[ 7: 4];
assign bcd_increased[11: 8] = ( ctr < CTR_LIMIT && bcd_shifted[11: 8] > 4 )? bcd_shifted[11: 8] + 3 : bcd_shifted[11: 8];
assign bcd_increased[15:12] = ( ctr < CTR_LIMIT && bcd_shifted[15:12] > 4 )? bcd_shifted[15:12] + 3 : bcd_shifted[15:12];
assign bcd_increased[19:16] = ( ctr < CTR_LIMIT && bcd_shifted[19:16] > 4 )? bcd_shifted[19:16] + 3 : bcd_shifted[19:16];
assign bcd_increased[23:20] = ( ctr < CTR_LIMIT && bcd_shifted[23:20] > 4 )? bcd_shifted[23:20] + 3 : bcd_shifted[23:20];
assign bcd_increased[27:24] = ( ctr < CTR_LIMIT && bcd_shifted[27:24] > 4 )? bcd_shifted[27:24] + 3 : bcd_shifted[27:24];
assign bcd_increased[31:28] = ( ctr < CTR_LIMIT && bcd_shifted[31:28] > 4 )? bcd_shifted[31:28] + 3 : bcd_shifted[31:28];

always @( posedge clk ) begin
    if ( rst ) begin
        state <= ST_IDLE;
        ctr <= 0;
        bcd_actual <= 0;
        { digits[7], digits[6], digits[5], digits[4],
            digits[3], digits[2], digits[1], digits[0] } <= 0;
    end else
        case ( state )
            ST_IDLE:
                if ( start ) begin
                    state <= ST_WORK;
                    bcd_actual <= 0;
                    ctr <= 0;
                end
            ST_WORK:
                if ( end_step ) begin
                    state <= ST_IDLE;
                    ctr <= 0;
                    bcd_actual <= 0;
                    { digits[7], digits[6], digits[5], digits[4],
                        digits[3], digits[2], digits[1], digits[0] } <= bcd_increased;  
                end else begin                  
                    ctr <= ctr + 1;
                    bcd_actual <= bcd_increased;
                end
        endcase
end

assign end_step = ( ctr == CTR_LIMIT );

assign d0_b = digits[0];
assign d1_b = digits[1];
assign d2_b = digits[2];
assign d3_b = digits[3];
assign d4_b = digits[4];
assign d5_b = digits[5];
assign d6_b = digits[6];
assign d7_b = digits[7];

assign busy = ( state == ST_WORK );

endmodule


// multiplexer MX8_1 with buses
module bcd_control(
    input [2:0] nr_digit_b,
    input [3:0] d0_b, d1_b, d2_b, d3_b, d4_b, d5_b, d6_b, d7_b,
    output reg [3:0] digit_b
);

always @(*)
    case ( nr_digit_b )
        3'd0:
            digit_b = d0_b;
        3'd1:
            digit_b = d1_b;
        3'd2:
            digit_b = d2_b;
        3'd3:
            digit_b = d3_b;
        3'd4:
            digit_b = d4_b;
        3'd5:
            digit_b = d5_b;
        3'd6:
            digit_b = d6_b;
        3'd7:
            digit_b = d7_b;
        default:
            digit_b = d0_b;
    endcase

endmodule


// transforms BCD digit into cathodes' control signals
module bcd_to_cathodes(
    input [3:0] digit_b,
    output reg [7:0] cathodes_b // [ DP, CG, CF, CE, CD, CC, CB, CA ]
);

always @( digit_b )
    case ( digit_b )
        4'd0:
            cathodes_b = 8'b1100_0000;
        4'd1:
            cathodes_b = 8'b1111_1001;
        4'd2:
            cathodes_b = 8'b1010_0100;
        4'd3:
            cathodes_b = 8'b1011_0000;
        4'd4:
            cathodes_b = 8'b1001_1001;
        4'd5:
            cathodes_b = 8'b1001_0010;
        4'd6:
            cathodes_b = 8'b1000_0010;
        4'd7:
            cathodes_b = 8'b1111_1000;
        4'd8:
            cathodes_b = 8'b1000_0000;
        4'd9:
            cathodes_b = 8'b1001_0000;
        default:
            cathodes_b = 8'b0111_1111;
    endcase

endmodule


module bcd_to_anodes(
    input [2:0] nr_digit_b,
    output reg [7:0] anodes_b
);

always @( nr_digit_b )
    case ( nr_digit_b )
        3'd0:
            anodes_b = 8'b1111_1110;
        3'd1:
            anodes_b = 8'b1111_1101;
        3'd2:
            anodes_b = 8'b1111_1011;
        3'd3:
            anodes_b = 8'b1111_0111;
        3'd4:
            anodes_b = 8'b1110_1111;
        3'd5:
            anodes_b = 8'b1101_1111;
        3'd6:
            anodes_b = 8'b1011_1111;
        3'd7:
            anodes_b = 8'b0111_1111;
        default:
            anodes_b = 8'b1111_1110;
    endcase

endmodule
