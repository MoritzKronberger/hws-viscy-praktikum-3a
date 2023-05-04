library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- ALU_TB entity declaration
entity ALU_TB is
end ALU_TB;

architecture TESTBENCH of ALU_TB is
    -- Declare ALU component
    component ALU is
        port (
            a: in std_logic_vector (15 downto 0);  -- 16-bit input a
            b: in std_logic_vector (15 downto 0);  -- 16-bit input b
            sel: in std_logic_vector (2 downto 0); -- 3-bit operation selector
            y: out std_logic_vector (15 downto 0); -- 16-bit output
            zero: out std_logic                    -- 0 output (helper for conditional jumps)
        );
    end component;
    
    -- Point ALU component to the submodule's RTL architecture
    for T_ALU: ALU use entity WORK.ALU(RTL);

    -- Internal signals
    signal a, b, y: std_logic_vector (15 downto 0);
    signal sel: std_logic_vector (2 downto 0);
    signal zero: std_logic;
begin
    -- Instantiate ALU
    T_ALU: ALU port map(a => a, b => b, sel => sel, y => y, zero => zero);

    process
        function rand_slv (seed: INTEGER) return std_logic_vector is
            variable r: INTEGER;
            variable bit_s: INTEGER;
            variable a: INTEGER := 214013;
            variable c: INTEGER := 2531001;
            variable max: INTEGER := 2 ** 8;
            variable slv: std_logic_vector(15 downto 0);
        begin
            -- Generate a random value for each of the vector's bits
            for i in slv'range loop
                -- New seed for every bit (clamped)
                bit_s := (seed * (i + 1)) mod max;
                -- Pseudo random value using a linear congruential generator
                -- Reference: https://rosettacode.org/wiki/Linear_congruential_generator
                r := (a * bit_s + c) mod max;
                -- Assign 1 to bit if random value is > max/2 (50:50 chance)
                if r > (max / 2) then
                    slv(i) := '1';
                else
                    slv(i) := '0';
                end if;
            end loop;
            return slv;
        end function;

        -- Toggle debug prints
        variable debug: std_logic := '1';

        procedure test_alu (signal a, b: in std_logic_vector (15 downto 0)) is
            -- Internal variable
            variable t_zero: std_logic;
        begin
            wait for 1 ns;
            -- Debug print test case
            if debug = '1' then
                assert false 
                    report "Testing a="
                        & INTEGER'image(to_integer(signed(a)))
                        & " b="
                        & INTEGER'image(to_integer(signed(b)))
                        severity note;
            end if;

            -- Test add
            sel <= "000";
            wait for 1 ns;
            assert y = std_logic_vector(signed(a) + signed(b))
                report "Received unexpected result for add operation y="
                    & INTEGER'image(to_integer(signed(y)));
            
            -- Test sub
            sel <= "001";
            wait for 1 ns;
            assert y = std_logic_vector(signed(a) - signed(b))
                report "Received unexpected result for sub operation y=" 
                    & INTEGER'image(to_integer(signed(y)));
            
            -- Test left shift
            sel <= "010";
            wait for 1 ns;
            assert y = a(14 downto 0) & '0'
                report "Received unexpected result for left shift operation y="
                    & INTEGER'image(to_integer(signed(y)));
            
            -- Test right shift
            sel <= "011";
            wait for 1 ns;
            assert y = a(15) & a(15 downto 1)
                report "Received unexpected result for right shift operation y="
                    & INTEGER'image(to_integer(signed(y)));
        
            -- Test AND
            sel <= "100";
            wait for 1 ns;
            assert y = (a AND b)
                report "Received unexpected result for AND operation y="
                    & INTEGER'image(to_integer(signed(y)));
            
            -- Test OR
            sel <= "101";
            wait for 1 ns;
            assert y = (a OR b)
                report "Received unexpected result for OR operation y="
                    & INTEGER'image(to_integer(signed(y)));
            
            -- Test XOR
            sel <= "110";
            wait for 1 ns;
            assert y = (a XOR b)
                report "Received unexpected result for XOR operation y="
                    & INTEGER'image(to_integer(signed(y)));
        
            -- Test NOT
            sel <= "111";
            wait for 1 ns;
            assert y = NOT a
                report "Received unexpected result for NOT operation y="
                    & INTEGER'image(to_integer(signed(y)));
        
            -- Test zero output
            sel <= "000";
            wait for 1 ns;
            if b = "0000000000000000" then
                t_zero := '1';
            else
                t_zero := '0';
            end if;
            assert zero = t_zero
                report "Received unexpected value for zero output zero="
                    & INTEGER'image(to_integer(signed'("" & zero)));
        end;
    begin
        a <= "0000000000000000"; -- 0
        b <= "0000000000000000"; -- 0
        test_alu(a, b);
        
        a <= "1111111111111111"; -- max
        b <= "1111111111111111"; -- max
        test_alu(a, b);

        a <= "1111111100000000";
        b <= "0000000011111111";
        test_alu(a, b);

        a <= "0000000011111111";
        b <= "1111111100000000";
        test_alu(a, b);

        -- Test random values
        L: for i in 1 to 1000 loop
               a <= rand_slv(i);
               b <= rand_slv(i + 15);
               test_alu(a, b);
           end loop;

        -- Print a note & finish simulation now
        assert false report "Simulation finished" severity note;
        wait;               -- end simulation
    end process;
end architecture;
