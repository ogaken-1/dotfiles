require "open3"
require "tempfile"

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

desc "Update flake.lock and create a commit with version diff"
task :update do
  repo_root = `git rev-parse --show-toplevel`.strip
  Dir.chdir(repo_root)

  sh "git restore --staged ."

  # プロファイルパスを取得
  profiles_dir = "/nix/var/nix/profiles"
  current_system = "#{profiles_dir}/system"
  # 後々比較するためにアップデート前のprofileのパスを取得しておく
  old_profile = "#{profiles_dir}/#{File.readlink(current_system)}"

  sh "nix flake update"

  # 更新後を適用
  Rake::Task[:switch].invoke

  # アップデート後のprofileのパスを取得
  new_profile = "#{profiles_dir}/#{File.readlink(current_system)}"

  sh "git add flake.lock"

  # 更新されたパッケージの一覧を取得する
  nvd_output, status = Open3.capture2("nvd", "diff", old_profile, new_profile)

  if status.success?
    # 最初の2行と各行の#を削除
    # 2行はnvdの出力ヘッダーなので要らない
    # #はgithubでissueへのメンションが乱発してやばい
    processed_output = nvd_output.lines[2..-1].join.gsub('#', '')

    # 一時ファイルに書き込み、git commitのテンプレートとして使用
    Tempfile.create('commit-template') do |tmpfile|
      tmpfile.write(processed_output)
      tmpfile.flush

      sh "git commit --template=#{tmpfile.path}"
    end
  else
    abort "nvd diff failed"
  end
end
