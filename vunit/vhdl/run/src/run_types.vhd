-- Run types package provides common types used by all VHDL implementations.
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this file,
-- You can obtain one at http://mozilla.org/MPL/2.0/.
--
-- Copyright (c) 2014-2016, Lars Asplund lars.anders.asplund@gmail.com

use std.textio.all;
use work.dictionary.all;

library ieee;
use ieee.std_logic_1164.all;

package run_types_pkg is
  constant max_locked_time_c : time := 1 ms;
  constant max_n_test_cases_c : natural := 1024;
  constant unknown_num_of_test_cases_c : integer := integer'left;
  constant runner_event : std_logic := '1';
  constant idle_runner  : std_logic := 'Z';

  subtype runner_cfg_t is string; -- Subtype deprecated, use string instead
  constant runner_cfg_default : string := "enabled_test_cases : __all__, output path : , active python runner : false";
  subtype test_cases_t is string;

  type runner_phase_t is (test_runner_entry, test_runner_setup, test_suite_setup, test_case_setup, test_case, test_case_cleanup, test_suite_cleanup, test_runner_cleanup, test_runner_exit, multiple_drivers);

  type phase_locks_t is record
    n_entry_locks : natural;
    n_exit_locks  : natural;
  end record phase_locks_t;
  type phase_locks_array_t is array (runner_phase_t range <>) of phase_locks_t;

  type boolean_array_t is array (integer range <>) of boolean;
  function resolve_runner_flag (
    constant values : boolean_array_t)
    return boolean;
  subtype runner_flag_t is resolve_runner_flag boolean;

  type runner_sync_t is record
    event : std_logic;
    exit_without_errors : runner_flag_t;
    exit_simulation : runner_flag_t;
  end record runner_sync_t;

  type test_case_names_t is array (positive range <>) of line;

  type runner_state_t is record
    active_python_runner : boolean;
    runner_phase : runner_phase_t;
    locks : phase_locks_array_t(test_runner_setup to test_runner_cleanup);
    test_case_names : test_case_names_t(1 to max_n_test_cases_c);
    n_test_cases : integer;
    active_test_case_index : positive;
    test_suite_completed : boolean;
    test_suite_iteration : natural;
    run_test_cases : test_case_names_t(1 to max_n_test_cases_c);
    running_test_case_v : line;
    n_run_test_cases : natural;
    has_run_since_last_loop_check : boolean;
    run_all : boolean;
    test_case_iteration : natural;
    test_case_exit_after_error : boolean;
    test_suite_exit_after_error : boolean;
    runner_cfg : line;
  end record runner_state_t;

end package;

package body run_types_pkg is
  function resolve_runner_flag (
    constant values : boolean_array_t)
    return boolean is
  begin
    for i in values'range loop
      if values(i) = true then
        return true;
      end if;
    end loop;

    return false;
  end;

end package body run_types_pkg;
