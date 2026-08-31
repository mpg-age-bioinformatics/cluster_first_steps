# Using the internal LLM in Posit Visual Studio Code

[Back to the MAGE-LLM user guides](README.md)

The MAGE-LLM service provides an OpenAI-compatible API and can be used with clients that support custom OpenAI-compatible endpoints. Such clients must allow users to configure an API base URL, model name, and API key. This guide presents Continue as one example, but other compatible clients may also be used.

For instance, Posit Visual Studio Code can connect to our internal LLM service through the **Continue** extension. You can use it for:

- questions and code explanations;
- generating and editing code;
- reviewing selected code or project files; and
- agent-assisted, multi-step coding tasks.

Before starting, request a personal MAGE-LLM key as described in the [user-guide overview](README.md#request-a-mage-llm-key).

The MAGE-LLM endpoint may also be usable with the official Visual Studio Code Chat/Copilot integration. Availability and configuration depend on the Visual Studio Code and Copilot features installed and enabled in your environment. See the [official Visual Studio Code BYOK documentation](https://code.visualstudio.com/docs/agent-customization/language-models) for further information.

> [!CAUTION]
> Continue is a third-party plugin and Visual Studio Code plugins run with the permissions of your Posit user and may access workspace files or communicate with configured services. Agent features may also propose file changes and terminal commands. Review its permissions, settings, updates, proposed changes, and commands carefully.

## 1. Install or open Continue

1. Open Visual Studio Code in Posit.
2. Open **Extensions** from the left sidebar, or press **Ctrl+Shift+X**.
3. Search for `Continue`.
4. Install **Continue - open-source AI code agent**, published by **Continue**. In Posit, the extension is provided through [Open VSX](https://open-vsx.org/extension/Continue/continue).
5. Select the **Continue** icon in the left sidebar.

If Continue is already installed, open it directly from the sidebar.

## 2. Store your personal API key

Continue reads your key from a private `.env` file in your Posit home directory. Open a terminal in Posit Visual Studio Code and run the following commands, replacing `your-personal-key` with your personal key:

```bash
cd
mkdir -p ~/.continue
chmod 700 ~/.continue
echo 'MAGE_LLM_KEY=your-personal-key' > ~/.continue/.env
chmod 600 ~/.continue/.env
```

These commands create or replace `~/.continue/.env`.

## 3. Configure the MAGE models

Your Continue configuration is stored in `~/.continue/config.yaml`. You can open and modify this file whenever you want or need to change the available models or their settings.

Edit `~/.continue/config.yaml` or:

1. Open the Continue panel.
2. Open the configuration selector above the chat input.
3. Select the gear icon next to **Local Config**. This opens `~/.continue/config.yaml`.
4. Replace its contents with the configuration below and save the file.

```yaml
name: MAGE Posit Assistant
version: 1.0.0
schema: v1

models:
  - name: MAGE-QWEN Assistant
    provider: openai
    model: qwen36-27b
    apiBase: https://gpu.bioinformatics.studio/v1
    apiKey: ${{ secrets.MAGE_LLM_KEY }}
    useResponsesApi: false
    roles:
      - chat
      - edit
      - apply
    requestOptions:
      extraBodyProperties:
        chat_template_kwargs:
          enable_thinking: false

  - name: MAGE-QWEN Reasoning
    provider: openai
    model: qwen36-27b
    apiBase: https://gpu.bioinformatics.studio/v1
    apiKey: ${{ secrets.MAGE_LLM_KEY }}
    useResponsesApi: false
    roles:
      - chat
      - edit
      - apply
    requestOptions:
      extraBodyProperties:
        chat_template_kwargs:
          enable_thinking: true

```

The `${{ secrets.MAGE_LLM_KEY }}` entry tells Continue to read the key from `~/.continue/.env`. The actual key does not need to appear in `config.yaml`.

After saving the configuration, reload Visual Studio Code if the models do not appear immediately.

## 4. Choose a model and mode

Select a model from the model selector in the Continue panel:

| Model | Recommended use |
|---|---|
| **MAGE-QWEN Assistant** | Default choice for questions, explanations, edits, and ordinary coding tasks |
| **MAGE-QWEN Reasoning** | More complex analysis or multi-step problems; usually slower and more verbose |

You can also choose how Continue works by selecting **Chat**, **Plan**, or **Agent** mode:

| Mode | Recommended use |
|---|---|
| **Chat** | Ask questions, explain code, and discuss possible changes without starting a multi-step agent task |
| **Plan** | Inspect the relevant context and prepare a proposed approach before making changes |
| **Agent** | Perform multi-step tasks that may inspect files, propose edits, or request permission to run commands |

Start with **Chat** for ordinary questions. Use **Plan** when you want to review the intended approach first, and select **Agent** only when the task requires actions in the workspace.

## 5. Use Agent mode carefully

Agent mode can inspect files, propose edits, and request permission to run commands. Its access is determined by your Posit user account and the directories available in your session; Continue does not provide an additional filesystem sandbox.

When using Agent mode:

1. Open only the intended project directory as your workspace.
2. Describe the task and expected output clearly.
3. Provide only the files required for the task.
4. Review every proposed file change and terminal command.
5. Check paths carefully before approving commands that write, overwrite, move, or delete files.
6. Prefer running a workflow on a small test input before using the complete dataset.

Do not approve a command merely because it was generated by the assistant. If a command is unclear, ask the assistant to explain it or run it manually after reviewing it.

## Good practice

- Treat generated code as a draft and validate it before use.
- Keep API keys and other credentials out of prompts, files, and screenshots.
- Add only relevant files as context, especially when working with large datasets.
- Use project-relative paths and confirm output locations before writing files.
- Do not ask the assistant to delete or overwrite important data without checking the exact target.
- The models are hosted internally, but institutional and project data-handling rules still apply.

## Troubleshooting

### No MAGE models appear

- Confirm that `~/.continue/config.yaml` is valid YAML and uses the indentation shown above.
- Confirm that `~/.continue/.env` contains `MAGE_LLM_KEY=your-personal-key`.
- Confirm that the key does not contain quotation marks or spaces around `=`.
- Reload the Visual Studio Code window or completely start a new Posit Visual Studio Code session.

### Authentication or connection error

- Confirm that your personal key is still valid.
- Confirm that the API base is exactly `https://gpu.bioinformatics.studio/v1`.
- Verify that you are connected to the MPCDF network as required by the service.
- Do not share the key when reporting an error.

### The response is slow, stops, or fails

The service uses shared GPU resources. Wait briefly and try again. For a simple task, switch from **MAGE-QWEN Reasoning** to **MAGE-QWEN Assistant**.

### Agent commands do not execute or return output

- Check whether Continue is waiting for confirmation.
- Review and approve the command only if it is safe and correct.
- If command execution does not work in the Posit remote terminal, copy the proposed command, review it, and run it manually in the terminal.
- Include the time, selected model, task description, and visible error message when reporting a persistent problem. Never include your API key.
