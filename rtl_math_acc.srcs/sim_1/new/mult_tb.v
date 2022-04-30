`timescale 1ns / 1ps


module mult_tb( );

reg clk, rst, start;
reg [7:0] a, b;
wire busy, end_step;
wire [15:0] y;

mult m(
    .clk_i( clk ),
    .rst_i( rst ),
    .start_i( start ),
    .a_bi( a ),
    .b_bi( b ),
    .y_bo( y ),
    .busy_o( busy ),
    .end_step_o( end_step )
);

always #10 clk = ~clk;

reg [15:0] expected_val;

integer i, j;
initial begin
    clk = 1;
    rst = 1;
    start = 0;
    for ( i = 1; i < 256; i = i + 1 ) begin
        for ( j = 1; j < 256; j = j + 1 ) begin
            a = 0;
            b = 0;
            
            #20
            expected_val = i * j;
            
            a = i;
            b = j;
            rst = 0;
            start = 1;
            #10
            start = 0;
            
            #190
            if ( expected_val == y ) begin
                $display( "CORRECT: actual: %d, expected: %d", y, expected_val );
            end else begin
                $display( "ERROR: actual: %d, expected: %d, a: %d, b: %d", y, expected_val, a, b );
            end
            
        end
    end
    
    rst = 1;
    #80 $stop;
end

endmodule
