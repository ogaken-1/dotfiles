$nix_config = "extra-experimental-features = flakes pipe-operators"
ENV["NIX_CONFIG"] = $nix_config

def os_config
  uname = `uname -s`.strip
  case uname
  when "Darwin"
    {
      rebuild: "sudo NIX_CONFIG='#{$nix_config}' darwin-rebuild",
      hostname: `scutil --get ComputerName`.strip,
    }
  when "Linux"
    {
      rebuild: "sudo NIX_CONFIG='#{$nix_config}' nixos-rebuild",
      hostname: `hostname`.strip,
    }
  else
    raise "Unsupported OS: #{uname}"
  end
end

desc "Execute the switch command based on your OS."
task :switch do
  config = os_config
  command = "#{config[:rebuild]} switch --flake .##{config[:hostname]}"
  sh command
end

task default: "switch"
