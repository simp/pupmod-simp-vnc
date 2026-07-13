# AGENTS.md

This file provides guidance to AI agents when working with code in this repository.

## What this module does

`simp-vnc` is a SIMP Puppet module that manages **VNC remote desktop** on
Enterprise Linux. It has two sides:

- **Server** (`manifests/server.pp`) — installs the `tigervnc-server` package
  (`server.pp`), pulls in `xinetd` and `gdm` (`server.pp`), and
  declares three ready-to-use VNC display instances via the
  `vnc::server::create` define: `vnc_standard` (port 5901, `1024x768`),
  `vnc_lowres` (port 5902, `800x600`), and `vnc_highres` (port 5903,
  `1280x1024`), all at 16-bit depth (`server.pp`).
- **Client** (`manifests/client.pp`) — installs the `tigervnc` package
  (`client.pp`).

VNC sessions are **not** run as long-lived daemons. Each session is an
**`xinetd`-launched, per-connection `Xvnc` process** (hence the hard dependency
on `simp/xinetd`), and the graphical login is served by GDM over XDMCP (hence
the hard dependency on `simp/gdm`). See `vnc::server::create` below for the
exact wiring.

### Business logic

The module has four manifests: one empty entry class, two feature classes, and
one define. **There is no `assert_private()` anywhere** — all four are
publicly declarable.

- **`vnc` (`manifests/init.pp`)** — an **empty no-op class**
  (`class vnc { }`); its own docstring says "This does nothing!"
  (`init.pp`). It exists as a namespace anchor; `include 'vnc'` does nothing.
  Real behaviour lives in `vnc::server` and `vnc::client`.

- **`vnc::server` (`manifests/server.pp`)** — the server entry class.
  - `$package_ensure` (`String`) defaults to
    `simplib::lookup('simp_options::package_ensure', { 'default_value' => 'installed' })`
    (`server.pp`) and controls the `tigervnc-server` package
    (`server.pp`).
  - `include 'xinetd'` and `include 'gdm'` (`server.pp`) — GDM is what
    answers the XDMCP query each `Xvnc` makes; without it VNC will not work.
  - Declares three `vnc::server::create` instances with fixed ports/geometries
    (`server.pp`).

- **`vnc::server::create` (`manifests/server/create.pp`)** — a
  **defined type** (`define`) that creates one VNC display served through
  xinetd. Parameters (`create.pp`):
  - `$port` (`Simplib::Port`, **required**) — the TCP port for the session.
  - `$geometry` (`Vnc::Geometry`, default `'800x600'`) — the display resolution.
  - `$depth` (`Integer`, default `16`) — pixel depth in bits.
  - `$screensaver_timeout` (`Integer`, default `15`) — minutes before the
    screensaver disables.

  It `include`s `xinetd` (`create.pp`) and declares one
  `xinetd::service { $name: ... }` (`create.pp`) that runs
  `/usr/bin/Xvnc` under user `nobody`, over a TCP stream socket, with
  `x_type => 'UNLISTED'` and `x_wait => 'no'`. The server args
  (`create.pp`) hard-wire `-inetd -localhost -query localhost
  -SecurityTypes None -once -NeverShared`, interpolating `$screensaver_timeout`
  (`-s`), the resource `$name` (`-desktop`), `$geometry`, and `$depth`. Access
  is restricted to loopback: `trusted_nets => ['127.0.0.1']` (`create.pp`).

### Gotchas / non-obvious details

- **`class vnc` is a no-op.** `include 'vnc'` (`init.pp`) manages nothing.
  Consumers must `include 'vnc::server'` and/or `include 'vnc::client'`
  directly.
- **XDMCP must be enabled in GDM or VNC will not work.** Each `Xvnc` runs with
  `-query localhost` (`create.pp`), so it depends on GDM answering XDMCP.
  The `vnc::server` docstring instructs setting
  `gdm::settings: { xdmcp: { Enable: true } }` in Hiera
  (`server.pp`) — the module does **not** set this for you.
- **VNC here uses no VNC-level authentication.** The `Xvnc` args set
  `-SecurityTypes None` (`create.pp`); the security boundary is instead the
  xinetd `trusted_nets => ['127.0.0.1']` loopback restriction (`create.pp`)
  plus `-localhost`. Access is expected via an SSH tunnel, not directly.
- **`vnc::server`'s three instances have hard-coded ports and geometries**
  (5901/5902/5903, `server.pp`). They are not parameterized; to change
  them, declare your own `vnc::server::create` resources instead of relying on
  `vnc::server`.
- **`Vnc::Geometry` is a strict `WxH` pattern.** `types/geometry.pp` defines
  it as `Pattern['^\d+x\d+$']` — digits, a literal lowercase `x`, digits, and
  nothing else. `'1024x768'` matches; `'1024X768'`, `'1024 x 768'`, or a
  trailing depth like `'1024x768x16'` do **not**.
- **`simp/simp_options` is NOT a declared dependency** in `metadata.json`, yet
  both feature classes consume the `simp_options::package_ensure` seam via
  `simplib::lookup` (provided by `simp/simplib`). `simp_options` is not even a
  fixture here — the lookup relies on its explicit `default_value`.
- **`simp/gdm` and `simp/xinetd` are hard runtime dependencies**, not optional
  — `vnc::server` and `vnc::server::create` `include` them unconditionally.
  There are no optional dependencies and no `simplib::assert_optional_dependency`
  calls in this module.

## The `simp_options` / `simplib::lookup` seam

The module's only business-logic seam is the package-ensure lookup, present in
both feature classes with the same shape:

| Location | Key | `default_value` |
|----------|-----|-----------------|
| `server.pp` | `simp_options::package_ensure` | `'installed'` |
| `client.pp` | `simp_options::package_ensure` | `'installed'` |

Keep routing package state through `simplib::lookup('simp_options::package_ensure',
{ 'default_value' => 'installed' })` rather than assuming `simp_options` is
included.

## Dependencies

Module dependencies (from `metadata.json`), all **hard** runtime deps:

- `simp/gdm` `>= 7.0.0 < 9.0.0` — the graphical login stack that answers the
  `Xvnc -query localhost` XDMCP request (`metadata.json`).
- `puppetlabs/stdlib` `>= 8.0.0 < 10.0.0` (`metadata.json`).
- `simp/simplib` `>= 4.9.0 < 6.0.0` — provides `simplib::lookup` and the
  `Simplib::Port` type used by `vnc::server::create` (`metadata.json`).
- `simp/xinetd` `>= 4.0.0 < 5.0.0` — provides the `xinetd::service` define that
  launches each `Xvnc` (`metadata.json`).

There are **no optional dependencies** (`metadata.json` has no
`simp.optional_dependencies` block).

Fixture-only dependencies (from `.fixtures.yml`, present for test compilation,
not runtime deps): `dconf`, `inifile` (pinned `v6.2.0`) — plus the runtime deps
above are also checked out as fixtures.

Runtime requirement (from `metadata.json`): **`openvox >= 8.0.0 < 9.0.0`**.
This module has migrated its baseline from Puppet to **OpenVox**; the `Gemfile`
reflects the transitional shim (see below). Update this line only if
`metadata.json` `requirements` changes.

Supported OS matrix (from `metadata.json`): CentOS 9/10; RedHat 8/9/10;
OracleLinux 8/9/10; Rocky 8/9/10; AlmaLinux 8/9/10.

## Repository layout

- `manifests/init.pp` — the empty `vnc` no-op class.
- `manifests/server.pp` — the `vnc::server` class (installs the server, wires
  xinetd + gdm, declares three default sessions).
- `manifests/client.pp` — the `vnc::client` class (installs `tigervnc`).
- `manifests/server/create.pp` — the `vnc::server::create` **defined type**
  (one xinetd-launched `Xvnc` session).
- `types/geometry.pp` — the `Vnc::Geometry` type alias (`WxH` pattern).
- `metadata.json` — deps, OS matrix, and the OpenVox runtime requirement.
- `spec/classes/server_spec.rb`, `spec/classes/client_spec.rb` — rspec-puppet
  unit tests for the two feature classes.
- `spec/defines/server_create_spec.rb` — unit tests for the define.
- `spec/type_aliases/vnc_geometry_spec.rb` — tests for the `Vnc::Geometry` type.
- `spec/spec_helper.rb` — unit test harness (`require` line at `spec_helper.rb`).
- `spec/spec_helper_acceptance.rb` — present, but see the CI note: there are no
  acceptance suites or nodesets to drive it.
- `REFERENCE.md` — generated Puppet Strings reference.
- **No `lib/`, `templates/`, `data/`, or `hiera.yaml`** — this module ships no
  Ruby types/providers/functions/facts, no templates, and no module data. The
  only custom type is the pure-Puppet `Vnc::Geometry` alias in `types/`.

### Continuous integration (`.github/workflows/pr_tests.yml`)

The PR workflow runs **six standard jobs and no acceptance job**:
`puppet-syntax` (`rake syntax`), `puppet-style` (`rake lint` + `rake
metadata_lint`), `ruby-style` (`rake rubocop`, `continue-on-error`),
`file-checks` (`rake check:dot_underscore` + `check:test_file`),
`releng-checks` (version/changelog checks + `pdk build --force`), and
`spec-tests` (`rake parallel_spec`).

- **This module has no acceptance testing at all.** `spec/acceptance/nodesets/`
  contains **0 files** (there is no `spec/acceptance/` suite tree), and the
  workflow has no `acceptance` job. It is **unit-tests-only**.
- The `spec-tests` job uses a per-job Puppet matrix (currently a single entry:
  Puppet 8.x, `PUPPET_VERSION: '~> 8.0'`, Ruby 3.2); there is no global
  `PUPPET_VERSION` env at the workflow level (`pr_tests.yml`).

## Common commands

```sh
# Install dependencies
bundle install

# Run all unit tests
bundle exec rake spec

# Run a single spec
bundle exec rspec spec/classes/server_spec.rb

# Run the parallel spec suite (as CI does)
bundle exec rake parallel_spec

# Puppet lint
bundle exec rake lint

# Ruby lint
bundle exec rake rubocop

# Regenerate REFERENCE.md from puppet-strings docstrings
puppet strings generate --format markdown --out REFERENCE.md
```

Relevant gem pins (from `Gemfile`): `rubocop ~> 1.88.0` (`Gemfile`),
`puppetlabs_spec_helper ~> 8.0.0` (`Gemfile`), `simp-rake-helpers ~> 5.24.0`
(`Gemfile`), `simp-beaker-helpers ~> 2.0.0` (`Gemfile`).

**OpenVox transitional shim:** the `:test` group defaults `puppet_version` to
`['>= 8', '< 9']` (`Gemfile`) and then installs **both** the `openvox` and
`puppet` gems via `['openvox', 'puppet'].each do |gem_name|` (`Gemfile`).
The comment explains this is temporary "until the puppet dependency is removed
from other gems." Do not remove either gem until that upstream cleanup lands.

## Conventions

- Preserve the `@summary` / `@param` puppet-strings docstrings on the classes
  and the define — they drive `REFERENCE.md`. Regenerate `REFERENCE.md` after
  changing docs or parameters.
- Route package state through
  `simplib::lookup('simp_options::package_ensure', { 'default_value' =>
  'installed' })` rather than assuming `simp_options` is included, as both
  `server.pp` and `client.pp` do.
- Use the `Vnc::Geometry` and `Simplib::Port` types for geometry/port
  parameters rather than raw `String`/`Integer`, matching
  `vnc::server::create`.
- `Gemfile`, `spec/spec_helper.rb`, `.pdkignore`, `.gitignore`, and
  `.github/workflows/pr_tests.yml` carry a **puppetsync** notice — they are
  baseline-managed and the next sync overwrites local edits. Push changes to
  those files upstream to the baseline, not here.
- Match the existing 2-space Puppet indentation and aligned-arrow parameter
  style used across `manifests/`.
