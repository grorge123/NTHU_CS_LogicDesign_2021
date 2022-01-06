module step(
	input wire [2:0] play1_M,
	input wire [2:0] play2_M,
	input wire clk,
	input wire rst_n,
	input wire stclk,
	output signed [10:0] ball1_posx,
	output signed [10:0] ball1_posy,
	output signed [10:0] ball2_posx,
	output signed [10:0] ball2_posy,
	output signed [10:0] ball3_posx,
	output signed [10:0] ball3_posy,
	output signed [10:0] ball4_posx,
	output signed [10:0] ball4_posy,
	output signed [10:0] ball5_posx,
	output signed [10:0] ball5_posy,
	output signed [10:0] ball1_velx,
	output signed [10:0] ball1_vely,
	output signed [10:0] ball2_velx,
	output signed [10:0] ball2_vely,
	output signed [10:0] ball3_velx,
	output signed [10:0] ball3_vely,
	output signed [10:0] ball4_velx,
	output signed [10:0] ball4_vely,
	output signed [10:0] ball5_velx,
	output signed [10:0] ball5_vely,
	output signed [10:0] paddle10_posx,
	output signed [10:0] paddle10_posy,
	output signed [10:0] paddle11_posx,
	output signed [10:0] paddle11_posy,
	output signed [10:0] paddle20_posx,
	output signed [10:0] paddle20_posy,
	output signed [10:0] paddle21_posx,
	output signed [10:0] paddle21_posy,
	output reg [4:0] l_score,
	output reg [4:0] r_score
);
	reg signed [10:0] ball_pos[4:0][1:0];
	reg signed [10:0] ball_vel[4:0][1:0];
	reg signed [10:0] paddle1_pos[1:0][1:0];
	reg signed [10:0] paddle2_pos[1:0][1:0];
	reg signed [10:0] next_ball_pos[4:0][1:0];
	reg signed [10:0] next_ball_vel[4:0][1:0];
	reg signed [10:0] tmp_ball_pos[4:0][1:0];
	reg signed [10:0] tmp_ball_vel[4:0][1:0];
	reg [4:0] next_l_score[4:0];
	reg [4:0] next_r_score[4:0];

	assign ball1_posx = ball_pos[0][0];
	assign ball1_posy = ball_pos[0][1];
	assign ball2_posx = ball_pos[1][0];
	assign ball2_posy = ball_pos[1][1];
	assign ball3_posx = ball_pos[2][0];
	assign ball3_posy = ball_pos[2][1];
	assign ball4_posx = ball_pos[3][0];
	assign ball4_posy = ball_pos[3][1];
	assign ball5_posx = ball_pos[4][0];
	assign ball5_posy = ball_pos[4][1];
	assign ball1_velx = ball_vel[0][0];
	assign ball1_vely = ball_vel[0][1];
	assign ball2_velx = ball_vel[1][0];
	assign ball2_vely = ball_vel[1][1];
	assign ball3_velx = ball_vel[2][0];
	assign ball3_vely = ball_vel[2][1];
	assign ball4_velx = ball_vel[3][0];
	assign ball4_vely = ball_vel[3][1];
	assign ball5_velx = ball_vel[4][0];
	assign ball5_vely = ball_vel[4][1];
	assign paddle10_posx = paddle1_pos[0][0];
	assign paddle10_posy = paddle1_pos[0][1];
	assign paddle20_posx = paddle2_pos[0][0];
	assign paddle20_posy = paddle2_pos[0][1];
	assign paddle11_posx = paddle1_pos[1][0];
	assign paddle11_posy = paddle1_pos[1][1];
	assign paddle21_posx = paddle2_pos[1][0];
	assign paddle21_posy = paddle2_pos[1][1];
	parameter signed WIDTH = 11'd640;
	parameter signed HEIGHT = 11'd480;       
	parameter signed BALL_RADIUS = 11'd10;
	parameter signed PAD_WIDTH = 11'd4;
	parameter signed PAD_HEIGHT = 11'd80;
	parameter signed PAD_SPACE = 11'd60;
	parameter signed HALF_PAD_WIDTH = PAD_WIDTH / 2;
	parameter signed HALF_PAD_HEIGHT = PAD_HEIGHT / 2;
	parameter signed ZERO = 11'd0;
	reg [2:0] objcounter;
	reg [2:0] next_objcounter;
	reg [1:0] mode;
	reg [1:0] next_mode[4:0];

	// -1 2
	// 1 3
	// 2 -4
	// -2 1
	wire [7:0] out1, out2;
	LFSR1 L1(.clk(clk), .rst_n(rst_n), .out(out1));
	LFSR2 L2(.clk(clk), .rst_n(rst_n), .out(out2));
	integer a, q, l, o, p, b, c; 
	always@(posedge clk)begin
		if(rst_n)begin
			objcounter <= 3'd0;
			paddle1_pos[0][0] <= HALF_PAD_WIDTH - 1;
			paddle1_pos[0][1] <= HEIGHT / 2;
			paddle1_pos[1][0] <= HALF_PAD_WIDTH - 1 + PAD_SPACE;
			paddle1_pos[1][1] <= HEIGHT / 2;
			paddle2_pos[0][0] <= WIDTH + 1 - HALF_PAD_WIDTH;
			paddle2_pos[0][1] <= HEIGHT / 2;
			paddle2_pos[1][0] <= WIDTH + 1 - HALF_PAD_WIDTH - PAD_SPACE;
			paddle2_pos[1][1] <= HEIGHT / 2;
			l_score <= 5'd0;
			r_score <= 5'd0;
			for(a = 0 ; a < 5 ; a = a + 1)begin
				ball_pos[a][0] <= WIDTH / 2;
				ball_pos[a][1] <= HEIGHT / 2;
			end
			// ball_vel[0][0] <= -11'd1;
			// ball_vel[0][1] <= -11'd2;
			ball_vel[0][0] <= -11'd5;
			ball_vel[0][1] <= -11'd20;
			ball_vel[1][0] <= 11'd2;
			ball_vel[1][1] <= 11'd1;
			ball_vel[2][0] <= -11'd3;
			ball_vel[2][1] <= 11'd2;
			ball_vel[3][0] <= 11'd3;
			ball_vel[3][1] <= 11'd1;
			ball_vel[4][0] <= -11'd4;
			ball_vel[4][1] <= 11'd3;
			mode <= 2'd0;
		end else begin
			mode <= mode + next_mode[0] + next_mode[1] + next_mode[2] + next_mode[3] + next_mode[4];
			
			l_score <= l_score + next_l_score[0] + next_l_score[1] + next_l_score[2] + next_l_score[3] + next_l_score[4];
			r_score <= r_score + next_r_score[0] + next_r_score[1] + next_r_score[2] + next_r_score[3] + next_r_score[4];
			if(stclk)begin
				objcounter <= 3'd0;
				for(l = 0 ; l < 5 ; l = l + 1)begin
					ball_pos[l][0] <= tmp_ball_pos[l][0];
					ball_pos[l][1] <= tmp_ball_pos[l][1];
					ball_vel[l][0] <= tmp_ball_vel[l][0] == ZERO ? 11'd1 : tmp_ball_vel[l][0];
					ball_vel[l][1] <= tmp_ball_vel[l][1];
				end
				paddle1_pos[0][1] <= play1_M == 3'd2 && paddle1_pos[0][1] < HEIGHT - HALF_PAD_HEIGHT ? paddle1_pos[0][1] + 11'd4: 
									play1_M == 3'd1  && paddle1_pos[0][1] > HALF_PAD_HEIGHT ? paddle1_pos[0][1] - 11'd4 : paddle1_pos[0][1];
				paddle1_pos[1][1] <= play1_M == 3'd4 && paddle1_pos[1][1] < HEIGHT - HALF_PAD_HEIGHT ? paddle1_pos[1][1] + 11'd4: 
									play1_M == 3'd3 && paddle1_pos[1][1] > HALF_PAD_HEIGHT ? paddle1_pos[1][1] - 11'd4 : paddle1_pos[1][1];
				paddle2_pos[0][1] <= play2_M == 3'd4 && paddle2_pos[0][1] < HEIGHT - HALF_PAD_HEIGHT? paddle2_pos[0][1] + 11'd4: 
									play2_M == 3'd3 && paddle2_pos[0][1] > HALF_PAD_HEIGHT ? paddle2_pos[0][1] - 11'd4 : paddle2_pos[0][1];
				paddle2_pos[1][1] <= play2_M == 3'd2 && paddle2_pos[1][1] < HEIGHT - HALF_PAD_HEIGHT? paddle2_pos[1][1] + 11'd4: 
									play2_M == 3'd1 && paddle2_pos[1][1] > HALF_PAD_HEIGHT ? paddle2_pos[1][1] - 11'd4 : paddle2_pos[1][1];
			end
			else begin
				objcounter <= (objcounter < 3'd5 ? next_objcounter : objcounter);
				paddle1_pos[0][1] <= paddle1_pos[0][1];
				paddle1_pos[1][1] <= paddle1_pos[1][1];
				paddle2_pos[0][1] <= paddle2_pos[0][1];
				paddle2_pos[1][1] <= paddle2_pos[1][1];
				for(b = 0 ; b < 5 ; b = b + 1)begin
					for(c = 0 ; c < 2 ; c = c + 1)begin
						ball_pos[b][c] <= ball_pos[b][c];
						ball_vel[b][c] <= ball_vel[b][c];
					end
				end
				paddle1_pos[0][0] <= paddle1_pos[0][0];
				paddle1_pos[1][0] <= paddle1_pos[1][0];
				paddle2_pos[0][0] <= paddle2_pos[0][0];
				paddle2_pos[1][0] <= paddle2_pos[1][0];
			end
		end
	end
	always@(posedge clk)begin
		for(o = 0 ; o < 5 ; o = o + 1)begin
			for(p = 0 ; p < 2 ; p = p + 1)begin
				tmp_ball_pos[o][p] <= next_ball_pos[o][p];						
				tmp_ball_vel[o][p] <= next_ball_vel[o][p];						
			end
		end
	end

	always@(*)begin
		next_objcounter = objcounter + 3'd1;
	end
	wire test1, test2, test3, test4;
	assign test1 = ball_pos[0][0] + BALL_RADIUS + ball_vel[0][0] >= paddle1_pos[0][0] - PAD_WIDTH;
	assign test2 = ball_pos[0][0] <= paddle1_pos[0][0] - PAD_WIDTH;
	assign test3 = ball_pos[0][1] >= paddle1_pos[0][1] - HALF_PAD_HEIGHT - BALL_RADIUS;
	assign test4 = ball_pos[0][1] <= paddle1_pos[0][1] + HALF_PAD_HEIGHT;
	genvar id;
	generate
		for(id = 0 ; id < 5 ; id = id + 1)begin
			always@(*)begin
				next_l_score[id] = 5'd0;
				next_r_score[id] = 5'd0;
				next_mode[id] = 2'd0;
				if(id == objcounter) begin
					next_ball_pos[id][0] = ball_pos[id][0] + ball_vel[id][0];
					next_ball_pos[id][1] = ball_pos[id][1] + ball_vel[id][1];
					next_ball_vel[id][0] = ball_vel[id][0];
					next_ball_vel[id][1] = ball_vel[id][1];
					if(ball_pos[id][1] <= BALL_RADIUS && ball_vel[id][1][10] == 1'd1)
						next_ball_vel[id][1] = ball_vel[id][1] * -11'd1;
					if(ball_pos[id][1] >= HEIGHT + 11'd1 - BALL_RADIUS && ball_vel[id][1][10] == 1'd0)
						next_ball_vel[id][1] = ball_vel[id][1] * -11'd1;
					for(q = 0 ; q < 2 ; q = q + 1)begin
						if(ball_pos[id][0] + BALL_RADIUS + ball_vel[id][0] >= paddle1_pos[q][0] - PAD_WIDTH && ball_pos[id][0] <= paddle1_pos[q][0] - PAD_WIDTH && ball_vel[id][0] > ZERO &&
						ball_pos[id][1] + BALL_RADIUS >= paddle1_pos[q][1] - HALF_PAD_HEIGHT - BALL_RADIUS && ball_pos[id][1] - BALL_RADIUS <= paddle1_pos[q][1] + HALF_PAD_HEIGHT)begin
							next_ball_vel[id][0] = (ball_vel[id][0] * -11'd1) - 11'd1;
							next_ball_vel[id][1] = ball_vel[id][1] > 0 ? ball_vel[id][1] + 11'd1: ball_vel[id][1] - 11'd1;
						end
						if(ball_pos[id][0] - BALL_RADIUS + ball_vel[id][0] <= paddle1_pos[q][0] + PAD_WIDTH && ball_pos[id][0] >= paddle1_pos[q][0] + PAD_WIDTH && ball_vel[id][0] < ZERO &&
						ball_pos[id][1] + BALL_RADIUS >= paddle1_pos[q][1] - HALF_PAD_HEIGHT - BALL_RADIUS && ball_pos[id][1] - BALL_RADIUS <= paddle1_pos[q][1] + HALF_PAD_HEIGHT)begin
							next_ball_vel[id][0] = (ball_vel[id][0] * -11'd1) + 11'd1;
							next_ball_vel[id][1] = ball_vel[id][1] > 0 ? ball_vel[id][1] + 11'd1: ball_vel[id][1] - 11'd1;
						end
						if(ball_pos[id][0] <= BALL_RADIUS)begin
							next_ball_vel[id][0] = {9'd0,out2[2],out2[6]};
													 
							next_ball_vel[id][1] = (out2[2] == 1'd0 ? {9'd0,out2[1:0]} : {9'b0,out2[1:0]} * -11'd1);
							next_ball_pos[id][0] = WIDTH / 2;
							next_ball_pos[id][1] = HEIGHT / 2;
							next_mode[id] = 2'd1;
							next_r_score[id] = 5'd1;
						end

						if(ball_pos[id][0] + BALL_RADIUS + ball_vel[id][0] >= paddle2_pos[q][0] - PAD_WIDTH && ball_pos[id][0] <= paddle2_pos[q][0] - PAD_WIDTH && ball_vel[id][0] > ZERO &&
						ball_pos[id][1] + BALL_RADIUS >= paddle2_pos[q][1] - HALF_PAD_HEIGHT - BALL_RADIUS && ball_pos[id][1] - BALL_RADIUS <= paddle2_pos[q][1] + HALF_PAD_HEIGHT)begin
							next_ball_vel[id][0] = (ball_vel[id][0] * -11'd1) - 11'd1;
							next_ball_vel[id][1] = ball_vel[id][1] > 0 ? ball_vel[id][1] + 11'd1: ball_vel[id][1] - 11'd1;
						end
						if(ball_pos[id][0] - BALL_RADIUS + ball_vel[id][0] <= paddle2_pos[q][0] + PAD_WIDTH && ball_pos[id][0] >= paddle2_pos[q][0] + PAD_WIDTH && ball_vel[id][0] < ZERO &&
						ball_pos[id][1] + BALL_RADIUS >= paddle2_pos[q][1] - HALF_PAD_HEIGHT - BALL_RADIUS && ball_pos[id][1] - BALL_RADIUS <= paddle2_pos[q][1] + HALF_PAD_HEIGHT)begin
							next_ball_vel[id][0] = (ball_vel[id][0] * -11'd1) + 11'd1;
							next_ball_vel[id][1] = ball_vel[id][1] > 0 ? ball_vel[id][1] + 11'd1: ball_vel[id][1] - 11'd1;
						end
						if(ball_pos[id][0] >= WIDTH + 1 - BALL_RADIUS - PAD_WIDTH)begin
							next_ball_vel[id][0] = {9'b111111111,out2[4],out2[6]};
													 
							next_ball_vel[id][1] = (out2[2] == 1'd0 ? {9'd0,out2[1:0]} : {9'b0,out2[1:0]} * -11'd1);
							next_ball_pos[id][0] = WIDTH / 2;
							next_ball_pos[id][1] = HEIGHT / 2;
							next_mode[id] = 2'd1;
							next_l_score[id] = 5'd1;
						end

					end
				end else begin
					next_ball_pos[id][0] = tmp_ball_pos[id][0];
					next_ball_pos[id][1] = tmp_ball_pos[id][1];
					next_ball_vel[id][0] = tmp_ball_vel[id][0];
					next_ball_vel[id][1] = tmp_ball_vel[id][1];
				end
			end
		end
	endgenerate


endmodule