{ config, lib, ... }:
let
	inherit (lib) mkEnableOption mkIf;

	cfg = config.within.$1;
in {
	options.within.$1 = {
		enable = mkEnableOption "$2";
	};

	config = mkIf cfg.enable {
		$0
	};
}
