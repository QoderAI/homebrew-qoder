cask "qodercli" do
  version "0.2.15"
  desc "Terminal-based AI assistant for code development"
  homepage "https://qoder.com"

  on_macos do
    if Hardware::CPU.arm?
      url "https://qoder-ide.oss-accelerate.aliyuncs.com/qodercli/releases/0.2.15/qodercli-darwin-arm64.tar.gz"
      sha256 "60c79023fe30f60e2a3127f1ae5fad796e46313e1ab3d7233b3e8739d0f3ca42"
    else
      url "https://qoder-ide.oss-accelerate.aliyuncs.com/qodercli/releases/0.2.15/qodercli-darwin-x64.tar.gz"
      sha256 "b26a3612a34149ca939ce59a219ba98aaa1df9eba28b40b557ae6a09c4c358d2"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://qoder-ide.oss-accelerate.aliyuncs.com/qodercli/releases/0.2.15/qodercli-linux-arm64.tar.gz"
      sha256 "e5cba044ad9fcfe757c67b57c0d1f022fb98eaa26de4fba18b94b0595b4fc30c"
    else
      url "https://qoder-ide.oss-accelerate.aliyuncs.com/qodercli/releases/0.2.15/qodercli-linux-x64.tar.gz"
      sha256 "89c89c5ee5f0370c997c59a72acf9ebb58d5b02c9a698bb7cde58cf3185d482c"
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
