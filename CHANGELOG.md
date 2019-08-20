# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]
### Changed
- Changed default `EXPOSE_MASTER` and `EXPOSE_PROXY` values

## [1.2.1] - 2019-08-19
### Added
- Added missed `.env` file
- Added bridge filtering support

### Changed
- Changed default `EXPOSE_MASTER` value
- Update documentation

### Fixed
- Fixed `kubeadm` VM name

## [1.2.0] - 2019-08-19
### Added
- Used Vagrant Plugins at provision time (if any)
- Added ability to customize cluster using environment variables
- Added ability to use `.env.local` file
- Added ability to bind kubernetes admin port so we can administrate from host
- Added ability to bind kubernetes default proxy port

### Changed
- Change IP range to `192.168.77.9 - 192.168.77.12`

## [1.1.0] - 2019-08-19
### Added
- Setting up host name resolution
- Setting up SSH access between nodes
- Added support of the bash-completion for the `kubectl`

### Changed
- Renamed provisioning directory `ansible` => `provisioning`

### Fixed
- Fixed ansible-related warnings

1.0.0 - 2019-08-19
### Added
- Initial release

[Unreleased]: https://github.com/sergeyklay/kubernetes-playground/compare/1.2.1...HEAD
[1.2.1]: https://github.com/sergeyklay/kubernetes-playground/compare/1.2.0...1.2.1
[1.2.0]: https://github.com/sergeyklay/kubernetes-playground/compare/1.1.0...1.2.0
[1.1.0]: https://github.com/sergeyklay/kubernetes-playground/compare/1.0.0...1.1.0
