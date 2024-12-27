
newSystemPath := /mnt/etc/nixos
systemPath := /etc/nixos

path :=
nixargs :=

rebuildCmd := nixos-rebuild
rebuildCmds := boot test build switch

nixpkgsRepoFilesBefore := https://raw.githubusercontent.com/NixOS/nixpkgs/
nixpkgsRLNotesFile := /nixos/doc/manual/release-notes/rl-2505.section.md
nixpkgsBranch := nixos-unstable

homeManagerRepoFilesBefore := https://raw.githubusercontent.com/nix-community/home-manager/
homeManagerRLNotesFile := /docs/release-notes/rl-2505.md
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
