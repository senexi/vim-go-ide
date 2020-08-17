FROM golang:latest

RUN apt-get update && apt-get -y install vim nodejs

RUN curl --fail -L https://github.com/neovim/neovim/releases/download/v0.4.4/nvim-linux64.tar.gz|tar xzfv - && mv nvim-linux64/bin/nvim /usr/bin

#RUN nvim +PlugInstall && nvim +GoInstallBinaries

# add dev user
RUN adduser dev --disabled-password --gecos ""                          && \
    echo "ALL            ALL = (ALL) NOPASSWD: ALL" >> /etc/sudoers     && \
    chown -R dev:dev /home/dev /go

COPY nvim-linux64/share /share

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && apt-get update && apt-get install yarn

USER dev
ENV HOME /home/dev

WORKDIR ${HOME} 

#RUN go get github.com/klauspost/asmfmt/cmd/asmfmt

COPY init.vim ${HOME}/.config/nvim/
RUN nvim --headless +PlugInstall  +qall
RUN nvim --headless +"CocInstall coc-go coc-json" +qall
COPY coc-settings.json ${HOME}/.config/nvim
CMD "/bin/bash"

