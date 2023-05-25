LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY CPU IS
	PORT (
		clk : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		adr : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		rdata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
		wdata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		rd : OUT STD_LOGIC;
		wr : OUT STD_LOGIC;
		ready : IN STD_LOGIC
	);
END CPU;

ARCHITECTURE RTL OF CPU IS
	-- Component declarations
	COMPONENT ALU IS
		PORT (
			a : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
			b : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
			sel : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
			y : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
			zero : OUT STD_LOGIC
		);
	END COMPONENT;

	COMPONENT IR IS
		PORT (
			clk : IN STD_LOGIC;
			load : IN STD_LOGIC;
			ir_in : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
			ir_out : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT PC IS
		PORT (
			clk : IN STD_LOGIC;
			reset, inc, load : IN STD_LOGIC;
			pc_in : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
			pc_out : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT REGFILE IS
		PORT (
			clk : IN STD_LOGIC;
			in_data : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
			in_sel : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
			out0_data : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
			out0_sel : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
			out1_data : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
			out1_sel : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
			load_lo, load_hi : IN STD_LOGIC
		);
	END COMPONENT;

	COMPONENT CONTROLLER IS
		PORT (
			clk : IN STD_LOGIC;
			reset : IN STD_LOGIC;

			ir : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
			ready : IN STD_LOGIC;
			zero : IN STD_LOGIC;

			c_reg_ldmem,
			c_reg_ldi,
			c_regfile_load_lo,
			c_regfile_load_hi,
			c_pc_load,
			c_pc_inc,
			c_ir_load,
			c_mem_rd,
			c_mem_wr,
			c_adr_pc_not_reg : OUT STD_LOGIC
		);
	END COMPONENT;

	-- Configuration
	FOR ALL : ALU USE ENTITY WORK.ALU(RTL);
	FOR ALL : IR USE ENTITY WORK.IR(RTL);
	FOR ALL : PC USE ENTITY WORK.PC(RTL);
	FOR ALL : REGFILE USE ENTITY WORK.REGFILE(RTL);
	FOR ALL : CONTROLLER USE ENTITY WORK.CONTROLLER(RTL);

	-- Internal Signals

	-- ALU
	SIGNAL alu_y : STD_LOGIC_VECTOR (15 DOWNTO 0);
	SIGNAL alu_zero : STD_LOGIC;

	-- IR
	SIGNAL ir_out : STD_LOGIC_VECTOR (15 DOWNTO 0);

	-- PC
	SIGNAL pc_out : STD_LOGIC_VECTOR (15 DOWNTO 0);

	-- REGFILE
	SIGNAL regfile_out0_data, regfile_out1_data, regfile_in_data : STD_LOGIC_VECTOR (15 DOWNTO 0);

	-- CONTROLLER
	SIGNAL c_pc_load, c_pc_inc : STD_LOGIC;
	SIGNAL c_ir_load : STD_LOGIC;
	SIGNAL c_regfile_load_lo, c_regfile_load_hi : STD_LOGIC;
	SIGNAL c_reg_ldmem, c_reg_ldi : STD_LOGIC;
	SIGNAL c_adr_pc_not_reg : STD_LOGIC;
	SIGNAL c_mem_rd, c_mem_wr : STD_LOGIC;

BEGIN
	-- Component instatiations
	U_ALU : ALU PORT MAP(
		a => regfile_out0_data,
		b => regfile_out1_data,
		y => alu_y,
		sel => ir_out(13 DOWNTO 11),
		zero => alu_zero
	);

	U_IR : IR PORT MAP(
		clk => clk,
		load => c_ir_load,
		ir_in => rdata,
		ir_out => ir_out
	);

	U_PC : PC PORT MAP(
		clk => clk,
		reset => reset,
		inc => c_pc_inc,
		load => c_pc_load,
		pc_in => regfile_out0_data,
		pc_out => pc_out
	);

	U_REGFILE : REGFILE PORT MAP(
		clk => clk,
		in_data => regfile_in_data,
		in_sel => ir_out(10 DOWNTO 8),
		out0_data => regfile_out0_data,
		out0_sel => ir_out(7 DOWNTO 5),
		out1_data => regfile_out1_data,
		out1_sel => ir_out(4 DOWNTO 2),
		load_lo => c_regfile_load_lo,
		load_hi => c_regfile_load_hi
	);

	U_CONTROLLER : CONTROLLER PORT MAP(
		clk => clk,
		reset => reset,

		ir => ir_out(15 DOWNTO 0),
		ready => ready,
		zero => alu_zero,

		-- Auswahl beim Register-Laden
		c_reg_ldmem => c_reg_ldmem,
		c_reg_ldi => c_reg_ldi,

		-- Steuersignale Registerfile
		c_regfile_load_lo => c_regfile_load_lo,
		c_regfile_load_hi => c_regfile_load_hi,

		-- Steuereingänge PC
		c_pc_load => c_pc_load,
		c_pc_inc => c_pc_inc,

		-- Steuereingang IR
		c_ir_load => c_ir_load,

		-- Signale zum Speicher
		c_mem_rd => c_mem_rd,
		c_mem_wr => c_mem_wr,

		-- Auswahl Adress-Quelle
		c_adr_pc_not_reg => c_adr_pc_not_reg
	);

	-- Multiplexer vor Adressbus
	PROCESS (pc_out, regfile_out0_data, c_adr_pc_not_reg)
	BEGIN
		IF c_adr_pc_not_reg = '1' THEN
			adr <= pc_out;
		ELSE
			adr <= regfile_out0_data;
		END IF;
	END PROCESS;

	-- Multiplexer für Regfile
	PROCESS (c_reg_ldi, c_reg_ldmem, ir_out, alu_y, rdata)
	BEGIN
		IF c_reg_ldi = '1' THEN
			regfile_in_data <= ir_out(7 DOWNTO 0) & ir_out(7 DOWNTO 0);
		ELSIF c_reg_ldmem = '1' THEN
			regfile_in_data <= rdata;
		ELSE
			regfile_in_data <= alu_y;
		END IF;
	END PROCESS;

	-- Speicher
	rd <= c_mem_rd;
	wr <= c_mem_wr;
	wdata <= regfile_out1_data;
END RTL;
