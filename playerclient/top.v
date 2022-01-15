//////////////////////////////////////////////////////////
//           player_top module for this project
// I/O
// reset     : reset button signal
// score     : player's socre
// PS2_DATA  : keyboard signal
// PS2_CLK   : keyboard signal clk
// seven     : seven display
// an        : seven display enable
// player_M  : player action
// led       : led display for debug
//////////////////////////////////////////////////////////
module clienttop(
	input wire [8:0] score,
	input wire clk,
	input wire reset,
	inout wire PS2_DATA,
	inout wire PS2_CLK,
	output wire [7:0] seven,
	output wire [3:0] an,
	output reg [2:0] player_M,
	output wire [15:0] led 
);
	reg [2:0] action;
	wire [511:0] key_down;
	wire [8:0] last_change;
	reg [8:0] decode;
	wire been_ready, rst;
	reg [26:0] clcounter;
	wire [26:0] fri60;
	reg lf = 1'd0;
	assign fri60 = 27'd833333;
	assign led = { 4'b1111, score, player_M};
	debounce der(
		.pb_debounced(dere),
		.pb(reset),
		.clk(clk)
	);
	OnePulse one(
		.signal_single_pulse(rst),
		.signal(dere),
		.clock(clk)
	);
	KeyboardDecoder key_de (
		.key_down(key_down),
		.last_change(last_change),
		.key_valid(been_ready),
		.PS2_DATA(PS2_DATA),
		.PS2_CLK(PS2_CLK),
		.rst(rst),
		.clk(clk)
	);
	sevenshow seven_show(
		.inp(score),
		.an(an),
		.seven(seven),
		.clk(clk),
		.rst_n(rst)
	);
	always @ (posedge clk or posedge rst) begin
		if(rst)begin
			clcounter <= 27'd0;
		end else begin
			clcounter <= (clcounter == fri60 ? 27'd0 : clcounter + 27'd1);
		end
	end
	always @ (posedge clk or posedge rst) begin
		if (rst) begin
			player_M <= 3'd0;
		end else begin
			if(clcounter == fri60)begin
				if(lf == 1'd0 && key_down[9'h1D] == 1'b1)begin
					player_M <= 3'd1;
				end else if(lf == 1'd0 && key_down[9'h1B] == 1'b1)begin
					player_M <= 3'd2;
				end else if(lf == 1'd1 && key_down[9'h75] == 1'b1)begin
					player_M <= 3'd3;
				end else if(lf == 1'd1 && key_down[9'h72] == 1'b1)begin
					player_M <= 3'd4;
				end else begin
					player_M <= 3'd0;
				end
				lf <= !lf;
			end else begin
				player_M <= player_M;
			end

		end
	end

	always@(*)begin
		case (last_change)
			9'h1D : action = 3'd1;
			9'h1B:action = 3'd2;
			9'h75:action = 3'd3;
			9'h72:action = 3'd4;
			default:action = 3'd0;
		endcase

	end

	always@(*)begin
		case (action)
			3'd1 : decode = 9'h1D;
			3'd2 : decode = 9'h1B;
			3'd3 :decode = 9'h75;
			3'd4 :decode = 9'h72;
			default:decode = 9'd0;
		endcase

	end
endmodule