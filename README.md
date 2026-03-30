# proxies

A shared LLM API proxy at `llm.proxies.of.achyuth.dev`. If you've been given a key, here's how to point Claude Code at it.

## Setup

Edit `~/.claude/settings.json` (create it if it doesn't exist) and add the following `env` block:

```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://llm.proxies.of.achyuth.dev",
    "ANTHROPIC_AUTH_TOKEN": "sk-your-key-here",
    "ENABLE_TOOL_SEARCH": "true"
  }
}
```

Replace `sk-your-key-here` with the key you were given. `ENABLE_TOOL_SEARCH` is required for MCP tool search to work when using a custom base URL.

**File location:**
- macOS / Linux: `~/.claude/settings.json`
- Windows: `%USERPROFILE%\.claude\settings.json`

That's it. Restart Claude Code and it will route through the proxy automatically.
