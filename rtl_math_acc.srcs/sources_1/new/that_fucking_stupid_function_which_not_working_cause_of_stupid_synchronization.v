`timescale 1ns / 1ps

// to extend simulation time enter next line in tcl console:
// run x [ns,us,ms,s]

module mult(
    input clk_i,
    input rst_i,
    input start_i,
    input [7:0] a_bi,
    input [7:0] b_bi,
    output reg [15:0] y_bo,
    output reg busy_o,
    output [2:0] end_step_bo
);

localparam CTR_DEFAULT = 3'b0;
localparam CTR_LIMIT = 3'h7;

reg [2:0] ctr;
wire [2:0] next_ctr;

assign next_ctr = ctr + 1;
assign end_step_bo = ctr == CTR_LIMIT;

always @( posedge clk_i ) begin
    if ( rst_i ) begin
        ctr <= CTR_DEFAULT;
        busy_o <= 0;
    end
    else if ( start_i ) begin
        if ( end_step_bo ) begin
            ctr <= CTR_DEFAULT;
            busy_o <= 0;
        end else begin
            ctr <= next_ctr;
            busy_o <= 1;
        end
    end
end

always @( posedge clk_i ) begin
    if ( rst_i )
        y_bo <= 0;
    else if ( start_i ) begin
        case ( b_bi[ ctr ] )
            1: y_bo <= ( a_bi << ctr ) + y_bo;
            0: y_bo <= y_bo;
        endcase
    end
end

endmodule


module sqrt(
    input clk_i,
    input rst_i,
    input start_i,
    input [7:0] x_bi,
    output reg [7:0] y_bo,
    output reg busy_o,
    output [7:0] end_step_bo
);

localparam N = 8;
localparam M_DEFAULT = 1 << ( N - 2 );

reg [7:0] m;
reg [7:0] x;

wire [7:0] shifted_m;
wire [7:0] b;
wire is_xgeb;
wire [7:0] next_y;
wire [7:0] next_b;


assign shifted_m = m >> 2;
assign b = y_bo | m;
assign is_xgeb = x >= b;
assign end_step_bo = m == 0;
assign next_y = y_bo >> 1;
assign next_b = next_y | m;

always @( posedge clk_i ) begin
    if ( rst_i )
        y_bo <= 0;
    else if ( start_i ) begin
        case ( is_xgeb )
            1:
                y_bo <= next_b;
            0:
                y_bo <= next_y;
        endcase
    end
end

always @( posedge clk_i ) begin
    if ( rst_i ) begin
        m <= M_DEFAULT;
        busy_o <= 0;
    end else if ( start_i ) begin
        if ( end_step_bo ) begin
            m <= M_DEFAULT;
            busy_o <= 0;
        end else begin
            m <= shifted_m;
            busy_o <= 1;
        end
    end
end

always @( posedge clk_i ) begin
    if ( rst_i )
        x <= x_bi;
    else if ( start_i && is_xgeb )
        x <= x - b;   
end

endmodule