`timescale 1ns / 1ps


module func_tb( );

reg clk, rst;
reg [7:0] a;
reg [7:0] b;
wire start, f_busy, end_step;
wire [15:0] y;

assign start = ~rst;

func f(
    .clk( clk ),
    .rst( rst ),
    .start( start ),
    .a_b( a ),
    .b_b( b ),
    .y_b( y ),
    .busy( f_busy ),
    .end_step_b( end_step )
);

always #10 clk = ~clk;

reg [15:0] expected_val;

integer i, j;
initial begin
    clk = 1;
    for ( i = 0; i < 256; i = i + 1 ) begin
        for ( j = 0; j < 16; j = j + 1 ) begin
            b = j * j;
            a = i;
            rst = 1;
            
            #10
            expected_val = i * j;
            rst = 0;
            
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
