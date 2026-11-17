# Versioning

Infradeck follows [Semantic Versioning](https://semver.org/) with versions in the form `X.Y.Z`. This page
explains what counts as a breaking change for Infradeck, what each kind of release may contain, and what stays
compatible between releases. It applies from 1.0.0 on. The 0.x versions were private pre-releases and came with
no guarantees.

## One version for everything

The dashboard (backend and frontend), the collector, the Docker proxy and the system helper always share one
version. It is stored in the [VERSION](../VERSION) file at the repository root. Pushing a tag `v<version>` runs
[images.yml](../.github/workflows/images.yml), which builds and signs every image from that commit. The workflow
refuses to run if the tag doesn't match `VERSION`. Collectors read the same file and report it as
`collector_version` (`_read_version()` in [collector.py](../src/collector/collector.py)).

A release can bump the version even when one component hasn't changed. Each component still gets a new image
with the new version, so on any host "which version is this?" has a single answer.

## What the version number promises

SemVer only makes sense with a defined public interface. For Infradeck, that interface is everything a
self-hoster or their scripts rely on:

- **The collector protocol**: how collectors join, report and receive checks from the dashboard.
- **The REST API**: the endpoints in [api.md](api.md), including those used with API tokens.
- **Configuration**: environment variables, the compose files, ports and volumes.
- **The upgrade path**: `docker compose pull && docker compose up -d`, with database migrations applied
  automatically when the backend starts (`upgrade_database()` in [main.py](../src/backend/main.py)).

Internals are not part of it: database tables, Redis keys, frontend routes, log formats and the incident
agent's prompts can change in any release.

## Major (X): you may have to act

A major release is needed when an upgrade can break something or requires a manual step, for example:

- An environment variable is removed or renamed, or the compose files must be edited by hand.
- Collectors from the previous major stop working with the new dashboard and must be upgraded.
- A REST API endpoint or response field is removed or changes meaning.
- A migration can't be reversed or needs a manual step, or upgrading directly from an older version is no
  longer supported.

Every major release has an **Upgrading** section in [CHANGELOG.md](../CHANGELOG.md) that lists every manual step.

## Minor (Y): new things, nothing breaks

A minor release adds features that are backward compatible:

- New features, checks, endpoints and response fields.
- New environment variables, as long as they are optional and have a sensible default.
- Database migrations, which run automatically on startup.
- Collector features that need the new collector version. Older collectors keep working and only lack the new
  feature (see [Collector compatibility](#collector-compatibility)).
- Deprecations: something that will be removed is announced here and in the changelog, and removed no earlier
  than the next major.

## Patch (Z): fixes only

A patch release contains only:

- Bug fixes and security fixes.
- Dependency updates.
- Documentation changes.

A patch has **no new features, no new configuration options and no database migrations**. This keeps every
patch safe to install and easy to roll back: going back to the previous patch of the same minor needs no
database restore. If a fix needs a migration, it goes into a minor release.

## Deprecation

Removing anything that is part of the public interface happens in two steps:

1. A minor release marks it as deprecated in the changelog and, if possible, logs a warning or shows one in the
   dashboard when it is used (this isn't available just yet but will be added in the next minor update).
2. It is removed in the next major release at the earliest.

## Collector compatibility

A dashboard accepts every collector with the same major version. When a feature needs a newer collector, the
backend sets a minimum version for that feature, and the dashboard marks servers with older collectors as
"update collector" instead of failing. The existing example is `MIN_COLLECTOR` in
[availability.py](../src/backend/availability.py): collectors older than 0.10.0 can't run checks, and the
Availability page names those servers and links to the place where you update them.

A collector newer than the dashboard is not supported. Upgrade the dashboard first, then the collectors.

## Support

Only the latest minor release gets fixes, security fixes included. Infradeck has a single maintainer, and
keeping older release lines patched would cost more than the upgrade it saves: minor and patch releases are
designed to be safe to install.

## Pre-releases

A version can be tested before release with a pre-release suffix, such as `1.1.0-rc.1`. The image workflow
publishes these under their full version only. No `1.1` tag is created for them, so the `X.Y` tags always
point at a final release.

## Changelog

Every release has an entry in [CHANGELOG.md](../CHANGELOG.md) in the
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) format. Deprecations and security fixes are always
listed. A major release also has an **Upgrading** section.

## Limits

- The backend's version parser (`_version()` in [availability.py](../src/backend/availability.py)) only
  understands plain `X.Y.Z`. A collector reporting a pre-release version such as `1.1.0-rc.1` is treated as
  unknown, so it can't run checks. This needs fixing before the first release candidate is published.
- Nothing enforces these rules automatically. CI checks only that the tag matches `VERSION`, so choosing the
  right number is done by hand when the release is prepared.

## Related

- [CHANGELOG.md](../CHANGELOG.md): what changed in each version.
- [Deploying on a server › Updating](deployment.md#updating): how to upgrade.
- [Database schema](database.md): how migrations work.
