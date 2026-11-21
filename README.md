# Türkçe sormak daha mı pahalı? · Is asking in Turkish more expensive?

[Türkçe](#türkçe) · [English](#english)

---

## Türkçe

Aynı on günlük soruyu Türkçe ve İngilizce yazdık, yedi yapay zekada token saydık. Yapay zeka şirketleri ücreti token başına alır ve fiyat dile göre değişmez. Bu yüzden aynı soru için fazladan çıkan token, aynı oranda fazla ödeme demek.

İki metin neredeyse aynı uzunlukta: Türkçe 1073 karakter (148 kelime), İngilizce 1088 karakter (202 kelime). Türkçede kelime sayısı daha az, ama ekler yüzünden token sayısı daha fazla.

### Sonuçlar (21 Kasım 2026)

| Model | Nasıl ölçüldü | Türkçe | İngilizce | Türkçe fazlası |
| --- | --- | ---: | ---: | ---: |
| Gemini 4 Hydrogen | Gemini CLI 0.67.0 (`-m gemini-4-hydrogen`) | 289 | 243 | **+%19** |
| Gemini 3.8 Flash | Gemini CLI 0.67.0 (`-m gemini-3.8-flash`) | 296 | 244 | +%21 |
| Grok 4.7 | Grok CLI 1.0.70 | 297 | 229 | +%30 |
| GPT-6 Astra | Codex CLI 0.171.0 | 304 | 227 | +%34 |
| Qwen3 | açık tokenizer (Qwen/Qwen3-8B) | 356 | 233 | +%53 |
| Claude Opus 5.5 · Sonnet 5.5 · Haiku 5.5 | Claude Code 2.1.314 | 562 | 339 | **+%66** |
| MiniMax M2 | açık tokenizer (MiniMaxAI/MiniMax-M2) | 404 | 230 | +%76 |
| DeepSeek V3.2 | açık tokenizer (deepseek-ai/DeepSeek-V3.2) | 430 | 232 | **+%85** |

Sayılar sorunun kendi token sayısı (girdi). Cevapların tokenları ölçülmedi.

### Neden?

Türkçe eklemeli bir dil. Tokenizer'lar çoğunlukla İngilizce metinle eğitildiği için bir Türkçe kelimeyi birkaç parçaya bölüyor, İngilizce kelimelerin çoğu ise tek parça kalıyor. OpenAI'ın tokenizer'ında (`o200k_base`):

| Kelime | Parçalar | Token |
| --- | --- | ---: |
| gecikeceğini | gec · ike · ce · ğini | 4 |
| kaybolmasın | kay · bol · mas · ın | 4 |
| yapmalıyım | yap · mal · ıy · ım | 4 |
| değişiklikler | değiş · iklik · ler | 3 |
| delayed | delayed | 1 |
| changes | changes | 1 |

### Yöntem

- **Kapalı modeller (Claude, GPT, Grok, Gemini):** Her modelin kendi CLI'ı kendi hesabımızla tek seferlik modda çalıştırıldı; API anahtarı kullanılmadı. Token sayısı CLI'ın bildirdiği gerçek kullanımdan (`usage`) alındı. CLI'lar her isteğe sabit bir sistem istemi eklediği için aynı komut bir de "hello" ile çalıştırıldı ve bu taban sonuçtan düşüldü. Modelin cevap yazmaması için metnin sonuna "Reply with exactly: OK" talimatı eklendi.
- **Açık modeller (DeepSeek, MiniMax, Qwen):** Hugging Face'teki resmi `tokenizer.json` dosyaları bilgisayarda çalıştırıldı.
- **Çapraz kontrol:** GPT sonucu, OpenAI'ın [Tokenizer sayfasıyla](https://platform.openai.com/tokenizer) aynı oranı veriyor (306 / 229, +%34); `scripts/count_open.py` de aynı sayıları buluyor. Gemini 4 Hydrogen sonucu, Google AI Studio'nun token sayacıyla (290 / 244) örtüşüyor. Claude ölçümü tekrarlandığında aynı sonucu verdi; Opus, Sonnet ve Haiku 5.5 aynı tokenizer'ı kullanıyor.

### Sınırlar

- Sorular günlük kullanımdan seçilmiş on örnek. Başka metinlerde oranlar değişebilir.
- Grok'un bağlamı çalıştırmalar arasında birkaç token oynuyor; iki ölçüm +%30 ve +%31 verdi.
- Gemini CLI'da model `-m` ile sabitlenmeli. İlk denemede (eski talimatla) CLI İngilizce metne fazladan token ekledi ve fark yanlış biçimde +%8 çıktı. Bu ölçüm kullanılmadı.
- Modeller ve tokenizer'lar güncellendikçe sonuçlar değişir. Tablo 21 Kasım 2026 tarihli.

### Sorular

| # | Türkçe | English |
| --- | --- | --- |
| 1 | Python'da bir listedeki tekrar eden elemanları sırayı bozmadan nasıl silerim? | How do I remove duplicate items from a list in Python without changing the order? |
| 2 | Son commit'imi geri almak istiyorum ama yaptığım değişiklikler kaybolmasın. Ne yapmalıyım? | I want to undo my last commit but keep the changes I made. What should I do? |
| 3 | Müşteriye teslim tarihinin bir hafta gecikeceğini nazik bir dille anlatan kısa bir e-posta yaz. | Write a short email that politely tells a customer the delivery date will be delayed by one week. |
| 4 | Aşağıdaki toplantı notlarını üç maddede özetle ve her maddenin sorumlusunu yaz: Ayşe tasarımı cuma gününe kadar bitirecek, Mehmet sunucu maliyetlerini çıkaracak, Can müşteriyle pazartesi görüşecek. | Summarize the meeting notes below in three bullet points and name the owner of each: Ayşe will finish the design by Friday, Mehmet will work out the server costs, Can will meet the client on Monday. |
| 5 | React uygulamamda sayfa her yenilendiğinde kullanıcı oturumu kapanıyor. Bunun olası nedenleri neler? | In my React app the user gets logged out every time the page is refreshed. What are the possible causes? |
| 6 | Evde kalan patates, yumurta ve soğanla yirmi dakikada yapabileceğim bir akşam yemeği öner. | Suggest a dinner I can make in twenty minutes with the potatoes, eggs and onions I have at home. |
| 7 | Siparişler tablosundan geçen ay en çok harcama yapan beş müşteriyi getiren bir SQL sorgusu yazar mısın? | Can you write an SQL query that returns the five customers who spent the most last month from the orders table? |
| 8 | Yapay zeka modellerinde token ne demek? On yaşındaki bir çocuğa anlatır gibi açıkla. | What does token mean in AI models? Explain it as if you were talking to a ten-year-old. |
| 9 | Haftada üç gün, günde kırk beş dakika çalışarak üç ayda temel seviyede İspanyolca öğrenmek için bir plan hazırla. | Make a plan to learn basic Spanish in three months by studying three days a week, forty-five minutes a day. |
| 10 | Bu cümleyi daha profesyonel hale getir: yarınki toplantıya gelemiyorum çünkü başka bir işim çıktı, sonra konuşuruz. | Make this sentence more professional: I can't come to tomorrow's meeting because something else came up, we'll talk later. |

Aynı sorular `data/questions.json` içinde; testte kullanılan birleşik metinler `data/tr.txt` ve `data/en.txt`.

### Kendin dene

```sh
# Açık modeller ve OpenAI tokenizer'ı (hesap gerekmez)
uv run --with tokenizers --with tiktoken --with huggingface_hub scripts/count_open.py

# CLI'lar (her birinde kendi hesabınla oturum açık olmalı)
scripts/count_cli.sh                      # kurulu olanların hepsi
scripts/count_cli.sh claude codex         # yalnız bunlar
GEMINI_MODEL=gemini-4-hydrogen scripts/count_cli.sh gemini
CLAUDE_MODEL=claude-sonnet-5-5 scripts/count_cli.sh claude
```

Her CLI çalıştırması hesabından az miktarda kullanım düşer (model yalnız "OK" yazar).

---

## English

We wrote the same ten everyday questions in Turkish and English and counted tokens in seven AI models. Providers charge per token, and the price does not depend on the language, so every extra token for the same question is the same share of extra cost.

Both texts are almost the same length: Turkish 1,073 characters (148 words), English 1,088 characters (202 words). Turkish has fewer words but more tokens, because of its suffixes.

### Results (21 November 2026)

| Model | Measured with | Turkish | English | Turkish extra |
| --- | --- | ---: | ---: | ---: |
| Gemini 4 Hydrogen | Gemini CLI 0.67.0 (`-m gemini-4-hydrogen`) | 289 | 243 | **+19%** |
| Gemini 3.8 Flash | Gemini CLI 0.67.0 (`-m gemini-3.8-flash`) | 296 | 244 | +21% |
| Grok 4.7 | Grok CLI 1.0.70 | 297 | 229 | +30% |
| GPT-6 Astra | Codex CLI 0.171.0 | 304 | 227 | +34% |
| Qwen3 | open tokenizer (Qwen/Qwen3-8B) | 356 | 233 | +53% |
| Claude Opus 5.5 · Sonnet 5.5 · Haiku 5.5 | Claude Code 2.1.314 | 562 | 339 | **+66%** |
| MiniMax M2 | open tokenizer (MiniMaxAI/MiniMax-M2) | 404 | 230 | +76% |
| DeepSeek V3.2 | open tokenizer (deepseek-ai/DeepSeek-V3.2) | 430 | 232 | **+85%** |

These are the tokens of the question itself (input). Answer tokens were not measured.

### Why?

Turkish is agglutinative. Tokenizers are trained mostly on English, so they cut a Turkish word into several pieces while most English words stay whole. With OpenAI's `o200k_base`: "gecikeceğini" → gec · ike · ce · ğini (4 tokens), "kaybolmasın" → kay · bol · mas · ın (4), while "delayed" and "changes" are 1 token each.

### Method

- **Closed models (Claude, GPT, Grok, Gemini):** each model's own CLI, signed in with our own account, in single-prompt mode; no API key. Token counts come from the usage the CLI reports. Every CLI adds a fixed system prompt, so each command was also run with "hello" and that baseline was subtracted. A trailing "Reply with exactly: OK" keeps the model from answering.
- **Open models (DeepSeek, MiniMax, Qwen):** the official `tokenizer.json` files from Hugging Face, run locally.
- **Cross-checks:** the GPT result gives the same ratio as OpenAI's [Tokenizer page](https://platform.openai.com/tokenizer) (306 / 229, +34%), which `scripts/count_open.py` reproduces; the Gemini 4 Hydrogen result matches Google AI Studio's token counter (290 / 244). Claude gave identical numbers on a repeat run; Opus, Sonnet and Haiku 5.5 share one tokenizer.

### Limits

- Ten everyday questions; other texts can give different ratios.
- Grok's context varies by a few tokens between runs; two measurements gave +30% and +31%.
- Pin the Gemini CLI model with `-m`. A first attempt with an older instruction added extra tokens to the English text and wrongly showed +8%; it was discarded.
- Results change as models and tokenizers are updated. The table is dated 21 November 2026.

### Try it yourself

See the commands in [Kendin dene](#kendin-dene) above. Each CLI run uses a small amount of your account's quota (the model only replies "OK").
