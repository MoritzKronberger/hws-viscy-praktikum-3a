; ---------------------------------------------------
; Reduzierter Befehlssatz
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

; halt    10 -01 --- --- --- --    halt

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
       ; load-Befehle testen
       ; ---------------------------------------------------

       ; load immediate low
       xor r0, r0, r0 ; r0 := 0000000000000000 (=0)
       ldil r0, 5     ; r0 = 0000000000000101 (lo=5)

       ; load immediate high
       xor r1, r1, r1 ; r1 := 0000000000000000 (=0)
       ldih r1, 8     ; r1 := 0000100000000000 (hi=8)

       ; load immediate low & high
       xor r2, r2, r2 ; r2 := 0000000000000000 (=0)
       ldil r2, 6     ; r2 := --------00000110 (lo=6)
       ldih r2, 12    ; r2 := 0000110000000110 (=3078)

       ; ALU-Befehle testen
       ; ---------------------------------------------------

       ldil r0, 10 ; r0 := --------00001010 (lo=10)
       ldih r0, 0  ; r0 := 0000000000001010 (=10)
       ldil r1, 2  ; r1 := --------00000010 (lo=2)
       ldih r1, 17 ; r1 := 0001000100000010 (=4354)

       ; add
       xor r3, r3, r3 ; r3 := 0000000000000000 (=0)
       add r3, r0, r1 ; r3 := 0001000100001100 (=4364)

       ; subtract
       xor r4, r4, r4 ; r4 := 0000000000000000 (=0)
       sub r4, r1, r0 ; r4 := 0001000011111000 (=4344)

       ; shift arithmetic left
       xor r5, r5, r5 ; r5 := 0000000000000000 (=0)
       sal r5, r1     ; r5 := 0010001000000100 (=8708)

       ; shift arithmetic right
       xor r6, r6, r6 ; r6 := 0000000000000000 (=0)
       sar r6, r1     ; r6 := 0000100010000001 (=2177)

       ; r0 := 0000000000001010 (=10)
       ; r1 := 0001000100000010 (=4354)

       ; and
       xor r7, r7, r7 ; r7 := 0000000000000000 (=0)
       and r7, r0, r1 ; r7 := 0000000000000010 (=2)

       ; or
       xor r2, r2, r2 ; r2 := 0000000000000000 (=0)
       or r2, r0, r1  ; r2 := 0001000100001010 (=4362)

       ; xor
       xor r2, r2, r2 ; r2 := 0000000000000000 (=0)
       xor r2, r0, r1 ; r2 := 0001000100001000 (=4360)

       ; not
       xor r2, r2, r2 ; r2 := 0000000000000000 (=0)
       not r2, r1     ; r2 := 1110111011111101 (=61181)

       ; halt-Befehl testen
       ; ---------------------------------------------------
       halt ; Prozessor anhalten

       .end
