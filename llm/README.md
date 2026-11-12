# MAGE-LLM user guides

The MAGE-LLM service provides internally hosted open-weight models for supported applications. These guides explain how to connect to the service from our Posit Workbench or your local computer.

## Request a MAGE-LLM key

Users need to request a personal API key for the MAGE-LLM service through [https://flaski.age.mpg.de/llms](https://flaski.age.mpg.de/llms).

API keys are personal credentials. Do not share your key with other users or save it in notebooks, scripts, Git repositories, or screenshots.

## Available guides

- [Example use of MAGE-LLM key with Python](api-key-python.md)
- [Posit JupyterLab with Notebook Intelligence](notebook-nbi.md)
- [Posit Visual Studio Code with Continue](vscode-continue.md)
- [Local desktop client (example: Open WebUI)](open-webui.md)

> [!CAUTION]
> MAGE-LLM is accessible only from the institute network and is currently experimental. The available open-weight models are hosted internally within the MPCDF network and run on a small cluster. Responses may be slow or temporarily unavailable during concurrent use. As with any other LLM, outputs may be inaccurate or incomplete. Always review generated code, commands, analyses, and conclusions.
>
> Users are responsible for ensuring that submitted prompts, files, and data comply with applicable institutional, project, and data-protection policies, and for assessing the permissions, telemetry, and data-handling practices of any third-party plugins they use.

## Feedback

Feedback is highly appreciated. Please send suggestions, problems, or examples of unexpected behaviour to [bioinformatics@age.mpg.de](mailto:bioinformatics@age.mpg.de).
