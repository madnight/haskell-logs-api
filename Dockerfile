FROM node:15.5.0-alpine3.12
WORKDIR /app
RUN apk add ripgrep
COPY index.js rg.js package.json yarn.lock /app/
RUN yarn
CMD ["node", "index.js"]
