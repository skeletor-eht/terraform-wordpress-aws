#!/bin/bash
# Update and install required packages
yum update -y
amazon-linux-extras enable php7.4
yum install -y httpd php php-mysqlnd mariadb wget unzip

# Start and enable Apache
systemctl start httpd
systemctl enable httpd

# Download and install WordPress
cd /var/www/html
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
mv wordpress/* .
rmdir wordpress
rm latest.tar.gz

# Set permissions
chown -R apache:apache /var/www/html
chmod -R 755 /var/www/html

# Create wp-config.php with DB variables passed in from Terraform
cat <<EOF > /var/www/html/wp-config.php
<?php
define( 'DB_NAME', '${db_name}' );
define( 'DB_USER', '${db_user}' );
define( 'DB_PASSWORD', '${db_pass}' );
define( 'DB_HOST', '${db_host}' );
define( 'DB_CHARSET', 'utf8' );
define( 'DB_COLLATE', '' );
\$table_prefix = 'wp_';
define( 'WP_DEBUG', false );
if ( ! defined( 'ABSPATH' ) ) {
  define( 'ABSPATH', __DIR__ . '/' );
}
require_once ABSPATH . 'wp-settings.php';
EOF

# Try to create the WordPress database if it doesn't exist
mysql -h ${db_host} -u ${db_user} -p${db_pass} -e "CREATE DATABASE IF NOT EXISTS ${db_name};"
