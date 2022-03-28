`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.03.2022 21:11:23
// Design Name: 
// Module Name: cubic_rt
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


module cubic_rt(
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
    localparam FINISH = -(6'sd3);
    reg state = IDLE;
    
    reg [5:0] s;
    wire [5:0] end_step;
    
    assign end_step = ( s == FINISH );
    assign busy_o = state;
    
    reg [7:0] b;
    reg [7:0] x;
    reg [7:0] y_b; 
    
    always @( posedge clk_i )
        if ( rst_i ) begin
            state <= IDLE;
            s <= START;
            y_bo <= 0;
            y_b <= 0;
        end else begin
            case ( state )
                IDLE:
                    if ( start_i ) begin
                        state <= WORK;
                        s <= START;
                        x <= x_bi;
                        y_b <= 0;
                        b <= 1 << s;
                    end
                WORK:
                    begin
                        if ( end_step ) begin
                            state <= IDLE;
                            y_bo <= y_b;
                        end
                        
                        y_b = y_b << 1;
                        b = ( 3 * y_b * ( y_b + 1 ) + 1 ) << s;
                        
                        if ( x >= b ) begin
                            x = x - b;
                            y_b = y_b + 1;
                        end
                        
                        s = s - 3;
                    end
            endcase
        end
endmodule
