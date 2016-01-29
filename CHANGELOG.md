# Change Log

All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [0.6.0] - 2016-01-29

### Added

- There is now a `LegislativePeriod` class to represent each legislative period in a legislature. This has a `#csv` method to return a parsed version of the legislative periods CSV.
- You can now call `Legislature#country` to get the country for a legislature. Similarly you can call `LegislativePeriod#country` or `LegislativePeriod#legislature` to get the related objects.

## [0.5.0] - 2016-01-27

### Added

- `Everypolitician.countries` method for returning an array of all countries.
- Find countries and legislatures by arbitrary attributes, e.g. `Everypolitician.country(code: 'AU')`

### Changed

- We no longer use ruby metaprogramming to define the methods on `Country` and `Legislature`, they are now explicitly defined as properties and methods.
- `Legislature#popolo_url` now uses the `Legislature#sha` method rather than `master` in the raw url.
- `countries.json` is only loaded once, when it's first accessed. If you want to force a refetch then you can call `Everypolitician.countries = nil`.

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
[0.5.0]: https://github.com/everypolitician/everypolitician-ruby/compare/v0.4.0...v0.5.0
[0.6.0]: https://github.com/everypolitician/everypolitician-ruby/compare/v0.5.0...v0.6.0
