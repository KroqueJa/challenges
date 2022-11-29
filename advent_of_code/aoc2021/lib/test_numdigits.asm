%include  'mathlib.asm'
%include  'iolib.asm'

          section .text
          global _start

_start:
          pop       rcx
          pop       rdi
          pop       rdi

          call      atou
          mov       rdi, rax
          call      numdigits
          mov       rdi, rax
          call      uprintln
          call      exit_0
