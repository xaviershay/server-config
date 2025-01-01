# Server Config

Automated configuration scripts for my personal stuff.

Right now it's a single Raspberry Pi, but I anticipate adding terraform for cloud things.

## Setup & Usage

We expect certain admin passwords to be provided, presumably from a vault.

    echo SOME_PASSWORD1 > ruby/secrets/grafana_password
    echo SOME_PASSWORD2 > ruby/secrets/influxdb_password

To apply configuration:

    cd ruby
    bin/apply

## Concepts

A microframework modeled off [Babushka](https://github.com/benhoskings/babushka) is used to setup a single Raspberry Pi for miscellaneous tasks around the home. This choice is motivated by a number of factors:

* Not wanting to run an agent on the Pi itself.
* Mostly wanting to "just run shell scripts", with a smattering of idempotency.
* It's more a pet than cattle.
* Finding the "translation tax" into Ansible YML too heavy.
* It's only me using it and I know exactly what I want.
* Framework is small enough I could rewrite it in a day.
* It's fun.
