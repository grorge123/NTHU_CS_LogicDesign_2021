module testb();
reg clk = 0;
reg rst_n = 0;
reg [2:0] play2_M;
reg [2:0] play1_M;
wire [7:0] seven;
wire [3:0] an;
wire [8:0] play2_S;
wire [8:0] play1_S;
wire [15:0] led;
reg start = 1'd0;
wire [3:0] VGAR;
wire [3:0] VGAG;
wire [3:0] VGAB;
wire hsync;
wire vsync;
wire mode = 1'b1;
gametop ga(rst_n, clk, play2_M, play1_M, start, mode, seven,an, play2_S, play1_S, led, VGAR, VGAG, VGAB, hsync, vsync);
always#(1)clk = !clk;
	initial begin
		@(negedge clk)
		rst_n = 1'b1;
		#2
		start = 1'd1;
		play2_M = 3'd0;
		play1_M = 3'd4;
		#(50000)
		$finish;
	end
endmodule
module gametop (
	input wire reset,
	input wire clk,
	input wire [2:0] play2_M,
	input wire [2:0] play1_M,
	input wire start,
	input wire mode,
	output wire [7:0] seven,
	output wire [3:0] an,
	output wire [8:0] play2_S,
	output wire [8:0] play1_S,
	output wire [15:0] led,
	output wire [3:0] VGAR,
	output wire [3:0] VGAG,
	output wire [3:0] VGAB,
	output wire hsync,
	output wire vsync
);
	wire dere, rst_n, fr1, fr60, fr180, stclk;
	wire signed [10:0] ball1_posx, ball1_posy, ball1_velx, ball1_vely;
	wire signed [10:0] ball2_posx, ball2_posy, ball2_velx, ball2_vely;
	wire signed [10:0] ball3_posx, ball3_posy, ball3_velx, ball3_vely;
	wire signed [10:0] ball4_posx, ball4_posy, ball4_velx, ball4_vely;
	wire signed [10:0] ball5_posx, ball5_posy, ball5_velx, ball5_vely;
	wire signed [10:0] paddle10_posx, paddle10_posy, paddle10_velx, paddle10_vely;
	wire signed [10:0] paddle11_posx, paddle11_posy, paddle11_velx, paddle11_vely;
	wire signed [10:0] paddle20_posx, paddle20_posy, paddle20_velx, paddle20_vely;
	wire signed [10:0] paddle21_posx, paddle21_posy, paddle21_velx, paddle21_vely;
	wire [2:0] AI_M;
	wire [8:0] l_score, r_score;
	wire dest, onst;
	reg nstop;
	reg [7:0] ticounter; 
	assign led = { play1_S[8:0], play2_S[5:0], play1_M, play2_M};
	reg [7:0] next_ticounter; 
	reg [26:0] clcounter;
	reg [26:0] clcounter2, next_clcounter2;
	reg [26:0] next_clcounter;
	wire [26:0] fri60, fri180;
	wire [26:0] fri1;
	// assign fri60 = 27'd1666666;
	assign fri60 = 27'd833333;
	// assign fri60 = 27'd555556;
	// assign fri60 = 27'd8;
	assign fri1 = 27'd100000000;
	// assign fri1 = 27'd100;
	assign fr1 = (clcounter2 == fri1);
	assign stclk = (ticounter > 8'd0 ? (clcounter == fri60 ? 1'd1 : 1'd0) : 1'd0) && nstop;
	debounce der(
		.pb_debounced(dere),
		.pb(reset),
		.clk(clk)
	);
	OnePulse one(
		.signal_single_pulse(rst_n),
		.signal(dere),
		.clock(clk)
	);
	debounce des(
		.pb_debounced(dest),
		.pb(start),
		.clk(clk)
	);
	OnePulse ons(
		.signal_single_pulse(onst),
		.signal(dest),
		.clock(clk)
	);
	AI AImodule(.clk(clk), .rst_n(rst_n),
	.ball1_posx(ball1_posx), .ball1_posy(ball1_posy), .ball2_posx(ball2_posx), .ball2_posy(ball2_posy), .ball3_posx(ball3_posx), .ball3_posy(ball3_posy), .ball4_posx(ball4_posx), .ball4_posy(ball4_posy), .ball5_posx(ball5_posx), .ball5_posy(ball5_posy), .ball1_velx(ball1_velx), .ball1_vely(ball1_vely), .ball2_velx(ball2_velx), .ball2_vely(ball2_vely), .ball3_velx(ball3_velx), .ball3_vely(ball3_vely), .ball4_velx(ball4_velx), .ball4_vely(ball4_vely), .ball5_velx(ball5_velx), .ball5_vely(ball5_vely), 
	.paddle10_posx(paddle10_posx), .paddle10_posy(paddle10_posy), .paddle11_posx(paddle11_posx), .paddle11_posy(paddle11_posy), .action(AI_M));
	step st(.play1_M(play1_M), .play2_M(play2_M), .AI_M(AI_M), .AIM(mode),.clk(clk), .rst_n(rst_n), .stclk(stclk),
	.ball1_posx(ball1_posx), .ball1_posy(ball1_posy), .ball2_posx(ball2_posx), .ball2_posy(ball2_posy), .ball3_posx(ball3_posx), .ball3_posy(ball3_posy), .ball4_posx(ball4_posx), .ball4_posy(ball4_posy), .ball5_posx(ball5_posx), .ball5_posy(ball5_posy), .ball1_velx(ball1_velx), .ball1_vely(ball1_vely), .ball2_velx(ball2_velx), .ball2_vely(ball2_vely), .ball3_velx(ball3_velx), .ball3_vely(ball3_vely), .ball4_velx(ball4_velx), .ball4_vely(ball4_vely), .ball5_velx(ball5_velx), .ball5_vely(ball5_vely),
	.paddle10_posx(paddle10_posx), .paddle10_posy(paddle10_posy), .paddle11_posx(paddle11_posx), .paddle11_posy(paddle11_posy), .paddle20_posx(paddle20_posx), .paddle20_posy(paddle20_posy), .paddle21_posx(paddle21_posx), .paddle21_posy(paddle21_posy), .l_score(play1_S), .r_score(play2_S));
	VGA vg(.clk(clk), .rst_n(rst_n), .vgaRed(VGAR), .vgaGreen(VGAG), .vgaBlue(VGAB), .hsync(hsync), .vsync(vsync), 
	.ball1_posx(ball1_posx), .ball1_posy(ball1_posy), .ball2_posx(ball2_posx), .ball2_posy(ball2_posy), .ball3_posx(ball3_posx), .ball3_posy(ball3_posy), .ball4_posx(ball4_posx), .ball4_posy(ball4_posy), .ball5_posx(ball5_posx), .ball5_posy(ball5_posy), .paddle10_posx(paddle10_posx),
	.ball1_velx(ball1_velx), .ball2_velx(ball2_velx), .ball3_velx(ball3_velx), .ball4_velx(ball4_velx), .ball5_velx(ball5_velx),
	.Play1_S(play1_S), .Play2_S(play2_S),
	.paddle10_posy(paddle10_posy), .paddle11_posx(paddle11_posx), .paddle11_posy(paddle11_posy), .paddle20_posx(paddle20_posx), .paddle20_posy(paddle20_posy), .paddle21_posx(paddle21_posx), .paddle21_posy(paddle21_posy));
	
	always@(posedge clk)begin
		if(rst_n)begin
			ticounter <= 8'd180; 
			clcounter <= 20'd0;
			clcounter2 <= 27'd0;
			nstop <= 1'b0;
		end else begin
			if(onst) nstop <= !nstop;
			else nstop <= nstop;
			clcounter <= next_clcounter;
			clcounter2 <= next_clcounter2;
			ticounter <= next_ticounter;
		end
	end
	
	always@(*)begin
		next_ticounter = ticounter - (nstop && fr1 && ticounter > 8'd0 ? 8'd1: 8'd0);
		next_clcounter = clcounter == fri60 ? 27'd0 : clcounter + 27'd1;
		next_clcounter2 = clcounter2 == fri1 ? 27'd0 : clcounter2 + 27'd1;
	end
	sevenshow seshow(.clk(clk), .num(ticounter), .rst_n(rst_n),.an(an), .seven(seven));
endmodule