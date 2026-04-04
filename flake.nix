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
                version = "0.0.4";
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

            # configuring out MATE desktop
            # isnt it cool that it uses dconf
            systemd.user.services.mate-dconf = {
              enable = true;
              description = "Apply MATE dconf settings at login";
              after = [ "graphical.target" ];
              wantedBy = [ "default.target" ];
              path = [ pkgs.dconf ];
              script = ''
                dconf write /org/mate/terminal/profiles/default/use-theme-colors false

                dconf write /org/mate/terminal/profiles/default/background-color "'#000000000000'"
                dconf write /org/mate/terminal/profiles/default/foreground-color "'#FFFFFFFFFFFF'"

                dconf write /org/mate/terminal/profiles/default/scrollbar-position "'hidden'"

                dconf write /org/mate/marco/general/theme "'BlueMenta'"

                dconf write /org/mate/desktop/interface/gtk-theme "'BlueMenta'"
                dconf write /org/mate/desktop/interface/icon-theme "'mate'"
                dconf write /org/mate/desktop/peripherals/mouse/cursor-theme "'mate-black'"

                dconf write /org/mate/desktop/background/color-shading-type "'solid'"
                dconf write /org/mate/desktop/background/picture-options "'wallpaper'"
                dconf write /org/mate/desktop/background/primary-color "'rgb(88,145,188)'"
                dconf write /org/mate/desktop/background/secondary-color "'rgb(60,143,37)'"

                dconf write /org/mate/panel/toplevels/bottom/y 1055
              '';
              serviceConfig.Type = "oneshot";
            };

            services.spice-vdagentd.enable = true;
            services.spice-autorandr.enable = true;
            services.qemuGuest.enable = true;

            environment.systemPackages = [ pkgs.microfetch ];

            fonts.enableDefaultPackages = true;
            fonts.packages = [
              pkgs.nerd-fonts.jetbrains-mono
              pkgs.noto-fonts
            ];

            # this should be changed after setup
            users.users.root.initialPassword = "flag";
          }
        )
      ];
    };
  };
}
