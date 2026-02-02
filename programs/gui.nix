# GUI preset: All programs including GUI applications (terminal emulators, etc.)
# Use for desktop environments like macOS (Darwin)
(import ./base.nix) ++ [
  ./rio
]
