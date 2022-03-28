`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.03.2022 20:17:33
// Design Name: 
// Module Name: square_rt
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


module square_rt(
    input clk_i,
    input rst_i,
    input [7:0] x_bi,
    input start_i,
    output busy_o,
    output reg [7:0] y_bo
);

localparam IDLE = 1'b0;
localparam WORK = 1'b1;
localparam START = 6'sd6;
localparam FINISH = 6'sd0;
reg state = IDLE;

reg [7:0] m;
wire [7:0] end_step;

assign end_step = ( m == FINISH );
assign busy_o = state;

reg [7:0] b;
reg [7:0] x;
reg [7:0] y_b; 

always @( posedge clk_i )
    if ( rst_i ) begin
        state <= IDLE;
        m <= 1 << START;
        y_b <= 0;
        y_bo <= 0;
    end else begin
        case ( state )
            IDLE:
                if ( start_i ) begin
                    state <= WORK;
                    m <= 1 << START;
                    x <= x_bi;
                end
            WORK:
                begin
                    if ( end_step ) begin
                        state <= IDLE;
                        y_bo <= y_b;
                    end
                    
                    b = y_b | m;
                    y_b = y_b >> 1;
                    
                    if ( x >= b ) begin
                        x = x - b;
                        y_b = y_b | m;
                    end
                    
                    m = m >> 2;
                end
        endcase
    end
endmodule