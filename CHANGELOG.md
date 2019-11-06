# deric-mesos

## v1.0.4
- Add parameter `mesos::manage_repo` that would disable repository management (#93)
- Fix Ubuntu support (#89)
- [Full diff](https://github.com/deric/puppet-mesos/compare/v1.0.3...v1.0.4)

## v1.0.3
- [Full diff](https://github.com/deric/puppet-mesos/compare/v1.0.2...v1.0.3)
- Support `puppetlabs-apt` 6.x

## v1.0.2
- [Full diff](https://github.com/deric/puppet-mesos/compare/v1.0.1...v1.0.2)
- Fixed the mesos_version variable check, which fails if the puppet server has "strict_variables = true" [#91](https://github.com/deric/puppet-mesos/pull/91)
- Adds notifier from credentials and acls files to services [#92](https://github.com/deric/puppet-mesos/pull/92)
- Mark Puppet 6 and new versions of `stdlib` and `apt` as compatible

## v1.0.1
- [Full diff](https://github.com/deric/puppet-mesos/compare/v1.0.0...v1.0.1)
- Fixed passing custom repository configuration

## v1.0.0
- [Full diff](https://github.com/deric/puppet-mesos/compare/v0.9.1...v1.0.0)
- Introduced Puppet 4 strong types

- [**Breaking Changes**]
 - Dropped Puppet 3 support
 - Use Mesosphere repo by default

## v0.9.1
- [Full diff](https://github.com/deric/puppet-mesos/compare/v0.9.0...v0.9.1)
- Use https for package repositories (#88)
- Fixed insecure dev dependency (`nokogiri`)

## v0.9.0
- [Full diff](https://github.com/deric/puppet-mesos/compare/v0.8.4...v0.9.0)
- New features:
  - [Allow passing after=, wants= parameters to systemd services](https://github.com/deric/puppet-mesos/issues/80)
- [**Breaking Changes**]
  - `force_provider` replaced with `service_provider`
  - Agent's `work_dir` defaults to `/var/lib/mesos`

## v0.8.4
- FIX: Install the package before managing the $conf_dir for slave [#79](https://github.com/deric/puppet-mesos/pull/79) [#72](https://github.com/deric/puppet-mesos/issues/72)
- [full changelog](https://github.com/deric/puppet-mesos/compare/v0.8.2...v0.8.3)

## v0.8.3
- incomplete release, fixed running tests on Ruby > 2.2.0

## v0.8.2

- FIX: /etc/init.d scripts not found on installation #28
- FEATURE: allow passing custom APT configuration #77
- systemd disabled on older systems #74
- removed code duplication #75
- expire yum cache #76
- [full changelog](https://github.com/deric/puppet-mesos/compare/v0.8.1...v0.8.2)


## v0.8.1

- Removing configuration file should cause service reload #73
- Refactor mesos::property and its spec #68
- Undef property specs failing with new rspec #70
- [full changelog](https://github.com/deric/puppet-mesos/compare/v0.8.0...v0.8.1)

## v0.8.0

- [**BC**] `single_role`: by default node is either master xor slave #62
- ZooKeeper servers are defined as an array (62ebc80498c35314af3b8ec56d2637c53d15ba8f) - old syntax is as well supported
- support alternative pip providers #63
- fix: restart service when `/etc/default/mesos-master` or `/etc/default/mesos-slave` changes #64
- prefix credentials file with `file://` #65
- full [changes diff](https://github.com/deric/puppet-mesos/compare/v0.7.1...v0.8.0)

## v0.7.1

-  Add ability to disable logging to syslog #60
- Add `mesos_version` fact (312d441d163fe5115252a6e2034b4026d984521c)
- test against Puppet 4
- [diff to previous version](https://github.com/deric/puppet-mesos/compare/v0.7.0...v0.7.1)

## v0.7.0

- Fix service restart when new version is installed #55
- Support [Mesos CLI management](https://github.com/deric/puppet-mesos/commit/da5b2a784753b088571f523b4d4db97ada335d29)
- Fix setting credential for mesos-slave #57
- Allow changing path to `/etc/default/mesos` #58
- Add ensure parameter to mesos::property #59
- `mesos::property` require/notify fixes #56
- [full diff to last patch version](https://github.com/deric/puppet-mesos/compare/v0.6.5...v0.7.0)
- [diff to last minor version - 0.6.0](https://github.com/deric/puppet-mesos/compare/v0.6.0...v0.7.0)

## v0.6.5

- Support ACLs #49 - Note: Mesos `<0.26` reads secrets as base64 encoded byte array, Mesos `>=0.26` reads secrets as plain strings
- Fix running `apt-get update` #54
- Add owner and group parameters to `mesos::property` #52
- [full patch version diff](https://github.com/deric/puppet-mesos/compare/v0.6.4...v0.6.5)
