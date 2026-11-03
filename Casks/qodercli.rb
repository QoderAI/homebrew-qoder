cask "qodercli" do
  version "1.1.82"
  desc "Qoder AI CLI tool - Terminal-based AI assistant for code development"
  homepage "https://qoder.com"

  on_macos do
    if Hardware::CPU.arm?
      url "https://download.qoder.com/qodercli/releases/1.1.82/qodercli-darwin-arm64.tar.gz"
      sha256 "c934e8a8888aef7be2781e3d491ef72475690af151f0daa6e4ccbc2750dd460b"
    else
      url "https://download.qoder.com/qodercli/releases/1.1.82/qodercli-darwin-x64.tar.gz"
      sha256 "ad98bebb07ca5d65595987017a5be3cecad008dbf769b2f0e7ebd2a497dfba8f"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://download.qoder.com/qodercli/releases/1.1.82/qodercli-linux-arm64.tar.gz"
      sha256 "2df53688489079b9c9e64362efa223fd1f11386dd72294f08a65c9400b736ab8"
    else
      url "https://download.qoder.com/qodercli/releases/1.1.82/qodercli-linux-x64.tar.gz"
      sha256 "e90dfa874a14100b83954ba16b3946d281adbb7104ad5df9d81a78eacf9c2eba"
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