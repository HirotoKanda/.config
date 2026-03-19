return {
   -- ref: https://wezfurlong.org/wezterm/config/lua/SshDomain.html
   ssh_domains = {
      -- yazi's image preview on Windows will only work if launched via ssh from WSL
      {
         name = '__home',
         remote_address = '192.168.1.10',
         username = 'Terra',
         multiplexing = 'None',
         assume_shell = 'Posix',
         ssh_option = {
           identityfile = '~/.ssh/id_ed25519',
           port = '22055',
         }
       },
      {
        name = '__remote',
        remote_address = 'fpcf41f812.tkyc101.ap.nuro.jp',
        username = 'Terra',
        multiplexing = 'WezTerm',
        assume_shell = 'Posix',
        ssh_option = {
          identityfile = '~/.ssh/id_ed25519',
          port = '22055'
      }
      }
   },

   -- ref: https://wezfurlong.org/wezterm/multiplexing.html#unix-domains
   unix_domains = {},

   -- ref: https://wezfurlong.org/wezterm/config/lua/WslDomain.html
   wsl_domains = {
      {
         name = 'WSL:Ubuntu',
         distribution = 'Ubuntu',
         username = 'kevin',
         default_cwd = '/home/kevin',
         default_prog = { 'fish', '-l' },
      },
   },
}
