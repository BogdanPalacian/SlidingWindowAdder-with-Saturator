LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY sliding_window_adder IS
    GENERIC(
        WINDOW_SIZE : INTEGER     := 5);
    PORT(
        aclk                : IN    STD_LOGIC;
        s_axis_val_tvalid   : IN    STD_LOGIC;
        s_axis_val_tready   : OUT   STD_LOGIC;
        s_axis_val_tdata    : IN    STD_LOGIC_VECTOR(31 DOWNTO 0);
        m_axis_sum_tvalid   : OUT   STD_LOGIC;
        m_axis_sum_tready   : IN    STD_LOGIC;
        m_axis_sum_tdata    : OUT   STD_LOGIC_VECTOR(31 DOWNTO 0));
END sliding_window_adder;

ARCHITECTURE Behavioral OF sliding_window_adder IS

TYPE state IS (READD, WRITEE);
TYPE window IS ARRAY(0 TO WINDOW_SIZE - 1) OF STD_LOGIC_VECTOR(31 DOWNTO 0);

SIGNAL mySlidingWindow : window                       := (OTHERS => x"0000_0000");
SIGNAL windowPointer : INTEGER                        :=  0;
SIGNAL currentState  : state                          :=  READD;
SIGNAL internalReady : STD_LOGIC                      :=  '0';
SIGNAL externalReady : STD_LOGIC                      :=  '0';
SIGNAL inputsValid   : STD_LOGIC                      :=  '0';
SIGNAL res_valid     : STD_LOGIC                      :=  '0';
SIGNAL result        : STD_LOGIC_VECTOR (31 DOWNTO 0) :=  (OTHERS => '0');

BEGIN
    s_axis_val_tready <= externalReady;
    
    internalReady <= '1' WHEN currentState = READD ELSE '0';
    inputsValid <= s_axis_val_tvalid;
    externalReady <= internalReady AND inputsValid;
    
    m_axis_sum_tvalid <= '1' WHEN currentState = WRITEE ELSE '0';
    m_axis_sum_tdata <= result;
    
    fsm: PROCESS(aclk)
    BEGIN
        IF rising_edge(aclk) THEN
            CASE currentState IS
                WHEN READD =>
                    IF externalReady = '1' AND inputsValid = '1' THEN
                        result <= result + s_axis_val_tdata - mySlidingWindow(windowPointer);
                        mySlidingWindow(windowPointer)  <= s_axis_val_tdata;
                        IF windowPointer < WINDOW_SIZE - 1 THEN
                            windowPointer <= windowPointer + 1;
                        ELSE
                            windowPointer <= 0;
                        END IF;
                        currentState <= WRITEE;
                    END IF;
                WHEN WRITEE =>
                    IF m_axis_sum_tready = '1' THEN
                        currentState <= READD;
                    END IF;
            END CASE;
        END IF; 
    END PROCESS;

END Behavioral;
