{
	description = "A package";
	inputs = {
		nixpkgs = {
			url = "github:NixOS/nixpkgs/nixos-unstable";
		};
	};
	outputs =
		{ nixpkgs, flake-utils, ... }:
		flake-utils.lib.eachDefaultSystem
		(system:
			let
				pkgs = import nixpkgs {
					inherit system;
				};
			in
			{
				devShells.default = pkgs.mkShellNoCC {
					packages = with pkgs; [
						{{_cursor_}}
					];
				};
			}
		);
}
