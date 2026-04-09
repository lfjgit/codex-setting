# Prompt Compiler

## Purpose

This file is for one specific workflow:

You describe a task in plain language.
The AI does not execute it immediately.
The AI first compiles your request into a strong prompt.

This reduces:

- ambiguity
- wasted tokens
- tool confusion
- wrong model selection
- low-quality first attempts

## Core idea

Do not ask the AI to jump directly from vague intent to final execution.

Use a middle step:

1. You speak naturally.
2. The AI extracts structure.
3. The AI rewrites your request into a high-quality prompt.
4. Then you choose which model or tool should run it.

## What the compiler should produce

A good compiled prompt should include:

- objective
- background
- constraints
- output format
- model/tool fit
- risk notes if needed

## The default compiler instruction

Use this when your request is still vague:

```text
我先用大白话说需求，请你先不要直接做。
请先把我的需求编译成一份高质量提示词。

要求：
- 先提炼目标
- 补齐必要背景
- 明确限制条件
- 明确交付格式
- 去掉歧义和废话
- 如果信息不足，先列出缺口
- 根据任务类型，给出最适合 Codex、Gemini、NotebookLM 的版本
- 每个版本都说明适用原因
```

## Compilation stages

### Stage 1: normalize the request

Convert plain language into:

```text
目标：
最终想得到什么？

背景：
依赖哪些资料、文件、上下文、限制？

要求：
有哪些边界？例如中文、最小改动、适合飞书、适合 GitHub、不能删改等。

交付：
最后要给我的形式是什么？例如摘要、脚本、表格、文档、邮件、PR 说明。
```

### Stage 2: detect task type

Classify into one of these:

- coding
- writing
- research
- operations
- analysis
- spreadsheet/data
- document synthesis

### Stage 3: choose the execution path

Pick the best tool:

- Codex for execution and local tooling
- Gemini for drafting and Google-native work
- NotebookLM for source-grounded synthesis

### Stage 4: generate the final prompt

The final prompt should be ready to paste into the selected tool without extra editing.

## Prompt quality checklist

Before accepting a compiled prompt, check:

- Is the goal concrete?
- Is the scope bounded?
- Is the output format explicit?
- Are the constraints visible?
- Does it fit the selected tool?
- Is anything essential still missing?

## Compiler output format

When the AI compiles a request, ask it to return this structure:

```text
任务理解：
<一句话概括任务>

关键信息：
- <要点 1>
- <要点 2>
- <要点 3>

信息缺口：
- <还缺什么，如果没有则写“无”>

推荐工具：
- <Codex / Gemini / NotebookLM>

编译后的提示词：
<最终可直接使用的高质量提示词>

为什么这样编排：
- <简短说明>
```

## Best prompt templates by tool

### Codex version

```text
目标：
<最终结果>

背景：
<相关文件、仓库、文档、当前状态>

要求：
- 先读取现有上下文
- 优先最小改动
- 不改无关部分
- 如会影响配置或环境，先备份
- 命令解释用中文

交付：
- 直接给结果
- 说明改了哪些文件
- 说明验证方式
```

### Gemini version

```text
角色：
你是我的内容整理和草稿编写助手。

目标：
<最终结果>

背景：
<资料来源、受众、语境、限制>

要求：
- 去掉歧义和重复
- 结构清晰
- 语言自然
- 如果资料不足，先指出不足

交付：
- 最终正文
- 3 条摘要
- 如果合适，附一个目录
```

### NotebookLM version

```text
目标：
基于我提供的资料，生成一个有依据的总结。

要求：
- 只使用提供的资料
- 结论先行
- 标出关键证据
- 标出不确定点

交付：
- 摘要
- 关键结论
- 可追问的问题
```

## Everyday compiler prompts

### 1. General plain-language request

```text
下面是我用大白话描述的需求。
请不要直接做内容。
先把它编译成一份高质量提示词。

要求：
- 提炼目标
- 补齐背景
- 明确约束
- 明确交付格式
- 判断更适合 Codex、Gemini 还是 NotebookLM
- 输出可以直接复制使用的版本
```

### 2. Coding request compiler

```text
下面是一个代码需求，请先不要写代码。
请先把它编译成给 Codex 使用的高质量提示词。

要求：
- 明确目标
- 明确涉及文件或模块
- 明确约束和风险
- 明确验证方式
- 优先最小改动
```

### 3. Writing request compiler

```text
下面是一个写作需求，请先不要写正文。
请先把它编译成给 Gemini 使用的高质量提示词。

要求：
- 明确受众
- 明确语气
- 明确结构
- 明确输出格式
```

### 4. Research request compiler

```text
下面是一个研究需求，请先不要给结论。
请先把它编译成适合研究型 AI 使用的高质量提示词。

要求：
- 明确研究范围
- 明确证据要求
- 明确不确定项处理方式
- 明确输出形式
```

## Bad vs good examples

### Bad

```text
帮我整理一下这个东西。
```

Problems:

- no goal
- no scope
- no output format
- no audience

### Good

```text
目标：
把这份会议纪要整理成适合飞书发布的正式总结。

背景：
受众是产品团队和老板，原始内容有重复和口语表达。

要求：
- 保留结论和行动项
- 去掉重复
- 用中文
- 适合直接发布

交付：
- 正文
- 3 条摘要
- 行动项清单
```

## Personal rule for your workflow

For your own use, the best default is:

1. Speak naturally first
2. Ask AI to compile the prompt
3. Confirm the compiled prompt
4. Only then execute

This is slower by one step, but usually saves tokens over the whole task because it avoids bad first attempts.

## Final shortcut

If you want one reusable command sentence, use this:

```text
我先用大白话说需求，请你先把它编译成一份可直接执行的高质量提示词，并根据任务类型分别给出 Codex、Gemini、NotebookLM 版本。
```
