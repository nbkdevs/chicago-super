# Travel Pal — Journey Notes (Safari)

Safari Web Extension companion for jotting trip memories (local storage only).

## Convert & run (macOS)

```bash
# From this folder, with Xcode installed:
xcrun safari-web-extension-converter . --project-location ../safari-xcode --app-name "Travel Pal" --bundle-identifier app.travelpal.journeynotes --swift --force
```

Then open the generated Xcode project, enable the extension under **Settings → Extensions**, and run.

Alternatively: **Develop → Allow Unsigned Extensions**, then load for testing.
