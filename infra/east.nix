# Terranix module for the "east" GCE devbox. `nix run .#infra -- <tofu args>`
# renders this to infra/config.tf.json and runs OpenTofu on it (see flake.nix).
# Auth comes from application-default credentials:
#   gcloud auth application-default login
{ inputs, lib, ... }:
let
  project = "gen-lang-client-0029335129";
  region = "us-west1";
  zone = "us-west1-b";
  sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIHcGBFNeXDBqJ0o3/SX+YfkCLTugtfyGeSR7rpmu7+o autumn@dmodel.ai";
in
{
  terraform.required_providers.google.source = "hashicorp/google";

  provider.google = { inherit project region zone; };

  # Dedicated network so nothing depends on the project's "default" VPC
  # existing.
  resource.google_compute_network.devbox = {
    name = "devbox";
    auto_create_subnetworks = true;
  };

  resource.google_compute_firewall.devbox-ssh = {
    name = "devbox-allow-ssh";
    network = "\${google_compute_network.devbox.name}";
    allow = [
      {
        protocol = "tcp";
        ports = [ "22" ];
      }
    ];
    source_ranges = [ "0.0.0.0/0" ];
  };

  # n2d-standard-16: 16 EPYC vCPU, 64 GiB. GPU heavy lifting belongs on
  # ephemeral compute workers, not the devbox.
  resource.google_compute_instance.east = {
    name = "east";
    machine_type = "n2d-standard-16";
    inherit zone;
    allow_stopping_for_update = true;

    boot_disk = {
      device_name = "east-root";
      initialize_params = {
        # Only boots once; nixos-anywhere replaces it with the flake's NixOS.
        image = "debian-cloud/debian-12";
        size = 200;
        type = "pd-balanced";
      };
    };

    network_interface = [
      {
        network = "\${google_compute_network.devbox.name}";
        # ephemeral public IP
        access_config = [ { } ];
      }
    ];

    # The Debian guest agent creates this user with passwordless sudo, which is
    # all nixos-anywhere needs to take the box over. The project-wide metadata
    # enables OS Login (this is a shared dmodel project), which would make the
    # agent ignore ssh-keys — override it off for this instance.
    metadata = {
      ssh-keys = "autumn:${sshKey}";
      enable-oslogin = "FALSE";
    };
  };

  # First apply: kexecs the Debian instance into an installer, partitions per
  # east's disko config, installs the flake's NixOS system. Later applies:
  # nixos-rebuilds the target when the system closure changed. Recreating the
  # instance (new id) triggers a fresh install. The ../. flake ref works
  # because the wrapper always runs tofu from infra/.
  module.east-install = {
    # A git source (not the store path) because the module references its
    # siblings with ../ paths, which tofu only allows within one source
    # "package". Pinned to the rev in flake.lock; bump with
    # `nix flake update nixos-anywhere`.
    source = "git::https://github.com/nix-community/nixos-anywhere.git//terraform/all-in-one?ref=${inputs.nixos-anywhere.rev}";
    nixos_system_attr = "../.#nixosConfigurations.east.config.system.build.toplevel";
    nixos_partitioner_attr = "../.#nixosConfigurations.east.config.system.build.diskoScript";
    target_host = "\${google_compute_instance.east.network_interface[0].access_config[0].nat_ip}";
    install_user = "autumn";
    instance_id = "\${google_compute_instance.east.id}";
  };

  output.east_ip.value = "\${google_compute_instance.east.network_interface[0].access_config[0].nat_ip}";
}
