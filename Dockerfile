# 前端开发中，时常需要使用 shell 命令，而有一个较为完整的环境比较重要，因此选择了使用 ubuntu 作为基础，若在意容器大小的话，可自行选择适用的基础镜像
FROM ubuntu
LABEL org.opencontainers.image.authors="ycyin8795@163.com"

# 设置时区
ARG TZ=Asia/Shanghai
ENV TZ ${TZ}
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 用 root 用户操作
USER root

# 更换阿里云源，在国内可以加快速度
RUN sed -i s@/archive.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list
RUN apt-get clean
RUN apt-get update

# 更新源，安装相应工具
RUN apt-get install -y \
    zsh \
    vim \
    wget \
    curl \
    lsof \
    sudo \
    git

# 安装 oh my zsh
RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# 安装 nvm 和 node14
ENV NVM_DIR=~/.nvm \
    DEFAULT_NODE_VERSION=v14
RUN mkdir -p $NVM_DIR && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash && \
    . $NVM_DIR/nvm.sh && \
    nvm install ${DEFAULT_NODE_VERSION} \
    nvm use ${DEFAULT_NODE_VERSION} && \
    nvm alias ${DEFAULT_NODE_VERSION} && \
    ln -s `npm bin --global` /home/.node-bin && \
    npm install --global nrm && \
    nrm use taobao && \
    echo '' >> ~/.zshrc && \
    echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.zshrc && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm' >> ~/.zshrc

# 安装 yarn
RUN curl -o- -L https://yarnpkg.com/install.sh | bash; \
    echo '' >> ~/.zshrc && \
    echo 'export PATH="$HOME/.yarn/bin:$PATH"' >> ~/.zshrc

# Add PATH for node & YARN
ENV PATH $PATH:/home/.node-bin:/home/.yarn/bin

WORKDIR /

ENTRYPOINT ["/bin/zsh"]