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
  type t_memory is array (0 to 27) of std_logic_vector (15 downto 0);
  signal mem_content: t_memory := (
      16#0000# => "0011000000000000",  --        xor r0, r0, r0 ; r0 := 0000000000000000 (=0)
      16#0001# => "0100000000000101",  --        ldil r0, 5     ; r0 = 0000000000000101 (lo=5)
      16#0002# => "0011000100100100",  --        xor r1, r1, r1 ; r1 := 0000000000000000 (=0)
      16#0003# => "0100100100001000",  --        ldih r1, 8     ; r1 := 0000100000000000 (hi=8)
      16#0004# => "0011001001001000",  --        xor r2, r2, r2 ; r2 := 0000000000000000 (=0)
      16#0005# => "0100001000000110",  --        ldil r2, 6     ; r2 := --------00000110 (lo=6)
      16#0006# => "0100101000001100",  --        ldih r2, 12    ; r2 := 0000110000000110 (=3078)
      16#0007# => "0100000000001010",  --        ldil r0, 10 ; r0 := --------00001010 (lo=10)
      16#0008# => "0100100000000000",  --        ldih r0, 0  ; r0 := 0000000000001010 (=10)
      16#0009# => "0100000100000010",  --        ldil r1, 2  ; r1 := --------00000010 (lo=2)
      16#000a# => "0100100100010001",  --        ldih r1, 17 ; r1 := 0001000100000010 (=4354)
      16#000b# => "0011001101101100",  --        xor r3, r3, r3 ; r3 := 0000000000000000 (=0)
      16#000c# => "0000001100000100",  --        add r3, r0, r1 ; r3 := 0001000100001100 (=4364)
      16#000d# => "0011010010010000",  --        xor r4, r4, r4 ; r4 := 0000000000000000 (=0)
      16#000e# => "0000110000100000",  --        sub r4, r1, r0 ; r4 := 0001000011111000 (=4344)
      16#000f# => "0011010110110100",  --        xor r5, r5, r5 ; r5 := 0000000000000000 (=0)
      16#0010# => "0001010100100000",  --        sal r5, r1     ; r5 := 0010001000000100 (=8708)
      16#0011# => "0011011011011000",  --        xor r6, r6, r6 ; r6 := 0000000000000000 (=0)
      16#0012# => "0001111000100000",  --        sar r6, r1     ; r6 := 0000100010000001 (=2177)
      16#0013# => "0011011111111100",  --        xor r7, r7, r7 ; r7 := 0000000000000000 (=0)
      16#0014# => "0010011100000100",  --        and r7, r0, r1 ; r7 := 0000000000000010 (=2)
      16#0015# => "0011001001001000",  --        xor r2, r2, r2 ; r2 := 0000000000000000 (=0)
      16#0016# => "0010101000000100",  --        or r2, r0, r1  ; r2 := 0001000100001010 (=4362)
      16#0017# => "0011001001001000",  --        xor r2, r2, r2 ; r2 := 0000000000000000 (=0)
      16#0018# => "0011001000000100",  --        xor r2, r0, r1 ; r2 := 0001000100001000 (=4360)
      16#0019# => "0011001001001000",  --        xor r2, r2, r2 ; r2 := 0000000000000000 (=0)
      16#001a# => "0011101000100000",  --        not r2, r1     ; r2 := 1110111011111101 (=61181)
      16#001b# => "1000100000000000",  --        halt ; Prozessor anhalten
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

    -- Clock cycles (make sure that entire memory content is executed)
    variable n: integer := 1000;
    
  begin

    -- Reset CPU on startup
    reset <= '1';
    run_cycle;
    reset <= '0';
    run_cycle;

    -- Run clock cycles
    for i in 0 to n loop
        run_cycle;
    end loop;
    
    -- Print a note & finish simulation now
    assert false report "Simulation finished" severity note;
    wait; -- wait forever (stop simulation)

  end process;

end architecture;
