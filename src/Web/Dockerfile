FROM node:26-alpine AS build

WORKDIR /app

COPY package*.json ./

# Require the OpenSSL package level that fixes CVE-2026-14456.
RUN apk add --no-cache 'libssl3>=3.5.8-r0' && apk upgrade --no-cache
RUN npm ci

COPY . .

RUN npm run build

FROM nginxinc/nginx-unprivileged:alpine

# Require the OpenSSL package level that fixes CVE-2026-14456 in the runtime image.
RUN apk add --no-cache 'libssl3>=3.5.8-r0' && apk upgrade --no-cache

COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
