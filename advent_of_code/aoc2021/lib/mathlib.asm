
; function to calculate the number of digits in an unsigned integer
numdigits:
          push      rcx
          push      rdx
          push      rsi

          xor       rcx, rcx
          mov       rax, rdi
.div_loop:
          inc       rcx
          mov       rsi, 0xA
          xor       rdx, rdx
          idiv      rsi
          cmp       rax, 0
          jnz       .div_loop
          mov       rax, rcx

          pop       rsi
          pop       rdx
          pop       rcx
          ret
