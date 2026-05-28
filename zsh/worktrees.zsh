# Work Tree Package - Create a git worktree for package development
wtp() {
    # Work Tree Package - Create a git worktree for package development
    # with automatic setup and Claude Code in a new tmux pane

    if [ -z "$1" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        echo "wtp - Work Tree Package"
        echo ""
        echo "Create a git worktree for package development with automatic setup."
        echo ""
        echo "Usage: wtp <branch-name> [base-branch]"
        echo ""
        echo "Arguments:"
        echo "  branch-name   Name of the new branch to create"
        echo "  base-branch   Branch to base off of (default: main)"
        echo ""
        echo "This command will:"
        echo "  1. Create a new git worktree at ../<project>--<branch>"
        echo "  2. Create a git branch prefixed with josh/ (e.g., josh/<branch>)"
        echo "  3. Open a new tmux pane (side by side) titled after the branch"
        echo "  4. Run composer install (if composer.json exists)"
        echo "  5. Run npm install (if package.json exists)"
        echo "  6. Run npm run build (if package.json exists)"
        echo "  7. Install Chrome driver for Dusk tests (if dusk-updater exists)"
        echo "  8. Start Claude Code"
        echo ""
        echo "Examples:"
        echo "  wtp feature-auth         # Branch from main"
        echo "  wtp bugfix-login develop # Branch from develop"
        return 0
    fi

    BRANCH_NAME="$1"
    GIT_BRANCH="josh/${BRANCH_NAME}"
    BASE_BRANCH="${2:-main}"
    PROJECT_NAME=$(basename "$(pwd)")
    WORKTREE_NAME="${PROJECT_NAME}--${BRANCH_NAME}"
    PARENT_DIR=$(dirname "$(pwd)")
    WORKTREE_PATH="${PARENT_DIR}/${WORKTREE_NAME}"

    # Write setup script to temp file
    local SETUP_SCRIPT=$(mktemp)
    cat > "$SETUP_SCRIPT" << SETUP_EOF
#!/bin/bash
tmux select-pane -T '${BRANCH_NAME}'
tmux set-option -p @branch '${BRANCH_NAME}'
echo 'Creating worktree: ${WORKTREE_NAME}'
if git show-ref --verify --quiet refs/heads/'${GIT_BRANCH}'; then
    git worktree add '${WORKTREE_PATH}' '${GIT_BRANCH}'
else
    git worktree add '${WORKTREE_PATH}' -b '${GIT_BRANCH}' '${BASE_BRANCH}'
fi
cd '${WORKTREE_PATH}'
# tmux split-window -h -d -c '${WORKTREE_PATH}'
[ -f composer.json ] && composer install
[ -f package.json ] && npm install
[ -f package.json ] && npm run build 2>/dev/null
[ -f vendor/bin/dusk-updater ] && vendor/bin/dusk-updater detect --auto-update
echo 'Setup complete. Starting Claude...'
rm '$SETUP_SCRIPT'
claude
exec zsh
SETUP_EOF
    chmod +x "$SETUP_SCRIPT"

    # Create tmux pane running the setup script (side by side)
    tmux split-window -h "$SETUP_SCRIPT"
    # tmux new-window -n "${BRANCH_NAME}" "$SETUP_SCRIPT"
}

# Remove a git worktree created by wtp
wtprm() {
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        echo "wtprm - Remove a git worktree"
        echo ""
        echo "Remove a git worktree and close its tmux pane."
        echo ""
        echo "Usage: wtprm [-f] [branch-name]"
        echo ""
        echo "Arguments:"
        echo "  -f, --force   Force remove even with uncommitted changes"
        echo "  branch-name   Name of the branch (without josh/ prefix)"
        echo "                Optional if run from within a worktree folder"
        echo ""
        echo "This command will:"
        echo "  1. Remove the git worktree at ../<project>--<branch>"
        echo "  2. Close the tmux pane (if it exists)"
        echo ""
        echo "Examples:"
        echo "  wtprm feature-auth     # From root package folder"
        echo "  wtprm                  # From within the worktree folder"
        echo "  wtprm -f feature-auth  # Force remove"
        return 0
    fi

    # Check for force flag
    FORCE=""
    if [ "$1" = "-f" ] || [ "$1" = "--force" ]; then
        FORCE="--force"
        shift
    fi

    CURRENT_DIR=$(basename "$(pwd)")

    # Check if we're in a worktree folder (contains --)
    if [ -z "$1" ] && [[ "${CURRENT_DIR}" == *"--"* ]]; then
        # Extract branch name and project name from folder
        BRANCH_NAME="${CURRENT_DIR##*--}"
        PROJECT_NAME="${CURRENT_DIR%%--*}"
        WORKTREE_PATH="$(pwd)"
        PARENT_DIR=$(dirname "$(pwd)")

        echo "Removing worktree: ${CURRENT_DIR}"

        # cd out of worktree before removing
        cd "${PARENT_DIR}/${PROJECT_NAME}"

        if git worktree remove ${FORCE} "${WORKTREE_PATH}"; then
            # Kill the tmux pane with matching @branch option
            local PANE_ID=$(tmux list-panes -a -F '#{pane_id} #{@branch}' 2>/dev/null | grep -F " ${BRANCH_NAME}" | awk '{print $1}')
            [ -n "$PANE_ID" ] && tmux kill-pane -t "$PANE_ID" 2>/dev/null
            # tmux kill-window -t "${BRANCH_NAME}" 2>/dev/null
            echo "Worktree removed successfully"
        else
            echo "Failed to remove worktree. Use -f to force remove."
            # cd back to worktree so user can retry with -f
            cd "${WORKTREE_PATH}"
            return 1
        fi

        return 0
    fi

    # Original behavior - must be in root package with branch name
    if [ -z "$1" ]; then
        echo "Error: Branch name is required (or run from within a worktree folder)"
        echo "Usage: wtprm [-f] <branch-name>"
        return 1
    fi

    BRANCH_NAME="$1"
    PROJECT_NAME=$(basename "$(pwd)")
    WORKTREE_NAME="${PROJECT_NAME}--${BRANCH_NAME}"
    PARENT_DIR=$(dirname "$(pwd)")
    WORKTREE_PATH="${PARENT_DIR}/${WORKTREE_NAME}"

    echo "Removing worktree: ${WORKTREE_NAME}"

    if git worktree remove ${FORCE} "${WORKTREE_PATH}"; then
        # Kill the tmux pane with matching @branch option
        local PANE_ID=$(tmux list-panes -a -F '#{pane_id} #{@branch}' 2>/dev/null | grep -F " ${BRANCH_NAME}" | awk '{print $1}')
        [ -n "$PANE_ID" ] && tmux kill-pane -t "$PANE_ID" 2>/dev/null
        # tmux kill-window -t "${BRANCH_NAME}" 2>/dev/null
        echo "Worktree removed successfully"
    else
        echo "Failed to remove worktree. Use -f to force remove."
        return 1
    fi
}

# List git worktrees for the current project
wtpls() {
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        echo "wtpls - List git worktrees"
        echo ""
        echo "Usage: wtpls"
        return 0
    fi

    git worktree list
}

# Work Tree Application - Create a git worktree for Laravel app development
wta() {
    if [ -z "$1" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        echo "wta - Work Tree Application"
        echo ""
        echo "Create a git worktree for Laravel application development with automatic setup."
        echo ""
        echo "Usage: wta <branch-name> [base-branch]"
        echo ""
        echo "Arguments:"
        echo "  branch-name   Name of the new branch to create"
        echo "  base-branch   Branch to base off of (default: main)"
        echo ""
        echo "This command will:"
        echo "  1. Create a new git worktree at ../<project>--<branch>"
        echo "  2. Create a git branch prefixed with josh/ (e.g., josh/<branch>)"
        echo "  3. Open a new tmux window named after the branch"
        echo "  4. Copy .env from main project"
        echo "  5. Update APP_URL for Laravel Herd"
        echo "  6. Create a dedicated MySQL database"
        echo "  7. Update DB_DATABASE in .env"
        echo "  8. Run composer install"
        echo "  9. Run php artisan migrate --seed"
        echo "  10. Run npm install"
        echo "  11. Run npm run build"
        echo "  12. Start Claude Code"
        echo ""
        echo "Examples:"
        echo "  wta feature-auth       # Branch from main"
        echo "  wta bugfix-login dev   # Branch from dev"
        return 0
    fi

    BRANCH_NAME="$1"
    GIT_BRANCH="josh/${BRANCH_NAME}"
    BASE_BRANCH="${2:-main}"
    PROJECT_NAME=$(basename "$(pwd)")
    WORKTREE_NAME="${PROJECT_NAME}--${BRANCH_NAME}"
    PARENT_DIR=$(dirname "$(pwd)")
    WORKTREE_PATH="${PARENT_DIR}/${WORKTREE_NAME}"
    MAIN_PROJECT_PATH="$(pwd)"

    # Database name: lowercase project + branch, dashes to underscores
    DB_NAME=$(echo "${PROJECT_NAME}_${BRANCH_NAME}" | tr '[:upper:]' '[:lower:]' | tr '-' '_')

    # App URL for Herd: lowercase worktree folder name
    APP_URL="http://$(echo "${WORKTREE_NAME}" | tr '[:upper:]' '[:lower:]').test"

    # Write setup script to temp file
    local SETUP_SCRIPT=$(mktemp)
    cat > "$SETUP_SCRIPT" << SETUP_EOF
#!/bin/bash
echo 'Creating worktree: ${WORKTREE_NAME}'
if git show-ref --verify --quiet refs/heads/'${GIT_BRANCH}'; then
    git worktree add '${WORKTREE_PATH}' '${GIT_BRANCH}'
else
    git worktree add '${WORKTREE_PATH}' -b '${GIT_BRANCH}' '${BASE_BRANCH}'
fi
cd '${WORKTREE_PATH}'
tmux split-window -h -d -c '${WORKTREE_PATH}'
cp '${MAIN_PROJECT_PATH}/.env' .env
sed -i '' 's|^APP_URL=.*|APP_URL=${APP_URL}|' .env
sed -i '' 's|^DB_DATABASE=.*|DB_DATABASE=${DB_NAME}|' .env
mysql -u root -S /tmp/mysql_3306.sock -e 'CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`'
composer install
php artisan migrate --seed
npm install
npm run build
echo 'Setup complete. Starting Claude...'
rm '$SETUP_SCRIPT'
herd open
fork .
claude
exec zsh
SETUP_EOF
    chmod +x "$SETUP_SCRIPT"

    # Create tmux window running the setup script
    tmux new-window -n "${BRANCH_NAME}" "$SETUP_SCRIPT"
}

# Remove a git worktree created by wta
wtarm() {
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        echo "wtarm - Remove an application git worktree"
        echo ""
        echo "Remove a git worktree, drop its database, and close its tmux window."
        echo ""
        echo "Usage: wtarm [-f] [branch-name]"
        echo ""
        echo "Arguments:"
        echo "  -f, --force   Force remove even with uncommitted changes"
        echo "  branch-name   Name of the branch (without josh/ prefix)"
        echo "                Optional if run from within a worktree folder"
        echo ""
        echo "This command will:"
        echo "  1. Drop the dedicated MySQL database"
        echo "  2. Remove the git worktree at ../<project>--<branch>"
        echo "  3. Close the tmux window (if it exists)"
        echo ""
        echo "Examples:"
        echo "  wtarm feature-auth     # From root app folder"
        echo "  wtarm                  # From within the worktree folder"
        echo "  wtarm -f feature-auth  # Force remove"
        return 0
    fi

    # Check for force flag
    FORCE=""
    if [ "$1" = "-f" ] || [ "$1" = "--force" ]; then
        FORCE="--force"
        shift
    fi

    CURRENT_DIR=$(basename "$(pwd)")

    # Check if we're in a worktree folder (contains --)
    if [ -z "$1" ] && [[ "${CURRENT_DIR}" == *"--"* ]]; then
        # Extract branch name and project name from folder
        BRANCH_NAME="${CURRENT_DIR##*--}"
        PROJECT_NAME="${CURRENT_DIR%%--*}"
        WORKTREE_PATH="$(pwd)"
        PARENT_DIR=$(dirname "$(pwd)")

        # Database name: lowercase project + branch, dashes to underscores
        DB_NAME=$(echo "${PROJECT_NAME}_${BRANCH_NAME}" | tr '[:upper:]' '[:lower:]' | tr '-' '_')

        echo "Removing worktree: ${CURRENT_DIR}"
        echo "Dropping database: ${DB_NAME}"

        # Drop the database
        mysql -u root -S /tmp/mysql_3306.sock -e "DROP DATABASE IF EXISTS \`${DB_NAME}\`"

        # cd out of worktree before removing
        cd "${PARENT_DIR}/${PROJECT_NAME}"

        if git worktree remove ${FORCE} "${WORKTREE_PATH}"; then
            tmux kill-window -t "${BRANCH_NAME}" 2>/dev/null
            echo "Worktree removed successfully"
        else
            echo "Failed to remove worktree. Use -f to force remove."
            # cd back to worktree so user can retry with -f
            cd "${WORKTREE_PATH}"
            return 1
        fi

        return 0
    fi

    # Original behavior - must be in root app with branch name
    if [ -z "$1" ]; then
        echo "Error: Branch name is required (or run from within a worktree folder)"
        echo "Usage: wtarm [-f] <branch-name>"
        return 1
    fi

    BRANCH_NAME="$1"
    PROJECT_NAME=$(basename "$(pwd)")
    WORKTREE_NAME="${PROJECT_NAME}--${BRANCH_NAME}"
    PARENT_DIR=$(dirname "$(pwd)")
    WORKTREE_PATH="${PARENT_DIR}/${WORKTREE_NAME}"

    # Database name: lowercase project + branch, dashes to underscores
    DB_NAME=$(echo "${PROJECT_NAME}_${BRANCH_NAME}" | tr '[:upper:]' '[:lower:]' | tr '-' '_')

    echo "Removing worktree: ${WORKTREE_NAME}"
    echo "Dropping database: ${DB_NAME}"

    # Drop the database
    mysql -u root -S /tmp/mysql_3306.sock -e "DROP DATABASE IF EXISTS \`${DB_NAME}\`"

    if git worktree remove ${FORCE} "${WORKTREE_PATH}"; then
        tmux kill-window -t "${BRANCH_NAME}" 2>/dev/null
        echo "Worktree removed successfully"
    else
        echo "Failed to remove worktree. Use -f to force remove."
        return 1
    fi
}

# List git worktrees for the current application
wtals() {
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        echo "wtals - List git worktrees"
        echo ""
        echo "Usage: wtals"
        return 0
    fi

    git worktree list
}
