`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// Design Name: 
// Module Name:    button_led_buzzer 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module button_led_buzzer(
    
input            clk,//ϵͳʱ���ź�
input      [3:0] row,//4����
output     [7:0] led,//��Ӧ������LED�ƻ���
output reg [3:0] col,
output reg       buzzer
);

//================4x4����=========================//
//����4�������ĵ�ַ ���е�ַ
   localparam				CHECK_R1=3'b000;//���COL1
	localparam				CHECK_R2=3'b001;//���COL2
	localparam				CHECK_R3=3'b011;//���COL3
	localparam				CHECK_R4=3'b010;//���COL4


//1s��ʱ
reg [31:0] time_cnt =0 ;             
always@(posedge clk) 
    if(time_cnt == 32'd100000000)//1������
	time_cnt <= 32'd0;
else
	time_cnt <= time_cnt + 1'b1;

//================��Ƶ�������߼�=====================//
reg [16:0] div_cnt = 0 ;	//���ڼ�ʱ1ms
reg        cnt_full = 0 ;  //״̬ת�Ʊ�־

always@(posedge clk )      //�˴����ÿ������һ��ʱ��Ϊ1ms
if(div_cnt==17'd1000_00)//���ڼ�ʱ1ms
	begin
		div_cnt <= 16'd0;
		cnt_full <= 1'b1;//�Ѿ����һ������
	end
else 
	begin
		div_cnt <= div_cnt + 1'b1;
		cnt_full <= 1'b0;//��δ���һ������
	end
	
//״̬����ж�--���ϵ�ת������һ�鰴��
reg [2:0] state = 3'b000;
always@(posedge clk)
	begin
			case(state)
				CHECK_R1:
					if(cnt_full)//���һ������
						state <= CHECK_R2;//��ת����һ��
					else
						state <= CHECK_R1;
				CHECK_R2:
					if(cnt_full)
						state <= CHECK_R3;
					else
						state <= CHECK_R2;
				CHECK_R3:
					if(cnt_full)
						state <= CHECK_R4;
					else
						state <= CHECK_R3;
				CHECK_R4:
					if(cnt_full)
						state <= CHECK_R1;
					else
						state <= CHECK_R4;
				default:
					state <= state;
			endcase
	end

//״̬������߼�
reg [4:0] key_out = 6'd0;//��¼ÿ����������֮������ ʮ���� 
always@(posedge clk)
	begin
			case(state)//���а���״̬���� ���ڰ���λ�� ���ж��� ���ж���
				CHECK_R1:begin
					col <= 4'b1110;//14
					case(row)
						4'b1110:key_out <= 5'd1;  //J1
						4'b1101:key_out <= 5'd5;  //J5
						4'b1011:key_out <= 5'd9;  //J9
						4'b0111:key_out <= 5'd13; //J13
						4'b1111:key_out <= 5'd17; //�ް�������
					endcase
				end
				CHECK_R2:begin
					col <= 4'b1101;//12
					case(row)
					   4'b1110:key_out <= 5'd2;  //J2
						4'b1101:key_out <= 5'd6;  //J6
						4'b1011:key_out <= 5'd10; //J10
						4'b0111:key_out <= 5'd14; //J14
						4'b1111:key_out <= 5'd17; //�ް�������
					endcase
				end
				CHECK_R3:begin
					col <= 4'b1011;//11
					case(row)
						4'b1110:key_out <= 5'd3;  //J3
						4'b1101:key_out <= 5'd7;  //J7
						4'b1011:key_out <= 5'd11; //J11
						4'b0111:key_out <= 5'd15; //J15
						4'b1111:key_out <= 5'd17; //�ް�������
					endcase
				end
				CHECK_R4:begin
					col <= 4'b0111;//7
					case(row)
						4'b1110:key_out <= 5'd4;  //J4
						4'b1101:key_out <= 5'd8;  //J8
						4'b1011:key_out <= 5'd12; //J12
						4'b0111:key_out <= 5'd16; //J16
						4'b1111:key_out <= 5'd17; //�ް�������
					endcase
				end	
				default:begin
					col <= 4'b1111;//15
					key_out <= 5'd17;//
				end
			endcase
	end

//======================keyfilter==========================//�ų��źŵ�ë��	
reg [4:0] key_out_buf = 5'd0; 
always@(posedge clk)
	key_out_buf <= key_out;//�����ص�ʱ�� ��������뵽key_out_buf buffer����
	
(*KEEP="TRUE"*)reg [19:0] cnt_900us;	
always@(posedge clk)
	if(cnt_900us == 20'd600_00)//����6000��Ϊһ������
		cnt_900us <= 20'd0;
	else if(key_out_buf != key_out)
		cnt_900us <= 20'd0;
	else if(key_out_buf == key_out)
		cnt_900us <= cnt_900us + 1'b1;//

reg [4:0] key_out_fliter;
always@(posedge clk)//J16�ķ��䰴���ں����ź������Ԫʵ��
	if(cnt_900us >= 20'd200_00 && key_out_buf!=5'd17)//���� ��������ж��� ����ʱ��ﵽ��20000
		key_out_fliter <= key_out_buf;//������ ������������ʱ�� ���ܽ��������еİ���ָ�����
	else 
		key_out_fliter <= key_out_fliter;//���򱣳�֮ǰ�İ�����Ϣ
		
	
		
(*KEEP="TRUE"*)wire error_flag;//����
assign error_flag = (key_out_buf != key_out)?1:0;//���������ݺͽ��ܵİ������ݲ���ͬ��ʱ�� ����

//======================BUZZER=============================//
reg [7:0]firseq=8'b00000000;				//�������������
reg [15:0]testseq=16'b0000000000000000;//�������У���������Ļ���ʹ洢firseq
reg [3:0]times=4'd0;//������
integer i;
always@(posedge clk)
	if(key_out_fliter>=5'd1&&key_out_fliter<=5'd8)//����J1~J8 ��Ӧλ��������7~0λ
	begin
		for(i=0;i<8;i=i+1)//��ȡ��λ����
		begin
			if(i==key_out_fliter-1)//��������İ����ź�
				firseq[i]=1'b1;
		end
	end
	else if(key_out_fliter==5'd14)//J14Ϊȷ�ϰ��� ��firseq���µ�testseq������led����ʽ���
	begin
		testseq={firseq[7:0],firseq[7:0]};
	end
	else if(key_out_fliter==5'd15)//J15��Ϊ���㰴��
	begin
	   buzzer=1'b0;
      firseq=8'b00000000;
      testseq={firseq[7:0],firseq[7:0]};
		times=4'd0;
	end
	else if(key_out_fliter == 5'd16)//J16��Ϊ���䰴��   
	begin
	   if(times==4'd0)
		begin
		   testseq={8'b00000000,firseq[7:0]};//�ڿ�ʼʱ���丳ֵ�������������
		end
		buzzer=1'b0;//����������
		if(times==4'd8)//�ڰ�������н���������������
		begin
			buzzer = 1'b1;
		end
		else
		begin
			if(time_cnt == 32'd100000000)//ÿ��1s
			begin
			testseq={testseq[14:0],testseq[15]};//ÿ1s�ƶ�һλ
			times=times+1'b1;//������+1
			end
		end
	end
	else if(key_out_fliter==5'd13)//�㰴����J13 �رշ�����
	begin
		buzzer = 1'b0;
	end
//============================LED=============================//

assign led={testseq[7:0]};//led�ƣ����testseq��ǰ��λ������ʾ

endmodule