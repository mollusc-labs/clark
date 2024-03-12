# How to get started with Clark:
1. Make sure you have the Perl >5.10 and the following packages installed:
    - On Ubuntu you can install them like this:
        ```
        sudo apt install libio-prompter-perl libterm-readkey-perl
        ```
    - Or on other distros with CPAN:
        ```
        cpan -I IO::Prompter Term::ReadKey
        ```
2. Run the `setup.pl`, press no if you're asked to setup mysql-rsyslog
3. Ensure you have `docker` and `docker-compose`
4. Run with `docker-compose start` (the first run will take a few minutes)
5. Now you should be able to login at `localhost:3000` with the default clark credentials you provided
6. Log in and generate an API key on `/dashboard/api-keys`, and share it with your services!
7. Happy logging.

## Getting logs from other processes

## Syslog

#### Getting logs from containers
Make sure you setup your containers to use `syslog` as the logging driver, this can be
done by following the guide on Docker's website, [click here](https://docs.docker.com/config/containers/logging/syslog/) for more information.

**TLDR**: run your containers with the following flags, make sure to replace `<container-name>` and `<clark-hostname>` with values that makesense,
if you're running clark locally, then your `<clark-hostname>` will be `localhost`.
```
docker run --name <container-name> --log-driver syslog --log-opt tag="{{.Name}}" --log-opt syslog-address=udp://<clark-hostname>:514
```

Make sure you point the logging end-point to the server at-which you host your clark instance.

#### Getting logs from other machines
You will need to configure `rsyslog` on remote machines to point to your machine, Clark will handle the rest.
It should be as simple as adding:

```
*.* @loghost
```

to your remote machines `rsyslog` configuration. Obviously `loghost` should be replaced by the hostname of the machine that's running Clark.

### Option 2: Rest API
This is a less reliable alternative to using syslog, you'll have to generate a REST
API key from your Clark dashboard to make logging requests. The logging REST API lives
on `/api/logs` and you can create a new log by POSTing data in the following format:
```json
{
    "severity": 1,
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

### Option 3: AMQP

**TODO**
