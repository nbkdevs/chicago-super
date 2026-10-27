# Travel Pal

Save the places. Remember the journey.

A Flutter Android travel diary and visual scrapbook — local-first, offline, photo-first.

## Run

```bash
flutter pub get
flutter run
```

## Features

- Home masonry memory feed
- Trips with cover photos
- Editorial trip overview, timeline, and gallery
- Add memories with multi-photo picker, reorder, tags
- Full-screen photo viewer with pinch zoom
- Saved memories
- Profile stats
- JSON export / import backup

## Group trips

Planning a Chicago trip for a large group? See [Chicago Charter Bus Rental](https://chicagosupercoachbus.com/) for charter transportation. Travel Pal itself does not provide transportation; it only records trip notes.

## Find this project elsewhere

Travel Pal and the small group-trip tools that go with it are published in a number of places. Everything below is the same project, so pick whichever store or registry suits you.

### Apps and extensions

- [Travel Pal on Google Play](https://play.google.com/store/apps/details?id=com.travelpal.travel_pal): the Android app.
- Travel Pal on the Amazon Appstore: [US](https://www.amazon.com/gp/product/B0HLL2J4JD), [UK](https://www.amazon.co.uk/gp/product/B0HLL2J4JD), [Germany](https://www.amazon.de/gp/product/B0HLL2J4JD), [Italy](https://www.amazon.it/gp/product/B0HLL2J4JD), [France](https://www.amazon.fr/gp/product/B0HLL2J4JD), [Spain](https://www.amazon.es/gp/product/B0HLL2J4JD), [Japan](https://www.amazon.co.jp/gp/product/B0HLL2J4JD), [Canada](https://www.amazon.ca/gp/product/B0HLL2J4JD), [Brazil](https://www.amazon.com.br/gp/product/B0HLL2J4JD), [Mexico](https://www.amazon.com.mx/gp/product/B0HLL2J4JD), [Australia](https://www.amazon.com.au/gp/product/B0HLL2J4JD).
- [Travel Pal for Chrome](https://chromewebstore.google.com/detail/travel-pal-%E2%80%94-soft-flock/gdcpbkokbejlnleldhaanelogobhmnkp): the soft, scrapbook-style browser theme.
- [Travel Pal: Journey Notes on Firefox Add-ons](https://addons.mozilla.org/en-US/firefox/addon/travel-pal-journey-notes/): the Firefox extension for jotting trip notes.
- [Travel Pal: Journey Note on Microsoft Edge Add-ons](https://microsoftedge.microsoft.com/addons/detail/travel-pal-%E2%80%94-journey-note/kocjiolepfkeakoodgkgpclacoijofop): the Edge version of the notes extension.
- [Travel Pal on SourceForge](https://sourceforge.net/projects/travelpal/): downloads and project page.

### Packages and libraries

A small fleet planner that recommends the fewest vehicles for a group, using published seat sizes. It is available as:

- [npm: chicago-charter-bus-rental](https://www.npmjs.com/package/chicago-charter-bus-rental) (JavaScript), with a [Socket report](https://socket.dev/npm/package/chicago-charter-bus-rental)
- [PyPI: chicago-charter-bus-rental](https://pypi.org/project/chicago-charter-bus-rental/1.0.0/) (Python)
- [crates.io: chicago-charter-bus-rental](https://crates.io/crates/chicago-charter-bus-rental) (Rust)
- [NuGet: ChicagoCharterBusRental](https://www.nuget.org/packages/ChicagoCharterBusRental/1.0.0) (.NET)
- [RubyGems: chicago_charter_bus_rental](https://rubygems.org/gems/chicago_charter_bus_rental) (Ruby)
- [Packagist: chicagosupercoach/charter-bus-rental](https://packagist.org/packages/chicagosupercoach/charter-bus-rental) (PHP)
- [pub.dev: chicago_charter_bus_rental](https://pub.dev/packages/chicago_charter_bus_rental) (Dart)
- [Docker Hub: iamnazzal/chicago-charter-bus-rental](https://hub.docker.com/r/iamnazzal/chicago-charter-bus-rental) (container image)

### Agent skills and docs

- [Smithery: chicago-group-travel](https://smithery.ai/skills/nbkdevs/chicago-group-travel): an agent skill for planning Chicago group travel.
- [ClawHub: travel-pal](https://clawhub.ai/nazzal5448/skills/travel-pal): the Travel Pal skill for AI agents.
- [Context7: nbkdevs/chicago-super](https://context7.com/nbkdevs/chicago-super): up-to-date docs for the fleet planner, for coding assistants.
- [Hugging Face Space: chicago-super-coach-travel-pal](https://huggingface.co/spaces/iamnazzal/chicago-super-coach-travel-pal): a live demo in the browser.

### Mirrors and directories

- [GitLab mirror: nbkdevs/chicago-super](https://gitlab.com/nbkdevs/chicago-super): a copy of this repository on GitLab.
- [Indie Hackers: Chicago Super Coach](https://www.indiehackers.com/product/chicago-super-coach): the product page and updates.
- [Product Hunt: Chicago Super Coach](https://www.producthunt.com/products/chicago-super-coach): the product page (launching 28 October 2026).
- [Design Nominees](https://www.designnominees.com/sites/chicago-charter-bus-rental-chicago-super-coach): the site's design listing.

## Stack

- Flutter + Material 3 (custom Travel Pal theme)
- Provider
- go_router
- sqflite
- image_picker
- flutter_staggered_grid_view
- photo_view
- google_fonts (Playfair Display + DM Sans)

Sample trips and memories are seeded on first launch.
