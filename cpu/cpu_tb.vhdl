----------------------------------------------------------------------------------------
-- This file is part of the VISCY project.
-- (C) 2007-2021 Gundolf Kiefer, Fachhochschule Augsburg, University of Applied Sciences
-- (C) 2018 Michael Schäferling, Hochschule Augsburg, University of Applied Sciences
--
-- Description:
-- This is a testbench for the VISCY CPU
----------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity CPU_TB is
end CPU_TB;


architecture TESTBENCH of CPU_TB is
    -- Declare CPU component (Unit Under Test - UUT)
    component CPU is
        port (
            clk:    in    std_logic;                      -- clock signal
            reset:  in    std_logic;                      -- reset CPU
            adr:    out   std_logic_vector (15 downto 0); -- memory address
            rdata:  in    std_logic_vector (15 downto 0); -- data read from memory
            wdata:  out   std_logic_vector (15 downto 0); -- data to write to memory
            rd:     out   std_logic;                      -- read from memory
            wr:     out   std_logic;                      -- write to memory
            ready:  in    std_logic                       -- ready signal
            );
        end component;

    -- Point CPU component to the submodule's RTL architecture
    for UUT: CPU use entity WORK.CPU(RTL);

    -- Internal signals
    signal clk:   std_logic := '0';              -- clock signal
    signal reset: std_logic := '0';              -- reset CPU
    signal ready: std_logic := '0';              -- ready signal
    signal adr:   std_logic_vector(15 downto 0); -- memory address
    signal rdata: std_logic_vector(15 downto 0); -- data read from memory
    signal wdata: std_logic_vector(15 downto 0); -- data to write to memory
    signal rd:    std_logic;                     -- read from memory
    signal wr:    std_logic;                     -- write to memory

    -- Internal constants
    constant clk_period: time := 10 ns;
    constant mem_delay: time := 25 ns;

    -- Memory content (generated by viscy2l) ...
    type t_memory is array (0 to 258) of std_logic_vector (15 downto 0);
    signal mem_content: t_memory := (
        16#0000# => "0100000000000000",  --         ldil r0, 0
        16#0001# => "0100100000000001",  --         ldih r0, 1    ; r0 := 0x100
        16#0002# => "0101000100000000",  --         ld r1, [r0]   ; r1 := Wert aus 0x100 (Faktor 1)
        16#0003# => "0100000000000001",  --         ldil r0, 1
        16#0004# => "0100100000000001",  --         ldih r0, 1  ; r0 := 0x101
        16#0005# => "0101001000000000",  --         ld r2, [r0] ; r2 := Wer aus 0x101 (Faktor 2)
        16#0006# => "0011000000000000",  --         xor r0, r0, r0 ; Clear r0 (Akkumulator)
        16#0007# => "0100001100000001",  --         ldil r3, 1 ;
        16#0008# => "0100101100000000",  --         ldih r3, 0 ; r3 := 0000000000000001 (1) (Maske und Decrement-Helper)
        16#0009# => "0100010100001000",  --         ldil r5, 8
        16#000a# => "0100110100000000",  --         ldih r5, 0 ; r5 := 8 (Loop counter)
        16#000b# => "0100011000001111",  --         ldil r6, loop & 255
        16#000c# => "0100111000000000",  --         ldih r6, loop >> 8 ; r6 := loop (Sprungadresse)
        16#000d# => "0100011100010010",  --         ldil r7, skip_add & 255
        16#000e# => "0100111100000000",  --         ldih r7, skip_add >> 8 ; r7 := add (Sprungadresse)
        16#000f# => "0010010001001100",  --         and r4, r2, r3 ; AND Faktor 2 mit Maske => letzes Bit == 0?
        16#0010# => "1001000011110000",  --         jz r4, r7 ; Faktor 1 zu Akkumulator addieren überspringen, wenn letztes Faktor-2-Bit == 0
        16#0011# => "0000000000000100",  --         add r0, r0, r1 ; Faktor 1 zu Akkumulator addieren
        16#0012# => "0001000100100000",  --         sal r1, r1 ; Ersten Faktor nach links schieben
        16#0013# => "0001101001000000",  --         sar r2, r2 ; Zweiten Faktor nach rechts schieben (nächstes Bit betrachten)
        16#0014# => "0000110110101100",  --         sub r5, r5, r3 ; Loop counter dekrementieren
        16#0015# => "1001100011010100",  --         jnz r5, r6 ; Nächste Loop-Iteration
        16#0016# => "0100000100000010",  --         ldil r1, result & 255
        16#0017# => "0100100100000001",  --         ldih r1, result >> 8 ; r1 := result (Adresse: 0x102)
        16#0018# => "0101100000100000",  --         st [r1], r0          ; Ergebnis in 0x102 schreiben
        16#0019# => "1000100000000000",  --         halt ; Fertig: Prozessor anhalten
        16#0100# => "0000000010110000",  --         .data 0xB0 ; 176 in 0x100 ablegen
        16#0101# => "0000000010100111",  --         .data 0xA7 ; 167 in 0x101 ablegen
        16#0102# => "0000000000000000",  -- result: .res 1 ; Ein Wort reservieren
        others => "UUUUUUUUUUUUUUUU"
    );

BEGIN
    -- Instantiate the CPU (UUT)
    UUT: CPU port map (
            clk => clk,
            reset => reset,
            adr => adr,
            rdata => rdata,
            wdata => wdata,
            rd => rd,
            wr => wr,
            ready => ready
         );

    -- Process to simulate the memory behavior
    memory: process
    begin
        -- Disable ready
        ready <= '0';
        -- Wait until CPU wants to read or write
        wait on rd, wr;
        -- In read mode
        if rd = '1' then
            wait for mem_delay; -- simulate memory delay
            -- Set read-data from memory-address-data
            if is_x (adr) then
                rdata <= (others => 'X'); -- fill read-data with X if memory address is X
            else
                rdata <= mem_content (to_integer (unsigned (adr))); -- otherwise, load memory content from memory address into read-data
            end if;
            -- Enable ready (data can now be used by CPU)
            ready <= '1';
            -- Wait until CPU disables read mode
            wait until rd = '0';
            -- Fill read-data with X (invalid data, which should not be used by CPU since rd = 0)
            rdata <= (others => 'X');
            wait for mem_delay; -- simulate memory delay
            -- Disable ready
            ready <= '0';
        -- In write mode
        elsif wr = '1' then
            wait for mem_delay; -- simulate memory delay
            -- Set memory-address-data from write-data (if address is not X)
            if not is_x(adr) then
                mem_content (to_integer (unsigned (adr))) <= wdata;
            end if;
            -- Enable ready (write was successful)
            ready <= '1';
            -- Wait until CPU disables write mode
            wait until wr = '0';
            wait for mem_delay; -- simulate memory delay
            -- Disable ready
            ready <= '0';
        end if;
    end process;


  -- Main testbench process
  testbench: process
    
    procedure run_cycle is
    begin
      clk <= '0';
      wait for clk_period / 2;
      clk <= '1';
      wait for clk_period / 2;
    end procedure;

    -- End testbench after n cycles without read signal
    variable read_tb_timeout: integer := 500;
    
  begin

    -- Reset CPU on startup
    reset <= '1';
    run_cycle;
    reset <= '0';

    -- Run clock cycles
    -- Exit loop if read timeout expires
    L: while read_tb_timeout > 0 loop
        run_cycle;
        -- Increment timeout if read signal is not set
        IF rd = '0' THEN
            read_tb_timeout := read_tb_timeout - 1;
        END IF;
    end loop;
    
    -- Print a note & finish simulation now
    assert false report "Simulation finished" severity note;
    wait; -- wait forever (stop simulation)

  end process;

end architecture;
