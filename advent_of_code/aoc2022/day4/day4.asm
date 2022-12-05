%include  'print.asm'
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

          section   .bss
file_buf:
          resb      FSIZE

bytes_read:
          resq      1

bytes_processed:
          resq      1

sum:
          resq      1

partial_sum:
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

; save the amount of bytes read
          mov       Qword [bytes_read], rax
          mov       rdi, rax
; close the file
          mov       rax, SYS_CLOSE
          syscall

; solve the problem

loop:
          mov       rdi, file_buf
          mov       rsi, [bytes_processed]

          call      parse_line                          ; after this function, four numbers should be in rax-rdx

          mov       Qword [bytes_processed], r8         ; after parsing the previous line, record how many bytes have now been processed
          call      fully_contained                     ; checks whether the interval [rdx-rcx] is fully contained in [rbx-rax]
          add       Qword [sum], rdi                    ; add 0 or 1 to the sought sum

          call      partially_contained
          add       Qword [partial_sum], rdi

          mov       rdi, [bytes_processed]
          cmp       rdi, Qword [bytes_read]
          jne       loop

; print the sum
          mov       rdi, Qword [sum]
          call      uprintln

          mov       rdi, Qword [partial_sum]
          call      uprintln

; exit the program
          mov       rax, SYS_EXIT
          mov       rdi, 0
          syscall

; function to check whether [rdx-rcx] is fully contained inside [rbx-rax] or vice versa
; stores the result in rdi
fully_contained:
          xor       rdi, rdi

.check_first:
          cmp       rdx, rbx
          jge       .check_first_right
          jmp       .check_second

.check_first_right:
          cmp       rcx, rax
          jle       .true

.check_second:
          cmp       rbx, rdx
          jge       .check_second_right
          jmp       .false

.check_second_right:
          cmp       rax, rcx
          jle       .true
          jmp       .false

.true:
          inc       rdi
.false:
          ret

; function to check whether [rdx-rcx] is partially contained inside [rbx-rax] or vice versa
; this is the same as checking whether they are not disjunct
; (rdx >= rbx && rdx <= rax) || (rcx >= rbx && rcx <= rax)
partially_contained:
          mov       r8, rdx
          mov       r9, rcx
          mov       r10, rbx
          mov       r11, rax

          mov       rdi, r8
          mov       rcx, r10
          mov       rdx, r11
          call      is_within
          cmp       rax, 1
          je        .true
          mov       rdi, r9
          mov       rcx, r10
          mov       rax, r11
          call      is_within
          cmp       rax, 1
          je        .true
          mov       rdi, r10
          mov       rcx, r8
          mov       rdx, r9
          call      is_within
          cmp       rax, 1
          je        .true
          mov       rdi, r11
          mov       rcx, r8
          mov       rdx, r9
          call      is_within
          jne       .false
.true:
          mov       rdi, 1
          ret
.false:
          mov       rdi, 0
          ret

; function to check whether rdi is in [rcx, rdx]
is_within:
          xor     rax, rax
          cmp     rdi, rcx
          jl     .false
.check_second:
          cmp     rdi, rdx
          jg      .false
.true:
          inc     rax
.false:
          ret


; function to parse four numbers from a line of input
parse_line:
          xor       rax, rax
          xor       rcx, rcx
          mov       r10, 10
          mov       r8, rsi                              ; line iterator, starts at file offset

.parse_loop:
          mul       r10                                 ; multiply current number by 10
          add       al, Byte [rdi + r8]                 ; get the next byte
          sub       rax, 48                             ; from ASCII
          inc       r8
          cmp       Byte [rdi + r8], 44                 ; ','
          je        .parse_done
          cmp       Byte [rdi + r8], 45                 ; '-'
          je        .parse_done
          cmp       Byte [rdi + r8], NEWLINE
          je        .line_done
          jmp       .parse_loop
.parse_done:
          push      rax                                 ; push parsed number to the stack
          inc       r8
          xor       rax, rax
          jmp       .parse_loop
.line_done:
          inc       r8                                  ;  increment r8 so it contains the number of processed bytes
          pop       rbx
          pop       rcx
          pop       rdx
          ret
