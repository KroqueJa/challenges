%include 'print.asm'

; the monkey struct:
; Byte id (+0) [number of the monkey]
; Byte op (+1) [either a number or 's' for "square]
; Byte test (+2)
; Byte true (+3)
; Byte false (+4)
; Qword items (+5) [pointer to linked list with items]

; macros
          SYS_READ      equ 0
          STDOUT        equ 1
          SYS_OPEN      equ 2
          O_RDONLY      equ 0
          SYS_EXIT      equ 60
          SYS_WRITE     equ 1
          NEWLINE       equ 10
          SYS_CLOSE     equ 3
          FSIZE         equ 1500

          MONKE_ID      equ 0
          MONKE_OP      equ 1
          MONKE_TEST    equ 2
          MONKE_TRUE    equ 3
          MONKE_FALSE   equ 4
          MONKE_ITEMS   equ 5

          section   .data

test_str:
          db '49, 543, 11, 1, 612', 0xA

          section   .bss

file_buf:
          resb      FSIZE

bytes_read:
          resq      1

          section   .text
          global    _start

_start:

io:
; read the filename from the command line
          pop       rcx
          pop       rsi
          pop       rsi

; read the file
          mov       rdi, file_buf
          mov       rdx, FSIZE
          call      read_file
          mov       Qword [bytes_read], rax

init:


          mov       rax, SYS_EXIT
          mov       rdi, 0x0
          syscall

; ===================================================================
; function to create a linked list from a string in rdi (including malloc)
; returns the head to the linked list
parse_items:

          ret

; ===================================================================
; function to open a file
; inputs
; rdi: buffer wherein to put the file contents
; rsi: pointer to file name
; rdx: bytes to read
; outputs
; rax: number of bytes read
read_file:

          push        rdi
          push        rsi
          push        rdx

          push        rdi

; open the input file
          mov         rdi, rsi
          mov         rax, SYS_OPEN
          mov         rsi, O_RDONLY
          mov         rdx, 0644o
          syscall

; read the file into the file_buffer
          mov         rdi, rax
          mov         rax, SYS_READ
          pop         rsi
          syscall

          push        rax

; close the file
          mov         rax, SYS_CLOSE
          syscall

          pop         rax
          pop         rdx
          pop         rsi
          pop         rdi
          ret
