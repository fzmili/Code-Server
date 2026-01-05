# 使用官方的 Code-Server 镜像作为基础镜像
FROM codercom/code-server:latest

# 切换为root来安装包
USER root

# 安装必要的工具和依赖
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        build-essential \
        git \
        curl \
        python3 python3-pip python3-venv \
        php-cli php-curl php-xml php-mbstring \
        rustc cargo \
        golang-go \
        locales \
        sudo \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 安装 VSCode 插件
RUN code-server --install-extension llvm-vs-code-extensions.vscode-clangd \
    && code-server --install-extension ms-python.python \
    && code-server --install-extension felixfbecker.php-intellisense \
    && code-server --install-extension dbaeumer.vscode-eslint \
    && code-server --install-extension rust-lang.rust-analyzer \
    && code-server --install-extension golang.go \
    && code-server --install-extension yzhang.markdown-all-in-one \
    && code-server --install-extension GitHub.github-vscode-theme \
    && code-server --install-extension MS-CEINTL.vscode-language-pack-zh-hans \
    && code-server --install-extension formulahendry.code-runner \
    && code-server --install-extension vscode-icons-team.vscode-icons \
    && code-server --install-extension emmanuelbeziat.vscode-great-icons \
    && code-server --install-extension teabyii.theme-dark-plus \
    && code-server --install-extension monokai.theme-monokai

RUN chown -R coder:coder /home/coder

USER coder
WORKDIR /home/coder

# 默认端口、无密码，按需自行改
CMD ["code-server", "--bind-addr", "0.0.0.0:8080", "--auth", "none"]
