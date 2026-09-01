# Using your MAGE-LLM key with Python

[Back to the MAGE-LLM user guides](README.md)

The MAGE-LLM API is available from within the MPCDF network. Before starting, request a personal `MAGE-LLM-KEY` as described in the [user-guide overview](README.md#request-a-mage-llm-key).

## Python example

The Python example requires the `openai` package to be installed.

Set the `MAGE-LLM-KEY` environment variable, or add your personal key between the quotation marks on the `mage_llm_key` line. The following example asks the model to analyse a short list of numbers:

```python
import os

from openai import OpenAI

mage_llm_key = os.environ.get("MAGE-LLM-KEY") or ""  # <your MAGE-LLM-KEY>

numbers = [12, 18, 7, 21, 15]

client = OpenAI(
    base_url="https://gpu.bioinformatics.studio/v1",
    api_key=mage_llm_key,
)

response = client.chat.completions.create(
    model="qwen36-27b",
    messages=[
        {
            "role": "user",
            "content": (
                f"Given the numbers {numbers}, write Python code to calculate "
                "their minimum, maximum, and mean. Briefly explain the result."
            ),
        }
    ],
)

print(response.choices[0].message.content)
```

## List available models

### curl

```bash
curl https://gpu.bioinformatics.studio/v1/models \
  -H "Authorization: Bearer <your MAGE-LLM-KEY>"
```

### Python

Using the `client` configured in the Python example above:

```python
models = client.models.list()

for model in models:
    print(model.id)
```

Do not share your `MAGE-LLM-KEY`. Always review and validate generated code and results.
