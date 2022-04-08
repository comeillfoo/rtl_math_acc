`timescale 1ns / 1ps


module mult_tb( );

reg clk, rst;
reg [7:0] a, b;
wire start, busy, end_step;
wire [15:0] y;

assign start = ~rst;

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
    for ( i = 0; i < 256; i = i + 1 ) begin
        for ( j = 0; j < 256; j = j + 1 ) begin
            rst = 1;
            a = 0;
            b = 0;
            
            #10
            expected_val = i * j;
            
            a = i;
            b = j;
            rst = 0;
            
            #170
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
