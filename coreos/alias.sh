alias ll='ls -l'
alias d='docker '
alias ds='docker ps'
alias di='docker images'
alias drm='docker rm -f $(docker ps -qa)'
alias sd='sudo systemctl'
alias cci='sudo coreos-cloudinit --from-file'
alias j='journalctl'
function nsa { sudo nsenter -p -u -m -i -n -t $(docker inspect -f '{{ .State.Pid }}' $1) ; }
