cask "qodercli" do
  version "1.0.29"
  desc "Qoder AI CLI tool - Terminal-based AI assistant for code development"
  homepage "https://qoder.com"

  on_macos do
    if Hardware::CPU.arm?
      url "https://download.qoder.com/qodercli/releases/1.0.29/qodercli-darwin-arm64.tar.gz"
      sha256 "7594de3051ad79971bd8a84c6033483fc58924389833abfb9379dafa845c1629"
    else
      url "https://download.qoder.com/qodercli/releases/1.0.29/qodercli-darwin-x64.tar.gz"
      sha256 "282f017afd87bf103f072bfa8c8f75000b705437662ffb56257af1d361cea6fb"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://download.qoder.com/qodercli/releases/1.0.29/qodercli-linux-arm64.tar.gz"
      sha256 "fa8755001d84bf75f1a1c26471a0eacbbb2d25d2b40d0934de9729cf9a8b2ec5"
    else
      url "https://download.qoder.com/qodercli/releases/1.0.29/qodercli-linux-x64.tar.gz"
      sha256 "78d11d198b401940bffcaf816b8ca5cf9d40750a4813a0362bbef56d759359ec"
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