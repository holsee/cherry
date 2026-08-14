# Cherry reference environment.
# Every mix task, TS build, and test run happens in this image — locally via the
# devcontainer and in CI via the same build. Drift between the two is a review
# finding. (Windows host note: Elixir is deliberately NOT installed on hosts;
# the container is the sandbox. CI still runs a windows-native leg for path bugs.)
#
# Pins (bumping any of these is a deliberate, reviewed change):
#   Elixir 1.20.2 · Erlang/OTP 28.5.0.4 · Debian bookworm (2026-07-13 snapshot)
#   Node 22 (LTS)
FROM hexpm/elixir:1.20.2-erlang-28.5.0.4-debian-bookworm-20260713

ENV LANG=C.UTF-8 \
    MIX_HOME=/opt/mix \
    HEX_HOME=/opt/hex

# build-essential: NIF compile fallback (MDEx ships precompiled, but never rely on it)
# inotify-tools: file watching for `cherry serve` live reload
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    git \
    gnupg \
    inotify-tools \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Node 22 LTS — the TypeScript toolchain (tsc, esbuild) for theme script islands.
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*

RUN mix local.hex --force && mix local.rebar --force

# The workspace is a bind mount whose host owner never matches the container user.
RUN git config --global --add safe.directory /workspace

WORKDIR /workspace
