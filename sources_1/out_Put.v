`timescale 1ns / 1ps

module out_Put(
    input wire display_On,
    input wire [9:0] h_Counter, v_Counter,
    input wire btn_U, btn_D, btn_L, btn_R,
    input wire clkHz,
    input wire clr,
    output reg [3:0] red, green, blue
    );
    
    // Screen Bounds
    localparam left_Bound = 113;
    localparam right_Bound = 751;
    localparam top_Bound = 36;
    localparam bot_Bound = 514;
    localparam midpoint = 271;
    localparam midpoint_Bot = 460;
    localparam midpoint_Top = 90;
    
    // wire for game over screen
    reg game_Over = 0;
    reg game_Start = 0;
    reg [8:0] random_Counter = midpoint_Top;
    
    // Counter for second and third pipes
    reg [15:0] counter = 0;
    
    // box information
    reg [10:0] box_X = 432;
    reg [10:0] box_Y = 271;
    reg [10:0] X_Left;
    reg [10:0] X_Right;
    reg [10:0] Y_Top;
    reg [10:0] Y_Bot;
    
    // Pipe 1 information
    reg [10:0] pipe_X = 763;
    reg [10:0] pipe_Y = bot_Bound;
    reg [10:0] p_1_Midpoint = midpoint;
    reg [10:0] p_X_Left;
    reg [10:0] p_X_Right;
    wire [10:0] p_Y_Top  = p_1_Midpoint + 40;
    reg [10:0] p_Y_Bot = bot_Bound;
    wire [10:0] p_Y_Top_Half_Bot = (p_1_Midpoint - 40);
    reg [10:0] p_Y_Top_Half_Top = top_Bound;
    
    // Pipe 2 information
    reg [10:0] pipe_2_X = 763;
    reg [10:0] pipe_2_Y = bot_Bound;
    reg [10:0] p_2_Midpoint = midpoint;
    reg [10:0] p_2_X_Left;
    reg [10:0] p_2_X_Right;
    wire [10:0] p_2_Y_Top = p_2_Midpoint + 40;
    reg [10:0] p_2_Y_Bot = bot_Bound;
    wire [10:0] p_2_Y_Top_Half_Bot = (p_2_Midpoint - 40);
    reg [10:0] p_2_Y_Top_Half_Top = top_Bound;
    
    // Pipe 3 information
    reg [10:0] pipe_3_X = 763;
    reg [10:0] pipe_3_Y = bot_Bound;
    reg [10:0] p_3_Midpoint = midpoint;
    reg [10:0] p_3_X_Left;
    reg [10:0] p_3_X_Right;
    wire [10:0] p_3_Y_Top = p_3_Midpoint + 40;
    reg [10:0] p_3_Y_Bot = bot_Bound;
    wire [10:0] p_3_Y_Top_Half_Bot = (p_3_Midpoint - 40);
    reg [10:0] p_3_Y_Top_Half_Top = top_Bound;
    
    // Update box and pipe x and y coordinates and calculate collision
    always @ (posedge clkHz)
    begin
        if(random_Counter <= midpoint_Bot - 1) random_Counter = random_Counter + 37;
        else random_Counter = midpoint_Top;
        
        if(game_Start)
        begin
            if(clr)
            begin
                box_X = 432;     box_Y = 271;
                counter = 0;
                pipe_X = 763;    pipe_Y = bot_Bound;
                pipe_2_X = 763;  pipe_2_Y = bot_Bound;
                pipe_3_X = 763;  pipe_3_Y = bot_Bound;
                game_Over = 0;
                game_Start = 0;
            end
            if(  (X_Right <= p_3_X_Left || X_Left >= p_3_X_Right 
                || ( (X_Left <= p_3_X_Right) && (Y_Top >= p_3_Y_Top_Half_Bot && Y_Bot <= p_3_Y_Top) ))
                  && (X_Right <= p_2_X_Left || X_Left >= p_2_X_Right 
                    || ( (X_Left <= p_2_X_Right) && (Y_Top >= p_2_Y_Top_Half_Bot && Y_Bot <= p_2_Y_Top) ))
                      && (X_Right <= p_X_Left || X_Left >= p_X_Right 
                        || ( (X_Left <= p_X_Right) && (Y_Top >= p_Y_Top_Half_Bot && Y_Bot <= p_Y_Top) ) ) )
            begin
                if( btn_U && Y_Top > top_Bound )                box_Y = box_Y - 4;
                else if( Y_Bot < bot_Bound )                    box_Y = box_Y + 3;
                if( btn_L && X_Left > left_Bound )              box_X = box_X - 2;
                if( btn_R && X_Right < right_Bound )            box_X = box_X + 2;
                
                if( p_X_Right > left_Bound )                    pipe_X = pipe_X - 2;
                else begin pipe_X = 763; p_1_Midpoint = random_Counter; end
                if( p_2_X_Right > left_Bound && counter > 115 )  pipe_2_X = pipe_2_X - 2;
                else begin pipe_2_X = 763; p_2_Midpoint = random_Counter; end
                if( p_3_X_Right > left_Bound && counter > 230 )  pipe_3_X = pipe_3_X - 2;
                else begin pipe_3_X = 763; p_3_Midpoint = random_Counter; end
            end
            if(counter != 16'b1111111111111111) counter = counter + 1;
        end
        X_Left = box_X - 5;
        X_Right = box_X + 5;
        Y_Top = box_Y - 6;
        Y_Bot = box_Y + 6;
        p_X_Left = pipe_X - 10;
        p_X_Right = pipe_X + 10;
        p_2_X_Left = pipe_2_X - 10;
        p_2_X_Right = pipe_2_X + 10;
        p_3_X_Left = pipe_3_X - 10;
        p_3_X_Right = pipe_3_X + 10;
        if(btn_U) game_Start = 1;
    end
    
    // Output to screen
    always @ (*)
    begin
        red = 0;
        green = 0;
        blue = 0;
        if(display_On == 1)
        begin
            if( !game_Over && ((h_Counter > X_Left) && (h_Counter < X_Right) && (v_Counter > Y_Top) && (v_Counter < Y_Bot))
                  || ((h_Counter > p_X_Left) && (h_Counter < p_X_Right) && (v_Counter > p_Y_Top) && (v_Counter < p_Y_Bot))
                    || ((h_Counter > p_X_Left) && (h_Counter < p_X_Right) && (v_Counter > p_Y_Top_Half_Top) && (v_Counter < p_Y_Top_Half_Bot))
                      || ((h_Counter > p_2_X_Left) && (h_Counter < p_2_X_Right) && (v_Counter > p_2_Y_Top) && (v_Counter < p_2_Y_Bot))
                        || ((h_Counter > p_2_X_Left) && (h_Counter < p_2_X_Right) && (v_Counter > p_2_Y_Top_Half_Top) && (v_Counter < p_2_Y_Top_Half_Bot))
                          || ((h_Counter > p_3_X_Left) && (h_Counter < p_3_X_Right) && (v_Counter > p_3_Y_Top) && (v_Counter < p_3_Y_Bot))
                            || ((h_Counter > p_3_X_Left) && (h_Counter < p_3_X_Right) && (v_Counter > p_3_Y_Top_Half_Top) && (v_Counter < p_3_Y_Top_Half_Bot)) )
            begin
                red =   4'b0000;
                green = 4'b0000;
                blue =  4'b0000;
            end else
            begin
                red =   4'b1111;
                green = 4'b1111;
                blue =  4'b1111;
            end
        end
    end
endmodule
