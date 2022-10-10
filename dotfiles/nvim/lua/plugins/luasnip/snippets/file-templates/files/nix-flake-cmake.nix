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
			buildInputs = [ cmake cmake-language-server clang ];
				# used in nvim
				NVIM_CLANGD_INCLUDE = "${glibc.dev}/include"
					+ ":${llvmPackages.clang-unwrapped.lib}/lib/clang/${clang.version}/include/";
		};
	};
}
