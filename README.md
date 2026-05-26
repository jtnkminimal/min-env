# min-env

A reusable [Minimal](https://minimal.dev) + [zellij](https://zellij.dev) dev-environment template: a `minimal run dev` task that drops you into a zellij layout with **Claude Code** in one pane and an interactive **shell** in another, fronted by a task selector pane.

Drop this into any project, add your own build/test tasks to `minimal.toml`, and you get a consistent, ephemeral sandbox dev loop with no host toolchain install required beyond the `minimal` CLI.

## Getting started

From the host:

    minimal run dev          # interactive zellij dev session (Claude pane + shell pane)
    minimal run claude       # Claude Code on its own
    minimal run shell        # a plain interactive shell

> **CLI naming:** on the host the binary is `minimal`. Once you're inside a sandbox (e.g. via `minimal run dev`) the same tool is exposed as `min`.

## What's here

- `minimal.toml` — sandbox + task definitions. Add your project's `build`/`test`/`run` tasks here.
- `zellij.kdl` — the dev layout: three panes (Claude / task selector / shell).
- `zellij-config.kdl` — zellij settings (suppresses startup tips & release notes).
- `scripts/setup-dev.sh` — launcher invoked by the `dev` task; resets and attaches the zellij session.
- `scripts/dev-shell.sh` — the interactive task selector pane. It discovers `[tasks.*]` entries from `minimal.toml`.

## `minimal run dev`

Launches a zellij layout (`zellij.kdl`) via `scripts/setup-dev.sh` with three panes:

- **left** — Claude Code (`claude --dangerously-skip-permissions`, only safe because the sandbox is ephemeral).
- **top-right** — a task selector pane (`scripts/dev-shell.sh`) for available `min run <task>` shortcuts. Use Up/Down or `j`/`k` to select a task and Enter to run it.
- **bottom-right** — a plain interactive fish shell.

The session is named `dev` and is reset on each invocation.

## Customizing

1. Add tasks to `minimal.toml` (e.g. a `build` task with your toolchain packages and an `exec` line).
2. Adjust the `packages` array of `[tasks.dev]` to include whatever tooling you want available in the shell pane.
