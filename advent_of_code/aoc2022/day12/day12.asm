%include 'print.asm'

extern malloc, free

; macros
          SYS_READ        equ 0
          STDOUT          equ 1
          STDERR          equ 2
          SYS_OPEN        equ 2
          SYS_STAT        equ 4
          O_RDONLY        equ 0
          SYS_EXIT        equ 60
          SYS_WRITE       equ 1
          SYS_CLOSE       equ 3

          ERRCODE_FSIZE   equ 100
          ERRCODE_FEXISTS equ 200
          ERRCODE_ARGS    equ 300
          ERRCODE_WIDTH   equ 400

          GRID_SZ         equ 3000
          MAX_LINE_W      equ 256
          UINT_MAX        equ 4294967295

          section   .data
err_fsize_msg:
          db        'Error: input file too large', 0xA, 0x0

err_fexists_msg:
          db        'Error: file does not exist', 0xA, 0x0

err_args_msg:
          db        'Error: exactly one input argument should be provided', 0xA, 0x0

err_width_msg:
          db        'Error: the lines of the input are too wide', 0xA, 0x0


          section   .bss
input_buf:
          resb      MAX_LINE_W

bytes_read:
          resq      1

width:
          resq      1

height:
          resq      1

checked:
          resq      1

grid:
          resq      1

stat_buf:
          resq      15


          section   .text
          global    _start

_start:

; check that the correct number of arguments (1) was provided
          pop         rcx
          cmp         rcx, 0x2
          jne         err_args

; read the filename from the command line
          pop         rdi
          pop         rdi
          mov         r14, rdi                        ; put the file name in r14

; find the file size
          mov         rax, SYS_STAT
          mov         rsi, stat_buf
          syscall                                     ; the file size is now in stat_buf + 48 - it is 0 if the file failed to open

; exit if the file doesn't exist
          cmp         Qword [stat_buf + 0x30], 0x0
          je          err_fexists

; open the input file
          mov         rax, SYS_OPEN
          mov         rsi, O_RDONLY
          mov         rdx, 0644o
          syscall

; read MAX_LINE_W bytes from the input file and scan the chunk for a newline
          mov         rdi, rax
          mov         r15, rax                        ; r15 is the file descriptor
          mov         rax, SYS_READ
          mov         rsi, input_buf
          mov         rdx, MAX_LINE_W
          syscall

          xor         rcx, rcx
find_width:
          inc         rcx
          cmp         Byte [input_buf + rcx], 0xa
          jne         find_width

          cmp         rcx, 0x100
          jg          err_width

          mov         Qword [width], rcx

; find the height of the grid by dividing the file size with the width
find_height:
          mov         rax, Qword [stat_buf + 0x30]
          xor         rdx, rdx
          mov         rbx, Qword [width]
          inc         rbx
          div         rbx

          mov         Qword [height], rbx

; allocate memory for the grid
          mov         rdi, Qword [stat_buf + 0x30]
          call        malloc
          mov         Qword [grid], rax

read:
; close and reopen the file
          mov         rax, SYS_CLOSE
          mov         rdi, r15
          syscall

          mov         rax, SYS_OPEN
          mov         rsi, O_RDONLY
          mov         rdx, 0644o
          mov         rdi, r14
          syscall

          mov         r13, Qword [height]
; read width bytes height times into grid
          mov         rdi, rax
          mov         rsi, grid
          mov         rax, SYS_READ
          mov         rdx, width



close_file:
; close the file
          mov         rax, SYS_CLOSE
          pop         rdi 
          syscall

; === Solve the problem ===




; free memory
          mov       rdi, Qword [grid]
          call      free

; exit the program
          mov       rax, SYS_EXIT
          mov       rdi, 0x0
          syscall

err_width:
          mov       rax, SYS_WRITE
          mov       rdi, STDERR
          mov       rsi, err_width_msg
          mov       rdx, 0x2b
          syscall

          mov       rax, SYS_EXIT
          mov       rdi, ERRCODE_WIDTH
          syscall
err_args:
          mov       rax, SYS_WRITE
          mov       rdi, STDERR
          mov       rsi, err_args_msg
          mov       rdx, 0x35
          syscall

          mov       rax, SYS_EXIT
          mov       rdi, ERRCODE_ARGS
          syscall

err_fsize:
          mov       rax, SYS_WRITE
          mov       rdi, STDERR
          mov       rsi, err_fsize_msg
          mov       rdx, 0x1c
          syscall

          mov       rax, SYS_EXIT
          mov       rdi, ERRCODE_FSIZE
          syscall

err_fexists:

          mov       rax, SYS_WRITE
          mov       rdi, STDERR
          mov       rsi, err_fexists_msg
          mov       rdx, 0x1b
          syscall

          mov       rax, SYS_EXIT
          mov       rdi, ERRCODE_FEXISTS
          syscall

; ===================================================================
; function to solve a maze


