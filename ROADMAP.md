# YAAT Bootstrap Roadmap

Bootstrap scripts for provisioning [YAAT](https://github.com/mhernandezve/yaat) - Yet Another Auto Tool for dotfiles management.

---

## MVP

- [x] Create `yaat-bootstrap` repository
- [ ] Create `bootstrap.sh` script:
  1. Detect architecture (x86_64-linux, aarch64-linux, x86_64-macos, aarch64-macos)
  2. Download YAAT binary from GitHub Releases (via cargo-dist)
  3. Install to `~/.local/bin/yaat` (or similar)
  4. Run `yaat init <repo-url>` with provided argument
  5. Clean up temporary files
- [ ] Create alternative one-liner installer (for systems with curl):
  ```bash
  curl -sL https://raw.githubusercontent.com/mhernandezve/yaat-bootstrap/main/bootstrap.sh | bash -s <dotfiles-repo-url>
  ```

---

## Future Improvements

- [ ] Support for installing specific YAAT version (`--version` flag)
- [ ] Checksum verification of downloaded binaries
- [ ] Support for different shells (bash, zsh, fish) in PATH setup
- [ ] Windows support (when YAAT adds Windows compatibility)
- [ ] Local YAAT installation (without modifying PATH)

---

Last updated: 2026-04-19
