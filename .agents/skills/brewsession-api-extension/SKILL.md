---
name: brewsession-api-extension
description: Extend BrewKit's BrewSession Swift API for Homebrew built-in commands with typed async APIs, structured models, bilingual doc comments, BrewSessionError error handling, focused tests, and synchronized TODO tracking in TodoLists/BrewSession-TODO.md. Use when adding or updating BrewSession command wrappers, mapping brew commands to Swift APIs, modeling brew JSON output, updating built-in command coverage, or validating BrewKit session behavior.
---

# BrewSession API Extension

## Core Workflow

1. Inspect existing patterns before editing:
   - `Sources/BrewKit/BrewSession/*`
   - `Sources/BrewKit/BrewModels/*`
   - `Tests/BrewKitTests/*`
2. Read `TodoLists/BrewSession-TODO.md` to identify the current coverage state and the exact built-in command forms being added or changed.
3. Confirm command behavior from the most local reliable source first:
   - Run `brew commands` for the built-in command list when Homebrew is available.
   - Use `brew help <command>` and the Homebrew manpage for flags and output details.
4. Choose the API shape:
   - Add a strong typed `BrewSession` method for common, user-facing workflows.
   - Use or extend `BrewBuiltinCommand` for generic built-in command coverage.
   - Prefer structured return types when the command has stable `--json` or `--json=v2` output.
5. Add or update models in `Sources/BrewKit/BrewModels` only when the API returns structured data.
6. Add or update command APIs in `Sources/BrewKit/BrewSession/BrewSession+Command+<Name>.swift`.
7. Add focused tests in `Tests/BrewKitTests`, reusing `MockCommandRunner` for command execution behavior.
8. Update `TodoLists/BrewSession-TODO.md` in the same change:
   - Mark newly supported command forms as `[x]`.
   - Add newly discovered built-in command forms as `[ ]`.
   - Keep descriptions short and aligned with the implemented API behavior.
   - Update the `更新时间` value when the TODO file changes.

## API Rules

- Use `async` methods for every API that launches a brew process.
- Use synchronous helpers only for pure local work such as argument construction, parsing, and lightweight getters.
- Expose typed errors with `throws(BrewSessionError)` on public APIs that can fail.
- Reuse `runCommand(args:)` and `streamCommand(args:)` as execution primitives.
- Return structured model types instead of raw strings when output shape is stable.
- Keep raw `BrewCommandResult` returns for commands whose output is primarily human-readable or pass-through.
- Preserve existing naming style, overload shape, access control, and test style.

## Documentation Rules

- Document public APIs with bilingual comments.
- Put English first and Chinese second.
- Keep comments factual: describe command behavior, parameters, return value, and notable error conditions.
- Avoid broad Homebrew explanations that can drift from the actual implementation.

## Test Rules

- Cover argument construction and command mapping.
- Cover JSON parsing and model decoding when structured output is introduced.
- Cover error mapping with `BrewSessionError` when behavior changes.
- Confirm `TodoLists/BrewSession-TODO.md` reflects every supported command form added or changed.
- Use targeted tests first:

```bash
swift test --filter <TargetedTests>
```

- Run `swift build` after implementation.
- Run full `swift test` when changes touch shared parsing, command execution, or public model contracts.

## Commit Guidance

Only create commits when the user asks for git work. If committing, keep commits scoped:

- `feat(models): add <ModelName> for <purpose>`
- `feat(session): add <apiName> for brew <command>`
- `test(session): cover <apiName> behavior and mapping`
