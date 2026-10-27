# Chicago Charter Bus Rental — publish assets

Minimal packages and metadata for listing **[Chicago Charter Bus Rental](https://chicagosupercoachbus.com/)** on common registries. Each artifact is self-contained under its folder.

**Homepage:** https://chicagosupercoachbus.com/

These are small reference packages (URLs, copy, and helpers)—not full applications. Publish manually from each directory using the notes below. **No GitHub Actions** are included (especially for Snapcraft).

## Platforms (verified)

| Platform   | Directory    | Status | Publish hint |
|-----------|--------------|--------|--------------|
| Snapcraft | `snapcraft/` | Ready | Local `snapcraft pack` / `snapcraft upload` only |
| Docker Hub | `docker/`   | Ready | `docker build` then `docker push` |
| Packagist | `packagist/` | Ready | Register Git repo on packagist.org |
| PyPI      | `pypi/`      | Ready | `python -m build && twine upload dist/*` |
| Crates.io | `crates/`    | Ready | `cargo publish` |
| NuGet     | `nuget/`     | Ready | `dotnet pack` then `dotnet nuget push` |
| npm       | `npm/`       | Ready | `npm publish` |
| RubyGems  | `rubygems/`  | Ready | `gem build` then `gem push` |
| pub.dev   | `pub_dev/`   | Ready | `dart pub publish` |
| Smithery AI | `smithery-ai/` | Ready | Upload `chicago-group-travel/` skill folder |

**Upload order (Snapcraft last):** Docker Hub → Packagist → PyPI → Crates.io → NuGet → npm → RubyGems → pub.dev → Smithery → Snapcraft

All packages link to https://chicagosupercoachbus.com/ and use **Chicago Charter Bus Rental** in names/descriptions.

Browser packages live separately under `/browser` (Chrome theme · Firefox · Edge · Safari · Opera).

Replace placeholder author names, emails, and registry IDs before publishing.
