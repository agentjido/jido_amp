# AGENTS.md - Jido.Amp AI Agent Instructions

## Project Overview

Jido.Amp is an amplified AI orchestration framework for the Jido ecosystem. It provides tools and agents for orchestrating complex AI workflows using the Amp coding agent SDK.

## Core Concepts

### Amp SDK Integration

The project integrates with the [Amp SDK](https://github.com/nshkrdotcom/amp_sdk) to:
- Define and execute orchestration workflows
- Manage tool definitions and execution
- Handle agent state and context management

### Error Handling

Use the `Jido.Amp.Error` module for all error types:
- **Invalid** errors for invalid input
- **Execution** errors for runtime failures
- **Config** errors for configuration issues
- **Internal** errors for unexpected failures

### Schema Validation

Core data structures use Zoi schemas for validation:
- All input validation is in the schema
- Struct builders use `new/1` and `new!/1` functions
- Never validate data in functions—validate at the schema level

## Project Structure

```
lib/
├── jido_amp.ex                    # Main module
├── jido_amp/
│   ├── application.ex             # Application supervisor
│   ├── error.ex                   # Error handling
│   └── orchestrator.ex            # Core orchestration logic
test/
├── support/                       # Test fixtures and helpers
└── jido_amp_test.exs             # Module tests
```

## Development Guidelines

### Adding New Modules

1. Create module under `lib/jido_amp/`
2. Add `@moduledoc` with clear description
3. Define Zoi schema for any structs
4. Add comprehensive `@doc` on all public functions
5. Create tests in `test/`

### Testing

- Tests go in `test/` with same directory structure
- Use descriptive test names
- Aim for >90% coverage
- Run `mix test --cover` to check coverage

### Documentation

- All public modules need `@moduledoc`
- All public functions need `@doc`
- Include examples in `@doc` strings
- Run `mix doctor --raise` before commits

## Common Commands

```bash
# Development
mix setup                 # Setup environment
mix test                  # Run tests
mix quality              # All quality checks
mix docs                 # Generate documentation

# Debugging
mix test --cover         # With coverage report
mix dialyzer            # Type checking
mix credo --strict      # Linting

# Git & Releases
git commit -m "feat: description"  # Conventional commit
mix git_ops.release                 # Create release
```

## Dependencies

### Core Ecosystem
- `zoi` - Schema validation
- `splode` - Error composition
- `req_llm` - LLM request handling
- `amp_sdk` - Amp orchestration SDK

### Development
- `ex_doc` - Documentation generation
- `doctor` - Documentation coverage
- `credo` - Linting
- `dialyxir` - Type checking
- `excoveralls` - Test coverage
- `git_ops` - Release automation

## Module Checklist for New Code

- [ ] Module has `@moduledoc`
- [ ] All public functions have `@doc` and `@spec`
- [ ] Error cases return `{:error, reason}` or raise
- [ ] Data structures use Zoi schemas
- [ ] Tests exist with >90% coverage
- [ ] No `IO.puts` (use `Logger` instead)
- [ ] No `jido_dep` helper functions
- [ ] Conventional commit message

## Amp Integration Patterns

When integrating with Amp SDK:
1. Define tool specifications following Amp conventions
2. Implement tool handlers that return structured results
3. Use orchestrator context to manage state
4. Handle errors gracefully with `Jido.Amp.Error` types
5. Document expected inputs/outputs

## Questions & Issues

- Check existing modules for patterns
- Review GENERIC_PACKAGE_QA.md for package standards
- Look at jido_action, jido_signal for ecosystem patterns
