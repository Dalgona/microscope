# Microscope Changelog

## v1.3.0 &mdash; 2019-05-19

### Changed

- Refactored codes under the hood. Existing codes using Microscope may not be
  affected by this change.

    The HTTP listener process is now wrapped with a GenServer process, to
    ensure a proper startup-shutdown lifecycle of the process.

### Added

- Added `Microscope.stop/1,2` function, which can stop running Microscope
  processes.

## v1.2.0 &mdash; 2019-04-14

### Changed

- Changed Elixir version requirement to `>= 1.7.0`.

## v1.1.1 &mdash; 2019-04-13

### Changed

- Minor internal changes

## v1.1.0 &mdash; 2019-02-25

### Changed

- Upgraded Cowboy from 1.x to 2.6.1

### Removed

- Response body compression was removed. This may be reimplemented later

## v1.0.1 &mdash; 2019-01-09

- Updated dependencies
- Minor code clean-ups

## v1.0.0 &mdash; 2017-01-15

- Initial release
