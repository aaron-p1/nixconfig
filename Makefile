
newSystemPath := /mnt/etc/nixos
systemPath := /etc/nixos

path :=

default: existing

existing: path := ${systemPath}
new: path := ${newSystemPath}

existing new:
	[ -w ${path} ]
	mkdir -p ${path}
	nix-shell -p rsync --run "rsync --verbose --delete-after --recursive --cvs-exclude --checksum . ${path}"

switch:
	nixos-rebuild switch

.PHONY: default existing new switch
