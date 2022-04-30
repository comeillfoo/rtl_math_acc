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

// converts binary to BCD using Double Dabble Algorithm
module bcd_converter(
    input clk_i,
    input start_i,
    input rst_i,
    input [15:0] half_word_bi,
    output [3:0] d0_bo,
    output [3:0] d1_bo,
    output [3:0] d2_bo,
    output [3:0] d3_bo,
    output [3:0] d4_bo,
    output [3:0] d5_bo,
    output [3:0] d6_bo,
    output [3:0] d7_bo,
    output [3:0] end_step_bo,
    output busy_o
); // yeap 8 digits contains 7 segment display

localparam ST_IDLE = 2'b00;
localparam ST_WORK = 2'b01;
localparam CTR_FINAL = 16;
localparam CTR_LIMIT = CTR_FINAL - 1;

reg [1:0] state;
reg [4:0] ctr;
reg [31:0] bcd_actual; 
reg [3:0] digits [7:0];
wire [31:0] bcd_shifted; assign bcd_shifted = {bcd_actual[30:0], half_word_bi[15 - ctr]};
wire [31:0] bcd_increased;

assign bcd_increased[ 3: 0] = ( ctr < CTR_LIMIT && bcd_shifted[ 3: 0] > 4 )? bcd_shifted[ 3: 0] + 3 : bcd_shifted[ 3: 0];
assign bcd_increased[ 7: 4] = ( ctr < CTR_LIMIT && bcd_shifted[ 7: 4] > 4 )? bcd_shifted[ 7: 4] + 3 : bcd_shifted[ 7: 4];
assign bcd_increased[11: 8] = ( ctr < CTR_LIMIT && bcd_shifted[11: 8] > 4 )? bcd_shifted[11: 8] + 3 : bcd_shifted[11: 8];
assign bcd_increased[15:12] = ( ctr < CTR_LIMIT && bcd_shifted[15:12] > 4 )? bcd_shifted[15:12] + 3 : bcd_shifted[15:12];
assign bcd_increased[19:16] = ( ctr < CTR_LIMIT && bcd_shifted[19:16] > 4 )? bcd_shifted[19:16] + 3 : bcd_shifted[19:16];
assign bcd_increased[23:20] = ( ctr < CTR_LIMIT && bcd_shifted[23:20] > 4 )? bcd_shifted[23:20] + 3 : bcd_shifted[23:20];
assign bcd_increased[27:24] = ( ctr < CTR_LIMIT && bcd_shifted[27:24] > 4 )? bcd_shifted[27:24] + 3 : bcd_shifted[27:24];
assign bcd_increased[31:28] = ( ctr < CTR_LIMIT && bcd_shifted[31:28] > 4 )? bcd_shifted[31:28] + 3 : bcd_shifted[31:28];

always @(posedge clk_i) begin
    if ( rst_i ) begin
        state <= ST_IDLE;
        ctr <= 0;
        bcd_actual <= 0;
        { digits[7], digits[6], digits[5], digits[4],
            digits[3], digits[2], digits[1], digits[0] } <= 0;
    end else
        case ( state )
            ST_IDLE:
                if ( start_i ) begin
                    state <= ST_WORK;
                    bcd_actual <= 0;
                    ctr <= 0;
                end
            ST_WORK:
                if ( end_step_bo ) begin
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

assign end_step_bo = ( ctr == CTR_LIMIT );

assign d0_bo = digits[0];
assign d1_bo = digits[1];
assign d2_bo = digits[2];
assign d3_bo = digits[3];
assign d4_bo = digits[4];
assign d5_bo = digits[5];
assign d6_bo = digits[6];
assign d7_bo = digits[7];

assign busy_o = ( state == ST_WORK );

endmodule


//module bcd_dc(
//    input [3:0] digit_bi,
//    output reg [7:0] cathodes_bo // [ DP, CG, CF, CE, CD, CC, CB, CA ]
//);

//always @(*) begin
//    //                        PGFE DCBA
//    case (digit_bi)
//        4'd0:
//            cathodes_bo <= 8'b1100_0000;
//        4'd1:
//            cathodes_bo <= 8'b1111_1001;
//        4'd2:
//            cathodes_bo <= 8'b1010_0100;
//        4'd3:
//            cathodes_bo <= 8'b1011_0000;
//        4'd4:
//            cathodes_bo <= 8'b1001_1001;
//        4'd5:
//            cathodes_bo <= 8'b1001_0010;
//        4'd6:
//            cathodes_bo <= 8'b1000_0010;
//        4'd7:
//            cathodes_bo <= 8'b1111_1000;
//        4'd8:
//            cathodes_bo <= 8'b1100_0000;
//        4'd9:
//            cathodes_bo <= 8'b1001_0000;
//        default:
//            cathodes_bo <= 8'b1111_1111;
//    endcase
//end

//endmodule
