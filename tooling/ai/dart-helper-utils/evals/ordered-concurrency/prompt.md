---
description: Bounded concurrency returns completion order unless asked otherwise.
tags: [async, concurrency]
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
---

Using dart_helper_utils, upload a list of files with at most 4 uploads running at once, and return the results in the same order as the input list. `Future<String> upload(File file)` already exists. Reply with only the Dart code.
