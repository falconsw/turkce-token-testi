# Counts tokens offline with open tokenizer files from Hugging Face (no API, no account).
# Run: uv run --with tokenizers --with tiktoken --with huggingface_hub scripts/count_open.py
import json
from pathlib import Path

import tiktoken
from huggingface_hub import hf_hub_download
from tokenizers import Tokenizer

ROOT = Path(__file__).resolve().parent.parent
TR = (ROOT / "data/tr.txt").read_text()
EN = (ROOT / "data/en.txt").read_text()

OPEN_MODELS = {
    "DeepSeek V3.2": "deepseek-ai/DeepSeek-V3.2",
    "MiniMax M2": "MiniMaxAI/MiniMax-M2",
    "Qwen3": "Qwen/Qwen3-8B",
}


def row(name, tr, en):
    print(f"{name:<22} {tr:>5} {en:>5} {100 * (tr / en - 1):>+6.0f}%")
    return {"tr": tr, "en": en}


print(f"{'model':<22} {'tr':>5} {'en':>5} {'diff':>7}")
results = {}
for name, repo in OPEN_MODELS.items():
    tok = Tokenizer.from_file(hf_hub_download(repo, "tokenizer.json"))
    count = lambda s: len(tok.encode(s, add_special_tokens=False).ids)
    results[name] = row(name, count(TR), count(EN))

# OpenAI's GPT-5.x / o1 / o3 tokenizer; matches platform.openai.com/tokenizer.
enc = tiktoken.get_encoding("o200k_base")
results["GPT (o200k_base)"] = row("GPT (o200k_base)", len(enc.encode(TR)), len(enc.encode(EN)))

print("\nHow Turkish words are split (o200k_base):")
for word in ["gecikeceğini", "kaybolmasın", "yapmalıyım", "değişiklikler", "delayed", "changes"]:
    print(f"  {word:<15} " + "|".join(enc.decode([t]) for t in enc.encode(" " + word)).strip())

(ROOT / "results").mkdir(exist_ok=True)
(ROOT / "results/open.json").write_text(json.dumps(results, ensure_ascii=False, indent=2))
