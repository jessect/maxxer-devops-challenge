# Build
FROM golang:1.17-buster AS build

WORKDIR /app

COPY ./golang-crud .

RUN go mod tidy && go build -a -o golang-crud

## Deploy
FROM alpine:3.14

RUN apk add --no-cache libc6-compat

WORKDIR /

COPY --from=build /app/golang-crud /golang-crud

EXPOSE 8090

ENTRYPOINT ["/golang-crud"]