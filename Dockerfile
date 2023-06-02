FROM perl:latest AS build
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y default-libmysqlclient-dev
RUN cpan -T Mojolicious Bread::Board DBI DBD::mysql DBIx::Class Crypt::Argon2 DateTime Crypt::JWT DateTime::Format::MySQL JSON::Validator Data::UUID

FROM node:20 AS frontend
WORKDIR /frontend
COPY ./frontend .
RUN yarn && yarn build

FROM frontend AS run
EXPOSE 3000
WORKDIR /clark
COPY --from=frontend /frontend ./frontend
COPY lib ./lib
COPY templates ./templates
COPY clark.pl .
# Prefork will run in multiple threads, daemon runs on a single thread, adjust wisely.
CMD ["perl", "clark.pl", "prefork", "-m", "production"]