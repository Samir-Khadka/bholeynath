cask "bholeynath" do
  version "0.5.8"
  sha256 "b6732b578f6f51cfc053bcc9e6f3468315d67dfc38d90a2c7c1ebd94c09f83d5"

  url "https://github.com/Samir-Khadka/bholeynath/releases/download/v#{version}/Bholeynath.zip"
  name "Bholeynath"
  desc "Notch companion that keeps an eye on your AI coding agents"
  homepage "https://github.com/Samir-Khadka/bholeynath"

  # Only the Mac's tags (vX.Y.Z): windows-v…, linux-v… and android-v… are other apps.
  livecheck do
    url :url
    regex(/^v?(\d+(?:\.\d+)+)$/i)
    strategy :github_releases
  end

  # Bholeynath updates itself from the notch: brew leaves the installed app alone.
  auto_updates true
  depends_on macos: :sequoia

  app "Bholeynath.app"

  uninstall quit: "com.samirkhadka.bholeynath"

  zap trash: [
    "~/Library/Application Support/Bholeynath",
    "~/Library/Application Support/NotchBuddy",
    "~/Library/Preferences/com.samirkhadka.bholeynath",
  ]
end
