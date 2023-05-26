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
       ; Kontrollregister r0
       ; Alle Bits == 1 (65535) -> korrekt
       ; Sonst -> Fehler
       ;
       ; -> Jeden Test-Wert mit Erwartungswert ANDen
       ; -> In r0 schreiben
       ; ---------------------------------------------------
       xor r0, r0, r0 ; r0 := 0000000000000000 (=0)

       ; load-Befehle testen
       ; ---------------------------------------------------

       ; load immediate low
       xor r1, r1, r1 ; r1 := 0000000000000000 (=0)
       ldil r1, 5     ; r1 := 0000000000000101 (lo=5)
       and r0, r1, 5  ; r0 := 1111111111111111 (65535)

       ; load immediate high
       xor r2, r2, r2   ; r2 := 0000000000000000 (=0)
       ldih r2, 8       ; r2 := 0000100000000000 (2048)
       and r0, r2, 2048 ; r0 := 1111111111111111 (65535)

       ; load immediate low & high
       xor r3, r3, r3   ; r3 := 0000000000000000 (=0)
       ldil r3, 6       ; r3 := --------00000110 (lo=6)
       ldih r3, 12      ; r3 := 0000110000000110 (=3078)
       and r0, r3, 3078 ; r0 := 1111111111111111 (65535)

       ; ALU-Befehle testen
       ; ---------------------------------------------------

       ldil r1, 10 ; r1 := --------00001010 (lo=10)
       ldih r1, 0  ; r1 := 0000000000001010 (=10)
       ldil r2, 2  ; r2 := --------00000010 (lo=2)
       ldih r2, 17 ; r2 := 0001000100000010 (=4354)

       ; add
       xor r4, r4, r4   ; r3 := 0000000000000000 (=0)
       add r4, r1, r2   ; r4 := 0001000100001100 (=4364)
       and r0, r4, 4364 ; r0 := 1111111111111111 (65535)

       ; subtract
       xor r5, r5, r5   ; r5 := 0000000000000000 (=0)
       sub r5, r1, r2   ; r5 := 0001000011111000 (=4344)
       and r0, r5, 4344 ; r0 := 1111111111111111 (65535)


       ; shift arithmetic left
       xor r6, r6, r6   ; r6 := 0000000000000000 (=0)
       sal r6, r2       ; r6 := 0010001000000100 (=8708)
       and r0, r6, 8708 ; r0 := 1111111111111111 (65535)


       ; shift arithmetic right
       xor r7, r7, r7   ; r7 := 0000000000000000 (=0)
       sar r7, r2       ; r7 := 0000100010000001 (=2177)
       and r0, r7, 2177 ; r0 := 1111111111111111 (65535)

       ; r1 := 0000000000001010 (=10)
       ; r2 := 0001000100000010 (=4354)

       ; and
       xor r7, r7, r7 ; r7 := 0000000000000000 (=0)
       and r7, r1, r2 ; r7 := 0000000000000010 (=2)
       and r0, r7, 2  ; r0 := 1111111111111111 (65535)

       ; or
       xor r7, r7, r7   ; r7 := 0000000000000000 (=0)
       or r7, r1, r2    ; r7 := 0001000100001010 (=4362)
       and r0, r7, 4362 ; r0 := 1111111111111111 (65535)

       ; xor
       xor r7, r7, r7   ; r7 := 0000000000000000 (=0)
       xor r7, r1, r2   ; r7 := 0001000100001000 (=4360)
       and r0, r7, 4360 ; r0 := 1111111111111111 (65535)

       ; not
       xor r7, r7, r7    ; r7 := 0000000000000000 (=0)
       not r7, r2        ; r7 := 1110111011111101 (=61181)
       and r0, r7, 61181 ; r0 := 1111111111111111 (65535)

       ; halt-Befehl testen
       ; ---------------------------------------------------
       halt ; Prozessor anhalten

       .end
