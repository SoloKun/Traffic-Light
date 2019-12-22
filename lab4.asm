 	ORG 	0000H	    ;����Ӵ˵�ַ��ʼ����
    S1  EQU 10H   //��ĵ�λ
	S2  EQU 11H   //��ĸ�λ
	FLAG EQU 16H //30s��־λ
	LJMP 	MAIN	    //��ת�� MAIN ����
 	ORG 000BH //��ʱ��0���жϵ�ַ
	PUSH ACC
	PUSH PSW
    AJMP TIME1S //��ת��30s��ʱ�ӳ���
    ORG 001BH   //��ʱ��1���жϵ�ַ
	PUSH ACC
	PUSH PSW
	AJMP TIMEY //��ת��5s��ʱ�ӳ���
	ORG 	030H	    
MAIN:
	MOV    12H,#00H  
	MOV    13H,#00H
	MOV    14H,#00H
	MOV    S1,#09H
	MOV    S2,#02H
	MOV    FLAG,#00H     //��ʼ�����б�־λ
	MOV TMOD,#00000001B //���ö�ʱ��0�����ڷ�ʽ1
	MOV TH0,#3CH 
	MOV TL0,#0B0H //Ԥ��15536����ʱ50ms
	MOV P1,#00H
	SETB EA //�����ж�����
	SETB ET0 //����ʱ/������0����
	SETB TR0 //��ʱ/������0��ʼ����	
LOOP: 
	ACALL DISPLAY //���õ���ʱ�����ӳ���
	ACALL RGB //���ý�ͨ�ƿ����ӳ���
	AJMP LOOP  
TIME1S:
     INC 12H  //��������¼20��50ms��1s
	 MOV A,12H
	 CJNE A,#20,T_RET //�ж��Ƿ���20��50ms
	 DEC S1 //ÿ��ʱ1s��λ���һ
TIME10S:
     MOV 12H,#00H //��������¼10��1s
	 INC 13H
	 MOV A,13H
	 CJNE A,#10,T_RET //�ж��Ƿ���10��1s
	 MOV S1,#09H //ÿ10s��λ�븴λ
	 DEC S2  //ÿ10s��λ���һ
TIME30S:
     MOV 13H,#00H //��������¼3��10s
	 INC 14H
	 MOV A,14H
	 CJNE A,#3,T_RET //�ж��Ƿ���3��10s
	 MOV 14H,#00H 
	 MOV S2,#02H
	 INC FLAG    
	 MOV 12H,#00H
	 MOV 13H,#00H//��λ������30s��־λ+1
	 MOV TMOD,#10H
     MOV TH1,#3CH 
	 MOV TL1,#0B0H
     SETB EA
     SETB ET1
     SETB TR1 
	 CLR ET0
	 CLR TR0 
	 MOV S1,#05H
	 MOV S2,#00H //�رռ�ʱ��0������ʱ��1������λ����0��λ������Ϊ5
T_RET:
	MOV TH0,#3CH
	MOV TL0,#0B0H //���ö�ʱ����
	POP PSW
	POP ACC
	RETI			//���¿�ʼ��ʱ
TIMEY:
     INC 12H
	 MOV A,12H
	 CJNE A,#20,TY_RET
	 DEC S1			   //��ʱ��1 ����5s��ʱ
TIMEY5S:
    MOV 12H,#00H
	INC 13H
	MOV A,13H
	CJNE A,#6,TY_RET
	INC FLAG
	MOV TMOD,#00000001B //��ʱ��1�����ڷ�ʽ1
	MOV TH0,#3CH 
	MOV TL0,#0B0H //Ԥ��15536����ʱ50ms
	SETB EA //�����ж�����
	SETB ET0 //����ʱ/������0����
	SETB TR0 //��ʱ/������0��ʼ����
	CLR ET1
	CLR TR1
	MOV TH0,#3CH 
	MOV TL0,#0B0H
	MOV    S1,#09H
	MOV    S2,#02H
	MOV    12H,#00H
	MOV     13H,#00H   //�رռ�ʱ��1������ʱ��2����ѭ����һ������
TY_RET:
	MOV TH1,#3CH
	MOV TL1,#0B0H ;���ö�ʱ����
	POP PSW
	POP ACC
	RETI
DISPLAY:
	MOV DPTR,#TAB
	MOV P1,#07FH
	MOV A,S1
	MOVC A,@A+DPTR
	MOV P0,A
	MOV P0,#00H
	MOV P1,#0BFH
	MOV	 A,S2
	MOVC A,@A+DPTR
	MOV P0,A
	MOV P0,#00H
	MOV P1,#0F7H
	MOV A,S1
	MOVC A,@A+DPTR
	MOV P0,A
	MOV P0,#00H
	MOV P1,#0FBH
	MOV A,S2
	MOVC A,@A+DPTR
	MOV P0,A
	MOV P0,#00H   	//����ʱ�ӳ����������ʾ
	RET
RGB:
	MOV A,FLAG
	MOV DPTR,#RGBTAB
	MOVC A,@A+DPTR
	MOV P2,A
	MOV A,FLAG
	MOV DPTR,#YTAB
	MOVC A,@A+DPTR
	MOV P3,A
	MOV A,FLAG			//
	CJNE A,#04H,RESET  //�ĸ�״̬һ��ѭ��
	CLR ET1
	CLR TR1
	CLR TR0
	CLR ET0
	CLR EA				  //�رն�ʱ��0��1�ص�������ʼ��һ��ѭ��
	LJMP MAIN
RESET:
	RET
ORG	400H
;�߶������Թ���ʾ���ֱ���(��Ӧ0~F)
TAB: DB 3Fh,06h,5Bh,4Fh,66h,6Dh,7Dh,07h,7Fh,6Fh,77h,7Ch,39h,5Eh,79h,71h 		;�������߶������Թ�
RGBTAB: DB 	7AH,0B6H,0CDH,0B6H	   
YTAB: DB 01H,02H,02H,02H		   //��ͨ�Ƶ�����״̬
END
