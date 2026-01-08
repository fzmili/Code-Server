FROM codercom/code-server:4.107.0-debian

# --------------------------------------------------
# 1. 系统依赖
# --------------------------------------------------
USER root
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential git curl \
        python3 python3-pip python3-venv python-is-python3\
        php-cli php-curl php-xml php-mbstring \
        rustc cargo golang-go locales \
        nodejs npm \
    && sed -i '/zh_CN.UTF-8/s/^# //g' /etc/locale.gen \
    && locale-gen zh_CN.UTF-8 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

ENV LANG=zh_CN.UTF-8 \
    LANGUAGE=zh_CN:zh \
    LC_ALL=zh_CN.UTF-8
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

# --------------------------------------------------
# 4. VS Code settings（build 阶段）
# --------------------------------------------------
RUN cat <<'EOF' > /home/coder/.local/share/code-server/User/settings.json
{
  "workbench.colorTheme": "Default Dark+",
  "workbench.iconTheme": "vscode-great-icons",
  "editor.fontSize": 14,
  "terminal.integrated.fontSize": 14
}
EOF
# ------------------------------------------------------
# 5.命令行配置文件
# --------------------------------------------
RUN cat <<'EOF' > /home/coder/.config/code-server/config.yaml
bind-addr: 0.0.0.0:8080
auth: none
locale: zh-CN
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

if [ "$RUNTIME_UID" != "1000" ]; then
  echo "Adjust permissions for UID=$RUNTIME_UID"
  chown -R "$RUNTIME_UID:$RUNTIME_GID" /home/coder || true
fi

export HOME=/home/coder

# --------------------------------------------------
# 关键修复点：
# 如果第一个参数是 --xxx，则补上 code-server
# --------------------------------------------------
if [ "${1#-}" != "$1" ]; then
  set -- code-server "$@"
fi

exec "$@"

EOF

RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# --------------------------------------------------
# 6. 运行配置
# --------------------------------------------------
USER root
WORKDIR /home/coder/project
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["code-server"]
