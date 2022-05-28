# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.209.6/containers/go/.devcontainer/base.Dockerfile

# [Choice] Go version (use -bullseye variants on local arm64/Apple Silicon): 1, 1.16, 1.17, 1-bullseye, 1.16-bullseye, 1.17-bullseye, 1-buster, 1.16-buster, 1.17-buster
ARG VARIANT="1.17-bullseye"
FROM mcr.microsoft.com/vscode/devcontainers/go:0-${VARIANT}

# [Choice] Node.js version: none, lts/*, 16, 14, 12, 10
ARG NODE_VERSION="none"
RUN if [ "${NODE_VERSION}" != "none" ]; then su vscode -c "umask 0002 && . /usr/local/share/nvm/nvm.sh && nvm install ${NODE_VERSION} 2>&1"; fi

# [Optional] Uncomment this section to install additional OS packages.
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends direnv 

# [Optional] Uncomment the next lines to use go get to install anything else you need
# USER vscode
# RUN go install -x github.com/google/ko@v0.9.3

   
# [Optional] Uncomment this line to install global node packages.
# RUN su vscode -c "source /usr/local/share/nvm/nvm.sh && npm install -g <your-package-here>" 2>&1

COPY library-scripts/*.sh /tmp/library-scripts/

RUN \
    # Install the Azure CLI
    bash /tmp/library-scripts/azcli-debian.sh \
    # Install git form source
    && bash /tmp/library-scripts/git-from-src-debian.sh  \
    # Install github cli
    && bash /tmp/library-scripts/github-debian.sh \
    # Install git lfs
    && bash /tmp/library-scripts/git-lfs-debian.sh \
    # Clean up
    && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/library-scripts


# choose the latest version 
ARG KO_VERSION="0.11.2"
RUN \
    VERSION=${KO_VERSION} OS="Linux" ARCH="x86_64"; curl -L https://github.com/google/ko/releases/download/v${VERSION}/ko_${VERSION}_${OS}_${ARCH}.tar.gz | tar -C /tmp/ -xzf - ko \
    && chmod +x /tmp/ko \
    && mv /tmp/ko /usr/local/bin/
