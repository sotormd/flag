{
  description = "a pattern called flag";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    pattern.url = "github:sotormd/pattern";
  };

  outputs = inputs: {
    nixosConfigurations.flag = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        inputs.pattern.nixosModules.pattern
        (
          { pkgs, ... }:
          {
            networking.hostName = "flag";

            pattern = {
              image = {
                id = "flag";
                version = "0.0.2";
                updates = {
                  url = "http://localhost";
                  pubring = ./flag-pubring.pgp;
                };
              };
              partitions = {
                disk = "/dev/sda";
                sizes = {
                  esp = "1G";
                  verity = "1G";
                  usr = "10G";
                };
                persist = {
                  etc = true;
                  home = true;
                  srv = true;
                  var = true;
                };
              };
              userspace = {
                homed = true;
                desktop = false; # dont want to use default desktop
                distrobox = true;
                sandboxing = false; # no thank you
              };
              debug = false;
            };

            # we will serve updates from /var/updates
            services.lighttpd = {
              enable = true;
              document-root = "/var/update";
            };

            systemd.services.create-var-updates = {
              description = "Create update directory for lighttpd";
              wantedBy = [ "lighttpd.service" ];
              path = [ pkgs.coreutils-full ];
              script = ''
                mkdir -p /var/update
              '';
              serviceConfig.Type = "oneshot";
            };

            # MATE desktop because why not
            services.xserver = {
              enable = true;
              desktopManager.mate = {
                enable = true;
                enableWaylandSession = true;
              };
              displayManager.lightdm.enable = true;
            };

            services.spice-vdagentd.enable = true;
            services.spice-autorandr.enable = true;
            services.qemuGuest.enable = true;

            environment.systemPackages = [ pkgs.microfetch ];

            # this should be changed after setup
            users.users.root.initialPassword = "flag";
          }
        )
      ];
    };
  };
}
