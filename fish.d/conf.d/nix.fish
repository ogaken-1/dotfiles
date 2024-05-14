# sudo install -d -m755 -o (id -u) -g (id -g) /nix
# curl -L https://nixos.org/nix/install | sh
set -l nixsetup "$HOME/.nix-profile/etc/profile.d/nix.fish"
if [ -e $nixsetup ]
  source $nixsetup
end
