# AI Efficiency Router

## Purpose

This document is a practical routing guide for turning plain-language requests into strong prompts,
and for deciding when to use Codex, Gemini, NotebookLM, or a simple manual workflow.

It is written for one goal:

- reduce wasted tokens
- reduce tool confusion
- improve completion quality
- make model selection explicit

## Core rule

Do not start by asking "which model is strongest?"

Start by asking:

1. What is the output?
2. What context is needed?
3. Does the task require tools, files, code, web search, or structured sources?
4. Is this a writing task, a research task, a coding task, or a synthesis task?

## Plain-language to prompt compiler

When you only know the task in everyday language, first normalize it into four parts:

```text
目标：
我要最终得到什么结果？

背景：
这个任务依赖哪些文件、文档、资料、链接或限制？

要求：
要注意什么边界？比如最小改动、中文输出、适合飞书、适合 GitHub、要不要表格、要不要代码。

交付：
最终要交给我的格式是什么？例如文档、清单、脚本、汇总、表格、邮件、PR 说明。
```

## Best prompt skeleton

```text
目标：
<一句话说明最终结果>

背景：
<任务来源、当前状态、相关文件、资料入口、上下游限制>

要求：
- 先读取现有上下文
- 优先最小改动
- 不重写无关部分
- 如果会影响配置或环境，先备份
- 命令解释用中文

交付：
- 直接给成品
- 说明改了什么
- 说明如何验证
```

## Task routing

### Use Codex when

- you need local files
- you need terminal commands
- you need Git, GitHub, or CLI tools
- you need edits, scripts, config, or repo work
- you need end-to-end execution instead of just a chat answer

### Use Gemini when

- you need fast drafting inside Google tools
- you need to work against Gmail, Drive, Docs, Sheets, or Search-heavy tasks
- you want reusable personal assistants through Gems
- you want large-context reading or file analysis without setting up local tooling
- you need quick synthesis from uploaded files rather than code execution

### Use NotebookLM when

- you have a bounded set of source materials
- you want citation-backed synthesis
- you want study guides, FAQ, briefing docs, audio overviews, or video overviews
- you care more about source-grounded understanding than tool execution

### Use a manual workflow when

- the task is tiny
- the task is sensitive and you do not want AI touching the source
- the output is obvious enough that writing a prompt would take longer than doing it directly

## Recommended division of labor

### Codex

- code changes
- repo setup
- local automation
- config management
- Git and GitHub work
- structured document production when files and tools matter

### Gemini

- first-draft writing
- rewrite and tone conversion
- Google Docs and Sheets assistance
- quick analysis of uploaded files
- reusable personal task bots via Gems
- Google Search-connected synthesis

### NotebookLM

- project source digestion
- source-grounded Q and A
- meeting packet synthesis
- training material compression
- audio and video overviews from source packs

## How to use Gemini efficiently

If your other quota is gone, Gemini is still useful, but only if you stop using it as a generic chatbot.

Use it as one of these:

1. A writing engine
2. A Google Workspace co-pilot
3. A research collector
4. A source-pack analyst
5. A reusable prompt shell through Gems

### Best Gemini use cases for you

#### 1. Deep Research for bounded research tasks

Good for:

- "帮我研究某个市场主题并整理成简报"
- "帮我对比几个工具并输出结论"
- "从 Drive 和 Search 中汇总这个主题"

Do not use it for:

- repo edits
- local terminal automation
- multi-file code changes

#### 2. Gems for repeatable personal workflows

Build Gems for:

- 飞书文档整理助手
- 会议纪要压缩助手
- 电商产品资料整理助手
- 邮件回复和润色助手

Your Gem should contain:

- role
- scope
- tone
- forbidden behaviors
- output format

#### 3. Docs and Sheets productivity

Use Gemini in Docs for:

- outline generation
- first draft creation
- rewrite by audience
- shortening and polishing
- executive summaries

Use Gemini in Sheets for:

- table design
- column planning
- formula drafting
- data cleanup ideas
- quick summarization of spreadsheet content

#### 4. File analysis

Upload:

- PDFs
- spreadsheets
- screenshots
- long docs
- NotebookLM notebooks

Then ask for:

- key points
- gaps
- action items
- decision summaries
- comparison tables

## How not to waste Gemini quota

- Do not use it for broad open-ended chatting.
- Do not paste huge context if a file upload would do.
- Do not ask for code execution it cannot perform.
- Do not repeatedly re-explain the same project; create a Gem or use NotebookLM.
- Do not mix writing, research, and operations in one thread.

## Gemini prompt patterns that work

### Writing prompt

```text
角色：你是我的文档整理助手。
目标：把下面内容整理成适合飞书或 Google Docs 的正式文档。
要求：
- 标题清晰
- 去掉重复
- 保留结论
- 输出适合直接发布
交付：
- 正文
- 3 条摘要
```

### Research prompt

```text
角色：你是我的研究助理。
目标：基于我上传的文件和 Google Search，生成一份中文研究摘要。
要求：
- 只保留和目标直接相关的信息
- 结论先行
- 标出不确定点
- 如果来源冲突，明确说明
交付：
- 结论摘要
- 关键证据
- 后续建议
```

### Spreadsheet prompt

```text
角色：你是我的数据整理助手。
目标：帮我把这份表格整理成可执行的工作表结构。
要求：
- 给出表头建议
- 给出字段说明
- 给出必要公式
- 适合团队后续维护
交付：
- 推荐表结构
- 公式建议
- 使用说明
```

## Workflow for "I only know it in plain words"

When your request is vague, use this adapter:

```text
我先用大白话说需求，请你先不要直接做内容。
请先把我的需求编译成一份高质量提示词。

要求：
- 补齐目标、背景、约束、交付
- 去掉歧义
- 如果适合 Codex，就输出 Codex 版本
- 如果适合 Gemini，就输出 Gemini 版本
- 如果适合 NotebookLM，就输出 NotebookLM 版本
- 每个版本都要告诉我为什么这样写
```

## Your personal default stack

Based on your current workflow, the practical stack is:

1. Codex for execution
2. Gemini for drafting and Workspace-native work
3. NotebookLM for source-grounded learning and compression
4. Git repo for saving templates and workflows

## Decision table

| Task | Best tool | Why |
|---|---|---|
| 改代码、改配置、跑命令 | Codex | Has terminal and file execution |
| 起草文档、润色、换语气 | Gemini | Fast drafting and rewriting |
| 读一堆资料并做带依据总结 | NotebookLM | Source-grounded outputs with citations |
| 做 Git 提交、推送、脚本自动化 | Codex | Local environment control |
| 对 Drive/Docs/Sheets 里的内容快速整理 | Gemini | Native Google workflow advantage |

## Final rule

Use one model for one job.

Do not ask one assistant to be:

- researcher
- coder
- operator
- writer
- analyst

all at once.

Split the work, and your quality will go up while token waste goes down.
