`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.03.2022 22:21:17
// Design Name: 
// Module Name: adder
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


module mult(
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
        // 4'b0110 == 0b0110
        reg [2:0] ctr;
        wire [2:0] end_step;
        wire [2:0] part_sum;
        wire [15:0] shifted_part_sum;
        reg [7:0] a, b;
        reg [15:0] part_res;
        reg state;
        
        // connect registers with wires
        assign part_sum = a & {8{b[ctr]}}; // {8{b[ctr]}} -> b[ctr]b[ctr]b[ctr]b[ctr]b[ctr]b[ctr]b[ctr]b[ctr]
        assign shifted_part_sum = part_sum << ctr;
        assign end_step = (ctr == 3'h7); // 3'h7 -> 0x7?
        assign busy_o = state;
        
        // @ ( <cond> ) -- block triggered at event <cond>
        // always -- block always executes unlike initial that only at the beginning
        always @( posedge clk_i )
            if ( rst_i ) begin
                ctr <= 0;
                part_res <= 0;
                y_bo <= 0;
                state <= IDLE;
            end else begin
                case ( state )
                    IDLE:
                        if ( start_i ) begin
                            state <= WORK;
                            
                            a <= a_bi;
                            b <= b_bi;
                            ctr <= 0;
                            part_res <= 0;
                        end
                    WORK:
                        begin
                            if ( end_step ) begin
                                state <= IDLE;
                                y_bo <= part_res;
                            end
                            
                            part_res <= part_res + shifted_part_sum;
                            ctr <= ctr + 1;
                        end
                endcase
            end
endmodule
