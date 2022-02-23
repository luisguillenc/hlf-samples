FROM golang:1.14-alpine AS build_base

RUN apk add --no-cache git

# Set the Current Working Directory inside the container
WORKDIR /tmp/basic-app

# We want to populate the module cache based on the go.{mod,sum} files.
COPY go.mod .
COPY go.sum .

RUN go mod download

COPY . .

# Unit tests
#RUN CGO_ENABLED=0 go test -v

# Build the Go app
RUN go build -o ./out/basic .

# Start fresh from a smaller image
FROM alpine
RUN apk add ca-certificates

COPY --from=build_base /tmp/basic-app/out/basic /app/basic

# Set workdir
WORKDIR /app

# This container exposes port 8080 to the outside world
EXPOSE 8080

# Exposes config volume
VOLUME [ "/app/config" ]

# Run the binary program produced by `go build`
CMD ["/app/basic"]
