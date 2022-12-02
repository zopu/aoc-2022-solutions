    org 32768
    CLS: equ $0D6B
    PRINT: equ $1601     
    PRINTCHAR: equ $0010

start:
    ; Set up the screen for text output
    call CLS
    ld a, 2         ; channel 2 = "S" for screen
    call PRINT
    
    ; call test_print
    ; call test_zero
    ; call test_from_ascii
    ; call test_data_from_ascii
    ; call test_add
    ; call test_cp

    ; sum, max = 0
    ld de, sum
    call bcd4b_zero
    ld de, max
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
    ; End: 
    ;   If sum > max, max = sum
    ; call update_max
    ;   Print max
    ld hl, max
    call bcd4b_print
    ret

update_max:
    ld de, sum
    ld hl, max
    call bcd4b_cp
    jp c, update_max_end
    ; Copy sum to max
    ld de, max
    ld hl, sum
    ld bc, 4
    ldir
update_max_end:
    ret

test_print:
    ld hl, testnum
    call bcd4b_print
    ret

test_zero:
    ld a, ' '
    call PRINTCHAR
    ld de, testnoise
    call bcd4b_zero
    ld hl, testnoise
    call bcd4b_print
    ret

test_from_ascii:
    ld a, ' '
    call PRINTCHAR
    ld hl, testinput
    ld de, temp
    call bcd4b_from_ascii
    ld hl, temp
    call bcd4b_print
    ld a, ' '
    call PRINTCHAR
    ret

test_data_from_ascii:
    ld a, ' '
    call PRINTCHAR
    ld hl, data
    ld de, temp
    call bcd4b_from_ascii
    ld hl, temp
    call bcd4b_print
    ld a, ' '
    call PRINTCHAR
    ret

test_add:
    ld de, testnum
    ld hl, testnum2
    call bcd4b_add
    ld hl, testnum
    call bcd4b_print
    ld a, ' '
    call PRINTCHAR
    ret

test_cp:
    ld de, testnum
    ld hl, testnum2
    call bcd4b_cp
    jp c, test_cp_less
    jp z, test_cp_equal
    ld a, '>'
    call PRINTCHAR
    jp test_cp_end
test_cp_less:
    ld a, '<'
    call PRINTCHAR
    jp test_cp_end
test_cp_equal:
    ld a, '='
    call PRINTCHAR
    jp test_cp_end
test_cp_end:
    ld a, ' '
    call PRINTCHAR
    ret

include 'bcd4b.asm'

temp: defs 4
sum: defs 4
max: defs 4
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