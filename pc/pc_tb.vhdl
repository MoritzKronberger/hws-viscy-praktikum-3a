library IEEE;
use IEEE.std_logic_1164.all;


entity PC_TB is
end PC_TB;



architecture TESTBENCH of PC_TB is

  -- Component declaration
entity PC is
port (
clk: in std_logic;
reset, inc, load: in std_logic; -- Steuersignale
pc_in: in std_logic_vector (15 downto 0); -- Dateneingang
pc_out: out std_logic_vector (15 downto 0) -- Ausgabe Zaehlerstand
);
end PC;

  -- Configuration...
  for IMPL: PC use entity WORK.PC(RTL);

  -- Internal signals...
  signal clk, reset, inc, load: std_logic;
  signal pc_in, pc_out: std_logic_vector (15 downto 0); -- 16-bit input & output

begin

  -- Instantiate half adder
  IMPL: PC port map (clk => clk, reset => reset, inc => inc, load => load, pc_in => pc_in, pc_out => pc_out);

  -- Main process...
  process
  
  variable counter: INTEGER := 0;	-- manueller Zähler zur Überprüfung
  
  procedure run_cycle is
	variable period: time := 10ns;
	begin
	clk <= '0'; -- 'clk' ist ein global deklariertes Signal
	wait for period / 2;
	clk <= '1';
	wait for period / 2;
	end procedure;
  -- internal variable
  variable max: std_logic_vector(15 downto 0) := "1111111111111111";
  
  begin

	pc_in <= "1111111111111111";
    reset <= '1'; inc <= '0'; load <= '0';
    run_cycle     -- wait 1 cycle
    assert pc_out = "0000000000000000"  report "Zähler wurde nicht korrekt zurückgesetzt";
	
	pc_in <= "1111111100000000";
    reset <= '0'; inc <= '0'; load <= '0';
    run_cycle     -- wait 1 cycle
    assert pc_out = "0000000000000000"  report "Zähler wurde nicht korrekt gehalten!";

-- inc loop
inc_loop: for i in 0 to to_integer(unsigned(max)) loop
    reset <= '0'; inc <= '1'; load <= '0';
	counter := counter+1;
    run_cycle     -- wait 1 cycle
    assert pc_out = counter  report "Zähler nicht korrekt erhöht";
end loop inc_loop;

load_loop: for i in 0 to to_integer(unsigned(max)) loop
	pc_in <= i
    reset <= '0'; inc <= '0'; load <= '1';
    run_cycle     -- wait 1 cycle
    assert pc_out = i  report "Zähler in loop nicht korrekt geladen";
end loop hold_loop;

	pc_in <= "1111000011110000"
    reset <= '0'; inc <= '0'; load <= '1';
    run_cycle     -- wait 1 cycle
    assert pc_out = "1111000011110000"  report "Zähler nicht korrekt geladen";


	pc_in <= "1100110011001100"
	reset <= '0'; inc <= '0'; load <= '0';
    run_cycle     -- wait 1 cycle
    assert pc_out = "1111000011110000"  report "Zähler wurde nicht korrekt gehalten!";


	-- all signals 1, reset should be dominant	
	pc_in <= "1100110011001100"
	reset <= '1'; inc <= '1'; load <= '1';
    run_cycle     -- wait 1 cycle
    assert pc_out = "0000000000000000"  report "Reset war nicht dominant";

    -- Print a note & finish simulation now
    assert false report "Simulation finished" severity note;
    wait;               -- end simulation

  end process;

end architecture;
