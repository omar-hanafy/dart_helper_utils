---
description: Dot-path reads use getPath, not a guessed getNested.
tags: [use, maps]
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
---

Using dart_helper_utils, read db.pool.size from a nested Map<String, dynamic> called config as an int, falling back to 10 when it is missing or not a number. Reply with one line of Dart.
