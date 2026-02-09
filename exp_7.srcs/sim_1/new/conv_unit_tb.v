`timescale 1ns / 1ps

module conv_unit_tb();
    reg pixel_clk;
    reg rst;
    reg enable;
    
    // 5-bit Pixel Inputs (Signed)
    reg signed [4:0] pixel11, pixel12, pixel13;
    reg signed [4:0] pixel21, pixel22, pixel23;
    reg signed [4:0] pixel31, pixel32, pixel33;
    
    // 4-bit Kernel Inputs
    reg signed [3:0] kernel11, kernel12, kernel13;
    reg signed [3:0] kernel21, kernel22, kernel23;
    reg signed [3:0] kernel31, kernel32, kernel33;

    wire [3:0] pixel_out;

    conv_unit uut (
        .pixel_clk(pixel_clk), 
        .rst(rst), 
        .enable(enable), 
        .pixel11(pixel11), .pixel12(pixel12), .pixel13(pixel13), 
        .pixel21(pixel21), .pixel22(pixel22), .pixel23(pixel23), 
        .pixel31(pixel31), .pixel32(pixel32), .pixel33(pixel33), 
        .kernel11(kernel11), .kernel12(kernel12), .kernel13(kernel13), 
        .kernel21(kernel21), .kernel22(kernel22), .kernel23(kernel23), 
        .kernel31(kernel31), .kernel32(kernel32), .kernel33(kernel33), 
        .pixel_out(pixel_out)
    );

    // 25 MHz -> 40ns
    initial begin
        pixel_clk = 0;
        forever #20 pixel_clk = ~pixel_clk;
    end

    initial begin
        rst = 1;
        enable = 0;
        // Kernel 
        // [ 1,  1,  1 ]
        // [ 1, -8,  1 ]
        // [ 1,  1,  1 ]
        kernel11 = 4'sd1; kernel12 = 4'sd1; kernel13 = 4'sd1;
        kernel21 = 4'sd1; kernel22 = -4'sd8; kernel23 = 4'sd1; 
        kernel31 = 4'sd1; kernel32 = 4'sd1; kernel33 = 4'sd1;
        
        // Reset Pixel
        pixel11 = 0; pixel12 = 0; pixel13 = 0;
        pixel21 = 0; pixel22 = 0; pixel23 = 0;
        pixel31 = 0; pixel32 = 0; pixel33 = 0;

        #100;
        rst = 0;
        enable = 1;

        // TEST 1: Flat Area
        // (8 * 5) + (1 * -8 * 5) = 40 - 40 = 0
        // Expected Result: 0
        
        pixel11 = 5; pixel12 = 5; pixel13 = 5;
        pixel21 = 5; pixel22 = 5; pixel23 = 5;
        pixel31 = 5; pixel32 = 5; pixel33 = 5;
        
        #40; // wait 1 clock cycle

        // TEST 2: Soft Edge
        // (8 * 4) + (1 * -8 * 5) = 32 - 40 = -8
        // Taking Negative: -(-8) = 8
        // Expected Result: 8 
        
        pixel11 = 4; pixel12 = 4; pixel13 = 4;
        pixel21 = 4; pixel22 = 5; pixel23 = 4;
        pixel31 = 4; pixel32 = 4; pixel33 = 4;

        #40;

        // TEST 3: Hard Edge
        // (8 * 0) + (1 * -8 * 10) = 0 - 80 = -80
        // Taking Negative: -(-80) = 80
        // Expected Result: 15 (80 > 15)
        
        pixel11 = 0; pixel12 = 0; pixel13 = 0;
        pixel21 = 0; pixel22 = 10; pixel23 = 0;
        pixel31 = 0; pixel32 = 0; pixel33 = 0;

        #40;
        
        // TEST 4: Enable Test
        
        enable = 0;
        #40;

        $stop;
    end
endmodule
