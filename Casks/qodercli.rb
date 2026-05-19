cask "qodercli" do
  version "1.0.0"
  desc "Terminal-based AI assistant for code development"
  homepage "https://qoder.com"

  on_macos do
    if Hardware::CPU.arm?
      url "https://qoder-ide.oss-accelerate.aliyuncs.com/qodercli/releases/1.0.0/qodercli-darwin-arm64.tar.gz"
      sha256 "9c073ad54df818541e7a8473070549dba4ebbe1a73dc799c6154e7f1cbe7e4df"
    else
      url "https://qoder-ide.oss-accelerate.aliyuncs.com/qodercli/releases/1.0.0/qodercli-darwin-x64.tar.gz"
      sha256 "ec913191247cb9ea6ba294d8fd7e815219345de92e08317db2206b1bc36fe5c2"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://qoder-ide.oss-accelerate.aliyuncs.com/qodercli/releases/1.0.0/qodercli-linux-arm64.tar.gz"
      sha256 "4c1d66505a921a547f6e6f18152a6ee5a1aa1bc8631e0e4072088047f58e3682"
    else
      url "https://qoder-ide.oss-accelerate.aliyuncs.com/qodercli/releases/1.0.0/qodercli-linux-x64.tar.gz"
      sha256 "cffcd3de6c0352004d2443d39aeb68b79d42ee8776b4b868c40dd473f05c213a"
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
