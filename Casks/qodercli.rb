cask "qodercli" do
  version "1.1.100"
  desc "Qoder AI CLI tool - Terminal-based AI assistant for code development"
  homepage "https://qoder.com"

  on_macos do
    if Hardware::CPU.arm?
      url "https://download.qoder.com/qodercli/releases/1.1.100/qodercli-darwin-arm64.tar.gz"
      sha256 "54ce3b896ec300d745094cce081bbd482ae38f5d2c32aabfec05f5c7ad61bd83"
    else
      url "https://download.qoder.com/qodercli/releases/1.1.100/qodercli-darwin-x64.tar.gz"
      sha256 "12ae6db8023f6710582a59e133769433b75c4f09d917c913873f7dc67c470ce3"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://download.qoder.com/qodercli/releases/1.1.100/qodercli-linux-arm64.tar.gz"
      sha256 "544cf0fd211826fb4ae93fcb0ea1c5669af3595f37c4954c578c70ee71e0fee6"
    else
      url "https://download.qoder.com/qodercli/releases/1.1.100/qodercli-linux-x64.tar.gz"
      sha256 "05969837c7940ff5a71936b2181d102ee690523ef9c71635ad4e8d0c62678f16"
    end
  end

  binary "qodercli"

  postflight_steps do
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
