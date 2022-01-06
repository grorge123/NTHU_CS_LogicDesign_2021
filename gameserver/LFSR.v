
module LFSR1(clk, rst_n, out);
	input clk;
	input rst_n;
	output reg [7:0] out;
	reg [7:0] DFF;
	wire D1, D2, D3;
	assign D1 = out[7]^out[1];
	assign D2 = out[7]^out[2];
	assign D3 = out[7]^out[3];
	always@(posedge clk)begin
		if(rst_n)begin
			out <= 8'b10111101;
			DFF <= 8'b10111101;
		end else begin
			out <= DFF;
		end
	end
	always@(*) begin
		DFF = {out[6:4], D3, D2, D1, out[0], out[7]};
	end

endmodule

module LFSR2(clk, rst_n, out);
input clk;
input rst_n;
output reg [7:0] out;
reg [7:0] DFF;
wire fir = ((DFF[1]^DFF[2])^(DFF[3]^DFF[7]));
always@(posedge clk)begin
	if(rst_n)begin
		out <= 8'b10111101;
		DFF <= 8'b10111101;
	end else begin
		out <= DFF;
		DFF[7:1] <= DFF[6:0];
		DFF[0] <= fir;
	end
end


endmodule

