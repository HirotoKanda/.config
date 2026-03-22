[[ -o interactive && -t 1 && ! -t 2 ]] && exec 2>&1
eval "$(sheldon source)"
