; ---------------------------------------------------
; Befehlssatz
; ---------------------------------------------------
; add     00 000 ddd sss ttt --    add r2, r3, r5
; sub     00 001 ddd sss ttt --    sub r1, r4, r6
; sal     00 010 ddd sss --- --    sal r7, r4
; sar     00 011 ddd sss --- --    sar r4, r7
; and     00 100 ddd sss ttt --    and r7, r6, r5
; or      00 101 ddd sss ttt --    or r7, r6, r6
; xor     00 110 ddd sss ttt --    xor r7, r6, r5
; not     00 111 ddd sss --- --    not r1, r0

; ldil    01 -00 ddd nnn nnn nn    ldil r2, 17
; ldih    01 -01 ddd nnn nnn nn    ldih r2, 3
; ld      01 -10 ddd sss --- --    ld r7, [r4]
; st      01 -11 --- sss ttt --    st [r5], r7

; jmp     10 -00 --- sss --- --    jmp r7
; halt    10 -01 --- --- --- --    halt
; jz      10 -10 --- sss ttt --    jz r1, r7
; jnz     10 -11 --- sss ttt --    jnz r1, r7

; ---------------------------------------------------
; VISCY -Befehlssatz-Test:
; - Alle Befehle testen
; - Alle Register (r0 - r7) benutzen
; - Gesamte Wortbreite nutzen
; - Möglichst verschiedene Zahlenwerte nutzen
;
; Referenz: Gesamt-Foliensatz S. 329, 330
; ---------------------------------------------------

        .org 0x0000 ; alles folgende ab Adresse 0
start:

        ; Helper-Register
        ; ---------------------------------------------------
        ldil r0, result & 255
        ldih r0, result >> 8 ; r0 := result (Adresse)
        ldil r1, 1           ; r1 := --------00000001 (lo=1)
        ldil r1, 0           ; r1 := 0000000000000001 (=1)

        ; load-Befehle testen
        ; ---------------------------------------------------

        ; load immediate low
        ldil r2, 5     ; r0 = --------00000101 (lo=5)
        st [r0], r2    ; Ergebnis schreiben
        add r0, r0, r1 ; Zieladresse inkrementieren

        ; load immediate high
        ldih r3, 8     ; r3 = 00001000-------- (hi=8)
        st [r0], r3    ; Ergebnis schreiben
        add r0, r0, r1 ; Zieladresse inkrementieren

        ; load immediate low & high
        ldil r4, 6     ; r4 := --------00000110 (lo=6)
        ldih r4, 12    ; r4 := 0000110000000110 (=3078)
        st [r0], r4    ; Ergebnis schreiben
        add r0, r0, r1 ; Zieladresse inkrementieren

        ; load from memory
        sub r5, r0, r1 ; letzte Zieladresse erhalten
        ld r6, [r5]
        st [r0], r6    ; Ergebnis schreiben
        add r0, r0, r1 ; Zieladresse inkrementieren

        ; ALU-Befehle testen
        ; ---------------------------------------------------

        ldil r5, 10 ; r5 := --------00001010 (lo=10)
        ldih r5, 0  ; r5 := 0000000000001010 (=10)
        ldil r6, 2  ; r6 := --------00000010 (lo=2)
        ldih r6, 17 ; r6 := 0001000100000010 (=4354)

        ; add
        xor r7, r7, r7 ; r7 := 0000000000000000 (=0)
        add r7, r5, r6 ; r7 := 0001000100001100 (=4364)
        st [r0], r7    ; Ergebnis schreiben
        add r0, r0, r1 ; Zieladresse inkrementieren

        ; subtract
        xor r7, r7, r7 ; r7 := 0000000000000000 (=0)
        sub r7, r6, r5 ; r7 := 0001000011111000 (=4344)
        st [r0], r7    ; Ergebnis schreiben
        add r0, r0, r1 ; Zieladresse inkrementieren

        ; shift arithmetic left
        xor r7, r7, r7 ; r7 := 0000000000000000 (=0)
        sal r7, r6     ; r7 := 0010001000000100 (=8708)
        st [r0], r7    ; Ergebnis schreiben
        add r0, r0, r1 ; Zieladresse inkrementieren

        ; shift arithmetic right
        xor r7, r7, r7 ; r7 := 0000000000000000 (=0)
        sar r7, r6     ; r7 := 0000100010000001 (=2177)
        st [r0], r7    ; Ergebnis schreiben
        add r0, r0, r1 ; Zieladresse inkrementieren

        ; r5 := 0000000000001010 (=10)
        ; r6 := 0001000100000010 (=4354)

        ; and
        xor r7, r7, r7 ; r7 := 0000000000000000 (=0)
        and r7, r5, r6 ; r7 := 0000000000000010 (=2)
        st [r0], r7    ; Ergebnis schreiben
        add r0, r0, r1 ; Zieladresse inkrementieren

        ; or
        xor r7, r7, r7 ; r7 := 0000000000000000 (=0)
        or r7, r5, r6  ; r7 := 0001000100001010 (=4362)
        st [r0], r7    ; Ergebnis schreiben
        add r0, r0, r1 ; Zieladresse inkrementieren

        ; xor
        xor r7, r7, r7 ; r7 := 0000000000000000 (=0)
        xor r7, r5, r6 ; r7 := 0001000100001000 (=4360)
        st [r0], r7    ; Ergebnis schreiben
        add r0, r0, r1 ; Zieladresse inkrementieren

        ; not
        xor r7, r7, r7 ; r7 := 0000000000000000 (=0)
        not r7, r6     ; r7 := 1110111011111101 (=61181)
        st [r0], r7    ; Ergebnis schreiben
        add r0, r0, r1 ; Zieladresse inkrementieren

        ; jump-Befehle testen
        ; ---------------------------------------------------

        ; jump
        ldil r2 4              ; r2 := --------00000100 (lo=4)
        ldih r2 0              ; r2 := 0000000000000100 (=4)
        ldil r3, jumpskip & 255
        ldih r3, jumpskip >> 8 ; r3 := jumpskip (Adresse)
        jmp r3                 ; jump to jumpskip label
        ldil r2, 0xFF          ; should be skipped
        ldih r2, 0xFF          ; should be skipped
        jumpskip:              ; r2 := 0000000000000100 (=4)
        st [r0], r2            ; Ergebnis schreiben
        add r0, r0, r1         ; Zieladresse inkrementieren

        ; jump zero (on zero = do jump)
        ldil r2 11            ; r2 := --------00001011 (lo=11)
        ldih r2 52            ; r2 := 1101000000001011 (=53259)
        xor r4, r4, r4
        ldil r3, jztskip & 255
        ldih r3, jztskip >> 8 ; r3 := jztskip (Adresse)
        jz r3, r4             ; jump to jztskip label
        ldil r2, 0xFF         ; should be skipped
        ldih r2, 0xFF         ; should be skipped
        jztskip:              ; r2 := 0000000000000100 (=4)
        st [r0], r2           ; Ergebnis schreiben
        add r0, r0, r1        ; Zieladresse inkrementieren

        ; jump zero (non zero = do not jump)
        ldil r2 0xFF          ; r2 := --------11111111
        ldih r2 0xFF          ; r2 := 1111111111111111
        ldil r4, 1            ; r4 := --------00000001 (lo=1)
        ldil r3, jzfskip & 255
        ldih r3, jzfskip >> 8 ; r3 := jzfskip (Adresse)
        jz r3, r4             ; do not jump to jzfskip label
        ldil r2, 17           ; should be executed, r2 := --------00010001 (lo=17)
        ldih r2, 23           ; should be executed, r2 := 1011100000010001 (=47121)
        jzfskip:              ; r2 := 1011100000010001 (=47121)
        st [r0], r2           ; Ergebnis schreiben
        add r0, r0, r1        ; Zieladresse inkrementieren

        ; jump non zero (non zero = do jump)
        ldil r2 47             ; r2 := --------00101111 (lo=47)
        ldih r2 52             ; r2 := 0000001100101111 (=815)
        ldil r4, 1             ; r4 := --------00000001 (lo=1)
        ldil r3, jnztskip & 255
        ldih r3, jnztskip >> 8 ; r3 := jnztskip (Adresse)
        jnz r3, r4             ; jump to jnztskip label
        ldil r2, 0xFF          ; should be skipped
        ldih r2, 0xFF          ; should be skipped
        jnztskip:              ; r2 := 0000001100101111 (=815)
        st [r0], r2            ; Ergebnis schreiben
        add r0, r0, r1         ; Zieladresse inkrementieren

        ; jump non zero (zero = do not jump)
        ldil r2 0xFF           ; r2 := --------11111111
        ldih r2 0xFF           ; r2 := 1111111111111111
        xor r4, r4, r4         ; r4 := 0000000000000000 (=0)
        ldil r3, jnzfskip & 255
        ldih r3, jnzfskip >> 8 ; r3 := jnzfskip (Adresse)
        jnz r3, r4             ; do not jump to jnzfskip label
        ldil r2, 8             ; should be executed, r2 := --------00001000 (lo=8)
        ldih r2, 16            ; should be executed, r2 := 0001000000001000 (=4104)
        jnzfskip:              ; r2 := 0001000000001000 (=4104)
        st [r0], r2            ; Ergebnis schreiben
        add r0, r0, r1         ; Zieladresse inkrementieren

        ; halt
        halt ; Prozessor anhalten

        .org 0x0100
result: .res 17 ; 17 Worte reservieren (für alle Test-Cases)
        .end

; ---------------------------------------------------
; Erwartete Ergebnisse:
; ---------------------------------------------------

; load-Befehle:
; ---------------------------------------------------
; 1. load immediate low:        --------00000101 (lo=5)
; 2. load immediate high:       00001000-------- (hi=8)
; 3. load immediate low & high: 0000110000000110 (=3078)
; 4. load from memory:          0000110000000110 (=3078)

; ALU-Befehle:
; ---------------------------------------------------
; 5. add:                   0001000100001100 (=4364)
; 6. subtract:              0001000011111000 (=4344)
; 7. shift arithmetic left: 0010001000000100 (=8708)
; 8.shift arithemtic right: 0000100010000001 (=2177)
; 9. and:                   0000000000000010 (=2)
; 10. or:                   0001000100001010 (=4362)
; 11. xor:                  0001000100001000 (=4360)
; 12. not:                  1110111011111101 (=61181)

; jump-Befehle:
; ---------------------------------------------------
; 13: jump:                 nicht 1111111111111111
; 14: jump zero (true):     nicht 1111111111111111
; 15: jump zero (false):    nicht 1111111111111111
; 16: jump non zero (true): nicht 1111111111111111
; 17: jump non zero (false) nicht 1111111111111111
        