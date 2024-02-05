{ config, lib, ... }:
let
	inherit (lib) mkEnableOption mkIf;

	cfg = config.within.<>;
in {
	options.within.<> = {
		enable = mkEnableOption "<>";
	};

	config = mkIf cfg.enable {
		<>
	};
}
