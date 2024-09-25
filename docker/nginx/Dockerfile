# Use the official Nginx image as the base image
FROM nginx:latest

# Copy the Nginx configuration files into the container
COPY ./nginx/nginx.conf.template /etc/nginx/nginx.conf.template
COPY ./nginx/proxy.conf.template /etc/nginx/proxy.conf.template
COPY ./nginx/https.conf.template /etc/nginx/https.conf.template
COPY ./nginx/conf.d /etc/nginx/conf.d
COPY ./nginx/docker-entrypoint.sh /docker-entrypoint.sh
COPY ./nginx/ssl /etc/ssl

# Ensure the entrypoint script is executable
RUN chmod +x /docker-entrypoint.sh

# Replace container names with 127.0.0.1 in the default.conf.template file
RUN sed -i 's|http://api|http://127.0.0.1|g' /etc/nginx/conf.d/default.conf.template && \
    sed -i 's|http://web|http://127.0.0.1|g' /etc/nginx/conf.d/default.conf.template

# Set environment variables
ENV NGINX_SERVER_NAME=${NGINX_SERVER_NAME:-_} \
    NGINX_HTTPS_ENABLED=${NGINX_HTTPS_ENABLED:-false} \
    NGINX_SSL_PORT=${NGINX_SSL_PORT:-443} \
    NGINX_PORT=${NGINX_PORT:-80} \
    NGINX_SSL_CERT_FILENAME=${NGINX_SSL_CERT_FILENAME:-dify.crt} \
    NGINX_SSL_CERT_KEY_FILENAME=${NGINX_SSL_CERT_KEY_FILENAME:-dify.key} \
    NGINX_SSL_PROTOCOLS="${NGINX_SSL_PROTOCOLS:-TLSv1.1 TLSv1.2 TLSv1.3}" \
    NGINX_WORKER_PROCESSES=${NGINX_WORKER_PROCESSES:-auto} \
    NGINX_CLIENT_MAX_BODY_SIZE=${NGINX_CLIENT_MAX_BODY_SIZE:-15M} \
    NGINX_KEEPALIVE_TIMEOUT=${NGINX_KEEPALIVE_TIMEOUT:-65} \
    NGINX_PROXY_READ_TIMEOUT=${NGINX_PROXY_READ_TIMEOUT:-3600s} \
    NGINX_PROXY_SEND_TIMEOUT=${NGINX_PROXY_SEND_TIMEOUT:-3600s} \
    NGINX_ENABLE_CERTBOT_CHALLENGE=${NGINX_ENABLE_CERTBOT_CHALLENGE:-false} \
    CERTBOT_DOMAIN=${CERTBOT_DOMAIN:-}

# Set the entrypoint
ENTRYPOINT ["/docker-entrypoint.sh"]

# Expose ports
EXPOSE ${NGINX_PORT:-80} ${NGINX_SSL_PORT:-443}