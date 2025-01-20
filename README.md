# Server Config

Automated configuration scripts for my personal stuff, including a Raspberry Pi,
a development server, assorted cloud services, and some homebrew IoT devices.

## Setup & Usage

### Secrets

Secrets are stored in an encrypted blob inside the repo. The decryption key
(from your password manager) should be placed into `keyctl` before beginning
development.

    bin/set-system-key

(Note: some terraform secrets are still stored outside the repo in a `tfvars`
file that will need to be copied from somewhere)

### Terraform

Terraform variables and secrets go in `terraform/variables.tfvars`. State is
stored in S3.

    cd terraform
    terraform init
    terraform apply

### Raspberry Pi

This depends on Terraform, since we need API tokens to be provisioned to use for
config.

To apply configuration:

    cd ruby
    bin/apply-styx

#### Development Server

Assumes a minimal Devuan install. After install need to manually configure
password SSH access for root (`/etc/ssh/sshd_config`) to enable bootstrap. I
have a proxmox snapshot and clone of this state.

    cd ruby
    export HOST=192.168.1.X # Edit to taste
    ssh-copy-id root@$HOST
    scripts/local_bootstrap.bash $HOST

On windows, Visual Studio Code may use a different SSH key than WSL, and
something like the following may be needed:

    cat /mnt/c/Users/$USERNAME/.ssh/id_rsa.pub | ssh $HOST 'cat - >> .ssh/authorized_keys'

A `tfvars` file will also be needed depending on which modules are being developed.

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