FROM ubuntu:latest as builder

ARG VERSION=latest

RUN apt-get update \
    && apt-get install unzip

COPY versions /versions
COPY unzip-version.sh /unzip-version.sh

RUN /unzip-version.sh /versions "${VERSION}"

FROM node:lts-alpine

COPY --from=builder /app /app
COPY entrypoint.sh /

CMD [ "/entrypoint.sh" ]