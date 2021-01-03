FROM node:15.5.0-alpine3.12
WORKDIR /app
COPY index.js rg.js package.json yarn.lock /app/
RUN yarn
CMD ["node", "index.js"]
