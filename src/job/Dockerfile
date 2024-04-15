FROM rust:1.70 as builder
WORKDIR /usr/src/job
COPY . .
RUN apt-get -y update \
    && apt-get install -y protobuf-compiler
RUN cargo install --path .

FROM debian:bookworm-slim
RUN apt-get update & apt-get install -y extra-runtime-dependencies & rm -rf /var/lib/apt/lists/*
COPY --from=builder /usr/local/cargo/bin/job /usr/local/bin/job
CMD ["job"]