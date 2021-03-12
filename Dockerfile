FROM golang:1.12-alpine AS builder
SHELL ["/bin/sh", "-o", "pipefail", "-c"]

# Create app directory
WORKDIR /go/src/github.com/tus/tusd/

ENV GO111MODULE=on

# Separate step to improve layer caching
RUN apk add --no-cache \
		git \
		gcc \
		libc-dev

COPY go.mod go.sum ./
COPY ./pkg ./pkg
COPY ./internal ./internal
COPY ./cmd ./cmd
RUN go get -d -v ./...

ARG VERSION
ARG COMMIT

RUN GOOS=linux GOARCH=amd64 go build \
		-ldflags="-X github.com/tus/tusd/cmd/tusd/cli.VersionName=${VERSION} -X github.com/tus/tusd/cmd/tusd/cli.GitCommit=${COMMIT} -X 'github.com/tus/tusd/cmd/tusd/cli.BuildDate=$(date --utc)'" \
		-o "/go/bin/tusd" ./cmd/tusd/main.go

# start a new stage that copies in the binary built in the previous stage
FROM alpine:3.13.2
# These don't change often, so set them early
EXPOSE 1080
WORKDIR /srv/tusd-data

RUN set -xe \
	&& apk add --no-cache \
		ca-certificates \
		jq \
	\
	&& addgroup -g 1000 tusd \
	&& adduser -u 1000 -G tusd -s /bin/sh -D tusd \
    && mkdir -p /srv/tusd-hooks \
    && mkdir -p /srv/tusd-data \
    && chown tusd:tusd /srv/tusd-data

COPY --chown=tusd --from=builder /go/bin/tusd /usr/local/bin/tusd

USER tusd
ENTRYPOINT [ "/usr/local/bin/tusd" ]
CMD [ "-hooks-dir", "/srv/tusd-hooks", "-upload-dir", "/srv/tusd-data" ]
