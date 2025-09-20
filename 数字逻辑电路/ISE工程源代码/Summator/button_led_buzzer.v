	
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
//�޸� ֻ��1~9�İ�ť���޸�
//״̬������߼�
reg [4:0] key_out = 5'd0;//��¼ÿ����������֮������ ʮ���� 
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
						4'b1111:begin key_out <= 5'd17;end
						
					endcase
					
				end
				CHECK_R2:begin
					col <= 4'b1101;//12
					case(row)
						4'b1110:key_out <= 5'd2;  //J2
						4'b1101:key_out <= 5'd6;  //J6
						4'b1011:key_out <= 5'd10;  //J10
						4'b0111:key_out <= 5'd14; //J14
						4'b1111:begin key_out <= 5'd17;end
						
						
					endcase
				
				end
				CHECK_R3:begin
					col <= 4'b1011;//11
					case(row)
						4'b1110:key_out <= 5'd3;  //J3
						4'b1101:key_out <= 5'd7;  //J7
						4'b1011:key_out <= 5'd11; //J11
						4'b0111:key_out <= 5'd15; //J15
						4'b1111:begin key_out <= 5'd17;end
				
					endcase
				
				end
				CHECK_R4:begin
					col <= 4'b0111;//7
					case(row)
						4'b1110:key_out <= 5'd4;  //J4
						4'b1101:key_out <= 5'd8;  //J8
						4'b1011:key_out <= 5'd12; //J12
						4'b0111:key_out <= 5'd16; //J16
						4'b1111:begin key_out <= 5'd17;end
						
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
reg [4:0] key_flag = 5'd0; //��0��1��־���ζ���
always@(posedge clk)
begin
	key_out_buf <= key_out;//�����ص�ʱ�� ��������뵽key_out_buf buffer����
end
	
(*KEEP="TRUE"*)reg [19:0] cnt_900us;	
always@(posedge clk)
	if(cnt_900us == 20'd600_00)//����6000��Ϊһ������
		cnt_900us <= 20'd0;
	else if(key_out_buf != key_out)
		cnt_900us <= 20'd0;
	else if(key_out_buf == key_out)
		cnt_900us <= cnt_900us + 1'b1;//

reg [4:0] key_out_fliter;//������
//reg [4:0] key_input_new=5'd0;//���ڼ����Ƿ�����ڶ�����
reg [4:0] q1=5'd0;//��ʱ�洢��1
reg [4:0] q2=5'd0;//�洢��2
reg[4:0] qans=5'd0;	//���
reg [4:0] xiangtong=5'd0;
always@(posedge clk)
begin
	if(cnt_900us >= 20'd200_00 && key_out_buf!=5'd17)//���� ��������ж��� ����ʱ��ﵽ��20000
		begin
		key_out_fliter<= key_out_buf;//������ ������������ʱ�� ���ܽ��������еİ���ָ�����
	   end
	else
      begin	
		key_out_fliter<= key_out_fliter;
		end
	//�˲�
	//���ݴ���Ĵ���
	if(key_out_fliter>=5'd1&&key_out_fliter<=5'd12)//1~9��Χ�ڵļӼ���
	begin
		if(q1==5'd0&&key_flag==5'd0)//һ������������ֻ���һ�� �������µ����ݱ�����
		begin	
			q1=key_out_fliter;
			key_flag=5'd1;//���������Ѿ�����ȡ
		end
		else
		begin
		  q2=key_out_fliter;
		  end
	
	 if((q1!=5'd0&&q2!=5'd0 && q1!=q2)||(q1!=5'd0&&q2!=5'd0 &&xiangtong==5'd1))
		//if(q1!=5'd0&&q2!=5'd0)//�Ĵ�������Ϊ0��ʱ����мӷ�����
			begin 
			qans=q1+q2;
			end
	end
	else if(key_out_fliter==5'd14)//��Ϊ���㰴��
	begin
		qans=5'd0;
		q1=5'd0;
		q2=5'd0;
		key_flag=5'd0;//������� ���Զ�ȡ��һ������
		xiangtong=5'd0;
	end
	else if(key_out_fliter==5'd13)
	  xiangtong=5'd1;
	
end
		
(*KEEP="TRUE"*)wire error_flag;//����
assign error_flag = (key_out_buf != key_out)?1:0;//���������ݺͽ��ܵİ������ݲ���ͬ��ʱ�� ����
//======================LED================================//
//�����ʾ
assign led = {qans[4:0],3'b0};
//======================BUZZER=============================//
always@(posedge clk)
if(key_out_fliter == 5'd15)    //����J16ʱ����������//
	buzzer <= 1'b1;
else 
	buzzer <= 1'b0;

//=========================================================//
endmodule
