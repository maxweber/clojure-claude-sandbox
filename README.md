# Clojure + Node.js + Claude Code Docker Image

Docker image combining Clojure development tools with Node.js ecosystem and
Claude Code CLI, optimized for UNATTENDED Clojure development with Claude Code 
in a sandbox.

I find lately that I can largely trust Claude Code to work unattended, and I wanted 
an environment where I can safely do that and just disable all security and questions
of "can I use this?".

This image has all the tools needed for running Bruce Hauman's clojure-mcp and clojure-mcp-light, and it has a start at 
a script that will appear in the docker shell called claude-setup-clojure that puts the stuff in place that
clojure-mcp-light current has. YMMV.

The image *tries* to mount your claude configs and sessions so that if you've already logged in to a 
subscription then it'll "just work".

Claude wrote almost everything here with my direction. I have not been particularly critical of the 
documentation, but I did glance through it.

## Usage

Copy the scripts/start-dev-container.sh to someplace on your path. 
The docker container itself is published for Macs (arm). If you want it for something else, 
you can build it yourself.

```bash
cd project-you-want-to-work-on
start-dev-container.sh .
cc838dd6a9bb:/workspace$ claude 
# or use the ccode alias, which is the same as:
claude --dangerously-skip-permissions
```

See the usage output (no args) for other options on the start script. The script currently does
try to expose port 7888 from inside the container to some random port on the
host (and writes it to .nrepl-port) so you can jack into/connect to the nrepl
INSIDE the container, assuming you run your REPL on 7888.

The user you'll be running as is ralph, after Ralph Wiggum of the Simpson's.
The idea being that your user is just blindly saying "sure, do that" without
thinking. Ralph has sudo, so you can have Claude (or manually) install anything else your
session might need, like aws-cli tools.

## Image Details

**Base Image:** `clojure:temurin-25-tools-deps` (Debian-based)
**Docker Hub:** `tonykayclj/clojure-node-claude:latest`
**Architecture:** ARM64 (Apple Silicon / aarch64)

## Included Tools

### Core Tools
- **Clojure CLI** 1.12.3.1577
- **Java/OpenJDK** 25.0.1 (Temurin LTS)
- **Node.js** v20
- **Claude Code** 2.0.37

### Clojure Development Tools
- **Babashka** 
- **bbin** 
- **parinfer-rust** 
- **cljfmt** 

### Claude Code Integration (clojure-mcp-light)
- **clj-paren-repair-claude-hook** - Automatic parenthesis repair with optional cljfmt integration
- **clj-nrepl-eval** - nREPL evaluation support for Claude Code
- **claude-setup-clojure** v1.0.0 - Project setup script for Claude Code hooks

## Quick Start

### Prerequisites

Before using the container, ensure you have authenticated Claude Code on your host machine:

```bash
# Install Claude Code CLI on your Mac (if not already installed)
npm install -g @anthropic-ai/claude-code

# Login with your Claude subscription
claude login

# This creates ~/.claude with your credentials
```

**For multiple accounts:** You can maintain different Claude config directories (e.g., `~/.claude-work`, `~/.claude-personal`) and use the `--claude-config` option to specify which account to use.

### Option 1: Using the Container Startup Script (Recommended)

```bash
# Start a development container for your project
./scripts/start-dev-container.sh ~/projects/my-clojure-app

# Or with custom options
./scripts/start-dev-container.sh --name my-repl --port 7890 ~/projects/my-app

# Interactive shell mode
./scripts/start-dev-container.sh --shell ~/projects/my-app
```

The script will:
- Find an available nREPL port (default: 7888-8888 range)
- Write the port to `PROJECT_DIR/.nrepl-port`
- Mount your project at `/workspace`
- Mount your Claude config directory to `/home/ralph/.claude` (default: `~/.claude`)
  - Use `--claude-config` to specify an alternate directory for different accounts
- Forward the nREPL port from container to host
- Start as user `ralph` with sudo access

### Option 2: Manual Docker Commands

```bash
# Pull the image
docker pull tonykayclj/clojure-node-claude:latest

# Run interactively
docker run -it --rm tonykayclj/clojure-node-claude:latest

# Mount your project directory with nREPL port and Claude config
docker run -it --rm \
  -v $(pwd):/workspace \
  -v ~/.claude:/home/ralph/.claude \
  -w /workspace \
  -p 7888:7888 \
  tonykayclj/clojure-node-claude:latest
```

## Setting Up a Clojure Project for Claude Code

Inside the container, run the setup script:

```bash
# Setup with defaults
claude-setup-clojure

# Preview changes without creating files
claude-setup-clojure --dry-run

# Overwrite existing configuration
claude-setup-clojure --force

# Skip creating slash commands
claude-setup-clojure --no-commands

# Disable cljfmt in hooks
claude-setup-clojure --no-cljfmt-hook
```

The script creates:
- `.claude/settings.local.json` - Hook configuration for parinfer and cljfmt
- `.cljfmt.edn` - Code formatting configuration (if missing)
- `.claude/commands/nrepl-eval.md` - Slash command for nREPL evaluation
- `.claude/commands/nrepl-eval-buffer.md` - Slash command for buffer evaluation

### Available Hooks

The setup script configures these Claude Code hooks:

**PreToolUse** - Before Write/Edit operations:
- Repairs parentheses using `clj-paren-repair-claude-hook`
- Optionally formats code with cljfmt

**PostToolUse** - After Write/Edit operations:
- Repairs parentheses and formats code

**SessionEnd** - When Claude Code session ends:
- Final cleanup and repair

### Shell Alias

A `ccode` alias is available for running Claude Code without permission checks:
```bash
ccode  # Equivalent to: claude --dangerously-disable-permissions
```

