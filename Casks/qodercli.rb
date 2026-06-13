cask "qodercli" do
  version "1.0.20"
  desc "Qoder AI CLI tool - Terminal-based AI assistant for code development"
  homepage "https://qoder.com"

  on_macos do
    if Hardware::CPU.arm?
      url "https://download.qoder.com/qodercli/releases/1.0.20/qodercli-darwin-arm64.tar.gz"
      sha256 "0bf5ae964cab73e8c435d80675bf63e2245ca6b65cc762e0733759efff30fcdf"
    else
      url "https://download.qoder.com/qodercli/releases/1.0.20/qodercli-darwin-x64.tar.gz"
      sha256 "e6d398c7954313e52c992ca37d2ab7f312c10e0c60e8dabc74c9e7dbcfbdd216"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://download.qoder.com/qodercli/releases/1.0.20/qodercli-linux-arm64.tar.gz"
      sha256 "c30386abec3a0100cbe8a1534c2f5f99912f49a972ef546d087e2c5ab6b6cd7a"
    else
      url "https://download.qoder.com/qodercli/releases/1.0.20/qodercli-linux-x64.tar.gz"
      sha256 "0866a1a87af6ed3997ebaad8b6c29130677f61a201cabdd90be5856280195972"
    end
  end

  binary "qodercli"

  postflight do
    require 'fileutils'
    require 'time'

    marker = staged_path/'.qodercli-install-resource'
    File.write(marker, "homebrew-cask")
    marker.chmod(0644)

    (staged_path/"qodercli").chmod(0755)

    bin_binary = HOMEBREW_PREFIX/"bin"/"qodercli"
    ENV['QODER_CLI_INSTALL'] = '1'

    begin
      log_dir = File.expand_path("~/.qoder/logs")
      FileUtils.mkdir_p(log_dir)

      timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
      log_file = File.join(log_dir, "qodercli_install_homebrew_#{timestamp}.log")

      log = File.open(log_file, 'w')
      log.puts "Installation started at #{Time.now.iso8601}"
      log.puts "Installation method: homebrew-cask"
      log.puts "Platform: #{RUBY_PLATFORM}"
      log.puts "Homebrew prefix: #{HOMEBREW_PREFIX}"
      log.puts "================================\n"
      log.flush

      latest_log = File.join(log_dir, "qodercli_install.log")
      File.unlink(latest_log) if File.exist?(latest_log) || File.symlink?(latest_log)
      File.symlink(log_file, latest_log)

      version_output = `#{bin_binary} --version 2>&1`.strip

      if $?.success?
        log.puts "Installation verified successfully"
        log.puts "Version: #{version_output}"
        puts "\nQoder CLI #{version_output} installed successfully!"
      else
        log.puts "[ERROR] Version check failed: #{version_output}"
        puts "\nInstallation completed but version check failed"
      end

      log.puts "\nInstallation completed at #{Time.now.iso8601}"
      log.close

      puts "Get started: qodercli --help"
      puts "Installation log: #{log_file}\n"

    rescue => e
      puts "\nQoder CLI installed successfully!"
      puts "Get started: qodercli --help"
      puts "(Note: Installation log could not be created: #{e.message})\n"
    end
  end
end