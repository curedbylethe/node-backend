# Build image: docker build -t <image-name> .
FROM node:latest AS build
RUN apt-get update && apt-get install -y --no-install-recommends dumb-init

# set app basepath
ENV HOME=/usr/src/app/

# add app dependencies
COPY package*.json $HOME

# change workgin dir and install deps in quiet mode
WORKDIR $HOME
RUN npm ci -q

# copy app source
COPY . $HOME

# compile typescript and build all production stuff
ENV NODE_PATH=./build
RUN npm run build

# remove dev dependencies and files that are not needed in production
RUN rm -rf node_modules && \
    npm ci --only=production && \
    npm prune --production

# Production image: docker build -t <image-name> --target production .
FROM node:20.5.1-bullseye-slim

# set app basepath
ENV HOME=/usr/src/app/

ENV NODE_ENV production
COPY --from=build /usr/bin/dumb-init /usr/bin/dumb-init

COPY --chown=node:node --from=build $HOME $HOME

# run app with low permissions level user
USER node
WORKDIR $HOME

EXPOSE 8000

ENTRYPOINT ["dumb-init"]
CMD ["node", "--enable-source-maps", "build/index.js"]
