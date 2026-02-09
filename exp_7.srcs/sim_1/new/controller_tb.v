`timescale 1ns / 1ps

module controller_tb;

    reg pixel_clk;
    reg rst;
    reg data_en;
    reg [11:0] data_in;

    wire frame_sent;
    wire [16:0] address;

    wire signed [3:0] k11, k12, k13, k21, k22, k23, k31, k32, k33;
    
    wire [3:0] p11, p12, p13, p21, p22, p23, p31, p32, p33;

    controller uut (
        .pixel_clk(pixel_clk),
        .rst(rst),
        .data_en(data_en),
        .data_in(data_in),
        
        .frame_sent(frame_sent),
        .address(address),
        
        .kernel11(k11), .kernel12(k12), .kernel13(k13),
        .kernel21(k21), .kernel22(k22), .kernel23(k23),
        .kernel31(k31), .kernel32(k32), .kernel33(k33),
        
        .pixel11(p11), .pixel12(p12), .pixel13(p13),
        .pixel21(p21), .pixel22(p22), .pixel23(p23),
        .pixel31(p31), .pixel32(p32), .pixel33(p33)
    );

    // 100 MHz clock (10ns periyot)
    initial begin
        pixel_clk = 0;
        forever #5 pixel_clk = ~pixel_clk;
    end

    // --- BLOCK RAM SIMULATION---
    always @(posedge pixel_clk) begin
        if (rst) begin
            data_in <= 0;
        end else begin
            data_in <= address[11:0]; 
        end
    end

    // --- TEST  ---
    initial begin
       
        rst = 1;
        data_en = 0;
        $display("Simulation started");
        
        #100;
        rst = 0;
        
        @(posedge pixel_clk);
        data_en = 1;

        wait(frame_sent == 1);
        
       
        #500;
        $stop;
    end

endmodule