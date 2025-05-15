; Name: Hung Do
; Date: 20250515
; Affiliation : University of Maryland, Baltimore County
; Email: hungd1@umbc.edu

; CMSC313 - HW#11
; Description: This program will take a number of bytes of data and print that data to the screen.
; Specifically, it will translate data from a list of raw hexadecimal byte representations to ACII characters for display.
; *EXTRA CREDIT* This operation will be done with the help of a subroutine

; ********************************************************************************************************
section .data
    ; Constants
    inputBuf:                       ; buffer to hold input
        db  0x83,0x6A,0x88,0xDE,0x9A,0xC3,0x54,0x9A
    len equ $ - inputBuf            ; length of inputBuf
    hexDigits db '0123456789ABCDEF' ; Lookup table for hexadecimal digits

; ********************************************************************************************************
section .bss
    outputBuf:                      ; buffer to hold output
        resb 80                     ; reserve 80 bytes for output

; ********************************************************************************************************
section .text
    global _start

    _start: 
        ; ****************************************************
        ; Set up pointers
        ; ****************************************************
        mov esi, inputBuf           ; input pointer - start of inputBuf
        mov edi, outputBuf          ; output pointer - start of outputBuf
        
        ; ****************************************************
        ; Loop through and translate each hex value
        ; ****************************************************
        call _BuildOutput           ; call the function to build the output
        
        ; ****************************************************
        ; Write the output to the stdout file
        ; ****************************************************
        ; Calculate output length
        mov edx, len                ; number of bytes to write
        mov eax, 3                  ; 3 characters per byte
        mul edx                     ; eax = len * 3
        mov edx, eax                ; edx = total output length

        mov eax,4                   ; sys_write system call
        mov ebx,1                   ; stdout
        mov ecx,outputBuf           ; output pointer
        int     80h                 ; call kernal
        
        ; ****************************************************
        ; End program
        ; ****************************************************
        mov     ebx, 0              ; return 0 status on exit - 'No Errors'
        mov     eax, 1              ; invoke SYS_EXIT (kernel opcode 1)
        int     80h                 ; call kernal
    ; ********************************************************//end of _start
    
    ; ********************************************************
    ; This function will loop through the input buffer

    ; Each byte is processed in 4 bit chunks
    ; A 4 chunk bit is converted from binary hex to ASCII hex
    
    ; Steps:
    ;   - the leading 4 bits are translated first
    ;   - the trailing 4 bits are translated second
    ;   - each result is then written to the output buffer 
    ;   - a space is written between every pair

    ; Function returns when the counter, ecx, reaches 0
    ; ********************************************************
    _BuildOutput:
        mov ecx, len                    ; loop counter - number of bytes to process
        .loop:
            ; ****************************************************
            ; Load the current byte into edx
            ; ****************************************************
            movzx edx, byte [esi]       ; grab next byte
            inc esi                     ; increment input pointer

            ; ****************************************************
            ; Convert XXXX---- bits of the current byte to ASCII
            ; ****************************************************
            mov eax, edx                ; copy current byte to eax
            shr eax, 4                  ; shift right to get leading 4 bits
            mov al, [hexDigits + eax]   ; search for the 4 bit value in the hex digit table
            stosb                       ; store the result in the output buffer

            ; ****************************************************
            ; Convert ----XXXX bits of the current byte to ASCII
            ; ****************************************************
            mov eax, edx                ; copy current byte to eax
            and eax, 0fh                ; mask off leading 4 bits
            mov al, [hexDigits + eax]   ; search for the 4 bit value in the hex digit table
            stosb                       ; store the result in the output buffer

            ; ****************************************************
            ; Write a space to the output buffer
            ; ****************************************************
            mov al, ' '
            stosb

            ; ****************************************************
            ; Check if there are still bytes to process:
            ;   - continue looping if there are
            ;   - exit the loop if there are not
            ; ****************************************************
            dec ecx
            jnz .loop  
            
            ; ****************************************************
            ; Exit the loop
            ; ****************************************************
            ; overwrite the last space with a new line character
            dec edi         ; move back to overwrite the last space
            mov al, 0x0A    ; newline character
            stosb

            ret                         ; exit the function
    ; ********************************************************//end of _BuildOutput