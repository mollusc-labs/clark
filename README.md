# Clark
A free and open-source logging dashboard, and REST API for `syslog`, `REST`, and soon, `AMQP`.
Clark is packaged as a simple docker-compose setup, allowing for seamless integrations and deployments.

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

## Contributing
Clark is a `Mojolicious` application that uses a `Vue3` frontend. Any and all contributions will be considered!
Make sure your Perl code follows the `.perltidyrc`'s configuration before you make any pull-requests. Thanks!

## License
Clark is licensed under the `BSD-3 Clause` license, to learn more, please view the `LICENSE` file at the root of
the project.