# build the tool 
FROM --platform=$BUILDPLATFORM golang:1.17-bullseye AS build
ARG TARGETARCH
ARG BUILD_VERSION
ENV BINARY_PATH="/pibox-framebuffer-linux-${TARGETARCH}-v${BUILD_VERSION}"

ENV APP_HOME=/go/src/pibox-framebuffer
WORKDIR "$APP_HOME"

RUN apt-get -yqq update && apt-get -yqq install gcc build-essential gcc-aarch64-linux-gnu

COPY . .

ENV CGO_ENABLED=1
ENV GOOS=linux
ENV GOARCH="${TARGETARCH}"
RUN go install github.com/rakyll/statik@latest
RUN ./go-build.sh

# create server image
# Use Debian slim image for ARM64 (glibc compatible)
#FROM debian:bookworm-slim
FROM alpine

ARG TARGETARCH
ARG BUILD_VERSION
ENV BINARY_PATH="/pibox-framebuffer-linux-${TARGETARCH}-v${BUILD_VERSION}"

RUN apk add --no-cache curl shadow
# Install necessary runtime dependencies
#RUN apt-get update && apt-get install -y \
    #curl \
    #&& rm -rf /var/lib/apt/lists/*

# Create a non-root user for security
RUN groupadd -g 1001 pibox && \
    useradd -u 1001 -g pibox -s /bin/bash pibox

RUN mkdir /app

# Set working directory
WORKDIR /app

# Copy the pibox-framebuffer binary from build directory
COPY --from=build "${BINARY_PATH}"/pibox-framebuffer /app/pibox-framebuffer

# Make the binary executable
RUN chmod +x /app/pibox-framebuffer

# Change ownership to non-root user
RUN chown -R pibox:pibox /app

# Note: Running as root for hardware access
# USER pibox

EXPOSE 2019

HEALTHCHECK --interval=5s --timeout=3s --retries=3 CMD curl -f http://localhost:2019/health || exit 1

ENV HOST=0.0.0.0
# Run the pibox-framebuffer service
CMD ["/app/pibox-framebuffer"]