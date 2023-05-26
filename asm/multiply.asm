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

; Referenz:
; - Gesamt-Foliensatz S. 329, 330
; https://en.wikipedia.org/wiki/Binary_multiplier


        .org 0x0000 ; alles folgende ab Adresse 0

data:

        .data 0x100 6
        .data 0x101 2

start:

        ldil r0, 0
        ldih r0, 1    ; r0 := 0x100
        ld r1, [r0]   ; r1 := Wert aus 0x100 (Faktor 1)

        ldil r0, 1
        ldih r0, 1  ; r0 := 0x101
        ld r2, [r0] ; r2 := Wer aus 0x101 (Faktor 2)

        xor r0, r0, r0 ; Clear r0 (Akkumulator)

        ldil r3, 1 ;
        ldih r3, 0 ; r3 := 0000000000000001 (Maske)

        ; r4 := Helper (letztes Bit == 0?)

        ldil r5, 8
        ldih r5, 0 ; r5 := 8 (Loop counter)

        ldil r6, loop & 255
        ldih r6, loop >> 8 ; r6 := loop (Sprungadresse)

        ldil r7, add & 255
        ldih r7, add >> 8 ; r7 := add (Sprungadresse)

loop:

        and r4, r2, r3 ; AND Faktor 2 mit Maske => letzes Bit == 0?

        jnz r4, r7 ; Faktor 2 zu Akkumulator addieren, wenn letztes Bit == 1

        sal r1, r1 ; Ersten Faktor nach links schieben
        sar r2, r2 ; Zweiten Faktor nach rechts schieben (nächstes Bit betrachten)
        
        sub r5, r5, 1 ; Loop counter dekrementieren

        jnz r5, r6 ; Nächste Loop-Iteration

        ; Loop beendet

        ldil r1, result & 255
        ldih r1, result >> 8 ; r1 := result (Adresse: 0x102)
        st [r1], r0          ; Ergebnis in 0x102 schreiben


        halt ; Fertig: Prozessor anhalten

add:

        add r0, r0, r1 ; Faktor 2 zu Akkumulator addieren

        ; Code dupliziert, weil: kein Register mehr übrig für Sprungadresse (& schneller)

        sal r1, r1 ; Ersten Faktor nach links schieben
        sar r2, r2 ; Zweiten Faktor nach rechts schieben (nächstes Bit betrachten)
        
        sub r5, r5, 1 ; Loop counter dekrementieren

        jnz r5, r6 ; Nächste Loop-Iteration

        ; Loop beendet

        ldil r1, result & 255
        ldih r1, result >> 8 ; r1 := result (Adresse: 0x102)
        st [r1], r0          ; Ergebnis in 0x102 schreiben

        halt ; Fertig: Prozessor anhalten

        .org 0x0102
result: .res 1 ; Ein Wort reservieren
        .end
