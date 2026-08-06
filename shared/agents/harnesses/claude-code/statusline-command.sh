input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
model=$(echo "$input" | jq -r '.model.display_name // ""')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Shorten home directory to ~
home="$HOME"
short_cwd="${cwd/#"$home"/\~}"

# Git branch (skip optional locks); these lookups legitimately fail outside
# git repos, so guard them against errexit
git_branch=""
if [ -d "$cwd" ]; then
  git_branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null) || true
  if [ -z "$git_branch" ]; then
    git_branch=$(git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null) || true
  fi
fi

# Build context string
user_host="$(whoami)@$(hostname -s)"

# Context percentage
ctx_part=""
if [ -n "$used" ]; then
  ctx_part=" ctx:$(printf '%.0f' "$used")%"
fi

# Assemble output with ANSI colors
# Blue for dir, cyan for git, dim white for user@host, yellow for model
if [ -n "$git_branch" ]; then
  printf "\033[34m%s\033[0m \033[36m%s\033[0m \033[2m%s\033[0m \033[33m%s\033[0m%s" \
    "$short_cwd" "($git_branch)" "$user_host" "$model" "$ctx_part"
else
  printf "\033[34m%s\033[0m \033[2m%s\033[0m \033[33m%s\033[0m%s" \
    "$short_cwd" "$user_host" "$model" "$ctx_part"
fi
