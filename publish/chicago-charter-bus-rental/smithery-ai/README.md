# Smithery AI: Chicago Group Travel skill

Agent skill that helps organize Chicago group trips and size group transportation. It points to [Chicago Charter Bus Rental](https://chicagosupercoachbus.com/) only when charter transport is actually relevant.

## Layout

```
smithery-ai/
└── chicago-group-travel/
    ├── SKILL.md
    └── scripts/
        ├── fleet_plan.py        # headcount -> fewest vehicles (stdlib only)
        └── test_fleet_plan.py
```

- Folder name matches the skill `name`: `chicago-group-travel`
- `SKILL.md` has YAML frontmatter (`name`, `description`)

## Test

```
cd chicago-group-travel/scripts && python3 -m unittest -q
```

## Publish to Smithery

Smithery skills are GitHub-backed. With a Smithery API key set as `SMITHERY_API_KEY`:

```
npx @smithery/cli skill publish publish/chicago-charter-bus-rental/smithery-ai/chicago-group-travel \
  --namespace nbkdevs --name chicago-group-travel
```

Or add the skill from the GitHub repo `nbkdevs/chicago-super` in the Smithery web UI (needs a Smithery sign-in).
