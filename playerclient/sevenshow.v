module sevenshow(
    input [8:0] inp,
	output [3:0] an,
	output [7:0] seven,
	input wire clk,
	input wire rst_n
);
	reg [7:0] counter;
	reg [5:0] tmp;
	reg [5:0] next_tmp;

	wire [8:0] lo[4:0];
	wire [8:0] dlo[4:0];
    assign lo[0] = inp % 9'd10;
    assign lo[1] = (inp / 9'd10) % 9'd10;
    assign lo[2] = (inp / 9'd100) % 9'd10;
    assign lo[3] = 8'd0;
	always@(posedge clk)begin
		if(rst_n)begin
			tmp <= 8'd0; 
		end else begin
			tmp <= next_tmp;
		end
	end
	always@(*)begin
		next_tmp = inp;
	end
    show_encode se0(.inp(lo[0]), .out(dlo[0]));
	show_encode se1(.inp(lo[1]), .out(dlo[1]));
	show_encode se2(.inp(lo[2]), .out(dlo[2]));
	show_encode se3(.inp(lo[3]), .out(dlo[3]));
	seven_show seven_s(.clk(clk), .rst_n(rst_n), .a(dlo[0]), .b(dlo[1]), .c(dlo[2]), .d(dlo[3]), .an(an), .led(seven));
endmodule
module show_encode(inp, out);
	input [8:0] inp;
	output [7:0] out;
	assign out = (inp == 9'd0) ?  8'b00000011:
				(inp == 9'd1) ? 8'b10011111:
				(inp == 9'd2) ? 8'b00100101:
				(inp == 9'd3) ? 8'b00001101:
				(inp == 9'd4) ? 8'b10011001:
				(inp == 9'd5) ? 8'b01001001:
				(inp == 9'd6) ? 8'b01000001:
				(inp == 9'd7) ? 8'b00011111:
				(inp == 9'd8) ? 8'b00000001:
				(inp == 9'd9) ? 8'b00001001:8'b00001111;
endmodule

module seven_show(clk, rst_n, a, b, c, d, an, led);
	input clk, rst_n;
	input [7:0] a, b, c, d;
	output [3:0] an;
	output [7:0] led;
	reg [3:0] an;
	reg [3:0] next_an;
	reg [7:0] led;
	reg [7:0] next_led;
	reg [2:0] next_counter;
	parameter size = 16;//16
	parameter size2 = 8;//18
	reg [size - 1:0] clcounter;
	reg [size - 1:0] next_clcounter;
	always @(posedge clk)begin
		if(rst_n)begin
			an <= 4'b0;
			clcounter <= {size{1'b0}};
            led <= 8'b00001111;
		end else begin
			an <= next_an;
       		led <= next_led;
			clcounter <= next_clcounter;
		end
	end
	always @(*)begin
		next_an = an;
		next_led = led;
		next_clcounter = clcounter + {size{1'b1}};
		if(clcounter == {size{1'b1}} ? 1'b1 : 1'b0)begin
			next_an = (an == 4'b1110) ? 4'b1101:
						(an == 4'b1101) ? 4'b1011:
						(an == 4'b1011) ? 4'b0111:
						(an == 4'b0111) ? 4'b1110:4'b1101;
			if(next_an == 4'b1110)begin
                next_led = a;
			end else if(next_an == 4'b1101) begin
				next_led = b;
			end else if(next_an == 4'b1011) begin
				next_led = c;
			end else begin 
				next_led = d;
			end
		end
	end
endmodule