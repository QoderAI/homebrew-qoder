cask "qodercli" do
  version "1.0.6"
  desc "Terminal-based AI assistant for code development"
  homepage "https://qoder.com"

  on_macos do
    if Hardware::CPU.arm?
      url "https://qoder-ide.oss-accelerate.aliyuncs.com/qodercli/releases/1.0.6/qodercli-darwin-arm64.tar.gz"
      sha256 "36e0427e66f8d282feed6cda39aaf1350ee504ce00bdf4f6497540d6fa3d5b44"
    else
      url "https://qoder-ide.oss-accelerate.aliyuncs.com/qodercli/releases/1.0.6/qodercli-darwin-x64.tar.gz"
      sha256 "518b51cae0dde212135beca9532b80c72530b65af54524d6d1afa187d5cb5159"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://qoder-ide.oss-accelerate.aliyuncs.com/qodercli/releases/1.0.6/qodercli-linux-arm64.tar.gz"
      sha256 "6fb95a1cd015e330e79ec2b0d833116c285203b902a4a17357f1da6af5e7c97d"
    else
      url "https://qoder-ide.oss-accelerate.aliyuncs.com/qodercli/releases/1.0.6/qodercli-linux-x64.tar.gz"
      sha256 "f3c1afd7c3fe38b77b35a13ab4ae8d822cc717f0fa8a4324bbd2eace48ec7a10"
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
