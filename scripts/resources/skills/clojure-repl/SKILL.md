---
name: clojure-repl
description: Automatically manage and use nREPL servers to run/evaluate Clojure code and tests.
---

# Clojure REPL Management

Automatically handle all Clojure REPL operations without requiring manual commands from the user.

## Core Capabilities

### 1. Starting nREPL

**Before starting the nREPL**, check the project's `deps.edn` file to determine which aliases to include:
- If the project has a `:test` alias, include it with `-A:test`
- If the project has a `:dev` alias, include it with `-A:dev`
- Always include the nREPL alias (e.g., `:test-nrepl` or `:nrepl`)

Common patterns:
- For projects with `:test` and `:test-nrepl` aliases: `clojure -A:test -M:test-nrepl`
- For projects with `:dev` and `:nrepl` aliases: `clojure -A:dev -M:nrepl`
- For projects with both `:test` and `:dev`: `clojure -A:test:dev -M:nrepl`
- For minimal projects: `clojure -M:nrepl`

Use bash to run this in the background. The nREPL server will:
- Start on an available port (written to `.nrepl-port`)

If you detect that the repl is malfunctioning, kill the background process and start a new one.

### 2. Code Evaluation

There is a CLI tool called `clj-nrepl-eval`. You can use that to send clojure expressions to the running REPL:

```bash
clj-nrepl-eval --timeout 60000 -p $(cat .nrepl-port)  <<'EOF'
(def x 10)
(+ x 20)
EOF
```

If you want to attempt to reset the session, you can try:

```bash
clj-nrepl-eval -p $(cat .nrepl-port) --reset-session 
```
