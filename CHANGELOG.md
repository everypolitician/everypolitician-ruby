# Change Log

All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [0.4.0] - 2016-01-26

### Changed

- `Everypolitician::Legislature#popolo` now returns an instance of `Everypolitician::Popolo::JSON` from [everypolitician-popolo](https://github.com/everypolitician/everypolitician-popolo) instead of a string representing the path.

### Added

- `Everypolitician::Legislature#popolo_url` now returns a GitHub raw url to the popolo for the legislature.

## [0.3.0] - 2015-12-22

### Added

- You can now use `EveryPolitician` as the constant name as well as `Everypolitician`
- You can change the `countries.json` the library uses via `Everypolitician.countries_json=`

## [0.2.0] - 2015-12-22

### Changed

- `countries.json` is now represented by a separate class allowing users to access the raw underlying data.

## 0.1.0 - 2015-12-22

- Initial release

[0.2.0]: https://github.com/everypolitician/everypolitician-ruby/compare/v0.1.0...v0.2.0
[0.3.0]: https://github.com/everypolitician/everypolitician-ruby/compare/v0.2.0...v0.3.0
[0.4.0]: https://github.com/everypolitician/everypolitician-ruby/compare/v0.3.0...v0.4.0
