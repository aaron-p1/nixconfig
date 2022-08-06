
newSystemPath := /mnt/etc/nixos
systemPath := /etc/nixos

path :=
nixargs :=

rebuildCmds := switch boot test build

default: existing

existing: path := ${systemPath}
new: path := ${newSystemPath}

existing new:
	[ -w ${path} ]
	mkdir -p ${path}
	rsync --verbose --delete-after --recursive --cvs-exclude --filter=':- .gitignore' --filter=':- .rsyncignore' --checksum . ${path}

${rebuildCmds}: existing
	nixos-rebuild ${nixargs} $@

update:
	cat ./afterupdate.txt
	@read -p "Update? " -n 1 -r ; echo ; [[ "$$REPLY" =~ ^[YyJj]$$ ]]
	nix flake update

listChanges:
	ls -d1 /nix/var/nix/profiles/system-*-link | sort -V | tail -n 2 | xargs nix store diff-closures | less

fixDependencies:
	nix shell nixpkgs#git-crypt --command direnv reload

.PHONY: default existing new ${rebuildCmds} update listChanges fixDependencies
