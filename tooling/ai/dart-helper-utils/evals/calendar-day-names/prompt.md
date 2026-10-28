---
description: A 7.x date question; the answer must use the 7.0 names, not the 6.x ones.
tags: [use, dates, renames]
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
---

My Flutter app depends on dart_helper_utils ^7.0.0. Write a Dart function `bool isDueTomorrow(DateTime due, DateTime now)` that returns true when `due` falls on the calendar day after `now`. Use the package's DateTime helpers instead of comparing year, month, and day by hand. Reply with only the code.
