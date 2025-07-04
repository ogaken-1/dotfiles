{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShellNoCC {
	packages = with pkgs; [
		{{_cursor_}}
	];
}
