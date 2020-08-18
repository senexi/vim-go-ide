# nvim go IDE in Docker

```
#run with
podman run -it -w /data -v $(pwd):/data --userns=keep-id --rm --net=host senexi/go-vim:latest /bin/bash

#set alias
alias vimgo='podman run -it -w /data -v $(pwd):/data --userns=keep-id --rm --net=host senexi/go-vim:latest /bin/bash'
```
