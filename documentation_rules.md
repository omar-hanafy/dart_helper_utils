# Rules for Creating or Modifying Documentation

## The Prime Directive

The README is a contract. If it says A, the code delivers A. Any deviation is a critical bug that cascades through
dependent modules.

## CRITICAL: README Compliance is MANDATORY

### Module README Violations = Immediate Rejection

**STOP**: Before writing ANY code in a module:
1. Read the ENTIRE module README
2. Create a mental/actual checklist of ALL rules
3. Verify EVERY rule is followed, not just some

**Theme Module Special Enforcement** (`lib/core/themes/README.md`):
- ❌ Using `theme.colorScheme.primary` when README shows `theme.primary` = VIOLATION
- ❌ Using `theme.textTheme.bodyMedium` when README shows `theme.bodyMedium` = VIOLATION  
- ❌ Using `Positioned` instead of `PositionedDirectional` = VIOLATION
- ❌ Using `.withOpacity()` instead of `.setOpacity()` = VIOLATION
- Every example in the README is a REQUIREMENT, not a suggestion

**Violations Include**:
- Partial compliance (following 3 of 5 rules) = FAILURE
- "Mostly correct" = INCORRECT
- Tunnel vision on one aspect while ignoring others = UNACCEPTABLE

**The Test**: Can another developer point to ANY line in the README and find your code violating it? If yes, you failed.

## Core Philosophy

- **Audience**: AI agents and developers who need to integrate NOW
- **Purpose**: Enable perfect integration without reading source code
- **Mindset**: Every token costs money; every ambiguity costs hours

## The Non-Negotiables

### 1. Information Density Rules

- **Token Budget**: README must be <30% of public API code size
- **Pattern Compression**: Group similar functions → `validate[Url|Email|Phone](str) → bool`
- **Type Fusion**: Constraints go IN the type → `port: int[1-65535]` not "port must be between..."
- **Zero Fluff**: No restating names, no explaining obvious functions

### 2. Required Information (For Every Public API)

- **Signature**: Exact, copy-pasteable function signature
- **Constraints**: Every parameter's type, range, format, structure
- **Returns**: All possible states (success/failure/async)
- **Errors**: Every exception/error with exact trigger conditions
- **Side Effects**: File I/O, network calls, state mutations, or "None"
- **Examples**: Minimal, runnable code showing actual I/O

### 3. Forbidden Content

- **No Implementation**: Zero algorithm details, internal logic, private members
- **No Human Formatting**: No **, //, ###, tables, decorative elements
- **No Redundancy**: Don't explain what names already convey
- **No Ambiguity**: Ban "might", "usually", "typically" - behavior is deterministic

### 4. Pattern Optimization

When documenting repetitive patterns:

```
# Good:
parse[Json|Xml|Yaml](input: str) → dict | throws ParseError
All accept UTF-8, return normalized dicts, fail on malformed input

# Bad:
parseJson(input) - parses JSON strings
parseXml(input) - parses XML strings  
parseYaml(input) - parses YAML strings
```

### 5. Critical Specifications

For each function, explicitly state:

- **Async Nature**: `→ Promise<T>`, `→ async generator`, or synchronous
- **Concurrency**: Thread-safe, not thread-safe, read-safe only
- **Performance**: O(n), breaks at >1MB input, etc.
- **Dependencies**: External libs with versions, required imports
- **Platform**: OS/runtime constraints if any

### 6. Example Requirements

- Must be executable as-is (given imports)
- Show both success and failure paths
- Include actual output in comments

```
result = api.process("data")  # → {"status": "ok", "count": 42}
api.process(None)  # throws ValueError: input required
```

### 7. Validation Checklist

Before committing, verify:

- [ ] Can I reconstruct working code from README alone?
- [ ] All constraints embedded in type definitions?
- [ ] Every error condition documented with a trigger?
- [ ] Examples run without modification?
- [ ] Side effects explicitly stated (even if "None")?
- [ ] Token count under 30% budget?
- [ ] Zero implementation details leaked?
- [ ] No human-comfort formatting present?

## Enforcement

- **PR Gate**: API changes without README updates = automatic rejection
- **CI Check**: README validation part of the build pipeline
- **Break on Failure**: Out-of-sync docs = broken build

## Last Note:
- For dart extension and similar No need to mention the name of the extension as its not used by anyway for users, until there is a static memeber it must be accessed throught the extension name, other than that it will be accessed by the member e.g. String this extension on.

## The Bottom Line

Write docs like you're paying per token, and debugging costs $1000/hour. Because you are.

Bad README → Wrong expectations → Broken integration → Wasted days → Dead project

Good README → Copy, paste, works → Ship it → Next task

Choose wisely.
