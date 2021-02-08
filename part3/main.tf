terraform {
    required_providers {
        digitalocean = {
            source = "digitalocean/digitalocean"
        }
    }
}


variable do_token {}
provider digitalocean {
    token = var.do_token
}

data "digitalocean_ssh_key" "home" {
    name = "Home Desktop WSL"
}

data "digitalocean_ssh_key" "work" {
    name = "Work Laptop"
}

variable "region" {
    type    = string
    default = "nyc3"
}

variable "droplet_count" {
    type = number
    default = 1
}

variable "droplet_size" {
    type = string
    default = "s-1vcpu-1gb"
}

resource "digitalocean_droplet" "web" {
    count = var.droplet_count
    image = "ubuntu-20-04-x64"
    name = "web-${var.region}-${count.index +1}"
    region = var.region
    size = var.droplet_size
    ssh_keys = [data.digitalocean_ssh_key.home.id, 
        data.digitalocean_ssh_key.work.id]

    # ensures that we create the new resource before we destroy the old one
    # https://www.terraform.io/docs/configuration/resources.html#lifecycle-lifecycle-customizations
    lifecycle {
        create_before_destroy = true
    }
}

output "server_ip" {
    value = digitalocean_droplet.web.*.ipv4_address
}
