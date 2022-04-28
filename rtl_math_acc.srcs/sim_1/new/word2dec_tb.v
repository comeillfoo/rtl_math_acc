`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.04.2022 00:40:09
// Design Name: 
// Module Name: word2dec_tb
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


module word2dec_tb;

reg [15:0] x; 
wire [3:0] digits [4:0];

word2dec dc_x(
    .word(x),
    .n0(digits[0]),
    .n1(digits[1]),
    .n2(digits[2]),
    .n3(digits[3]),
    .n4(digits[4])
);

reg [15:0] expected_val;
reg [15:0] test_val;

integer i;
initial begin
    
    for ( i = 0; i < 65536; i = i + 1 ) begin
        x = i;
        expected_val = i;
        #1
        test_val = ( ( ( ( ( digits[4] * 10 ) + digits[3]) * 10 ) + digits[2] ) * 10 + digits[1] ) * 10 + digits[0];
        if ( test_val == expected_val )
            $display( "CORRECT: actual: %d%d%d%d%d, expected: %d", digits[4], digits[3], digits[2], digits[1], digits[0], expected_val );
        else
            $display( "ERROR: actual: %d%d%d%d%d, expected: %d", digits[4], digits[3], digits[2], digits[1], digits[0], expected_val );
    end
    #1 $stop;
end
endmodule
