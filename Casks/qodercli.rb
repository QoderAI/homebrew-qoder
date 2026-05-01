cask "qodercli" do
  version "0.2.6"
  desc "Terminal-based AI assistant for code development"
  homepage "https://qoder.com"

  on_macos do
    if Hardware::CPU.arm?
      url "https://qoder-ide.oss-accelerate.aliyuncs.com/qodercli/releases/0.2.6/qodercli-darwin-arm64.tar.gz"
      sha256 "a04a55f730470cefdda69aeb383c43a92e945539d192b344c92b0f6625e3f9b2"
    else
      url "https://qoder-ide.oss-accelerate.aliyuncs.com/qodercli/releases/0.2.6/qodercli-darwin-x64.tar.gz"
      sha256 "b98f2567f34f68269001326813f3c7b42fc5e31a342d2c0b19867684c43de185"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://qoder-ide.oss-accelerate.aliyuncs.com/qodercli/releases/0.2.6/qodercli-linux-arm64.tar.gz"
      sha256 "fbcd05cf64938ef2fa6228ae9026cebb1640d065f57c5bc3736748443e68746d"
    else
      url "https://qoder-ide.oss-accelerate.aliyuncs.com/qodercli/releases/0.2.6/qodercli-linux-x64.tar.gz"
      sha256 "be3b283db58e36394ac9c15b3b966f23188d6795be7e1edbec5535c9d8153293"
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
