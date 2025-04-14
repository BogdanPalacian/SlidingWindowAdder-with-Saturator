LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY sliding_window_adder_tb IS
END sliding_window_adder_tb;

ARCHITECTURE arh OF sliding_window_adder_tb IS

    COMPONENT sliding_window_adder IS
        GENERIC(
            WINDOW_SIZE         :       INTEGER);
        PORT(
            aclk                : IN    STD_LOGIC;
            s_axis_val_tvalid   : IN    STD_LOGIC;
            s_axis_val_tready   : OUT   STD_LOGIC;
            s_axis_val_tdata    : IN    STD_LOGIC_VECTOR(31 DOWNTO 0);
            m_axis_sum_tvalid   : OUT   STD_LOGIC;
            m_axis_sum_tready   : IN    STD_LOGIC;
            m_axis_sum_tdata    : OUT   STD_LOGIC_VECTOR(31 DOWNTO 0));
    END COMPONENT;

    -- Testbench signals
    SIGNAL clk                     : STD_LOGIC                     := '0';
    SIGNAL s_axis_val_tvalid_in    : STD_LOGIC                     := '0';
    SIGNAL s_axis_val_tready_out   : STD_LOGIC                     := '0';
    SIGNAL s_axis_val_tdata_in     : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL m_axis_sum_tvalid_out  : STD_LOGIC                     := '0';
    SIGNAL m_axis_sum_tready_in   : STD_LOGIC                     := '0';
    SIGNAL m_axis_sum_tdata_out   : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');

BEGIN

    -- Instantiate the sliding_window_adder component
    uut: sliding_window_adder GENERIC MAP(
        WINDOW_SIZE => 5)  -- Set the window size to 5 for this test
    PORT MAP(
        aclk                => clk,
        s_axis_val_tvalid   => s_axis_val_tvalid_in,
        s_axis_val_tready   => s_axis_val_tready_out,
        s_axis_val_tdata    => s_axis_val_tdata_in,
        m_axis_sum_tvalid   => m_axis_sum_tvalid_out,
        m_axis_sum_tready   => m_axis_sum_tready_in,
        m_axis_sum_tdata    => m_axis_sum_tdata_out);

    -- Clock generation
    clk <= NOT clk AFTER 10 ns;  -- 50 MHz clock

    -- Test process
    stim_proc: PROCESS
    BEGIN
        -- Initialize inputs
        s_axis_val_tvalid_in <= '0';
        s_axis_val_tdata_in <= (OTHERS => '0');
        m_axis_sum_tready_in <= '1';  -- Ready to receive results

        -- Wait for the reset state
        WAIT FOR 20 ns;

        -- Test 1: Apply first value to the adder
        s_axis_val_tvalid_in <= '1';
        s_axis_val_tdata_in <= x"00000001";  -- Send a value of 1
        WAIT FOR 20 ns;  -- Wait for the process to act

        -- Test 2: Apply second value
        s_axis_val_tdata_in <= x"00000002";  -- Send a value of 2
        WAIT FOR 20 ns;

        -- Test 3: Apply third value
        s_axis_val_tdata_in <= x"00000003";  -- Send a value of 3
        WAIT FOR 20 ns;

        -- Test 4: Apply fourth value
        s_axis_val_tdata_in <= x"00000004";  -- Send a value of 4
        WAIT FOR 20 ns;

        -- Test 5: Apply fifth value, completing the window
        s_axis_val_tdata_in <= x"00000005";  -- Send a value of 5
        WAIT FOR 20 ns;

        -- End of tests, finish simulation
        WAIT FOR 20 ns;
        ASSERT FALSE REPORT "Test completed" SEVERITY note;
        WAIT;

    END PROCESS;

END arh;
