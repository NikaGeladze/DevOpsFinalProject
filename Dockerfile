# Render builds from repo root — app code lives in app/
FROM node:20-alpine

WORKDIR /app

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

COPY app/package*.json ./
RUN npm ci --omit=dev && npm cache clean --force

COPY app/src ./src
COPY app/public ./public

USER appuser

ENV NODE_ENV=production
ENV SERVICE_NAME=demo-app

CMD ["node", "src/server.js"]
