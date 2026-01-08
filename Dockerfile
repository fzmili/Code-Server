FROM codercom/code-server:4.107.0-debian

# --------------------------------------------------
# 1. 系统依赖
# --------------------------------------------------
USER root
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential git curl \
        python3 python3-pip python3-venv \
        php-cli php-curl php-xml php-mbstring \
        rustc cargo golang-go locales \
    && rm -rf /var/lib/apt/lists/*

# --------------------------------------------------
# 2. 准备 coder 目录
# --------------------------------------------------
RUN mkdir -p \
    /home/coder/project \
    /home/coder/.config/code-server \
    /home/coder/.local/share/code-server/User \
    /home/coder/.local/share/code-server/extensions \
 && chown -R coder:coder /home/coder

# --------------------------------------------------
# 3. 安装插件（build 阶段，固定 coder）
# --------------------------------------------------
USER coder
RUN code-server --install-extension llvm-vs-code-extensions.vscode-clangd \
 && code-server --install-extension ms-python.python \
 && code-server --install-extension rust-lang.rust-analyzer \
 && code-server --install-extension golang.go \
 && code-server --install-extension MS-CEINTL.vscode-language-pack-zh-hans

# --------------------------------------------------
# 4. VS Code settings（build 阶段）
# --------------------------------------------------
RUN cat <<'EOF' > /home/coder/.local/share/code-server/User/settings.json
{
  "workbench.colorTheme": "Default Dark+",
  "editor.fontSize": 14,
  "terminal.integrated.fontSize": 14,
  "locale": "zh-cn"
}
EOF

# --------------------------------------------------
# 5. 生成 docker-entrypoint.sh（关键）
# --------------------------------------------------
USER root
RUN cat <<'EOF' > /usr/local/bin/docker-entrypoint.sh
#!/usr/bin/env bash
set -e

RUNTIME_UID=$(id -u)
RUNTIME_GID=$(id -g)

# 如果不是 coder（1000），修正权限
if [ "$RUNTIME_UID" != "1000" ]; then
  echo "Adjust permissions for UID=$RUNTIME_UID"
  chown -R "$RUNTIME_UID:$RUNTIME_GID" /home/coder || true
fi

# 强制使用 coder 的 HOME（插件 & 配置）
export HOME=/home/coder

exec "$@"
EOF

RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# --------------------------------------------------
# 6. 运行配置
# --------------------------------------------------
USER root
WORKDIR /home/coder/project
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["code-server", "--bind-addr", "0.0.0.0:8080", "--auth", "none"]
