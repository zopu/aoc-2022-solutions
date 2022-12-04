.option pic
.global _start

.equ STDIN, 0
.equ STDOUT, 1
.equ INPUT_TXT_SIZE, 11419
.equ INPUT_SM_TXT_SIZE, 47

.macro push reg
        addi    sp, sp, -4
        sw      \reg, 0(sp)
.endm

.macro pop reg
        lw      \reg, 0(sp)
        addi    sp, sp, 4
.endm

.include "utils.s"

_start:
        la      a0, input_txt

main_loop:
        # iff next char (a0) is '$'
        # jump to end
        li      t0, '$'
        lb      t1, 0(a0)
        beq     t0, t1, main_loop_end;

        call     read_input_line

        push    a0     # Save read ptr

        call    detect_overlap
        # la      a1, temp
        # jal     print_hex
        # jal     print_new_line

        # update the sum
        la      a2, sum
        lw      a1, 0(a2)
        add    a1, a0, a1
        sw      a1, 0(a2)

        pop     a0
        j       main_loop

main_loop_end:
        la      a2, sum
        lw      a0, 0(a2)
        la      a1, temp
        jal     print_hex
        
        addi    a0, x0, 0
        addi    a7, x0, 93      # exit
        ecall


# Expects a0 to point at input data
# On return:
#   a0 will point at the new input data location
#   a1 through a4 will point at the input numbers read
read_input_line:
        push ra
        # consume a decimal
        # push to stack
        call    consume_decimal
        push    a1

        # consume a hyphen
        addi    a0, a0, 1

        # consume a decimal
        # push to stack
        call    consume_decimal
        push    a1

        # consume a comma
        addi    a0, a0, 1

        # consume a decimal
        # push to stack
        call    consume_decimal
        push    a1

        # consume a hyphen
        addi    a0, a0, 1

        # consume finak decimal
        # and just move it to a4
        call    consume_decimal
        addi    a4, a1, 0

        # consume the \n
        addi    a0, a0, 1

read_input_line_end:
        # pop numbers from the stack into return registers
        pop     a3
        pop     a2
        pop     a1

        pop ra
        ret


# Expects two ranges of uints
# one a1-a2, one a3-a4
# Returns in a0
#   1 if there one contains the other.
#   0 otherwise
detect_contains:
        # Call a1-a2 "A" and a3-a4 "B"
        beq     a1, a3, detect_contains_true
        beq     a2, a4, detect_contains_true
        bgeu    a1, a3, detect_contains_maybe_b_contains_a
        # a1 < a3 so now maybe a contains b
        bgeu    a2, a4, detect_contains_true
        j       detect_contains_false
detect_contains_maybe_b_contains_a:
        # a1 >= a3
        bgeu    a4, a2, detect_contains_true
        # Finally check if they're identical
detect_contains_false:
        li      a0, 0
        ret
detect_contains_true:
        li      a0, 1
        ret


# Expects two ranges of uints
# one a1-a2, one a3-a4
# Returns in a0
#   1 if there one overlaps the other.
#   0 otherwise
detect_overlap:
        # Overlaps if a3 <= a2 <= a4
        # or a3 <= a1 <= a4
        # Call a1-a2 "A" and a3-a4 "B"
        bltu    a2, a3, detect_overlap_false
        bgtu    a1, a4, detect_overlap_false
detect_overlap_true:
        li      a0, 1
        ret
detect_overlap_false:
        li      a0, 0
        ret


.data
sum:
        .space 4, 0
temp:
        .space 8, 0
input_txt:
        .incbin "input.txt"
input_txt_endmarker:
        .ascii "$"

input_sm_txt:
.incbin "input_sm.txt"
input_sm_txt_endmarker:
        .ascii "$"

hex_chars:
        .ascii "0x"
new_line_char:
        .ascii "\n"
