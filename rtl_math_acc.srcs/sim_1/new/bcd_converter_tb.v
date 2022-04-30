`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/30/2022 03:49:42 AM
// Design Name: 
// Module Name: bcd_converter_tb
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


module bcd_converter_tb;

reg clk, start, rst;
reg [15:0] x; 
wire [3:0] digits [7:0];
wire [3:0] end_step;
wire busy;

bcd_converter converter(
    .clk_i(clk),
    .start_i(start),
    .rst_i(rst),
    .half_word_bi(x),
    .d0_bo(digits[0]),
    .d1_bo(digits[1]),
    .d2_bo(digits[2]),
    .d3_bo(digits[3]),
    .d4_bo(digits[4]),
    .d5_bo(digits[5]),
    .d6_bo(digits[6]),
    .d7_bo(digits[7]),
    .end_step_bo(end_step),
    .busy_o(busy)
);

always #10 clk = ~clk;

reg [15:0] expected_val;
reg [15:0] test_val;

integer i;
initial begin
    clk = 1;
    rst = 1;
    start = 0;
    #20
    rst = 0;
    for ( i = 0; i < 65536; i = i + 1 ) begin
        x = i;
        expected_val = i;
        test_val = 0;
        start = 1;
        
        #10
        start = 0;
        
        #330
        test_val = ((((((( digits[7] * 10 ) * 10
            + digits[6] ) * 10
            + digits[5] ) * 10
            + digits[4] ) * 10
            + digits[3] ) * 10
            + digits[2] ) * 10
            + digits[1] ) * 10
            + digits[0];
        
        
        if ( test_val == expected_val )
            $display( "CORRECT: actual: %d%d%d%d%d%d%d%d, expected: %d", digits[7], digits[6], digits[5], digits[4], digits[3], digits[2], digits[1], digits[0],
                expected_val );
        else
            $display( "ERROR: actual: %d%d%d%d%d%d%d%d, expected: %d", digits[7], digits[6], digits[5], digits[4], digits[3], digits[2], digits[1], digits[0],
                expected_val );
    end
    #10 $stop;
end
    
endmodule
