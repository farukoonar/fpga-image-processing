`timescale 1ns / 1ps

module conv_unit(
    input wire pixel_clk,
    input wire rst,
    input wire enable,
    
    // 5-bit signed input signals
    input wire signed [4:0] pixel11, pixel12, pixel13,
    input wire signed [4:0] pixel21, pixel22, pixel23,
    input wire signed [4:0] pixel31, pixel32, pixel33,
    
    // 4-bit signed kernel signals
    input wire signed [3:0] kernel11, kernel12, kernel13,
    input wire signed [3:0] kernel21, kernel22, kernel23,
    input wire signed [3:0] kernel31, kernel32, kernel33,
    
    // 4-bit pixel_out signal
    output reg [3:0] pixel_out
);

    // wires for multiplications (5-bit * 4-bit = 9-bit) 
    wire signed [8:0] mult11, mult12, mult13;
    wire signed [8:0] mult21, mult22, mult23;
    wire signed [8:0] mult31, mult32, mult33;

    // Sum Result 
    wire signed [12:0] sum;
    wire signed [12:0] inverted_sum;

    // 1. Ste: Multiplication Stage
    assign mult11 = pixel11 * kernel11;
    assign mult12 = pixel12 * kernel12;
    assign mult13 = pixel13 * kernel13;
    assign mult21 = pixel21 * kernel21;
    assign mult22 = pixel22 * kernel22;
    assign mult23 = pixel23 * kernel23;
    assign mult31 = pixel31 * kernel31;
    assign mult32 = pixel32 * kernel32;
    assign mult33 = pixel33 * kernel33;

    // 2. Step: Accumulation
    assign sum = mult11 + mult12 + mult13 +
                 mult21 + mult22 + mult23 +
                 mult31 + mult32 + mult33;

    // 3. step: Taking Inverse
    assign inverted_sum = -sum;

    // 4. Step: Clamping
    always @(posedge pixel_clk or posedge rst) begin
        if (rst) begin
            pixel_out <= 4'd0;
        end
        else if (enable == 1'b0) begin
            pixel_out <= 4'd0;
        end
        else begin
            if (inverted_sum > 13'sd15) begin
                pixel_out <= 4'd15;
            end
            else if (inverted_sum < 13'sd0) begin
                pixel_out <= 4'd0;
            end
            else begin
                pixel_out <= inverted_sum[3:0];
            end
        end
    end
endmodule
