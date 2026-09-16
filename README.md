# DevOps Board

An Omarchy shell plugin that shows your Azure DevOps team's sprint as a
keyboard-driven card: user stories (and bugs) with their tasks nested
underneath, how far through the sprint you are, and an editor for any story
or task.

- **Board**: stories in backlog order with state glyphs (○ to do, ◐ in
  progress, ● done), task progress, points, remaining hours and assignee
  initials, with your own items highlighted. A bar across the top shows tasks
  done or in progress, plus a marker for today's position in the sprint.
- **Editor**: title, state, assignee, story points / effort or remaining
  hours, priority, tags, description (or repro steps) and acceptance
  criteria. It also shows the parent and child items and the discussion, and
  you can add comments. Only the fields you change are sent. The save checks
  the item's revision so it can't overwrite someone else's edit.
- Works with the Agile, Scrum and CMMI processes and their custom
  inheritances. States and fields are read from the process.

## Keys

| Where | Keys |
|---|---|
| Board | type to filter · ↑↓ move · → ← expand / collapse · Enter open · Tab all / mine · Ctrl+← → sprint · Ctrl+T team · Ctrl+R refresh · Ctrl+O open in browser · Ctrl+, connection · Esc clear filter, close |
| Editor | Tab next field · Ctrl+S save · Ctrl+Enter post comment · Ctrl+R reload · Ctrl+O browser · Esc leave field, then back |

Rich text is edited as light markdown: paragraphs, `- ` and `1. ` lists,
`#` headings, `**bold**`, `*italic*` and `[links](https://…)`. A description
containing images or tables is read-only here (Ctrl+O edits it in the
browser), so nothing is lost in the round trip.

## Setup

```bash
./deploy-local.sh
omarchy plugin enable funcoder.devops-board
```

Bind a key in `~/.config/hypr/bindings.lua`:

```lua
o.bind("SUPER + SHIFT + PERIOD", "DevOps board", "omarchy-shell shell toggle funcoder.devops-board '{}'")
```

On first open, step 1 asks for access: your organization (a URL like
`https://dev.azure.com/contoso`, or paste any Azure DevOps URL) and a personal
access token with **Work Items (Read & write)** and **Project and Team
(Read)**. The token is kept in the desktop keyring (`secret-tool`);
`AZURE_DEVOPS_EXT_PAT` is used when the keyring has none. Step 2 lists every
team the token can see, with its project; pick yours (Ctrl+T switches later).
"Try with demo data" shows a sample sprint without connecting.

Re-run `./deploy-local.sh` after editing. If QML changes don't show up, run
`omarchy restart shell`.

## Files

| Path | Contents |
|---|---|
| `~/.config/funcoder-devops-board/config.json` | organization, chosen team and its project, you |
| `~/.cache/funcoder-devops-board/` | last board per sprint (opens instantly), states, fields, team members |

## Command line

Everything goes through `devops.py`, which prints JSON:

```bash
H=~/.config/omarchy/plugins/funcoder.devops-board/devops.py
$H status
$H teams
$H board                       # current sprint; --iteration <id> for another
$H item 4812
echo '{"changes":{"state":"Active"}}' | $H update 4812
omarchy-shell funcoder.devops-board item 4812   # open the card on an item
```
