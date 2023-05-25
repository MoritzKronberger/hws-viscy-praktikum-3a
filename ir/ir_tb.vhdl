library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity IR_TB is
end IR_TB;

architecture TESTBENCH of IR_TB is
    -- Component declaration
    component IR
        port (clk: in std_logic;                       -- Clock-Signal
            load: in std_logic;                        -- Steuersignal
            ir_in: in std_logic_vector (15 downto 0);  -- Dateneingang
            ir_out: out std_logic_vector (15 downto 0) -- Datenausgang
        );
    end component;

    -- Clock period
    constant period: time := 10 ns;

    --Internal signals
    signal clk, load: std_logic;
    signal ir_in, ir_out: std_logic_vector(15 downto 0);

begin
    -- Instantiierung
    U_IR : IR port map (
        clk => clk,
        load => load,
        ir_in => ir_in,
        ir_out => ir_out
    );

    -- Process start
     process

        --Prozedur für einen Clock-cycle
        procedure run_cycle is
            begin
            clk <= '0';
            wait for period / 2;
            clk <= '1';
            wait for period / 2;
        end procedure;

        -- Prozedur Test
        procedure test_pc (data: in std_logic_vector(15 downto 0)) is
        begin
            -- Lade Befehl
            run_cycle;
            ir_in <= data;
            load <= '1';
            run_cycle;
            assert ir_out = data
            report "Lade Befehl ist fehlgeschlagen";

            -- Befehl wird gehalten
            run_cycle;
            load <= '0';
            run_cycle;
            assert ir_out = data
            report "Befehl wird gehalten fehlgeschlagen";

            -- Setze neuen Befehl ohne zu laden--
            run_cycle;
            ir_in <= "0000111100001111";
            load <= '0';
            run_cycle;
            assert ir_out = data
            report "Setze neuen Befehl ohne zu laden fehlgeschlagen";

            -- Setze neuen Wert
            run_cycle;
            ir_in <= "1111000011110000";
            load <= '1';
            run_cycle;
            assert ir_out = "1111000011110000"
            report "Setze neuen Wert fehlgeschlagen";

            --Setze neuen Befehl nach halten--
            run_cycle;
            ir_in <= data;
            load <= '1';
            run_cycle;
            assert ir_out = data
            report "Setze neuen Befehl nach halten fehlgeschlagen";
        end procedure;

        -- Internal variable
        variable max: std_logic_vector(15 downto 0) := "1111111111111111";
    begin
    
        -- Test every possible value
        for i in 0 to to_integer(unsigned(max)) loop
            test_pc(std_logic_vector(to_unsigned(i, max'length)));
        end loop;

        --Ende der Testbench
        assert false report "Simulation finished" severity note;
        wait;

    end process;
end TESTBENCH;
