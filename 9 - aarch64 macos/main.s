// Iterate through the input and work out where the head is
.global _main
.align 2
.equ STDOUT, 1
.equ GRID_SIZE_X, 1000
.text

.include "utils.s"
.include "move_tail.s"

_main:
	// Rope positions are initialized in the fill directive
	// where the space is defined

	bl count_tail_grid_hits
	bl print_hex

	adrp x0, input@PAGE
    add x0, x0, input@PAGEOFF
	mov x2, #0  // Line count

_main_loop_start:
	ldrb    w1, [x0]
	cmp w1, '$'
	beq _main_end

	push w2
	bl read_line		// Will update x0. Dir in w1. Steps in w2.
	
	// Process steps
	push x0
	mov w0, w1
	mov w1, w2
	bl process_steps
	pop x0

	push x0
	push x1
	push x2
	bl print_head_location
	pop x2
	pop x1
	pop x0
	
	pop w2
	add w2, w2, #1

	b _main_loop_start

_main_end:
	bl count_tail_grid_hits
	bl print_hex

	adrp x0, alldone@PAGE
    add x0, x0, alldone@PAGEOFF
	mov x1, 10
	bl print_msg

_main_exit:
    // exit
	mov     X0, #0		// Use 0 return code
	mov     X16, #1		// 1 == exit
	svc     #0x80		// Call kernel


print_input:
	push lr
	adrp x0, input@PAGE
    add x0, x0, input@PAGEOFF
	mov x1, 32
	bl print_msg
	pop lr
	ret


// Expects x0 to point at input data
// On return:
//   x0 will point at the new input data location (after the \n)
//   w1 will be the movement direction
//   w2 will be the number of steps
read_line:
	push lr

	# consume the direction
	ldrb w1, [x0]
	push w1	// Push direction
	add x0, x0, #1

	# consume the space
	add x0, x0, #1

	# Parse number of steps
	bl consume_decimal
	push w1	// Push numsteps

	# consume the \n
	add x0, x0, #1

	pop w2	// Pop numsteps
	pop w1	// Pop direction
	pop lr
	ret

// Expects:
//   w0 will be the movement direction
//   w1 will be the number of steps
process_steps:
	push lr
	// w1 is counter
process_steps_loop:
	cmp w1, 0
	beq process_steps_end
	push w0
	push w1
	bl update_head
	pop w1
	pop w0
	push w0
	push w1
	bl update_all_tails
	pop w1
	pop w0
	sub w1, w1, #1
	b process_steps_loop
process_steps_end:
	pop lr
	ret


// Will update head position global
// Expects:
//   Direction in w0
update_head:
	push lr
	push w0
	bl print_char_w0
	pop w0
	cmp w0, #'U'
	beq update_head_up
	cmp w0, #'D'
	beq update_head_down
	cmp w0, #'L'
	beq update_head_left
	cmp w0, #'R'
	beq update_head_right
	push w0
	mov w0, #'?'
	bl print_char_w0
	pop w0
	b update_head_end
update_head_up:
	adrp x0, head_y@PAGE
    add x0, x0, head_y@PAGEOFF
	ldr w1, [x0]
	sub w1, w1, #1
	str w1, [x0]
	b update_head_end
update_head_down:
	push w0
	mov w0, #'D'
	bl print_char_w0
	pop w0
	adrp x0, head_y@PAGE
    add x0, x0, head_y@PAGEOFF
	ldr w1, [x0]
	add w1, w1, #1
	str w1, [x0]
	b update_head_end
update_head_left:
	adrp x0, head_x@PAGE
    add x0, x0, head_x@PAGEOFF
	ldr w1, [x0]
	sub w1, w1, #1
	str w1, [x0]
	b update_head_end
update_head_right:
	adrp x0, head_x@PAGE
    add x0, x0, head_x@PAGEOFF
	ldr w1, [x0]
	add w1, w1, #1
	str w1, [x0]
	b update_head_end
update_head_end:
	pop lr
	ret


print_head_location:
	push lr
	adrp x0, head_x@PAGE
    add x0, x0, head_x@PAGEOFF
	ldr x0, [x0]
	bl print_hex
	mov w0, #','
	bl print_char_w0
	adrp x0, head_y@PAGE
    add x0, x0, head_y@PAGEOFF
	ldr x0, [x0]
	bl print_hex
	bl print_new_line
	pop lr
	ret


.data
.align 4
// Rope:
// head_x, head_y, tail_x,tail_y named separately for convenience
// Stored in order as (x,y) word pairs.
// 4*2*8=64 bytes for middle of rope
rope:
head_x:		.fill	1, 4, 500
head_y:		.fill	1, 4, 500
tails:		.fill	16, 4, 500
tail_x:		.fill	1, 4, 500
tail_y:		.fill	1, 4, 500
.align 4
tail_grid:	.fill   4194304, 4, 0	// 2^22. > 1000*1000*4
.align 4
alldone: .ascii  "All done!\n"
.align 4
input:      .incbin "input.txt"
endchar:    .ascii "$"