// This would generally be a wasteful push/pop using 16 bytes for everything,
// but it's fine for our purposes
.macro push, r
	str	\r, [sp, #-16]!
.endm

.macro pop, r
	ldr	\r, [sp], #16
.endm


# Pointer to message in x0
# Length of msg in x1
print_msg:
	push lr
    push x2

	mov x2, x1
	mov x1, x0
	mov	x0, STDOUT
	mov	X16, #4		// Unix write system call
	svc	#0x80		// Call kernel to output the string

    pop x2
	pop lr
	ret

// Will print a 16-bit number in w0 in hex
print_hex:
    push lr
    sub sp, sp, #(16)  // Make space for the hex string

    mov w2, w0

    // Print "0x"
    mov w3, #0x78   // "x"
    lsl w3, w3, 8
    and w3, w3, #0xFF00
    orr w3, w3, 0x30
    str w3, [sp]

    mov x0, sp
    mov x1, 2
    bl print_msg

    cmp w2, #0xFF
    b.lt print_hex_8bit

    // Upper 16 bits
    lsr w3, w2, 12
    and w3, w3, #0xF
    bl print_hex_conv_digit_to_ascii
    str w3, [sp]

    mov x0, sp
    mov x1, 1
    bl print_msg

    lsr w3, w2, 8
    and w3, w3, #0xF
    bl print_hex_conv_digit_to_ascii
    str w3, [sp]

    mov x0, sp
    mov x1, 1
    bl print_msg

print_hex_8bit:
    lsr w3, w2, 4
    and w3, w3, #0xF
    bl print_hex_conv_digit_to_ascii
    str w3, [sp]

    mov x0, sp
    mov x1, 1
    bl print_msg

    mov w3, w2
    and w3, w3, #0xF
    bl print_hex_conv_digit_to_ascii
    str w3, [sp]

    mov x0, sp
    mov x1, 1
    bl print_msg

    add sp, sp, #(16)
    pop lr
    ret

print_hex_conv_digit_to_ascii:
    // Only call this within print_hex! Otherwise your registers will be corrupted
    // Expects digit in w3. Expects in range 1-15
    mov w4, #0xA
    cmp w3, w4
    b.lt print_hex_conv_digit_to_ascii_end
    add w3, w3, #7
print_hex_conv_digit_to_ascii_end:
    add w3, w3, 0x30
    ret


print_new_line:
    push lr
    mov w0, #'\n'
    bl print_char_w0
    pop lr
    ret


print_char_w0:
    push lr
    sub sp, sp, #(16)
    mov w3, w0
    str w3, [sp]

    mov x0, sp
    mov x1, 1
    bl print_msg
    add sp, sp, #(16)
    pop lr
    ret

// Expects x0 to point at ASCII input data
// Only handles unsigned integers
// On return:
//   x0 will be updated to point at the first char after the decimal
//   w1 will contain the number read
consume_decimal:
        // addi    t0, x0, 0
        mov x9, #0
        
        // addi    t2, x0, 0x30      # ASCII digits start/end
        // addi    t3, x0, 0x39
        // addi    t4, x0, 10      # Decimal multiple
        mov x11, #10
consume_decimal_loop:
        // lb      t1, 0(a0)       # Read next digit
        ldrb w10, [x0]
        
        // End if the digit is not ascii
        // bltu    t1, t2, consume_decimal_end
        cmp x10, #0x30
        b.lt consume_decimal_end

        // bgtu    t1, t3, consume_decimal_end
        cmp x10, #0x39
        b.gt consume_decimal_end

        // addi    t1, t1, -0x30   # ASCII digit -> Decimal digit
        sub x10, x10, 0x30  // ASCII digit -> Decimal digit

        # Add to our existing number, which get *10 first
        // mul     t0, t0, t4
        mul x9, x9, x11     // x9 * 10
        // add     t0, t0, t1
        add x9, x9, x10

        // addi    a0, a0, 1
        add x0, x0, #1
        b consume_decimal_loop

consume_decimal_end:
        // addi    a1, t0, 0
        mov w1, w9
        ret