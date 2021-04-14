# nvim go IDE in Docker

```
#build with 
#--format docker is important due to comppability issues with k8s
podman build --format docker -t senexi/go-vim:latest .

#run with
podman run -it -w /data -v $(pwd):/data --userns=keep-id --rm --net=host senexi/go-vim:latest /bin/zsh

#set alias
alias vimgo='podman run -it -w /data -v $(pwd):/data --userns=keep-id --rm --net=host senexi/go-vim:latest /bin/zsh'
```
