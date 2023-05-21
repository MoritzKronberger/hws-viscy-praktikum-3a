library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Programm counter entity declaration
entity PC is
    port (
        clk: in std_logic;                         -- clock signal
        reset, inc, load: in std_logic;            -- commands
        pc_in: in std_logic_vector (15 downto 0);  -- 16-bit input
        pc_out: out std_logic_vector (15 downto 0) -- 16-bit output
    );
end PC;

-- RTL behavior architecture
architecture RTL of PC is
    -- Internal register
    signal reg: std_logic_vector (15 downto 0);
begin
    -- Continuous output
    pc_out <= reg;

    -- State changes
    process (clk)
    begin
        -- On clock rising edge
        if rising_edge(clk) then
            -- Reset command (priority!)
            if reset = '1' then
                reg <= "0000000000000000";
            -- Load input data
            elsif load = '1' then
                reg <= pc_in;
            -- Increment
            elsif inc = '1' then
                reg <= std_logic_vector(unsigned(reg) + 1);
            end if;
        end if;
    end process;
end RTL;
