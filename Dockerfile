# Stage 1: Build Flutter web app
FROM ghcr.io/cirruslabs/flutter:stable AS builder

WORKDIR /app

# Copy pubspec file first for dependency caching
COPY pubspec.yaml ./

# Get dependencies (generates pubspec.lock)
RUN flutter pub get

# Copy the rest of the source code
COPY . .

# Build the web app in release mode
RUN flutter build web --release

# Stage 2: Serve with Nginx
FROM nginx:alpine

# Remove default Nginx welcome page
RUN rm -rf /usr/share/nginx/html/*

# Copy the built web assets from the builder stage
COPY --from=builder /app/build/web /usr/share/nginx/html

# Copy custom Nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
