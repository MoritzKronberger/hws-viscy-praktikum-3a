LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY ALU IS
	PORT (
		a : IN STD_LOGIC_VECTOR (15 DOWNTO 0); -- Eingang A
		b : IN STD_LOGIC_VECTOR (15 DOWNTO 0); -- Eingang B
		sel : IN STD_LOGIC_VECTOR (2 DOWNTO 0); -- Operation
		y : OUT STD_LOGIC_VECTOR (15 DOWNTO 0); -- Ausgang
		zero : OUT STD_LOGIC -- gesetzt, falls Eingang B = 0
	);
END ALU;

ARCHITECTURE RTL OF ALU IS
BEGIN
	PROCESS (a, b, sel)
	BEGIN
		CASE sel IS
			WHEN "000" => y <= std_logic_vector(signed(a) + signed(b)); -- add
			WHEN "001" => y <= std_logic_vector(signed(a) - signed(b)); -- sub
			WHEN "010" => y <= std_logic_vector(shift_left(signed(a), 1)); -- sal
			WHEN "011" => y <= std_logic_vector(shift_right(signed(b), 1)); -- sar
			WHEN "100" => y <= a AND b; -- and
			WHEN "101" => y <= a OR b; -- or
			WHEN "110" => y <= a XOR b; -- xor
			WHEN "111" => y <= NOT b; -- not
            WHEN others => y <= "0000000000000000";
		END CASE;

		IF b = "0000000000000000" THEN
			zero <= '1';
		ELSE
			zero <= '0';
		END IF;
    END PROCESS;
END RTL;

