---
name: add-dotfile
description: >
  Add a file or folder into this dotfiles repo, wire setup.sh to symlink it,
  update README, and apply the link on the live machine. Use when the user
  wants to add a dotfile, track ~/.config/..., vendor an app config, or add
  a file or folder to this repo.
---

# Add a file or folder to this dotfiles repo

Capture a live config path in this repo, symlink it from the machine, and keep `setup.sh` / `README.md` in sync.

This skill is project-local. Follow it in any coding agent working in this repository.

## 1. Resolve the live path

- Expand `~`. Treat a bare name (e.g. `starship.toml`) as `$HOME/.config/<name>` only if that file exists; otherwise ask which path.
- If the live path is already a symlink into this repo, stop and report it.
- If it exists, copy that content. Do not invent a replacement unless asked to.
- Never copy secrets or junk: private keys, `credentials*`, tokens, `.env`, cookies, `node_modules`, plugin/cache dirs, large generated trees.

## 2. Choose the repo path

| Live destination | Repo path |
|---|---|
| `$HOME/<rel>` where `<rel>` starts with `.` | `<rel>` (keep the home-relative path) |
| App path outside `$HOME` (e.g. `~/Library/Application Support/...`) | `<app-name>/<filename>` |
| Third-party git repo to vendor and update | git submodule only (see tpm) |

Examples already in this repo:

- `.zshrc` → `~/.zshrc`
- `.config/starship.toml` → `~/.config/starship.toml`
- `.ssh/config` → `~/.ssh/config`
- `ghostty/config.ghostty` → `~/Library/Application Support/com.mitchellh.ghostty/config.ghostty`

Add the specific file or folder requested, not a parent dump (do not vendor all of `~/.config`).

## 3. Put it in the repo

- Create parent directories as needed.
- File: write the live contents to the repo path.
- Directory: copy into the repo path, excluding secrets/junk above.
- Copy into the repo first. Never `mv` the live path away before the repo copy exists.

## 4. Wire `setup.sh`

Add one `link_file` call next to the existing ones:

```bash
link_file "${DOTFILES_DIR}/<repo-rel>" "${HOME_DIR}/<home-rel>"
```

For a destination not under `$HOME`, pass the absolute dest (Ghostty style).

If the added thing needs a Homebrew formula, append it to `BREW_PACKAGES`. Do not add a brew entry for a config-only file.

## 5. Update `README.md`

- Install step 3: add the repo-relative path to the symlink list.
- What's inside: one short entry for the new file or folder.

## 6. Apply the link now

Apply immediately with the same behavior as `link_file` in `setup.sh`:

1. `mkdir -p` the dest parent
2. If dest is already the correct symlink, skip
3. If dest is a different symlink, remove it
4. If dest exists, `mv` it to `${dest}.backup.$(date +%Y%m%d%H%M%S)`
5. `ln -s` from the repo path to dest
6. Confirm with `ls -la`

If you added a brew package, run `./setup.sh` so the formula is installed. Otherwise do not run the full script just to link (it also inits tpm and installs plugins).

## 7. Stop

- Do not commit unless asked.
- Tell the user the repo path, dest symlink, and backup name if one was created.
