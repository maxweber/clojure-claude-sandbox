---
name: clojure-repl
description: Automatically manage and use nREPL servers to run/evaluate Clojure code and tests.
---

# Clojure REPL Management

Automatically handle all Clojure REPL operations without requiring manual commands from the user.

## Core Capabilities

### 1. Code Evaluation

There is a CLI tool called `clj-nrepl-eval`. You can use that to send clojure expressions to the running REPL:

```bash
clj-nrepl-eval --timeout 60000 -H dev-app -p 4000  <<'EOF'
(def x 10)
(+ x 20)
EOF
```
