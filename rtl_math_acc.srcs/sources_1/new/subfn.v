`timescale 1ns / 1ps

// to extend simulation time enter next line in tcl console:
// run x [ns,us,ms,s]

/**
 * So, what states should multiplier contain?
 * 1. DISABLED/POWER OFF/RESET: all possible registers are 0
 * 2. IDLE: don't see differences between 1, so maybe we can unite them
 * 3. REQUEST_ACCEPTED: all input parameters latched and busy set to 1
 * 4. WORK: calculations until end_step return to IDLE
 */
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

// some useful constants
localparam CTR_DEFAULT = 3'b0;
localparam CTR_LIMIT = 3'h7;

// states list:
// localparam ST_RESET = 2'b00;
localparam ST_IDLE = 2'b01;
localparam ST_REQUEST_ACCEPTED = 2'b10;
localparam ST_WORK = 2'b11;

reg [1:0] state;

// fms description
always @( posedge clk_i )
    case ( state )
        ST_IDLE: state <= 
            ( rst_i )? ST_IDLE : 
            ( start_i )? ST_REQUEST_ACCEPTED : state;
            
        ST_REQUEST_ACCEPTED: state <=
            ( rst_i )? ST_IDLE : ST_WORK;
            
        ST_WORK: state <= ( rst_i | end_step_bo )? ST_IDLE : state;
        default: state <= ( rst_i )? ST_IDLE : state;
    endcase


reg [2:0] ctr;

wire [2:0] next_ctr; assign next_ctr = ctr + 1;

// ctr behaviour description
always @( posedge clk_i )
    if ( rst_i )
        ctr <= CTR_DEFAULT;
    else
        case ( state )
            ST_IDLE: ctr <= ctr;
            ST_REQUEST_ACCEPTED: ctr <= CTR_DEFAULT;
            ST_WORK: ctr <= ( end_step_bo )? CTR_DEFAULT : next_ctr;
            default: ctr <= ctr;
        endcase

assign end_step_bo = ctr == CTR_LIMIT;


// busy_o behaviour description
always @( posedge clk_i )
    if ( rst_i )
        busy_o <= 0;
    else
        case ( state )
            ST_IDLE: busy_o <= busy_o;
            ST_REQUEST_ACCEPTED: busy_o <= 1;
            ST_WORK: busy_o <= ( end_step_bo )? 0 : 1;
            default: busy_o <= busy_o;
        endcase


// y_bo behaviour description
always @( posedge clk_i )
    if ( rst_i )
        y_bo <= 0;
    else
        case ( state )
            ST_IDLE: y_bo <= y_bo;
            ST_REQUEST_ACCEPTED: y_bo <= 0;
            ST_WORK:
                case ( b_bi[ ctr ] )
                    1: y_bo <= ( a_bi << ctr ) + y_bo;
                    0: y_bo <= y_bo;
                endcase
            default: y_bo <= y_bo;
        endcase

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