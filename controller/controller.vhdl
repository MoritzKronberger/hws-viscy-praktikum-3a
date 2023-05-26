LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY CONTROLLER IS
	PORT (
		clk, reset : IN STD_LOGIC;
		ir : IN STD_LOGIC_VECTOR(15 DOWNTO 0); -- Befehlswort
		ready, zero : IN STD_LOGIC; -- weitere Statussignale
		c_reg_ldmem, c_reg_ldi, -- Auswahl beim Register-Laden
		c_regfile_load_lo, c_regfile_load_hi, -- Steuersignale Reg.-File
		c_pc_load, c_pc_inc, -- Steuereingaenge PC
		c_ir_load, -- Steuereingang IR
		c_mem_rd, c_mem_wr, -- Signale zum Speicher
		c_adr_pc_not_reg : OUT STD_LOGIC -- Auswahl Adress-Quelle
	);
END CONTROLLER;

ARCHITECTURE RTL OF CONTROLLER IS
	TYPE t_state IS (s_reset, s_if1, s_if2, s_id, s_alu, s_ldil, s_ldih, s_wait, s_ld1, s_ld2, s_st, s_jmp, s_jz, s_jnz, s_halt);
	SIGNAL state, next_state : t_state;
BEGIN
	-- Zustandsregister (taktsynchroner Prozess)
	PROCESS (clk) -- (nur) Taktsignal in Sensitivitätsliste
	BEGIN
		IF rising_edge (clk) THEN
			IF reset = '1' THEN
				state <= s_reset; -- Reset hat Vorrang!
			ELSE state <= next_state;
			END IF;
		END IF;
	END PROCESS;

	-- Prozess für die Uebergangs- und Ausgabefunktion
	PROCESS (state, ready, zero, ir) -- Zustand und alle Status-Signale in Sensitiviaetsliste 
	BEGIN
		-- Default-Werte für alle Ausgangssignale
		c_reg_ldi <= '0';
		c_reg_ldmem <= '0';
		c_regfile_load_lo <= '0';
		c_regfile_load_hi <= '0';
		c_pc_load <= '0';
		c_pc_inc <= '0';
		c_ir_load <= '0';
		c_mem_rd <= '0';
		c_mem_wr <= '0';
		c_adr_pc_not_reg <= '0';
		-- Default-Wert für internes Signal
		next_state <= state;

		-- Zustandsaenderungen dürfen mit Bedingungen verknüpft sein
		CASE state IS
			WHEN s_reset =>
				next_state <= s_if1;
			WHEN s_if1 =>
				IF ready = '0' THEN
					next_state <= s_if2;
				END IF;
				-- Else remain at current state (=default)
			WHEN s_if2 =>
				IF ready = '1' THEN
					next_state <= s_id;
				END IF;
				-- Else remain at current state (=default)
			WHEN s_id =>
				CASE ir(15 downto 14) IS
					-- ALU
					WHEN "00" =>
						next_state <= s_alu;
					-- Load (immediate/ memory) and store
					WHEN "01" =>
						CASE ir(12 downto 11) IS
							WHEN "00" =>
								next_state <= s_ldil;
							WHEN "01" => 
								next_state <= s_ldih;
							WHEN "10" =>
								next_state <= s_wait;
							WHEN "11" =>
								next_state <= s_wait;
							WHEN OTHERS =>
								next_state <= s_halt; -- should never be reached
						END CASE;
					-- Jump and halt
					WHEN "10" =>
						CASE ir(12 downto 11) IS
							WHEN "00" => 
								next_state <= s_jmp;
							WHEN "01" =>
								next_state <= s_halt;
							WHEN "10" =>
								IF zero = '0' THEN next_state <= s_jz; ELSE next_state <= s_if1; END IF;
							WHEN "11" =>
								IF zero = '1' THEN next_state <= s_jnz; ELSE next_state <= s_if1; END IF;
							WHEN OTHERS =>
								next_state <= s_halt; -- should never be reached
						END CASE;
					-- Halt for undefined instruction
					WHEN OTHERS =>
						next_state <= s_halt;
				END CASE;
			-- Fetch new instruction after ALU
			WHEN s_alu =>
				next_state <= s_if1;
			-- Fetch new instruction after ldil
			WHEN s_ldil =>
				next_state <= s_if1;
			-- Fetch new instruction after ldih
			WHEN s_ldih =>
				next_state <= s_if1;
			WHEN s_wait =>
				-- If memory ready
				IF ready = '0' THEN
					-- Determine whether to load or store
					CASE ir(12 downto 11) IS
						WHEN "10" =>
							next_state <= s_ld1;
						WHEN "11" =>
							next_state <= s_st;
						WHEN OTHERS =>
							next_state <= s_halt; -- should never be reached
					END CASE;
				END IF;
				-- Else remain at current state (=default)
			WHEN s_ld1 =>
				-- If memory ready to be read/ valid
				IF ready = '1' THEN
					next_state <= s_ld2;
				END IF;
				-- Else remain at current state (=default)
			-- Fetch new instruction after load
			WHEN s_ld2 =>
				next_state <= s_if1;
			-- Fetch new instruction after store
			WHEN s_st =>
				-- If load confirmed by memory
				IF ready = '1' THEN
					next_state <= s_if1;
				END IF;
				-- Else remain at current state (=default)
			-- Fetch new instruction after jump
			WHEN s_jmp =>
				next_state <= s_if1;
			-- Fetch new instruction after jz
			WHEN s_jz =>
				next_state <= s_if1;
			-- Fetch new instruction after jnz
			WHEN s_jnz =>
				next_state <= s_if1;
			WHEN OTHERS =>
				next_state <= s_halt;
		END CASE;

		-- Zuweisungen an Steuersignale duerfen nur von state abhaengig sein!
		CASE state IS
			WHEN s_if2 =>
				c_adr_pc_not_reg <= '1';
				c_mem_rd <= '1';
				c_ir_load <= '1';
			WHEN s_id =>
				c_pc_inc <= '1';
			WHEN s_alu =>
				c_regfile_load_lo <= '1';
				c_regfile_load_hi <= '1';
			WHEN s_ldil =>
				c_regfile_load_lo <= '1';
				c_reg_ldi <= '1';
			WHEN s_ldih =>
				c_regfile_load_hi <= '1';
				c_reg_ldi <= '1';
			-- Signal to memory that CPU wants to load data
			WHEN s_ld1 =>
				c_mem_rd <= '1';
				c_reg_ldmem <= '1';
			-- Actually load data into regfile once memory is ready
			WHEN s_ld2 =>
				c_mem_rd <= '1';
				c_reg_ldmem <= '1';
				c_regfile_load_lo <= '1';
				c_regfile_load_hi <= '1';
			WHEN s_st =>
				c_mem_wr <= '1';
			WHEN s_jmp =>
				c_pc_load <= '1';
			WHEN s_jz =>
				c_pc_load <= '1';
			WHEN s_jnz =>
				c_pc_load <= '1';
			WHEN OTHERS =>
				NULL;
		END CASE;
	END PROCESS;
END RTL;
