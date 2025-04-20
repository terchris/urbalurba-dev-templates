# filename: templates/golang-basic-webserver/Dockerfile
# Docker image for the Go web application
# This is a multi-stage build to create a smaller final image

# Build stage - Compiles the Go application
FROM golang:1.21-alpine AS build
WORKDIR /app
COPY . .
RUN go mod init example.com/hello
RUN go mod tidy
RUN CGO_ENABLED=0 GOOS=linux go build -o server

# Run stage - Creates the final lightweight image
FROM alpine:latest
WORKDIR /app
COPY --from=build /app/server .

# Expose the port that the app runs on
EXPOSE 3000

# Command to run the application
CMD ["./server"] 