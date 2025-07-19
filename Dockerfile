FROM ubuntu:22.04

# To make it easier for build and release pipelines to run apt-get,
# configure apt to not require confirmation (assume the -y argument by default)
ENV DEBIAN_FRONTEND=noninteractive
RUN echo "APT::Get::Assume-Yes \"true\";" > /etc/apt/apt.conf.d/90assumeyes

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    jq \
    git \
    unzip \
    zip \
    iputils-ping \
    libcurl4 \
    libicu70 \
    libunwind8 \
    netcat-traditional \
    libssl1.0 \
    wget \
    apt-transport-https \
    dotnet-sdk-8.0 \
    dotnet-sdk-6.0 \
    mysql-client

RUN curl -LsS https://aka.ms/InstallAzureCLIDeb | bash
RUN rm -rf /var/lib/apt/lists/*
RUN dotnet tool install --global dotnet-ef --ignore-failed-sources

RUN curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip \
  && unzip awscliv2.zip \
  && ./aws/install \
  && rm -rf aws awscliv2.zip

RUN wget -q https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb \
    && apt-get update \
    && apt-get install -y powershell -y \
    && rm packages-microsoft-prod.deb

RUN apt-get update && apt-get install -y --no-install-recommends \
    openjdk-21-jdk

# Can be 'linux-x64', 'linux-arm64', 'linux-arm', 'rhel.6-x64'.
ENV TARGETARCH=linux-x64

# Set JAVA_HOME environment variable
ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
ENV PATH="$JAVA_HOME/bin:$PATH"

WORKDIR /azp

COPY ./start.sh .
RUN chmod +x start.sh

ENTRYPOINT ["./start.sh"]
