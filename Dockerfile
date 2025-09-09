FROM docker.io/mstorsjo/llvm-mingw:20250826

ENV RUSTUP_HOME=/usr/local/rustup
ENV CARGO_HOME=/usr/local/cargo
ENV PATH=/usr/local/cargo/bin:$PATH
ENV RUST_VERSION=1.87.0
ENV RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static
ENV RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup

RUN dpkg --add-architecture arm64&&rm -rf /etc/apt/sources.list.d/ubuntu.sources
RUN echo '\n\
  deb [arch=amd64] http://archive.ubuntu.com/ubuntu/ noble main restricted universe multiverse\n\
  deb [arch=amd64] http://archive.ubuntu.com/ubuntu/ noble-updates main restricted universe multiverse\n\
  deb [arch=amd64] http://archive.ubuntu.com/ubuntu/ noble-backports main restricted universe multiverse\n\
  deb [arch=amd64] http://archive.ubuntu.com/ubuntu/ noble-security main restricted universe multiverse\n\
  deb [arch=arm64] https://ports.ubuntu.com/ubuntu-ports/ noble main restricted universe multiverse\n\
  deb [arch=arm64] https://ports.ubuntu.com/ubuntu-ports/ noble-updates main restricted universe multiverse\n\
  deb [arch=arm64] https://ports.ubuntu.com/ubuntu-ports/ noble-backports main restricted universe multiverse\n\
  deb [arch=arm64] https://ports.ubuntu.com/ubuntu-ports/ noble-security main restricted universe multiverse\n\
  ' > /etc/apt/sources.list && apt-get update --ignore-missing && apt-get install -y musl-dev musl-dev:arm64 nsis && apt-get clean
RUN rm -rf /var/lib/apt/lists/*

RUN curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain $RUST_VERSION
RUN rustup target add \
  aarch64-unknown-linux-musl x86_64-unknown-linux-musl \
  aarch64-pc-windows-gnullvm x86_64-pc-windows-gnullvm \
  x86_64-pc-windows-msvc
RUN wget -qO- https://get.pnpm.io/install.sh | ENV="$HOME/.bashrc" SHELL="$(which bash)" bash -
RUN pnpm env use --global 20
