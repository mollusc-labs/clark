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

## Getting logs from containers
Make sure you setup your containers to use `syslog` as the logging driver, this can be
done by following the guide on Docker's website, [click here](https://docs.docker.com/config/containers/logging/syslog/) for more information.

Make sure you point the logging end-point to the server at-which you host your clark instance.

## Getting logs from other machines/over-the-wire

### Option 1: Syslog
You'll want to setup your syslog daemon (probably Rsyslog) to receive data from UDP and TCP.
On your Clark instance machine you'll add the following to `/etc/rsyslog.conf`:

```
$ModLoad imudp.so
$UDPServerRun 514
$ModLoad imtcp.so
$InputTCPServerRun 514
```

Then on your remote machines add the following to configure Rsyslog by editing your `/etc/rsyslog.d/remote.conf` 
file (you may have to create this):

```
*.* 
```

If your client is a docker container, you just have to point it's syslog to your server.

### Option 2: Rest API
This is a less reliable alternative to using syslog, you'll have to generate a REST
API key from your Clark dashboard to make logging requests. The logging REST API lives
on `/api/logs` and you can create a new log by POSTing data in the following format:

```json
{
    "severity": "warn",
    "service_name": "foo-service",
    "message": "foo bar"
}
```

with a header:

```
X-Clark: <YOUR-SERVICE-API-KEY>
```

This is mostly recommended for systems with informational logging or non-critical logs. If you want to log
fatal errors, server outtages, etc. You'll want to stick to syslog.