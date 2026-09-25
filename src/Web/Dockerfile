FROM node:26-alpine AS build

WORKDIR /app

COPY package*.json ./

# Upgrade the Alpine base packages before enforcing the OpenSSL security floor.
# This fixes CVE-2026-14456 (libssl3 < 3.5.8-r0) without relying on a stale
# package index from the base image.
RUN apk upgrade --no-cache

# Reconcile the committed dependency manifest before the clean install. The
# repository intentionally keeps package-lock.json under review, while this
# step also makes the image resilient to a manifest-only dependency repair.
RUN npm install --package-lock-only --ignore-scripts --no-audit --no-fund \
    && npm ci --no-audit --no-fund

COPY . .

RUN npm run build

FROM nginxinc/nginx-unprivileged:stable-trixie


COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 8080

USER 101
CMD ["nginx", "-g", "daemon off;"]
