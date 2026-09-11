# Template Design Review

Audits every shipping template in `templates/` against the anti-slop rules
from the `frontend-dev` skill, so choosing a template for a real video is
deliberate rather than guesswork.

## Signal counts

For each template, signal counts are lifted directly from the template's
HTML/CSS (lower is better). Banned by the design skill:

- `black`: pure `#000` / `background: black`
- `inter`: Inter or Inter Tight
- `purple`: `#7c5cff` / `#a78bfa` / `#8b5cf6` / `#a855f7` / `#6366f1` / `#3b82f6`
- `glow`: box-shadow with cyan/blue, drop-shadow, text-shadow
- `huge`: `font-size: NN0px` ≥ 100 or `clamp(..., NN0px)` ≥ 100

`✅` = zero signals across all five. `⚠️` = 1–2. `❌` = 3 or more.

## Summary (22 of 23 audited; `frame-data-rollup` lacks `source/index.html`)

| Template | black | inter | purple | glow | huge | Verdict |
|----------|------:|------:|-------:|-----:|-----:|:-------:|
| frame-data-chart-nyt | 0 | 0 | 0 | 0 | 0 | ✅ |
| frame-decision-tree | 0 | 0 | 0 | 0 | 0 | ✅ |
| frame-kinetic-type | 0 | 0 | 0 | 0 | 0 | ✅ |
| frame-nyt-graph | 0 | 0 | 0 | 0 | 0 | ✅ |
| frame-play-mode | 0 | 0 | 0 | 0 | 0 | ✅ |
| frame-product-promo | 0 | 0 | 0 | 0 | 0 | ✅ |
| frame-product-promo-30s | 0 | 0 | 0 | 0 | 0 | ✅ |
| frame-swiss-grid | 0 | 0 | 0 | 0 | 0 | ✅ |
| frame-takram-organic | 0 | 0 | 0 | 0 | 0 | ✅ |
| frame-vignelli | 0 | 0 | 0 | 0 | 0 | ✅ |
| frame-warm-grain | 0 | 0 | 0 | 0 | 0 | ✅ |
| frame-bold-poster | 0 | 0 | 0 | 0 | 2 | ⚠️ |
| frame-bold-signal | 0 | 0 | 0 | 0 | 1 | ⚠️ |
| frame-creative-voltage | 0 | 0 | 0 | 0 | 2 | ⚠️ |
| frame-electric-studio | 0 | 0 | 0 | 0 | 1 | ⚠️ |
| frame-glitch-title | 0 | 0 | 0 | 0 | 3 | ⚠️ |
| frame-build-minimal | 0 | 1 | 0 | 0 | 1 | ⚠️ |
| vfx-text-cursor | 0 | 2 | 0 | 1 | 1 | ⚠️ |
| frame-light-leak-cinema | 2 | 0 | 0 | 0 | 0 | ⚠️ |
| frame-pentagram-stat | 3 | 0 | 0 | 0 | 2 | ⚠️ |
| frame-liquid-bg-hero | 0 | 3 | 2 | 0 | 1 | ⚠️ |
| frame-logo-outro | 0 | 3 | 5 | 2 | 0 | ⚠️ |

Counts (v3.0.0 rules): **11 ✅ / 9 ⚠️ / 2 ❌**.

> ### ⚠️ v3.1.0 修正 (2026-09-12, Wallance-directed)
>
> UNIQorn Design Guide 已从 v3.0.0 升到 **v3.1.0**。关键变化：**灵性符号
> (水晶 / 月亮 / 塔罗 / 独角兽) 不再是品牌违禁品**，它们是 UNIQorn 的品牌
> 词汇。被禁的只剩"视觉俗气执行"：紫银河**背景**、整图金粉、恐怖、宗教、
> 儿童卡通、通用 wellness stock 素材、拥挤。
>
> 直接影响本表的两个 ❌ 判定：
>
> | Template | v3.0.0 | v3.1.0 | 原因 |
> |---|:---:|:---:|---|
> | `frame-liquid-bg-hero` | ❌ | **⚠️** | `#7c5cff` / `#a78bfa` 是**强调色**，不是紫银河背景 → 不再是品牌违规；剩 Inter + 128px 大标题两个通用质量问题 |
> | `frame-logo-outro` | ❌ | **⚠️** | 同上；紫 logo 是品牌色，不再违规；剩 Inter + text-shadow glow 两个通用质量问题 |
>
> 所以 v3.1.0 口径下应为 **11 ✅ / 11 ⚠️ / 0 ❌**。
>
> **注意**：上表的 ⚠️ 是**通用设计质量**信号 (来自 `frontend-dev` skill：
> 纯黑 / Inter / 高饱和 / glow / 超大标题)，不是品牌违规。品牌违规只有
> 一份清单，在 `uniqorn-design-guide/references/05-negative-prompts.md`。
> 别把两者混为一谈——这正是我 v3.0.0 时犯的错。

## Aspect coverage

None of the templates ship native 9:16 support. Every source HTML hardcodes
`1920px × 1080px` viewport in CSS. The `fix/vars-aspect-duration` patch
makes `--aspect 9:16` change the canvas the renderer writes to
(`1080×1920`), but it does NOT reflow the template — text bleeds off the
right edge, columns overflow, motion timings assume 16:9.

Two ways forward:

1. Pick templates that are visually tolerant of a square-ish crop (warm
   grain, liquid bg hero, light leak cinema) and post a landscape video
   in a portrait slot. Faster, no per-template work.
2. Rewrite the template CSS to use `aspect-ratio` and flexible units.
   30–90 min per template.

I recommend (1) for the first batch and (2) only for the templates that
prove worth keeping.

## Recommended pick for an atmosphere / healing short

For a single-image short that needs to feel calm and editorial, start
with **`frame-warm-grain`**. It is the only ✅ template that pairs warm
color grading with text capacity (`title` / `subtitle` on the intro
composition). Render in 16:9 for landscape posts; for 9:16 the title
card reflows naturally because the composition is centered with left
padding, not column-counted.

If the brief needs a punchline, **`frame-kinetic-type`** is the next
pick — ✅, large display type, supports `title` / `subtitle` injection on
both layouts. Same caveat: render in 16:9 unless you take the CSS
reflow pass.

## Notes per ❌ template

### frame-liquid-bg-hero

- Inter Tight + Noto Sans SC are loaded on `body`. Switch the display
  face to **Outfit** (the skill recommends Geist / Outfit / Satoshi).
- Accent `#a78bfa` and `#7c5cff` are the literal "AI purple" the skill
  calls out. For a healing/wellness brand, the **Brand Override**
  palette is orange `#d97757`, blue `#6a9bcc`, green `#788c5d` on
  dark `#141413` or light `#faf9f5`.
- Headline is 128px on a 1920-wide canvas (~6.7% width). Skill cap is
  `text-6xl` (~60–72px) on similar surfaces — drop to `text-6xl` or
  `text-7xl` (max 96px) and rely on `tracking-tighter` for emphasis.

### frame-logo-outro

- Same Inter Tight + `#7c5cff` problem, plus two text-shadow / drop-shadow
  glows on the `shimmer` element. The cleanest version of this template
  is a dark logo on a dark background with NO shimmer — let the mark do
  the work. Glow and shimmer together read as "AI generated demo" rather
  than a brand sign-off.

## What this audit does not cover

- **Motion quality.** A template can pass the static audit and still be
  motion-cliché (perpetual floating blobs, infinite marquees, etc.).
  Watch the rendered video, not just the still.
- **Accessibility.** `prefers-reduced-motion` handling is not checked
  here. The skill requires it (2.6) and several templates skip it.
- **Brand fit.** A ✅ template can still be off-brand. This audit is
  necessary, not sufficient.

## Reproduce

```bash
cd templates && for d in */; do
  [ "$d" = "NOTICE.md" ] && continue
  files=$(find "$d" -name "*.html" 2>/dev/null)
  [ -z "$files" ] && continue
  total=$(grep -oiE "(background(-color)?\s*:\s*#000\b|#000000|background:\s*black|Inter(\+Tight)?[:, ]|#(7c5cff|a78bfa|8b5cf6|a855f7|6366f1|3b82f6)|box-shadow\s*:\s*[^;]*rgba?\([0-9]+,[0-9]+,255|filter\s*:\s*drop-shadow|text-shadow|font-size\s*:\s*[0-9]{3,}px|clamp\([0-9]+px,[0-9.]+vw,[0-9]{3,}px\))" $files | wc -l)
  printf "%-26s %s\n" "${d%/}" "$([ "$total" -eq 0 ] && echo "✅ clean" || ([ "$total" -le 2 ] && echo "⚠️  light ($total)" || echo "❌ heavy ($total)"))"
done
```
