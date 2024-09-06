packer {
  required_plugins {
    vultr = {
      version = ">=v2.3.2"
      source = "github.com/vultr/vultr"
    }
    ansible = {
      version = "~> 1"
      source = "github.com/hashicorp/ansible"
    }
  }
}

variable "vultr_api_key" {
  type      = string
  default   = env("vultr_api_key")
  sensitive = true
}

variable "image_tag" {
  type      = string
  default   = "dev"
}

source "vultr" "discord-bot-server" {
  api_key = var.vultr_api_key
  os_id = 1869  # Rocky Linux 9 x64
  plan_id = "vhp-1c-1gb-intel"
  region_id = "dfw"  # Dallas, Texas
  snapshot_description = "Discord Bot Server [${var.image_tag}] ${formatdate("YYYY-MM-DD HH:mm", timestamp())} UTC"
  state_timeout = "15m"
  ssh_username = "root"
  ssh_timeout = "5m"
}

build {
  hcp_packer_registry {
    bucket_name = "discord-bot-server"
    description = "Discord Bot Server image"
  }

  sources = ["source.vultr.discord-bot-server"]

  provisioner "ansible" {
    playbook_file = "ansible/playbook.yml"
  }
}