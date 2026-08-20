FROM swift:6.0-jammy AS build
WORKDIR /build
COPY . .
RUN swift build -c release --static-swift-stdlib --product App

FROM ubuntu:jammy
RUN apt-get -q update && apt-get -q install -y ca-certificates tzdata libsqlite3-0 && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY --from=build /build/.build/release/App ./App
EXPOSE 8080
ENTRYPOINT ["./App"]
CMD ["serve", "--env", "production", "--hostname", "0.0.0.0", "--port", "8080"]
