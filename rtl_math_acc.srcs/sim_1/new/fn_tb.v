`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.03.2022 21:43:28
// Design Name: 
// Module Name: fn_tb
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


module fn_tb( );

reg clk, rst;
reg [7:0] a, b;
wire busy, start;
wire [15:0] y;

assign start = ~rst;

fn fn_1(
    .clk_i( clk ),
    .rst_i( rst ),
    .a_bi( a ),
    .b_bi( b ),
    .start_i( start ),
    .busy_o( busy ),
    .y_bo( y )
);

integer i, j;
reg [7:0] test_val_a;
reg [7:0] test_val_b;
reg [15:0] expected_val;

always #10 clk = ~clk;

initial begin
    clk = 1'b1;
    for ( i = 2; i < 256; i = i + 1 ) begin
        for ( j = 0; j < 16; j = j + 1 ) begin 
            rst = 1'b1;
            a = 0;
            b = 0;
            
            #10
            test_val_a = i;
            test_val_b = j * j;
            expected_val = i * j;
            
            a = i;
            b = j * j;
            rst = 1'b0;
            
            #150
            if ( expected_val == y ) begin
                $display( "CORRECT: actual: %d, expected: %d", y, expected_val );
            end else begin
                $display( "ERROR: actual: %d, expected: %d, a: %d, b: %d", y, expected_val, a, b );
            end
        end
    end
    
    rst = 1'b1;
    #80 $stop;
end
endmodule
