# YAMDI (Moodle with Docker)

This is yet another moodle Docker image, since they still haven't published any official one. This is an image I've been using for a few years and update not too frequently. Please feel free to fork or copy this repository and modified as you need.

## Installation

I usually install this image using [compose](https://docs.docker.com/compose/install/) here is an example compose file using postgres DB.
You can easily change the DB to mariadb or mysql since both are already supported by the image.

```yml
services:
  app:
    image: "dnangelus/moodle:${TAG:-latest}"
    volumes:
      - datasrc:/srv/www/moodle
      - "${VOLFILES:-datafiles}:/var/moodle/data"
    environment:
      DB_DATABASE: "${DB:-postgres}"
      DB_HOST: "${DBHOST:-db}"
      DB_NAME: "${DBNAME:-postgres}"
      DB_USER: "${DBUSER:-moodle}"
      DB_PASSWORD: "${DBPASSWORD:-moodle}"
  db:
    image: postgres:10
    volumes:
      - "${VOLDB:-datadb}:${DBDATA:-/var/lib/postgresql/data}"
    environment:
      POSTGRES_DB: "${DBNAME:-moodle}"
      POSTGRES_USER: "${DBUSER:-moodle}"
      POSTGRES_PASSWORD: "${DBPASSWORD:-moodle}"
      PGDATA: "${DBDATA:-/var/lib/postgresql/data}"

volumes:
  datasrc:
  datadb:
  datafiles:
```

## Usage
To set your own environment variables create a .env file with some (or all) of these variables
```bash
#DB Configuration
DB=postgres
DBHOST=db
DBNAME=moodle
DBUSER=moodle
DBPASSWORD=moodle
DBDATA=/data

# Docker Volumes binding
VOLDB=./db
VOLFILES=./moodledata
```

Start container 
```bash
docker-compose up -d
```

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License
[MIT](https://choosealicense.com/licenses/mit/)
