#!/bin/sh

wg() {
  echo "defaults write -g" "$@"
  defaults write -g "$@"
}

w() {
  echo "defaults write" "$@"
  defaults write "$@"
}

# appkit debug
wg _NS_4445425547 -bool true
# really doesn't like it (unity stuff too, i think)
w com.ableton.live _NS_4445425547 -bool false

# trackpad
wg com.apple.trackpad.scaling -float 0.6875 # (default)

# appearance
wg AppleReduceDesktopTinting -bool true
wg AppleInterfaceStyleSwitchesAutomatically -bool true
wg AppleScrollerPagingBehavior -bool true

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
w com.apple.finder ShowHardDrivesOnDesktop -bool false
w com.apple.finder ShowExternalHardDrivesOnDesktop -bool false
w com.apple.finder ShowMountedServersOnDesktop -bool true
w com.apple.finder ShowRemovableMediaOnDesktop -bool false
w com.apple.finder ShowRecentTags -bool false

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
w com.apple.dock wvous-br-corner -int 1
w com.apple.dock appswitcher-all-displays -bool true

# xcode
w com.apple.dt.Xcode DVTEnableDockIconVersionNumber -bool true
w com.apple.dt.Xcode XcodeCloudUpsellPromptEnabled -bool false
w com.apple.dt.Xcode XcodeCloudUserHasDismissedGetStartedPrompt -bool true
w com.apple.dt.Xcode XcodeCloudUserHasDismissedSignInPrompt -bool true

# screencapture
w com.apple.screencapture disable-shadow -bool true
w com.apple.screencapture target -string "clipboard"

# mail
w com.apple.mail BottomPreview -bool false
w com.apple.mail ColumnLayoutMessageList -bool true

# crash reporter
w com.apple.CrashReporter DialogType -string developer
w com.apple.CrashReporter UseUNC -bool true
w com.apple.CrashReporter UseRegularActivationPolicy -bool true

# preview
w com.apple.preview PVImageSizeSizeUnit -int 0

# zoom
w com.apple.universalaccess closeViewSmoothImages -bool false
w com.apple.universalaccess closeViewScrollWheelToggle -bool true
w com.apple.universalaccess closeViewScrollWheelModifiersInt -int 262144

# keychain access
w com.apple.keychainaccess "User Has Acknowledged Passwords Settings Dialog" -bool true
