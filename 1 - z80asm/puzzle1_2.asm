    org 32768
    CLS: equ $0D6B
    PRINT: equ $1601     
    PRINTCHAR: equ $0010

start:
    ; Set up the screen for text output
    call CLS
    ld a, 2         ; channel 2 = "S" for screen
    call PRINT

    ; sum, max = 0
    ld de, sum
    call bcd4b_zero
    ld de, max1
    call bcd4b_zero
    ld de, max2
    call bcd4b_zero
    ld de, max3
    call bcd4b_zero

    ld hl, data

    ; Read file in a loop until $
    ; hl will be location in input data
puzzle1_loop_start:
    ld a, (hl)
    cp '$'
    jp z, puzzle1_end

    cp '\n'
    jp nz, puzzle1_next_num

    ; If Newline,
    ;   If sum > max, max = sum
    push hl
    call update_max
    pop hl

    ld de, sum      ; sum = 0
    call bcd4b_zero

    inc hl
    jp puzzle1_loop_start

    ; Else
puzzle1_next_num:
    ; Read line to temp
    ld de, temp
    call bcd4b_from_ascii
    inc hl      ; Consume the trailing \n

    ; Add temp to sum
    push hl
    ld de, sum
    ld hl, temp
    call bcd4b_add
    pop hl
    
    jp puzzle1_loop_start

puzzle1_end:
    ; sum the maxes into max1
    ld de, max1
    ld hl, max2
    call bcd4b_add

    ld de, max1
    ld hl, max3
    call bcd4b_add

    ld hl, max1
    call bcd4b_print
    ret

update_max:
    ld de, sum
    ld hl, max3
    call bcd4b_cp
    jp c, update_max_end
    ; Copy sum to max3
    ld de, max3
    ld hl, sum
    ld bc, 4
    ldir
update_max_end:
    call sort_maxes
    ret

; We want m1 > m2 > m3
sort_maxes:
    ; Compare/Swap m1/m2
    push de
    push hl
    ld de, max2
    ld hl, max1
    call compare_and_sort
    ; Compare/Swap m2/m3
    ld de, max3
    ld hl, max2
    call compare_and_sort
    ; Compare/Swap m1/m2
    ld de, max2
    ld hl, max1
    call compare_and_sort
    pop hl
    pop de
    ret

; de, hl
; Will leave the smaller in de and the larger in hl
compare_and_sort:
    push de
    push hl
    call bcd4b_cp
    pop hl
    pop de
    ret c
    push de
    push hl
    ; (hl)->(swap_temp)
    ld de, swap_temp
    ld bc, 4
    ldir
    pop hl
    pop de
    push de
    push hl
    ; (de)->(hl)
    ex de, hl
    ld bc, 4
    ldir
    pop hl
    pop de
    push de
    push hl
    ; (swap_temp)->(de)
    ld hl, swap_temp
    ld bc, 4
    ldir
    pop hl
    pop de
    ret

include 'bcd4b.asm'

temp: defs 4
sum: defs 4

; Top 3
; When updating these we'll keep them sorted m1 > m2 > m3
max1: defs 4
max2: defs 4
max3: defs 4
swap_temp: defs 4

data:  incbin 'input.txt'
endchar:    defb '$'

; Some test data

; Test number 00156734
; testnum: dw $6734, $0015  ; Same as below
testnum: db $34, $67, $15, $00      ; 00156734
testnum2: db $81, $49, $01, $20     ; 20014981
; Some noise for testing zeroing
testnoise: dw $1234, $FFFF

testinput: defb '123\n45678910\n\n3123\n1\n$'