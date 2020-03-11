module vga1206(clk, reset, enable, iSW, oVGA_CLOCK, oVGA_R, oVGA_G, oVGA_B, oVGA_HS, oVGA_VS, oVGA_SYNC_N, oVGA_BLANK_N,disp1,disp2,disp3,disp4,disp5,disp6,disp7,ps2_clk,ps2_data);
   input clk, reset, enable;//top module
   input [3:0] iSW;//monitor line select R G B P(2015253039 권진우)
   wire clk25;
   wire vga_clk;
   wire [9:0] vga_r, vga_g, vga_b;
   wire [9:0] vga_a;
   wire hsync, vsync, vga_sync, vga_blank;
   
   //ps2 port
   input ps2_clk,ps2_data;
   reg [7:0] data;
   reg [7:0]data_curr;
   reg [7:0]data_pre;
   reg ps2c,ps2d;
   reg [7:0]ps2c_reg;
   wire falling_edge;
   reg [2:0]state;  
   reg clk_filter,clk_filter_prev;
   reg flag;
   reg [3:0]counter;
   
   //ps2 port
   
   output reg oVGA_CLOCK;
   output reg [7:0] oVGA_R, oVGA_G, oVGA_B;
   output reg oVGA_HS, oVGA_VS;
   output reg oVGA_SYNC_N;
   output reg oVGA_BLANK_N;
   wire [9:0] in_r, in_g, in_b;//1,2,3번재 line(2015253039 권진우)
   wire [9:0] in_a;//4번째 line(2015253039 권진우)
   wire tc;//tc -> line 블럭 내려오는데 clk으로 사용(2015253039 권진우)
   //input [3:0] key;//input button R G B Pink
   wire[10:0] y1, y2, y3, y4;//(2015253039 권진우)
   wire[10:0] y11, y22, y33, y44;//y1 == y11, y2== y22, ...(2015253039 권진우)
   wire aa, bb, cc, dd;//점수 합산을 위해 변수 분할(2015253039 권진우)
   wire aa1, bb1, cc1, dd1;//점수 합산을 위해 변수 분할(2015253039 권진우)
   output [6:0]disp1,disp2,disp3,disp4;   //7-segment display output
   output reg [6:0] disp5,disp6,disp7;//점수 표시 
   reg [3:0] a,b,c;//
   wire [15:0] score;//16bit line별 4 bit
   wire [3:0] scorereg1, scorereg2, scorereg3, scorereg4;//line별 score(2015253039 권진우)
   
   sec_gen u3 (clk, tc);
   clockgen25 u1 (clk, clk25); //1/2 -> 25Mhz clock generating
   vga_sync u2 (flag, aa1, bb1, cc1, dd1, aa, bb, cc, dd, y1, y2, y3, y4,y11, y22, y33, y44, data, clk25, reset, tc, iSW, in_r, in_g, in_b, in_a, px, py1, py2, py3, py4, vga_r, vga_g, vga_b, vga_a, hsync, vsync, vga_sync, vga_blank, vga_clk);//rgb
   //input : clk25, rst, in_r, 
   wire [9:0] total_score;
   check u4 (y1,y2,y3,y4,score);  //버튼누른 좌표의 위치값 check하는 모듈 
   //input : clk25, rst, in_r,
   score u5 (score,disp1,disp2,disp3,disp4,total_score);   // 좌표값에 따라 display에 기호를 표시하는 모듈 
   real_total u6 (aa1, bb1, cc1, dd1, aa, bb, cc, dd, y1, y2, y3, y4,y11, y22, y33, y44, real_total_score);  //종합점수를 7-segment display에 출력 
   wire [9:0] real_total_score;
   reg [1:0] flags;
   
   // state machine
  always @(negedge ps2_clk)  //ps2 clock에따라 
   begin
   case (counter)
      0:      begin data_curr = 0; end          //키보드에서 전송된 데이터를 저장 
      1:    begin data_curr[0] = ps2_data;  end
      2:    data_curr[1] = ps2_data;   
      3:    data_curr[2] = ps2_data;   
      4:    data_curr[3] = ps2_data;
      5:    data_curr[4] = ps2_data;
      6:    data_curr[5] = ps2_data;
      7:    data_curr[6] = ps2_data;
      8:    data_curr[7] = ps2_data;     
      9:    if(flags == 0) begin data = data_curr; flag = 1'b1; flags = 3; end  //make code만 전송하고 break code는 전송안함
      10:   begin flag <= 0; flags = flags - 1; end//flag를 negedge로 1->0 : negedge flag일 때, 각 line으로  입력 신호가 들어감
   endcase

   if (counter <= 9) begin
      counter <= counter + 1;
   end
   else 
      counter <= 0;
end

   always@(real_total_score) begin   //종합점수 출력 
      a<=real_total_score/100;
         case(a)
            0:disp7=7'b0000001;
            1:disp7=7'b1001111;
            2:disp7=7'b0010010;
            3:disp7=7'b0000110;
            4:disp7=7'b1001100;
            5:disp7=7'b0100100;
            6:disp7=7'b0100000;
            7:disp7=7'b0001111;
            8:disp7=7'b0000000;
            9:disp7=7'b0000100;
            default: disp7=7'b0000001;
         endcase
      end
      always@(real_total_score) begin
      b<=(real_total_score/10)%10;
         case(b)
            0:disp6=7'b0000001;
            1:disp6=7'b1001111;
            2:disp6=7'b0010010;
            3:disp6=7'b0000110;
            4:disp6=7'b1001100;
            5:disp6=7'b0100100;
            6:disp6=7'b0100000;
            7:disp6=7'b0001111;
            8:disp6=7'b0000000;
            9:disp6=7'b0000100;
            default: disp6=7'b0000001;
         endcase
      end
      always@(real_total_score) begin
      c<=(real_total_score%10);
         case(c)
            0:disp5=7'b0000001;
            1:disp5=7'b1001111;
            2:disp5=7'b0010010;
            3:disp5=7'b0000110;
            4:disp5=7'b1001100;
            5:disp5=7'b0100100;
            6:disp5=7'b0100000;
            7:disp5=7'b0001111;
            8:disp5=7'b0000000;
            9:disp5=7'b0000100;
            default: disp5=7'b0000001;
         endcase
      end
   always @* begin//(2015253039 권진우) -> display를 위한 조합회로 
      oVGA_CLOCK = vga_clk;
      {oVGA_R[7], oVGA_G[7], oVGA_B[7]} = {vga_r[7], vga_g[7], vga_b[7]};//색깔 출력 -> RGBP에 겹치는 bit가 있으면 동시에 출력이 안되므로
      {oVGA_R[6:0], oVGA_B[6:0]} = {vga_a[6:0],vga_a[6:0]};//color mix and select /   색깔마다 bit가 겹치지 않도록 [7] , {[6:0],[6:0]}
      {oVGA_HS, oVGA_VS} = {hsync, vsync};
      oVGA_SYNC_N = vga_sync;
      oVGA_BLANK_N = vga_blank;
   end
   assign {sw_r, sw_g, sw_b, sw_a} = iSW[3:0];//each switch R,G,B on fpga board (2015253039 권진우)
   assign in_r = (sw_r) ? 10'h3ff : 10'h0;//if switch on -> display Red//색깔 정해주기//(2015253039 권진우)
   assign in_g = (sw_g) ? 10'h3ff : 10'h0;//if switch on -> display Green(2015253039 권진우)
   assign in_b = (sw_b) ? 10'h3ff : 10'h0;//if switch on -> display Blue(2015253039 권진우)
   assign in_a = (sw_a) ? 10'h3ff : 10'h0;// pink = blue + red(2015253039 권진우)
endmodule

module real_total(aa1, bb1, cc1, dd1, aa, bb, cc, dd, y1, y2, y3, y4,y11, y22, y33, y44, real_total_score);//(2015253039 권진우)
   input [10:0] y1, y2, y3, y4, y11, y22, y33, y44;//y1 == y11, y2 == y22 (y is 좌표 )(2015253039 권진우)
   input aa,bb,cc,dd;//반전 비트 누를때마다 (2015253039 권진우)
   input aa1, bb1, cc1, dd1;//aa, aa1은 서로 같으나 always문 hierarchy문제를 해결하기 위해 variable 분할(2015253039 권진우) 
   output reg [9:0] real_total_score;
   reg [3:0] sc1, sc2, sc3, sc4 ,sc5, sc6, sc7, sc8;//각 line별 toggle별 score(2015253039 권진우)
   reg [9:0] sc_sum1, sc_sum2, sc_sum3, sc_sum4, sc_sum5, sc_sum6, sc_sum7, sc_sum8;//line 별 합산 score
      always@(posedge aa) begin//always문을 each Line 별로 나눠서 each line별 점수를 더해줌 (2015253039 권진우)
         if(y1>=430&&y1<=450) sc1=10; //good
         else if(y1>=410&&y1<=470) sc1=5; // soso
         else sc1 = 0; // bad
         sc_sum1 = sc_sum1 + sc1;
      end
      always@(posedge bb) begin//posedge 에서 더하기 
         if(y2>=430&&y2<=450) sc2=10; //good
         else if(y2>=410&&y2<=470) sc2=5; // soso
         else sc2 = 0; // bad
         sc_sum2 = sc_sum2+ sc2;
      end
      always@(posedge cc) begin//각 line별로 posedge, negedge마다 4 x 2 = 8 always 문 사용 (2015253039 권진우)
         if(y3>=430&&y3<=450) sc3=10; //good
         else if(y3>=410&&y3<=470) sc3=5; // soso
         else sc3 = 0; // bad
         sc_sum3 = sc_sum3 + sc3;
      end
      always@(posedge dd) begin
         if(y4>=430&&y4<=450) sc4=10; //good
         else if(y4>=410&&y4<=470) sc4=5; // soso
         else sc4 = 0; // bad
         sc_sum4 = sc_sum4 + sc4;
      end
      always@(negedge aa1) begin//always문을 each Line 별로 나눠서 each line별 점수를 더해줌 (2015253039 권진우)
         if(y11>=430&&y11<=450) sc5=10; //good
         else if(y11>=410&&y11<=470) sc5=5; // soso
         else sc5 = 0; // bad
         sc_sum5 = sc_sum5 + sc5;
      end
      always@(negedge bb1) begin//negedge 에서 더하기 
         if(y22>=430&&y22<=450) sc6=10; //good
         else if(y22>=410&&y22<=470) sc6=5; // soso
         else sc6 = 0; // bad
         sc_sum6 = sc_sum6+ sc6;
      end
      always@(negedge cc1) begin
         if(y33>=430&&y33<=450) sc7=10; //good
         else if(y33>=410&&y33<=470) sc7=5; // soso
         else sc7 = 0; // bad
         sc_sum7 = sc_sum7 + sc7;
      end
      always@(negedge dd1) begin
         if(y44>=430&&y44<=450) sc8=10; //good
         else if(y44>=410&&y44<=470) sc8=5; // soso
         else sc8 = 0; // bad
         sc_sum8 = sc_sum8 + sc8;
      end
      //aa,bb(button 클릭 시 마다(반전) 속도 변화)(posedge 마다) 쌍은 y1, y2 , aa1, aa2쌍은 y1, y2//(2015253039 권진우)
      always@(posedge aa or posedge bb or posedge cc or posedge dd or negedge aa1 or negedge bb1 or negedge cc1 or negedge dd1) begin//버튼을 누를 때 마다 a,b,c,d 반전을 통해서 속도를 변환하는데
         real_total_score = sc_sum1 + sc_sum2 + sc_sum3 + sc_sum4 + sc_sum5 + sc_sum6 + sc_sum7 + sc_sum8;//버튼을 누를 때 마다 변하는 값을 그대로 wire로 받아와서 posedge,negedge마다 점수를 update
      end//최종 display할 score == real_total_score(2015253039 권진우)
endmodule
//---------------------------------------------

module score(score,disp1,disp2,disp3,disp4, total_score);  //좌표값에 따라 점수계산 
   input[15:0] score;
   reg [3:0]scorereg1, scorereg2, scorereg3, scorereg4;
   output reg [6:0]disp1,disp2,disp3,disp4;
   //output reg[5:0]total_score;
   //output reg disp1_1,disp1_2,disp1_3,disp1_4,disp2_1,disp2_2,disp2_3,disp2_4,disp3_1,disp3_2,disp3_3,disp3_4,disp4_1,disp4_2,disp4_3,disp4_4;
   output reg [9:0] total_score;
   
   always@(score[15:12]) begin
      if(score[15:12] == 4'b1010 || score[15:12] == 4'b0101 || score[15:12] == 4'b0001)begin
            scorereg1 = score[15:12];
            //total_score=scorereg1;
         end
      case(scorereg1)
         10: begin disp4=7'b000_0001;  end //정확하게 눌렀을때 10점,O표시 
         5: begin disp4=7'b110_0010; end   //조금 정확할때 5점, o표시 
         0: begin disp4=7'b100_1000; end   //못맞췄을때 1점,x표시 
         default: disp4=111_1111;
      endcase
   end
   
   always@(score[11:8]) begin
      if(score[11:8] == 4'b1010 || score[11:8] == 4'b0101 || score[11:8] == 4'b0000)begin
            scorereg2 = score[11:8];
            //total_score=scorereg2;
         end
      case(scorereg2)
         10: disp3=7'b000_0001;
         5: disp3=7'b110_0010;
         0: disp3=7'b100_1000;
         default: disp3=111_1111;
      endcase
   end
   
   always@(score[7:4]) begin
      if(score[7:4] == 4'b1010 || score[7:4] == 4'b0101 || score[7:4] == 4'b0000)begin
            scorereg3 = score[7:4];
            //total_score=scorereg3;
         end
      case(scorereg3)
         10: disp2=7'b000_0001;
         5: disp2=7'b110_0010;
         0: disp2=7'b100_1000;
         default: disp2=111_1111;
      endcase
   end
   
   always@(score[3:0]) begin
      if(score[3:0] == 4'b1010 || score[3:0] == 4'b0101 || score[3:0] == 4'b0000)begin
            scorereg4 = score[3:0];
            //total_score=scorereg4;
         end
      case(scorereg4)
         10: disp1=7'b000_0001;
         5: disp1=7'b110_0010;
         0: disp1=7'b100_1000;
         default: disp1=111_1111;
      endcase
   end
   
endmodule
      
      
module check(Y1,Y2,Y3,Y4,score);   //버튼 누른 좌표 체크 
   input [9:0] Y1,Y2,Y3,Y4;
   reg [10:0] p1, p2, p3, p4;
   output reg [15:0] score;
   
   always @(Y1)begin
   score[15:12] = 1;
      p1=Y1;// p1 <- Y1
      if(p1>=430&&p1<=450) score[15:12]=10; //good
      else if(p1>=410&&p1<=470) score[15:12]=5; // soso
      else score[15:12] = 0; // bad
      p1 = 0;//p1 initializing
      
   end
   always @(Y2)begin
      score[11:8] = 1;
      p2=Y2;// 
      if(p2>=430&&p2<=450) score[11:8]=10; //good
      else if(p2>=410&&p2<=470) score[11:8]=5; // soso
      else score[11:8] = 0; // bad
      p2 = 0;//p2 initializing
   end
   
   always @(Y3)begin
   score[7:4] = 1;
      p3=Y3;//  <- Y1
      if(p3>=430&&p3<=450) score[7:4]=10; //good
      else if(p3>=410&&p3<=470) score[7:4]=5; // soso
      else score[7:4] = 0; // bad
      p3 = 0;//p3 initializing
   end
   always @(Y4)begin
   score[3:0] = 1;
      p4=Y4;// p1 <- Y1
      if(p4>=430&&p4<=450) score[3:0]=10; //good
      else if(p4>=410&&p4<=470) score[3:0]=5; // soso
      else score[3:0] = 0; // bad
      p4 = 0;//p4 initializing
   end
endmodule


module clockgen25(clk, clk25);//1/2 clock generating module(2015253039 권진우)
   input clk;
   output reg clk25;
   
   always @(posedge clk) begin
      clk25 <= ~clk25;
   end
endmodule

module sec_gen(clk, tc);//tc counter(블럭의 적당한 down 속도를 generating 하기 위해)(2015253039 권진우)
   input clk;
   output reg tc;
   reg [25:0] qout1;//64Mhz = 2^26
   
   always @(posedge clk) begin
      tc = 0;
      if(qout1 == 159_9999) begin qout1 <= 26'b0; tc <= 1; end
      else qout1 <= qout1 + 1;//counter
   end
endmodule

module vga_sync(flag, aa1, bb1, cc1, dd1, aa, bb, cc, dd, y1, y2, y3, y4,y11, y22, y33, y44, data, clk25, reset, tc, iSW, in_r, in_g, in_b, in_a, px, py1, py2, py3, py4, vga_r, vga_g, vga_b, vga_a, hsync, vsync, vga_sync, vga_blank, vga_clk);//(2015253039 권진우)
   input clk25, reset;//controller, 분주된 clk 받기 (2015253039 권진우)
   input [9:0] in_r, in_g, in_b;//rgb input(switch)(2015253039 권진우)
   input [9:0] in_a;//rgb input(switch)(2015253039 권진우)
   input [3:0] iSW;//line display switch
   output reg [9:0] px, py1, py2, py3, py4;//x row / y column(2015253039 권진우)
   output [7:0] vga_r, vga_g, vga_b;//output display VGA(2015253039 권진우)
   output [7:0] vga_a;//output display VGA
   output reg hsync, vsync;//sync
   output vga_sync, vga_blank;
   output vga_clk;
   reg [8:0] Rblackboxupper1, Rblackboxupper2, Rblackboxupper3, Rblackboxupper4;//떨어지는 막대의 위쪽 모서리(2015253039 권진우)
   input tc;//Every posedge tc -> block go down(2015253039 권진우) 
   output reg aa, bb, cc, dd, dd1, aa1, bb1, cc1;// flag 역할 
   input [7:0]data;//keyboard로 부터 받은 data(ASCII code, make code part) -> keyboard 누르는 순간 입력으로 바로 들어옴(2015253039 권진우)
   output reg [10:0] y1, y2, y3, y4, y11, y22, y33, y44;//y1 == y11 (변수 분산 해서 점수 합산에 활용 )(2015253039 권진우)
   input flag;//key board flag(keyboard data 8bit 모두 받고난 뒤 다음 state에서 flag가 1->0이되며 negedge에서 line별 Y 좌표 보내기)(2015253039 권진우)
   
   
   reg video_on;//display on / off
   reg[9:0] hcount, vcount;//horizontal/vertical
   
   always @(posedge clk25 or posedge reset) begin//(2015253039 권진우)
      if(reset) hcount<=0;//horizontal(640)
      else begin
         if(hcount==799) hcount <= 0;//mod800
         else hcount <= hcount + 1;
      end
   end
   
   always @(posedge clk25) begin//(2015253039 권진우)
      if((hcount >= 659) && (hcount <= 755))//sync pulse is 96 clk(active low)
         hsync <= 0;//hsync pulse is active low
      else hsync <= 1;
   end
   
   always@(posedge clk25 or posedge reset) begin//vcount(480) is +1 when hcount==799(2015253039 권진우)
      if(reset) vcount <= 0;//(480)
      else if(hcount==799) begin
         if(vcount == 524) vcount <= 0;//mod 525
         else vcount <= vcount + 1;
      end
   end
   
   always@(posedge clk25) begin//vsync pulse is 2 clk(active low)(2015253039 권진우)
      if((vcount >= 493) && (vcount <= 494)) vsync <=0;
      else vsync <= 1;
   end
   
   always@(posedge clk25) begin
      video_on <= (hcount <= 639) && (vcount <= 479);//0~639 and 0~479 display on show(box)(2015253039 권진우)
      px <= hcount;//x and y below hcount and vcount
      py1 <= vcount;
      py2 <= vcount;
      py3 <= vcount;
      py4 <= vcount;//Y Line partitionint by 4 way
   end
   
   always@(negedge flag) begin//flag(go down speed) switching when button click(2015253039 권진우)
      if(data == 8'h15) begin//data 입력을 받아서 check (2015253044 전준형)
      aa <= ~aa;//변수 toggle 을 통한 다양한 활용
      aa1 <= ~aa1;
      y1 <= Rblackboxupper1;//y1 : Red output(2015253039 권진우)
      y11 <= Rblackboxupper1;//입력 순간의 y축 좌표 값을 받음(2015253039 권진우)
      end
   end
   always@(negedge flag) begin
      if(data == 8'h1D) begin//data 입력을 받아서 check (2015253044 전준형)
      bb <= ~bb;
      bb1 <= ~bb1;
      y2 <= Rblackboxupper2;//y2 : Green output(2015253039 권진우)
      y22 <= Rblackboxupper2;//입력 순간의 y축 좌표 값을 받음(2015253039 권진우)
      end
   end
   always@(negedge flag)begin
      if(data == 8'h24) begin//data 입력을 받아서 check (2015253044 전준형)
      cc <= ~cc;
      cc1 <= ~cc1;
      y3 <= Rblackboxupper3;//y3 : Blue output(2015253039 권진우)
      y33 <= Rblackboxupper3;//입력 순간의 y축 좌표 값을 받음(2015253039 권진우)
      end
   end
   always@(negedge flag) begin//y4 : Pink output(2015253039 권진우)
      if(data == 8'h2D) begin//data 입력을 받아서 check (2015253044 전준형)
      dd <= ~dd;
      dd1 <= ~dd1;
      y4 <= Rblackboxupper4;//y4 : Red output(2015253039 권진우)
      y44 <= Rblackboxupper4;//입력 순간의 y축 좌표 값을 받음(2015253039 권진우)
      end
   end
   always@(posedge tc) begin//clk25를 활용하면 무늬만들기도 가능, line 별 입력 시 마다 aa,bb,cc,dd를 toggle하므로 line별로 속도 변화 (2015253039 권진우)
         if(aa)//flag(2015253039 권진우)
            Rblackboxupper1 <= Rblackboxupper1 + 2;// +n is go down speed
         else
            Rblackboxupper1 <= Rblackboxupper1 + 5;
            
         if(bb)
            Rblackboxupper2 <= Rblackboxupper2 + 3;// +n is go down speed
         else
            Rblackboxupper2 <= Rblackboxupper2 + 6;
            
         if(cc)
            Rblackboxupper3 <= Rblackboxupper3 + 4;// +n is go down speed
         else
            Rblackboxupper3 <= Rblackboxupper3 + 2;
            
         if(dd)
            Rblackboxupper4 <= Rblackboxupper4 + 3;// +n is go down speed
         else
            Rblackboxupper4 <= Rblackboxupper4 + 5;
   end
   
   assign vga_clk = ~clk25;//vga clk is active(sampling) in middle of clk25 <- stable withdraw(2015253039 권진우)
   assign vga_blank = hsync & vsync;// both sync 0 -> display blank(2015253039 권진우)
   assign vga_sync = 1'b0;//sync = 0;
   assign vga_r = (px < 155 && (Rblackboxupper1+40 < py1 || py1 <Rblackboxupper1) && py1 < 440 || py1 > 479) ? in_r : 10'h000;//(10bit -> 0~1023)(16)
   assign vga_g = (165 <= px && px<315 && (Rblackboxupper2+40 < py2 || py2 <Rblackboxupper2) && py2 < 440 || py2 > 479) ? in_g : 10'h000;//video_on : 1 -> display on
   assign vga_b = (325 <= px && px<475 && (Rblackboxupper3+40 < py3 || py3 <Rblackboxupper3) && py3 < 440 || py3 > 479) ? in_b : 10'h000;//video_on : 0 -> display off(black)
   assign vga_a = (485 <= px && px<635 && (Rblackboxupper4+40 < py4 || py4 <Rblackboxupper4) && py4 < 440 || py4 > 479) ? in_a : 10'h000;//(2015253039 권진우)
endmodule