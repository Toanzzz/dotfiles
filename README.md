# dotfiles

Personal macOS shell setup: zsh + starship, tmux + tpm.

## Install

```sh
git clone git@github.com:Toanzzz/dotfiles.git ~/code/T/dotfiles
cd ~/code/T/dotfiles
./setup.sh
```

`setup.sh` requires [Homebrew](https://brew.sh) and is idempotent — re-run it any time. It:

1. Installs `starship`, `fzf`, `zsh-autosuggestions`, `tmux` via brew (skips what's present)
2. Initializes the [tpm](https://github.com/tmux-plugins/tpm) submodule
3. Symlinks `.zshrc`, `.tmux.conf`, and `.tmux/plugins/tpm` into `$HOME` (existing files are backed up as `*.backup.<timestamp>`)
4. Installs tmux plugins

Then reload: `source ~/.zshrc` and `tmux source ~/.tmux.conf`.

## What's inside

**`.zshrc`** — starship prompt, fzf, autosuggestions, PATH for mise/bun/deno/ruby/android/etc., plus helpers:

| | |
|---|---|
| `awsp` | pick an AWS profile with fzf |
| `javah` | pick a `JAVA_HOME` with fzf |
| `sshs` | pick a host from `~/.ssh/config` and connect |
| `gwtj` | jump between git worktrees (with log preview) |
| `*-gitinit` | set per-repo git user name/email |
| `tm-*` | open a tmux session for a given project |

**`.tmux.conf`** — mouse on, 256 colors, `C-k` clear history, `C-q` kill session. Plugins: tmux-sensible, tmux-yank, tmux-prefix-highlight, sombre theme.

## License

MIT — see [LICENSE](LICENSE).
