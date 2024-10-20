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
    supervisor

# Copy Nginx configuration
COPY nginx.conf /usr/local/nginx/conf/nginx.conf
COPY fastcgi_params /usr/local/nginx/conf/fastcgi_params

COPY supervisord.conf /etc/supervisord.conf

# Copy CSS themes into the image
COPY css /usr/local/nginx/html/css

# Move FancyIndex header and footer to /usr/local/nginx/html (simplified directory)
RUN rm -f /usr/local/nginx/html/*.html
COPY fancyindex_header.html /usr/local/nginx/html/fancyindex_header.html
COPY fancyindex_footer.html /usr/local/nginx/html/fancyindex_footer.html
COPY mime.types /usr/local/nginx/conf/mime.types

# Set permissions for header and footer in the correct directory
RUN chmod 644 /usr/local/nginx/html/fancyindex_header.html /usr/local/nginx/html/fancyindex_footer.html

# Copy the shell script for rendering Markdown
COPY scripts/render_markdown.sh /usr/local/bin/render_markdown.sh
RUN chmod +x /usr/local/bin/render_markdown.sh

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
