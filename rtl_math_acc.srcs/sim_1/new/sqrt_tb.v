`timescale 1ns / 1ps


module sqrt_tb( );

reg clk, rst, start;
reg [7:0] x;
wire busy, end_step;
wire [7:0] y;


sqrt s(
    .clk_i( clk ),
    .rst_i( rst ),
    .start_i( start ),
    .x_bi( x ),
    .y_bo( y ),
    .busy_o( busy ),
    .end_step_bo( end_step )
);

always #10 clk = ~clk;

reg [7:0] expected_val;

integer i;
initial begin
    clk = 1;
    rst = 1;
    start = 0;
    for ( i = 0; i < 16; i = i + 1 ) begin
        x = 0;
        
        #20
        expected_val = i;
        
        x = i * i;
        rst = 0;
        start = 1;
        #10
        start = 0;
        
        #110
        if ( expected_val == y ) begin
            $display( "CORRECT: actual: %d, expected: %d", y, expected_val );
        end else begin
            $display( "ERROR: actual: %d, expected: %d, x: %d", y, expected_val, i * i );
        end
    end
    
    rst = 1;
    #80 $stop;
end

endmodule
