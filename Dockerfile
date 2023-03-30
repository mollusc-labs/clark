FROM perl:latest AS build
RUN apt-get install -y default-libmysqlclient-dev
RUN cpan Mojolicious Bread::Board DBI DBD::mysql DBIx::Class Crypt::Argon2 DateTime

FROM build AS clark
RUN sleep 1
EXPOSE 3000
WORKDIR /clark
COPY . .
# Prefork will run in multiple threads, daemon runs on a single thread, adjust wisely.
CMD ["perl", "clark.pl", "prefork", "-m", "production"]