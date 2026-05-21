cask "qodercli" do
  version "1.0.2"
  desc "Terminal-based AI assistant for code development"
  homepage "https://qoder.com"

  on_macos do
    if Hardware::CPU.arm?
      url "https://qoder-ide.oss-accelerate.aliyuncs.com/qodercli/releases/1.0.2/qodercli-darwin-arm64.tar.gz"
      sha256 "ff2822a177df923cd0cd443dfc9fed7c2a219c04c31921c7b3436d8d7d975a1e"
    else
      url "https://qoder-ide.oss-accelerate.aliyuncs.com/qodercli/releases/1.0.2/qodercli-darwin-x64.tar.gz"
      sha256 "510f2b4c94c84117003296d9debb3d18bbe1ab43d292c5ce7af393d37ddee746"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://qoder-ide.oss-accelerate.aliyuncs.com/qodercli/releases/1.0.2/qodercli-linux-arm64.tar.gz"
      sha256 "dfa5b1551c3166985f7fc8e1af450ded5b24c895f624e00b9309ada6ef4ec277"
    else
      url "https://qoder-ide.oss-accelerate.aliyuncs.com/qodercli/releases/1.0.2/qodercli-linux-x64.tar.gz"
      sha256 "5ab5024e1f5ccf8d418a118c4050aaf1b0261fe5e67b47df3d29253db54f2700"
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
