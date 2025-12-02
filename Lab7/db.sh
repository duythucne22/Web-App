# run mysql container for spring app
docker run -d --name spring-mysql -e MYSQL_ROOT_PASSWORD=rootpassword -e MYSQL_DATABASE=product_management -e MYSQL_USER=springuser -e MYSQL_PASSWORD=springpassword -p 3306:3306 --restart unless-stopped mysql:8.0 --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci

#init db with script
docker exec -it spring-mysql mysql -uspringuser -pspringpassword product_management -e "
CREATE TABLE IF NOT EXISTS products (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    product_code VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    quantity INT DEFAULT 0,
    category VARCHAR(50),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
"

# if Stop
# Start container (if stopped)
docker start spring-mysql

# Stop container
docker stop spring-mysql

# View container logs
docker logs spring-mysql

# Restart container
docker restart spring-mysql

# Remove container (when done)
docker stop spring-mysql && docker rm spring-mysql

# Check databases in container
docker exec -it spring-mysql mysql -uroot -prootpassword -e "SHOW DATABASES;"