library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity tb_top_level is
end tb_top_level;

architecture behavior of tb_top_level is
   
    component top_level is
        Port (
            aclk : IN STD_LOGIC;
            min  : IN STD_LOGIC_VECTOR(31 DOWNTO 0);  
            max  : IN STD_LOGIC_VECTOR(31 DOWNTO 0);  
            value: IN STD_LOGIC_VECTOR(31 DOWNTO 0);  
            sum  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)  
        );
    end component;

    
    signal aclk     : STD_LOGIC := '0';
    signal min      : STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
    signal max      : STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
    signal value    : STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
    signal sum      : STD_LOGIC_VECTOR(31 DOWNTO 0);

begin
   
    uut: top_level
        port map (
            aclk  => aclk,
            min   => min,
            max   => max,
            value => value,
            sum   => sum
        );

    
    clk_process : process
    begin
        aclk <= '0';
        wait for 5 ns;
        aclk <= '1';
        wait for 5 ns;
    end process;

    
    stim_proc: process
    begin
        -- Test 1
        min <= x"00000005";  
        max <= x"00000009";  
        value <= x"00000006"; 
        wait for 20 ns;  

        -- Test 2
        value <= x"00000004"; 
        wait for 20 ns;

        -- Test 3
        value <= x"00000010";  
        wait for 20 ns;

        -- Test 4:
        value <= x"00000005"; 
        wait for 20 ns;

        -- Test 5
        value <= x"00000009";  
        wait for 20 ns;

        -- Test 6
        value <= x"00000008"; 
        wait for 20 ns;

        wait;
    end process;

end behavior;
