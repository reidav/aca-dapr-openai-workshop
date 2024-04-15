#!/usr/bin/env bash

set -e

set_tools() {
    sudo apt-get update && sudo apt-get install protobuf-compiler redis -y
    az extension add --name containerapp --upgrade
}

set_ruby_for_docs_management() {
    sudo apt-get update && sudo apt-get install ruby-full build-essential zlib1g-dev -y
    echo '# Install Ruby Gems to ~/gems' >> ~/.bashrc
    echo 'export GEM_HOME="$HOME/gems"' >> ~/.bashrc
    echo 'export PATH="$HOME/gems/bin:$PATH"' >> ~/.bashrc
    source ~/.bashrc
    sudo gem install jekyll bundler
}

set_dapr_config() {
    dapr uninstall # clean if needed
    dapr init

    # Swapping dapr provided redis with latest redislabs/redismod
    # Required for state management support (json queries & indexing)
    docker stop dapr_redis
    docker rm dapr_redis
    docker run -d --name dapr_redis -p 6379:6379 redis/redis-stack-server:latest
}

# Install tools
set_tools
set_ruby_for_docs_management

# Set dapr config
set_dapr_config

# Prefetch dependencies
pip install -r ./src/requests-api/requirements.txt
pip install -r ./src/requests-processor/requirements.txt
dotnet restore ./src/requests-frontend/Frontend.csproj
(cd ./src/job/ && cargo build)
