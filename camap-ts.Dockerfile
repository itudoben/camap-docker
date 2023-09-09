FROM node:16.20.1-bullseye-slim as builder

ENV FRONT_URL=https://api.camap
ENV FRONT_GRAPHQL_URL=${FRONT_URL}/graphql
ENV CAMAP_HOST=https://camap
ENV MAPBOX_KEY=pk.eyJ1IjoiYnViYXIiLCJhIjoiY2xhaTJoaDMxMGhsODNwbXpveHI5cmRvYSJ9.EamPFVWWXhGRzJX5SOU0xg
ENV THEME_ID=default

RUN apt-get update && apt-get install -y \
    g++ \
    libconfig-tiny-perl \
    libtest-script-perl \
    make \
    python3

RUN adduser --disabled-password --disabled-login --gecos "InterAMAP user" --home /home/interamap interamap
WORKDIR /srv
RUN chown interamap:interamap /srv

COPY --chown=interamap:interamap camap-ts/orm*.js camap-ts/package.json camap-ts/package-lock.json /srv/
COPY --chown=interamap:interamap camap-ts/packages/ /srv/packages
COPY --chown=interamap:interamap camap-ts/public/ /srv/public

USER interamap
RUN npm --fetch-retries 4 install && npm cache clean --force
RUN npm run build
## remove packages of devDependencies
RUN npm prune --production

COPY --chown=interamap:interamap ./camap-ts/scripts/ /srv/scripts

FROM  node:20.3.1-bullseye-slim

RUN adduser --disabled-password --disabled-login --gecos "InterAMAP user" --home /home/interamap interamap

RUN apt-get update && apt-get install -y \
    libconfig-tiny-perl \
    virtual-mysql-client-core \
    procps \
    && apt-get clean && rm -rf /var/lib/apt/lists/*
ENV TZ="Europe/Paris" 
RUN echo "Europe/Paris" > /etc/timezone
COPY --from=builder /srv/ /srv/
COPY ./camap-ts/.env /srv/.env
WORKDIR /srv
