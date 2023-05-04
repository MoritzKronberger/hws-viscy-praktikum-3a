library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity IR_TB is
end IR_TB;

architecture TESTBENCH of IR_TB is
--component--

    component IR
        port (clk: in std_logic;
            load: in std_logic; -- Steuersignal
            ir_in: in std_logic_vector (15 downto 0); -- Dateneingang
            ir_out: out std_logic_vector (15 downto 0) -- Datenausgang
        );
    end component;

--clock period--
    constant period: time := 10 ns;

--signals--
    signal clk, load: std_logic;
    signal ir_in, ir_out: std_logic_vector(15 downto 0);

begin
    --instantiierung--
    U_IR : IR port map (
    clk => clk,
    load => load,
    ir_in => ir_in,
    ir_out => ir_out
    );

    --process start--
     process

        --Procedur für einen CLockcycle
        procedure run_cycle is
            begin
            clk <= '0';
            wait for period / 2;
            clk <= '1';
            wait for period / 2;
        end procedure;

        --Procedur Test
        procedure test_pc (data: in std_logic_vector(15 downto 0)) is
        begin
        --lade befehl--
        run_cycle;
        ir_in <= data;
        load <= '1';
        run_cycle;
        assert ir_out = data
        report "lade Befehl ist fehlgeschlagen";
        --Befehl wird gehalten--
        run_cycle;
        load <= '0';
        run_cycle;
        assert ir_out = data
        report "Befehl wird gehalten fehlgeschlagen";
        --setze neuen Befehl ohne zu laden--
        run_cycle;
        ir_in <= "0000111100001111";
        load <= '0';
        run_cycle;
        assert ir_out = data
        report "setze neuen Befehl ohne zu laden fehlgeschlagen";
        --setze neuen Wert
        run_cycle;
        ir_in <= "1111000011110000";
        load <= '1';
        run_cycle;
        assert ir_out = "1111000011110000"
        report "setze neuen Wert fehlgeschlagen";
        --setze neuen Befehl nach halten--
        run_cycle;
        ir_in <= data;
        load <= '1';
        run_cycle;
        assert ir_out = data
        report "setze neuen Befehl nach halten fehlgeschlagen";
        end procedure;

        -- Interal variable
        variable max: std_logic_vector(15 downto 0) := "1111111111111111";
    begin
    
    -- Test every possible value
    for i in 0 to to_integer(unsigned(max)) loop
        test_pc(std_logic_vector(to_unsigned(i, max'length)));
    end loop;

    --Ende der Testbench--
    assert false report "Simulation finished" severity note;
    wait;

    end process;


end TESTBENCH;
