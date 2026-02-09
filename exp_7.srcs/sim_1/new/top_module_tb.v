`timescale 1ns / 1ps

module top_tb();

	reg  clk   = 0;
	reg  clk25 = 0;
	reg  rst   = 0;
	wire VGA_HS;
	wire VGA_VS;
	wire [3:0] VGA_R;
	wire [3:0] VGA_G;
	wire [3:0] VGA_B;

	top TOP_SYSTEM(
		.clk(clk),
		.rst(rst),
		.VGA_HS(VGA_HS),
		.VGA_VS(VGA_VS),
		.VGA_R(VGA_R),
		.VGA_G(VGA_G),
		.VGA_B(VGA_B)
	);

	always #5  clk   = ~clk;
	always #20 clk25 = ~clk25;


	parameter REFRESH = 416667;  	// 1/60 second  refresh rate
	integer i   = 0;   
	integer cnt = 0;

	integer fdr, fdg, fdb;	
	
	initial
	begin
		fdr = $fopen("red.txt",   "w");
		fdg = $fopen("green.txt", "w");
		fdb = $fopen("blue.txt",  "w");

        repeat (200) @(posedge clk25);
        rst = 1;
        repeat (200) @(posedge clk25);
        rst = 0;
		
		// Write the output pixel values
		for( i = 0; i < REFRESH; i=i+1)
		begin
            @(posedge clk25);
			
			if(TOP_SYSTEM.vga_data_en)
			begin
				$fwrite(fdr, "%h", VGA_R);
				$fwrite(fdg, "%h", VGA_G);
				$fwrite(fdb, "%h", VGA_B);
				cnt = cnt + 1;
				if(cnt == 640)
				begin
					$fwrite(fdr, "\n");
					$fwrite(fdg, "\n");
					$fwrite(fdb, "\n");	
					cnt = 0;			
				end
			end
		end
        $fclose(fdr);
        $fclose(fdg);
        $fclose(fdb);
	end

endmodule
