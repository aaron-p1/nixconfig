# A NixOS Config

# Install on new System

1. [Partition and format drives](https://nixos.org/manual/nixos/stable/index.html#sec-installation-partitioning)

2. Generate config

   Mount drives to /mnt

   ```shell
   nixos-generate-config --root /mnt
   ```

3. Add new host to config

   ```shell
   git clone https://github.com/aaron-p1/nixconfig.git
   ```

   Copy generated config (/mnt/etc/nixos) to new host directory and change it like the other hosts.

   Add entry to flake.nix

4. Install system
   Copy repo to /mnt/etc/nixos with:

   ```shell
   sudo nix-shell -p pkgs.gnumake --command 'make new'
   ```

   Build system

   ```shell
   sudo nix-shell -p pkgs.nixUnstable --command 'cd /mnt/etc/nixos && nixos-install --impure --flake .#HOSTNAME'
   ```

   Reboot

