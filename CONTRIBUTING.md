# Contributing to Jido.Amp

Thank you for your interest in contributing to Jido.Amp! This document provides guidelines and workflows for contributing.

## Development Workflow

### Setup

```bash
mix setup
```

### Running Tests

```bash
mix test
```

### Code Quality Checks

Run all quality checks:

```bash
mix quality
```

This includes:
- Code formatting (mix format)
- Linting (Credo)
- Type checking (Dialyzer)
- Documentation coverage (Doctor)

### Making Changes

1. Create a feature branch from `main`
2. Make your changes
3. Run `mix quality` to ensure all checks pass
4. Commit with a conventional commit message
5. Push and create a pull request

## Commit Message Format

We follow [Conventional Commits](https://www.conventionalcommits.org/).

Format:
```
type(scope): description

[optional body]

[optional footer]
```

Types:
- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation changes
- `style` - Formatting (no code change)
- `refactor` - Code change (no fix or feature)
- `perf` - Performance improvement
- `test` - Test changes
- `chore` - Maintenance, deps, tooling
- `ci` - CI/CD changes

Examples:
```bash
git commit -m "feat: add orchestration layer"
git commit -m "fix: resolve deadlock in async operations"
git commit -m "docs: update README with examples"
```

## Code Standards

- Follow standard Elixir conventions
- Use `Logger` for output instead of `IO.puts`
- Handle errors gracefully with pattern matching
- Document all public API functions with `@doc`
- Maintain test coverage above 90%

## Pull Request Process

1. Ensure `mix quality` passes
2. Ensure tests have >90% coverage
3. Update CHANGELOG.md with your changes
4. Provide a clear description of what changed and why
5. Ensure CI passes

## Questions?

Feel free to open a discussion or issue on GitHub.
