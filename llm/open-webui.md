# Using MAGE-LLM with the Open WebUI desktop app

[Back to the MAGE-LLM user guides](README.md)

This guide uses Open WebUI Desktop as one example of connecting a desktop chat application to the MAGE-LLM API. The interface should run on your computer, while prompts are sent to the internally hosted MAGE-LLM service.

## Privacy and security

Open WebUI is included only as an example of connecting a desktop client to MAGE-LLM. We have not verified how it stores, processes, or shares prompts, files, chat history, or API keys. Before using it, review its privacy policy, documentation, settings, and any enabled plugins or external services. Running an application locally does not guarantee that your data stays on your computer or within the institute network. Keep your API key private and ensure that your use complies with institute and project data-handling requirements.

## 1. Before starting

- Request a personal API key through the [MAGE-LLM key request page](README.md#request-a-mage-llm-key).
- Connect your computer to the institute network. If working remotely, use an institute VPN connection that provides access to the service.

## 2. Install and open the desktop app

1. Open the [Open WebUI Desktop download page](https://github.com/open-webui/desktop#download).
2. Choose the installer matching your operating system and processor: Apple Silicon or Intel on macOS; x64 or ARM64 on Windows or Linux. For Debian, Ubuntu, or Mint, use the provided `.deb` package.
3. Install and launch **Open WebUI Desktop**.
4. Select **Get Started**. Allow the app to download and set up its local Open WebUI installation.
5. When the Open WebUI welcome screen appears, create your local administrator account. This account is separate from your MPCDF account.

Continue inside the app with the settings below. Menu labels can vary with the installed version. The [desktop project documentation](https://github.com/open-webui/desktop) explains how the app manages the local installation.

## 3. Connect to MAGE-LLM

1. Open your profile menu, then **Settings → Admin → Connections**. Some versions label this **Admin Panel → Settings → Connections**.
2. Under **Manage OpenAI API Connections**, select **Add Connection** or **+**.
3. Enter the following settings:

| Setting | Value |
|---|---|
| Connection type, if shown | `External` |
| URL | `https://gpu.bioinformatics.studio/v1` |
| API key | Your personal MAGE-LLM key |
| API protocol, if offered | OpenAI-compatible Chat Completions |

4. Select **Verify Connection** beside the URL, then **Save**. Verification checks the model list; a chat response is the next check.
5. Return to **New Chat** and select one of the models from the model selector.

Open WebUI documents this connection mechanism in its [OpenAI-compatible provider guide](https://docs.openwebui.com/getting-started/quick-start/connect-a-provider/starting-with-openai-compatible/).

## Other desktop clients

Other applications may also connect to MAGE-LLM if they support a custom OpenAI-compatible API URL, personal API key, and model name. One example is [Chatbox](https://docs.chatboxai.app/en/guides/providers). Check each application's privacy settings and data-handling practices before use.
