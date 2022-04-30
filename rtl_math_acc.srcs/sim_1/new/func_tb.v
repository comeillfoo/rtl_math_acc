`timescale 1ns / 1ps


module func_tb;

reg clk, rst, start;
reg [7:0] a;
reg [7:0] b;
wire f_busy, f_end_step;
wire [15:0] y;


func f(
    .clk( clk ),
    .rst( rst ),
    .start( start ),
    .a_b( a ),
    .b_b( b ),
    .y_b( y ),
    .busy( f_busy ),
    .end_step( f_end_step )
);

always #10 clk = ~clk;

reg [15:0] expected_val;

integer i, j;
initial begin
    clk = 1;
    rst = 1;
    start = 0;
    for ( i = 215; i < 256; i = i + 1 ) begin
        for ( j = 0; j < 16; j = j + 1 ) begin
            a = 0;
            b = 0;
            
            #20
            expected_val = i * j;
            a = i;
            b = j * j;
            
            rst = 0;
            start = 1;
            
            #10
            start = 0;
            
            #290
            if ( expected_val == y ) begin
                $display( "CORRECT: actual: %d, expected: %d", y, expected_val );
            end else begin
                $display( "ERROR: actual: %d, expected: %d, a: %d, b: %d", y, expected_val, i, j * j );
            end
        end
    end
    rst = 1;
    #80 $stop;
end

endmodule
