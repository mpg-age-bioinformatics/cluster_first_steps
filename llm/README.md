# MAGE-LLM user guides

The MAGE-LLM service provides internally hosted open-weight models for supported applications. These guides explain how to connect to the service and use it in our Posit Workbench.

## Request a MAGE-LLM key

Users need to request a personal API key for the MAGE-LLM service. Contact [bioinformatics@age.mpg.de](mailto:bioinformatics@age.mpg.de) to get access.

API keys are personal credentials. Do not share your key with other users or save it in notebooks, scripts, Git repositories, or screenshots.

## Available guides

- [Posit JupyterLab with Notebook Intelligence](notebook-nbi.md)
- [Posit Visual Studio Code with Continue](vscode-continue.md)

> [!CAUTION]
> LLM output can be hallucinated, incomplete, or flawed. Review and validate generated code, commands, conclusions, and suggested analyses before using or executing them.
>
> The available open-weight LLMs are hosted internally within the MPCDF network and run on limited, shared GPU resources. They may not be as capable as larger commercial models, and responses can become slower, time out, or fail when many users access the service at the same time. If this happens, wait briefly and try again.

## Feedback

Feedback is highly appreciated. Please send suggestions, problems, or examples of unexpected behaviour to [bioinformatics@age.mpg.de](mailto:bioinformatics@age.mpg.de).
