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
       ; Kontrollregister r0, r7:
       ; - Jeden Test-Wert mit Erwartungswert (r7) XORen
       ; - In r0 schreiben
       ;
       ; -> Alle Bits == 0 -> korrekt
       ; -> Sonst -> Fehler
       ; ---------------------------------------------------
       xor r0, r0, r0 ; r0 := 00000000 00000000 (=0) | Funktioniert nicht, da Bits = 'U'?
       xor r7, r7, r7 ; r7 := 00000000 00000000 (=0) | Funktioniert nicht, da Bits = 'U'?

       ; load-Befehle testen
       ; ---------------------------------------------------

       ; load immediate low
       ldil r1, 5     ; r1 := 00000000 00000101 (lo=5)

       ; load immediate high
       ldih r2, 8       ; r2 := 00001000 00000000 (2048)

       ; load immediate low & high
       ldil r3, 6       ; r3 := -------- 00000110 (lo=6)
       ldih r3, 12      ; r3 := 00001100 00000110 (=3078)

       ; ALU-Befehle testen
       ; ---------------------------------------------------

       ; Testwerte festlegen
       ldil r1, 10 ; r1 := -------- 00001010 (lo=10)
       ldih r1, 0  ; r1 := 00000000 00001010 (=10)
       ldil r2, 2  ; r2 := -------- 00000010 (lo=2)
       ldih r2, 17 ; r2 := 00010001 00000010 (=4354)

       ; add
       add r4, r1, r2   ; r4 := 00010001 00001100 (=4364)
       ; Kontrollregister updaten
       ldil r7, 0x0C
       ldih r7, 0x11  ; r7 := 00010001 00001100 (=4364)
       xor r0, r4, r7 ; r0 := 00000000 00000000 (0)

       ; subtract
       sub r5, r2, r1   ; r5 := 00010000 11111000 (=4344)
       ; Kontrollregister updaten
       ldil r7, 0xF8
       ldih r7, 0x10  ; r7 := 00010000 11111000 (=4344)
       xor r0, r5, r7 ; 00000000 00000000 (0)


       ; shift arithmetic left
       sal r6, r2       ; r6 := 00100010 00000100 (=8708)
       ; Kontrollregister updaten
       ldil r7, 0x04
       ldih r7, 0x22  ; r7 := 00100010 00000100 (=8708)
       xor r0, r6, r7 ; r0 := 00000000 00000000 (0)


       ; shift arithmetic right
       sar r3, r2       ; r3 := 00001000 10000001 (=2177)
       ; Kontrollregister updaten
       ldil r7, 0x81
       ldih r7, 0x08  ; r7 := 00001000 10000001 (=2177)
       xor r0, r3, r7 ; r0 := 00000000 00000000 (0)

       ; r1 := 00000000 00001010 (=10)
       ; r2 := 00010001 00000010 (=4354)

       ; and
       and r3, r1, r2 ; r3 := 00000000 00000010 (=2)
       ; Kontrollregister updaten
       ldil r7, 0x02
       ldih r7, 0x00  ; r7 := 00000000 00000010 (=2)
       xor r0, r3, r7 ; r0 := 00000000 00000000 (0)

       ; or
       or r3, r1, r2    ; r3 := 00010001 00001010 (=4362)
       ; Kontrollregister updaten
       ldil r7, 0x0A
       ldih r7, 0x11  ; r7 := 00010001 00001010 (=4362)
       xor r0, r3, r7 ; r0 := 00000000 00000000 (0)

       ; xor
       xor r3, r1, r2   ; r3 := 00010001 00001000 (=4360)
       ; Kontrollregister updaten
       ldil r7, 0x08
       ldih r7, 0x11  ; r7 := 00010001 00001000 (=4360)
       xor r0, r3, r7 ; r0 := 00000000 00000000 (0)

       ; not
       not r3, r2        ; r3 := 11101110 11111101 (=61181)
       ; Kontrollregister updaten
       ldil r7, 0xFD
       ldih r7, 0xEE  ; r7 := 11101110 11111101 (=61181)
       xor r0, r3, r7 ; 00000000 00000000 (0)

       ; halt-Befehl testen
       ; ---------------------------------------------------
       halt ; Prozessor anhalten

       .end
