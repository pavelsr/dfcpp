dfcpp - Dockerfile post-processing by cpanfile.

Automatically creates separate docker layer for each Perl module, mentioned in cpanfile

Simple console utility for Perl developers. Saves time when debugging
what is wrong during docker container build.

# Problem

It's not possible to run container from layer
corresponding to last failed module.

Sometimes you are getting module install error,
like `Installing WWW::Telegram::BotAPI failed`.

It's bit of complicated to define the reason
because `cpanm` puts info about error in a separate file,
like `/root/.cpanm/work/1517580036.144/build.log`,
but you can't access this file in case of Docker container build
since Docker doesn't save result of failed build.

`dfcpp` auto-rewrites Dockerfile so that each module  
is installing by separate command
(like `RUN cpanm WWW::Telegram::BotAPI`),
so in new layer (each Dockerfile command = separate layer),
instead of installing modules batch way
(like `cpanm --installdeps .`) in a single layer.

This approach saves much time if you have a lot of modules.

To troubleshot you just need to run stopped container,
which is the result of last successfully executed command in Dockerfile
( = last successfully installed module).

# Example

Dockerfile:

```
RUN apk update && \
...
cpanm --installdeps .
```

cpanfile:

```
requires 'List::MoreUtils';
requires 'Mojolicious::Lite';
requires 'MongoDB';
requires 'WWW::Telegram::BotAPI';
```

resulted Dockerfile:

```
RUN cpanm List::MoreUtils
RUN cpanm Mojolicious::Lite
RUN cpanm MongoDB
RUN cpanm WWW::Telegram::BotAPI
```

# Installing

## For local testing after git clone

```
sudo ln -s ${PWD}/dfcpp.pl /usr/bin/dfcpp
chmod +x /usr/bin/dfcpp
```

## From Github directly using wget, without git clone

```
```

# TO DO

* --help or man
* undo changes
* Python, Nodejs and other languages
