cask "qodercli" do
  version "0.2.3"
  desc "Terminal-based AI assistant for code development"
  homepage "https://qoder.com"

  on_macos do
    if Hardware::CPU.arm?
      url "https://qoder-ide.oss-ap-southeast-1.aliyuncs.com/qodercli/releases/0.2.3/qodercli-darwin-arm64.tar.gz"
      sha256 "d4ffc660fae4fa1bce52a8f90b3bdf862ed7e4c78d0be3d2c7f1a10652fee0d7"
    else
      url "https://qoder-ide.oss-ap-southeast-1.aliyuncs.com/qodercli/releases/0.2.3/qodercli-darwin-x64.tar.gz"
      sha256 "b125f3a7d527ba2c38e5149aec497962c91bb57e9bb82a44c0badd07991aac0b"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://qoder-ide.oss-ap-southeast-1.aliyuncs.com/qodercli/releases/0.2.3/qodercli-linux-arm64.tar.gz"
      sha256 "1b3bd28798da575ce67f27732efee7d9b22a1e046d75b94f307b2bb8cc701b7d"
    else
      url "https://qoder-ide.oss-ap-southeast-1.aliyuncs.com/qodercli/releases/0.2.3/qodercli-linux-x64.tar.gz"
      sha256 "a81379dcd18fa7f46e643ebde5fbcd3b0c3fedc3017120998f654dbb0a916900"
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
