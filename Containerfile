FROM alpine:latest

RUN apk add --no-cache coreutils zsh curl fzf less tzdata \
    && ln -fs /usr/share/zoneinfo/UTC /etc/localtime \
    && export SHELL=$(command -v zsh) \
    && curl -fsSL https://gist.githubusercontent.com/poetaman/bdc598ee607e9767fe33da50e993c650/raw/d0146d258a30daacb9aee51deca9410d106e4237/arttime_online_installer.sh | TERM=xterm-256color zsh

ENV SHELL=/bin/zsh LC_ALL=C.UTF-8

CMD ["/root/.local/bin/arttime"]
