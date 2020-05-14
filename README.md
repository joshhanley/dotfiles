# Josh's Dotfiles

## A Fresh macOS Setup

### Before you re-install

First, go through the checklist below to make sure you didn't forget anything before you wipe your hard drive.

- Did you backup to Time Machine?
- Did you commit and push any changes/branches to your git repositories?
- Did you remember to save all important documents from non-iCloud directories?
- Did you save all of your work from apps which aren't synced through iCloud?
- Did you remember to export important data from your local database?
- Did you update [mackup](https://github.com/lra/mackup) to the latest version and ran `mackup backup`?

### Installing macOS cleanly

After going to our checklist above and making sure you backed everything up, we're going to cleanly install macOS with the latest release. Follow [this article](https://www.imore.com/how-do-clean-install-macos) to cleanly install the latest macOS version.

### Setting up your Mac

If you did all of the above you may now follow these install instructions to setup a new Mac.

1. Update macOS to the latest version with the App Store
2. Sync iCloud
3. Enable iCloud messages
4. Install Xcode from the App Store, open it and accept the license agreement
5. Install macOS Command Line Tools by running `xcode-select --install`
6. Copy your public and private SSH keys to `~/.ssh` and make sure they're set to `600`
7. Clone this repo to `~/.dotfiles`
8. Install [Oh My Zsh](https://github.com/robbyrussell/oh-my-zsh#getting-started)
9. Run `install.sh` to start the installation
10. After mackup is synced with your cloud storage, restore preferences by running `mackup restore`
11. Restart your computer to finalize the process
12. Manual install the following
	- airbuddy
13. Manual copy:
	- Sites directory
	- Development directory
14. Remap spotlight to Option+Space
15. Open the following and setup:
	- Spark
	- Backup and Sync
	- Alfred and relink preferences
	- Dato
	- Sourcetree link to system git
	- VSCode and install "Settings Sync"
	
Your Mac is now ready to use!
