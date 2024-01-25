#!/bin/sh

wg() {
  echo "defaults write -g" "$@"
  defaults write -g "$@"
}

w() {
  echo "defaults write" "$@"
  defaults write "$@"
}

# appearance
wg AppleReduceDesktopTinting -bool true
wg AppleInterfaceStyleSwitchesAutomatically -bool true

# keyboard
wg ApplePressAndHoldEnabled -bool false
wg InitialKeyRepeat -int 15
wg KeyRepeat -int 2
wg NSAutomaticCapitalizationEnabled -bool false
wg NSAutomaticDashSubstitutionEnabled -bool false
wg NSAutomaticInlinePredictionEnabled -bool false
wg NSAutomaticPeriodSubstitutionEnabled -bool false
wg NSAutomaticQuoteSubstitutionEnabled -bool false
wg NSAutomaticSpellingCorrectionEnabled -bool false
wg WebAutomaticSpellingCorrectionEnabled -bool false

# finder
wg AppleShowAllExtensions -bool true
w com.apple.finder _FXSortFoldersFirst -bool true
w com.apple.finder NewWindowTarget -string "PfHm" # home folder
w com.apple.finder FXEnableExtensionChangeWarning -bool false

# dock
w com.apple.dock show-recents -bool false
w com.apple.dock showLaunchpadGestureEnabled -bool false
w com.apple.dock showAppExposeGestureEnabled -bool true
w com.apple.dock tilesize -int 48
w com.apple.dock autohide -bool true
w com.apple.dock autohide-delay -float 0
w com.apple.dock autohide-time-modifier -float 0.25
w com.apple.dock expose-group-apps -bool true
w com.apple.dock mru-spaces -bool false
w com.apple.dock size-immutable -bool true

# xcode
w com.apple.dt.Xcode DVTEnableDockIconVersionNumber -bool true
w com.apple.dt.Xcode XcodeCloudUpsellPromptEnabled -bool false

# screencapture
w com.apple.screencapture disable-shadow -bool false
w com.apple.screencapture target -string "clipboard"

# mail
w com.apple.mail BottomPreview -bool false
w com.apple.mail ColumnLayoutMessageList -bool true
