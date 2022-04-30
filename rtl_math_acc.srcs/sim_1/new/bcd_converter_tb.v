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

reg clk_i, start_i, rst_i;
reg [15:0] x; 
wire [3:0] digits [7:0];
wire busy_o, end_step_o;

bcd_converter converter(
    .clk(clk_i),
    .start(start_i),
    .rst(rst_i),
    .half_word_b(x),
    .d0_b(digits[0]),
    .d1_b(digits[1]),
    .d2_b(digits[2]),
    .d3_b(digits[3]),
    .d4_b(digits[4]),
    .d5_b(digits[5]),
    .d6_b(digits[6]),
    .d7_b(digits[7]),
    .end_step(end_step_o),
    .busy(busy_o)
);

always #10 clk_i = ~clk_i;

reg [15:0] expected_val;
reg [15:0] test_val;

integer i;
initial begin
    clk_i = 1;
    rst_i = 1;
    start_i = 0;
    #20
    rst_i = 0;
    for ( i = 0; i < 65536; i = i + 1 ) begin
        x = i;
        expected_val = i;
        test_val = 0;
        start_i = 1;
        
        #10
        start_i = 0;
        
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
