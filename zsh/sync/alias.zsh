# terminal color
# LSCOLORS=exfxcxdxbxegedabagacad
alias ls='lsd -l'
alias tree='lsd -l --tree'
alias vim='nvim'


function custom_cd()
{
  \cd "$@" && ls
}
alias cd='custom_cd'

function custom_mv()
{
  \mv "$@" && ls
}
alias mv='custom_mv'

# reboot shell
alias reboot='exec $SHELL -l'

#application alias

#LaTeX Template commands

alias as="cd ~"

alias update="fastfetch && brew upgrade && brew cleanup && brew doctor"

