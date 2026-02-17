FROM ubuntu:latest as builder

ARG ARTIFACT

RUN apt-get update \
    && apt-get install unzip

COPY versions/${ARTIFACT} /artifact.zip
COPY unzip-version.sh /unzip-version.sh

# RUN /unzip-version.sh /versions "${VERSION}"
RUN unzip "artifact.zip" -d "/app";

FROM node:lts-alpine
ARG FOUNDRY_VERSION

COPY --from=builder /app /app
COPY entrypoint.sh /

ENV FOUNDRY_VERSION=$FOUNDRY_VERSION
ENTRYPOINT [ "sh" ]
CMD [ "/entrypoint.sh" ]