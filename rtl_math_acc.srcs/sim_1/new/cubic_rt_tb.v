`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.03.2022 22:12:07
// Design Name: 
// Module Name: cubic_rt_tb
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


module cubic_rt_tb( );

    reg clk, rst, start;
    reg [7:0] x;
    wire busy;
    wire [7:0] y;
    cubic_rt cubic_rt_1( 
        .clk_i( clk ),
        .rst_i( rst ),
        .start_i( start ),
        .x_bi( x ),
        .busy_o( busy ),
        .y_bo( y ) 
    );
    
    integer i;
    reg [7:0] test_val;
    reg [7:0] expected_val;
    
    always #10 clk = ~clk;
    
    initial begin
        clk = 1'b1;
        for ( i = 0; i < 7; i = i + 1 ) begin
            rst = 1'b1;
            start = 1'b0;
            x = 0;
            
            #10
            test_val = i * i * i;
            expected_val = i;
            
            rst = 1'b0;
            x = i * i * i;
            start = 1'b1;
            
            #110
            if ( expected_val == y ) begin
                $display( "CORRECT: actual: %d, expected: %d", y, expected_val );
            end else begin
                $display( "ERROR: actual: %d, expected: %d, x: %d", y, expected_val, x );
            end
        end
        
        rst = 1'b1;
        start = 1'b0;
        #20 $stop;
    end
endmodule
