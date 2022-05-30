{ config, lib, ... }:
let
	cfg = config.within.<>;
in with lib; {
	options.within.<> = {
		enable = mkEnableOption "<>";
	};

	config = mkIf cfg.enable {
		<>
	};
}
