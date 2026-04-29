cask "qodercli" do
  version "0.2.5"
  desc "Terminal-based AI assistant for code development"
  homepage "https://qoder.com"

  on_macos do
    if Hardware::CPU.arm?
      url "https://qoder-ide.oss-accelerate.aliyuncs.com/qodercli/releases/0.2.5/qodercli-darwin-arm64.tar.gz"
      sha256 "84c6dadf6d4b758d74bd1bd64aa7bff31d7dbed266bf75d3c47a652d5d81575f"
    else
      url "https://qoder-ide.oss-accelerate.aliyuncs.com/qodercli/releases/0.2.5/qodercli-darwin-x64.tar.gz"
      sha256 "d92f88a115b818bcc488d3661ee4ef3e4650c8baea65dcee9831fd2c43071af2"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://qoder-ide.oss-accelerate.aliyuncs.com/qodercli/releases/0.2.5/qodercli-linux-arm64.tar.gz"
      sha256 "1e8bf94f468aa64e03a07694919ea9c44ad20869c35d5804671a0a65ec73c9fb"
    else
      url "https://qoder-ide.oss-accelerate.aliyuncs.com/qodercli/releases/0.2.5/qodercli-linux-x64.tar.gz"
      sha256 "3ababd13ffa541b8e75cd7544085c432c54c47664c8395c9ba2b3fc35cc94044"
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
