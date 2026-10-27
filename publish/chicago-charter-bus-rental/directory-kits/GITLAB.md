# GitLab mirror plan: Chicago Super Coach

Nothing has been created on GitLab. `GITLAB_TOKEN` is not set in the box environment and no web sign-in is allowed here, so the project has to be created by the user or after a token is provided.

## Decision
Mirror the whole `nbkdevs/chicago-super` GitHub repo (not a trimmed subset). This is what GoPromotional did (`gitlab.com/nbkdevs/gopromotional`, "mirror imported from GitHub"). The root `README.md` already carries the exact anchor once, in the "Group trips" section:

`[Chicago Charter Bus Rental](https://chicagosupercoachbus.com/)`

so an import brings the anchor along with no extra edit. The `publish/` packages also carry their own anchored READMEs, which is fine for a mirror.

## Target
- Project: `nbkdevs/chicago-super` (public), expected URL https://gitlab.com/nbkdevs/chicago-super
- Sheet row: Gitlab (92/92, Source Code, Nofollow). Item URL = the project URL above.

## Steps (any one of these)
1. GitLab web: New project > Import project > GitHub, pick `nbkdevs/chicago-super`, namespace `nbkdevs`, visibility Public. Needs a GitHub PAT with `repo` scope.
2. API (needs `GITLAB_TOKEN` with `api` scope): `POST https://gitlab.com/api/v4/import/github` with `personal_access_token` (GitHub), `repo_id`, `target_namespace=nbkdevs`, `new_name=chicago-super`.
3. Push mirror: create an empty public project `nbkdevs/chicago-super`, then `git push --mirror` from /workspace/softrank/chicago-super with a GitLab token.

## After it exists
- Set the project description: "Chicago Super Coach Travel Pal and charter bus planning tools".
- Verify the README renders the anchor as a link to https://chicagosupercoachbus.com/ and note its rel (sheet expects Nofollow).
- Set the sheet row's Item URL and Status to Live; add a Live row to STATUS.md.
