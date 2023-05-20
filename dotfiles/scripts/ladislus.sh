# NOTE: All these scripts assume that the current shell is ZSH as they rely on some of it's unique features

# Check if we're currently running Zsh, or skip sourcing
if [[ -z "$ZSH_VERSION" ]]; then
    echo "\$ZSH_VERSION isn't set, shell must not be ZSH, skipping sourcing of Zsh functions" 1>&2
    return 1
fi

# Enable extended wildcards in case it isn't already
setopt EXTENDED_GLOB

# Source all sh files inside the current directory (except ourself)
for _X in $(dirname $0)/*.sh~$(dirname $0)/ladislus.sh(N); do
    echo "Sourcing: $_X"
    source "$_X"
done