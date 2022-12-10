update_all_tails:
    push lr
    mov x2, #0

    adrp x0, head_x@PAGE
    add x0, x0, head_x@PAGEOFF

update_all_tails_loop:
    push x2
    push x0

    add x1, x0, 4
    add x2, x1, 4
    add x3, x2, 4
    
	bl update_tail

    pop x0
    pop x2

    add x2, x2, #1
    add x0, x0, #8  // Move up to the next head/tail pair
    
    cmp x2, #9
    b.lt update_all_tails_loop


    // x0 now points to the tail x location. Load tail x,y into w3,w4
    ldr w3, [x0]
    add x0, x0, #4
    ldr w4, [x0]

    // Store a 1 at the right position in the tail grid
    adrp x0, tail_grid@PAGE
    add x0, x0, tail_grid@PAGEOFF
	// pos = y * GRID_SIZE_X + x
    mov w6, GRID_SIZE_X
    mov x5, #0
    mul w5, w4, w6
    add w5, w5, w3
    lsl w5, w5, #2      // *4, since we're storing words
    add x0, x0, x5
    mov w5, #1
    str w5, [x0]

    bl print_tail_location      // TODO: Debug output to remove

    pop lr
    ret


// Will update tail position of a head/tail pair
// Expects:
//   head location in x0, x1
//   tail location in x2, x3
update_tail:
	push lr
    // Push the tail location - We'll want to update it later
    push x3     // tail.y location
    push x2     // tail.x location

    // Load head into w1, w2, tail into w3, w4.
	ldr w4, [x3]
	ldr w3, [x2]
    ldr w2, [x1]
	ldr w1, [x0]

    // Now check the various conditions

    // if tail.x < head.x - 1
    // ++tail.x, adjust y
    sub w5, w1, #1
    cmp w3, w5
    b.ge update_tail_check_big_x
    add w3, w3, #1
    b update_tail_adjust_y
update_tail_check_big_x:
    // if tail.x > head.x + 1
    // --tail.x, adjust y
    add w5, w1, #1
    cmp w3, w5
    b.le update_tail_check_small_y
    sub w3, w3, #1
    b update_tail_adjust_y
update_tail_check_small_y:
    // if tail.y < head.y - 1
    // ++tail.y, adjust x
    sub w5, w2, #1
    cmp w4, w5
    b.ge update_tail_check_big_y
    add w4, w4, #1
    b update_tail_adjust_x
update_tail_check_big_y:
    // if tail.y > head.y + 1
    // --tail.y, adjust x
    add w5, w2, #1
    cmp w4, w5
    b.le update_tail_end    // Last check, so go to end
    sub w4, w4, #1
    b update_tail_adjust_x

    // The "adjust" parts here mean move the respective dimension
    // in the direction of the head
update_tail_adjust_x:
    cmp w3, w1
    b.lt update_tail_inc_x
    b.gt update_tail_dec_x
    b update_tail_end
update_tail_adjust_y:
    cmp w4, w2
    b.lt update_tail_inc_y
    b.gt update_tail_dec_y
    b update_tail_end

update_tail_inc_x:
    add w3, w3, #1
    b update_tail_end
update_tail_dec_x:
    sub w3, w3, #1
    b update_tail_end
update_tail_inc_y:
    add w4, w4, #1
    b update_tail_end
update_tail_dec_y:
    sub w4, w4, #1
    b update_tail_end
update_tail_end:
    // Store updated tail
    pop x0 
	str w3, [x0]
    pop x0
	str w4, [x0]

	pop lr
	ret


print_tail_location:
	push lr
    mov w0, #'t'
	bl print_char_w0
	adrp x0, tail_x@PAGE
    add x0, x0, tail_x@PAGEOFF
	ldr x0, [x0]
	bl print_hex
	mov w0, #','
	bl print_char_w0
	adrp x0, tail_y@PAGE
    add x0, x0, tail_y@PAGEOFF
	ldr x0, [x0]
	bl print_hex
	bl print_new_line
	pop lr
	ret


// Returns # hits in w0
count_tail_grid_hits:
    push lr
    adrp x0, tail_grid@PAGE
    add x0, x0, tail_grid@PAGEOFF
    mov w1, #1     // Iteration count. 2^22
    lsl w1, w1, #22
    // mul w1, w1, w1
    mov w2, #0          // hit count
count_tail_grid_hits_loop_start:
    ldr w3, [x0]
    add w2, w2, w3
    add x0, x0, #4      // Iterating over words
    sub w1, w1, #1
    cmp w1, #0
    b.gt count_tail_grid_hits_loop_start
    mov w0, w2
    pop lr
    ret