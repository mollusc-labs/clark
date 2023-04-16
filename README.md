# Clark
A free and open-source logging dashboard, and REST API for `rsyslog` and theoretically any other syslog-daemon.

## How to use
1. Make sure you have Perl >5.10 and the following packages installed:
    - On Ubuntu you can install them like this:
        ```
        sudo apt install libio-prompter-perl libterm-readkey-perl
        ```
    - Or on other distros with CPAN:
        ```
        sudo cpan install IO::Prompter Term::ReadKey
        ```
2. Run Clarks system configuration script: `./setup.pl`
3. Make sure you have `docker` and `docker compose`
4. Run the following commands to install and run Clark (the first install may take a few minutes):
    ```bash
    git clone https://github.com/mollusc-labs/clark
    cd clark
    docker-compose up -d
    ```
5. Read `QUICKSTART.md` to figure out what logging configuration works for you!
6. Happy logging!

## Use in production
It is highly recommended to place Clark behind a proxy like `NGiNX`, `httpd` or similar, before exposing it to the internet.
You will also want to ensure that you are using `HTTPS`.

## Troubleshooting

#### Port is closed
`setup.pl` will configure `rsyslog` to use port `514` for both UDP and TCP traffic, some people may want to change these
or are simply unable to open these ports. In that case edit `rsyslog.d/remote.conf` to use whatever port you'd like.

#### Firewalls
If you plan to log over the internet (not recommended outside of the REST API) you will need to open the port specified
in the `rsyslog.d/remote.conf`, this is defaulted to `514` for both TCP and UDP.

## Contributing
Clark is a Perl application using `Mojolicious` that uses a `Vue3` frontend. Any and all contributions will be considered!
Make sure your Perl code follows the `.perltidyrc`'s configuration before you make any pull-requests. Thanks!

#### How to run in development
Run `docker-compose up -d clark_database` and `setup.pl`, then install all of the CPAN dependencies listed in the `cpanfile`.

Now you can run the frontend with `cd frontend && yarn dev`, and the backend with `./dev.sh`.

## License
Clark is licensed under the `BSD-3 Clause` license, to learn more, please view the `LICENSE` file at the root of
the project.