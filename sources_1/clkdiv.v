`timescale 1ns / 1ps

module clkdiv(
    input wire mclk,
    output wire clk25,
    output wire clkHz
    );
    reg [24:0] q;
    
    // 25-bit counter
    always @ (posedge mclk)
    begin
            q <= q + 1;
    end
    assign clk25 = q[1];    // 25 MHz
    assign clkHz = q[19];    
endmodule
