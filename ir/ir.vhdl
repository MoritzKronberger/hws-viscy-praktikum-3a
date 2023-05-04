entity IR is
    port (
        clk: in std_logic;
        load: in std_logic; -- Steuersignal
        ir_in: in std_logic_vector (15 downto 0); -- Dateneingang
        ir_out: out std_logic_vector (15 downto 0) -- Datenausgang
    );
    end IR;
    
    architecture RTL of IR is
    -- Temporäres register
    signal ir_temp: std_logic_vector (15 downto 0);
    begin
        -- Output always contains register entry
        ir_out <= ir_temp;
        -- State machine
        process(clk)
        begin
        if (rising_edge(clk)) then
            if load = '1' then
                ir_temp <= ir_in;
            end if;
        end if;
    end process;
end RTL;
