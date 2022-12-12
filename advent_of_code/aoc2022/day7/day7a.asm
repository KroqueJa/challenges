%include 'print.asm'

; the spec for a directory is
; name            | 8 Bytes
; parent_ptr      | 1 Qword
; sum             | 1 Qword
; ls              | 1 Byte
; = 25 bytes in total


; macros
          SYS_READ      equ 0
          STDOUT        equ 1
          SYS_OPEN      equ 2
          O_RDONLY      equ 0
          SYS_EXIT      equ 60
          SYS_WRITE     equ 1
          NEWLINE       equ 10
          SYS_CLOSE     equ 3
          FSIZE         equ 11500

          PARENT        equ 8
          SUM           equ 16
          LS            equ 24

          DIR_SZ        equ 25

          section   .bss

file_buf:
          resb      FSIZE

string_buf:
          resb      9

dirs:
          resq      500

pwd:
          resq      1                               ; index of the current directory

bytes_read:
          resq      1

          section   .text
          global    _start

_start:

; read the filename from the command line
          pop       rcx
          pop       rdi
          pop       rdi

; open the input file
          mov       rax, SYS_OPEN
          mov       rsi, O_RDONLY
          mov       rdx, 0644o
          syscall

; read the file into the file_buffer
          mov       rdi, rax
          mov       rax, SYS_READ
          mov       rsi, file_buf
          mov       rdx, FSIZE
          syscall

; store the amount of bytes read
          mov       [bytes_read], rax

; close the file
          mov       rax, SYS_CLOSE
          syscall

; === solve the problem ===

; move the file buffer into rdi

init:
          mov       rdi, file_buf
          add       rdi, 0x7                        ; skip the first line of input
          xor       rbx, rbx                        ; ls in progress flag
          mov       Qword [pwd], dirs               ; set the current directory to be the root

; we don't need to name the root directory, nor does it have a parent

; the below loop will handle all lines
; lines beginning with '$' set or unset an "ls in progress flag" that we store in rbx for the duration (ls sets it, cd unsets it)
; any lines not beginning with '$' are inside an ls and will either increase a sum or create a new directory in the memory space

          mov       r14, 0
parse:
          inc       r14
          cmp       Byte [rdi], 0x24                ; '$'
          je        command
          cmp       Byte [rdi], 0x64                ; 'd'
          je        new_dir

; gather some bytes for the sum of the pwd ====================================
bytes:
          xor       rax, rax
          xor       rdx, rdx
          mov       rcx, 0xA

bytes_atoi:
          mul       rcx
          mov       dl, Byte [rdi]
          add       rax, rdx
          sub       rax, 0x30
          inc       rdi
          cmp       Byte [rdi], 0x20                ; space
          jne       bytes_atoi

          mov       rsi, [pwd]
          mov       rcx, [rsi + SUM]
          add       rcx, rax
          mov       Qword [rsi + SUM], rax
          jmp       next_line

; a command was passed, either ls or cd =======================================
command:
          cmp       Byte [rdi+2], 0x6c              ; 'l'
          je        ls

; change the current directory ================================================
cd:
; regardless of anything else, this command means that an ls is no longer in progress
          mov       rbx, 0x0

; check if we're going up or down
          cmp       Byte [rdi + 5], 0x2e            ; '.'
          je        cd_dot_dot

; find the directory in memory (we know it's there as there are no erroneous commands in the input)
; read the target directory into our string buffer
          add       rdi, 5                          ; skip ahead to the dir name
          push      rdi                             ; safekeep rdi, we want to use it for movsb
          xor       rcx, rcx

cd_count_loop:
          inc       rcx
          cmp       Byte [rdi + rcx], 0xA           ; '\n'
          jne       cd_count_loop

          push      rcx                             ; save rcx, we want it for two things
cd_cpy_to_string_buf:
; rcx now contains the offset of the newline, and therefore the amount of bytes to copy
; switch rdi over to rsi for movsb, and put the string buffer in rdi
          push      rdi
          mov       rdi, string_buf
          pop       rsi
          rep       movsb

          pop       rdx
; now we have copied the destination string into the string buffer, and can start to compare it to the different strings in our memory space
          mov       rdi, string_buf
          mov       rsi, [pwd]
cd_find_loop:
          add       rsi, DIR_SZ
          call      streq8
          cmp       rax, 0x1
          jne       cd_find_loop

; we've found our target directory in the memory space, set it to be pwd
          mov       [pwd], rsi

          pop       rdi                             ; rdi once more contains the first byte of the target name
          jmp       next_line
cd_dot_dot:
          mov       rsi, [pwd + PARENT]
          mov       [pwd], rsi
          jmp       next_line

; ls handles the ls in progress flag mainly ===================================
ls:
; since ls can be called twice in a row, it is important to check whether an ls is already in progress and in that case just set this directory as ls:d
          cmp       Byte [pwd + LS], 0x1
          je        ls_skip_loop                    ; if the directory has already been ls:d, we can just skip a bunch of lines

          cmp       rbx, 0x1                        ; is an ls already in progress?
          jne       ls_single                       ; if not, this is an "honest" ls

          mov       Byte [rsi + LS], 0x1            ; set ls as done on pwd as this is the second one in a row
ls_skip_loop:
          inc       rdi
          cmp       Byte [rdi], 0x24                ; '$'
          jne       ls_skip_loop
          jmp       command                         ; we already know we found a command, so we don't even need to jump to 'parse'

ls_single:
          mov       rbx, 0x1                        ; an ls is now in progress
          jmp       next_line                       ; find the next line of input

new_dir:
; the line of input specifies the creation of a new directory
          mov       rsi, dirs

; find empty memory space
new_dir_find_loop:
          add       rsi, DIR_SZ
          cmp       Byte [rsi], 0x0
          jne       new_dir_find_loop

; we've found an empty space; put the name of the new directory here (the name is the first field in the spec)
          add       rdi, 0x4
          xor       rax, rax
          xor       rcx, rcx

new_dir_count:
          inc       rcx
          cmp       Byte [rdi + rcx], 0xA
          jne       new_dir_count

          mov       rax, 0x8
          sub       rax, rcx
          mov       rcx, 0x8
          mul       rcx                               ; rax now contains the amount of bytes to clear from the end of the string
          mov       rcx, rax

          mov       rax, Qword [rdi]
          shl       rax, cl
          shr       rax, cl
          mov       Qword [rsi], rax                  ; since the dir name is at most 8 bytes we can just move a Qword... mind *blown*

          mov       rax, [pwd]
          mov       Qword [rsi + PARENT], rax         ; set the current directory as the parent of the new one

; we've done something, move to the next line of input ========================
next_line:
          inc       rdi
          cmp       Byte [rdi-1], 0xA                 ; '\n'
          jne       next_line
          mov       rax, rdi
          sub       rax, file_buf
          cmp       rax, Qword [bytes_read]
          jl        parse

; we've parsed all the commands ===============================================
parse_done:

; DEBUG: print all sums
          xor       rcx, rcx
          mov       rax, dirs
          mov       rdi, [rax + SUM]
          call      uprintln

; exit the program
          mov       rax, SYS_EXIT
          mov       rdi, 0
          syscall

; ============================================================================
; function to check if the null-terminated 8 byte strings pointed at by rdi and rsi are the same
; their length is found in rdx
streq8:
          push      rdi
          push      rsi
          push      rcx

          xor       rcx, rcx
          xor       rax, rax

; whatever is left in rdx is how many bytes we need to clear at the end of rsi and rdi
          mov       rax, rdx
          mov       rcx, 0x8
          mul       rcx
          mov       rcx, rax

          mov       r8, Qword [rsi]
          mov       r9, Qword [rdi]

; now we have the amount of bits to clear instead - shift them left then right (little endian) to clear them
          shl       r8, cl
          shr       r8, cl
          shl       r9, cl
          shr       r9, cl

          cmp       r8, r9
          je        .true
.false:
          xor       rax, rax

          pop       rcx
          pop       rsi
          pop       rdi
          ret

.true:
          mov       rax, 0x1
          pop       rcx
          pop       rsi
          pop       rdi
          ret

