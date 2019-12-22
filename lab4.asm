 	ORG 	0000H	    ;程序从此地址开始运行
    S1  EQU 10H   //秒的低位
	S2  EQU 11H   //秒的高位
	FLAG EQU 16H //30s标志位
	LJMP 	MAIN	    //跳转到 MAIN 程序处
 	ORG 000BH //定时器0的中断地址
	PUSH ACC
	PUSH PSW
    AJMP TIME1S //跳转到30s计时子程序
    ORG 001BH   //定时器1的中断地址
	PUSH ACC
	PUSH PSW
	AJMP TIMEY //跳转到5s计时子程序
	ORG 	030H	    
MAIN:
	MOV    12H,#00H  
	MOV    13H,#00H
	MOV    14H,#00H
	MOV    S1,#09H
	MOV    S2,#02H
	MOV    FLAG,#00H     //初始化所有标志位
	MOV TMOD,#00000001B //设置定时器0工作于方式1
	MOV TH0,#3CH 
	MOV TL0,#0B0H //预置15536，计时50ms
	MOV P1,#00H
	SETB EA //开总中断允许
	SETB ET0 //开定时/计数器0允许
	SETB TR0 //定时/计数器0开始运行	
LOOP: 
	ACALL DISPLAY //调用倒计时控制子程序
	ACALL RGB //调用交通灯控制子程序
	AJMP LOOP  
TIME1S:
     INC 12H  //计数，记录20个50ms即1s
	 MOV A,12H
	 CJNE A,#20,T_RET //判断是否有20个50ms
	 DEC S1 //每计时1s低位秒减一
TIME10S:
     MOV 12H,#00H //计数，记录10个1s
	 INC 13H
	 MOV A,13H
	 CJNE A,#10,T_RET //判断是否有10个1s
	 MOV S1,#09H //每10s低位秒复位
	 DEC S2  //每10s高位秒减一
TIME30S:
     MOV 13H,#00H //计数，记录3个10s
	 INC 14H
	 MOV A,14H
	 CJNE A,#3,T_RET //判断是否有3个10s
	 MOV 14H,#00H 
	 MOV S2,#02H
	 INC FLAG    
	 MOV 12H,#00H
	 MOV 13H,#00H//复位，设置30s标志位+1
	 MOV TMOD,#10H
     MOV TH1,#3CH 
	 MOV TL1,#0B0H
     SETB EA
     SETB ET1
     SETB TR1 
	 CLR ET0
	 CLR TR0 
	 MOV S1,#05H
	 MOV S2,#00H //关闭计时器0开启计时器1，将高位秒置0低位秒设置为5
T_RET:
	MOV TH0,#3CH
	MOV TL0,#0B0H //重置定时常数
	POP PSW
	POP ACC
	RETI			//重新开始定时
TIMEY:
     INC 12H
	 MOV A,12H
	 CJNE A,#20,TY_RET
	 DEC S1			   //计时器1 处理5s计时
TIMEY5S:
    MOV 12H,#00H
	INC 13H
	MOV A,13H
	CJNE A,#6,TY_RET
	INC FLAG
	MOV TMOD,#00000001B //定时器1工作于方式1
	MOV TH0,#3CH 
	MOV TL0,#0B0H //预置15536，计时50ms
	SETB EA //开总中断允许
	SETB ET0 //开定时/计数器0允许
	SETB TR0 //定时/计数器0开始运行
	CLR ET1
	CLR TR1
	MOV TH0,#3CH 
	MOV TL0,#0B0H
	MOV    S1,#09H
	MOV    S2,#02H
	MOV    12H,#00H
	MOV     13H,#00H   //关闭计时器1开启计时器2重新循环下一步操作
TY_RET:
	MOV TH1,#3CH
	MOV TL1,#0B0H ;重置定时常数
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
	MOV P0,#00H   	//倒计时子程序，数码管显示
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
	CJNE A,#04H,RESET  //四个状态一个循环
	CLR ET1
	CLR TR1
	CLR TR0
	CLR ET0
	CLR EA				  //关闭定时器0、1回到主程序开始下一轮循环
	LJMP MAIN
RESET:
	RET
ORG	400H
;七段数码显管显示数字编码(对应0~F)
TAB: DB 3Fh,06h,5Bh,4Fh,66h,6Dh,7Dh,07h,7Fh,6Fh,77h,7Ch,39h,5Eh,79h,71h 		;共阴极七段数码显管
RGBTAB: DB 	7AH,0B6H,0CDH,0B6H	   
YTAB: DB 01H,02H,02H,02H		   //交通灯的四种状态
END
