# Server Config

Automated configuration scripts for my personal stuff, including a Raspberry Pi,
a development server, assorted cloud services, and some homebrew IoT devices.

## Setup & Usage

### Terraform

Terraform variables go in `terraform/variables.tfvars`. State is stored in S3.

    cd terraform
    terraform init
    terraform apply

### Raspberry Pi

This depends on Terraform, since we need API tokens to be provisioned to use for
config.

We expect certain admin passwords and secrets to be provided, presumably from a
vault or from terraform.

    echo SOME_PASSWORD1 > ruby/secrets/grafana_password
    echo SOME_PASSWORD2 > ruby/secrets/influxdb_password

    # AWS credential needs to be able to write to our secrets bucket and post to
    # SNS. See terraform config.
    echo SOME_PASSWORD3 > ruby/secrets/aws_access_key_id
    echo SOME_PASSWORD4 > ruby/secrets/aws_secret_access_key

To apply configuration:

    cd ruby
    bin/apply-styx

#### Development Server

Assumes a minimal Devuan install. After install need to manually configure
password SSH access for root (`/etc/ssh/sshd_config`) to enable bootstrap. I
have a proxmox snapshot and clone of this state.

    cd ruby
    ssh-copy-id root@$HOST
    ssh root@$HOST 'bash -s' < scripts/bootstrap.bash

AWS secrets are needed as these are required by terraform. (A `tfvars` file will
also be needed depending on which modules are being developed.)

    echo SOME_PASSWORD5 > ruby/secrets/terraform_aws_access_key_id
    echo SOME_PASSWORD6 > ruby/secrets/terraform_aws_secret_access_key

From there we can proceed normally (which will disable root SSH access):

    bin/apply-apollo
    
#### Concepts

A microframework modeled off [Babushka](https://github.com/benhoskings/babushka)
is used to setup a single Raspberry Pi for miscellaneous tasks around the home.
This choice is motivated by a number of factors:

* Not wanting to run an agent on the Pi itself.
* Mostly wanting to "just run shell scripts", with a smattering of idempotency.
* It's more a pet than cattle.
* Finding the "translation tax" into Ansible YML too heavy.
* It's only me using it and I know exactly what I want.
* Framework is small enough I could rewrite it in a day.
* It's fun.

### IoT

See `iot/README.md`.