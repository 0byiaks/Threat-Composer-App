FROM --platform=linux/amd64 node:20-alpine AS deps
WORKDIR /app

COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile



FROM --platform=linux/amd64 node:20-alpine AS build
WORKDIR /app

# Reuse installed dependencies from the deps stage
COPY --from=deps /app/node_modules ./node_modules
COPY package.json yarn.lock ./

# Copy source and build
COPY . .
RUN yarn build


FROM --platform=linux/amd64 nginx:alpine AS runtime

# Use our NGINX site config (health endpoint + SPA fallback)
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy only the built static site into NGINX web root
COPY --from=build /app/build /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]