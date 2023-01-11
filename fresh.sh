#!/bin/sh

# Color key
green=$'\e[1;32m'
yellow=$'\e[1;33m'
cyan=$'\e[1;36m'
end=$'\e[0m'

# Prep directories.
dotfiles="$HOME/.dotfiles"
repo_dir="$HOME/test"

printf "%s\n***** Loading josuapsianturi/dotfiles *****\n%s" $yellow $end


#-----------------------------------------------------------------------------
# Codespace directories                                                      -
#-----------------------------------------------------------------------------

printf "%s\n# Creating codespace directories...\n%s" $yellow $end

# Creating Github directory.
printf "%s- Creating $repo_dir...%s"
if [[ ! -e "$repo_dir" ]]; then
  mkdir -p $repo_dir
  printf "%s Success!\n%s" $green $end
else
  printf "%s already created\n%s" $cyan $end
fi

#-----------------------------------------------------------------------------
# Apps, packages, and dependencies                                           -
#-----------------------------------------------------------------------------

printf "%s\n# Installing apps and dependencies...\n%s" $yellow $end

# Check for Oh My Zsh and install if we don't have it
printf "%s- Installing Oh My Zsh...\n%s"
if test ! $(which omz); then
  /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/HEAD/tools/install.sh)"
fi

# Install Hombrew and additional dependencies with bundle (See Brewfile)
printf "%s- Installing Homebrew...\n%s"
if test ! $(which brew); then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> $HOME/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

printf "%s- Updating Homebrew recipes... \n%s"
brew update
printf "%s- Loading Brewfile... \n%s"
brew tap homebrew/bundle
# brew bundle

# Install global Composer packages.
packages=( laravel/installer laravel/valet )
for package in "${packages[@]}"
do
  printf "%s- Installing $package...%s"
  if [[ ! -e "$HOME/.composer/vendor/$package" ]]; then
    /usr/local/bin/composer global require $package
  else
    printf "%s already installed\n%s" $cyan $end
  fi
done


#-----------------------------------------------------------------------------
# Repositories                                                               -
#-----------------------------------------------------------------------------

printf "%s\n# Cloning repositories...\n%s" $yellow $end

cd $repo_dir
github_repos=( velflix velzon tac )
for repo in "${github_repos[@]}"
do
  printf "%s- josuapsianturi/$repo %s"
  if [[ ! -e "$repo_dir/$repo" ]]; then
    git clone git@github.com:josuapsianturi/$repo.git $repo_dir/$repo/
  else
    printf "%s already cloned\n%s" $cyan $end
  fi
done


#-----------------------------------------------------------------------------
# Symbolic Links                                                             -
#-----------------------------------------------------------------------------

printf "%s\n# Creating symbolic links...\n%s" $yellow $end

# Global gitignore.
printf "%s- Symlink .gitignore_global file...%s" $yellow $end
ln -s $HOME/.dotfiles/.gitignore_global $HOME/.gitignore_global
git config --global core.excludesfile $HOME/.gitignore_global
printf "%s Done!\n%s" $green $end

# .zshrc.
printf "%s- Symlink .zshrc file...%s" $yellow $end
rm -rf $HOME/.zshrc
ln -s $HOME/.dotfiles/.zshrc $HOME/.zshrc
printf "%s Done!\n%s" $green $end

# Mackup config.
printf "%s- Symlink .mackup.cfg file...%s" $yellow $end
ln -s $HOME/.dotfiles/.mackup.cfg $HOME/.mackup.cfg
printf "%s Done!\n%s" $green $end


#-----------------------------------------------------------------------------
# macOS Preferences                                                          -
#-----------------------------------------------------------------------------

# printf "%s\n# Adjusting macOS...\n%s" $yellow $end
# cd $dotfiles
# source .macos
# printf "%sDone. Note that some of these changes require a logout/restart to take effect.\n%s" $green $end

#-----------------------------------------------------------------------------
# All Done!                                                          -
#-----------------------------------------------------------------------------
printf "%s\n***** ALL DONE *****\n%s" $green $end
