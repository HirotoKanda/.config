--@type LazyPluginSpec
return {
  "wassup05/fortran.nvim",
  lazy = true,
  -- load the plugin when `ft` is fortran
  ft = { "fortran" },
  opts = {
    server_opts = {
      args = {
        "--notify_init",
        "--lowercase_intrinsics",
        "--hover_signature",
        "--hover_language=fortran",
        "--use_signature_help",
        "--enable_code_actions",
        "--disable_autoupdate",
      },
    },
  }
}
