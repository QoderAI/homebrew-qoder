cask "qodercli" do
  version "0.2.16"
  desc "Terminal-based AI assistant for code development"
  homepage "https://qoder.com"

  on_macos do
    if Hardware::CPU.arm?
      url "https://qoder-ide.oss-accelerate.aliyuncs.com/qodercli/releases/0.2.16/qodercli-darwin-arm64.tar.gz"
      sha256 "ea5d717bfcc03a440187f69cc2066e8136b7e8fe3f8fc380fdae538adbd82e6e"
    else
      url "https://qoder-ide.oss-accelerate.aliyuncs.com/qodercli/releases/0.2.16/qodercli-darwin-x64.tar.gz"
      sha256 "27913005513bf52006ce9c9a827390bb37b68da149d527c2688f71f9923df310"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://qoder-ide.oss-accelerate.aliyuncs.com/qodercli/releases/0.2.16/qodercli-linux-arm64.tar.gz"
      sha256 "59ae80a5d6ede8730dba214406a2a186119bc55d302b1509c258de35eb379056"
    else
      url "https://qoder-ide.oss-accelerate.aliyuncs.com/qodercli/releases/0.2.16/qodercli-linux-x64.tar.gz"
      sha256 "d9efa3b9e3ca5458120a06c94442e7f0fce8efed6c88d904e022cedcb6dceb67"
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
