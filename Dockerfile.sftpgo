FROM golang:1.23.4-bullseye

ARG SFTPGO_VERSION=v2.6.4
ENV SFTPGO_VERSION=$SFTPGO_VERSION
ARG BUILD_DATE
ENV BUILD_DATE=$BUILD_DATE

RUN git clone https://github.com/drakkan/sftpgo /go/src/github.com/drakkan/sftpgo && \
    git -C /go/src/github.com/drakkan/sftpgo checkout "tags/$SFTPGO_VERSION"

WORKDIR /go/src/github.com/drakkan/sftpgo

ENV GOOS=linux
ENV GOARCH=arm64
ENV CGO_ENABLED=1
ENV CC=aarch64-linux-gnu-gcc

RUN go build -tags nogcs,nos3 \
    -ldflags "-linkmode external -extldflags '--static-pie' -s -w -X github.com/drakkan/sftpgo/v2/internal/version.commit=${SFTPGO_VERSION} -X github.com/drakkan/sftpgo/v2/internal/version.date=${BUILD_DATE}" \
    -buildmode=pie \
    -o sftpgo

RUN apt-get update && apt-get install -y file

RUN file /go/src/github.com/drakkan/sftpgo/sftpgo