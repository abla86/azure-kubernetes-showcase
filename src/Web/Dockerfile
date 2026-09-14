FROM node:26-alpine AS build

WORKDIR /app

COPY package*.json ./

RUN apk upgrade --no-cache
RUN npm ci

COPY . .

RUN npm run build

FROM nginxinc/nginx-unprivileged:alpine

# Keep Alpine security packages current in the runtime image.
RUN apk upgrade --no-cache

COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
