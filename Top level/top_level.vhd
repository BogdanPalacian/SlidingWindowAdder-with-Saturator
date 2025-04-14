library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity top_level is
    Port (
        aclk : IN STD_LOGIC;
        min  : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
        max  : IN STD_LOGIC_VECTOR(31 DOWNTO 0);  
        value: IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
        sum  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)  
    );
end top_level;

architecture Behavioral of top_level is

    
    signal s_axis_val_tvalid : STD_LOGIC;
    signal s_axis_val_tready : STD_LOGIC;
    signal s_axis_val_tdata  : STD_LOGIC_VECTOR(31 DOWNTO 0);

    signal s_axis_max_tvalid : STD_LOGIC;
    signal s_axis_max_tready : STD_LOGIC;
    signal s_axis_max_tdata  : STD_LOGIC_VECTOR(31 DOWNTO 0);

    signal s_axis_min_tvalid : STD_LOGIC;
    signal s_axis_min_tready : STD_LOGIC;
    signal s_axis_min_tdata  : STD_LOGIC_VECTOR(31 DOWNTO 0);

    signal m_axis_result_tvalid : STD_LOGIC;
    signal m_axis_result_tready : STD_LOGIC;
    signal m_axis_result_tdata  : STD_LOGIC_VECTOR(31 DOWNTO 0);

    signal m_axis_sum_tvalid   : STD_LOGIC;
    signal m_axis_sum_tready   : STD_LOGIC;
    signal m_axis_sum_tdata    : STD_LOGIC_VECTOR(31 DOWNTO 0);

   
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

    -- Instantiate the sliding window adder component
    component sliding_window_adder is
        Port (
            aclk : IN STD_LOGIC;
            s_axis_val_tvalid : IN STD_LOGIC;
            s_axis_val_tready : OUT STD_LOGIC;
            s_axis_val_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            m_axis_sum_tvalid : OUT STD_LOGIC;
            m_axis_sum_tready : IN STD_LOGIC;
            m_axis_sum_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    end component;

begin
    
    s_axis_val_tvalid <= '1'; 
    s_axis_val_tdata  <= value;
    s_axis_max_tvalid <= '1'; 
    s_axis_max_tdata  <= max;
    s_axis_min_tvalid <= '1'; 
    s_axis_min_tdata  <= min;

    --Connect saturator to adder 
    s_axis_val_tready <= m_axis_sum_tready; 
    m_axis_sum_tready <= '1';  

    
    u_saturator: saturator
        port map (
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

    
    u_sliding_window_adder: sliding_window_adder
        port map (
            aclk => aclk,
            s_axis_val_tvalid => m_axis_result_tvalid,  
            s_axis_val_tready => s_axis_val_tready,
            s_axis_val_tdata => m_axis_result_tdata,
            m_axis_sum_tvalid => m_axis_sum_tvalid,
            m_axis_sum_tready => m_axis_sum_tready,
            m_axis_sum_tdata => sum  
        );

end Behavioral;
