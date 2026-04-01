# proxies

Two-layer LLM proxy on Cloud Run: [CLIProxyAPI](https://github.com/router-for-me/CLIProxyAPI) handles OAuth-based model access, [LiteLLM](https://github.com/BerriAI/litellm) sits in front with per-key model restrictions and spend tracking.

| Service | Domain | Purpose |
|---------|--------|---------|
| LiteLLM | `llm.proxies.of.achyuth.dev` | API gateway with virtual keys, model access control, and admin UI |
| CLIProxyAPI | `models.proxies.of.achyuth.dev` | Upstream model provider (Claude via OAuth, Fireworks, etc.) |

## Architecture

```
Client (Claude Code, curl, etc.)
  │
  ▼
LiteLLM (llm.proxies.of.achyuth.dev)
  │  per-key model restrictions, spend tracking, admin UI
  ▼
CLIProxyAPI (models.proxies.of.achyuth.dev)
  │  OAuth token management, provider routing
  ├──► Anthropic (Claude models via OAuth)
  └──► Fireworks AI (Kimi K2.5, etc.)
```

## Client setup

Edit `~/.claude/settings.json` and add:

```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://llm.proxies.of.achyuth.dev",
    "ANTHROPIC_AUTH_TOKEN": "sk-your-key-here"
  }
}
```

Replace `sk-your-key-here` with the key you were given.

**File location:**
- macOS / Linux: `~/.claude/settings.json`
- Windows: `%USERPROFILE%\.claude\settings.json`

## Infrastructure

Everything runs on GCP Cloud Run, managed by Terraform.

### Prerequisites

- Terraform >= 1.11.0
- `gcloud` CLI (authenticated)
- A Cloudflare zone for DNS
- A Neon PostgreSQL database (shared by both services)

### First-time setup

```sh
cp infra/terraform/terraform.tfvars.example infra/terraform/terraform.tfvars
# Fill in your values

make bootstrap-state GCP_PROJECT=your-project-id
make init
make deploy
```

### Day-to-day

```sh
make plan              # Preview changes
make deploy            # Apply changes
make logs              # LiteLLM logs
make logs-cliproxy     # CLIProxyAPI logs
make status            # LiteLLM service status
make status-cliproxy   # CLIProxyAPI service status
make restart           # Force new LiteLLM revision
make restart-cliproxy  # Force new CLIProxyAPI revision
make open              # Open LiteLLM admin dashboard
make open-cliproxy     # Open CLIProxyAPI management UI
```

### Configuration

- **LiteLLM** models and keys are managed through the admin UI at `/ui` or via the `/model/new` and `/key/generate` API endpoints. State is stored in PostgreSQL.
- **CLIProxyAPI** providers and OAuth tokens are managed through the management UI at `/management.html`. State is persisted to PostgreSQL via `PGSTORE_DSN`.
