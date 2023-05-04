entity IR is
port (
clk: in std_logic;
load: in std_logic; -- Steuersignal
ir_in: in std_logic_vector (15 downto 0); -- Dateneingang
ir_out: out std_logic_vector (15 downto 0) -- Datenausgang
);
end IR;

architecture RTL of IR is
begin
	process(clk, load, ir_in)
	begin
	if (rising_edge(clk)) then

	if load <= '1' then
		ir_temp := ir_in;
	else
		ir_out <= ir_temp;

    end if;
end if;
end process;
end RTL;