# Render builds from repo root — app code lives in app/
FROM node:20-alpine AS build

WORKDIR /app

COPY app/package*.json ./
RUN npm ci --omit=dev && npm cache clean --force

COPY app/src ./src
COPY app/public ./public

FROM node:20-alpine AS runtime

# Patch OS packages and remove npm/npx (not needed at runtime; avoids false-positive Trivy hits)
RUN apk upgrade --no-cache \
    && rm -rf /usr/local/lib/node_modules/npm \
    && rm -f /usr/local/bin/npm /usr/local/bin/npx

WORKDIR /app

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/src ./src
COPY --from=build /app/public ./public

USER appuser

ENV NODE_ENV=production
ENV SERVICE_NAME=demo-app

CMD ["node", "src/server.js"]
