# syntax=docker/dockerfile:1.4
FROM codercom/code-server:4.107.0-39


# 1. 先把 coder 用户的主目录准备好
USER root
RUN mkdir -p /home/coder/project \
 && mkdir -p /home/coder/.local/share/code-server/User \
 && chown -R coder:coder /home/coder

# 2. 换到 coder 身份再装插件（关键）
USER coder
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
 && code-server --install-extension emmanuelbeziat.vscode-great-icons

# 3. 如果还要装系统包，再切回 root（可选）
USER root
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential git curl \
        python3 python3-pip python3-venv \
        php-cli php-curl php-xml php-mbstring \
        rustc cargo golang-go locales && \
    rm -rf /var/lib/apt/lists/*

# 4. 配置Code-Server环境
RUN cat > /home/coder/.local/share/code-server/User/settings.json << SETTINGS
{
  "workbench.colorTheme": "Default Dark",   // 想换别的主题改这里
  "workbench.iconTheme": "vscode-great-icons",
  "editor.fontSize": 14,
  "terminal.integrated.fontSize": 14,
  "code-runner.runInTerminal": true
}
SETTINGS && chown coder:coder /home/coder/.local/share/code-server/User/settings.json

RUN cat > /home/coder/.local/share/code-server/User/locale.json << LOCALE
{
  "locale": "zh-CN"
}
LOCALE && chown coder:coder /home/coder/.local/share/code-server/User/locale.json


# 4. 最终仍以 coder 启动
USER coder
WORKDIR /home/coder/project
CMD ["code-server", "--bind-addr", "0.0.0.0:8080", "--auth", "none"]
