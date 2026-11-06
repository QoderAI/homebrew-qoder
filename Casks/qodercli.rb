cask "qodercli" do
  version "1.1.84"
  desc "Qoder AI CLI tool - Terminal-based AI assistant for code development"
  homepage "https://qoder.com"

  on_macos do
    if Hardware::CPU.arm?
      url "https://download.qoder.com/qodercli/releases/1.1.84/qodercli-darwin-arm64.tar.gz"
      sha256 "911fa96be6137050a8cc59a7773979e5303897b65d875f2707d9df80553996b4"
    else
      url "https://download.qoder.com/qodercli/releases/1.1.84/qodercli-darwin-x64.tar.gz"
      sha256 "6fb42b6c9dc7665938c5c419dbe747781b2f61037b9b77da168f41d9db2d5e22"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://download.qoder.com/qodercli/releases/1.1.84/qodercli-linux-arm64.tar.gz"
      sha256 "f44184d43e8792e923141ffebcc797e6cb32dc03e9b6a1c30621c8a0a94abd93"
    else
      url "https://download.qoder.com/qodercli/releases/1.1.84/qodercli-linux-x64.tar.gz"
      sha256 "a7e3dc3b74e61b9a9655a1a6a214ff70b7ffd1cac376cc8c5fb823814b53b273"
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

      # Configure dispatcher + PATH so the multi-channel `qoder` resolver
      # is in place after `brew install --cask`. Best-effort — the
      # subcommand always returns exit 0 by design, but rescue defensively
      # in case the binary itself fails to launch. 30s timeout matches the
      # parallel npm postinstall path so brew install doesn't hang on a
      # stuck child.
      begin
        require 'timeout'
        Timeout.timeout(30) do
          configure_log = `#{bin_binary} configure-path 2>&1`
          log.puts "configure-path output:"
          log.puts configure_log
        end
      rescue Timeout::Error
        log.puts "[WARN] configure-path timed out after 30s"
      rescue => e
        log.puts "[WARN] configure-path failed: #{e.message}"
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