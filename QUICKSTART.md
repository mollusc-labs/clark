# How to get started with Clark:
1. Make sure you have the Perl >5.10 and the following packages installed:
    - On Ubuntu you can install them like this:
        ```
        sudo apt install libio-prompter-perl libterm-readkey-perl
        ```
    - Or on other distros with CPAN:
        ```
        sudo cpan install IO::Prompter Term::ReadKey
        ```
2. Run the `make-env.pl` script via: `perl make-env.pl` or `./make-env.pl`
3. Ensure you have `docker` and `docker-compose`
4. Run with `docker-compose start` (the first run will take a few minutes)
5. Now you should be able to login at `localhost:3000` with the default clark credentials you provided
6. Generate an API key on `/dashboard/api-keys`, and share it with your services!
7. Happy logging.