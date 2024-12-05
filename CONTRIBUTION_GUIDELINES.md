# Contribution Guidelines

If you're planning to contribute, **please follow the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) standard.**

Pull Requests (PRs) that do not adhere to this standard will **not be accepted**.

## Branch Requirements

- **All PRs must be based on the `dev` branch.**
- Merges will only occur into the `dev` branch before being released to the main branch.

## Commit Message Format

Ensure your commit messages and PR titles use the following format:

```
<type>(<scope>): <description>
```

For example:  
```
feat(es_extended/client/main): sync where players look at
fix(es_extended/client/functions): validate model is a vehicle
refactor(es_extended/client/modules/death): replace gameEventTriggered
```

Common commit types include:  
- **`feat`** for new features  
- **`fix`** for bug fixes  
- **`refactor`** for code improvements without functionality changes  
- **`!`** to indicate breaking changes (e.g., `feat!` or `fix!`)

---

## PR Checklist

**Please include this in your PR.**
```
- [ ]  My commit messages and PR title follow the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) standard.
- [ ]  My changes have been tested locally and function as expected.
- [ ]  My PR does not introduce any breaking changes.
- [ ]  I have provided a clear explanation of what my PR does, including the reasoning behind the changes and any relevant context.
```


# We value your contribution!
By adhering to these guidelines, we can ensure a clean and maintainable codebase. Thank you for contributing to ESX!