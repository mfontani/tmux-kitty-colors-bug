FROM debian:buster-slim AS kitty_builder

RUN apt-get update && apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    python \
    xz-utils \
    libfontconfig1 \
    libx11-6 libx11-xcb1 \
    libdbus-1-3 \
    libxcb-xkb1 \
    xkb-data \
    libglvnd0 libgl1 libglx0 libegl1 \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*
RUN curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin

FROM debian:buster-slim AS tmux_builder

RUN apt-get update && apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    git \
    build-essential \
    autoconf automake pkg-config \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /src/
WORKDIR /src/

# ARG TMUX_VERSION=3.1b
ARG TMUX_VERSION=3.2-rc
RUN git clone --recursive --branch "$TMUX_VERSION" https://github.com/tmux/tmux
RUN apt-get update && apt-get install -y \
    libevent-dev \
    libncurses-dev \
    bison \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /src/tmux
RUN sh autogen.sh && \
    LDFLAGS=--static ./configure --prefix=/opt/tmux/ && \
    make -j8
RUN make install

FROM kitty_builder
COPY --from=tmux_builder /opt/tmux/bin/tmux /usr/local/bin/tmux
COPY --from=tmux_builder /opt/tmux/share/man/man1/tmux.1 /usr/local/share/man/man1/tmux.1
ADD colortest.sh /usr/local/bin/colortest.sh
ENTRYPOINT ["/root/.local/kitty.app/bin/kitty", "-o", "font_size=22", "tmux", "-f", "/dev/null", "new-session", "colortest.sh"]
