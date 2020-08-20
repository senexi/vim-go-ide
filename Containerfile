FROM golang:latest

RUN apt-get update && apt-get -y install vim nodejs silversearcher-ag protobuf-compiler

RUN curl --fail -L https://github.com/neovim/neovim/releases/download/v0.4.4/nvim-linux64.tar.gz|tar xzfv - && mv nvim-linux64/bin/nvim /usr/bin && mv nvim-linux64/share /

# add dev user
RUN adduser dev --disabled-password --gecos ""                          && \
    echo "ALL            ALL = (ALL) NOPASSWD: ALL" >> /etc/sudoers     && \
    chown -R dev:dev /home/dev /go

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && apt-get update && apt-get install yarn

USER dev
ENV HOME /home/dev

WORKDIR ${HOME} 

COPY init.vim ${HOME}/.config/nvim/
RUN nvim --headless +PlugInstall  +qall && nvim --headless +"CocInstall coc-go coc-json" +qall
COPY coc-settings.json ${HOME}/.config/nvim

# install protobuf support 
RUN go get -u -v github.com/golang/protobuf/protoc-gen-go && \
    go get -u -v github.com/gogo/protobuf/protoc-gen-gofast && \
    go get -u -v github.com/gogo/protobuf/proto && \
    go get -u -v github.com/gogo/protobuf/protoc-gen-gogoslick && \
    go get -u -v github.com/gogo/protobuf/gogoproto && \
    go get -u -v github.com/pseudomuto/protoc-gen-doc/cmd/protoc-gen-doc && \
    go get -u -v github.com/grpc-ecosystem/grpc-gateway/protoc-gen-grpc-gateway && \
    go get -u -v github.com/grpc-ecosystem/grpc-gateway/protoc-gen-swagger && \
    go get -u -v github.com/gogo/googleapis/...

#configure git to use ssh instead of https
RUN git config --global user.email "dev@go.com" && \
    git config --global user.name "dev" && \
    git config --global url."git@github.com:".insteadOf "https://github.com/" 

CMD "/bin/bash"

