FROM alpine 

COPY . .

RUN apk add wget --no-cache &&\
    wget -q https://github.com/elm/compiler/releases/download/0.19.0/binaries-for-linux.tar.gz &&\
    tar -C /bin -xf binaries-for-linux.tar.gz &&\
    elm make src/Main.elm --output=elm.js --optimize

FROM node:alpine

COPY . .

RUN npm ci

COPY --from=0 elm.js .

EXPOSE 8080/tcp

CMD ["npm", "start"]
