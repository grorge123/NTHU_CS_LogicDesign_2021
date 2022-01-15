//////////////////////////////////////////////////////////
//           top module for this project
// I/O
// reset       : reset button signal
// clk         : system clock
// play2_M     : player2 action
// play1_M     : player1 action
// start       : stop/start button signal
// mode        : turn on/off AI
// pad1_add_vel: custom paddle1 velocity
// pad2_add_vel: custom paddle2 velocity 
// seven       : seven signal display information
// an          : seven signal display information
// play2_S     : player2 score
// play1_S     : player1 score
// led         : led debug signal
// VGAR        : VGA color
// VGAG        : VGA color
// VGAB        : VGA color
// hsync       : for VGA signal
// vsync       : for VGA signal
//////////////////////////////////////////////////////////
module gametop (
	input wire reset,
	input wire clk,
	input wire [2:0] play2_M,
	input wire [2:0] play1_M,
	input wire start,
	input wire mode,
	input wire [1:0] pad1_add_vel,   // add paddle1 velocity(personality) {R2 ,T1, U1}
	input wire [1:0] pad2_add_vel,   // add paddle2 velocity(personality) {W2 ,R3, T2}
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
	wire dere, rst_n, fr1, fr60, fr180, stclk, dest, onst;
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
	wire [2:0] VGAcounter;
	wire [7:0] timecounter;
	reg gamestart, nstop;
	reg [7:0] ticounter;
	reg [7:0] next_ticounter; 
	reg [26:0] clcounter;
	reg [26:0] clcounter2, next_clcounter2;
	reg [26:0] clcounter3, next_clcounter3;
	reg [26:0] next_clcounter;
	// control reciprocal
	reg [2:0] reciprocal_counter, next_reciprocal_counter; 
	wire [26:0] fri60, fri180;
	wire [26:0] fri1;
	assign led = { play1_S[8:0], play2_S[5:0], play1_M, play2_M};
	assign fri60 = 27'd833333;
	assign fri1 = 27'd100000000;
	assign fri2 = 27'd130000000;
	assign fr1 = (clcounter2 == fri1);
	assign fr2 = (clcounter3 == fri2);
	// ============================
	// stclk:
	// use clcounter to update stclk 
	// when nstop = 0, the game pauses, the stclk should stop update
	// when the reciprocal number is running, the stclk should stop update, too.
	// ============================
	assign stclk = (ticounter > 8'd0 ? (clcounter == fri60 ? 1'd1 : 1'd0) : 1'd0) && nstop && !reciprocal_counter;
	assign timecounter = ticounter;
	assign VGAcounter = reciprocal_counter;
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
	AI AImodule(.clk(clk),
	.ball1_posx(ball1_posx), .ball1_posy(ball1_posy), .ball2_posx(ball2_posx), .ball2_posy(ball2_posy), .ball3_posx(ball3_posx), .ball3_posy(ball3_posy), .ball4_posx(ball4_posx), .ball4_posy(ball4_posy), .ball5_posx(ball5_posx), .ball5_posy(ball5_posy), .ball1_velx(ball1_velx), .ball1_vely(ball1_vely), .ball2_velx(ball2_velx), .ball2_vely(ball2_vely), .ball3_velx(ball3_velx), .ball3_vely(ball3_vely), .ball4_velx(ball4_velx), .ball4_vely(ball4_vely), .ball5_velx(ball5_velx), .ball5_vely(ball5_vely), 
	.paddle10_posx(paddle10_posx), .paddle10_posy(paddle10_posy), .paddle11_posx(paddle11_posx), .paddle11_posy(paddle11_posy), .action(AI_M));
	step st(.play1_M(play1_M), .play2_M(play2_M), .AI_M(AI_M), .AIM(mode),.clk(clk), .rst_n(rst_n), .stclk(stclk), .pad1_add_vel(pad1_add_vel), .pad2_add_vel(pad2_add_vel),
	.ball1_posx(ball1_posx), .ball1_posy(ball1_posy), .ball2_posx(ball2_posx), .ball2_posy(ball2_posy), .ball3_posx(ball3_posx), .ball3_posy(ball3_posy), .ball4_posx(ball4_posx), .ball4_posy(ball4_posy), .ball5_posx(ball5_posx), .ball5_posy(ball5_posy), .ball1_velx(ball1_velx), .ball1_vely(ball1_vely), .ball2_velx(ball2_velx), .ball2_vely(ball2_vely), .ball3_velx(ball3_velx), .ball3_vely(ball3_vely), .ball4_velx(ball4_velx), .ball4_vely(ball4_vely), .ball5_velx(ball5_velx), .ball5_vely(ball5_vely),
	.paddle10_posx(paddle10_posx), .paddle10_posy(paddle10_posy), .paddle11_posx(paddle11_posx), .paddle11_posy(paddle11_posy), .paddle20_posx(paddle20_posx), .paddle20_posy(paddle20_posy), .paddle21_posx(paddle21_posx), .paddle21_posy(paddle21_posy), .l_score(play1_S), .r_score(play2_S));
	VGA vg(.clk(clk), .rst_n(rst_n), .vgaRed(VGAR), .vgaGreen(VGAG), .vgaBlue(VGAB), .hsync(hsync), .vsync(vsync), 
	.ball1_posx(ball1_posx), .ball1_posy(ball1_posy), .ball2_posx(ball2_posx), .ball2_posy(ball2_posy), .ball3_posx(ball3_posx), .ball3_posy(ball3_posy), .ball4_posx(ball4_posx), .ball4_posy(ball4_posy), .ball5_posx(ball5_posx), .ball5_posy(ball5_posy), .paddle10_posx(paddle10_posx),
	.ball1_velx(ball1_velx), .ball2_velx(ball2_velx), .ball3_velx(ball3_velx), .ball4_velx(ball4_velx), .ball5_velx(ball5_velx),
	.Play1_S(play1_S), .Play2_S(play2_S), .reciprocal_counter(VGAcounter), .timecounter(timecounter), .gamestart(gamestart),
	.paddle10_posy(paddle10_posy), .paddle11_posx(paddle11_posx), .paddle11_posy(paddle11_posy), .paddle20_posx(paddle20_posx), .paddle20_posy(paddle20_posy), .paddle21_posx(paddle21_posx), .paddle21_posy(paddle21_posy));
	// =======================================
	// use the combinational circuit & sequential circuit to update following signal:
	// 1.ticounter
	// 2.clcounter
	// 3.clcounter2
	// 4.clcounter3
	// 5.nstop
	// 	   - if start button pressed & game start signal was 1, nstop will reverse.
	// 	   - nstop = 1 the game start , nstop = 0 the game stop.
	// 6.reciprocal_counter
	//     - the game start, counter will be 5. It means VGA will display ready.
	//     - the game pause, counter will be 5. It means the VGA display pause.
	//     - the game continue, counter will be 3 -> 2 -> 1. It means the VGA will display reciprocal number.
	// 7.gamestart 
	// 	   - if start button pressed, game start signal will be 1.
	// =======================================
 	always@(posedge clk)begin
		if(rst_n)begin
			ticounter <= 8'd180; 
			clcounter <= 20'd0;
			clcounter2 <= 27'd0;
			clcounter3 <= 27'd0;
			nstop <= 1'b0;
			reciprocal_counter <= 3'd5;
			gamestart <= 1'b0;
		end else begin
			if(onst) begin
				gamestart <= 1'd1;
			end else begin
				gamestart <= gamestart;
			end
			if(gamestart && onst)begin
				nstop <= !nstop;
			end else begin
				nstop <= nstop;
			end
			reciprocal_counter <= next_reciprocal_counter;
			clcounter <= next_clcounter;
			clcounter2 <= next_clcounter2;
			clcounter3 <= next_clcounter3;
			ticounter <= next_ticounter;
		end
	end
	
	always@(*)begin
		if(reciprocal_counter == 3'd0)begin
			next_reciprocal_counter = (nstop == 1'b1 || ticounter == 8'd0) ? 3'd0 : 3'd4;
		end else if (reciprocal_counter == 3'd5) begin
			if(gamestart == 1'd1 && onst)begin
				next_reciprocal_counter = 3'd3;
			end else begin
				next_reciprocal_counter = 3'd5;
			end
		end else begin
			if(nstop == 1'd1)
				next_reciprocal_counter = reciprocal_counter - ( fr1 > 8'd0 ? 8'd1 : 8'd0);
			else 
				next_reciprocal_counter = 3'd4;
		end
		next_ticounter = ticounter - (nstop && fr1 && ticounter && !reciprocal_counter > 8'd0 ? 8'd1: 8'd0);
		next_clcounter = clcounter == fri60 ? 27'd0 : clcounter + 27'd1;
		next_clcounter2 = clcounter2 == fri1 ? 27'd0 : clcounter2 + 27'd1;
		next_clcounter3 = ((clcounter3 == fri2) && nstop) ? 27'd0 : clcounter3 + 27'd1;
	end
	sevenshow seshow(.clk(clk), .num(ticounter), .rst_n(rst_n),.an(an), .seven(seven));
endmodule