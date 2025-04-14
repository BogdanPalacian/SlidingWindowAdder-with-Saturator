library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity tb_saturator is
-- Testbench has no ports
end tb_saturator;

architecture Behavioral of tb_saturator is
    -- Component declaration for the unit under test (UUT)
    component saturator is
      Port (
        aclk : IN STD_LOGIC;
        s_axis_val_tvalid : IN STD_LOGIC;
        s_axis_val_tready : OUT STD_LOGIC;
        s_axis_val_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        s_axis_max_tvalid : IN STD_LOGIC;
        s_axis_max_tready : OUT STD_LOGIC;
        s_axis_max_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        s_axis_min_tvalid : IN STD_LOGIC;
        s_axis_min_tready : OUT STD_LOGIC;
        s_axis_min_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        m_axis_result_tvalid : OUT STD_LOGIC;
        m_axis_result_tready : IN STD_LOGIC;
        m_axis_result_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
      );
    end component;

    -- Signals for connecting to the UUT
    signal aclk : STD_LOGIC := '0';
    signal s_axis_val_tvalid : STD_LOGIC := '0';
    signal s_axis_val_tready : STD_LOGIC;
    signal s_axis_val_tdata : STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
    signal s_axis_max_tvalid : STD_LOGIC := '0';
    signal s_axis_max_tready : STD_LOGIC;
    signal s_axis_max_tdata : STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
    signal s_axis_min_tvalid : STD_LOGIC := '0';
    signal s_axis_min_tready : STD_LOGIC;
    signal s_axis_min_tdata : STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
    signal m_axis_result_tvalid : STD_LOGIC;
    signal m_axis_result_tready : STD_LOGIC := '0';
    signal m_axis_result_tdata : STD_LOGIC_VECTOR(31 DOWNTO 0);

    
    constant CLK_PERIOD : time := 10 ns;


begin

    clk: process
    begin    
            aclk <= '0';
            wait for CLK_PERIOD / 2;
            aclk <= '1';
            wait for CLK_PERIOD / 2;
    end process;
 
    UUT: saturator Port map (
            aclk => aclk,
            s_axis_val_tvalid => s_axis_val_tvalid,
            s_axis_val_tready => s_axis_val_tready,
            s_axis_val_tdata => s_axis_val_tdata,
            s_axis_max_tvalid => s_axis_max_tvalid,
            s_axis_max_tready => s_axis_max_tready,
            s_axis_max_tdata => s_axis_max_tdata,
            s_axis_min_tvalid => s_axis_min_tvalid,
            s_axis_min_tready => s_axis_min_tready,
            s_axis_min_tdata => s_axis_min_tdata,
            m_axis_result_tvalid => m_axis_result_tvalid,
            m_axis_result_tready => m_axis_result_tready,
            m_axis_result_tdata => m_axis_result_tdata
        );

  
    process
    begin
        -- Test Case 1: Input within range
        s_axis_val_tdata <= X"00000010"; -- val = 16
        s_axis_max_tdata <= X"00000020"; -- max = 32
        s_axis_min_tdata <= X"00000005"; -- min = 5
        s_axis_val_tvalid <= '1';
        s_axis_max_tvalid <= '1';
        s_axis_min_tvalid <= '1';
        m_axis_result_tready <= '1';
        wait for CLK_PERIOD;
        wait until s_axis_val_tready = '1';

        -- Wait for result
        wait until m_axis_result_tvalid = '1';
        assert m_axis_result_tdata = X"00000010" -- Expected: 16
        report "Test Case 1 Failed!" severity error;

        -- Test Case 2: Input above max
        s_axis_val_tdata <= X"00000040"; -- val = 64
        wait for CLK_PERIOD;
        wait until s_axis_val_tready = '1';

        -- Wait for result
        wait until m_axis_result_tvalid = '1';
        assert m_axis_result_tdata = X"00000020" -- Expected: 32
        report "Test Case 2 Failed!" severity error;

        -- Test Case 3: Input below min
        s_axis_val_tdata <= X"00000003"; -- val = 3
        wait for CLK_PERIOD;
        wait until s_axis_val_tready = '1';

        -- Wait for result
        wait until m_axis_result_tvalid = '1';
        assert m_axis_result_tdata = X"00000005" -- Expected: 5
        report "Test Case 3 Failed!" severity error;

        
        report "All test cases passed!";
        wait;
    end process;

end Behavioral;
