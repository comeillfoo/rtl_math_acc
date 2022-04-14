`timescale 1ns / 1ps

/**
 * 
 */
module func(
    input clk,
    input rst,
    input start,
    input [7:0] a_b,
    input [7:0] b_b,
    output wire [15:0] y_b,
    output wire busy,
    output [2:0] end_step_b
);

// prototype sqrt module
// the module signals:
// reg s_start_i, s_rst_i;
reg [7:0] s_x_bi;
wire [7:0] s_y_bo;
wire s_busy_o, s_end_step_bo;

// the module itself:
sqrt s(
    .clk_i( clk ),
    .rst_i( rst ),
    .start_i( start ),
    .x_bi( s_x_bi ),
    .y_bo( s_y_bo ),
    .busy_o( s_busy_o ),
    .end_step_bo( s_end_step_bo )
);


// list of states:
localparam ST_IDLE = 2'b01;
localparam ST_SQRT_WORK = 2'b10;
localparam ST_MULT_WORK = 2'b11;

reg [1:0] state;

// fms description
always @( posedge clk )
    case ( state )
        ST_IDLE: state <= 
            ( rst )? ST_IDLE : 
            ( start )? ST_SQRT_WORK : state;
            
        ST_SQRT_WORK: state <=
            ( rst )? ST_IDLE :
            ( s_end_step_bo )? ST_MULT_WORK : state;
        
        ST_MULT_WORK: state <=
            ( rst | end_step_b )? ST_IDLE : state;
            
        default: state <=
            ( rst )? ST_IDLE : state;
    endcase


// sqrt start and reset behavioural description
// suppose sqrt start ans reset are external start and reset 


// x behavioural description
always @( posedge clk )
    case ( state )
        ST_IDLE: s_x_bi <= ( start )? b_b : s_x_bi;
        ST_SQRT_WORK: s_x_bi <= b_b;
        ST_MULT_WORK: s_x_bi <= s_x_bi;
        default: s_x_bi <= s_x_bi;
    endcase


// prototype mult module
// the module signals
reg [7:0] m_a_bi;
reg [7:0] m_b_bi;
wire m_busy_o;
wire [15:0] m_y_bo;

// the module itself
mult m(
    .clk_i( clk ),
    .rst_i( rst ),
    .start_i( s_end_step_bo ),
    .a_bi( m_a_bi ),
    .b_bi( m_b_bi ),
    .y_bo( m_y_bo ),
    .busy_o( m_busy_o ),
    .end_step_bo( end_step_b )
);


// multiplier inputs behavioural description
always @( posedge clk )
    case ( state )
        ST_IDLE: begin
            m_a_bi <= m_a_bi;
            m_b_bi <= m_b_bi;
        end
        ST_SQRT_WORK:
            if ( s_end_step_bo ) begin
                m_a_bi <= a_b;
                m_b_bi <= s_y_bo;
            end
            
        ST_MULT_WORK: begin
            m_a_bi <= m_a_bi;
            m_b_bi <= m_b_bi;
        end
        default: begin
            m_a_bi <= m_a_bi;
            m_b_bi <= m_b_bi;
        end
    endcase

// the total function behavioural description
assign busy = s_busy_o | m_busy_o;
assign y_b = m_y_bo;

endmodule
