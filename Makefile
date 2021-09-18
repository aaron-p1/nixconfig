
newSystemPath := /mnt/etc/nixos
systemPath := /etc/nixos

path :=

default: existing

existing: path := ${systemPath}
new: path := ${newSystemPath}

existing new:
	[ -w ${path} ]
	mkdir -p ${path}
	rsync --verbose --delete-after --recursive --cvs-exclude --filter=':- .gitignore' --checksum . ${path}

switch:
	nixos-rebuild switch

.PHONY: default existing new switch
