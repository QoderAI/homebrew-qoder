cask "qodercli" do
  version "1.0.35"
  desc "Qoder AI CLI tool - Terminal-based AI assistant for code development"
  homepage "https://qoder.com"

  on_macos do
    if Hardware::CPU.arm?
      url "https://download.qoder.com/qodercli/releases/1.0.35/qodercli-darwin-arm64.tar.gz"
      sha256 "0e9d518a3b66cc6d96007dab0ae5eef52961798b6bf7afa144c23f11105d498a"
    else
      url "https://download.qoder.com/qodercli/releases/1.0.35/qodercli-darwin-x64.tar.gz"
      sha256 "3dc11203c3113e1a7849407efde40d49c050faae76e45c6cc5b7202433afe96e"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://download.qoder.com/qodercli/releases/1.0.35/qodercli-linux-arm64.tar.gz"
      sha256 "aa3d4daf2a19d359885b5763150475c4bfac9e9cb60b7a29eb7d3f270dc32262"
    else
      url "https://download.qoder.com/qodercli/releases/1.0.35/qodercli-linux-x64.tar.gz"
      sha256 "fbf55f27d2ac631227c20a9096a51d235f1c04b0b8e5e825293954690749e93f"
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