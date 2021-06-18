--
-------------------------------------------------------------------------------------------
-- Copyright � 2010-2013, Xilinx, Inc.
-- This file contains confidential and proprietary information of Xilinx, Inc. and is
-- protected under U.S. and international copyright and other intellectual property laws.
-------------------------------------------------------------------------------------------
--
-- Disclaimer:
-- This disclaimer is not a license and does not grant any rights to the materials
-- distributed herewith. Except as otherwise provided in a valid license issued to
-- you by Xilinx, and to the maximum extent permitted by applicable law: (1) THESE
-- MATERIALS ARE MADE AVAILABLE "AS IS" AND WITH ALL FAULTS, AND XILINX HEREBY
-- DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY,
-- INCLUDING BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-INFRINGEMENT,
-- OR FITNESS FOR ANY PARTICULAR PURPOSE; and (2) Xilinx shall not be liable
-- (whether in contract or tort, including negligence, or under any other theory
-- of liability) for any loss or damage of any kind or nature related to, arising
-- under or in connection with these materials, including for any direct, or any
-- indirect, special, incidental, or consequential loss or damage (including loss
-- of data, profits, goodwill, or any type of loss or damage suffered as a result
-- of any action brought by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the possibility of the same.
--
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-safe, or for use in any
-- application requiring fail-safe performance, such as life-support or safety
-- devices or systems, Class III medical devices, nuclear facilities, applications
-- related to the deployment of airbags, or any other applications that could lead
-- to death, personal injury, or severe property or environmental damage
-- (individually and collectively, "Critical Applications"). Customer assumes the
-- sole risk and liability of any use of Xilinx products in Critical Applications,
-- subject only to applicable laws and regulations governing limitations on product
-- liability.
--
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS PART OF THIS FILE AT ALL TIMES.
--
-------------------------------------------------------------------------------------------
--
--
-- Production definition of a 2K program for KCPSM6 in a 7-Series device using a 
-- RAMB36E1 primitive.
--
-- Note: The complete 12-bit address bus is connected to KCPSM6 to facilitate future code 
--       expansion with minimum changes being required to the hardware description. 
--       Only the lower 11-bits of the address are actually used for the 2K address range
--       000 to 7FF hex.  
--
-- Program defined by 'touch.fidex.psm'.
--
-- Generated by KCPSM6 Assembler: 2017-12-06 17:09:27 . 
--
-- Assembler used ROM_form template: ROM_form_7S_2K_14March13.vhd
--
--
-- Standard IEEE libraries
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--
-- The Unisim Library is used to define Xilinx primitives. It is also used during
-- simulation. The source can be viewed at %XILINX%\vhdl\src\unisims\unisim_VCOMP.vhd
--  
library unisim;
use unisim.vcomponents.all;
--
--
entity picoblaze_prog_mem is
    Port (      address : in std_logic_vector(11 downto 0);
            instruction : out std_logic_vector(17 downto 0);
                 enable : in std_logic;
                    clk : in std_logic);
    end picoblaze_prog_mem;
--
architecture low_level_definition of picoblaze_prog_mem is
--
signal  address_a : std_logic_vector(15 downto 0);
signal  data_in_a : std_logic_vector(35 downto 0);
signal data_out_a : std_logic_vector(35 downto 0);
signal  address_b : std_logic_vector(15 downto 0);
signal  data_in_b : std_logic_vector(35 downto 0);
signal data_out_b : std_logic_vector(35 downto 0);
signal   enable_b : std_logic;
signal      clk_b : std_logic;
signal       we_b : std_logic_vector(7 downto 0);
--
begin
--
  address_a <= '1' & address(10 downto 0) & "1111";
  instruction <= data_out_a(33 downto 32) & data_out_a(15 downto 0);
  data_in_a <= "00000000000000000000000000000000000" & address(11);
  --
  address_b <= "1111111111111111";
  data_in_b <= "00" & data_out_b(33 downto 32) & "0000000000000000" & data_out_b(15 downto 0);
  enable_b <= '0';
  we_b <= "00000000";
  clk_b <= '0';
  --
  kcpsm6_rom: RAMB36E1
  generic map ( READ_WIDTH_A => 18,
                WRITE_WIDTH_A => 18,
                DOA_REG => 0,
                INIT_A => X"000000000",
                RSTREG_PRIORITY_A => "REGCE",
                SRVAL_A => X"000000000",
                WRITE_MODE_A => "WRITE_FIRST",
                READ_WIDTH_B => 18,
                WRITE_WIDTH_B => 18,
                DOB_REG => 0,
                INIT_B => X"000000000",
                RSTREG_PRIORITY_B => "REGCE",
                SRVAL_B => X"000000000",
                WRITE_MODE_B => "WRITE_FIRST",
                INIT_FILE => "NONE",
                SIM_COLLISION_CHECK => "ALL",
                RAM_MODE => "TDP",
                RDADDR_COLLISION_HWCONFIG => "DELAYED_WRITE",
                EN_ECC_READ => FALSE,
                EN_ECC_WRITE => FALSE,
                RAM_EXTENSION_A => "NONE",
                RAM_EXTENSION_B => "NONE",
                SIM_DEVICE => "7SERIES",
                INIT_00 => X"00141100D204001411D90014119900141199D801180019006002D90119008001",
                INIT_01 => X"4A0E4A0E420C420C320300221C080A1002A000221C031A002002D8011820D208",
                INIT_02 => X"D801584000000000000000004D06D80148B0387F3B800BD01A000DA0500042A0",
                INIT_03 => X"603E9E019E024E0E500060249C01003C1E0AD80138BF4A704A069701003C1E12",
                INIT_04 => X"0000000000000000000000000000000000000000000000000000900119015000",
                INIT_05 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_06 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_07 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_08 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_09 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_0A => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_0B => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_0C => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_0D => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_0E => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_0F => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_10 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_11 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_12 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_13 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_14 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_15 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_16 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_17 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_18 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_19 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_1A => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_1B => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_1C => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_1D => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_1E => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_1F => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_20 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_21 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_22 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_23 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_24 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_25 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_26 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_27 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_28 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_29 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_2A => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_2B => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_2C => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_2D => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_2E => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_2F => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_30 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_31 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_32 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_33 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_34 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_35 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_36 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_37 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_38 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_39 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_3A => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_3B => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_3C => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_3D => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_3E => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_3F => X"2041000000000000000000000000000000000000000000000000000000000000",
                INIT_40 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_41 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_42 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_43 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_44 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_45 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_46 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_47 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_48 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_49 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_4A => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_4B => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_4C => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_4D => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_4E => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_4F => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_50 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_51 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_52 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_53 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_54 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_55 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_56 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_57 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_58 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_59 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_5A => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_5B => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_5C => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_5D => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_5E => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_5F => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_60 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_61 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_62 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_63 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_64 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_65 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_66 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_67 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_68 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_69 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_6A => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_6B => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_6C => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_6D => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_6E => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_6F => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_70 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_71 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_72 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_73 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_74 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_75 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_76 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_77 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_78 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_79 => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_7A => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_7B => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_7C => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_7D => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_7E => X"0000000000000000000000000000000000000000000000000000000000000000",
                INIT_7F => X"0000000000000000000000000000000000000000000000000000000000000000",
               INITP_00 => X"00000000000000000000000000000022D5B6204880060008552020A28A2220D2",
               INITP_01 => X"0000000000000000000000000000000000000000000000000000000000000000",
               INITP_02 => X"0000000000000000000000000000000000000000000000000000000000000000",
               INITP_03 => X"0000000000000000000000000000000000000000000000000000000000000000",
               INITP_04 => X"0000000000000000000000000000000000000000000000000000000000000000",
               INITP_05 => X"0000000000000000000000000000000000000000000000000000000000000000",
               INITP_06 => X"0000000000000000000000000000000000000000000000000000000000000000",
               INITP_07 => X"8000000000000000000000000000000000000000000000000000000000000000",
               INITP_08 => X"0000000000000000000000000000000000000000000000000000000000000000",
               INITP_09 => X"0000000000000000000000000000000000000000000000000000000000000000",
               INITP_0A => X"0000000000000000000000000000000000000000000000000000000000000000",
               INITP_0B => X"0000000000000000000000000000000000000000000000000000000000000000",
               INITP_0C => X"0000000000000000000000000000000000000000000000000000000000000000",
               INITP_0D => X"0000000000000000000000000000000000000000000000000000000000000000",
               INITP_0E => X"0000000000000000000000000000000000000000000000000000000000000000",
               INITP_0F => X"0000000000000000000000000000000000000000000000000000000000000000")
  port map(   ADDRARDADDR => address_a,
                  ENARDEN => enable,
                CLKARDCLK => clk,
                    DOADO => data_out_a(31 downto 0),
                  DOPADOP => data_out_a(35 downto 32), 
                    DIADI => data_in_a(31 downto 0),
                  DIPADIP => data_in_a(35 downto 32), 
                      WEA => "0000",
              REGCEAREGCE => '0',
            RSTRAMARSTRAM => '0',
            RSTREGARSTREG => '0',
              ADDRBWRADDR => address_b,
                  ENBWREN => enable_b,
                CLKBWRCLK => clk_b,
                    DOBDO => data_out_b(31 downto 0),
                  DOPBDOP => data_out_b(35 downto 32), 
                    DIBDI => data_in_b(31 downto 0),
                  DIPBDIP => data_in_b(35 downto 32), 
                    WEBWE => we_b,
                   REGCEB => '0',
                  RSTRAMB => '0',
                  RSTREGB => '0',
               CASCADEINA => '0',
               CASCADEINB => '0',
            INJECTDBITERR => '0',
            INJECTSBITERR => '0');
--
--
end low_level_definition;
--
------------------------------------------------------------------------------------
--
-- END OF FILE picoblaze_prog_mem.vhd
--
------------------------------------------------------------------------------------