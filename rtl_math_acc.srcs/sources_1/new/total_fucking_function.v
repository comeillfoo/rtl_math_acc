`timescale 1ns / 1ps


module func(
    input clk,
    input rst,
    input start,
    input [7:0] a_b,
    input [7:0] b_b,
    output reg [15:0] y_b,
    output reg busy,
    output [2:0] end_step_b
);

reg s_start_i, s_rst_i;
reg [7:0] s_x_bi;
wire [7:0] s_y_bo;
wire s_busy_o, s_end_step_bo;

always @( posedge clk ) begin
    if ( rst ) begin
        s_rst_i <= 1;
        s_start_i <= 0;
        s_x_bi <= b_b;
    end else if ( start ) begin
        if ( s_end_step_bo ) begin
            s_rst_i <= 0;
            s_start_i <= 0;
        end else begin
            s_rst_i <= 0;
            s_start_i <= 1;
        end
    end
end

sqrt s(
    .clk_i( clk ),
    .rst_i( s_rst_i ),
    .start_i( s_start_i ),
    .x_bi( s_x_bi ),
    .y_bo( s_y_bo ),
    .busy_o( s_busy_o ),
    .end_step_bo( s_end_step_bo )
);

reg m_start_i, m_rst_i;
reg [7:0] m_a_bi;
reg [7:0] m_b_bi;
wire m_busy_o;
wire [15:0] m_y_bo;

always @( posedge clk ) begin
    if ( rst ) begin
        m_rst_i <= 1;
        m_start_i <= 0;
        y_b <= 0;
    end else if ( s_end_step_bo ) begin
        m_rst_i <= 0;
        m_start_i <= 1;
        m_a_bi <= a_b;
        m_b_bi <= s_y_bo;
    end else if ( end_step_b ) begin
        m_rst_i <= 0;
        m_start_i <= 0;
        y_b <= m_y_bo;
    end
end

mult m(
    .clk_i( clk ),
    .rst_i( m_rst_i ),
    .start_i( m_start_i ),
    .a_bi( m_a_bi ),
    .b_bi( m_b_bi ),
    .y_bo( m_y_bo ),
    .busy_o( m_busy_o ),
    .end_step_bo( end_step_b )
);

always @( posedge clk ) begin
    if ( rst )
        busy <= 0;
    else if ( start )
        if ( end_step_b )
            busy <= 0;
        else
            busy <= 1;
end

endmodule
