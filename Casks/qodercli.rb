cask "qodercli" do
  version "1.0.4"
  desc "Terminal-based AI assistant for code development"
  homepage "https://qoder.com"

  on_macos do
    if Hardware::CPU.arm?
      url "https://qoder-ide.oss-accelerate.aliyuncs.com/qodercli/releases/1.0.4/qodercli-darwin-arm64.tar.gz"
      sha256 "12c0ce516af3f72d8b598dd8c5b86b2cac254c2239f4a57d7dd97ef50f0136cf"
    else
      url "https://qoder-ide.oss-accelerate.aliyuncs.com/qodercli/releases/1.0.4/qodercli-darwin-x64.tar.gz"
      sha256 "1691b88a0f0a9c77d69414b42fe331abf99baf64e8f0ed09e1ed55bd72bab5ca"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://qoder-ide.oss-accelerate.aliyuncs.com/qodercli/releases/1.0.4/qodercli-linux-arm64.tar.gz"
      sha256 "5755e2d6af6cca8a489b46ec1ed9f2284e1dac2a813bec9504148c19c3ebe42e"
    else
      url "https://qoder-ide.oss-accelerate.aliyuncs.com/qodercli/releases/1.0.4/qodercli-linux-x64.tar.gz"
      sha256 "acd5051415df80bd36d7fd06422b17e94ca703be293acc3157ee1cc76142d7de"
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
