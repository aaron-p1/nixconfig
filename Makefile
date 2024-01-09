
newSystemPath := /mnt/etc/nixos
systemPath := /etc/nixos

path :=
nixargs :=

rebuildCmds := boot test build

specialisationFile := /etc/specialisation

nixpkgsRepoFilesBefore := https://raw.githubusercontent.com/NixOS/nixpkgs/
nixpkgsRLNotesFile := /nixos/doc/manual/release-notes/rl-2405.section.md
nixpkgsBranch := nixos-unstable

homeManagerRepoFilesBefore := https://raw.githubusercontent.com/nix-community/home-manager/
homeManagerRLNotesFile := /docs/release-notes/rl-2405.md
homeManagerBranch := master

default: existing

existing: path := ${systemPath}
new: path := ${newSystemPath}

existing new:
	[ -w ${path} ]
	mkdir -p ${path}
	rsync --verbose --delete-after --recursive --cvs-exclude --filter=':- .gitignore' --filter=':- .rsyncignore' --checksum . ${path}

${rebuildCmds}: existing
	nixos-rebuild ${nixargs} $@

# when switching with specialisation support,
# > nixos-rebuild switch --specialisation "${specialisation}"
# updates the grub menu, so the specialisation is the default
# and the main config is not bootable anymore
#
# Workaround:
# > nixos-rebuild build
# > result/bin/switch-to-configuration boot
# > result/specialisation/${specialisation}/bin/switch-to-configuration test
#
# nixos-rebuild boot then nixos-rebuild test evaluates the config 2 times
switch: existing
	$(eval specialisation = $(shell [ -f $(specialisationFile) ] && cat $(specialisationFile)))
	nixos-rebuild ${nixargs} build
	result/bin/switch-to-configuration boot
	$(eval switchScript = result/$(if $(strip ${specialisation}),specialisation/$(specialisation)/)bin/switch-to-configuration)
	${switchScript} test

update:
	cat ./afterupdate.txt
	@read -p "Update? " -n 1 -r ; echo ; [[ "$$REPLY" =~ ^[YyJj]$$ ]]
	nix flake update

listChanges:
	ls -d1 /nix/var/nix/profiles/system-*-link | sort -V | tail -n 2 | xargs nix store diff-closures | less

urlBefore := ${nixpkgsRepoFilesBefore}
filePath := ${nixpkgsRLNotesFile}
branch := ${nixpkgsBranch}
flakeInputName := unstable
showLine := ^\#\#

check-release-notes:
	@# download old and new release notes to temporary folder
	$(eval tmpdir = $(shell mktemp -d))
	$(eval currentRev = $(shell cat flake.lock | jq -r '.nodes."${flakeInputName}".locked.rev'))
	@curl -s ${urlBefore}${currentRev}${filePath} > ${tmpdir}/oldRLNotes.md
	@curl -s ${urlBefore}${branch}${filePath} > ${tmpdir}/newRLNotes.md
	@# check if there are any changes in the release notes
	-@diff --color=always --unified=0 --show-function-line='${showLine}' \
		--ignore-space-change ${tmpdir}/oldRLNotes.md ${tmpdir}/newRLNotes.md
	@# remove temporary folder
	@rm -r ${tmpdir}

check-release-notes-home-manager: urlBefore := ${homeManagerRepoFilesBefore}
check-release-notes-home-manager: filePath := ${homeManagerRLNotesFile}
check-release-notes-home-manager: branch := ${homeManagerBranch}
check-release-notes-home-manager: flakeInputName := home-manager
check-release-notes-home-manager: showLine := ^===
check-release-notes-home-manager: check-release-notes

.PHONY: default existing new ${rebuildCmds} update listChanges check-release-notes check-release-notes-home-manager
