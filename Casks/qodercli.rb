cask "qodercli" do
  version "0.2.11"
  desc "Terminal-based AI assistant for code development"
  homepage "https://qoder.com"

  on_macos do
    if Hardware::CPU.arm?
      url "https://qoder-ide.oss-accelerate.aliyuncs.com/qodercli/releases/0.2.11/qodercli-darwin-arm64.tar.gz"
      sha256 "6f86401dd63aa6d8bb653540786f553b3997dafe5d6b8717f6121603d7a86349"
    else
      url "https://qoder-ide.oss-accelerate.aliyuncs.com/qodercli/releases/0.2.11/qodercli-darwin-x64.tar.gz"
      sha256 "6bd61eff3bf30677183ddd39d383e8a91b39b525d2c8feffecb2e5e7534af448"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://qoder-ide.oss-accelerate.aliyuncs.com/qodercli/releases/0.2.11/qodercli-linux-arm64.tar.gz"
      sha256 "ba0f287fc9b6fe40b2001568f6b58bbb2116558f0fb2c91eae4f8e4d46d4c858"
    else
      url "https://qoder-ide.oss-accelerate.aliyuncs.com/qodercli/releases/0.2.11/qodercli-linux-x64.tar.gz"
      sha256 "315cf5e05a9be819fcb0f029f6826ed387f09954f444456f0a835896e8cb13af"
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
