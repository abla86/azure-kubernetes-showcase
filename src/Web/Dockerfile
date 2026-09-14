FROM node:26-alpine AS build

WORKDIR /app

COPY package*.json ./

# Upgrade the Alpine base packages before enforcing the OpenSSL security floor.
# This fixes CVE-2026-14456 (libssl3 < 3.5.8-r0) without relying on a stale
# package index from the base image.
RUN apk upgrade --no-cache \
    && apk add --no-cache 'libssl3>=3.5.8-r0'
RUN npm ci

COPY . .

RUN npm run build

FROM nginxinc/nginx-unprivileged:alpine

# apk requires root; return to the image's non-root nginx user afterwards.
USER root
RUN apk upgrade --no-cache \
    && apk add --no-cache 'libssl3>=3.5.8-r0'

COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 8080

USER 101
CMD ["nginx", "-g", "daemon off;"]
