# 使用官方的 Ubuntu 20.04 作为基础镜像
FROM ubuntu:20.04

# 设置环境变量以避免交互式安装时的提示
ENV DEBIAN_FRONTEND=noninteractive

# 替换 APT 源为阿里云镜像
RUN sed -i 's|http://archive.ubuntu.com|http://mirrors.aliyun.com|g' /etc/apt/sources.list && \
    sed -i 's|http://security.ubuntu.com|http://mirrors.aliyun.com|g' /etc/apt/sources.list

# 安装必要的依赖
RUN apt-get update && apt-get install -y \
    curl \
    build-essential \
    cmake \
    clang \
    git \
    python3 \
    python3-pip \
    openjdk-8-jdk \
    unzip \
    wget \
    && rm -rf /var/lib/apt/lists/*

# 配置 Rustup 使用阿里云镜像
ENV RUSTUP_DIST_SERVER=https://mirrors.aliyun.com/rustup
ENV RUSTUP_UPDATE_ROOT=https://mirrors.aliyun.com/rustup/rustup

# 安装 Rust 和 Cargo
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# 配置 Cargo 使用阿里云镜像
RUN mkdir -p /root/.cargo && \
    echo '[source.crates-io]' > /root/.cargo/config.toml && \
    echo 'replace-with = "aliyun"' >> /root/.cargo/config.toml && \
    echo '[source.aliyun]' >> /root/.cargo/config.toml && \
    echo 'registry = "sparse+https://mirrors.aliyun.com/crates.io-index/"' >> /root/.cargo/config.toml

# 安装 Android NDK 27c
RUN wget https://dl.google.com/android/repository/android-ndk-r27c-linux.zip -O /tmp/android-ndk.zip && \
    unzip /tmp/android-ndk.zip -d /opt && \
    rm /tmp/android-ndk.zip
ENV ANDROID_NDK_HOME="/opt/android-ndk-r27c"
ENV PATH="${ANDROID_NDK_HOME}/toolchains/llvm/prebuilt/linux-x86_64/bin:${PATH}"

# 安装 Rust 的 Android 目标
RUN rustup target add aarch64-linux-android armv7-linux-androideabi i686-linux-android x86_64-linux-android

# 创建全局的 .cargo/config.toml 文件（配置 Android 交叉编译工具链）
RUN echo '[target.aarch64-linux-android]' >> /root/.cargo/config.toml && \
    echo 'ar = "/opt/android-ndk-r27c/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android-ar"' >> /root/.cargo/config.toml && \
    echo 'linker = "/opt/android-ndk-r27c/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android33-clang"' >> /root/.cargo/config.toml && \
    echo '[target.armv7-linux-androideabi]' >> /root/.cargo/config.toml && \
    echo 'ar = "/opt/android-ndk-r27c/toolchains/llvm/prebuilt/linux-x86_64/bin/arm-linux-androideabi-ar"' >> /root/.cargo/config.toml && \
    echo 'linker = "/opt/android-ndk-r27c/toolchains/llvm/prebuilt/linux-x86_64/bin/armv7a-linux-androideabi33-clang"' >> /root/.cargo/config.toml && \
    echo '[target.i686-linux-android]' >> /root/.cargo/config.toml && \
    echo 'ar = "/opt/android-ndk-r27c/toolchains/llvm/prebuilt/linux-x86_64/bin/i686-linux-android-ar"' >> /root/.cargo/config.toml && \
    echo 'linker = "/opt/android-ndk-r27c/toolchains/llvm/prebuilt/linux-x86_64/bin/i686-linux-android33-clang"' >> /root/.cargo/config.toml && \
    echo '[target.x86_64-linux-android]' >> /root/.cargo/config.toml && \
    echo 'ar = "/opt/android-ndk-r27c/toolchains/llvm/prebuilt/linux-x86_64/bin/x86_64-linux-android-ar"' >> /root/.cargo/config.toml && \
    echo 'linker = "/opt/android-ndk-r27c/toolchains/llvm/prebuilt/linux-x86_64/bin/x86_64-linux-android33-clang"' >> /root/.cargo/config.toml

# 设置工作目录
WORKDIR /workspace

# 默认命令
CMD ["bash"]
