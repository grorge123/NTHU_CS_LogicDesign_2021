module clockDivider(
	input wire clk,
	input wire rst_n,
	input wire [19:0] frequency,
	output wire out
);
	reg [20-1:0] clcounter;
	reg [20-1:0] next_clcounter;
	always@(clk)begin
		if(rst_n)begin
			clcounter <= 20'b0;
		end else begin
			clcounter <= next_clcounter;
		end
	end

	always@(*)begin
		next_clcounter = clcounter == frequency ? 20'b0 : clcounter + 20'b1;
	end
	assign out = (clcounter == frequency);
endmodule