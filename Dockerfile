# Base image
FROM node:20-bookworm-slim

# Copy repository
COPY . /metrics
WORKDIR /metrics

# Environment variables
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_BROWSER_PATH=google-chrome-stable
ENV NOKOGIRI_USE_SYSTEM_LIBRARIES=true

# Setup
RUN set -eux; \
  chmod +x /metrics/source/app/action/index.mjs; \
  \
  # Install system dependencies
  apt-get update; \
  apt-get install -y --no-install-recommends \
    xz-utils wget gnupg ca-certificates curl unzip git \
    ruby-full ruby-dev build-essential patch \
    g++ cmake pkg-config libssl-dev python3 \
    libgconf-2-4 libxss1 libx11-xcb1 libxtst6 lsb-release \
    zlib1g-dev liblzma-dev libxml2-dev libxslt1-dev; \
  \
  # Add Chrome repo & install Chrome + fonts
  wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -; \
  echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google.list; \
  apt-get update; \
  apt-get install -y --no-install-recommends \
    google-chrome-stable \
    fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst fonts-freefont-ttf; \
  \
  # Install Deno
  curl -fsSL https://deno.land/x/install/install.sh | DENO_INSTALL=/usr/local sh; \
  \
  # Install Ruby gems (licensed + deps)
  gem install nokogiri licensed; \
  \
  # Install Node dependencies and build
  npm ci; \
  npm run build; \
  \
  # Clean up
  rm -rf /var/lib/apt/lists/* /tmp/*

# Use JSON form for ENTRYPOINT to avoid signal issues
ENTRYPOINT ["node", "/metrics/source/app/action/index.mjs"]
