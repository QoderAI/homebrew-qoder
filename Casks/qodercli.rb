cask "qodercli" do
  version "0.2.1"
  desc "Qoder AI CLI tool - Terminal-based AI assistant for code development"
  homepage "https://qoder.com"

  on_macos do
    if Hardware::CPU.arm?
      url "https://download.qoder.com/qodercli/releases/0.2.1/qodercli-darwin-arm64.tar.gz"
      sha256 "fe6ed1782d9cc7d73c9fab996dd603081c9d4949dbdff200c1a4423cc0fdefb2"
    else
      url "https://download.qoder.com/qodercli/releases/0.2.1/qodercli-darwin-x64.tar.gz"
      sha256 "b3cfeb89744aeaa7a02fef3395ec1575652d6aed7ff8c81e472ba619be324aa5"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://download.qoder.com/qodercli/releases/0.2.1/qodercli-linux-arm64.tar.gz"
      sha256 "5b3497a7f7217133b350f9275ceb5b0c5e56c5bb7ddc6e2a5c84cc8a62c83504"
    else
      url "https://download.qoder.com/qodercli/releases/0.2.1/qodercli-linux-x64.tar.gz"
      sha256 "93512bd6f02bc86ccc6b8a8753cf03f9620b019563da803ce40c5afb8080101d"
    end
  end

  binary "qodercli"

  # Create installation source marker after installation for update detection
  postflight do
    require 'fileutils'
    require 'time'

    # Core installation steps (must succeed)
    marker = staged_path/'.qodercli-install-resource'
    File.write(marker, "homebrew-cask")
    marker.chmod(0644)

    (staged_path/"qodercli").chmod(0755)

    bin_binary = HOMEBREW_PREFIX/"bin"/"qodercli"
    ENV['QODER_CLI_INSTALL'] = '1'

    # Logging and verification (failures here won't block installation)
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
