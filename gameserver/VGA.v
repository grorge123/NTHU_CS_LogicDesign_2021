//////////////////////////////////////////////////////////
//           VGA module for this project
// I/O
// reset               : reset button signal
// clk                 : system clock
// ball*_posx          : ball x-axis position
// ball*_posy          : ball y-axis position
// play2_S             : player2 score
// play1_S             : player1 score
// ball*_velx          : ball x-axis velocity
// ball*_vely          : ball y-axis velocity
// reciprocal_counter  : the counter for game reciprocal number display
// time_counter        : the counter for game time
// gamestart       	   : game start signal
// mode                : turn on/off AI
// pad1**_posx         : custom paddle1 X-pos
// pad1**_posy         : custom paddle1 Y-pos
// pad2**_posx         : custom paddle2 X-pos 
// pad2**_posy         : custom paddle2 Y-pos 
// VGAR                : VGA color
// VGAG                : VGA color
// VGAB                : VGA color
// hsync               : for VGA signal
// vsync               : for VGA signal
//////////////////////////////////////////////////////////
module VGA(
	input wire clk,
	input wire rst_n,
	input wire signed [10:0] ball1_posx,
	input wire signed [10:0] ball1_posy,
	input wire signed [10:0] ball2_posx,
	input wire signed [10:0] ball2_posy,
	input wire signed [10:0] ball3_posx,
	input wire signed [10:0] ball3_posy,
	input wire signed [10:0] ball4_posx,
	input wire signed [10:0] ball4_posy,
	input wire signed [10:0] ball5_posx,
	input wire signed [10:0] ball5_posy,
	input wire signed [10:0] ball1_velx,
	input wire signed [10:0] ball2_velx,
	input wire signed [10:0] ball3_velx,
	input wire signed [10:0] ball4_velx,
	input wire signed [10:0] ball5_velx,
	input wire [8:0] Play1_S,
	input wire [8:0] Play2_S,
	input wire [2:0] reciprocal_counter,
	input wire [7:0] timecounter,
	input wire gamestart,
	
	input wire signed [10:0] paddle10_posx,
	input wire signed [10:0] paddle10_posy,
	input wire signed [10:0] paddle11_posx,
	input wire signed [10:0] paddle11_posy,
	input wire signed [10:0] paddle20_posx,
	input wire signed [10:0] paddle20_posy,
	input wire signed [10:0] paddle21_posx,
	input wire signed [10:0] paddle21_posy,
	output [3:0] vgaRed,
	output [3:0] vgaGreen,
	output [3:0] vgaBlue,
	output wire hsync,
	output wire vsync
);
	//some basic thing for VGA
	wire [11:0] data;
	assign data = 12'd0;
    wire clk_25MHz;
    wire [16:0] pixel_addr;
    reg [11:0] pixel;
    wire [11:0] outdata;
    wire valid;
    wire signed [10:0] h_cnt; //640
    wire signed [10:0] v_cnt;  //480
	//basic setting
	parameter signed WIDTH = 11'd640;
	parameter signed HEIGHT = 11'd480;       
	parameter signed BALL_RADIUS = 11'd6;
	parameter signed PAD_WIDTH = 11'd4;
	parameter signed PAD_HEIGHT = 11'd80;
	parameter signed PAD_SPACE = 11'd60;
	parameter signed HALF_PAD_WIDTH = PAD_WIDTH / 2;
	parameter signed HALF_PAD_HEIGHT = PAD_HEIGHT / 2;
	//pixel setting
	assign {vgaRed, vgaGreen, vgaBlue} = (valid==1'b1) ? pixel:12'h0;
	assign pixel_addr = (({6'd0,h_cnt} >> 17'd1) + 17'd320 * ({6'd0, v_cnt} >> 17'd1) ) % 17'd76800;
	//blood control
	wire [10:0] lf, rf;
	assign lf = (11'd320 + ({2'b0, Play1_S} - {2'b0, Play2_S}) * 11'd2);
	assign rf = (11'd320 - ({2'b0, Play2_S} - {2'b0, Play1_S}) * 11'd2);
	//combinaitonal circuit for display 
	always@(*)begin
		// if game not start, we set the picture with our memory
		if(!gamestart)
			pixel = outdata;
		// ========================================
		// if game start we should following thing :
		// 1. blood background
		// 2. pause
		// 3. central line
		// 4. reciprocal number
		// 5. paddle  
		// 6. ball 
		// 7. win
		// 8. ready
		// ========================================
		else begin
			// ========================================
			// blood backgroud:
			// Player1(left)  -> green 
			// Player2(right) -> black 
			// the thing should notice is to use the if syntax to draw blood
			// that avoid lf or rf have some wrong signal to make bug for display 
			// ========================================
			if(Play1_S > Play2_S)begin
				if(h_cnt <= lf || lf < 11'd320)begin
					pixel = {4'd0, 4'd15, 4'd0};
				end else begin
					pixel = {4'd0, 4'd0, 4'd0};
				end
			end else if(Play1_S == Play2_S)begin
				if(h_cnt <= 11'd319)begin
					pixel = {4'd0, 4'd15, 4'd0};
				end else begin
					pixel = {4'd0, 4'd0, 4'd0};
				end
			end else begin
				if(h_cnt <= rf && rf < 11'd320)begin
					pixel = {4'd0, 4'd15, 4'd0};
				end else begin
					pixel = {4'd0, 4'd0, 4'd0};
				end
			end
			//central line(white)
			if(h_cnt >= 11'd319 && h_cnt <= 11'd321)
				pixel = {4'd15, 4'd15, 4'd15};
			// ========================================
			// reciprocal number & pause & ready
			// we use the reciprocal_counter signal to control the thing we should display
			// 5: draw ready 
			// 4: draw pause     
			// 3: number 3
			// 2: number 2
			// 1: number 1
		    // other: draw pixels on central line which has same color in order to keep best coding style
			// ========================================
			case(reciprocal_counter)
				3'd5:begin
					//white rectangle
					if(h_cnt >= 11'd194 && h_cnt <= 11'd446 && v_cnt >= 11'd25 && v_cnt <= 11'd100)
						pixel = {4'd15, 4'd15, 4'd15};
					//R(R = P+\)
					// the part of P
					if(h_cnt >= 11'd206 && h_cnt <= 11'd218 && v_cnt >= 11'd37 && v_cnt <= 11'd97)
						pixel = {4'd0, 4'd0, 4'd0};
					if(h_cnt >= 11'd218 && h_cnt <= 11'd230 && ((v_cnt >= 11'd37 && v_cnt <= 11'd49) || (v_cnt >= 11'd61 && v_cnt <= 11'd73)))
						pixel = {4'd0, 4'd0, 4'd0};
					if(h_cnt >= 11'd230 && h_cnt <= 11'd242 && v_cnt >= 11'd37 && v_cnt <= 11'd73)
						pixel = {4'd0, 4'd0, 4'd0};

					// the part of \
					if(h_cnt >= 11'd218 && h_cnt <= 11'd231 && v_cnt >= 11'd73 && v_cnt <= 11'd74)
						pixel = {4'd0, 4'd0, 4'd0};
					if(h_cnt >= 11'd219 && h_cnt <= 11'd232 && v_cnt >= 11'd75 && v_cnt <= 11'd76)
						pixel = {4'd0, 4'd0, 4'd0};
					if(h_cnt >= 11'd220 && h_cnt <= 11'd233 && v_cnt >= 11'd77 && v_cnt <= 11'd78)
						pixel = {4'd0, 4'd0, 4'd0};
					if(h_cnt >= 11'd221 && h_cnt <= 11'd234 && v_cnt >= 11'd79 && v_cnt <= 11'd80)
						pixel = {4'd0, 4'd0, 4'd0};
					if(h_cnt >= 11'd222 && h_cnt <= 11'd235 && v_cnt >= 11'd81 && v_cnt <= 11'd82)
						pixel = {4'd0, 4'd0, 4'd0};
					if(h_cnt >= 11'd223 && h_cnt <= 11'd236 && v_cnt >= 11'd83 && v_cnt <= 11'd84)
						pixel = {4'd0, 4'd0, 4'd0};
					if(h_cnt >= 11'd224 && h_cnt <= 11'd237 && v_cnt >= 11'd85 && v_cnt <= 11'd86)
						pixel = {4'd0, 4'd0, 4'd0};
					if(h_cnt >= 11'd225 && h_cnt <= 11'd238 && v_cnt >= 11'd87 && v_cnt <= 11'd88)
						pixel = {4'd0, 4'd0, 4'd0};
					if(h_cnt >= 11'd226 && h_cnt <= 11'd239 && v_cnt >= 11'd89 && v_cnt <= 11'd90)
						pixel = {4'd0, 4'd0, 4'd0};
					if(h_cnt >= 11'd227 && h_cnt <= 11'd240 && v_cnt >= 11'd91 && v_cnt <= 11'd92)
						pixel = {4'd0, 4'd0, 4'd0};
					if(h_cnt >= 11'd228 && h_cnt <= 11'd241 && v_cnt >= 11'd93 && v_cnt <= 11'd94)
						pixel = {4'd0, 4'd0, 4'd0};
					if(h_cnt >= 11'd229 && h_cnt <= 11'd242 && v_cnt >= 11'd95 && v_cnt <= 11'd97)
						pixel = {4'd0, 4'd0, 4'd0};
					
					//E
					if(h_cnt >= 11'd254 && h_cnt <= 11'd266 && v_cnt >= 11'd37 && v_cnt <= 11'd97)
						pixel = {4'd0, 4'd0, 4'd0};
					if(h_cnt >= 11'd266 && h_cnt <= 11'd278 && ((v_cnt >= 11'd37 && v_cnt <= 11'd49) || (v_cnt >= 11'd61 && v_cnt <= 11'd73) || (v_cnt >= 11'd85 && v_cnt <= 11'd97)))
						pixel = {4'd0, 4'd0, 4'd0};
					if(h_cnt >= 11'd278 && h_cnt <= 11'd290 && ((v_cnt >= 11'd37 && v_cnt <= 11'd49) || (v_cnt >= 11'd61 && v_cnt <= 11'd73) || (v_cnt >= 11'd85 && v_cnt <= 11'd97)))
						pixel = {4'd0, 4'd0, 4'd0}; 
					//A
					if(h_cnt >= 11'd302 && h_cnt <= 11'd314 && v_cnt >= 11'd37 && v_cnt <= 11'd97)
						pixel = {4'd0, 4'd0, 4'd0};
					if(h_cnt >= 11'd314 && h_cnt <= 11'd326 && ((v_cnt >= 11'd37 && v_cnt <= 11'd49) || (v_cnt >= 11'd61 && v_cnt <= 11'd73)))
						pixel = {4'd0, 4'd0, 4'd0};
					if(h_cnt >= 11'd326 && h_cnt <= 11'd338 && v_cnt >= 11'd37 && v_cnt <= 11'd97)
						pixel = {4'd0, 4'd0, 4'd0};
					//D
					if(h_cnt >= 11'd350 && h_cnt <= 11'd362 && v_cnt >= 11'd37 && v_cnt <= 11'd97)
						pixel = {4'd0, 4'd0, 4'd0};
					if(h_cnt >= 11'd362 && h_cnt <= 11'd374 && ((v_cnt >= 11'd37 && v_cnt <= 11'd49) || (v_cnt >= 11'd85 && v_cnt <= 11'd97)))
						pixel = {4'd0, 4'd0, 4'd0};
					if(h_cnt >= 11'd374 && h_cnt <= 11'd386 && v_cnt >= 11'd37 && v_cnt <= 11'd97)
						pixel = {4'd0, 4'd0, 4'd0};
					//Y
					if(h_cnt >= 11'd398 && h_cnt <= 11'd410 && v_cnt >= 11'd37 && v_cnt <= 11'd61)
						pixel = {4'd0, 4'd0, 4'd0};
					if(h_cnt >= 11'd410 && h_cnt <= 11'd422 && v_cnt >= 11'd49 && v_cnt <= 11'd97)
						pixel = {4'd0, 4'd0, 4'd0};
					if(h_cnt >= 11'd422 && h_cnt <= 11'd434 && v_cnt >= 11'd37 && v_cnt <= 11'd61)
						pixel = {4'd0, 4'd0, 4'd0};
				end
				3'd4:begin
					//white rectangle
					if(h_cnt >= 11'd194 && h_cnt <= 11'd446 && v_cnt >= 11'd25 && v_cnt <= 11'd100)
						pixel = {4'd15, 4'd15, 4'd15};
					//P 
					if(h_cnt >= 11'd206 && h_cnt <= 11'd218 && v_cnt >= 11'd37 && v_cnt <= 11'd97)
						pixel = {4'd0, 4'd0, 4'd0};
					if(h_cnt >= 11'd218 && h_cnt <= 11'd230 && ((v_cnt >= 11'd37 && v_cnt <= 11'd49) || (v_cnt >= 11'd61 && v_cnt <= 11'd73)))
						pixel = {4'd0, 4'd0, 4'd0};
					if(h_cnt >= 11'd230 && h_cnt <= 11'd242 && v_cnt >= 11'd37 && v_cnt <= 11'd73)
						pixel = {4'd0, 4'd0, 4'd0};

					//A
					if(h_cnt >= 11'd254 && h_cnt <= 11'd266 && v_cnt >= 11'd37 && v_cnt <= 11'd97)
						pixel = {4'd0, 4'd0, 4'd0};
					if(h_cnt >= 11'd266 && h_cnt <= 11'd278 && ((v_cnt >= 11'd37 && v_cnt <= 11'd49) || (v_cnt >= 11'd61 && v_cnt <= 11'd73)))
						pixel = {4'd0, 4'd0, 4'd0};
					if(h_cnt >= 11'd278 && h_cnt <= 11'd290 && v_cnt >= 11'd37 && v_cnt <= 11'd97)
						pixel = {4'd0, 4'd0, 4'd0};

					//U
					if(h_cnt >= 11'd302 && h_cnt <= 11'd314 && v_cnt >= 11'd37 && v_cnt <= 11'd97)
						pixel = {4'd0, 4'd0, 4'd0};
					if(h_cnt >= 11'd314 && h_cnt <= 11'd326 && v_cnt >= 11'd85 && v_cnt <= 11'd97)
						pixel = {4'd0, 4'd0, 4'd0};
					if(h_cnt >= 11'd326 && h_cnt <= 11'd338 && v_cnt >= 11'd37 && v_cnt <= 11'd97)
						pixel = {4'd0, 4'd0, 4'd0};

					//S
					if(h_cnt >= 11'd350 && h_cnt <= 11'd362 && ((v_cnt >= 11'd37 && v_cnt <= 11'd73) || (v_cnt >= 11'd85 && v_cnt <= 11'd97)))
						pixel = {4'd0, 4'd0, 4'd0};
					if(h_cnt >= 11'd362 && h_cnt <= 11'd374 && ((v_cnt >= 11'd37 && v_cnt <= 11'd49) || (v_cnt >= 11'd61 && v_cnt <= 11'd73) || (v_cnt >= 11'd85 && v_cnt <= 11'd97)))
						pixel = {4'd0, 4'd0, 4'd0};
					if(h_cnt >= 11'd374 && h_cnt <= 11'd386 && ((v_cnt >= 11'd37 && v_cnt <= 11'd49) || (v_cnt >= 11'd61 && v_cnt <= 11'd97)))
						pixel = {4'd0, 4'd0, 4'd0};
					
					//E
					if(h_cnt >= 11'd398 && h_cnt <= 11'd410 && v_cnt >= 11'd37 && v_cnt <= 11'd97)
						pixel = {4'd0, 4'd0, 4'd0};
					if(h_cnt >= 11'd410 && h_cnt <= 11'd422 && ((v_cnt >= 11'd37 && v_cnt <= 11'd49) || (v_cnt >= 11'd61 && v_cnt <= 11'd73) || (v_cnt >= 11'd85 && v_cnt <= 11'd97)))
						pixel = {4'd0, 4'd0, 4'd0};
					if(h_cnt >= 11'd422 && h_cnt <= 11'd434 && ((v_cnt >= 11'd37 && v_cnt <= 11'd49) || (v_cnt >= 11'd61 && v_cnt <= 11'd73) || (v_cnt >= 11'd85 && v_cnt <= 11'd97)))
						pixel = {4'd0, 4'd0, 4'd0}; 
				end		
				3'd3:begin
					//white square
					if(h_cnt >= 11'd290 && h_cnt <= 11'd350 && v_cnt >= 11'd25 && v_cnt <= 11'd100)
						pixel = {4'd15, 4'd15, 4'd15};
					//3
					if(h_cnt >= 11'd302 && h_cnt <= 11'd314 && ((v_cnt >= 11'd37 && v_cnt <= 11'd49) || (v_cnt >= 11'd61 && v_cnt <= 11'd73) || (v_cnt >= 11'd85 && v_cnt <= 11'd97)))
						pixel = {4'd0, 4'd0, 4'd0};
					if(h_cnt >= 11'd314 && h_cnt <= 11'd326 && ((v_cnt >= 11'd37 && v_cnt <= 11'd49) || (v_cnt >= 11'd61 && v_cnt <= 11'd73) || (v_cnt >= 11'd85 && v_cnt <= 11'd97)))
						pixel = {4'd0, 4'd0, 4'd0};
					if(h_cnt >= 11'd326 && h_cnt <= 11'd338 && v_cnt >= 11'd37 && v_cnt <= 11'd97)
						pixel = {4'd0, 4'd0, 4'd0};
				end
				3'd2:begin
					//white square
					if(h_cnt >= 11'd290 && h_cnt <= 11'd350 && v_cnt >= 11'd25 && v_cnt <= 11'd100)
						pixel = {4'd15, 4'd15, 4'd15};
					//2
					if(h_cnt >= 11'd302 && h_cnt <= 11'd314 && ((v_cnt >= 11'd37 && v_cnt <= 11'd49) || (v_cnt >= 11'd61 && v_cnt <= 11'd97)))
						pixel = {4'd0, 4'd0, 4'd0};
					if(h_cnt >= 11'd314 && h_cnt <= 11'd326 && ((v_cnt >= 11'd37 && v_cnt <= 11'd49) || (v_cnt >= 11'd61 && v_cnt <= 11'd73) || (v_cnt >= 11'd85 && v_cnt <= 11'd97)))
						pixel = {4'd0, 4'd0, 4'd0};
					if(h_cnt >= 11'd326 && h_cnt <= 11'd338 && ((v_cnt >= 11'd37 && v_cnt <= 11'd73) || (v_cnt >= 11'd85 && v_cnt <= 11'd97)))
						pixel = {4'd0, 4'd0, 4'd0};
					
				end
				3'd1:begin
					//white square
					if(h_cnt >= 11'd290 && h_cnt <= 11'd350 && v_cnt >= 11'd25 && v_cnt <= 11'd100)
						pixel = {4'd15, 4'd15, 4'd15};
					//1
					if(h_cnt >= 11'd314 && h_cnt <= 11'd326 && v_cnt >= 11'd37 && v_cnt <= 11'd97)
						pixel = {4'd0, 4'd0, 4'd0};

				end
				default:
					if(h_cnt >= 11'd319 && h_cnt <= 11'd321 && v_cnt >= 11'd1)
						pixel = {4'd15, 4'd15, 4'd15};
			endcase
			// =========================================
			// paddle
			// draw paddle use the basic setting & paddle_pos
			// right paddle(red)     left paddle(blue)
			// =========================================
			if(h_cnt >= paddle10_posx - PAD_WIDTH && h_cnt <= paddle10_posx + PAD_WIDTH && v_cnt >= paddle10_posy - HALF_PAD_HEIGHT && v_cnt <= paddle10_posy + HALF_PAD_HEIGHT)
				pixel = {4'd0,4'd0,4'd15};
			if(h_cnt >= paddle11_posx - PAD_WIDTH && h_cnt <= paddle11_posx + PAD_WIDTH && v_cnt >= paddle11_posy - HALF_PAD_HEIGHT && v_cnt <= paddle11_posy + HALF_PAD_HEIGHT)
				pixel = {4'd0,4'd0,4'd15};
			if(h_cnt >= paddle20_posx - PAD_WIDTH && h_cnt <= paddle20_posx + PAD_WIDTH && v_cnt >= paddle20_posy - HALF_PAD_HEIGHT && v_cnt <= paddle20_posy + HALF_PAD_HEIGHT)
				pixel = {4'd15,4'd0,4'd0};
			if(h_cnt >= paddle21_posx - PAD_WIDTH && h_cnt <= paddle21_posx + PAD_WIDTH && v_cnt >= paddle21_posy - HALF_PAD_HEIGHT && v_cnt <= paddle21_posy + HALF_PAD_HEIGHT)
				pixel = {4'd15,4'd0,4'd0};
			// =========================================
			// ball(fill)
			// draw ball use the basic setting & ball_pos & ball_vel
			// use the ball velocity to draw the color  
			// if ball goes to left => red 
			// if ball goes to right => blue
			// the thing should notice is to judge the velocity value which is negative or positive
			// the method is watching the MSB is 1(negative) or 0(positive) 
			// =========================================
			if(h_cnt >= ball1_posx - BALL_RADIUS && h_cnt <= ball1_posx + BALL_RADIUS && v_cnt <= ball1_posy + BALL_RADIUS && v_cnt >= ball1_posy - BALL_RADIUS)begin
				if(ball1_velx[10] == 0)
					pixel = {4'd0, 4'd0, 4'd15};
				else 
					pixel = {4'd15, 4'd0, 4'd0};
			end
			if(h_cnt >= ball2_posx - BALL_RADIUS && h_cnt <= ball2_posx + BALL_RADIUS && v_cnt <= ball2_posy + BALL_RADIUS && v_cnt >= ball2_posy - BALL_RADIUS)begin
				if(ball2_velx[10] == 0)
					pixel = {4'd0, 4'd0, 4'd15};
				else 
					pixel = {4'd15, 4'd0, 4'd0};
			end
			if(h_cnt >= ball3_posx - BALL_RADIUS && h_cnt <= ball3_posx + BALL_RADIUS && v_cnt <= ball3_posy + BALL_RADIUS && v_cnt >= ball3_posy - BALL_RADIUS)begin
				if(ball3_velx[10] == 0)
					pixel = {4'd0, 4'd0, 4'd15};
				else 
					pixel = {4'd15, 4'd0, 4'd0};
			end
			if(h_cnt >= ball4_posx - BALL_RADIUS && h_cnt <= ball4_posx + BALL_RADIUS && v_cnt <= ball4_posy + BALL_RADIUS && v_cnt >= ball4_posy - BALL_RADIUS)begin
				if(ball4_velx[10] == 0)
					pixel = {4'd0, 4'd0, 4'd15};
				else 
					pixel = {4'd15, 4'd0, 4'd0};
			end
			if(h_cnt >= ball5_posx - BALL_RADIUS && h_cnt <= ball5_posx + BALL_RADIUS && v_cnt <= ball5_posy + BALL_RADIUS && v_cnt >= ball5_posy - BALL_RADIUS)begin
				if(ball5_velx[10] == 0)
					pixel = {4'd0, 4'd0, 4'd15};
				else 
					pixel = {4'd15, 4'd0, 4'd0};
			end
			// =========================================
			// win
			// When timecounter goes to 0, it means the game is over
			// compare the score of the both side
			// the winner's side will display "WIN"
			// if the both side score is the same, the p2(right) win
			// =========================================
			if(timecounter == 8'd0)begin
				if(Play1_S > Play2_S)begin
					//W
					if(h_cnt >= 11'd30 && h_cnt <= 11'd42 && v_cnt >= 11'd40 && v_cnt <= 11'd100)
						pixel = {4'd0, 4'd0, 4'd15};
					if(h_cnt >= 11'd42 && h_cnt <= 11'd48 && v_cnt >= 11'd82 && v_cnt <= 11'd100)
						pixel = {4'd0, 4'd0, 4'd15};
					if(h_cnt >= 11'd48 && h_cnt <= 11'd54 && v_cnt >= 11'd76 && v_cnt <= 11'd94)
						pixel = {4'd0, 4'd0, 4'd15};
					if(h_cnt >= 11'd54 && h_cnt <= 11'd60 && v_cnt >= 11'd70 && v_cnt <= 11'd88)
						pixel = {4'd0, 4'd0, 4'd15};
					if(h_cnt >= 11'd60 && h_cnt <= 11'd66 && v_cnt >= 11'd64 && v_cnt <= 11'd82)
						pixel = {4'd0, 4'd0, 4'd15};
					if(h_cnt >= 11'd66 && h_cnt <= 11'd72 && v_cnt >= 11'd58 && v_cnt <= 11'd76)
						pixel = {4'd0, 4'd0, 4'd15};
					if(h_cnt >= 11'd72 && h_cnt <= 11'd84 && v_cnt >= 11'd58 && v_cnt <= 11'd70)
						pixel = {4'd0, 4'd0, 4'd15};
					if(h_cnt >= 11'd84 && h_cnt <= 11'd90 && v_cnt >= 11'd58 && v_cnt <= 11'd76)
						pixel = {4'd0, 4'd0, 4'd15};
					if(h_cnt >= 11'd90 && h_cnt <= 11'd96 && v_cnt >= 11'd64 && v_cnt <= 11'd82)
						pixel = {4'd0, 4'd0, 4'd15};
					if(h_cnt >= 11'd96 && h_cnt <= 11'd102 && v_cnt >= 11'd70 && v_cnt <= 11'd88)
						pixel = {4'd0, 4'd0, 4'd15};
					if(h_cnt >= 11'd102 && h_cnt <= 11'd108 && v_cnt >= 11'd76 && v_cnt <= 11'd94)
						pixel = {4'd0, 4'd0, 4'd15};
					if(h_cnt >= 11'd108 && h_cnt <= 11'd114 && v_cnt >= 11'd82 && v_cnt <= 11'd100)
						pixel = {4'd0, 4'd0, 4'd15};
					if(h_cnt >= 11'd114 && h_cnt <= 11'd126 && v_cnt >= 11'd40 && v_cnt <= 11'd100)
						pixel = {4'd0, 4'd0, 4'd15};
					//I
					if(h_cnt >= 11'd132 && h_cnt <= 11'd144 && ((v_cnt >= 11'd40 && v_cnt <= 11'd52) || (v_cnt >= 11'd88 && v_cnt <= 11'd100)))
						pixel = {4'd0, 4'd0, 4'd15};
					if(h_cnt >= 11'd144 && h_cnt <= 11'd162 && v_cnt >= 11'd40 && v_cnt <= 11'd100)
						pixel = {4'd0, 4'd0, 4'd15};
					if(h_cnt >= 11'd162 && h_cnt <= 11'd174 && ((v_cnt >= 11'd40 && v_cnt <= 11'd52) || (v_cnt >= 11'd88 && v_cnt <= 11'd100)))
						pixel = {4'd0, 4'd0, 4'd15};
					//N
					if(h_cnt >= 11'd186 && h_cnt <= 11'd198 && v_cnt >= 11'd40 && v_cnt <= 11'd100)
						pixel = {4'd0, 4'd0, 4'd15};
					if(h_cnt >= 11'd198 && h_cnt <= 11'd204 && v_cnt >= 11'd40 && v_cnt <= 11'd58)
						pixel = {4'd0, 4'd0, 4'd15};
					if(h_cnt >= 11'd204 && h_cnt <= 11'd210 && v_cnt >= 11'd46 && v_cnt <= 11'd64)
						pixel = {4'd0, 4'd0, 4'd15};
					if(h_cnt >= 11'd210 && h_cnt <= 11'd216 && v_cnt >= 11'd52 && v_cnt <= 11'd70)
						pixel = {4'd0, 4'd0, 4'd15};
					if(h_cnt >= 11'd216 && h_cnt <= 11'd222 && v_cnt >= 11'd58 && v_cnt <= 11'd76)
						pixel = {4'd0, 4'd0, 4'd15};
					if(h_cnt >= 11'd222 && h_cnt <= 11'd228 && v_cnt >= 11'd64 && v_cnt <= 11'd82)
						pixel = {4'd0, 4'd0, 4'd15};
					if(h_cnt >= 11'd228 && h_cnt <= 11'd234 && v_cnt >= 11'd70 && v_cnt <= 11'd88)
						pixel = {4'd0, 4'd0, 4'd15};				
					if(h_cnt >= 11'd234 && h_cnt <= 11'd240 && v_cnt >= 11'd76 && v_cnt <= 11'd94)
						pixel = {4'd0, 4'd0, 4'd15};
					if(h_cnt >= 11'd240 && h_cnt <= 11'd252 && v_cnt >= 11'd40 && v_cnt <= 11'd100)
						pixel = {4'd0, 4'd0, 4'd15};
				end else begin
					//W
					if(h_cnt >= 11'd478 && h_cnt <= 11'd490 && v_cnt >= 11'd40 && v_cnt <= 11'd100)
						pixel = {4'd0, 4'd15, 4'd0};
					if(h_cnt >= 11'd472 && h_cnt <= 11'd478 && v_cnt >= 11'd82 && v_cnt <= 11'd100)
						pixel = {4'd0, 4'd15, 4'd0};
					if(h_cnt >= 11'd466 && h_cnt <= 11'd472 && v_cnt >= 11'd76 && v_cnt <= 11'd94)
						pixel = {4'd0, 4'd15, 4'd0};
					if(h_cnt >= 11'd460 && h_cnt <= 11'd466 && v_cnt >= 11'd70 && v_cnt <= 11'd88)
						pixel = {4'd0, 4'd15, 4'd0};
					if(h_cnt >= 11'd454 && h_cnt <= 11'd460 && v_cnt >= 11'd64 && v_cnt <= 11'd82)
						pixel = {4'd0, 4'd15, 4'd0};
					if(h_cnt >= 11'd448 && h_cnt <= 11'd454 && v_cnt >= 11'd58 && v_cnt <= 11'd76)
						pixel = {4'd0, 4'd15, 4'd0};
					if(h_cnt >= 11'd442 && h_cnt <= 11'd448 && v_cnt >= 11'd58 && v_cnt <= 11'd70)
						pixel = {4'd0, 4'd15, 4'd0};
					if(h_cnt >= 11'd436 && h_cnt <= 11'd442 && v_cnt >= 11'd58 && v_cnt <= 11'd76)
						pixel = {4'd0, 4'd15, 4'd0};
					if(h_cnt >= 11'd432 && h_cnt <= 11'd436 && v_cnt >= 11'd64 && v_cnt <= 11'd82)
						pixel = {4'd0, 4'd15, 4'd0};
					if(h_cnt >= 11'd426 && h_cnt <= 11'd432 && v_cnt >= 11'd70 && v_cnt <= 11'd88)
						pixel = {4'd0, 4'd15, 4'd0};
					if(h_cnt >= 11'd420 && h_cnt <= 11'd426 && v_cnt >= 11'd76 && v_cnt <= 11'd94)
						pixel = {4'd0, 4'd15, 4'd0};
					if(h_cnt >= 11'd414 && h_cnt <= 11'd420 && v_cnt >= 11'd82 && v_cnt <= 11'd100)
						pixel = {4'd0, 4'd15, 4'd0};
					if(h_cnt >= 11'd402 && h_cnt <= 11'd414 && v_cnt >= 11'd40 && v_cnt <= 11'd100)
						pixel = {4'd0, 4'd15, 4'd0};
					//I
					if(h_cnt >= 11'd526 && h_cnt <= 11'd538 && ((v_cnt >= 11'd40 && v_cnt <= 11'd52) || (v_cnt >= 11'd88 && v_cnt <= 11'd100)))
						pixel = {4'd0, 4'd15, 4'd0};
					if(h_cnt >= 11'd508 && h_cnt <= 11'd526 && v_cnt >= 11'd40 && v_cnt <= 11'd100)
						pixel = {4'd0, 4'd15, 4'd0};
					if(h_cnt >= 11'd496 && h_cnt <= 11'd508 && ((v_cnt >= 11'd40 && v_cnt <= 11'd52) || (v_cnt >= 11'd88 && v_cnt <= 11'd100)))
						pixel = {4'd0, 4'd15, 4'd0};
					//N
					if(h_cnt >= 11'd598 && h_cnt <= 11'd610 && v_cnt >= 11'd40 && v_cnt <= 11'd100)
						pixel = {4'd0, 4'd15, 4'd0};
					if(h_cnt >= 11'd592 && h_cnt <= 11'd598 && v_cnt >= 11'd76 && v_cnt <= 11'd94)
						pixel = {4'd0, 4'd15, 4'd0};
					if(h_cnt >= 11'd586 && h_cnt <= 11'd592 && v_cnt >= 11'd70 && v_cnt <= 11'd88)
						pixel = {4'd0, 4'd15, 4'd0};
					if(h_cnt >= 11'd580 && h_cnt <= 11'd586 && v_cnt >= 11'd64 && v_cnt <= 11'd82)
						pixel = {4'd0, 4'd15, 4'd0};
					if(h_cnt >= 11'd574 && h_cnt <= 11'd580 && v_cnt >= 11'd58 && v_cnt <= 11'd76)
						pixel = {4'd0, 4'd15, 4'd0};
					if(h_cnt >= 11'd568 && h_cnt <= 11'd574 && v_cnt >= 11'd52 && v_cnt <= 11'd70)
						pixel = {4'd0, 4'd15, 4'd0};
					if(h_cnt >= 11'd562 && h_cnt <= 11'd568 && v_cnt >= 11'd46 && v_cnt <= 11'd64)
						pixel = {4'd0, 4'd15, 4'd0};				
					if(h_cnt >= 11'd556 && h_cnt <= 11'd562 && v_cnt >= 11'd40 && v_cnt <= 11'd58)
						pixel = {4'd0, 4'd15, 4'd0};
					if(h_cnt >= 11'd544 && h_cnt <= 11'd556 && v_cnt >= 11'd40 && v_cnt <= 11'd100)
						pixel = {4'd0, 4'd15, 4'd0};
				end
			end else begin
				if(h_cnt >= 11'd319 && h_cnt <= 11'd321 && v_cnt <= 11'd1)
				pixel = {4'd15, 4'd15, 4'd15};
			end
		end	
	end

	clock_divisor clk_wiz_0_inst(
      .clk(clk),
      .clk1(clk_25MHz),
	  .rst_n(rst_n)
    );

    blk_mem_gen_1 blk_mem_gen_1_inst(
      .clka(clk_25MHz),
      .wea(0),
      .addra(pixel_addr),
      .dina(data[11:0]),
      .douta(outdata)
    ); 

    vga_controller  vga_inst(
      .pclk(clk_25MHz),
      .reset(rst_n),
      .hsync(hsync),
      .vsync(vsync),
      .valid(valid),
      .h_cnt(h_cnt),
      .v_cnt(v_cnt)
    );
endmodule


module vga_controller 
  (
    input wire pclk,reset,
    output wire hsync,vsync,valid,
    output wire signed [10:0]h_cnt,
    output wire signed [10:0]v_cnt
    );
    
    reg [10:0]pixel_cnt;
    reg [10:0]line_cnt;
    reg hsync_i,vsync_i;
    wire hsync_default, vsync_default;
    wire [10:0] HD, HF, HS, HB, HT, VD, VF, VS, VB, VT;

   
    assign HD = 640;
    assign HF = 16;
    assign HS = 96;
    assign HB = 48;
    assign HT = 800; 
    assign VD = 480;
    assign VF = 10;
    assign VS = 2;
    assign VB = 33;
    assign VT = 525;
    assign hsync_default = 1'b1;
    assign vsync_default = 1'b1;
     
    always@(posedge pclk, posedge reset)
        if(reset)
            pixel_cnt <= 0;
        else if(pixel_cnt < (HT - 1))
                pixel_cnt <= pixel_cnt + 1;
             else
                pixel_cnt <= 0;

    always@(posedge pclk, posedge reset)
        if(reset)
            hsync_i <= hsync_default;
        else if((pixel_cnt >= (HD + HF - 1))&&(pixel_cnt < (HD + HF + HS - 1)))
                hsync_i <= ~hsync_default;
            else
                hsync_i <= hsync_default; 
    
    always@(posedge pclk, posedge reset)
        if(reset)
            line_cnt <= 0;
        else if(pixel_cnt == (HT -1))
                if(line_cnt < (VT - 1))
                    line_cnt <= line_cnt + 1;
                else
                    line_cnt <= 0;
                    
    always@(posedge pclk, posedge reset)
        if(reset)
            vsync_i <= vsync_default; 
        else if((line_cnt >= (VD + VF - 1))&&(line_cnt < (VD + VF + VS - 1)))
            vsync_i <= ~vsync_default; 
        else
            vsync_i <= vsync_default; 
                    
    assign hsync = hsync_i;
    assign vsync = vsync_i;
    assign valid = ((pixel_cnt < HD) && (line_cnt < VD));
    
    assign h_cnt = (pixel_cnt < HD) ? pixel_cnt:11'd0;
    assign v_cnt = (line_cnt < VD) ? line_cnt:11'd0;
           
endmodule
module clock_divisor(clk1, clk, rst_n);
	input clk;
	input rst_n;
	output clk1;

	reg [1:0] num;
	wire [1:0] next_num;

	always @(posedge clk) begin
		if(rst_n)
			num <= 2'd0;
		else
			num <= next_num;
	end

	assign next_num = num + 1'b1;
	assign clk1 = num[1];

endmodule
