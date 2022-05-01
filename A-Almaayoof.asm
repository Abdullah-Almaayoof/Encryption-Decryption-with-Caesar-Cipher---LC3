; This algorithm takes an instruction from the user to either Encrypt(E), Decrypt(D), or Exit(X). 
;It then asks the user to input a 5 character key; if the key is valid(i.e. meets all the criteria 
;for a valid key), the user is asked to enter a 10 character message to be encrypted or decrypted.


.ORIG x3000
; This block of code is the 'main' of this program, it starts off by displaying a message stating 
; that the program is starting, it then displays a message that asks the user if they want to Encrypt(E), 
; Decrypt(D), or Exit(X). To check for what the user chose, we loaded the ASCII values of E, D, and X
; We then check by subtracting the input(R0) from the ASCII value. If the result is 0, then we know that
; the user chose this instruction(E for example). After we know which instruction(letter) the user chose, 
; let's say E, we call the encryption subroutine that does the encryption. If on the other hand, it comes 
; out to a negative or a positive integer, then we know it's not that instruction(E for example) and we 
; branch to check for the next instruction(D for example). Finally, if the input(R0) does not match any
; of the ASCII values, then we know that the input is invalid, and we display a message that states the 
; input is invalid, and ask the user to input an instruction again by looping back to the beginning.

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
        BRnp Inval          ; If result is negative or positive, branch to 'inval'
        LD R1 message
        ADD R2 R1 #0
        AND R3 R3 #0
        ADD R3 R3 #10
clear   AND R2 R2 #0
        ADD R1 R1 #1
        ADD R3 R3 #-1
        BRp clear
        HALT

Inval   LEA R0 invalid
        PUTS
        BRnzp loop          ; End main
        

startmsg    .STRINGZ "\nSTARTING PRIVACY MODULE\n"
query       .STRINGZ "\nENTER E OR D OR X\n"
keymsg      .STRINGZ "\nENTER KEY\n"
promptmsg   .STRINGZ "\nENTER MESSAGE\n"
invalid     .STRINGZ "\nINVALID INPUT\n"
debugmsg    .STRINGZ "\nDEBUG\n"

ASCE    .FILL x45
ASCD    .FILL x44
ASCX    .FILL x58               ; Fill ASCX with the hex value of X
ASC0    .FILL x30
ASC1    .FILL x31
ASC2    .FILL x32
ASC7    .FILL x37
ASC9    .FILL x39
bit7    .FILL x7F

goSUB       .FILL SUB               ; initialize variable goSUB to the address/label of subroutine SUB
goEnc       .FILL encrypt
goDec       .FILL decrypt


key     .BLKW 5                 ; Make space for 5 addresses somewhere in memory for the key
message .FILL x4000             ; Store the message at address x4000
decmsg  .FILL x5000             ; Store the decrypted message at address x5000
encRet  .BLKW 1                 ; Save R7 in encrypt
keyRet  .BLKW 1                 ; Save R7 in getKey
caeRet  .BLKW 1                 ; Save R7 in caeser
vigRet  .BLKW 1
yRet    .BLKW 1                 ; Save R7 in getY
hvRet   .BLKW 1



; This is the encryption subroutine:
; This is where the encryption happens. It first saves whatever value in encRet into R7. It then calls the 
; 'getKey' subroutine which is a subroutine that validates that the key is valid and stores the key in the 
; block of words of 5 characters. After confirming that the key is indeed valid, it asks the user to input
; the message to be encrypted. it then calls the 'readN' subroutine which reads the inputted message. After
; reading the message and storing it in 'message' at address x4000, the subroutine calls all the encryption 
; subroutines: vigenere, caeser, and shift. 
         
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
        LD R6 message
        LD R4 message
        JSR vigenere
        JSR caeser
        ;JSR shift
        LD R7 encRet
        RET

; This is the decryption subroutine:
; This is where the decryption happens. It first saves whatever value in encRet into R7. It then calls the 
; 'getKey' subroutine which is a subroutine that validates that the key is valid and stores the key in the 
; block of words of 5 characters. After confirming that the key is indeed valid, it asks the user to input
; the message to be decrypted. it then calls the 'readN' subroutine which reads the inputted message. After
; reading the message and storing it in 'message' at address x4000, the subroutine calls all the decryption 
; subroutines: vigenere, unCaeser, and unShift. 

decrypt
        ST R7 encRet            ; Save our return 
        ;LEA R4 getKey
        JSR getKey
        LEA R0 promptmsg
        PUTS
        LD  R6 message
        AND R5 R5 #0
        ADD R5 R5 #10
        JSR readN
        ;JSR unshift
        LD R6 message
        LD R4 decmsg
        JSR unCaeser
        LD R6 decmsg
        LD R4 decmsg
        JSR vigenere
        LD R7 encRet
        RET
        
        
        
; This is the getKey subroutine:
; This is where the validation of the key and storing it occurs. It first starts by storing R7 into keyRet.
; It then displays a message that prompts the user to input a key. It then calls the 'readN' subroutine
; to read what the user input for a key. After that, it starts the validation process of the characters of 
; the key. We did that by loading some ASCII values of numbers and doing the same process that we did in
; main. By comparing the ASCII values to the input and checking if each character meets the criteria of 
; a valid input.

getKey  ST R7 keyRet            ; Save our return
eKey    LEA R0 keymsg           ; prompt for key
        PUTS                    ; display prompt
        LEA R6 key              ; use R6 to access key
        AND R5 R5 #0            ; clear Register 5
        ADD R5 R5 #5            ; Set counter for readN to 5 
        ;LEA R4 goReadN         ; read key
        JSR readN               ; reads the key
        LEA R6 key              ; reload R6 with key
        LDR R0 R6 #0            ; load R0 with key[0]
        LD R1 ASC0              ; load the ASCII value of 0 into R1
        ;LEA R4 goSUB            
        JSR SUB
        BRn keyInv              ; key[0] < '0'
        
        LD R1 ASC7              ; load the ASCII value of 7 into R1
        JSR SUB                 ; Subtract
        BRp keyInv              ; key[0] > '7'
        
        LDR R0 R6 #1            ;load R0 with key[1]
        LD R1 ASC0
        JSR SUB
        BRnz y1

        LD R1 ASC9
        JSR SUB
        BRnz keyInv
        
y1      LDR R0 R6 #2            ; load R0 with key[2]
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
        JSR getY
        LD R1 bit7
        JSR SUB
        BRp keyInv
        ; key is valid   
        LD R7 keyRet
        RET
keyInv
        LEA R0 invalid
        PUTS
        BRnzp eKey
 

; This is the Vigenere subroutine:
; This is the encryption part that uses key[2] XOR message. We first store vigRet into R7. We then load the
; key into R6. Then load the second element of the key into R0, and load the ASCII value of 0 into R1. We
; then call the SUB subroutine to subtract the second element of the key from the ASCII value of 0 to check
; if the input for the second value of the key is 0. If it is indeed 0, then return. Else do the encryption. 
; We then initialize a counter for the loop. Inside the loop, we first call the XOR subroutine, which has R0 
; and R3 as the input and returns the output in R5. After returning from the subroutine, we store result(which is R5) 
; into R4(which is at x4000 from the encrypt subroutine). we then increment both R4(input) and R6(output) to move to the next address(x4001 for example) 
; and decrement the counter. The loop goes through all the elements in 'message' and stores the encrypted data back into message.
vigenere
        ST R7 vigRet
        LEA R1 key
        LDR R0 R1 #1
        LD R1 ASC0
        JSR SUB
        BRz VX
        AND R2 R2 #0
        ADD R2 R2 #10
vigLoop 
        LDR R3 R6 #0
        JSR XOR
        STR R5 R4 #0
        ADD R4 R4 #1
        ADD R6 R6 #1
        ADD R2 R2 #-1
        BRp vigLoop
VX      LD R7 vigRet
        RET
        
        
; This is the XOR subroutine. 
; This subroutine takes inputs R0 and R3 and does an XOR function. It then stores the result
; into R5.
XOR     NOT R5, R0              ; //R5 = !A
        NOT R1, R3              ; //R1 = !B
        AND R5, R5, R3          ; //R5 = !AB
        ;NOT R5, R5              ; //R5 = NOT(!AB)
        AND R1, R0, R1          ; // R1 = (A!B)
        ;NOT R1, R1              ; // R1 = NOT(A!B)
        ;AND R5, R5, R1          ; // R5 = NOT(!AB) AND NOT(A!B)
        ;NOT R5, R5              ; //// R5 = NOT(NOT(!AB) AND NOT(A!B)) = AXORB  
        ADD R5 R5 R1
        RET 
        
        
; This is the caeser subroutine:
; This subroutine does the ceaser cipher encryption of the message. We first store whatever is in R7
; into caeRet. Then call the getY subroutine(which adds up y1, y2, y3). After that, the helpCae subroutine 
; is called. and finally, we load whatever is in caeRet back into R7.
        
caeser
        ST R7 caeRet
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

; This is the helpCae subrotine     
; this subroutine acts as a helper to caeser. We first set the counter to 10(because thats the size of the message)
; We then load R1 with address of message. Then load a label called bit7. Then the subroutine goes into a loop that 
; first loads the first value of message into R3. We then add R0 to R3. And we add R5 which has bit7 to R3 which has the product
; After the computation of the modulo is finished, we store R3 into R1. Increment pointer, decrement counter.
helpCae
        AND R2 R2 #0
        ADD R2 R2 #10
        LD  R1 message
        LD  R5 bit7
caeLoop 
        LDR R3 R1 #0
        ADD R3 R3 R0
        AND R3 R3 R5
        STR R3 R1 #0
        ADD R1 R1 #1
        ADD R2 R2 #-1
        BRp caeLoop
        RET
        
        
        
        
;This is the getY subroutine:
; This is where the computation of the y values in the key is made. 
        
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
        
        ADD R1 R1 R3            ; R1 = (10*y1 + y2) 
        AND R0 R0 #0
        ADD R0 R0 #10
        ;LEA R4 goMult
        JSR Mult
        
        ADD R3 R2 #0            ; copy 10*(10*y1 + y2) to R3
        LDR R0 R6 #4
        LD R1 ASC0
        ;LEA R4 goSUB
        JSR SUB
        
        ADD R0 R1 R3            ; R0 = 10*(10*y1 + y2) + y3
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
                           
; This is the readN subroutine:
; This is where the reading of the inputs occurs. It takes in characters inputed, and stores
; R0(the input) into R6.
readN
        GETC
        STR R0 R6 #0
        ADD R6 R6 #1
        ADD R5 R5 #-1
        BRp readN
        RET

shift
    
    
    
    
    
        
unshift
        
        
        
        

.END