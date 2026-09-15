# Git workflow (one clone, clean `main`, `internal` patch stack)

Unstructured-IO is not yours. Keep a private fork, stay current with upstream, and keep
your changes as a short rebaseable stack.

## Layout

One local clone per repo. No second “pristine” folder. `upstream/main` is the clean original.

| Local folder | `origin` (push) | `upstream` (fetch only) |
|---|---|---|
| `/Users/rukesh/Documents/projects/unstructured-remote` | [Rudreysh/unstructured](https://github.com/Rudreysh/unstructured) | [Unstructured-IO/unstructured](https://github.com/Unstructured-IO/unstructured) |
| `/Users/rukesh/Documents/projects/unstructured-api` | [Rudreysh/unstructured-api](https://github.com/Rudreysh/unstructured-api) | [Unstructured-IO/unstructured-api](https://github.com/Unstructured-IO/unstructured-api) |

Push to Unstructured-IO is disabled.

### Branches

| Branch | Role |
|---|---|
| `main` | Exact mirror of Unstructured-IO `main`. No custom commits. |
| `internal` | What you run: upstream + your patch stack. |
| `feat/…` | One change. Open a PR on **your** GitHub into `internal`. |

## Remotes (already configured)

Library (`unstructured-remote`):

```text
origin     https://github.com/Rudreysh/unstructured.git          (fetch + push)
upstream   https://github.com/Unstructured-IO/unstructured.git   (fetch only)
```

API (`unstructured-api`):

```text
origin     https://github.com/Rudreysh/unstructured-api.git          (fetch + push)
upstream   https://github.com/Unstructured-IO/unstructured-api.git   (fetch only)
```

## Rules

1. Never commit on `main`.
2. Never `git push` to Unstructured-IO.
3. Run and develop on `internal` or a `feat/…` branch.
4. Push custom branches to `origin` (your GitHub) only.
5. Keep `main` a fast-forward of `upstream/main`.
6. Keep custom work as a small, named commit stack on `internal` so you can always list “what is ours.”
7. Prefer wrapping or configuring stock `unstructured` over growing the fork.

## Daily work

```bash
cd /Users/rukesh/Documents/projects/unstructured-remote   # or unstructured-api
git checkout internal
git checkout -b feat/short-name
# edit files
git add -A
git commit -m "Describe why this change exists."
git push -u origin feat/short-name
```

On your GitHub, open a PR: `feat/short-name` → `internal`. Merge it. Then:

```bash
git checkout internal
git pull origin internal
```

Do not merge feature branches into `main`.

## Update from Unstructured-IO

Replay **your** commits on top of the new original.

```bash
cd /Users/rukesh/Documents/projects/unstructured-remote   # or unstructured-api
git sync-upstream      # fast-forward local + GitHub main
git rebase-internal    # rebase internal onto upstream/main and push
```

Equivalent commands:

```bash
git fetch upstream
git checkout main
git merge --ff-only upstream/main
git push origin main

git checkout internal
git rebase upstream/main
git push --force-with-lease origin internal
```

`--force-with-lease` is only for **your** `internal` (or a `feat/…` branch you rebased). Never on `main`. Never against Unstructured-IO.

If several people share `internal` and rebase is painful, merge instead:

```bash
git checkout internal
git merge main
git push origin internal
```

After a rebase, update any open `feat/…` branches:

```bash
git checkout feat/short-name
git rebase internal
git push --force-with-lease origin feat/short-name
```

See what is yours:

```bash
git log --oneline upstream/main..internal
```

## Aliases (already set)

| Alias | What it does |
|---|---|
| `git sync-upstream` | Fetch Unstructured-IO, fast-forward local `main`, push `main` to your fork. |
| `git rebase-internal` | Run `sync-upstream`, rebase `internal` onto `upstream/main`, force-with-lease push `internal`. |

## New machine / re-clone

You do not need to fork again.

Library:

```bash
git clone -b internal https://github.com/Rudreysh/unstructured.git /Users/rukesh/Documents/projects/unstructured-remote
cd /Users/rukesh/Documents/projects/unstructured-remote
git remote add upstream https://github.com/Unstructured-IO/unstructured.git
git remote set-url --push upstream DISABLED
git fetch upstream
git checkout main
git merge --ff-only upstream/main
git checkout internal
git config --local alias.sync-upstream '!git fetch upstream && git checkout main && git merge --ff-only upstream/main && git push origin main'
git config --local alias.rebase-internal '!git fetch upstream && git checkout main && git merge --ff-only upstream/main && git push origin main && git checkout internal && git rebase upstream/main && git push --force-with-lease origin internal'
```

API: same steps with `unstructured-api` paths and GitHub remotes.

## Do not

- Push to Unstructured-IO.
- Commit on `main`.
- Merge `internal` or `feat/…` into `main`.
- Keep a second local clone as a “clean original” (`upstream/main` is that).
- Open a PR to Unstructured-IO unless you intentionally want to contribute upstream.

## Checklist: “original updated, my work kept”

1. `git sync-upstream`
2. Confirm `main` matches upstream: `git log -1 --oneline main` equals `git log -1 --oneline upstream/main`.
3. `git rebase-internal`
4. Resolve conflicts on `internal` only.
5. Confirm `git log --oneline upstream/main..internal` is still your patch stack.
6. Rebase any open `feat/…` branches onto `internal`.
