{
	description = "<>";

	outputs = { self, nixpkgs }:
		with nixpkgs.legacyPackages.x86_64-linux; {

			packages.x86_64-linux.default = stdenv.mkDerivation {
				name = "<>";
				version = "<>";
				src = ./.;
				buildInputs = [ cmake ];
			};

			devShell.x86_64-linux = mkShell {
				buildInputs = [ cmake cmake-language-server clang-tools ];
			};
		};
}
