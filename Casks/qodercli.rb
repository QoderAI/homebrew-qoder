cask "qodercli" do
  version "1.0.5"
  desc "Terminal-based AI assistant for code development"
  homepage "https://qoder.com"

  on_macos do
    if Hardware::CPU.arm?
      url "https://qoder-ide.oss-accelerate.aliyuncs.com/qodercli/releases/1.0.5/qodercli-darwin-arm64.tar.gz"
      sha256 "e786a451169c83190813fb6b5680e2c481a4d7649459ca5944e5020853366c23"
    else
      url "https://qoder-ide.oss-accelerate.aliyuncs.com/qodercli/releases/1.0.5/qodercli-darwin-x64.tar.gz"
      sha256 "e5a3258d732b8e9b32955ea4a88f84d4b8e8fd63aec05569598f39a9de880ab4"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://qoder-ide.oss-accelerate.aliyuncs.com/qodercli/releases/1.0.5/qodercli-linux-arm64.tar.gz"
      sha256 "003abbdfe5b43d6cff499d34f93214aa0a4f6d825b9532633d95676a96d0a7c9"
    else
      url "https://qoder-ide.oss-accelerate.aliyuncs.com/qodercli/releases/1.0.5/qodercli-linux-x64.tar.gz"
      sha256 "cc0eea07226db1b0b01083d88e6a73bfb7412e8c693947b940789d2da2888b5f"
    end
  end

  binary "qodercli"

  postflight do
    set_permissions "#{staged_path}/qodercli", "0755"

    # Write install marker
    File.write("#{staged_path}/.qodercli-install-resource", "homebrew-cask")
    set_permissions "#{staged_path}/.qodercli-install-resource", "0644"

    ENV["QODER_CLI_INSTALL"] = "1"

    begin
      log_dir = File.expand_path("~/.qoder/logs")
      FileUtils.mkdir_p(log_dir)
      timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
      log_file = "#{log_dir}/install_#{timestamp}.log"
      log_content = [
        "Install Time: #{Time.now}",
        "Version: #{version}",
        "Platform: #{RUBY_PLATFORM}",
        "Install Method: homebrew-cask",
        "Staged Path: #{staged_path}",
      ].join("\n")
      File.write(log_file, log_content)
      FileUtils.ln_sf(log_file, "#{log_dir}/qodercli_install.log")

      # Verify installation
      output = `"#{staged_path}/qodercli" --version 2>&1`.strip
      puts "qodercli #{version} installed successfully (#{output})"
    rescue => e
      opoo "Post-install logging failed: #{e.message}"
    end
  end
end
