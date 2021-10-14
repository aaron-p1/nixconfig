
newSystemPath := /mnt/etc/nixos
systemPath := /etc/nixos

path :=
nixargs :=

default: existing

existing: path := ${systemPath}
new: path := ${newSystemPath}

existing new:
	[ -w ${path} ]
	mkdir -p ${path}
	rsync --verbose --delete-after --recursive --cvs-exclude --filter=':- .gitignore' --checksum . ${path}

switch:
	nixos-rebuild ${nixargs} switch

update:
	cat ./afterupdate.txt
	nix flake update
	cat ./afterupdate.txt

.PHONY: default existing new switch update
