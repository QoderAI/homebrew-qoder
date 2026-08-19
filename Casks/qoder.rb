cask "qoder" do
  arch arm: "arm64", intel: "x64"

  version "1.6.0"
  sha256 arm:   "0592b6634aeb1c726b8f522682bf31f48ca38be3aedc6ed14a0c85c472d9e015",
         intel: "c613bf6614f3c378d2030ba3b617ca4505f9dd4b4eb1731c78bbc4119cac0f1d"

  url "https://download.qoder.com/release/latest/Qoder-darwin-#{arch}.dmg"
  name "Qoder"
  desc "Qoder - Agentic Coding Platform for Real Software"
  homepage "https://qoder.com"

  auto_updates true
  depends_on macos: :monterey

  app "Qoder.app"
  binary "#{appdir}/Qoder.app/Contents/Resources/app/bin/code", target: "qoder"

  zap trash: [
    "~/Library/Application Support/Caches/Qoder",
    "~/Library/Application Support/Qoder",
    "~/Library/Logs/Qoder",
    "~/Library/Preferences/com.qoder.ide.plist",
    "~/Library/Preferences/Qoder.plist",
    "~/Library/Application Support/com.apple.sharedfilelist/com.apple.LSSharedFileList.ApplicationRecentDocuments/com.qoder.ide.sfl3",
    "~/Library/Application Support/CrashReporter/Electron_BEBB1342-528D-57F1-B45E-6D267BE92CBC.plist",
  ]
end
