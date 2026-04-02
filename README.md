# proxies

LLM proxy that gives you a single API key for multiple model providers. If you've been given a key, see [Using your key](#using-your-key) below.

## Using your key

You'll receive an API key that looks like `sk-...`. This key works with any OpenAI-compatible client.

### Claude Code

Edit `~/.claude/settings.json` (`%USERPROFILE%\.claude\settings.json` on Windows):

```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://llm.proxies.of.achyuth.dev",
    "ANTHROPIC_AUTH_TOKEN": "sk-your-key-here"
  }
}
```

### OpenCode

Add to `~/.config/opencode/opencode.json` (or `.opencode/opencode.json` in a project):

```json
{
  "$schema": "https://opencode.ai/config.json",
  "provider": {
    "proxy": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "Achyuth's Proxy",
      "options": {
        "baseURL": "https://llm.proxies.of.achyuth.dev/v1",
        "apiKey": "sk-your-key-here"
      },
      "models": {
        "kimi-k2p5-turbo": {
          "name": "Kimi K2.5 Turbo"
        }
      }
    }
  },
  "model": "proxy/kimi-k2p5-turbo"
}
```

The `models` block must list the model IDs your key has access to. The `model` field sets the default, in `provider-id/model-id` format.

### aider

```sh
export OPENAI_API_BASE="https://llm.proxies.of.achyuth.dev/v1"
export OPENAI_API_KEY="sk-your-key-here"
aider --model openai/kimi-k2p5-turbo
```

The `openai/` prefix on the model name is required. You can also set these in `~/.aider.conf.yml`:

```yaml
openai-api-base: https://llm.proxies.of.achyuth.dev/v1
openai-api-key: sk-your-key-here
model: openai/kimi-k2p5-turbo
```

### Continue (VS Code / JetBrains)

Edit `~/.continue/config.yaml`:

```yaml
models:
  - name: Kimi K2.5 Turbo
    provider: openai
    model: kimi-k2p5-turbo
    apiBase: https://llm.proxies.of.achyuth.dev/v1
    apiKey: sk-your-key-here
```

### Any other OpenAI-compatible client

The proxy speaks the standard `/v1/chat/completions` format:

```
Base URL: https://llm.proxies.of.achyuth.dev/v1
API Key:  sk-your-key-here
```

This works with the OpenAI Python/Node SDKs, LangChain, LlamaIndex, and most tools that accept a custom OpenAI base URL.

### curl

```sh
curl https://llm.proxies.of.achyuth.dev/v1/chat/completions \
  -H "Authorization: Bearer sk-your-key-here" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "kimi-k2p5-turbo",
    "messages": [{"role": "user", "content": "Hello"}]
  }'
```

### Available models

Your key may be scoped to specific models. To list what you have access to:

```sh
curl -s https://llm.proxies.of.achyuth.dev/v1/models \
  -H "Authorization: Bearer sk-your-key-here" | jq '.data[].id'
```

Examples of what may be available: Claude (Anthropic), Gemini (Google), GPT (OpenAI), Mistral, open-weight models, etc.

## Architecture

Two services work together on Cloud Run:

```
Client (Claude Code, OpenCode, curl, etc.)
  │
  ▼
LiteLLM (llm.proxies.of.achyuth.dev)
  │  per-key model restrictions, spend tracking, admin UI
  ▼
CLIProxyAPI (models.proxies.of.achyuth.dev)
  │  OAuth token management, provider routing
  ├──► Anthropic (Claude models via OAuth)
  ├──► Google (Gemini models)
  └──► other providers
```

| Service | Domain | Role |
|---------|--------|------|
| [LiteLLM](https://github.com/BerriAI/litellm) | `llm.proxies.of.achyuth.dev` | API gateway — virtual keys, model access control, spend tracking, admin UI |
| [CLIProxyAPI](https://github.com/router-for-me/CLIProxyAPI) | `models.proxies.of.achyuth.dev` | Upstream router — OAuth token management, provider round-robin |

LiteLLM is the user-facing endpoint. CLIProxyAPI sits behind it as one of several possible model providers, handling cases where OAuth-based access or custom routing is needed.

## Infrastructure

Everything runs on GCP Cloud Run, managed by Terraform. Both services scale to zero when idle.

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

- **LiteLLM** — models and keys are managed through the admin UI at `/ui` or via the `/model/new` and `/key/generate` API endpoints. State lives in PostgreSQL.
- **CLIProxyAPI** — providers and OAuth tokens are managed through the management UI at `/management.html`. State is persisted to PostgreSQL via `PGSTORE_DSN`.
