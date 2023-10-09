# syntax=docker/dockerfile:1
# read the doc: https://huggingface.co/docs/hub/spaces-sdks-docker
# you will also find guides on how best to write your Dockerfile
FROM node:20 as builder

WORKDIR /app

COPY --link --chown=1000 . .

RUN npm install
RUN npm run build

# Add custom conf and rebuild
COPY --link --chown=1000 demo/custom_conf.env /app/.env
RUN npm run build

FROM node:19-slim

RUN npm install -g pm2

COPY --from=builder /app/node_modules /app/node_modules
COPY --link --chown=1000 package.json /app/package.json
COPY --from=builder /app/build /app/build
COPY --from=builder /app/certs /app/certs

CMD pm2 start /app/build/index.js -i 1 --no-daemon
