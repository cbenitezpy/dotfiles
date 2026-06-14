#!/usr/bin/env python3
"""
Install dotfiles via symlinks from ~/.dotfiles → home.

Supports file symlinks (default) and directory symlinks (for ~/.config/nvim).
"""
from pathlib import Path

HOME = Path.home()
DOTFILES = HOME / ".dotfiles"

# Mapping: source_in_dotfiles -> destination_in_home
# A leading dir like "nvim" means "symlink the whole directory"
LINKS = {
    # Shell
    "shell/.zshrc": ".zshrc",
    "shell/.zprofile": ".zprofile",
    "shell/.bashrc": ".bashrc",
    "shell/.bash_profile": ".bash_profile",
    "shell/.profile": ".profile",
    # Git
    "git/.gitconfig": ".gitconfig",
    "git/.gitignore_global": ".gitignore_global",
    # Tmux
    "tmux/.tmux.conf": ".tmux.conf",
    # Starship
    "starship/starship.toml": ".config/starship.toml",
    # GitHub CLI
    "gh/config.yml": ".config/gh/config.yml",
    # Atuin
    "atuin/config.toml": ".config/atuin/config.toml",
    # sesh (tmux session manager)
    "sesh/sesh.toml": ".config/sesh/sesh.toml",
    # lazygit (git TUI)
    "lazygit/config.yml": ".config/lazygit/config.yml",
    # Zed editor
    "zed/settings.json": ".config/zed/settings.json",
    # Neovim (whole directory symlink — LazyVim config)
    "nvim": ".config/nvim",
    # SDKMAN — NOT symlinked by default: a global ~/.sdkmanrc with a pinned
    # Java version makes SDKMAN auto-env trigger on every shell load in $HOME.
    # If you want it on a specific machine, run manually:
    #   ln -s ~/.dotfiles/dev/.sdkmanrc ~/.sdkmanrc
    # Claude Code
    "claude/CLAUDE.md": ".claude/CLAUDE.md",
    "claude/mcp.json": ".claude/mcp.json",
    "claude/settings.json": ".claude/settings.json",
}


def install():
    print("Installing dotfiles via symlinks...")

    for source_rel, target_rel in LINKS.items():
        source = DOTFILES / source_rel
        target = HOME / target_rel

        if not source.exists():
            print(f"   skip (missing): {source_rel}")
            continue

        # Ensure parent dir exists
        target.parent.mkdir(parents=True, exist_ok=True)

        # Backup existing real file/dir (only if not already a symlink)
        if target.exists() and not target.is_symlink():
            backup = target.parent / f"{target.name}.pre-dotfiles"
            target.rename(backup)
            print(f"   backup: {target_rel} -> {backup.name}")

        # Remove existing symlink to refresh
        if target.is_symlink():
            target.unlink()

        target.symlink_to(source)
        print(f"   linked: {target_rel} -> {source}")

    print("\nDotfiles installed.")


if __name__ == "__main__":
    install()
