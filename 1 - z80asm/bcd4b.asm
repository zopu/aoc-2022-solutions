;; 4-byte packed BCD numbers.
;; 8 decimal digits
;; Unsigned. So range is 0-99999999
;; Little-endian, so
;; 00156734
;; is represented as
;; db $34, $67, $15, $00

; Zero out 4 bytes
; de should point at the 4 bytes
; Non-destructive to registers
bcd4b_zero:
    push de
    push af
    ld a, 0
    ld (de), a
    inc de
    ld (de), a
    inc de
    ld (de), a
    inc de
    ld (de), a
    pop af
    pop de
    ret


; Print
; hl should point at the 4 byte packed BCD number
bcd4b_print:
    inc hl
    inc hl
    inc hl
    push hl
    call bcd4b_print_byte
    pop hl
    dec hl
    push hl
    call bcd4b_print_byte
    pop hl
    dec hl
    push hl
    call bcd4b_print_byte
    pop hl
    dec hl
    push hl
    call bcd4b_print_byte
    pop hl
    ret

; Print one byte (2 digits)
; hl should point at byte
bcd4b_print_byte:
    ld a, (hl)
    and $F0
    srl a
    srl a
    srl a
    srl a
    add 48
    call PRINTCHAR
    ld a, (hl)
    and $F
    add 48
    call PRINTCHAR
    ret


; Read from ascii into packed BCD format
; hl should point at the ascii line to read
; which should be numbers delimited by \n
; and we assume is 8 or fewer digits
; de should point where we want to put the BCD number
; will update hl to the end of the line
bcd4b_from_ascii:
    ; Zero out the memory
    push hl
    push de
    call bcd4b_zero
    pop de
    pop hl

    ; First read and push every digit onto the stack
    ld b, 0     ; Count how many digits we find
bcd4b_from_ascii_readloopstart:
    ld a,(hl)       ; Location of number line to read
    cp '\n'         ; Finish on \n
    jp z, bcd4b_from_ascii_pop_and_convert
    cp '$'         ; Also finish on $ (EOF)
    jp z, bcd4b_from_ascii_pop_and_convert
    inc b
    push af
    inc hl          ; Move onto the next character
    jp bcd4b_from_ascii_readloopstart

    ; Then we repeatedly pop off the stack, pair digits up, and store
bcd4b_from_ascii_pop_and_convert:
    ld a, b
    cp 1
    jp z, bcd4b_from_ascii_last_digit_solo
    cp 0
    ret z
    ; If there are 2+ more, pop them both and pair
    pop af
    sub 48      ; Convert from ascii
    ld c, a     ; Move to c so we can load the high nibble, then combine
    pop af
    sub 48
    sla a
    sla a
    sla a
    sla a
    or c
    ld (de), a  ; store
    inc de
    dec b
    dec b
    jp bcd4b_from_ascii_pop_and_convert
bcd4b_from_ascii_last_digit_solo:
    ; If there's only one more, pop (will effectively be padded with zeros)
    pop af
    sub 48
    ld (de), a  ; store
    ret

; Add two numbers together
; de should point at first number
; hl should point at second number
; Result will overwrite first number
bcd4b_add:
    or a
    ld b, 4
bcd4b_add_loop:
    ld a, (de)
    adc a, (hl)
    daa
    ld (de), a
    inc de
    inc hl
    djnz bcd4b_add_loop
    ret

; Compare two numbers
; de should point at first number
; hl should point at second number
bcd4b_cp:
    ; First move to MSB
    inc de
    inc de
    inc de
    inc hl
    inc hl
    inc hl
    ld b, 4

bcd4b_cp_loop:
    ld a, (de)
    cp (hl)
    ret c
    ret nz
    dec de
    dec hl
    djnz bcd4b_cp_loop
    ld a, 0
    cp 0
    ret