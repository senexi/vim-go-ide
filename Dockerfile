FROM arm64v8/ubuntu:groovy

RUN apt-get update -y && apt-get -y install vim \
	nodejs \
	silversearcher-ag \
	protobuf-compiler \
	postgresql-client \
	less \
    mpv \
	zsh \
    git \
    gnupg \
    make \
    wget \
    gcc \
    exuberant-ctags \
    curl \
    neovim \
    zip \
    yarn

RUN wget -c https://dl.google.com/go/go1.16.3.linux-arm64.tar.gz -O - | tar -xz -C /usr/local && \
    mkdir /go && \
    printf 'export GOPATH=/go \n\
export GOBIN=$GOPATH/bin \n\
export PATH=$PATH:$GOPATH/bin \n\
export GOROOT=/usr/local/go \n\
export PATH=$PATH:$GOROOT/bin' >> /etc/profile

# add dev user
RUN adduser dev --disabled-password --gecos ""                          && \
    echo "ALL            ALL = (ALL) NOPASSWD: ALL" >> /etc/sudoers     && \
    chown -R dev:dev /home/dev /go && \
    chgrp -R 0 /home/dev /go && \
    chmod -R g+rwX /home/dev /go
#    chsh -s /usr/bin/zsh dev \

USER dev
ENV HOME /home/dev
ENV GOROOT /usr/local/go
ENV GOPATH /go
ENV GOBIN /go/bin
ENV PATH $GOBIN:$PATH
ENV PATH $GOROOT/bin:$PATH
WORKDIR ${HOME} 

COPY --chown=dev:0 init.vim ${HOME}/.config/nvim/
RUN nvim --headless +PlugInstall  +qall && nvim --headless +"CocInstall coc-go coc-json" +qall
COPY --chown=dev:0 coc-settings.json ${HOME}/.config/nvim

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

COPY --chown=dev:0 .p10k.zsh ${HOME}/.p10k.zsh
COPY --chown=dev:0 .zshrc ${HOME}/.zshrc
CMD "exec zsh"

