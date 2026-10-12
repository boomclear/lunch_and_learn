# Run existing checks locally

Austin requested local checks on his Mac for every project that already has checks on October 12, 2026. This PR removes automatic hosted triggers; default-branch files change after merge. Existing hosted jobs remain available only by explicit manual dispatch and can consume minutes if enabled. Repository workflow settings are separately disabled. Disabling a check is not a passing result.

Run one project's checks at a time from an isolated checkout. Use synthetic data only. The script stops on the first failure. Resolve it and rerun; an early failure does not prove later checks passed. Existing coverage floors, security regression suites and dependency audits remain in the commands.

## Setup

Use the existing workflow’s Ruby **3.2.2**, selected before these commands; verify `ruby --version`. The Mac’s system Ruby 2.6.10 is insufficient. From an isolated checkout, prepare only the existing locked/focused dependencies:

```bash
gem install --no-document --install-dir "$PWD/.local-check-gems" vcr:6.2.0 webmock:3.18.1 rspec:3.12.0 faraday:2.7.10
export GEM_HOME="$PWD/.local-check-gems"
export GEM_PATH="$GEM_HOME"
export PATH="$GEM_HOME/bin:$PATH"
```

The wrapper does not install Ruby or gems, and no global Ruby installation is part of this migration. Keep local gems/bundle configuration untracked.

## Run

```bash
# Activate the prepared virtualenv or set LOCAL_CHECKS_PYTHON to its python.
bash scripts/local-checks.sh
```

Pytest worker count is bounded to one where the former workflow used four; this preserves the suite while reducing simultaneous work on the Mac. Browser installation uses the macOS-supported Chromium command without Linux OS package installation. macOS results do not certify Windows/Linux-only behavior.

## Reversal and evidence

Restore the previous workflow trigger stanza and re-enable the workflow only when Austin requests hosted execution. Record the Git head, command, exit status, passed/skipped counts and any audit findings. Do not change required branch/security checks to get a merge through; surface a required-check blocker for explicit approval.
