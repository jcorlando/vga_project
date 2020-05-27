`timescale 1ns / 1ps

module vga_640x480(
    input wire clk,
    input wire clr,
    output reg hsync,
    output reg vsync,
    output reg [9:0] h_Counter,
    output reg [9:0] v_Counter,
    output reg display_On
    );
    parameter hpixels = 10'd800;
    // Value of pixels in a horizontal line = 800
    parameter vlines = 10'd525;
    // Number of horizontal lines in the display = 525
    parameter h_Back_Porch = 10'd112;
    // Horizontal back porch = 112 (96+16)
    parameter h_Front_Porch = 10'd752;
    // Horizontal Front porch = 752 (96+16+640)
    parameter v_Back_Porch = 10'd35;
    // Vertical back porch = 35 (2+33)
    parameter v_Front_Porch = 10'd515;
    // Vertical front porch = 515 (2+33+480)
    reg vsenable;   // Enable for the Vertical counter
    
    
    // Counter for the horizontal sync signal
    always @ (posedge clk or posedge clr)
    begin
        if(clr == 1)
            h_Counter <= 0;
        else
        begin
            if(h_Counter == hpixels - 1)
            begin
                // The counter has reached the end of pixel count
                h_Counter <= 0;
                vsenable <= 1;
                // Enable the vertical counter to increment
            end
            else
            begin
                h_Counter <= h_Counter + 1; // Increment the horizontal counter
                vsenable <= 0;
            end
        end
    end
    
    
    // Generate hsync pulse
    // Horizontal Sync Pulse is low when h_Counter is 0 - 95
    always @ (*)
    begin
        if(h_Counter < 96) hsync = 0;
        else hsync = 1;
    end
    
    // Counter for the vertical sync signal
    always @ (posedge clk or posedge clr)
    begin
        if(clr == 1)
            v_Counter <= 0;
        else
            if(vsenable == 1)
            begin
                if(v_Counter == vlines - 1)
                    // Reset when the number of lines is reached
                    v_Counter <= 0;
                else
                    v_Counter <= v_Counter +1;
            end
    end
    
    // Generate vsync pulse
    // Vertical Sync Pulse is low when h_Counter is 0 or 1
    always @ (*)
    begin
        if(v_Counter < 2) vsync = 0;
        else       vsync = 1;
    end
    
    // Enable video out when within the porches
    always @ (*)
    begin
        if( (h_Counter < h_Front_Porch) && (h_Counter > h_Back_Porch) && (v_Counter < v_Front_Porch) && (v_Counter > v_Back_Porch) )
            display_On = 1;
        else
            display_On = 0;
    end
endmodule
