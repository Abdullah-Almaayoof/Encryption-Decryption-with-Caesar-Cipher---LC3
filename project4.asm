.ORIG x3000

LEA R0 startmsg
PUTS
loop    LEA R0 query
        PUTS
        GETC
        LD R1 ASCE          ; Check for an "E"
    	LD R4 goSUB         ; load address of SUB subroutine into register R4
        JSRR R4             ; call subtract subroutine - inputs are in R1, R0 and it will return result in R1
        BRnp qD
        LD R4 goEnc
        JSRR R4
        BRnzp loop
qD      LD R1 ASCD          ; Check for an "D"
    	LD R4 goSUB         ; load address of SUB subroutine into register R4
        JSRR R4             ; call subtract subroutine - inputs are in R1, R0 and it will return result in R1
        BRnp qX
        LD R4 goDec
        JSRR R4
        BRnzp loop
qX      LD R1 ASCX          ; Check for an "X"
    	LD R4 goSUB         ; load address of SUB subroutine into register R4
        JSRR R4             ; call subtract subroutine - inputs are in R1, R0 and it will return result in R1
        BRnp Inval
        LDI R1 message
        AND R1 R1 #0
        HALT
        
Inval   LEA R0 invalid
        PUTS
        BRnzp loop          ; End main
        

startmsg    .STRINGZ "\nSTARTING PRIVACY MODULE\n"
query       .STRINGZ "\nENTER E OR D OR X\n"
keymsg      .STRINGZ "\nENTER KEY\n"
promptmsg   .STRINGZ "\nENTER MESSAGE\n"
invalid     .STRINGZ "\nINVALID INPUT\n"

ASCE    .FILL x45
ASCD    .FILL x44
ASCX    .FILL x58               ; Fill ASCX with the hex value of X
ASC0    .FILL x30
ASC7    .FILL x37
ASC1    .FILL x31
ASC9    .FILL x39

goSUB       .FILL SUB               ; initialize variable goSUB to the address/label of subroutine SUB
;goMult      .FILL Mult
;goKey       .FILL getKey
goEnc       .FILL encrypt
goDec       .FILL decrypt
;goCae       .FILL caeser
;goUncaeser  .FILL uncaeser
;goY         .FILL getY
;goCH        .FILL helpCaeser
;goShift     .FILL shift
;goUnshift   .FILL unshift
;goReadN     .FILL readN
;goXOR       .FILL XOR

key     .BLKW 5
message .FILL x4000
encRet  .BLKW 1                 ; Save R7 in encrypt
keyRet  .BLKW 1                 ; Save R7 in getKey
caeRet  .BLKW 1                 ; Save R7 in caeser
vigRet  .BLKW 1
yRet    .BLKW 1                 ; Save R7 in getY


; Sub routine         
encrypt
        ST R7 encRet            ; Save our return 
        ;LEA R4 getKey
        JSR getKey
        LEA R0 promptmsg
        PUTS
        LD R6 message
        AND R5 R5 #0
        ADD R5 R5 #10
        ;LEA R4 goReadN
        JSR readN
        JSR vigenere
        JSR caeser
        JSR shift
        LD R7 encRet
        RET

getKey  ST R7 keyRet            ; Save our return
eKey    LEA R0 keymsg           ; prompt for key
        PUTS                    ; display prompt
        LEA R6 key              ; use R6 to access key
        AND R5 R5 #0            ; clear Register 5
        ADD R5 R5 #5            ; set R5 to 5
        ;LEA R4 goReadN            ; read key
        JSR readN                 ; call readN
        LEA R6 key              ; reload R6 with key
        LDR R0 R6 #0            ; load R0 with key[0]
        LD R1 ASC0              ; load the ASCII value of 0 into R1
        ;LEA R4 goSUB            
        JSR SUB
        BRn keyInv              ; key[0] < '0'
        
        LD R1 ASC7              ; load the ASCII value of 7 into R1
        JSR SUB                 ; Subtract
        BRp keyInv              ; key[0] > '7'
        
        ;LDR R0 R6 #1            ;load R0 with key[1]
        ;LD R1 ASC0
        ;JSR SUB
        ;BRp keyInv
        
        ;LD R1 ASC9
        ;JSR SUB
        ;BRn keyInv
        
        LDR R0 R6 #2            ; load R0 with key[2]
        LD R1 ASC0              ;
        ;LEA R4 goSUB
        JSR SUB
        BRn keyInv              ; key[2] < '0'
        
        LD R1 ASC1              ; load the ASCII value of 1 into R1
        JSR SUB                 ; Subtract
        BRp keyInv              ; key[2] > '1'
        
        LDR R0 R6 #3            ; load R0 with key[3]
        LD R1 ASC0              ;
        ;LEA R4 goSUB
        JSR SUB
        BRn keyInv              ; key[3] < '0'
        LD R1 ASC9              ; load the ASCII value of 9 into R1
        JSR SUB                 ; Subtract
        BRp keyInv              ; key[3] > '9'
        
        LDR R0 R6 #4            ; load R0 with key[4]
        LD R1 ASC0              ;
        ;LEA R4 goSUB
        JSR SUB
        BRn keyInv              ; key[4] < '0'
        LD R1 ASC9              ; load the ASCII value of 9 into R1
        JSR SUB                 ; Subtract
        BRp keyInv              ; key[4] > '9'
        ; key is valid   
        LD R7 keyRet
        RET
keyInv
        LEA R0 invalid
        PUTS
        BRnzp eKey
 
decrypt
        ST R7 encRet            ; Save our return 
        LEA R4 getKey
        JSRR R4
        LEA R0 promptmsg
        PUTS
        LEA R6 message
        AND R5 R5 #0
        ADD R5 R5 #10
        JSR readN
        JSR unVigenere
        JSR unCaeser
        JSR unshift
        LD R7 encRet
        RET
        
caeser
        ST R7 caeRet
        ;LEA R4 goY
        JSR getY
        JSR helpCae
        LD R7 caeRet
        RET
        
uncaeser
        ST R7 caeRet
        JSR getY
        NOT R0 R0
        ADD R0 R0 #1
        JSR helpCae
        LD R7 caeRet
        RET
        
helpCae
        
        
        
        
        
        
vigenere
        ST R7 vigRet
        LDR R0 R6 #1
        JSR helpVig
        LD R7 vigRet
        RET
        
unVigenere
        
        
        
        
        
helpVig
        
        
        
        
getY
        ST R7 yRet
        LEA R6 key              ; use R6 to access key
        LDR R0 R6 #2
        LD R1 ASC0              
        ;LEA R4 goSUB
        JSR SUB
        AND R0 R0 #0
        ADD R0 R0 #10
        ;LEA R4 goMult
        JSR Mult
        
        ADD R3 R2 #0            ; copy 10*y1 to R3
        LDR R0 R6 #3
        LD R1 ASC0
        ;LEA R4 goSUB
        JSR SUB
        
        ADD R1 R0 R3            ; R1 = (10*y1 + y2) 
        AND R0 R0 #0
        ADD R0 R0 #10
        ;LEA R4 goMult
        JSR Mult
        
        ADD R3 R2 #0            ; copy 10*(10*y1 + y2) to R3
        LDR R0 R6 #4
        LD R1 ASC0
        ;LEA R4 goSUB
        JSR SUB
        
        ADD R0 R0 R3            ; R0 = 10*(10*y1 + y2) + y3
        LD R7 yRet
        RET
        
; subroutine SUB 
SUB    
        NOT R1, R1              ; complement R1 and store into R1
        ADD R1,R1, #1           ; 2's complement of R1 is now in R1
        ADD R1, R1, R0          ; compute R1 = R0-R1 and store into R1
        RET                     ;return to caller
    
Mult 
        AND R2 R2 #0    ; reset R2
Mull    ADD R2 R2 R0    ; R2 = R0 * R1
        ADD R1 R1 #-1
        BRnp Mull
        RET
                            ; Make sure all the LEA's are all go's
                            ; Make shift and unshift which have the helpShift call with z1 for shifting or (8 - z) for unshifting
                           
XOR
        ; Fill in XOR subroutine
readN
        GETC
        STR R0 R6 #0
        ADD R6 R6 #1
        ADD R5 R5 #-1
        BRp readN
        RET

shift
    
    
    
    
    
        
unshift
        
        
        
        
        
        
MOD
    ADD R1 R1 R0
    RET

.END