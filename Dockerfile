FROM postgres:14

COPY schema.sql /docker-entrypoint-initdb.d/