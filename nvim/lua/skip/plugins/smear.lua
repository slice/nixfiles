---@type LazySpec
return {
  {
    'sphamba/smear-cursor.nvim',
    cond = not HEADLESS,
    opts = {
      smear_insert_mode = false,
      smear_terminal_mode = true,

      legacy_computing_symbols_support = true,
      legacy_computing_symbols_support_vertical_bars = true,

      never_draw_over_target = true,
      particles_over_text = false,

      cursor_color = '#ff0000',
      gradient_exponent = 0,

      time_interval = 16, -- 60fps
      damping = 0.85,

      -- since we use conform.nvim, prevent jumping up to the top left corner
      -- a bunch when we format
      --
      -- (https://github.com/sphamba/smear-cursor.nvim/issues/78)
      delay_event_to_smear = 50,

      particle_damping = 0.15,
      particle_gravity = 40,
      particle_max_lifetime = 1000,
      particle_max_num = 50,
      particle_random_velocity = 0,
      particle_spread = 0.5,
      particle_velocity_from_cursor = 1,
      particles_enabled = true,
      particles_per_length = 2,

      windows_zindex = 9999,
    },
  },
}
