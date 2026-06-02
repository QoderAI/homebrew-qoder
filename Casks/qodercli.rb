cask "qodercli" do
  version "1.0.12"
  desc "Qoder AI CLI tool - Terminal-based AI assistant for code development"
  homepage "https://qoder.com"

  on_macos do
    if Hardware::CPU.arm?
      url "https://download.qoder.com/qodercli/releases/1.0.12/qodercli-darwin-arm64.tar.gz"
      sha256 "c343a7ac3fce504f77afc6f6a6540b6eba387bf39e502ac551a9a586ec1c44c9"
    else
      url "https://download.qoder.com/qodercli/releases/1.0.12/qodercli-darwin-x64.tar.gz"
      sha256 "1d5a96168e9b0f99010e8fc30b2267fed3ae4a101fbbf4e66a87c16c5bed9ace"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://download.qoder.com/qodercli/releases/1.0.12/qodercli-linux-arm64.tar.gz"
      sha256 "3e82b5791beea7a153e2a03d639fafe2ee6120e11b3ceb3b4eb2d167c8883f90"
    else
      url "https://download.qoder.com/qodercli/releases/1.0.12/qodercli-linux-x64.tar.gz"
      sha256 "845d08ec9c3c7e6f9de78b0a6c8342d58c3c0231a4c1b09ce4d40bfd41041fb9"
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