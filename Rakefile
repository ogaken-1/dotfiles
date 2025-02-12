ENV["NIX_CONFIG"] = "extra-experimental-features = flakes"

def os_config
  uname = `uname -s`.strip
  case uname
  when "Darwin"
    {
      rebuild: "nix run nix-darwin --",
      hostname: `scutil --get ComputerName`.strip,
    }
  when "Linux"
    {
      rebuild: "sudo nixos-rebuild",
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
