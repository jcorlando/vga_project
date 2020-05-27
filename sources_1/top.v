`timescale 1ns / 1ps

module top(
    input wire mclk,
    input wire btnC, btnU, btnD, btnL, btnR,
    output wire Hsync, Vsync,
    output wire [3:0] vgaRed, vgaGreen, vgaBlue
    );
    wire clkHz, clk25, clr, display_On;
    wire [9:0] h_Counter, v_Counter;
    
    assign clr = btnC;
    
    clkdiv U1 (
        .mclk(mclk), .clk25(clk25), .clkHz(clkHz)
    );
    
    vga_640x480 U2 (
        .clk(clk25), .clr(clr), .hsync(Hsync), .vsync(Vsync),
            .h_Counter(h_Counter), .v_Counter(v_Counter), .display_On(display_On)
    );
    
    out_Put U3 (
        .display_On(display_On), .h_Counter(h_Counter), .v_Counter(v_Counter),
            .btn_U(btnU), .btn_D(btnD), .btn_L(btnL), .btn_R(btnR), .clkHz(clkHz),
                .clr(clr), .red(vgaRed), .green(vgaGreen), .blue(vgaBlue)
    );
endmodule
