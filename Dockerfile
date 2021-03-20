ARG UBUNTU_VERSION
# https://hub.docker.com/_/ubuntu/
FROM ubuntu:${UBUNTU_VERSION}

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y curl vim git unzip clang \
    xserver-xorg pkg-config libgtk-3-dev curl cmake ninja-build \
    wget gnupg net-tools \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Ubuntu set Locale
RUN apt update && \
    apt upgrade -y -q && \
    apt -y -q install language-pack-ja-base language-pack-ja && \
    locale-gen ja_JP.UTF-8 && \
    rm -rf /var/lib/apt/lists/*
ENV LC_ALL=ja_JP.UTF-8
ENV LC_CTYPE=ja_JP.UTF-8
ENV LANGUAGE=ja_JP:jp
RUN localedef -f UTF-8 -i ja_JP ja_JP.utf8

# set TimeZone
ENV TZ=Asia/Tokyo
RUN echo "${TZ}" > /etc/timezone \
    && rm /etc/localtime \
    && ln -s /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
    && dpkg-reconfigure -f noninteractive tzdata

# コンテナのデバッグ等で便利なソフト導入しておく
RUN apt-get update \
    && apt-get -y install vim netcat git curl wget zip unzip make sudo gcc libc-dev \
    && rm -rf /var/lib/apt/lists/*

# Prerequisites
RUN apt update \
    && apt install -y curl git unzip xz-utils zip libglu1-mesa openjdk-8-jdk wget software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Prepare Android directories and system variables
ARG SDK_BASE_DIR=/usr/local
WORKDIR ${SDK_BASE_DIR}
RUN mkdir -p Android/sdk
ENV ANDROID_SDK_ROOT ${SDK_BASE_DIR}/Android/sdk
RUN mkdir -p .android && touch .android/repositories.cfg
RUN wget -O sdk-tools.zip https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip
RUN unzip sdk-tools.zip && rm sdk-tools.zip
RUN mv tools Android/sdk/tools
RUN cd Android/sdk/tools/bin && yes | ./sdkmanager --licenses
RUN cd Android/sdk/tools/bin && ./sdkmanager "build-tools;29.0.2" "patcher;v4" "platform-tools" "platforms;android-29" "sources;android-29"
ENV PATH "$PATH:${SDK_BASE_DIR}/Android/sdk/platform-tools"

# Prerequisites
RUN apt update \
    && apt install -y openjdk-11-jdk \
    && rm -rf /var/lib/apt/lists/*

# install chrome
RUN echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN apt update \
    && apt install -y google-chrome-stable \
    && rm -rf /var/lib/apt/lists/*

# install android studio
RUN add-apt-repository ppa:maarten-fonville/android-studio
RUN apt update \
    && apt install -y android-studio \
    && rm -rf /var/lib/apt/lists/*

# Download Flutter SDK
RUN git clone https://github.com/flutter/flutter.git
ENV PATH "$PATH:${SDK_BASE_DIR}/flutter/bin"

WORKDIR ${APP_CODE_PATH_CONTAINER}
RUN flutter config --enable-web

# Run basic check to download Dark SDK
RUN flutter doctor

# シェルスクリプトを実行
COPY entrypoint.sh /entrypoint/entrypoint.sh
ENTRYPOINT ["/entrypoint/entrypoint.sh"]
