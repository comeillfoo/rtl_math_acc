`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.03.2022 20:33:17
// Design Name: 
// Module Name: square_rt_tb
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


module square_rt_tb();
    reg clk, rst;
    reg [7:0] x;
    wire busy, start;
    wire [7:0] y;
    assign start = ~rst;
    
    square_rt square_rt_1( 
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
        for ( i = 0; i < 16; i = i + 1 ) begin
            rst = 1'b1;
            x = 0;
            
            #10
            test_val = i * i;
            expected_val = i;
            
            x = i * i;
            rst = 1'b0;
            
            #130
            if ( expected_val == y ) begin
                $display( "CORRECT: actual: %d, expected: %d", y, expected_val );
            end else begin
                $display( "ERROR: actual: %d, expected: %d, x: %d", y, expected_val, x );
            end
        end
        
        rst = 1'b1;
        #80 $stop;
    end
endmodule
