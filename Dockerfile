# Use a basic Debian image to build Nginx with fancyindex
FROM debian:stable-slim

# Install dependencies for building Nginx and for rendering Markdown
RUN apt-get update && apt-get install -y \
    build-essential \
    libpcre3 libpcre3-dev \
    zlib1g zlib1g-dev \
    libssl-dev \
    wget \
    git \
    pandoc \
    fcgiwrap \
    spawn-fcgi \
    nginx-extras \
    supervisor \
    npm \
    lua5.4 \
    sed \
    && npm install -g @mermaid-js/mermaid-cli

# Copy Nginx configuration
COPY nginx.conf /usr/local/nginx/conf/nginx.conf
COPY fastcgi_params /usr/local/nginx/conf/fastcgi_params

COPY supervisord.conf /etc/supervisord.conf

# Copy CSS themes into the image
COPY css /usr/local/nginx/html/css

# Move FancyIndex header and footer to /usr/local/nginx/html (simplified directory)
RUN rm -f /usr/local/nginx/html/*.html

COPY fancyindex /usr/local/nginx/html/fancyindex
COPY mime.types /usr/local/nginx/conf/mime.types

# Set permissions for header and footer in the correct directory
RUN chmod -R 644 /usr/local/nginx/html/fancyindex/fancyindex-dark
RUN chmod 755 /usr/local/nginx/html/fancyindex/fancyindex-dark
RUN chmod -R 644 /usr/local/nginx/html/fancyindex/fancyindex-light
RUN chmod 755 /usr/local/nginx/html/fancyindex/fancyindex-light

# Copy the shell script for rendering Markdown
COPY scripts/render_markdown.sh /usr/local/bin/render_markdown.sh
RUN chmod +x /usr/local/bin/render_markdown.sh

# Create directory for temporary files with proper permissions
RUN mkdir -p /tmp/pandoc && chmod 777 /tmp/pandoc

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
