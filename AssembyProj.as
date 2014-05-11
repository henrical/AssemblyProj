;-------------------------------------------------------------------------------
;----------------------------------CONSTANTES-----------------------------------
;-------------------------------------------------------------------------------
SP_INICIAL		EQU		FDFFh

DISP1			EQU	FFF0h
DISP2			EQU	FFF1h
DISP3			EQU	FFF2h
DISP4			EQU	FFF3h 

LCD_POSICAO		EQU 	FFF4h
LCD_WRITE		EQU		FFF5h

COUNT_TIMER		EQU		FFF6h ; tempo
CONTROLO_TIMER	EQU		FFF7h ;estado do temporizador, 1=on ,0=off

LEDS			EQU		FFF8h

IO_WRITE 		EQU  	FFFEh
IO_POS			EQU		FFFCh ;posicionamento do prox. caracter
IO_STATUS		EQU  	FFFDh ;verifica se houve uma tecla premida (0/1)
IO_READ			EQU 	FFFFh ;recebe caracter escrito	

MASK_ADDR		EQU 	FFFAh ;mascara de interrupçoes
INT_MASK        EQU     1000100000000011b


VELOCIDADE_OBS1	EQU		5 ;velocidade inicial dos obstaculos: 1	metro por cada 1/2 segundos
VELOCIDADE_OBS2	EQU		4 ;1/2,5=0,4
VELOCIDADE_OBS3	EQU		3 ;

NCOLS			EQU		22; 26 menos as paredes	
NLINS			EQU		24;linhas utilizadas

INCLIN			EQU		0100h ; Valor utilizado para somar/subtrair linhas

MAXBITS			EQU		FF00h ;bits de maior peso	
MINBITS			EQU		00FFh ;bits de maior peso

FIM_STR			EQU		'@'

RAND_MASK		EQU	1000000000010110b ;1000 0000 0001 0110b

COL_POS1		EQU		001Dh ;-------1D se estiver muito a direita
COL_POS2		EQU		0037h ;-------37 se estiver muito a direita

POS_MSG_INIT1	EQU     0C16h ;---- linha 12 col 22
POS_MSG_INIT2	EQU 	0E16h ;---- linha 14 col 22

;
;-------------------------------------------------------------------------------
;----------------------------------VARIAVEIS------------------------------------
;-------------------------------------------------------------------------------
				ORIG 	8000h
CICLOS			WORD	0	; valor usado para gerar numeros aleatorios, num de ciclos de jogo executados
RANDNUM			WORD	0	; ultimo valor aleatorio gerado	

OBSTACULO		STR		'*'

FLAG_ESQUERDA	WORD	0	; Flag de direccao do movimento da bicicleta(1 ou 2)
FLAG_DIREITA	WORD	0

MAPCHAR1		STR  	'+'
MAPCHAR2		STR 	'|'
RODA_BIKE		STR		'O'
CORPO_BIKE		STR		'|'

MSG_INICIO1		STR		'Bem-vindo à corrida de bicicleta!@'
MSG_INICIO2		STR		'Prima o interruptor I1 para comecar@'
MSG_FIM1		STR		'Fim do Jogo@'
MSG_FIM2		STR		'Prima o interruptor I1 para recomecar@'

POS_BIKE1		WORD 	172Ah ;---posiçao inicial da roda de tras


BIKEMD			STR		'O|O'

SPACE			STR  	' '

OBS_POS1 		WORD 	0
OBS_POS2		WORD 	0
OBS_POS3		WORD 	0
OBS_POS4		WORD	0

JOGO_REINICIALIZADO  WORD 	0 ; diz se o jogo ja foi re-inicializado


;'Distancia:00000m' em código ASCII
D			WORD	0044h
i0			WORD	0069h
s			WORD	0073h
t			WORD	0074h
a			WORD	0061h
n0			WORD	006Eh
c0			WORD	0063h
i1			WORD	0069h
a1			WORD	0061h
dps			WORD	003Ah
z1			WORD	0030h
z2			WORD	0030h
z3			WORD	0030h
z4			WORD	0030h
z5			WORD	0030h
m0			WORD	006Dh

;'Maximo:00000m' em código ASCII
caracterM		WORD	004Dh
caractera			WORD	0061h
x			WORD	0078h
i2			WORD	0069h
m1			WORD	006Dh
o0			WORD	006Fh
dps2			WORD	003Ah
z6			WORD	0030h
z7			WORD	0030h
z8			WORD	0030h
z9			WORD	0030h
z10			WORD	0030h
m2			WORD	006Dh


VALORLEDS 		WORD  	0

VELOCIDADE_JOGO WORD 	0

Distancia1 	 	WORD 	0030h
Distancia2		WORD	0030h
Distancia3		WORD	0030h
Distancia4		WORD	0030h
Distancia5		WORD	0030h
Aux 			WORD  	0
ObstaculosUltrapassados 	WORD 	0		
;------------------------------------FLAGS--------------------------------------
JOGOINICIADO	WORD	0	;  ---Flag de inicio de jogo
Flag_Timer		WORD	0	;  ---Flag do timer

Flag_Obs1 		WORD 	0
Flag_Obs2 		WORD 	0
Flag_Obs3 		WORD 	0
Flag_Obs4 		WORD 	0

Flag_FimdeJogo WORD 	0


;-------------------------------------------------------------------------------
;----------------------------VECTOR DE INTERRUPCOES-----------------------------
;-------------------------------------------------------------------------------

		ORIG	FE00h
INT0		WORD	IMoveEsq
INT1		WORD	IComecar
		ORIG	FE0Bh	
INTB		WORD	IMoveDir
		ORIG	FE0Fh
INT15		WORD	Temporizador;

;-------------------------------------------------------------------------------
;----------------------------ROTINAS DE INTERRUPCAO-----------------------------
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
;			IComeçar
;EFEITO:
; ---Activar a flag de (re)inicio de jogo
;-------------------------------------------------------------------------------
IComecar:	PUSH 	R1
			CMP 	M[JOGOINICIADO],R0
			BR.NZ	RtInt
			MOV 	R1,1
			MOV 	M[JOGOINICIADO],R1
			POP 	R1
RtInt:		RTI
;-------------------------------------------------------------------------------
;			IMoveDir
; ---Activa a variavel de estado BIKE_MOVEDIR com a direcçao DIREITA(1)
;-------------------------------------------------------------------------------
IMoveDir:	PUSH 	R1
			MOV 	R1,1
			MOV 	M[FLAG_DIREITA],R1
			POP 	R1
			RTI
;-------------------------------------------------------------------------------
;			IMoveEsq
; ---Activa a variavel de estado BIKE_MOVEDIR com a direcçao ESQUERDA(2)
;-------------------------------------------------------------------------------
IMoveEsq:	PUSH 	R1
			MOV 	R1,1
			MOV 	M[FLAG_ESQUERDA],R1
			POP		R1
			RTI
;-------------------------------------------------------------------------------			
;
; ---Activa a variavel de estado do timer, que faz com que os obstaculos se movam 
; -----e reinicia o contador
;-------------------------------------------------------------------------------
Temporizador: 				PUSH 	R1
					PUSH	R2
					MOV 	R1,M[VELOCIDADE_JOGO]
					MOV 	M[COUNT_TIMER],R1
					MOV 	R1,1
					MOV 	M[CONTROLO_TIMER],R1
					INC 	M[Aux]
					MOV 	M[Flag_Timer],R1
					MOV	R2, 60
					CMP	M[Aux], R2
					BR.Z	RESET_AUX
EndInt:					POP	R2
					POP 	R1
					RTI

RESET_AUX:				MOV	M[Aux], R0
					BR	EndInt
;===============================================================================
;===============================PROGRAMA PRINCIPAL==============================
; -----Registos reservados - R4,R5 e R6
;===============================================================================
				ORIG	0000h
inicio:				MOV		R7, SP_INICIAL
				MOV		SP, R7
				
				MOV     R7, INT_MASK
                		MOV     M[MASK_ADDR], R7
				
				MOV		R7,FFFFh			
				MOV		M[IO_POS],R7
				

				CALL    InitMessages

				ENI				

espera:			INC	M[CICLOS]
				CMP 	M[JOGOINICIADO],R0
				
				BR.Z 	espera

				;CALL 	AtomicBomb
				;MOV 	M[Flag_Timer],R0

				MOV 	R4,5
				MOV 	M[VELOCIDADE_JOGO],R4
				MOV 	M[COUNT_TIMER],R4
				MOV 	R4,1
				MOV 	M[CONTROLO_TIMER],R4
				
				
				CALL    ApagaMessages

				INC     M[CICLOS]

				CALL    DesenhaMapa
				CALL  	DesenhaBike
				CALL	InicLCD
				
				CMP 	M[JOGO_REINICIALIZADO],R0
				BR.NZ 	skip1

				CALL	InicLCD_Max

skip1:			CALL 	InicLeds
				CALL 	InitDisplays

				;PUSH 	32
				;PUSH 	53
			 	;CALL 	Rand
				;MOV 	M[OBS_POS1],R6
				;CALL 	DesenhaObstaculo

				MOV 	R5,1
				MOV 	M[Aux],R5

				;PUSH 	32
				;PUSH 	37
				;CALL 	Rand
				;MOV 	M[OBS_POS2],R6
				;CALL 	DesenhaObstaculo2

				;PUSH 	38
				;PUSH 	45
				;CALL 	Rand
				;MOV 	M[OBS_POS3],R6
				;CALL 	DesenhaObstaculo3

				;PUSH 	47
				;PUSH 	51
				;CALL 	Rand
				;MOV 	M[OBS_POS3],R6
				;CALL 	DesenhaObstaculo3
	
		
CicloJogo:		MOV 	R5,M[Flag_FimdeJogo]
				CMP 	R5,R0
				JMP.NZ 	espera

				MOV 	R5,M[Aux]	
				INC		M[CICLOS]
				CALL Colisoes
				;CALL	DesenhaMapa
				CALL	LCD
				
				CMP		M[Flag_Timer],R0
				JMP.Z Next	

				CALL 	TesteIncNivel2
				CALL 	TesteIncNivel3
				CALL 	ResetObsPos
				
				CMP	R5, 1
				JMP.N	Next
				CMP	R5, 1
				BR.Z	Obs1
				CMP	R5, 1
				BR.P	RESTO0
Obs1:				PUSH 	32
				PUSH 	54
				CALL 	Rand
				MOV 	M[OBS_POS1],R6
RESTO0:				CALL	MoveObstaculo
				CMP 	R5,12
				JMP.N 	Next
				CMP	R5, 12
				BR.Z	Obs2
				CMP	R5, 12
				BR.P	RESTO

Obs2:		 		PUSH 	32
				PUSH 	54
				CALL 	Rand
				MOV 	M[OBS_POS2],R6
RESTO:				CALL	MoveObstaculo2
				CMP	R5, 23
				JMP.N 	Next
				CMP	R5, 23
				BR.Z	Obs3
				CMP	R5, 23
				BR.P	RESTO2
Obs3:				PUSH 	32
				PUSH 	54
				CALL 	Rand
				MOV 	M[OBS_POS3],R6
RESTO2:				CALL	MoveObstaculo3
				CMP	R5, 34
				JMP.N 	Next
				CMP	R5, 34
				BR.Z	Obs4
				CMP	R5, 34
				BR.P	RESTO3
Obs4:				PUSH 	32
				PUSH 	54
				CALL 	Rand
				MOV 	M[OBS_POS4],R6
RESTO3:				CALL	MoveObstaculo4


Next:				CMP 	M[FLAG_ESQUERDA], R0
				CALL.NZ	MoveBike
				
				CMP 	M[FLAG_DIREITA], R0
				CALL.NZ	MoveBike			
				
				MOV 	M[Flag_Timer],R0
				
				JMP 		CicloJogo

				DSI

fim: 			BR 	    fim
;--------------------------------------------------------------------------------
;---------------------------------ROTINAS----------------------------------------
;--------------------------------------------------------------------------------
;================================================================================
; 				MoveBike
; ---Efeito:
; -----Apaga a posiçao actual da bicicleta, actualiza a sua posiçao para esquerda 
;      ou direita e desenha-a nessa posiçao
;================================================================================
MoveBike:		CALL 	ApagaBike
		
				CALL 	IncPosBike

				CALL	DesenhaBike
				RET
;=================================================================================
; 				DesenhaBike
; Efeito:
; --- Rotina que escreve a bicicleta, centrado na posicao POS_BIKE do ecra
;=================================================================================
DesenhaBike:		PUSH	R1
				PUSH	R2
				PUSH	R3
				PUSH 	R4

				MOV		R4, IO_POS
				MOV 	R2, M[POS_BIKE1]
				MOV		M[R4], R2		
				MOV		R3, BIKEMD
		
CicloBike:		MOV		R1, M[R3]
				MOV 	M[IO_WRITE], R1
				INC		R3
				SUB		R2, 0100h
				MOV		M[R4], R2
				CMP 	R2, 1500h
				BR.P	CicloBike

				POP		R4
				POP		R3
				POP		R2
				POP		R1
				RET
;=================================================================================
;				DesenhaMapa 													 =
;																				 =
; ----Efeito:																	 =
; ------Desenha as duas colunas do mapa de jogo 								 =
;=================================================================================
DesenhaMapa:    PUSH    R1
                PUSH    R2
                PUSH    R3
 
                MOV     R2, COL_POS1
                MOV     R3, IO_POS
                MOV     R1, '+'
 
DesenhaMapa1:   MOV     M[R3], R2
                MOV     M[IO_WRITE], R1
                ADD     R2, 0100h
                CMP     R2, 181Dh       ;---------181Dh se estiver muito a direita
                BR.NZ   DesenhaMapa1
               
                INC     R2
                MOV     R1, '|'
 
DesenhaMapa2:   MOV     M[R3], R2
                MOV     M[IO_WRITE], R1
                ADD     R2, 0100h
                CMP     R2, 101Eh      ;-----------181Eh se estiver muito a direita
                BR.NZ   DesenhaMapa2
 
                MOV     R2, COL_POS2
 
DesenhaMapa3:   MOV     M[R3], R2
                MOV     M[IO_WRITE], R1
                ADD     R2, 0100h
                CMP     R2, 1837h     ;-----------1837h se estiver muito a direita
                BR.NZ   DesenhaMapa3
 
                INC     R2
                MOV     R1, '+'
 
DesenhaMapa4:   MOV     M[R3], R2
                MOV     M[IO_WRITE], R1
                ADD     R2, 0100h
                CMP     R2, 1838h     ;------------1838h se estiver muito a direita
                BR.NZ   DesenhaMapa4
 
                POP     R3
                POP     R2
                POP     R1
                RET
;====================================================================================
;				ApagaBike
;
; ---Efeito:
; -----Apaga a bicicleta da sua posiçao actual
;====================================================================================
ApagaBike:		PUSH	R1
				PUSH	R2
				PUSH	R3


				MOV		R1, IO_POS
				MOV 	R2, M[POS_BIKE1]
				MOV		M[R1], R2
				MOV 	R3, ' '
 
CicloApaga:		MOV 	M[IO_WRITE], R3
				SUB 	R2, 0100h
				MOV		M[R1], R2
				CMP		R2, 1500h
				BR.P	CicloApaga

				POP		R3
				POP		R2
				POP		R1
				RET
;=====================================================================================
; 				IncPosBike
;
; ---Efeitos:
; -----Incrementa ou decrementa a posiçao da bicicleta dependendo de qual o valor da 
;      flags, testando colisoes contra paredes.
;=====================================================================================
IncPosBike:		PUSH 	R1
				PUSH 	R2	

				CMP		M[FLAG_ESQUERDA], R0  ;---testa se a interrupçao premida foi a esquerda
				BR.Z	MoveDir

MovEsq:			MOV		R2, M[POS_BIKE1]  ;---testa colisoes com limite esquerdo
				AND		R2, 00FFh
				MOV		R1, 001Fh
				CMP 	R1, R2
				BR.NN	ColisaoLimite

				DEC		M[POS_BIKE1]
				MOV		M[FLAG_ESQUERDA], R0
				POP 	R2
				POP 	R1
				RET

MoveDir:		MOV		R2, M[POS_BIKE1] ; ----testa colisoes com limite direito
				AND		R2, 00FFh
				MOV		R1, 0036h
				CMP 	R1, R2 ;
				BR.NP	ColisaoLimite
		
				MOV		M[FLAG_DIREITA], R0
				INC		M[POS_BIKE1]
				POP 	R2
				POP 	R1
				RET

ColisaoLimite:	MOV		M[FLAG_ESQUERDA], R0
				MOV		M[FLAG_DIREITA], R0
				POP 	R2
				POP 	R1
				RET
;===================================MENSAGENS======================================
;==================================================================================
;				InitMenssages
;
; ----Efeito:
; ------Escreve as mensagens iniciais nas linhas 12=000Ch e 14=000Eh
;==================================================================================
InitMessages: 	PUSH 	R1
				PUSH    R2
				PUSH 	R3
				PUSH 	R4

				MOV 	R3,FIM_STR
				MOV  	R1,POS_MSG_INIT1
				MOV 	R2,MSG_INICIO1
				

Ciclo1:			MOV 	M[IO_POS],R1
				MOV 	R4,M[R2]
				MOV 	M[IO_WRITE],R4
				INC  	R1
				INC 	R2
				CMP 	M[R2],R3
				BR.Z	linhaSeguinte
				BR 		Ciclo1

linhaSeguinte: 	MOV 	R1,POS_MSG_INIT2
				MOV 	R2,MSG_INICIO2

Ciclo2: 		MOV 	M[IO_POS],R1
				MOV 	R4,M[R2]
				MOV 	M[IO_WRITE],R4
				INC 	R1
				INC 	R2
				CMP 	M[R2],R3
				BR.Z    end
				BR 		Ciclo2

end: 			POP 	R4
				POP 	R3
				POP 	R2
				POP 	R1
				RET
;===================================================================================
;				ApagaMenssages
;
; ---Efeitos:
; -----Apaga as duas linhas onde se encontram as mensagens de inicio e fim de jogo
;===================================================================================
ApagaMessages: 	PUSH 	R1
				PUSH 	R2
				PUSH 	R3

				MOV 	R1,0C00h
				MOV 	R2,SPACE
				MOV 	R3,M[R2]

ciclo_p:			MOV 	M[IO_POS],R1
				MOV 	M[IO_WRITE],R3
				INC 	R1
				CMP		R1,0C4Fh
				BR.Z 	proxLinha
				BR 		ciclo_p

proxLinha:		MOV 	R1,0E00h
				
ciclo2:			MOV 	M[IO_POS],R1
				MOV 	M[IO_WRITE],R3
				INC 	R1
				CMP		R1,0E4Fh
				BR.Z 	AMfim
				BR 		ciclo2 

AMfim:			POP 	R3
				POP 	R2
				POP 	R1
				RET
;=================================OBSTACULOS====================================
;===============================================================================
;				MoveObstaculo
;
; ---Efeitos:
; -----Apaga, actualiza a posiçao e desenha o obstaculo na nova posiçao
;===============================================================================
MoveObstaculo: 			CALL 	DesenhaObstaculo

				CALL 	ApagaObstaculo
	
				CALL 	IncPosObstaculo

				CALL 	DesenhaObstaculo

				INC	M[Distancia1]

				MOV	M[Flag_Timer], R0

				RET
;===============================================================================
;				DesenhaObstaculo
;
; -----vai receber um valor aleatorio para a 1ª posiçao
;===============================================================================
DesenhaObstaculo: 	PUSH 	R1
					PUSH 	R2

					MOV 	R1,1
					MOV 	M[Flag_Obs1],R1  ;testa se o obstaculo ja apareceu pela primeira vez, e se pode mover

					MOV 	R1,M[OBS_POS1]  ;------VALOR ALEATORIO----
					MOV 	R2,M[OBSTACULO]

					MOV 	M[IO_POS],R1
					MOV 	M[IO_WRITE],R2
					
					INC  	R1

					MOV 	M[IO_POS],R1
					MOV 	M[IO_WRITE],R2

					MOV 	R1,M[OBS_POS1]
					DEC 	R1

					MOV 	M[IO_POS],R1
					MOV 	M[IO_WRITE],R2

					POP 	R2
					POP 	R1
					RET
;================================================================================
;					ApagaObstaculo
;
; ----Efeito:
; ------Apaga o obstaculo antes de o mover para baixo
;================================================================================
ApagaObstaculo: 	PUSH 	R1
					PUSH 	R2

					MOV 	R1,M[OBS_POS1]
					MOV 	R2,M[SPACE]

					MOV 	M[IO_POS],R1
					MOV 	M[IO_WRITE],R2
					
					INC  	R1

					MOV 	M[IO_POS],R1
					MOV 	M[IO_WRITE],R2

					MOV 	R1,M[OBS_POS1]
					DEC 	R1

					MOV 	M[IO_POS],R1
					MOV 	M[IO_WRITE],R2

					POP 	R2
					POP 	R1
					RET
;=================================================================================
;						IncPosObstaculo
;
; ---Efeito:
; ------Move obstaculo para baixo
;=================================================================================
IncPosObstaculo: 	PUSH 	R1

					MOV 	R1,0100h
					ADD 	M[OBS_POS1],R1

					POP 	R1
					RET
;================================================================================
;================================================================================
;				MoveObstaculo2
;
; ---Efeitos:
; -----Apaga, actualiza a posiçao e desenha o obstaculo na nova posiçao
;===============================================================================
MoveObstaculo2: 		CALL 	DesenhaObstaculo2

				CALL 	ApagaObstaculo2
	
					CALL 	IncPosObstaculo2

					CALL 	DesenhaObstaculo2

					MOV	M[Flag_Timer], R0

					RET
;===============================================================================
;				DesenhaObstaculo2
;
; -----vai receber um valor aleatorio para a 1ª posiçao
;===============================================================================
DesenhaObstaculo2: 	PUSH 	R1
					PUSH 	R2

					MOV 	R1,1
					MOV 	M[Flag_Obs2],R1  ;testa se o obstaculo ja apareceu pela primeira vez, e se pode mover

					MOV 	R1,M[OBS_POS2]  ;------VALOR ALEATORIO----
					MOV 	R2,M[OBSTACULO]

					MOV 	M[IO_POS],R1
					MOV 	M[IO_WRITE],R2
					
					INC  	R1

					MOV 	M[IO_POS],R1
					MOV 	M[IO_WRITE],R2

					MOV 	R1,M[OBS_POS2]
					DEC 	R1

					MOV 	M[IO_POS],R1
					MOV 	M[IO_WRITE],R2

					POP 	R2
					POP 	R1
					RET
;================================================================================
;					ApagaObstaculo2
;
; ----Efeito:
; ------Apaga o obstaculo antes de o mover para baixo
;================================================================================
ApagaObstaculo2: 	PUSH 	R1
					PUSH 	R2

					MOV 	R1,M[OBS_POS2]
					MOV 	R2,M[SPACE]

					MOV 	M[IO_POS],R1
					MOV 	M[IO_WRITE],R2
					
					INC  	R1

					MOV 	M[IO_POS],R1
					MOV 	M[IO_WRITE],R2

					MOV 	R1,M[OBS_POS2]
					DEC 	R1

					MOV 	M[IO_POS],R1
					MOV 	M[IO_WRITE],R2

					POP 	R2
					POP 	R1
					RET
;=================================================================================
;						IncPosObstaculo2
;
; ---Efeito:
; ------Move obstaculo para baixo
;=================================================================================
IncPosObstaculo2: 	PUSH 	R1

					MOV 	R1,0100h
					ADD 	M[OBS_POS2],R1

					POP 	R1
					RET
;===============================================================================
;				MoveObstaculo3
;
; ---Efeitos:
; -----Apaga, actualiza a posiçao e desenha o obstaculo na nova posiçao
;===============================================================================
MoveObstaculo3: 		CALL 	DesenhaObstaculo3

				CALL 	ApagaObstaculo3
	
					CALL 	IncPosObstaculo3

					CALL 	DesenhaObstaculo3

					MOV	M[Flag_Timer], R0

					RET
;===============================================================================
;				DesenhaObstaculo3
;
; -----vai receber um valor aleatorio para a 1ª posiçao
;===============================================================================
DesenhaObstaculo3: 	PUSH 	R1
					PUSH 	R2

					MOV 	R1,1
					MOV 	M[Flag_Obs3],R1  ;testa se o obstaculo ja apareceu pela primeira vez, e se pode mover

					MOV 	R1,M[OBS_POS3]  ;------VALOR ALEATORIO----
					MOV 	R2,M[OBSTACULO]

					MOV 	M[IO_POS],R1
					MOV 	M[IO_WRITE],R2
					
					INC  	R1

					MOV 	M[IO_POS],R1
					MOV 	M[IO_WRITE],R2

					MOV 	R1,M[OBS_POS3]
					DEC 	R1

					MOV 	M[IO_POS],R1
					MOV 	M[IO_WRITE],R2

					POP 	R2
					POP 	R1
					RET
;================================================================================
;					ApagaObstaculo3
;
; ----Efeito:
; ------Apaga o obstaculo antes de o mover para baixo
;================================================================================
ApagaObstaculo3: 	PUSH 	R1
					PUSH 	R2

					MOV 	R1,M[OBS_POS3]
					MOV 	R2,M[SPACE]

					MOV 	M[IO_POS],R1
					MOV 	M[IO_WRITE],R2
					
					INC  	R1

					MOV 	M[IO_POS],R1
					MOV 	M[IO_WRITE],R2

					MOV 	R1,M[OBS_POS3]
					DEC 	R1

					MOV 	M[IO_POS],R1
					MOV 	M[IO_WRITE],R2

					POP 	R2
					POP 	R1
					RET
;=================================================================================
;						IncPosObstaculo3
;
; ---Efeito:
; ------Move obstaculo para baixo
;=================================================================================
IncPosObstaculo3: 	PUSH 	R1

					MOV 	R1,0100h
					ADD 	M[OBS_POS3],R1

					POP 	R1
					RET
;================================================================================
;				MoveObstaculo4
;
; ---Efeitos:
; -----Apaga, actualiza a posiçao e desenha o obstaculo na nova posiçao
;===============================================================================
MoveObstaculo4: 		CALL 	DesenhaObstaculo4

				CALL 	ApagaObstaculo4
	
					CALL 	IncPosObstaculo4

					CALL 	DesenhaObstaculo4

					MOV	M[Flag_Timer], R0

					RET
;===============================================================================
;				DesenhaObstaculo4
;
; -----vai receber um valor aleatorio para a 1ª posiçao
;===============================================================================
DesenhaObstaculo4: 	PUSH 	R1
					PUSH 	R2

					MOV 	R1,1
					MOV 	M[Flag_Obs4],R1  ;testa se o obstaculo ja apareceu pela primeira vez, e se pode mover

					MOV 	R1,M[OBS_POS4]  ;------VALOR ALEATORIO----
					MOV 	R2,M[OBSTACULO]

					MOV 	M[IO_POS],R1
					MOV 	M[IO_WRITE],R2
					
					INC  	R1

					MOV 	M[IO_POS],R1
					MOV 	M[IO_WRITE],R2

					MOV 	R1,M[OBS_POS4]
					DEC 	R1

					MOV 	M[IO_POS],R1
					MOV 	M[IO_WRITE],R2

					POP 	R2
					POP 	R1
					RET
;================================================================================
;					ApagaObstaculo4
;
; ----Efeito:
; ------Apaga o obstaculo antes de o mover para baixo
;================================================================================
ApagaObstaculo4: 	PUSH 	R1
					PUSH 	R2

					MOV 	R1,M[OBS_POS4]
					MOV 	R2,M[SPACE]

					MOV 	M[IO_POS],R1
					MOV 	M[IO_WRITE],R2
					
					INC  	R1

					MOV 	M[IO_POS],R1
					MOV 	M[IO_WRITE],R2

					MOV 	R1,M[OBS_POS4]
					DEC 	R1

					MOV 	M[IO_POS],R1
					MOV 	M[IO_WRITE],R2

					POP 	R2
					POP 	R1
					RET
;=================================================================================
;						IncPosObstaculo4
;
; ---Efeito:
; ------Move obstaculo para baixo
;=================================================================================
IncPosObstaculo4: 	PUSH 	R1

					MOV 	R1,0100h
					ADD 	M[OBS_POS4],R1

					POP 	R1
					RET
;================================================================================
;=================================================================================
;===================================LEDS==========================================
;					IncLevelLeds
;
; ---Altera os LEDS para corresponder ao nivel
;=================================================================================
;=================================================================================
; 					InicLeds  				   
; Efeito:
; --- Rotina que acende todos os 4 LEDS correspondentes ao 1º nivel;
;=================================================================================
InicLeds:			PUSH	R1

					MOV 	R1, F000h;
					MOV	    M[VALORLEDS],R1
					MOV 	M[LEDS], R1

					POP	R1
					RET
;================================================================================
; 				IncLedsNivel2
; Efeito:
; --- Altera o valor dos LEDS (4 / 8 / 12).
;=================================================================================
IncLedsNivel2:		PUSH	R1
					PUSH 	R2
					
					MOV 	R1,FF00h
					MOV 	M[VALORLEDS],R1
					MOV 	R2,M[VALORLEDS]
					MOV 	M[LEDS],R2

					POP 	R1
					POP 	R2

					RET
;=================================================================================
; 				IncLedsNivel3
; Efeito:
; --- Altera o valor dos LEDS (4 / 8 / 12).
;=================================================================================
IncLedsNivel3:		PUSH	R1
					PUSH 	R2
					
					MOV 	R1,FFF0h
					MOV 	M[VALORLEDS],R1
					MOV 	R2,M[VALORLEDS]
					MOV 	M[LEDS],R2

					POP 	R1
					POP 	R2

					RET
					
;=================================================================================
;				Inicia o LCD DA PRIMEIRA LINHA
;Efeito:
;--- Escreve no LCD 'Distancia:00000m' na primeira linha
;=================================================================================
InicLCD:				PUSH	R1
					PUSH	R2
					PUSH	R3
					MOV	R1, D
					MOV	R2, 8000h   ;Posição da primeira coluna e primeira linha, ativando o LCD
VOLTA:				MOV	R3, M[R1]
					MOV	M[LCD_POSICAO], R2
					MOV	M[LCD_WRITE], R3
					INC R2
					INC	R1
					CMP R2, 800Fh
					BR.NP	VOLTA
					POP	R3
					POP	R2
					POP	R1
					RET
					
;ROTINA PARA ESCREVER O MAXIMO NO LCD
;=================================================================================
;					Inicia o LCD DA SEGUNDA LINHA
;Efeito:
;--- Escreve no LCD 'Maximo:00000m' NA SEGUNDA LINHA
;=================================================================================
InicLCD_Max:				PUSH	R1
					PUSH	R2
					PUSH	R3
					MOV	R1, caracterM
					MOV	R2, 8010h
REPETE:					MOV	R3, M[R1]
					MOV	M[LCD_POSICAO], R2
					MOV	M[LCD_WRITE], R3
					INC	R2
					INC	R1
					CMP	R2, 801Ch
					BR.NP	REPETE
					POP	R3
					POP	R2
					POP	R1
					RET
;=================================================================================
;				ESCREVE NUMEROS NA PRIMEIRA LINHA
;Efeito:
;--- Escreve no LCD OS NUMEROS DA DISTANCIA
;=================================================================================
LCD:					PUSH	R1
					PUSH	R2
					PUSH	R3
					PUSH	R4
					PUSH	R5
					PUSH	R6
					PUSH	R7
RETOMA:					MOV	R1, Distancia1
					MOV	R2, 800Eh
					MOV	R3, M[R1]
					MOV	M[LCD_POSICAO], R2
					MOV	M[LCD_WRITE], R3
					CMP	R3, 003Ah
					BR.Z	DEZENAS
					POP	R7
					POP	R6
					POP	R5
					POP	R4
					POP	R3
					POP	R2
					POP	R1
					RET

DEZENAS:				MOV	R4, 0030h
					MOV	M[Distancia1], R4
					INC	M[Distancia2]
					DEC	R2
RETOMA2:			MOV	R4, Distancia2
					MOV	R3, M[R4]
					MOV	M[LCD_POSICAO], R2
					MOV	M[LCD_WRITE], R3
					INC	R2
					CMP	R3, 003Ah
					BR.Z	CENTENAS
					JMP	RETOMA

CENTENAS:				MOV	R4, 0030h
					MOV	M[Distancia2], R4
					INC	M[Distancia3]
					DEC	R2
RETOMA3:			MOV	R5, Distancia3
					MOV	R3, M[R5]
					MOV	M[LCD_POSICAO], R2
					MOV	M[LCD_WRITE], R3
					INC	R2
					CMP	R3, 003Ah
					BR.Z	MILHARES
					JMP	RETOMA2

MILHARES:				MOV	R4, 0030h
					MOV	M[Distancia3], R4
					INC	M[Distancia4]
					DEC	R2
RETOMA4:			MOV	R6, Distancia4
					MOV	R3, M[R6]
					MOV	M[LCD_POSICAO], R2
					MOV	M[LCD_WRITE], R3
					INC	R2
					CMP	R3, 003Ah
					BR.Z	DEZ_MILHARES
					JMP	RETOMA3

DEZ_MILHARES:				MOV	R4, 0030h
					MOV	M[Distancia4], R4
					INC	M[Distancia5]
					MOV	R7, Distancia5
					MOV	R3, M[R7]
					DEC	R2
					MOV	M[LCD_POSICAO], R2
					MOV	M[LCD_WRITE], R3
					CMP	R3, 003Ah
					JMP.Z	RETOMA


;=================================================================================
;==================================DISPLAYS=======================================
; 				EscDisplays
; Entradas:
; --- Pilha:
; ------ (+4)Valor
; Efeito:
; --- Escreve o valor recebido nos displays
;=================================================================================
EscDisplays:		PUSH	R1
					PUSH	R2

					MOV	R1, M[SP+4]
					MOV	R2, Ah
					DIV	R1, R2
					MOV	M[DISP1], R2
					MOV	R2, Ah
					DIV	R1, R2
					MOV	M[DISP2], R2
					MOV	R2, Ah
					DIV	R1, R2
					MOV	M[DISP3], R2
					MOV	M[DISP4], R1

					POP	R2
					POP	R1
					RETN	1
;=================================================================================
; 				InitDisplays
; Efeito:
; --- Rotina que poe os displays a 0.
;=================================================================================
InitDisplays:		PUSH	R0
					CALL 	EscDisplays
					RET
;=================================================================================
;====================================RANDOM=======================================
; 				GeraNumero
; Efeito:
; --- Gera um novo numero aleatorio em M[RANDNUM]
;=================================================================================
GerarNumero:		PUSH	R2
					PUSH	R3

					MOV	R2, M[CICLOS]
					MOV	R3, M[RANDNUM]
					AND	R2, 0001h
					CMP	R2, R0
					BR.NZ	GN2
					ROR	R3, 1
					BR	GNEnd

GN2:				XOR	R3, RAND_MASK
					ROR	R3, 1

GNEnd:				MOV	M[RANDNUM], R3

					POP	R3
					POP	R2
		
					RET

;=================================================================================
; 				Rand
; Entradas:
; --- Pilha:
; ------ (+6)ValMinimo
; ------ (+5)ValMaximo
; Saidas
; --- Saida:
; ------  R6-Numero gerado
; Efeito:
; --- Gera um numero entre ValMinimo e ValMaximo
;=================================================================================
Rand:			PUSH	R1
				PUSH	R2
				PUSH 	R3

				CALL	GerarNumero

				MOV	R1, M[SP+6]
				MOV R3, M[SP+6]
				MOV	R2, M[SP+5]

				SUB	R2, R1

				MOV	R1, M[RANDNUM]
				DIV	R1, R2

				ADD	R3, R2

				MOV R6, R3

				POP R3
				POP	R2
				POP	R1
				RETN	2
;=================================================================================
;					GameOver
;
; ----Efeito: Apos colisao com obstaculo, apaga o ecra, poe as flags de inicio de 
;  --- inicio de jogo a zero e a de fim de jogo a um, e reinicia os dados de jogo.
;
;=================================================================================
GameOver: 		PUSH 	R1
				
				CALL 	AtomicBomb     ;----limpa o ecra
				
				MOV 	R1,1
				MOV 	M[Flag_FimdeJogo],R1
				MOV 	M[JOGOINICIADO],R0
				;MOV 	M[Aux],R0

				CALL 	MessagesEndGame
				CALL	MAXIMO_LCD

				MOV 	M[JOGO_REINICIALIZADO],R1

				POP 	R1
				RET
;=================================================================================
;						Colisoes
;
; ---Efeitos:Testa colisoes com os obstaculos se eles tiverem ultrapassado a linha 19
;=================================================================================
Colisoes:				PUSH 	R1
				PUSH 	R2
				PUSH 	R3

				MOV 	R1,M[POS_BIKE1]
				SUB 	R1,0300h

				MOV 	R2,M[OBS_POS1]
				CMP 	R2,1300h
				BR.P 	testObj1
				BR 		Next0


testObj1:  		CMP 	R1,R2
			 	CALL.Z GameOver

				INC 	R2
				CMP 	R1,R2
				CALL.Z GameOver

				DEC 	R2
				DEC 	R2
				CMP 	R1,R2
				CALL.Z GameOver

Next0: 			MOV 	R2,M[OBS_POS2]
				CMP 	R2,1300h
				BR.P 	testObj2
				BR 		Next2


testObj2:  		CMP 	R1,R2
				CALL.Z  GameOver

				INC 	R2
				CMP 	R1,R2
				CALL.Z 	GameOver

				DEC 	R2
				DEC 	R2
				CMP 	R1,R2
				CALL.Z 	GameOver

Next2: 			MOV 	R2,M[OBS_POS3]
				CMP 	R2,1300h
				BR.P 	testObj3
				BR 		Next3


testObj3:  		CMP 	R1,R2
				CALL.Z GameOver

				INC 	R2
				CMP 	R1,R2
				CALL.Z 	GameOver

				DEC 	R2
				DEC 	R2
				CMP 	R1,R2
				CALL.Z 	GameOver

Next3: 			MOV 	R2,M[OBS_POS4]
				CMP 	R2,1300h
				BR.P 	testObj4
				BR 		End4


testObj4:  		CMP 	R1,R2
				CALL.Z  GameOver

				INC 	R2
				CMP 	R1,R2
				CALL.Z 	GameOver

				DEC 	R2
				DEC 	R2
				CMP 	R1,R2
				CALL.Z 	GameOver

End4: 			POP 	R3
				POP 	R2
				POP 	R1
				RET
;===============================================================================
;				AtomicBomb
; --- Apaga o ecra,escrevendo SPACE em cada posicao.
;===============================================================================
AtomicBomb: 	PUSH 	R4
				PUSH	R5
				PUSH	R1
				PUSH 	R2
				
				MOV	R4, ' '
				MOV	R1, IO_POS

 
				PUSH	R0

Ciclo6:			POP	R5
				
				MOV R2,3


				MOV	M[R1], R5
				MOV	M[IO_WRITE], R4
				INC	R5
				PUSH	R5
				AND	R5, 00FFh
				CMP	R5, 0051h
				BR.NZ	Ciclo6


				POP	R5	
				AND	R5, FF00h
				ADD	R5, 0100h
				PUSH	R5
				CMP	R5, 1800h
				BR.NZ	Ciclo6
				POP	R5
				

				POP R2
				POP	R1
				POP R5
				POP	R4
				RET
;==================================================================================
;==================================================================================
;				MenssagesEndGame
;
; ----Efeito:
; ------Escreve as mensagens iniciais nas linhas 12=000Ch e 14=000Eh
;==================================================================================
MessagesEndGame: 	PUSH 	R1
				PUSH    R2
				PUSH 	R3
				PUSH 	R4

				MOV 	R3,FIM_STR
				MOV  	R1,POS_MSG_INIT1
				MOV 	R2,MSG_FIM1
				

Ciclo7:			MOV 	M[IO_POS],R1
				MOV 	R4,M[R2]
				MOV 	M[IO_WRITE],R4
				INC  	R1
				INC 	R2
				CMP 	M[R2],R3
				BR.Z	linhaSeguinte2
				BR 		Ciclo7

linhaSeguinte2: 	MOV 	R1,POS_MSG_INIT2
				MOV 	R2,MSG_FIM2

Ciclo8: 		MOV 	M[IO_POS],R1
				MOV 	R4,M[R2]
				MOV 	M[IO_WRITE],R4
				INC 	R1
				INC 	R2
				CMP 	M[R2],R3
				BR.Z    end4
				BR 		Ciclo8

end4: 			POP 	R4
				POP 	R3
				POP 	R2
				POP 	R1
				RET


;=========================================================================
;				MAXIMO_LCD
;
;
;==========================================================================
MAXIMO_LCD:		PUSH	R1
				PUSH	R2
				PUSH	R3
				PUSH	R4
				MOV 	R1, Distancia1
				MOV 	R2, 801Ch
				MOV 	R4, 0000h
DENOVO:			MOV 	M[LCD_POSICAO], R2
				MOV 	R3, M[R1]
				MOV 	M[LCD_WRITE], R3
				INC 	R4
				DEC 	R2
				INC 	R1
				CMP 	R4, 0005h
				BR.N 	DENOVO

				POP		R4
				POP 	R3
				POP 	R2
				POP		R1
				RET
;==========================================================================
TesteIncNivel2:		PUSH 	R1
					PUSH 	R2

					MOV 	R1,M[ObstaculosUltrapassados]
					CMP 	R1,4
					BR.NZ 	End5

					CALL 	IncLedsNivel2
					MOV 	R2,4
					MOV 	M[VELOCIDADE_JOGO],R2
					MOV 	M[COUNT_TIMER],R2
					CALL 	ApagaObstaculo
					CALL 	ApagaObstaculo2
					CALL 	ApagaObstaculo3
					CALL 	ApagaObstaculo4

End5: 				POP 	R2
					POP 	R1
					RET
;=============================================================================
TesteIncNivel3:		PUSH 	R1
					PUSH 	R2

					MOV 	R1,M[ObstaculosUltrapassados]
					CMP 	R1,8
					BR.NZ 	End6

					CALL 	IncLedsNivel3
					MOV 	R2,3
					MOV 	M[VELOCIDADE_JOGO],R2
					MOV 	M[COUNT_TIMER],R2

End6: 				POP 	R2
					POP 	R1
					RET
;=============================================================================
;=============================================================================
;						ResetObsPos
;
; ---Efeitos:Testa a posiçao dos obstaculos. Se algum estiver na linha 24 variavel
; ---de contagem de obstaculos ultrapassados e incrementada e o seu novo valor es-
; ---crito nos displays
;
;=============================================================================
ResetObsPos:	PUSH 	R1
				PUSH 	R2
				PUSH 	R3

				MOV 	R2,M[OBS_POS1]
				CMP 	R2,1800h
				BR.P 	testObj10
				BR 		Next10


testObj10: 		INC 	M[ObstaculosUltrapassados]
				PUSH  	M[ObstaculosUltrapassados]
				CALL 	EscDisplays	
				PUSH 	32
				PUSH 	53
				CALL 	Rand
				MOV 	M[OBS_POS1],R6


Next10: 		MOV 	R2,M[OBS_POS2]
				CMP 	R2,1800h
				BR.P 	testObj20
				BR 		Next20


testObj20:  	INC 	M[ObstaculosUltrapassados]
				PUSH  	M[ObstaculosUltrapassados]
				CALL 	EscDisplays	 
				PUSH 	32
				PUSH 	53
				CALL 	Rand
				MOV 	M[OBS_POS2],R6

Next20: 		MOV 	R2,M[OBS_POS3]
				CMP 	R2,1800h
				BR.P 	testObj30
				BR 		Next30


testObj30:  	INC 	M[ObstaculosUltrapassados]
				PUSH  	M[ObstaculosUltrapassados]
				CALL 	EscDisplays
				PUSH 	32
				PUSH 	53
				CALL 	Rand
				MOV 	M[OBS_POS3],R6	

Next30: 			MOV 	R2,M[OBS_POS4]
				CMP 	R2,1800h
				BR.P 	testObj40
				BR 		End40


testObj40:  	INC 	M[ObstaculosUltrapassados]
				PUSH  	M[ObstaculosUltrapassados]
				CALL 	EscDisplays
				PUSH 	32
				PUSH 	53
				CALL 	Rand
				MOV 	M[OBS_POS4],R6	 

End40: 			POP 	R3
				POP 	R2
				POP 	R1
				RET
;===============================================================================