# 使用官方的 Code-Server 镜像作为基础镜像
FROM codercom/code-server:latest

# 设置环境变量
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

# 切换为root来安装包
USER root

# 为了增强安全性，设置 Code-Server 用户权限
RUN useradd -m coder && \
    usermod -aG sudo coder && \
    echo "coder:coder" | chpasswd && \
    chmod 755 /usr/lib/code-server


# 安装必要的工具和依赖
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    python3-pip \
    python3-dev \
    php-cli \
    php-curl \
    php-xml \
    rustc \
    cargo \
    golang \
    sudo \
    locales \
    && apt-get clean

# 配置中文环境
RUN locale-gen zh_CN.UTF-8
RUN update-locale LANG=zh_CN.UTF-8

# 切换为codr用户，安全性和后期可用行
USER coder
# 安装 VSCode 插件
RUN code-server --install-extension ms-vscode.cpptools \
    && code-server --install-extension ms-python.python \
    && code-server --install-extension php.php-intellisense \
    && code-server --install-extension dbaeumer.vscode-eslint \
    && code-server --install-extension rust-lang.rust \
    && code-server --install-extension golang.go \
    && code-server --install-extension yzhang.markdown-all-in-one \
    && code-server --install-extension ms-vscode.theme-dark-plus \
    && code-server --install-extension GitHub.github-vscode-theme \
    && code-server --install-extension MS-CEINTL.vscode-language-pack-zh-hans \
    && code-server --install-extension formulahendry.code-runner \
    && code-server --install-extension vscode-icons-team.vscode-icons \
    && code-server --install-extension emmanuelbeziat.vscode-great-icons \
    && code-server --install-extension Adrien.VisualStudioDarkTheme \
    && code-server --install-extension gerane.Theme-Monokai

# 设置 Code-Server 的默认工作目录
WORKDIR /home/coder

# 设置 Code-Server 监听端口并启动
CMD ["code-server", "--auth", "none", "--bind-addr", "0.0.0.0:8080"]
