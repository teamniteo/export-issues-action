FROM alpine:3.11

RUN apk add --no-cache bash ca-certificates wget jq \
  && wget https://github.com/cli/cli/releases/download/v1.0.0/gh_1.0.0_linux_arm64.tar.gz \
  && tar -xvf gh_1.0.0_linux_arm64.tar.gz \
  && mv gh_1.0.0_linux_arm64/bin/gh /bin/gh \
  && chmod +x /bin/gh

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]