FROM perl:latest AS build
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y default-libmysqlclient-dev
RUN cpan Mojolicious Bread::Board DBI DBD::mysql DBIx::Class Crypt::Argon2 DateTime Crypt::JWT DateTime::Format::MySQL
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && apt-get install -y nodejs
RUN npm install -g yarn

FROM build AS frontend
WORKDIR /clark/frontend
COPY ./frontend .
VOLUME public
RUN yarn && yarn build

FROM frontend AS run
EXPOSE 3000
WORKDIR /clark
COPY lib ./lib
COPY templates ./templates
COPY public ./public
COPY clark.pl .
# Prefork will run in multiple threads, daemon runs on a single thread, adjust wisely.
CMD ["perl", "clark.pl", "prefork", "-m", "production"]