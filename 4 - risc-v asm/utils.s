# Utility functions


# Expects a0 to point at ASCII input data
# Only handles unsigned integers
# On return:
#   a0 will be updated to point at the first char after the decimal
#   a1 will contain the number read
consume_decimal:
        addi    t0, x0, 0
        addi    t2, x0, 0x30      # ASCII digits start/end
        addi    t3, x0, 0x39
        addi    t4, x0, 10      # Decimal multiple
consume_decimal_loop:
        lb      t1, 0(a0)       # Read next digit
        # End if the digit is not ascii
        bltu    t1, t2, consume_decimal_end
        bgtu    t1, t3, consume_decimal_end
        addi    t1, t1, -0x30   # ASCII digit -> Decimal digit

        # Add to our existing number, which get *10 first
        mul     t0, t0, t4
        add     t0, t0, t1

        addi    a0, a0, 1
        j consume_decimal_loop

consume_decimal_end:
        addi    a1, t0, 0
        ret


# Expects:
#   a0 to contain number to print
#   a1 to contain 8 byte buffer address
# Returns
#   memory at a1 will contain ASCII hex val
print_hex:
        push    ra

        # Print "0x"
        push    a0
        push    a1
        la      a1, hex_chars
        addi    a0, x0, 0
        addi    a0, x0, STDOUT
        addi    a2, x0, 2       # Number of chars
        addi    a7, x0, 64      # Write
        ecall
        pop     a1
        pop     a0

        # zero out the return memory
        li      t0, 0
        sw      t0, 0(a1)
        sw      t0, 4(a1)

        # iff 8 bit, skip ahead
        li      t0, 0x100
        bltu    a0, t0, print_hex_8bit

        sra     t0, a0, 28
        and     t0, t0, 0xF
        addi    t0, t0, 0x30
        sb      t0, 0(a1)
        sra     t0, a0, 24
        and     t0, t0, 0xF
        addi    t0, t0, 0x30
        sb      t0, 1(a1)
        sra     t0, a0, 20
        and     t0, t0, 0xF
        addi    t0, t0, 0x30
        sb      t0, 2(a1)
        sra     t0, a0, 16
        and     t0, t0, 0xF
        addi    t0, t0, 0x30
        sb      t0, 3(a1)
        sra     t0, a0, 12
        and     t0, t0, 0xF
        addi    t0, t0, 0x30
        sb      t0, 4(a1)
        sra     t0, a0, 8
        and     t0, t0, 0xF
        addi    t0, t0, 0x30
        sb      t0, 5(a1)
print_hex_8bit:
        sra     t0, a0, 4
        and     t0, t0, 0xF
        addi    t0, t0, 0x30
        sb      t0, 6(a1)
        sra     t0, a0, 0
        and     t0, t0, 0xF
        call print_hex_conv_digit_to_ascii
        sb      t0, 7(a1)

        # Now print what's in temp
        addi    a0, x0, 0
        addi    a0, x0, STDOUT

        addi    a2, x0, 8       # Number of chars
        addi    a7, x0, 64      # Write
        ecall

        pop     ra
        ret

print_hex_conv_digit_to_ascii:
        # Only call this within print_hex! Otherwise your registers will be corrupted
        # Expects digit in t0. Expects in range 1-15
        li      t1, 0xA
        bltu    t0, t1, print_hex_conv_digit_to_ascii_end
        addi    t0, t0, 7
print_hex_conv_digit_to_ascii_end:
        addi    t0, t0, 0x30
        ret


print_new_line:
        # Now print what's in temp
        addi    a0, x0, 0
        addi    a0, x0, STDOUT

        la      a1, new_line_char

        addi    a2, x0, 1       # Number of chars
        addi    a7, x0, 64      # Write
        ecall
        ret
