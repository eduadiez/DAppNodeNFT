#
# Builder stage.
# This state compile our TypeScript to get the JavaScript code
#
FROM node:12.16.3 AS builder

WORKDIR /usr/src/app

COPY package*.json ./
COPY tsconfig*.json ./
COPY ./src ./src
RUN npm ci --quiet && npm run build

#
# Build Production stage.
# This state compile get back the JavaScript code from builder stage
# It will also install the production package only
#
FROM node:12.16.3-alpine as production-builder

# This cause a layer build as it brings 200 mb of data
RUN apk --no-cache add --virtual builds-deps build-base python

WORKDIR /app
ENV NODE_ENV=production

COPY package*.json ./
RUN npm ci --quiet --only=production

FROM node:12.16.3-alpine as production

WORKDIR /app
ENV NODE_ENV=production

COPY package*.json ./
## We just need the dist folder and node_modules to execute the command
COPY --from=builder /usr/src/app/dist ./dist
COPY --from=production-builder /app/node_modules ./node_modules

CMD [ "node", "dist/app.js" ]