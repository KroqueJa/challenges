        %include 'functions.asm'

        section .data

; define some useful macros to make the code more understandable
        SYS_READ equ 0
        STDOUT equ 1
        SYS_OPEN equ 2
        O_RDONLY equ 0
        SYS_EXIT equ 60
        SYS_WRITE equ 1
        NEWLINE equ 10
        SYS_CLOSE equ 3

        FSIZE equ 2000000                 ; define the approximate size of the file we're reading

; define an error message to print if a filename isn't passed
err_msg_argc:
        db 'Wrong number of arguments - exiting', 0x0

        section .bss

        fd_in resd 1                    ; reserve one word for the file descriptor
        file_buf resb FSIZE             ; we'll make it easy on ourselves and read the whole file into a file_buffer
        numbers resw 2000000            ; reserve 2 Mb for numbers

        section .text
        global _start

_start:

; get command line argument (name of input file)
        pop rcx                         ; get number of arguments (including name of program)
        cmp rcx, 2
        jne err_argc                    ; we have the wrong number of args - exit
        pop rdi                         ; skip the name of the program
        pop rdi

; open the input file
        mov rax, SYS_OPEN
        mov rsi, O_RDONLY               ; set the read-only flag
        mov rdx, 0644o                  ; permissions are a mystery to me

        syscall                         ; after this syscall, the file address is in rax

; read the file into the file_buffer
        mov rdi, rax
        mov rax, SYS_READ
        mov rsi, file_buf
        mov rdx, FSIZE
        syscall

        mov r8, rax                     ; rax holds the number of bytes read from the file; we keep track of this in r8

        mov rax, SYS_CLOSE
        syscall                         ; dutifully close the file

; --- parse the numbers into the numbers array ---
        mov r9, file_buf                ; set r9 to iterate over the chars in the file buffer
        mov r10, numbers                ; initialize r10 to point at the start of the numbers array
        xor r11, r11                    ; zero out r11
        xor r12, r12                    ; and r12, which will keep count of how many numbers we've read
        mov rdi, 10
read_num:                               ; loop to read digits and parse them to integers

        mov r11b, Byte [r9]             ; read a byte into r11b

        dec r8                          ; decrease the number of bytes left to read
        cmp r8, 0                       ; are we done?
        je solve_problem                ; if we are, jump forward to the next part of the program
        cmp r11b, NEWLINE               ; we are not; check if the char was a newline
        je  .write_number               ; if it was, jump to the next number
        sub r11b, 48                    ; subtract 48 from the byte to get its number value from ASCII

        mov ax, Word [r10]
        mul rdi                         ; multiply the current number in the numbers array by 10
        mov Word [r10], ax
        add Word [r10], r11w            ; add the read digit to the current number
        jmp .next_digit                 ; jump to the next_digit logic

.write_number:
        add r10, 2                      ; move the numbers pointer one Word forward
        inc r12                         ; increase numbers counter
.next_digit:
        inc r9                          ; increment the pointer to the file buffer
        jmp read_num                    ; read the next number

solve_problem:
        mov r10, numbers                ; set r10 to the beginning of the numbers array
        xor rdi, rdi                    ; zero rdi, which will contain our answer

        mov r11w, Word [r10]            ; read the first number
        dec r12                         ; decrease number counter
        add r10, 2                      ; move up the number array

.loop:
        xor r9, r9
        mov r9w, Word [r10]
        cmp r9, r11                     ; compare the current number to the previous one
        jle .move_ahead                 ; if less or equal, just move on
        inc rdi                         ; otherwise, count a number before moving ahead

.move_ahead:
        cmp r12, 0
        je  done
        mov r11w, Word [r10]
        dec r12
        add r10, 2
        jmp .loop

done:
        call  iprintln                  ; print the solution, which is already in rdi

exit:
        mov rdi, 0
        mov rax, SYS_EXIT
        syscall

err_argc:
        mov rdi, err_msg_argc
        call sprintln
        mov rdi, 255
        mov rax, SYS_EXIT
        syscall

