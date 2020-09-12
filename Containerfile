FROM golang:latest

RUN apt-get update -y && apt-get -y install vim \
	nodejs \
	silversearcher-ag \
	protobuf-compiler \
	postgresql-client \
	less \
	zsh

RUN curl --fail -L https://github.com/neovim/neovim/releases/download/v0.4.4/nvim-linux64.tar.gz|tar xzfv - && mv nvim-linux64/bin/nvim /usr/bin && mv nvim-linux64/share /

# add dev user
RUN adduser dev --disabled-password --gecos ""                          && \
    echo "ALL            ALL = (ALL) NOPASSWD: ALL" >> /etc/sudoers     && \
    chown -R dev:dev /home/dev /go && \
    chsh -s /usr/bin/zsh dev

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && apt-get update && \
	apt-get install yarn

USER dev
ENV HOME /home/dev

WORKDIR ${HOME} 

COPY init.vim ${HOME}/.config/nvim/
RUN nvim --headless +PlugInstall  +qall && nvim --headless +"CocInstall coc-go coc-json" +qall
COPY coc-settings.json ${HOME}/.config/nvim

# install protobuf support 
RUN go get -u google.golang.org/protobuf/cmd/protoc-gen-go && \
    go get -u google.golang.org/grpc/cmd/protoc-gen-go-grpc && \
    go get -u -v github.com/pseudomuto/protoc-gen-doc/cmd/protoc-gen-doc && \
    go get -u github.com/cweill/gotests/...

#configure git to use ssh instead of https
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended && \
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}/themes/powerlevel10k && \
    git config --global user.email "dev@go.com" && \
    git config --global user.name "dev" && \
    git config --global url."git@github.com:".insteadOf "https://github.com/"

COPY .p10k.zsh ${HOME}/.p10k.zsh
COPY .zshrc ${HOME}/.zshrc

CMD "exec zsh"

