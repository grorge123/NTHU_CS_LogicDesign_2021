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
	//new thing
	input wire signed [10:0] ball1_velx,
	input wire signed [10:0] ball2_velx,
	input wire signed [10:0] ball3_velx,
	input wire signed [10:0] ball4_velx,
	input wire signed [10:0] ball5_velx,
	//score
	input wire [8:0] Play1_S,
	input wire [8:0] Play2_S,

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
	// wire [11:0] data;
	// assign data = 12'd0;
    wire clk_25MHz;
    wire clk_22;
    // wire [16:0] pixel_addr;
    reg [11:0] pixel;
    // wire [11:0] outdata;
    wire valid;
    wire signed [10:0] h_cnt; //640
    wire signed [10:0] v_cnt;  //480
	//background update
	// wire [8:0] sub;
	parameter signed WIDTH = 11'd640;
	parameter signed HEIGHT = 11'd480;       
	parameter signed BALL_RADIUS = 11'd6;
	parameter signed PAD_WIDTH = 11'd4;
	parameter signed PAD_HEIGHT = 11'd80;
	parameter signed PAD_SPACE = 11'd60;
	parameter signed HALF_PAD_WIDTH = PAD_WIDTH / 2;
	parameter signed HALF_PAD_HEIGHT = PAD_HEIGHT / 2;

	assign {vgaRed, vgaGreen, vgaBlue} = (valid==1'b1) ? pixel:12'h0;

    clock_divisor clk_wiz_0_inst(
      .clk(clk),
      .clk1(clk_25MHz),
	  .rst_n(rst_n)
    );
     
    // blk_mem_gen_0 blk_mem_gen_0_inst(
    //   .clka(clk_25MHz),
    //   .wea(0),
    //   .addra(pixel_addr),
    //   .dina(data[11:0]),
    //   .douta(outdata)
    // ); 

    vga_controller  vga_inst(
      .pclk(clk_25MHz),
      .reset(rst_n),
      .hsync(hsync),
      .vsync(vsync),
      .valid(valid),
      .h_cnt(h_cnt),
      .v_cnt(v_cnt)
    );

	// assign sub = ;
	wire [10:0] lf, rf;
	assign lf = (11'd320 + ({2'b0, Play1_S} - {2'b0, Play2_S}) * 11'd2);
	assign rf = (11'd320 - ({2'b0, Play2_S} - {2'b0, Play1_S}) * 11'd2);
	always@(*)begin
		// pixel = outdata;
		//backgroud
		if(Play1_S > Play2_S)begin
			if(h_cnt <= lf || lf < 11'd320)begin
				pixel = {4'd0, 4'd15, 4'd0};
			end else begin
				pixel = {4'd0, 4'd0, 4'd0};
			end
		end else begin
			if(h_cnt <= rf || rf < 11'd320)begin
				pixel = {4'd0, 4'd15, 4'd0};
			end else begin
				pixel = {4'd0, 4'd0, 4'd0};
			end
		end
		// if(h_cnt >= 11'd320 )
		// 	pixel = {4'd0 , 4'd15 , 4'd0};
		//central line
		if(h_cnt >= 11'd319 && h_cnt <= 11'd322)
			pixel = {4'd15, 4'd15, 4'd15};
		
		//right paddle(red)     left paddle(blue)
		if(h_cnt >= paddle10_posx - PAD_WIDTH && h_cnt <= paddle10_posx + PAD_WIDTH && v_cnt >= paddle10_posy - HALF_PAD_HEIGHT && v_cnt <= paddle10_posy + HALF_PAD_HEIGHT)
			pixel = {4'd0,4'd0,4'd15};
		if(h_cnt >= paddle11_posx - PAD_WIDTH && h_cnt <= paddle11_posx + PAD_WIDTH && v_cnt >= paddle11_posy - HALF_PAD_HEIGHT && v_cnt <= paddle11_posy + HALF_PAD_HEIGHT)
			pixel = {4'd0,4'd0,4'd15};
		if(h_cnt >= paddle20_posx - PAD_WIDTH && h_cnt <= paddle20_posx + PAD_WIDTH && v_cnt >= paddle20_posy - HALF_PAD_HEIGHT && v_cnt <= paddle20_posy + HALF_PAD_HEIGHT)
			pixel = {4'd15,4'd0,4'd0};
		if(h_cnt >= paddle21_posx - PAD_WIDTH && h_cnt <= paddle21_posx + PAD_WIDTH && v_cnt >= paddle21_posy - HALF_PAD_HEIGHT && v_cnt <= paddle21_posy + HALF_PAD_HEIGHT)
			pixel = {4'd15,4'd0,4'd0};
		//ball(fill)
		//if ball goes to left => red 
		//if ball goes to right => blue
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

		//ball(side)
		// if(h_cnt >= ball1_posx - BALL_RADIUS && h_cnt <= ball1_posx + BALL_RADIUS && v_cnt == ball1_posy + BALL_RADIUS)
		// 	pixel = {4'd4, 4'd0, 4'd0};
		// if(h_cnt >= ball1_posx - BALL_RADIUS && h_cnt <= ball1_posx + BALL_RADIUS && v_cnt == ball1_posy - BALL_RADIUS)
		// 	pixel = {4'd4, 4'd0, 4'd0};
		// if(v_cnt >= ball1_posy - BALL_RADIUS && v_cnt <= ball1_posy + BALL_RADIUS && h_cnt == ball1_posx + BALL_RADIUS)
		// 	pixel = {4'd4, 4'd0, 4'd0};
		// if(v_cnt >= ball1_posy - BALL_RADIUS && v_cnt <= ball1_posy + BALL_RADIUS && h_cnt == ball1_posx - BALL_RADIUS)
		// 	pixel = {4'd4, 4'd0, 4'd0};
		// if(h_cnt >= ball2_posx - BALL_RADIUS && h_cnt <= ball2_posx + BALL_RADIUS && v_cnt == ball2_posy + BALL_RADIUS)
		// 	pixel = {4'd4, 4'd0, 4'd0};
		// if(h_cnt >= ball2_posx - BALL_RADIUS && h_cnt <= ball2_posx + BALL_RADIUS && v_cnt == ball2_posy - BALL_RADIUS)
		// 	pixel = {4'd4, 4'd0, 4'd0};
		// if(v_cnt >= ball2_posy - BALL_RADIUS && v_cnt <= ball2_posy + BALL_RADIUS && h_cnt == ball2_posx + BALL_RADIUS)
		// 	pixel = {4'd4, 4'd0, 4'd0};
		// if(v_cnt >= ball2_posy - BALL_RADIUS && v_cnt <= ball2_posy + BALL_RADIUS && h_cnt == ball2_posx - BALL_RADIUS)
		// 	pixel = {4'd4, 4'd0, 4'd0};
		// if(h_cnt >= ball3_posx - BALL_RADIUS && h_cnt <= ball3_posx + BALL_RADIUS && v_cnt == ball3_posy + BALL_RADIUS)
		// 	pixel = {4'd4, 4'd0, 4'd0};
		// if(h_cnt >= ball3_posx - BALL_RADIUS && h_cnt <= ball3_posx + BALL_RADIUS && v_cnt == ball3_posy - BALL_RADIUS)
		// 	pixel = {4'd4, 4'd0, 4'd0};
		// if(v_cnt >= ball3_posy - BALL_RADIUS && v_cnt <= ball3_posy + BALL_RADIUS && h_cnt == ball3_posx + BALL_RADIUS)
		// 	pixel = {4'd4, 4'd0, 4'd0};
		// if(v_cnt >= ball3_posy - BALL_RADIUS && v_cnt <= ball3_posy + BALL_RADIUS && h_cnt == ball3_posx - BALL_RADIUS)
		// 	pixel = {4'd4, 4'd0, 4'd0};
		// if(h_cnt >= ball4_posx - BALL_RADIUS && h_cnt <= ball4_posx + BALL_RADIUS && v_cnt == ball4_posy + BALL_RADIUS)
		// 	pixel = {4'd4, 4'd0, 4'd0};
		// if(h_cnt >= ball4_posx - BALL_RADIUS && h_cnt <= ball4_posx + BALL_RADIUS && v_cnt == ball4_posy - BALL_RADIUS)
		// 	pixel = {4'd4, 4'd0, 4'd0};
		// if(v_cnt >= ball4_posy - BALL_RADIUS && v_cnt <= ball4_posy + BALL_RADIUS && h_cnt == ball4_posx + BALL_RADIUS)
		// 	pixel = {4'd4, 4'd0, 4'd0};
		// if(v_cnt >= ball4_posy - BALL_RADIUS && v_cnt <= ball4_posy + BALL_RADIUS && h_cnt == ball4_posx - BALL_RADIUS)
		// 	pixel = {4'd4, 4'd0, 4'd0};
		// if(h_cnt >= ball5_posx - BALL_RADIUS && h_cnt <= ball5_posx + BALL_RADIUS && v_cnt == ball5_posy + BALL_RADIUS)
		// 	pixel = {4'd4, 4'd0, 4'd0};
		// if(h_cnt >= ball5_posx - BALL_RADIUS && h_cnt <= ball5_posx + BALL_RADIUS && v_cnt == ball5_posy - BALL_RADIUS)
		// 	pixel = {4'd4, 4'd0, 4'd0};
		// if(v_cnt >= ball5_posy - BALL_RADIUS && v_cnt <= ball5_posy + BALL_RADIUS && h_cnt == ball5_posx + BALL_RADIUS)
		// 	pixel = {4'd4, 4'd0, 4'd0};
		// if(v_cnt >= ball5_posy - BALL_RADIUS && v_cnt <= ball5_posy + BALL_RADIUS && h_cnt == ball5_posx - BALL_RADIUS)
		// 	pixel = {4'd4, 4'd0, 4'd0};
		
	end
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
