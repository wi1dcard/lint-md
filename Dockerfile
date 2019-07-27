FROM node:current-alpine AS build
WORKDIR /app
COPY . .
RUN set -x \
    && yarn install \
    && (cd packages/lint-md && yarn run build) \
    && (cd packages/ast-plugin && yarn run build)

FROM node:current-alpine AS deps
WORKDIR /app
COPY . .
RUN yarn install --production && yarn cache clean

FROM node:current-alpine
WORKDIR /usr/local/lint-md
COPY . .
COPY --from=deps /app/node_modules ./node_modules
COPY --from=build /app/packages/lint-md ./packages/lint-md
COPY --from=build /app/packages/ast-plugin ./packages/ast-plugin
RUN ln -s $(pwd)/packages/lint-md-cli/bin/index.js /usr/local/bin/lint-md
WORKDIR /docs
CMD ["lint-md"]
