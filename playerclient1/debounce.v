
module debounce(pb_debounced, pb, clk);
	output pb_debounced;
	input pb;
	input clk;

	reg [3:0] DFF;

	always @(posedge clk)begin
		DFF[3:1] <= DFF[2:0];
		DFF[0] <= pb;
	end
	assign pb_debounced = ((DFF == 4'b1111) ? 1'b1 : 1'b0);
endmodule
