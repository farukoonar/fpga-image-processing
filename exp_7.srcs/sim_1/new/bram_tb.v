`timescale 1ns / 1ps

module bram_tb();

    // Girişler
    reg clka;
    reg [16:0] addra; 
    wire [11:0] douta;

    bram_red uut (
        .clka(clka),    // input wire clka
        .addra(addra),  // input wire [16 : 0] addra
        .douta(douta)   // output wire [11 : 0] douta
    );

    // (25 MHz -> 40ns)
    initial begin
        clka = 0;
        forever #20 clka = ~clka;
    end

    initial begin
        addra = 0;
        #100;

        repeat (400) begin
            @(posedge clka); #1; 
            $display("Adress: %d, Data: %h", addra, douta);
            addra = addra + 1;
        end
        
        addra = 8041;
        @(posedge clka); #1;
        $display("Adress: %d, Data: %h", addra, douta);

        $stop;
    end
endmodule
