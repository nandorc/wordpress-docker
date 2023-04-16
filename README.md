# WP Dockerizer

> **Version:** 1.0.0

Project to deploy WordPress locally using Docker Containers. Supported and installed components are:

- Git v2.x
- Apache v2.4.x
- PHP v7.4.x
- Composer v2.x
- MySQL v8.0
- Node v18.15.0 with NPM v9.5.0

## Using `wpenv` utility

On `bin` folder, `wpenv` utility can be found. It allows user to interact with **docker compose** services easily. Follow codeblock shows main commands related with `wpenv` utility

```bash
#!/bin/bash

# Setup mage alias
bash ./bin/setup

# Start services
#   Additional args from docker compose up are received
wpenv up

# Dispose services
wpenv down

# Restart services
wpenv restart

# See currently running services
wpenv ps

# Log in to web-service terminal
wpenv bash

# Log in to mysql-service terminal
#   Parameters for mysql connection are received
wpenv mysql
```

Any other command executed using `wpenv` command is done through `docker compose exec` command using `wpenv` user on `web` service, so if the command `wpenv ls -a /wp-app` is executed, a list of files and folders (`ls -a` command) located at `/wp-app` directory inside web container are shown

## Installing new WordPress App

---

### 0. Prepare services

---

Start services

```bash
wpenv up -d --build
```

---

### 1. Create database

---

Open MySQL CLI using `root` as password

```bash
wpenv mysql -p
```

Create new user

```sql
create user 'wpuser'@'%' identified with mysql_native_password by 'wpuser';
```

Allow new user to use new database

```sql
grant all on wp_test.* to 'wpuser'@'%';
```

Flush privileges

```sql
flush privileges;
```

Close MySQL CLI

```sql
exit;
```

Test new user conection to MySQL using `wpuser` as password

```bash
wpenv mysql -u wpuser -p
```

---

### 2. Create new WordPress project

---

Log in web container

```bash
wpenv bash
```

Download WordPress

```bash
wp core download --path=wordpress --locale=es_CO
```

Create wp-config

```bash
wp config create --path=wordpress --dbname=wp_test --dbuser=wpuser --dbhost=db --prompt=dbpass
```

Create database

```bash
wp db create --path=wordpress
```

Install WordPress

```bash
wp core install --path=wordpress --url=localhost --title="WP Site" --admin_user=wpadmin --admin_password=wpadmin --admin_email=admin@sample.com --locale=es_CO --skip-email
```

Update files/folders default permission and property

```bash
wpperms .
```

### 3. Test Access to WordPress App

Access on you browser to [localhost](http://localhost) and you must see Magento App home page.
