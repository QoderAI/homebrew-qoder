cask "qodercli" do
  version "1.1.65"
  desc "Qoder AI CLI tool - Terminal-based AI assistant for code development"
  homepage "https://qoder.com"

  on_macos do
    if Hardware::CPU.arm?
      url "https://download.qoder.com/qodercli/releases/1.1.65/qodercli-darwin-arm64.tar.gz"
      sha256 "8cd72311b0fea4978b3acf06b6431037280b717e175dc0a6231bd2cf06d397ee"
    else
      url "https://download.qoder.com/qodercli/releases/1.1.65/qodercli-darwin-x64.tar.gz"
      sha256 "3dd358318ea99f54da7f7de8cd8b7b3e8356042a679573ea126189ab55535f37"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://download.qoder.com/qodercli/releases/1.1.65/qodercli-linux-arm64.tar.gz"
      sha256 "d00b39e1fb2fe222b156853b70e0355c28fd5e13ef51e3159cea8cf62f93f349"
    else
      url "https://download.qoder.com/qodercli/releases/1.1.65/qodercli-linux-x64.tar.gz"
      sha256 "b49ebbb9c812757850047a2084f29853f6c2e242c90baf8d0c03396b1a21fc8c"
    end
  end

  generated_script "qodercli-postflight.rb", content: <<~'RUBY'
    #!/usr/bin/env ruby
    require 'fileutils'
    require 'time'

    prefix = ENV.fetch('QODER_HOMEBREW_PREFIX')
    bin_binary = File.join(prefix, 'bin', 'qodercli')

    begin
      log_dir = File.expand_path("~/.qoder/logs")
      FileUtils.mkdir_p(log_dir)

      timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
      log_file = File.join(log_dir, "qodercli_install_homebrew_#{timestamp}.log")

      log = File.open(log_file, 'w')
      log.puts "Installation started at #{Time.now.iso8601}"
      log.puts "Installation method: homebrew-cask"
      log.puts "Platform: #{RUBY_PLATFORM}"
      log.puts "Homebrew prefix: #{prefix}"
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
  RUBY
  binary "qodercli"

  postflight_steps do
    write_file ".qodercli-install-resource", "homebrew-cask"
    set_permissions ".qodercli-install-resource", "0644"
    set_permissions "qodercli", "0755"
    run "qodercli-postflight.rb", base: :staged_path,
                                env: { "QODER_CLI_INSTALL" => "1", "QODER_HOMEBREW_PREFIX" => "{{HOMEBREW_PREFIX}}" },
                                print_stdout: true, writable_paths: ["."], writable_base: :home
  end
end
