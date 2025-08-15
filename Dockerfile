FROM docker.1ms.run/ecpe4s/ubuntu20.04

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive \
    LC_CTYPE=C.UTF-8

# 使用国内镜像源加速（可选）
RUN sed -i 's|http://archive.ubuntu.com|http://mirrors.hust.edu.cn|g' /etc/apt/sources.list

# 安装基础编译工具
RUN apt-get update && \
    apt-get install -y \
    build-essential \
    gcc \
    make \
    file \
    findutils \
    && rm -rf /var/lib/apt/lists/*

# 创建挂载点目录
RUN mkdir -p /dojos

# 使用Heredoc语法创建构建脚本
RUN printf '%s\n' \
    '#!/bin/bash' \
    '# 注意：移除了 set -e 和 set -u，改为手动错误处理' \
    '' \
    'process_makefiles() {' \
    '    local dir_path="$1"' \
    '    echo "→ 进入目录: $dir_path"' \
    '' \
    '    if ! cd "$dir_path" 2>/dev/null; then' \
    '        echo "⚠ 目录不存在: $dir_path" >&2' \
    '        return 1' \
    '    fi' \
    '' \
    '    # 检查是否是C项目' \
    '    if ! ls *.c &>/dev/null; then' \
    '        echo "⚠ 忽略: 无C文件" >&2' \
    '        return 0' \
    '    fi' \
    '' \
    '    echo "▶ 执行 make..."' \
    '    if ! make -j$(nproc); then' \
    '        echo "⚠ make 失败!" >&2' \
    '        return 1' \
    '    fi' \
    '' \
    '    echo "✓ 编译成功"' \
    '    return 0' \
    '}' \
    '' \
    'main() {' \
    '    local error_count=0' \
    '    local processed=0' \
    '' \
    '    echo "========================================"' \
    '    echo "开始处理道馆目录: /dojos"' \
    '' \
    '    # 查找所有包含Makefile的目录' \
    '    while IFS= read -r -d $'"'"'\0'"'"' makefile; do' \
    '        dir_path=$(dirname "$makefile")' \
    '        echo "------------------------------"' \
    '        echo "处理项目: $dir_path"' \
    '' \
    '        if process_makefiles "$dir_path"; then' \
    '            ((processed++))' \
    '        else' \
    '            ((error_count++))' \
    '        fi' \
    '    done < <(find /dojos -name Makefile -print0 2>/dev/null)' \
    '' \
    '    echo "========================================"' \
    '    echo "统计:"' \
    '    echo "成功项目: $processed"' \
    '    echo "失败项目: $error_count"' \
    '' \
    '    if [[ $error_count -gt 0 ]]; then' \
    '        echo "[×] 处理完成，但有 $error_count 个错误" >&2' \
    '        exit 1' \
    '    else' \
    '        echo "[√] 所有道馆处理完成"' \
    '        exit 0' \
    '    fi' \
    '}' \
    '' \
    'main "$@"' \
    > /usr/local/bin/build-dojo && \
    chmod +x /usr/local/bin/build-dojo

# 设置入口点
ENTRYPOINT ["build-dojo"]
