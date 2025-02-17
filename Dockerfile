FROM golang:1.12-alpine3.9 AS build
RUN apk add --no-cache curl gcc musl-dev
WORKDIR /go/src/github.com/keybase
ARG KEYBASE_VERSION=4.0.0
RUN curl -L "https://github.com/keybase/client/archive/v${KEYBASE_VERSION}.tar.gz" | tar xz && mv "client-${KEYBASE_VERSION}" client
WORKDIR ./client/go
RUN go build -tags production -o /keybase ./keybase
RUN go build -tags production -o /kbfsfuse ./kbfs/kbfsfuse

FROM alpine:3.9
RUN apk add --no-cache fuse
COPY --from=build /keybase /kbfsfuse /usr/local/bin/
COPY entrypoint.sh /usr/local/bin/docker-entrypoint
ENTRYPOINT ["docker-entrypoint"]
CMD ["kbfsfuse"]
