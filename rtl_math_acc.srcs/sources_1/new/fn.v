`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.03.2022 21:22:52
// Design Name: 
// Module Name: whip_fun
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


module fn(
        input clk_i,
        input rst_i,
        input [7:0] a_bi,
        input [7:0] b_bi,
        input start_i,
        output busy_o,
        output reg [15:0] y_bo
);
// localparam -- local constants unlike parameter cannot be redefined or modified by defparam
localparam IDLE = 2'h0; // digital literal 1'b0 == 0b0
localparam WORK_SQRT = 2'h1; // digital literal 1'b1 == 0b1
localparam WORK_MULT = 2'h2;

reg [1:0] state = IDLE;
reg [7:0] a, b;
wire [7:0] sqrt_bo;
wire [15:0] mult_bo;
// reg [1:0] start;
wire [1:0] busy;

square_rt square_rt_1(
    .clk_i( clk_i ),
    .rst_i( rst_i ),
    .x_bi( b ),
    .start_i( state[ 0 ] ),
    .busy_o( busy[ 0 ] ),
    .y_bo( sqrt_bo )
);

mult mult_1(
    .clk_i( clk_i ),
    .rst_i( rst_i ),
    .a_bi( a ),
    .b_bi( sqrt_bo ),
    .start_i( state[ 1 ] ),
    .busy_o( busy[ 1 ] ),
    .y_bo( mult_bo ) 
);

// connect registers with wires
assign busy_o = state == IDLE? 0 : 1;

// @ ( <cond> ) -- block triggered at event <cond>
// always -- block always executes unlike initial that only at the beginning
always @( posedge clk_i )
    if ( rst_i ) begin
        state <= IDLE;
        
        a <= 0;
        b <= 0;
        y_bo <= 0;
    end else begin
        case ( state )
            IDLE:
                if ( start_i ) begin
                    state <= WORK_SQRT;
                    
                    b <= b_bi;
                end
            WORK_SQRT:
                if ( ~busy[ 0 ] ) begin
                    state <= WORK_MULT;
                    
                    a <= a_bi;
                end
            WORK_MULT:
                if ( ~busy[ 1 ] ) begin
                    state <= IDLE;
                    y_bo <= mult_bo;
                end
        endcase
    end
endmodule
