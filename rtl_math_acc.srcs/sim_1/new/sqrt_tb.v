`timescale 1ns / 1ps


module sqrt_tb( );

reg clk, rst;
reg [7:0] x;
wire start, busy, end_step;
wire [7:0] y;

assign start = ~rst;

sqrt s(
    .clk_i( clk ),
    .rst_i( rst ),
    .start_i( start ),
    .x_bi( x ),
    .y_bo( y ),
    .busy_o( busy ),
    .end_step_o( end_step )
);

always #10 clk = ~clk;

reg [7:0] expected_val;

integer i;
initial begin
    clk = 1;
    for ( i = 0; i < 16; i = i + 1 ) begin
        rst = 1;
        x = i * i;
        
        #10
        expected_val = i;
        
        rst = 0;
        
        #90
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
