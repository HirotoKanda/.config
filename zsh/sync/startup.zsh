fastfetch
ls

restore_stderr() {
  [[ -o interactive && -t 1 && ! -t 2 ]] && exec 2>&1
}
precmd_functions+=(restore_stderr)