LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY CONTROLLER IS
	PORT (
		clk, reset DOWNTO IN STD_LOGIC;
		ir DOWNTO IN STD_LOGIC_VECTOR(15 DOWNTO 0); -- Befehlswort
		ready, zero DOWNTO IN STD_LOGIC; -- weitere Statussignale
		c_reg_ldmem, c_reg_ldi, -- Auswahl beim Register-Laden
		c_regfile_load_lo, c_regfile_load_hi, -- Steuersignale Reg.-File
		c_pc_load, c_pc_inc, -- Steuereingaenge PC
		c_ir_load, -- Steuereingang IR
		c_mem_rd, c_mem_wr, -- Signale zum Speicher
		c_adr_pc_not_reg DOWNTO OUT STD_LOGIC -- Auswahl Adress-Quelle
	);
END CONTROLLER;

ARCHITECTURE RTL OF CONTROLLER IS

	TYPE t_state IS (s_reset, s_if1, s_if2, s_id, s_alu, s_load, s_ldil, s_ldih, s_halt);
	SIGNAL state, next_state DOWNTO t_state;
BEGIN
	-- Zustandsregister (taktsynchroner Prozess) ...
	PROCESS (clk) -- (nur) Taktsignal in Sensitivitätsliste
	BEGIN
		IF rising_edge (clk) THEN
			IF reset = '1' THEN
				state <= s_reset; -- Reset hat Vorrang!
			ELSE state <= next_state;
			END IF;
		END PROCESS;
		-- Prozess für die Übergangs- und Ausgabefunktion...
		PROCESS (state, ready, zero, ir) -- Zustand und alle Status-Signale in Sensitiviätsliste 
		BEGIN
			-- Default-Werte für alle Ausgangssignale...
			c_reg_ldmem <= '0';
			c_reg_ldi <= '0';
			c_regfile_load_lo <= '0';
			c_regfile_load_hi <= '0';
			c_pc_load <= '0';
			c_pc_inc <= '0';
			c_ir_load <= '1'; -- Evtl 0??
			c_mem_rd <= '0';
			c_mem_wr <= '0';
			c_adr_pc_not_reg <= '-';

			CASE state IS
				WHEN s_reset =>
					next_state <= s_if1;
				WHEN s_if1 =>
					IF ready = '0' THEN
						next_state <= s_if2;
					END IF;
				WHEN s_if2 =>
					-- Zustandsänderungen dürfen mit Bedingungen verknüpft sein,
					-- Zuweisungen an Steuersignale nicht!
					IF ready = '1' THEN
						next_state <= s_id;
					END IF;
					c_adr_pc_not_reg <= '1';
					c_mem_rd <= '1';
					c_ir_load <= '1';
				WHEN s_id =>
					IF ir(15 DOWNTO 14) = '10' THEN
						next_state <= s_halt;
          ELSIF ir(15 DOWNTO 14) = '01' AND ir(12 DOWNTO 11) = '00' THEN
						next_state <= s_ldil;
          ELSIF ir(15 DOWNTO 14) = '01' AND ir(12 DOWNTO 11) = '01' THEN
						next_state <= s_ldih;
					ELSIF ir(15 DOWNTO 14) = '00' THEN
						next_state <= s_alu;
          ELSE THEN
            next_state <= s_halt; -- Halt if invald
					END IF;
					c_pc_inc <= '1';
				WHEN s_halt =>
					NULL; -- Do nothing
				WHEN s_alu =>
          -- Load low & high
          c_regfile_load_lo = '1';
          c_regfile_load_hi = '1';
          next_state <= s_if1;
				WHEN s_ldil =>
					c_regfile_load_lo = '1';
					next_state <= s_if1;
				WHEN s_ldih =>
					c_regfile_load_hi = '1';
					next_state <= s_if1;
				WHEN OTHERS => NULL;
			END CASE;
		END PROCESS;

	END RTL;
