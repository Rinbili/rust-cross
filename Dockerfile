FROM mstorsjo/llvm-mingw:latest

ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH \
    RUST_VERSION=1.84.0 \
    RUSTUP_VERSION=1.27.1

RUN echo '\n\
    deb [arch=amd64] http://archive.ubuntu.com/ubuntu/ jammy main restricted universe multiverse\n\
    deb [arch=amd64] http://archive.ubuntu.com/ubuntu/ jammy-updates main restricted universe multiverse\n\
    deb [arch=amd64] http://archive.ubuntu.com/ubuntu/ jammy-backports main restricted universe multiverse\n\
    deb [arch=arm64] https://www.ports.ubuntu.com/ubuntu-ports/ jammy main restricted universe multiverse\n\
    deb [arch=arm64] https://www.ports.ubuntu.com/ubuntu-ports/ jammy-updates main restricted universe multiverse\n\
    deb [arch=arm64] https://www.ports.ubuntu.com/ubuntu-ports/ jammy-backports main restricted universe multiverse\n\
    ' > /etc/apt/sources.list \
    && dpkg --add-architecture arm64 \
    && apt-get update --ignore-missing \
    && apt-get install -y musl-dev musl-dev:arm64 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* 

RUN set -eux; \
    case "${dpkgArch##*-}" in \
        amd64) rustArch='x86_64-unknown-linux-gnu';; \
        armhf) rustArch='armv7-unknown-linux-gnueabihf';; \
        arm64) rustArch='aarch64-unknown-linux-gnu';; \
        i386) rustArch='i686-unknown-linux-gnu';; \
        ppc64el) rustArch='powerpc64le-unknown-linux-gnu';; \
        s390x) rustArch='s390x-unknown-linux-gnu';; \
        *) echo >&2 "unsupported architecture: ${dpkgArch}"; exit 1 ;; \
    esac; \
    url="https://static.rust-lang.org/rustup/archive/${rustup_version}/${rustArch}/rustup-init"; \
    wget "$url"; \
    chmod +x rustup-init; \
    ./rustup-init -y --no-modify-path --profile minimal --default-toolchain $RUST_VERSION --default-host ${rustArch}; \
    rm rustup-init; \
    chmod -R a+w $RUSTUP_HOME $CARGO_HOME; \
    rustup --version; \
    cargo --version; \
    rustc --version; \
    rustup target add \
    aarch64-unknown-linux-musl x86_64-unknown-linux-musl \
    aarch64-pc-windows-gnullvm x86_64-pc-windows-gnullvm;
