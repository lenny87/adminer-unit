# Use the official Nginx Unit image with PHP 8.2 (you can choose another PHP version)
FROM unit:php8.4

# Set Adminer version
ARG ADMINER_VERSION=5.4.0

# Create application directory and set permissions
RUN mkdir -p /app && chown unit:unit /app

# Install wget, download Adminer, then clean up
RUN apt-get update && apt install -y libpq-dev freetds-dev
RUN docker-php-ext-install mysqli pdo_mysql pgsql pdo_pgsql pdo_dblib
RUN apt-get update && apt-get install -y wget && \
    # It's best to use a direct, version-locked URL if available for adminer-5.3.0.php
    # The official site's "latest-en.php" might not always point to 5.3.0 in the future.
    # For true reproducibility, download adminer-5.3.0.php yourself and use COPY,
    # or find a permanent URL for that specific version.
    # Example assuming you are okay with latest for now, or will replace with a specific URL:
    wget -O /app/adminer.php https://www.adminer.org/latest-en.php && \
    # If you had adminer-5.3.0.php locally, you would use:
    # COPY --chown=unit:unit adminer-5.3.0.php /app/adminer.php
    apt-get remove --purge -y wget && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# Copy the Nginx Unit configuration
# This configuration tells Unit to serve PHP files from /app/
# and specifically pass requests for /adminer.php to the PHP application.
COPY --chown=unit:unit unit.config.json /docker-entrypoint.d/

# Expose the default Unit port
EXPOSE 80

# The CMD is usually part of the base image:
# CMD ["unitd", "--no-daemon", "--control", "unix:/var/run/control.unit.sock"]
