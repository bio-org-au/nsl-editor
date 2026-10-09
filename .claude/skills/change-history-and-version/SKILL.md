---
name: change-history-and-version
description: Record a user-facing change in the yearly change-history file (config/history/changes-YYYY.yml) and bump the app version in config/version.properties. Use for changes that affect users of the Editor, usually ones with a Jira ticket. Skip it for tooling, docs, or Claude config changes.
argument-hint: "[jira-id] [description]"
---

# Change history and version bump

Users can see changes that affect them on the in-app History page, which reads `config/history/changes-<year>.yml`. Each change of this kind also bumps the app version.

## When to use it

- **Use it** for changes users would notice: bug fixes, features, and security fixes. These usually have a Jira ticket.
- **Skip it** for changes that don't affect users, such as CLAUDE.md, skills, editor config, or CI tooling. If you're unsure, ask the user.

## 1. Add the history entry

Edit `config/history/changes-<current year>.yml`. **New entries go at the top** of the file, so the newest comes first.

```yaml
- :date: 08-October-2026
  :jira_id: '5974'
  :description: |-
    Security: Sanitize Batch Loader Review Comment HTML
```

- `:date:` uses the `DD-Month-YYYY` format with the month written in full, using today's date.
- `:jira_id:` is the ticket number only, as a **quoted string**, without the `NSL-` prefix.
- `:description:` is `<Area>: <what changed>`, in plain words for users, for example `Loader Batch: Fix bug in ...` or `Typeahead upgrade: ...`. Ask the user for the Jira number and wording if you don't have them.
- Check that the file still parses: `ruby -ryaml -e 'YAML.load_file("config/history/changes-<year>.yml")'`.

**First change of a new year:** the year needs more than a new YAML file. `app/views/history/` has a `_<year>.html.erb` partial for each year. Look at how the previous year was set up (`git log --diff-filter=A -- config/history/changes-<last year>.yml`) and copy the same set of files. The first entry is traditionally `History: Set up Changes <year> page`.

## 2. Bump the version

In `config/version.properties`, increment the **last** number of `appversion`:

```
appversion=5.1.7.19  ->  appversion=5.1.7.20
```

Only change the higher-order numbers if the user asks for it, for example for a release.

## 3. Commit

Include both files in the same commit as the change itself. The commit subject matches the history entry: `NSL-<jira_id>: <description>`.
