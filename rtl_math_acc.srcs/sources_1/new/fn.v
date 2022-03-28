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
localparam IDLE = 1'b0; // digital literal 1'b0 == 0b0
localparam WORK = 1'b1; // digital literal 1'b1 == 0b1

wire end_step;
reg [7:0] a, b;
reg start_mult = 0;
reg state;
wire mult_busy, sqrt_busy; 
wire [15:0] mult_y;
wire [7:0] sqrt_y;

square_rt square_rt_1(
    .clk_i( clk_i ),
    .rst_i( rst_i ),
    .x_bi( b ),
    .start_i( start_i ),
    .busy_o( sqrt_busy ),
    .y_bo( sqrt_y )
);

mult mult_1(
    .clk_i( clk_i ),
    .rst_i( sqrt_busy | rst_i ),
    .a_bi( a ),
    .b_bi( sqrt_y ),
    .start_i( start_mult ),
    .busy_o( mult_busy ),
    .y_bo( mult_y ) 
);

// connect registers with wires
assign busy_o = state;
assign end_step = ( ~mult_busy & ~sqrt_busy );

// @ ( <cond> ) -- block triggered at event <cond>
// always -- block always executes unlike initial that only at the beginning
always @( posedge clk_i )
    if ( rst_i ) begin
        state <= IDLE;
        y_bo <= 0;
        start_mult <= 0;
    end else begin
        case ( state )
            IDLE:
                if ( start_i ) begin
                    state <= WORK;
                    
                    a <= a_bi;
                    b <= b_bi;
                    start_mult <= ~sqrt_busy & start_i;
                end
            WORK:
                begin
                    if ( end_step ) begin
                        state <= IDLE;
                        y_bo <= mult_y;
                    end
                    
                    start_mult <= ~sqrt_busy & start_i;
                end
        endcase
    end
endmodule
