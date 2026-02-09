`timescale 1ns / 1ps

module vga_driver_tb;

    // Parametreler (Modüldeki default değerler ile aynı)
    parameter HPULSE  = 96;
    parameter HBP     = 48;
    parameter HACTIVE = 640;
    parameter HFP     = 16;
    
    parameter VPULSE  = 2;
    parameter VBP     = 33;
    parameter VACTIVE = 480;
    parameter VFP     = 10;

    // Inputs
    reg pixel_clk;
    reg rst;

    // Outputs
    wire VGA_HS;
    wire VGA_VS;
    wire data_en;

    vga_driver #(
        .HPULSE(HPULSE), .HBP(HBP), .HACTIVE(HACTIVE), .HFP(HFP),
        .VPULSE(VPULSE), .VBP(VBP), .VACTIVE(VACTIVE), .VFP(VFP)
    ) uut (
        .pixel_clk(pixel_clk), 
        .rst(rst), 
        .VGA_HS(VGA_HS), 
        .VGA_VS(VGA_VS), 
        .data_en(data_en)
    );

    // 1. Clock Generation (25 MHz -> 40ns)
    initial begin
        pixel_clk = 0;
        forever #20 pixel_clk = ~pixel_clk; // 20ns high, 20ns low
    end

    // 2. Reset Logic ve Simülasyon Kontrolü
    initial begin
        rst = 1;
        #100;
        
        rst = 0;
        $display("Simulation Started");

        #18000000; 
        
        $display("Simulation Finished.");
        $finish;
    end

   

endmodule