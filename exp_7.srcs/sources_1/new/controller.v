`timescale 1ns / 1ps

module controller(
    input pixel_clk,
    input rst,
    input data_en,                  
    input [11:0] data_in,          
    
    output reg frame_sent,          
    output reg [16:0] address,      
    
    output signed [3:0] kernel11, output signed [3:0] kernel12, output signed [3:0] kernel13,
    output signed [3:0] kernel21, output signed [3:0] kernel22, output signed [3:0] kernel23,
    output signed [3:0] kernel31, output signed [3:0] kernel32, output signed [3:0] kernel33,
    
    output reg signed [4:0] pixel11, output reg signed [4:0] pixel12, output reg signed [4:0] pixel13,
    output reg signed [4:0] pixel21, output reg signed [4:0] pixel22, output reg signed [4:0] pixel23,
    output reg signed [4:0] pixel31, output reg signed [4:0] pixel32, output reg signed [4:0] pixel33
    );

    localparam FIRST_LINE  = 3'd0;
    localparam SECOND_LINE = 3'd1;
    localparam PROC1       = 3'd2;
    localparam PROC2       = 3'd3;
    localparam PROC3       = 3'd4;
    localparam END_OF_LINE = 3'd5;

   
    reg [2:0] state;
    reg [11:0] buffer1 [0:213]; // row N-2
    reg [11:0] buffer2 [0:213]; // row N-1
    reg [7:0] buf_idx;          
    
    // "current" readed datas (Buffer and BRAM)
    reg [11:0] data_buf1; 
    reg [11:0] data_buf2;
    
    // "prev" stored datas 
    reg [11:0] prev_buf1; 
    reg [11:0] prev_buf2;
    reg [11:0] prev_data;       // from bram 

    reg [7:0] write_idx;

    // --- KERNEL Assing ---
    assign kernel11 = 4'sd1; assign kernel12 = 4'sd1; assign kernel13 = 4'sd1;
    assign kernel21 = 4'sd1; assign kernel22 = -4'sd8; assign kernel23 = 4'sd1;
    assign kernel31 = 4'sd1; assign kernel32 = 4'sd1; assign kernel33 = 4'sd1;

    // --- COMBINATIONAL LOGIC: PİKSEL SEÇİMİ ---
    // PREV (Left) and DATA (Right)
    
    always @(*) begin
        
        pixel11 = 0; pixel12 = 0; pixel13 = 0;
        pixel21 = 0; pixel22 = 0; pixel23 = 0;
        pixel31 = 0; pixel32 = 0; pixel33 = 0;

        case(state)
            PROC1: begin 
                // row 1 
                pixel11 = {prev_buf1[11:8]}; pixel12 = {prev_buf1[7:4]}; pixel13 = {prev_buf1[3:0]};
                // row 2
                pixel21 = {prev_buf2[11:8]}; pixel22 = {prev_buf2[7:4]}; pixel23 = {prev_buf2[3:0]};
                // row 3
                pixel31 = {prev_data[11:8]}; pixel32 = {prev_data[7:4]}; pixel33 = {prev_data[3:0]};
            end
            
            PROC2: begin 
                // row 1: [Prev_Mid, Prev_Right, New_Left]
                pixel11 = {prev_buf1[7:4]}; pixel12 = {prev_buf1[3:0]}; pixel13 = {data_buf1[11:8]};
                // row 2
                pixel21 = {prev_buf2[7:4]}; pixel22 = {prev_buf2[3:0]}; pixel23 = {data_buf2[11:8]};
                // row 3
                pixel31 = {prev_data[7:4]}; pixel32 = {prev_data[3:0]}; pixel33 = {data_in[11:8]};
            end
            
            PROC3: begin 
                // row 1: [Prev_Right, New_Left, New_Mid]
                pixel11 = {prev_buf1[3:0]}; pixel12 = {data_buf1[11:8]}; pixel13 = {data_buf1[7:4]};
                // row 2
                pixel21 = {prev_buf2[3:0]}; pixel22 = {data_buf2[11:8]}; pixel23 = {data_buf2[7:4]};
                // row 3
                pixel31 = {prev_data[3:0]}; pixel32 = {data_in[11:8]};   pixel33 = {data_in[7:4]};
            end
        endcase
    end

    // --- SEQUENTIAL LOGIC ---
    always @(posedge pixel_clk or posedge rst) begin
        if (rst) begin
            state <= FIRST_LINE;
            address <= 0;
            buf_idx <= 0;
            frame_sent <= 0;
            prev_data <= 0;
            prev_buf1 <= 0; prev_buf2 <= 0;
            data_buf1 <= 0; data_buf2 <= 0;
            write_idx <= 0;
        end else begin
        
            data_buf1 <= buffer1[buf_idx];
            data_buf2 <= buffer2[buf_idx];

            case (state)
                FIRST_LINE: begin
                    buffer1[buf_idx] <= data_in;
                    address <= address + 1;
                    if (buf_idx == 213) begin
                        buf_idx <= 0;
                        state <= SECOND_LINE;
                    end else begin
                        buf_idx <= buf_idx + 1;
                    end
                end

                SECOND_LINE: begin
                    buffer2[buf_idx] <= data_in;
                    address <= address + 1;
                    if (buf_idx == 213) begin
                        buf_idx <= 0;
                        state <= PROC1; 
                    end else begin
                        buf_idx <= buf_idx + 1;
                    end
                end

                PROC1: begin
                    if (data_en) begin
                        
                        prev_buf1 <= data_buf1;
                        prev_buf2 <= data_buf2;
                        prev_data <= data_in;
                        
                        write_idx <= buf_idx;

                        if (buf_idx == 213) begin
                             state <= END_OF_LINE;
                        end else begin
                             buf_idx <= buf_idx + 1;
                             address <= address + 1;
                             state <= PROC2;
                        end
                    end
                end

                PROC2: begin
                    if (data_en) begin
                        state <= PROC3;
                    end
                end

                PROC3: begin
                    if (data_en) begin
                        buffer1[write_idx] <= prev_buf2;
                        
                        buffer2[write_idx] <= prev_data;
                        
                        state <= PROC1;
                    end
                end

                END_OF_LINE: begin
                    buffer1[write_idx] <= prev_buf2;
                    buffer2[write_idx] <= prev_data;
                    
                    buf_idx <= 0;
                    address <= address + 1; 
                    
                    if (address == 103147) begin 
                        address <= 0;
                        frame_sent <= 1;
                        state <= FIRST_LINE;
                    end else begin
                        frame_sent <= 0;
                        state <= PROC1; 
                    end
                end
            endcase
        end
    end
endmodule