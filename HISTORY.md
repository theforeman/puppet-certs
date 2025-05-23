## [21.0.0](https://github.com/theforeman/puppet-certs/tree/21.0.0) (2025-05-09)

[Full Changelog](https://github.com/theforeman/puppet-certs/compare/20.0.1...21.0.0)

**Breaking changes:**

- Remove unused ca\_cert and ca\_cert\_stripped parameters [\#495](https://github.com/theforeman/puppet-certs/pull/495) ([ekohl](https://github.com/ekohl))
- Remove cleanup of KATELLO-TRUSTED-SSL-CERT [\#493](https://github.com/theforeman/puppet-certs/pull/493) ([ehelms](https://github.com/ehelms))
- Drop references to the deployed CA key that is not deployed [\#485](https://github.com/theforeman/puppet-certs/pull/485) ([ehelms](https://github.com/ehelms))
- Drop certs::foreman from foreman\_proxy\_content tarballs [\#480](https://github.com/theforeman/puppet-certs/pull/480) ([ehelms](https://github.com/ehelms))

**Implemented enhancements:**

- Add apache\_client\_ca\_cert parameter to be used as public API [\#497](https://github.com/theforeman/puppet-certs/pull/497) ([ehelms](https://github.com/ehelms))
- Split generate and deploy config into separate classes [\#491](https://github.com/theforeman/puppet-certs/pull/491) ([ehelms](https://github.com/ehelms))
- Bundle default and server CA certificate and use for Foreman client CA [\#490](https://github.com/theforeman/puppet-certs/pull/490) ([ehelms](https://github.com/ehelms))
- Explicitly set deploy to false for foreman\_proxy\_content class [\#486](https://github.com/theforeman/puppet-certs/pull/486) ([ehelms](https://github.com/ehelms))
- Cleanup trustore and keystore passwordfiles in pki\_dir [\#484](https://github.com/theforeman/puppet-certs/pull/484) ([ehelms](https://github.com/ehelms))
- Only create password file when generate is true [\#481](https://github.com/theforeman/puppet-certs/pull/481) ([ehelms](https://github.com/ehelms))

**Fixed bugs:**

- Fix assertion to do actual comparison [\#499](https://github.com/theforeman/puppet-certs/pull/499) ([ekohl](https://github.com/ekohl))
- don't document server\_cert\_req, it's gone [\#498](https://github.com/theforeman/puppet-certs/pull/498) ([evgeni](https://github.com/evgeni))
- Remove unused pulp\_pki\_dir variable [\#483](https://github.com/theforeman/puppet-certs/pull/483) ([ekohl](https://github.com/ekohl))

## [20.0.1](https://github.com/theforeman/puppet-certs/tree/20.0.1) (2025-02-14)

[Full Changelog](https://github.com/theforeman/puppet-certs/compare/20.0.0...20.0.1)

**Fixed bugs:**

- Regenerate keystore if the keystore is empty [\#477](https://github.com/theforeman/puppet-certs/pull/477) ([ehelms](https://github.com/ehelms))

## [20.0.0](https://github.com/theforeman/puppet-certs/tree/20.0.0) (2025-02-11)

[Full Changelog](https://github.com/theforeman/puppet-certs/compare/18.0.2...20.0.0)

**Breaking changes:**

- Drop EL8 support -- Foreman/Katello do not support EL8 anymore [\#475](https://github.com/theforeman/puppet-certs/pull/475) ([ehelms](https://github.com/ehelms))
- Ensure KATELLO-TRUSTED-SSL-CERT is absent [\#464](https://github.com/theforeman/puppet-certs/pull/464) ([ekohl](https://github.com/ekohl))
- Drop unused privkey, pubkey and key\_bundle types & providers [\#462](https://github.com/theforeman/puppet-certs/pull/462) ([ekohl](https://github.com/ekohl))

**Implemented enhancements:**

- Add class to handle creation of certs for advisor service on localhost [\#474](https://github.com/theforeman/puppet-certs/pull/474) ([ehelms](https://github.com/ehelms))

## [19.1.1](https://github.com/theforeman/puppet-certs/tree/19.1.1) (2024-11-12)

[Full Changelog](https://github.com/theforeman/puppet-certs/compare/19.1.0...19.1.1)

**Fixed bugs:**

- Fixes [\#38010](https://projects.theforeman.org/issues/38010) - Include keyalg in keytool for OpenJDK 17 [\#470](https://github.com/theforeman/puppet-certs/pull/470) ([ehelms](https://github.com/ehelms))

## [19.1.0](https://github.com/theforeman/puppet-certs/tree/19.1.0) (2024-11-04)

[Full Changelog](https://github.com/theforeman/puppet-certs/compare/19.0.1...19.1.0)

**Implemented enhancements:**

- Merge if/else branch into a single resource declaration & introduce $default\_ca\_path [\#467](https://github.com/theforeman/puppet-certs/pull/467) ([ekohl](https://github.com/ekohl))

## [19.0.1](https://github.com/theforeman/puppet-certs/tree/19.0.1) (2024-09-13)

[Full Changelog](https://github.com/theforeman/puppet-certs/compare/19.0.0...19.0.1)

**Fixed bugs:**

- Fixes [\#37817](https://projects.theforeman.org/issues/37817): Only copy server CA in build root if generate is true [\#463](https://github.com/theforeman/puppet-certs/pull/463) ([ehelms](https://github.com/ehelms))

## [19.0.0](https://github.com/theforeman/puppet-certs/tree/19.0.0) (2024-08-12)

[Full Changelog](https://github.com/theforeman/puppet-certs/compare/18.0.0...19.0.0)

**Breaking changes:**

- Move keystore and trustore password files [\#457](https://github.com/theforeman/puppet-certs/pull/457) ([ehelms](https://github.com/ehelms))
- Drop absent file declarations [\#451](https://github.com/theforeman/puppet-certs/pull/451) ([ehelms](https://github.com/ehelms))

**Implemented enhancements:**

- Add AlmaLinux 8 & 9 support [\#454](https://github.com/theforeman/puppet-certs/pull/454) ([archanaserver](https://github.com/archanaserver))

## [18.0.0](https://github.com/theforeman/puppet-certs/tree/18.0.0) (2024-05-15)

[Full Changelog](https://github.com/theforeman/puppet-certs/compare/17.1.1...18.0.0)

**Breaking changes:**

- Remove deploy via provider [\#426](https://github.com/theforeman/puppet-certs/pull/426) ([ehelms](https://github.com/ehelms))
- Drop RPMs from being included in tarball [\#421](https://github.com/theforeman/puppet-certs/pull/421) ([ehelms](https://github.com/ehelms))
- Remove all qpid related certificate handling [\#414](https://github.com/theforeman/puppet-certs/pull/414) ([ehelms](https://github.com/ehelms))

**Fixed bugs:**

- Ensure hostname directory exists when copying server cert [\#450](https://github.com/theforeman/puppet-certs/pull/450) ([ehelms](https://github.com/ehelms))
- Fixes [\#37384](https://projects.theforeman.org/issues/37384) - properly pass fips=false when checking keystore [\#444](https://github.com/theforeman/puppet-certs/pull/444) ([evgeni](https://github.com/evgeni))

**Merged pull requests:**

- Fix tests on EL9 [\#443](https://github.com/theforeman/puppet-certs/pull/443) ([ehelms](https://github.com/ehelms))

## [17.1.1](https://github.com/theforeman/puppet-certs/tree/17.1.1) (2024-04-25)

[Full Changelog](https://github.com/theforeman/puppet-certs/compare/17.0.1...17.1.1)

## [17.0.1](https://github.com/theforeman/puppet-certs/tree/17.0.1) (2024-04-25)

[Full Changelog](https://github.com/theforeman/puppet-certs/compare/17.1.0...17.0.1)

## [17.1.0](https://github.com/theforeman/puppet-certs/tree/17.1.0) (2024-02-19)

[Full Changelog](https://github.com/theforeman/puppet-certs/compare/17.0.0...17.1.0)

**Implemented enhancements:**

- Support EL9 [\#442](https://github.com/theforeman/puppet-certs/pull/442) ([ekohl](https://github.com/ekohl))
- Use automatic compression based on file path for tar [\#440](https://github.com/theforeman/puppet-certs/pull/440) ([ekohl](https://github.com/ekohl))

## [17.0.0](https://github.com/theforeman/puppet-certs/tree/17.0.0) (2023-11-12)

[Full Changelog](https://github.com/theforeman/puppet-certs/compare/16.1.1...17.0.0)

**Breaking changes:**

- Drop Puppet 6 support [\#435](https://github.com/theforeman/puppet-certs/pull/435) ([ekohl](https://github.com/ekohl))
- Remove default\_ca parameter [\#425](https://github.com/theforeman/puppet-certs/pull/425) ([ehelms](https://github.com/ehelms))
- puppetlabs/stdlib: Require 9.x [\#411](https://github.com/theforeman/puppet-certs/pull/411) ([bastelfreak](https://github.com/bastelfreak))

**Implemented enhancements:**

- Mark compatible with puppet-extlib 7.x [\#437](https://github.com/theforeman/puppet-certs/pull/437) ([ekohl](https://github.com/ekohl))
- Support changing passwords on keystores & truststores [\#428](https://github.com/theforeman/puppet-certs/pull/428) ([ekohl](https://github.com/ekohl))
- Document certs::apache parameters [\#423](https://github.com/theforeman/puppet-certs/pull/423) ([ekohl](https://github.com/ekohl))
- Set required params and autorequire [\#422](https://github.com/theforeman/puppet-certs/pull/422) ([ekohl](https://github.com/ekohl))
- Manage the build\_dir [\#419](https://github.com/theforeman/puppet-certs/pull/419) ([ehelms](https://github.com/ehelms))
- Remove unused full\_path method [\#418](https://github.com/theforeman/puppet-certs/pull/418) ([ekohl](https://github.com/ekohl))
- Deploy the CA password file to ssl build directory [\#416](https://github.com/theforeman/puppet-certs/pull/416) ([ehelms](https://github.com/ehelms))
- Add Puppet 8 support [\#412](https://github.com/theforeman/puppet-certs/pull/412) ([bastelfreak](https://github.com/bastelfreak))

**Fixed bugs:**

- Fix some RuboCop flagged issues for Puppet 8 support [\#438](https://github.com/theforeman/puppet-certs/pull/438) ([ekohl](https://github.com/ekohl))
- Handle more unknown password errors [\#432](https://github.com/theforeman/puppet-certs/pull/432) ([ekohl](https://github.com/ekohl))

## [16.1.1](https://github.com/theforeman/puppet-certs/tree/16.1.1) (2023-10-05)

[Full Changelog](https://github.com/theforeman/puppet-certs/compare/16.1.0...16.1.1)

## [16.1.0](https://github.com/theforeman/puppet-certs/tree/16.1.0) (2023-10-05)

[Full Changelog](https://github.com/theforeman/puppet-certs/compare/16.0.2...16.1.0)

## [16.0.2](https://github.com/theforeman/puppet-certs/tree/16.0.2) (2023-06-19)

[Full Changelog](https://github.com/theforeman/puppet-certs/compare/16.0.1...16.0.2)

**Fixed bugs:**

- Fix bad requires and old Puppet\_X notation [\#408](https://github.com/theforeman/puppet-certs/pull/408) ([coreone](https://github.com/coreone))

## [16.0.1](https://github.com/theforeman/puppet-certs/tree/16.0.1) (2023-05-15)

[Full Changelog](https://github.com/theforeman/puppet-certs/compare/16.0.0...16.0.1)

**Fixed bugs:**

- Remove unused puppetlabs-concat dependency [\#406](https://github.com/theforeman/puppet-certs/pull/406) ([ekohl](https://github.com/ekohl))

## [16.0.0](https://github.com/theforeman/puppet-certs/tree/16.0.0) (2022-10-28)

[Full Changelog](https://github.com/theforeman/puppet-certs/compare/15.1.1...16.0.0)

**Breaking changes:**

- Drop EL7 support [\#400](https://github.com/theforeman/puppet-certs/pull/400) ([ehelms](https://github.com/ehelms))
- Refs [\#35005](https://projects.theforeman.org/issues/35005): Drop certs::pulp\_client [\#399](https://github.com/theforeman/puppet-certs/pull/399) ([ehelms](https://github.com/ehelms))

**Implemented enhancements:**

- Update to voxpupuli-test 5 [\#401](https://github.com/theforeman/puppet-certs/pull/401) ([ekohl](https://github.com/ekohl))

**Fixed bugs:**

- Fixes [\#35335](https://projects.theforeman.org/issues/35335) - allow everyone to read the Katello CA certificate [\#403](https://github.com/theforeman/puppet-certs/pull/403) ([evgeni](https://github.com/evgeni))

## [15.1.1](https://github.com/theforeman/puppet-certs/tree/15.1.1) (2022-05-03)

[Full Changelog](https://github.com/theforeman/puppet-certs/compare/15.1.0...15.1.1)

**Fixed bugs:**

- Ensure nssdb private key changes when certificate changes [\#397](https://github.com/theforeman/puppet-certs/pull/397) ([ehelms](https://github.com/ehelms))

## [15.1.0](https://github.com/theforeman/puppet-certs/tree/15.1.0) (2022-03-15)

[Full Changelog](https://github.com/theforeman/puppet-certs/compare/15.0.0...15.1.0)

**Implemented enhancements:**

- Allow stdlib 8.x, extlib 6.x [\#392](https://github.com/theforeman/puppet-certs/pull/392) ([ekohl](https://github.com/ekohl))

**Fixed bugs:**

- Fixes [\#34598](https://projects.theforeman.org/issues/34598): Disable fips for keytool  [\#394](https://github.com/theforeman/puppet-certs/pull/394) ([ehelms](https://github.com/ehelms))

## [15.0.0](https://github.com/theforeman/puppet-certs/tree/15.0.0) (2022-02-03)

[Full Changelog](https://github.com/theforeman/puppet-certs/compare/14.0.0...15.0.0)

**Breaking changes:**

- Fixes [\#34189](https://projects.theforeman.org/issues/34189): Unencrypt CA key when deploying for Candlepin [\#386](https://github.com/theforeman/puppet-certs/pull/386) ([ehelms](https://github.com/ehelms))

**Fixed bugs:**

- Correctly pass the path to the tempfile when adding keystore certificates [\#385](https://github.com/theforeman/puppet-certs/pull/385) ([ehelms](https://github.com/ehelms))
- Reintroduce $apache\_ca\_cert [\#384](https://github.com/theforeman/puppet-certs/pull/384) ([ekohl](https://github.com/ekohl))

**Merged pull requests:**

- use foreman::repo to setup foreman repos during CI [\#390](https://github.com/theforeman/puppet-certs/pull/390) ([evgeni](https://github.com/evgeni))
- Mark classes as private using Puppet Strings [\#389](https://github.com/theforeman/puppet-certs/pull/389) ([ekohl](https://github.com/ekohl))

## [14.0.0](https://github.com/theforeman/puppet-certs/tree/14.0.0) (2021-10-29)

[Full Changelog](https://github.com/theforeman/puppet-certs/compare/13.0.0...14.0.0)

**Breaking changes:**

- Deploy certificates from build directory and drop the use of RPMs [\#370](https://github.com/theforeman/puppet-certs/pull/370) ([ehelms](https://github.com/ehelms))

**Implemented enhancements:**

- New cert key bundle type [\#380](https://github.com/theforeman/puppet-certs/pull/380) ([ehelms](https://github.com/ehelms))
- Add types for parameters for all classes [\#377](https://github.com/theforeman/puppet-certs/pull/377) ([ehelms](https://github.com/ehelms))
- Keep Candlepin CA key password protected [\#376](https://github.com/theforeman/puppet-certs/pull/376) ([ehelms](https://github.com/ehelms))

**Fixed bugs:**

- Allow passing string for hostname to certs::qpid\_router::client [\#379](https://github.com/theforeman/puppet-certs/pull/379) ([ehelms](https://github.com/ehelms))

## [13.0.0](https://github.com/theforeman/puppet-certs/tree/13.0.0) (2021-07-22)

[Full Changelog](https://github.com/theforeman/puppet-certs/compare/12.0.0...13.0.0)

**Breaking changes:**

- Drop Puppet 5 support [\#345](https://github.com/theforeman/puppet-certs/pull/345) ([ehelms](https://github.com/ehelms))

**Implemented enhancements:**

- Manage the certs::foreman ssl\_ca\_file [\#375](https://github.com/theforeman/puppet-certs/pull/375) ([ehelms](https://github.com/ehelms))
- Add owner, group parameters to certs::foreman [\#374](https://github.com/theforeman/puppet-certs/pull/374) ([ehelms](https://github.com/ehelms))
- Fixes [\#32382](https://projects.theforeman.org/issues/32382): Use certs::foreman client certificate to communicate wi… [\#371](https://github.com/theforeman/puppet-certs/pull/371) ([ehelms](https://github.com/ehelms))
- Support ensuring certs::keypair cert and key can be absent [\#365](https://github.com/theforeman/puppet-certs/pull/365) ([ehelms](https://github.com/ehelms))
- Include certs directory tarball [\#352](https://github.com/theforeman/puppet-certs/pull/352) ([ehelms](https://github.com/ehelms))
- Remove dependency on trusted\_ca [\#350](https://github.com/theforeman/puppet-certs/pull/350) ([ekohl](https://github.com/ekohl))
- Declare the build directory for all certificate creation [\#346](https://github.com/theforeman/puppet-certs/pull/346) ([ehelms](https://github.com/ehelms))
- Fixes [\#32511](https://projects.theforeman.org/issues/32511) - Add a puppet type and provider to manage an nssdb [\#344](https://github.com/theforeman/puppet-certs/pull/344) ([wbclark](https://github.com/wbclark))
- Fixes [\#32637](https://projects.theforeman.org/issues/32637): Add truststore type and provider  [\#336](https://github.com/theforeman/puppet-certs/pull/336) ([ehelms](https://github.com/ehelms))
- Fixes [\#32631](https://projects.theforeman.org/issues/32631): Add keystore\_certificate provider type [\#335](https://github.com/theforeman/puppet-certs/pull/335) ([ehelms](https://github.com/ehelms))
- Fixes [\#32506](https://projects.theforeman.org/issues/32506): Add keystore puppet provider type [\#334](https://github.com/theforeman/puppet-certs/pull/334) ([ehelms](https://github.com/ehelms))
- Fixes [\#32585](https://projects.theforeman.org/issues/32585): Add function to extract Artemis client certificate subj… [\#332](https://github.com/theforeman/puppet-certs/pull/332) ([ehelms](https://github.com/ehelms))
- Switch Foreman client certificates to root:foreman [\#330](https://github.com/theforeman/puppet-certs/pull/330) ([ehelms](https://github.com/ehelms))
- Fixes [\#32506](https://projects.theforeman.org/issues/32506): Add an nssdb\_certificate type and provider  [\#327](https://github.com/theforeman/puppet-certs/pull/327) ([ehelms](https://github.com/ehelms))
- Allow Puppet 7 compatible versions of mods [\#325](https://github.com/theforeman/puppet-certs/pull/325) ([ekohl](https://github.com/ekohl))

**Fixed bugs:**

- certs::foreman should inherit certs, but only inherits certs::params [\#362](https://github.com/theforeman/puppet-certs/issues/362)
- Refs [\#32506](https://projects.theforeman.org/issues/32506) - Avoid in place modification of array [\#341](https://github.com/theforeman/puppet-certs/pull/341) ([ekohl](https://github.com/ekohl))
- Fixes [\#32647](https://projects.theforeman.org/issues/32647): Do not show diff on password files [\#337](https://github.com/theforeman/puppet-certs/pull/337) ([ehelms](https://github.com/ehelms))

## [12.0.0](https://github.com/theforeman/puppet-certs/tree/12.0.0) (2021-04-27)

[Full Changelog](https://github.com/theforeman/puppet-certs/compare/11.0.0...12.0.0)

**Breaking changes:**

- Remove qpid\_client class and avoid resource defaults in qpid class [\#315](https://github.com/theforeman/puppet-certs/pull/315) ([ehelms](https://github.com/ehelms))

**Implemented enhancements:**

- Refs [\#31574](https://projects.theforeman.org/issues/31574): Compare SHA256 fingerprints when checking truststore [\#323](https://github.com/theforeman/puppet-certs/pull/323) ([ehelms](https://github.com/ehelms))
- Support Puppet 7 [\#319](https://github.com/theforeman/puppet-certs/pull/319) ([ekohl](https://github.com/ekohl))

**Fixed bugs:**

- Fixes [\#31574](https://projects.theforeman.org/issues/31574): Ensure truststore certificates get updated when they change [\#320](https://github.com/theforeman/puppet-certs/pull/320) ([ehelms](https://github.com/ehelms))

## [11.0.0](https://github.com/theforeman/puppet-certs/tree/11.0.0) (2021-02-19)

[Full Changelog](https://github.com/theforeman/puppet-certs/compare/10.1.0...11.0.0)

**Breaking changes:**

- Refs [\#31878](https://projects.theforeman.org/issues/31878) - Split qpid router server and client certificates [\#316](https://github.com/theforeman/puppet-certs/pull/316) ([ehelms](https://github.com/ehelms))
- Drop creation of mongodb certificates [\#307](https://github.com/theforeman/puppet-certs/pull/307) ([ehelms](https://github.com/ehelms))

## [10.1.0](https://github.com/theforeman/puppet-certs/tree/10.1.0) (2021-01-28)

[Full Changelog](https://github.com/theforeman/puppet-certs/compare/10.0.0...10.1.0)

**Implemented enhancements:**

- Convert parameters to static defaults [\#308](https://github.com/theforeman/puppet-certs/pull/308) ([ehelms](https://github.com/ehelms))

**Merged pull requests:**

- Revert "Convert foreman\_proxy\_content.pp parameters to static defaults" [\#310](https://github.com/theforeman/puppet-certs/pull/310) ([ekohl](https://github.com/ekohl))
- Move cname default back to params.pp due to Kafo improperly handling validation [\#309](https://github.com/theforeman/puppet-certs/pull/309) ([ehelms](https://github.com/ehelms))
- Removed unused rhsm\_reconfigure\_script [\#306](https://github.com/theforeman/puppet-certs/pull/306) ([ehelms](https://github.com/ehelms))

## [10.0.0](https://github.com/theforeman/puppet-certs/tree/10.0.0) (2020-10-29)

[Full Changelog](https://github.com/theforeman/puppet-certs/compare/9.0.0...10.0.0)

**Breaking changes:**

- Remove unused variables in params.pp [\#301](https://github.com/theforeman/puppet-certs/pull/301) ([ekohl](https://github.com/ekohl))
- Refs [\#30316](https://projects.theforeman.org/issues/30316): Cleanup bootstrap RPM generation code [\#294](https://github.com/theforeman/puppet-certs/pull/294) ([ehelms](https://github.com/ehelms))

**Implemented enhancements:**

- Change foreman-proxy file ownership to 440 [\#300](https://github.com/theforeman/puppet-certs/pull/300) ([ekohl](https://github.com/ekohl))

## [9.0.0](https://github.com/theforeman/puppet-certs/tree/9.0.0) (2020-08-05)

[Full Changelog](https://github.com/theforeman/puppet-certs/compare/8.0.0...9.0.0)

**Breaking changes:**

- Refs [\#30346](https://projects.theforeman.org/issues/30346): Generate a separate truststore for Candlepin [\#291](https://github.com/theforeman/puppet-certs/pull/291) ([ehelms](https://github.com/ehelms))
- Refs [\#30316](https://projects.theforeman.org/issues/30316): Drop bootstrap RPM code [\#290](https://github.com/theforeman/puppet-certs/pull/290) ([ehelms](https://github.com/ehelms))
- Fixes [\#30312](https://projects.theforeman.org/issues/30312): Drop docker, atomic and goferd support from consumer RPM [\#289](https://github.com/theforeman/puppet-certs/pull/289) ([ehelms](https://github.com/ehelms))

**Implemented enhancements:**

- Refs [\#30346](https://projects.theforeman.org/issues/30346) - allow override of candlepin client keypair group [\#295](https://github.com/theforeman/puppet-certs/pull/295) ([jturel](https://github.com/jturel))
- Refs [\#29715](https://projects.theforeman.org/issues/29715) - Create mongodb client certificate bundle [\#288](https://github.com/theforeman/puppet-certs/pull/288) ([ehelms](https://github.com/ehelms))
- Refs [\#29715](https://projects.theforeman.org/issues/29715): Add mongodb server and client certs [\#285](https://github.com/theforeman/puppet-certs/pull/285) ([ehelms](https://github.com/ehelms))

## [8.0.0](https://github.com/theforeman/puppet-certs/tree/8.0.0) (2020-05-14)

[Full Changelog](https://github.com/theforeman/puppet-certs/compare/7.0.0...8.0.0)

**Breaking changes:**

- Use modern facts [\#286](https://github.com/theforeman/puppet-certs/issues/286)
- Remove unused defines [\#280](https://github.com/theforeman/puppet-certs/pull/280) ([ekohl](https://github.com/ekohl))
- Refs [\#28924](https://projects.theforeman.org/issues/28924): Drop amqp key and truststore + generate Artemis client certs [\#275](https://github.com/theforeman/puppet-certs/pull/275) ([ehelms](https://github.com/ehelms))

**Implemented enhancements:**

- Refs [\#29215](https://projects.theforeman.org/issues/29215): Add RHEL 8 to metadata and run tests on all OSes [\#284](https://github.com/theforeman/puppet-certs/pull/284) ([ehelms](https://github.com/ehelms))
- Allow extlib 5.x [\#279](https://github.com/theforeman/puppet-certs/pull/279) ([mmoll](https://github.com/mmoll))
- Fixes [\#29195](https://projects.theforeman.org/issues/29195) - puppet-certs should run on el8 [\#278](https://github.com/theforeman/puppet-certs/pull/278) ([wbclark](https://github.com/wbclark))

**Fixed bugs:**

- Refs [\#28922](https://projects.theforeman.org/issues/28922): Replace keystore certificate if it changes [\#276](https://github.com/theforeman/puppet-certs/pull/276) ([ehelms](https://github.com/ehelms))

## [7.0.0](https://github.com/theforeman/puppet-certs/tree/7.0.0) (2020-02-11)

[Full Changelog](https://github.com/theforeman/puppet-certs/compare/6.1.1...7.0.0)

**Breaking changes:**

- Remove unused $regenerate\_ca parameter [\#268](https://github.com/theforeman/puppet-certs/pull/268) ([ekohl](https://github.com/ekohl))
- /etc/pki/pulp perms and group owner [\#266](https://github.com/theforeman/puppet-certs/pull/266) ([wbclark](https://github.com/wbclark))

## [6.1.1](https://github.com/theforeman/puppet-certs/tree/6.1.1) (2020-01-17)

[Full Changelog](https://github.com/theforeman/puppet-certs/compare/6.1.0...6.1.1)

**Implemented enhancements:**

- Expose the qpid nss cert name as a variable [\#265](https://github.com/theforeman/puppet-certs/pull/265) ([ekohl](https://github.com/ekohl))

**Fixed bugs:**

- Fixes [\#25683](https://projects.theforeman.org/issues/25683) - Do not run postun script if upgrading [\#267](https://github.com/theforeman/puppet-certs/pull/267) ([jlsherrill](https://github.com/jlsherrill))

**Merged pull requests:**

- Correct author case to name in metadata [\#263](https://github.com/theforeman/puppet-certs/pull/263) ([ekohl](https://github.com/ekohl))

## [6.1.0](https://github.com/theforeman/puppet-certs/tree/6.1.0) (2019-10-23)

[Full Changelog](https://github.com/theforeman/puppet-certs/compare/6.0.2...6.1.0)

**Implemented enhancements:**

- Set a variable that defines the Apache CA [\#261](https://github.com/theforeman/puppet-certs/pull/261) ([ekohl](https://github.com/ekohl))
- Fixes [\#27847](https://projects.theforeman.org/issues/27847) - Refactor foreman\_proxy\_content class [\#256](https://github.com/theforeman/puppet-certs/pull/256) ([ekohl](https://github.com/ekohl))

**Fixed bugs:**

- Refs [\#27847](https://projects.theforeman.org/issues/27847) - Use legacy facts [\#260](https://github.com/theforeman/puppet-certs/pull/260) ([ekohl](https://github.com/ekohl))
- Refs [\#27847](https://projects.theforeman.org/issues/27847) - Load CNAME default from params [\#259](https://github.com/theforeman/puppet-certs/pull/259) ([ekohl](https://github.com/ekohl))

## [6.0.2](https://github.com/theforeman/puppet-certs/tree/6.0.2) (2019-09-16)

[Full Changelog](https://github.com/theforeman/puppet-certs/compare/6.0.1...6.0.2)

**Fixed bugs:**

- Fixes [\#27857](https://projects.theforeman.org/issues/27857) - autorequire parent paths in types [\#257](https://github.com/theforeman/puppet-certs/pull/257) ([ekohl](https://github.com/ekohl))

## [6.0.1](https://github.com/theforeman/puppet-certs/tree/6.0.1) (2019-06-13)

[Full Changelog](https://github.com/theforeman/puppet-certs/compare/6.0.0...6.0.1)

**Merged pull requests:**

- allow newer versions of dependencies [\#253](https://github.com/theforeman/puppet-certs/pull/253) ([mmoll](https://github.com/mmoll))

## [6.0.0](https://github.com/theforeman/puppet-certs/tree/6.0.0) (2019-04-16)

[Full Changelog](https://github.com/theforeman/puppet-certs/compare/5.1.2...6.0.0)

**Breaking changes:**

- Drop Puppet 4 [\#251](https://github.com/theforeman/puppet-certs/pull/251) ([ekohl](https://github.com/ekohl))
- Move qpid client cert to /etc/pki/pulp [\#229](https://github.com/theforeman/puppet-certs/pull/229) ([ehelms](https://github.com/ehelms))
- Add CA cert to keystore as a trustedcert [\#245](https://github.com/theforeman/puppet-certs/pull/245) ([ehelms](https://github.com/ehelms))
- Add nssdb files for EL8 [\#244](https://github.com/theforeman/puppet-certs/pull/244) ([ehelms](https://github.com/ehelms))

## [5.1.2](https://github.com/theforeman/puppet-certs/tree/5.1.2) (2019-04-03)

[Full Changelog](https://github.com/theforeman/puppet-certs/compare/5.1.1...5.1.2)

**Fixed bugs:**

- Fixes [\#26119](https://projects.theforeman.org/issues/26119) - don't use md5 for digesting [\#246](https://github.com/theforeman/puppet-certs/pull/246) ([iNecas](https://github.com/iNecas))

## [5.1.1](https://github.com/theforeman/puppet-certs/tree/5.1.1) (2019-04-02)

[Full Changelog](https://github.com/theforeman/puppet-certs/compare/5.1.0...5.1.1)

**Fixed bugs:**

- Fixes [\#26180](https://projects.theforeman.org/issues/26180) Move type common module to PuppetX namespace so doesn't break 'puppet generate types' [\#249](https://github.com/theforeman/puppet-certs/pull/249) ([treydock](https://github.com/treydock))
- Fixes [\#26088](https://projects.theforeman.org/issues/26088) - ensure RSA word for SSLProxyMachineCertificateFile [\#243](https://github.com/theforeman/puppet-certs/pull/243) ([iNecas](https://github.com/iNecas))

## [5.1.0](https://github.com/theforeman/puppet-certs/tree/5.1.0) (2019-02-14)

[Full Changelog](https://github.com/theforeman/puppet-certs/compare/5.0.0...5.1.0)

**Implemented enhancements:**

- Fixes [\#25873](https://projects.theforeman.org/issues/25873) - Set rhsm package upload options [\#240](https://github.com/theforeman/puppet-certs/pull/240) ([parthaa](https://github.com/parthaa))

## [5.0.0](https://github.com/theforeman/puppet-certs/tree/5.0.0) (2019-01-11)

[Full Changelog](https://github.com/theforeman/puppet-certs/compare/4.4.2...5.0.0)

**Breaking changes:**

- Clean up $nss\_db\_dir handling [\#201](https://github.com/theforeman/puppet-certs/pull/201) ([ekohl](https://github.com/ekohl))

**Implemented enhancements:**

- Use FQDNs data types where appropriate [\#236](https://github.com/theforeman/puppet-certs/pull/236) ([ekohl](https://github.com/ekohl))
- Check the file is present in tar\_extract [\#230](https://github.com/theforeman/puppet-certs/pull/230) ([ekohl](https://github.com/ekohl))
- Add Puppet 6 support [\#226](https://github.com/theforeman/puppet-certs/pull/226) ([ekohl](https://github.com/ekohl))
- Move keystore to Candlepin default location [\#225](https://github.com/theforeman/puppet-certs/pull/225) ([ehelms](https://github.com/ehelms))
- Refs [\#24947](https://projects.theforeman.org/issues/24947) - Allow extract tar files at the top level [\#215](https://github.com/theforeman/puppet-certs/pull/215) ([ekohl](https://github.com/ekohl))

**Fixed bugs:**

- Fixes [\#25739](https://projects.theforeman.org/issues/25739) - don't allow statements to fail in an set -e script [\#234](https://github.com/theforeman/puppet-certs/pull/234) ([evgeni](https://github.com/evgeni))
- Fixes [\#25512](https://projects.theforeman.org/issues/25512) fixes incorrect editing of rhsm.conf [\#227](https://github.com/theforeman/puppet-certs/pull/227) ([patilsuraj767](https://github.com/patilsuraj767))

**Merged pull requests:**

- Use extlib namespaced functions [\#239](https://github.com/theforeman/puppet-certs/pull/239) ([ekohl](https://github.com/ekohl))
- Candlepin CA should be owned by tomcat user [\#232](https://github.com/theforeman/puppet-certs/pull/232) ([jturel](https://github.com/jturel))
- Deploy CA cert and key to Candlepin default locations [\#228](https://github.com/theforeman/puppet-certs/pull/228) ([ehelms](https://github.com/ehelms))

## [4.4.2](https://github.com/theforeman/puppet-certs/tree/4.4.2) (2018-11-29)

[Full Changelog](https://github.com/theforeman/puppet-certs/compare/4.4.1...4.4.2)

**Fixed bugs:**

- Fixes [\#25512](https://projects.theforeman.org/issues/25512) fixes incorrect editing of rhsm.conf [\#227](https://github.com/theforeman/puppet-certs/pull/227) ([patilsuraj767](https://github.com/patilsuraj767))
- Fix wrong redirect notation [\#224](https://github.com/theforeman/puppet-certs/pull/224) ([masatake](https://github.com/masatake))

## [4.4.1](https://github.com/theforeman/puppet-certs/tree/4.4.1) (2018-10-31)

[Full Changelog](https://github.com/theforeman/puppet-certs/compare/4.4.0...4.4.1)

**Fixed bugs:**

- Fixes [\#25359](https://projects.theforeman.org/issues/25359) - Add name flag to openssl pkcs12 nsddb key/cert convert. [\#223](https://github.com/theforeman/puppet-certs/pull/223) ([chris1984](https://github.com/chris1984))

## [4.4.0](https://github.com/theforeman/puppet-certs/tree/4.4.0) (2018-10-31)

[Full Changelog](https://github.com/theforeman/puppet-certs/compare/4.3.0...4.4.0)

**Implemented enhancements:**

- Rewrite validate\_file\_exists to a modern Ruby function [\#222](https://github.com/theforeman/puppet-certs/pull/222) ([ekohl](https://github.com/ekohl))
- Add support for debian derivatives [\#220](https://github.com/theforeman/puppet-certs/pull/220) ([m-bucher](https://github.com/m-bucher))

## [4.3.0](https://github.com/theforeman/puppet-certs/tree/4.3.0) (2018-10-05)

[Full Changelog](https://github.com/theforeman/puppet-certs/compare/4.2.0...4.3.0)

**Implemented enhancements:**

- Switch to puppet-trusted\_ca & allow puppet-extlib 3.0 [\#217](https://github.com/theforeman/puppet-certs/pull/217) ([ekohl](https://github.com/ekohl))
- set empty-password for nssdb as FIPS fails on password file [\#211](https://github.com/theforeman/puppet-certs/pull/211) ([amitkarsale](https://github.com/amitkarsale))

**Merged pull requests:**

- Allow stdlib & concat 5.x [\#216](https://github.com/theforeman/puppet-certs/pull/216) ([ekohl](https://github.com/ekohl))
- Do not let foreman\_proxy\_content inherit from params [\#214](https://github.com/theforeman/puppet-certs/pull/214) ([ekohl](https://github.com/ekohl))

## [4.2.0](https://github.com/theforeman/puppet-certs/tree/4.2.0) (2018-07-16)

[Full Changelog](https://github.com/theforeman/puppet-certs/compare/4.1.0...4.2.0)

**Implemented enhancements:**

- Fixes [\#16911](https://projects.theforeman.org/issues/16911) - Make $server\_cert\_req optional [\#172](https://github.com/theforeman/puppet-certs/pull/172) ([ekohl](https://github.com/ekohl))

**Fixed bugs:**

- fixes [\#24210](https://projects.theforeman.org/issues/24210) - certs group must be overridable [\#204](https://github.com/theforeman/puppet-certs/pull/204) ([stbenjam](https://github.com/stbenjam))

## [4.1.0](https://github.com/theforeman/puppet-certs/tree/4.1.0) (2018-05-29)

[Full Changelog](https://github.com/theforeman/puppet-certs/compare/4.0.1...4.1.0)

**Implemented enhancements:**

- Remove katello-common dependency [\#202](https://github.com/theforeman/puppet-certs/pull/202) ([jturel](https://github.com/jturel))
- Remove dependency on puppet-common [\#197](https://github.com/theforeman/puppet-certs/pull/197) ([jturel](https://github.com/jturel))
- candlepin: remove nssdb dependency [\#174](https://github.com/theforeman/puppet-certs/pull/174) ([timogoebel](https://github.com/timogoebel))

**Fixed bugs:**

- Refs [\#15963](https://projects.theforeman.org/issues/15963) - Fix documentation typos [\#203](https://github.com/theforeman/puppet-certs/pull/203) ([itsbill](https://github.com/itsbill))
- Fixes [\#22725](https://projects.theforeman.org/issues/22725) - Add newline to CA to prevent EOM error on registration. [\#198](https://github.com/theforeman/puppet-certs/pull/198) ([chris1984](https://github.com/chris1984))
- Fixes [\#22884](https://projects.theforeman.org/issues/22884) - Check RHSM version for hostname-override [\#195](https://github.com/theforeman/puppet-certs/pull/195) ([johnpmitsch](https://github.com/johnpmitsch))

## [4.0.1](https://github.com/theforeman/puppet-certs/tree/4.0.1) (2018-02-28)

[Full Changelog](https://github.com/theforeman/puppet-certs/compare/4.0.0...4.0.1)

**Fixed bugs:**

- Fix debian OS determination [\#193](https://github.com/theforeman/puppet-certs/pull/193) ([jturel](https://github.com/jturel))

## [4.0.0](https://github.com/theforeman/puppet-certs/tree/4.0.0) (2018-01-29)

[Full Changelog](https://github.com/theforeman/puppet-certs/compare/3.0.1...4.0.0)

**Breaking changes:**

- Stop managing tomcat keystore symlink [\#175](https://github.com/theforeman/puppet-certs/pull/175) ([ekohl](https://github.com/ekohl))

**Implemented enhancements:**

- Add "set -e" to consumer script [\#191](https://github.com/theforeman/puppet-certs/pull/191) ([mdellweg](https://github.com/mdellweg))
- Refs [\#21873](https://projects.theforeman.org/issues/21873) - Switch warn to fail [\#189](https://github.com/theforeman/puppet-certs/pull/189) ([chris1984](https://github.com/chris1984))
- Correct documentation on Candlepin certs [\#187](https://github.com/theforeman/puppet-certs/pull/187) ([ekohl](https://github.com/ekohl))
- Fixes [\#21873](https://projects.theforeman.org/issues/21873) - Add validation for proxy fqdn [\#186](https://github.com/theforeman/puppet-certs/pull/186) ([chris1984](https://github.com/chris1984))
- add debian support [\#184](https://github.com/theforeman/puppet-certs/pull/184) ([mdellweg](https://github.com/mdellweg))
- Update changelog & major version bump [\#180](https://github.com/theforeman/puppet-certs/pull/180) ([ekohl](https://github.com/ekohl))

**Merged pull requests:**

- Update Github URLs [\#182](https://github.com/theforeman/puppet-certs/pull/182) ([ekohl](https://github.com/ekohl))

## [3.1.0](https://github.com/theforeman/puppet-certs/tree/3.1.0)

[Full Changelog](https://github.com/theforeman/puppet-certs/compare/3.0.1...3.1.0)

**Merged pull requests:**

- Allow extlib 2.0 [\#178](https://github.com/theforeman/puppet-certs/pull/178) ([ekohl](https://github.com/ekohl))
- Correct stdlib dependency [\#177](https://github.com/theforeman/puppet-certs/pull/177) ([ekohl](https://github.com/ekohl))
- Use implicit dependency chaining on puppet [\#176](https://github.com/theforeman/puppet-certs/pull/176) ([ekohl](https://github.com/ekohl))
- Remove the $candlepin\_qpid\_exchange variable [\#171](https://github.com/theforeman/puppet-certs/pull/171) ([ekohl](https://github.com/ekohl))
- REAMDE: Remove dummy sections [\#170](https://github.com/theforeman/puppet-certs/pull/170) ([ekohl](https://github.com/ekohl))
- Use certs::keypair [\#169](https://github.com/theforeman/puppet-certs/pull/169) ([ekohl](https://github.com/ekohl))
- Drop apache username/password [\#168](https://github.com/theforeman/puppet-certs/pull/168) ([ekohl](https://github.com/ekohl))
- Add acceptance tests [\#167](https://github.com/theforeman/puppet-certs/pull/167) ([ekohl](https://github.com/ekohl))
- Document & parametrize certs::katello [\#166](https://github.com/theforeman/puppet-certs/pull/166) ([ekohl](https://github.com/ekohl))
- Add an acceptance test for candlepin [\#145](https://github.com/theforeman/puppet-certs/pull/145) ([ekohl](https://github.com/ekohl))

## [3.0.1](https://github.com/theforeman/puppet-certs/tree/3.0.0) (2017-11-29)
[Full Changelog](https://github.com/theforeman/puppet-certs/compare/3.0.0...3.0.1)

- Fixes [\#20642](https://projects.theforeman.org/issues/20642) - don't set hostname-override when localhost [\#164](https://github.com/theforeman/puppet-certs/pull/164) ([iNecas](https://github.com/iNecas))

## [3.0.0](https://github.com/theforeman/puppet-certs/tree/3.0.0) (2017-08-30)

[Full Changelog](https://github.com/theforeman/puppet-certs/compare/2.0.1...3.0.0)

**Merged pull requests:**

- Simplify variable access [\#165](https://github.com/theforeman/puppet-certs/pull/165) ([ekohl](https://github.com/ekohl))
- Allow puppetlabs-concat 4.0 [\#163](https://github.com/theforeman/puppet-certs/pull/163) ([ekohl](https://github.com/ekohl))
- msync: Puppet 5, parallel tests, .erb templates, cleanups, facter fix [\#162](https://github.com/theforeman/puppet-certs/pull/162) ([ekohl](https://github.com/ekohl))
- \#19578 - Switch to custom datatype for path validation [\#161](https://github.com/theforeman/puppet-certs/pull/161) ([NeilHanlon](https://github.com/NeilHanlon))
- Refactor to Puppet 4 types [\#159](https://github.com/theforeman/puppet-certs/pull/159) ([sean797](https://github.com/sean797))

## [2.0.1](https://github.com/theforeman/puppet-certs/tree/2.0.1) (2017-06-01)

[Full Changelog](https://github.com/theforeman/puppet-certs/compare/2.0.0...2.0.1)

**Merged pull requests:**

- Fixes [\#19734](https://projects.theforeman.org/issues/19734) - enforce proper exection order for Candlepin [\#158](https://github.com/theforeman/puppet-certs/pull/158) ([evgeni](https://github.com/evgeni))
- modulesync: Drop puppet 3, improve testing infra [\#157](https://github.com/theforeman/puppet-certs/pull/157) ([ekohl](https://github.com/ekohl))
- Fixes [\#19271](https://projects.theforeman.org/issues/19271) - reload docker instead of restart [\#156](https://github.com/theforeman/puppet-certs/pull/156) ([ahumbe](https://github.com/ahumbe))
- fixes [\#19259](https://projects.theforeman.org/issues/19259) - apache key should be mode 0440 [\#154](https://github.com/theforeman/puppet-certs/pull/154) ([stbenjam](https://github.com/stbenjam))

## [2.0.0](https://github.com/theforeman/puppet-certs/tree/2.0.0) (2017-04-07)

[Full Changelog](https://github.com/theforeman/puppet-certs/compare/1.0.1...2.0.0)

**Closed issues:**

- Proxy install failing [\#149](https://github.com/theforeman/puppet-certs/issues/149)

**Merged pull requests:**

- Expand ignore with generated files/directories [\#153](https://github.com/theforeman/puppet-certs/pull/153) ([ekohl](https://github.com/ekohl))
- Simplifications & some specs [\#152](https://github.com/theforeman/puppet-certs/pull/152) ([ekohl](https://github.com/ekohl))
- Modulesync update [\#151](https://github.com/theforeman/puppet-certs/pull/151) ([ekohl](https://github.com/ekohl))
- Contain classes in init to preserve relationships [\#150](https://github.com/theforeman/puppet-certs/pull/150) ([ehelms](https://github.com/ehelms))
- Remove a dependency on theforeman-foreman [\#147](https://github.com/theforeman/puppet-certs/pull/147) ([ekohl](https://github.com/ekohl))
- Modulesync update [\#146](https://github.com/theforeman/puppet-certs/pull/146) ([ekohl](https://github.com/ekohl))
- Fix qpid dependency on apache [\#144](https://github.com/theforeman/puppet-certs/pull/144) ([ekohl](https://github.com/ekohl))
- Deploy CA cert for Foreman to talk to proxy [\#143](https://github.com/theforeman/puppet-certs/pull/143) ([ehelms](https://github.com/ehelms))
- remove dependencies to external modules [\#142](https://github.com/theforeman/puppet-certs/pull/142) ([timogoebel](https://github.com/timogoebel))
- move qpidd reload to katello module [\#141](https://github.com/theforeman/puppet-certs/pull/141) ([timogoebel](https://github.com/timogoebel))
- qpid does not need apache [\#140](https://github.com/theforeman/puppet-certs/pull/140) ([timogoebel](https://github.com/timogoebel))
- extract nssdb creation into separate class [\#139](https://github.com/theforeman/puppet-certs/pull/139) ([timogoebel](https://github.com/timogoebel))
- extract ca code from init.pp [\#138](https://github.com/theforeman/puppet-certs/pull/138) ([timogoebel](https://github.com/timogoebel))
- Introduce certs::keypair [\#137](https://github.com/theforeman/puppet-certs/pull/137) ([ekohl](https://github.com/ekohl))
- foreman\_proxy does not need foreman user [\#136](https://github.com/theforeman/puppet-certs/pull/136) ([timogoebel](https://github.com/timogoebel))
- fix keytool idempotency [\#135](https://github.com/theforeman/puppet-certs/pull/135) ([timogoebel](https://github.com/timogoebel))
- move qpid exchange creation to puppet-candlepin module [\#134](https://github.com/theforeman/puppet-certs/pull/134) ([timogoebel](https://github.com/timogoebel))
- fixtures.yml uses https [\#133](https://github.com/theforeman/puppet-certs/pull/133) ([timogoebel](https://github.com/timogoebel))
- fix README [\#132](https://github.com/theforeman/puppet-certs/pull/132) ([timogoebel](https://github.com/timogoebel))
- classes inherit from init [\#131](https://github.com/theforeman/puppet-certs/pull/131) ([timogoebel](https://github.com/timogoebel))
- Allow newer versions of dependencies [\#130](https://github.com/theforeman/puppet-certs/pull/130) ([ekohl](https://github.com/ekohl))
- Make variable usage and indenting consistent [\#129](https://github.com/theforeman/puppet-certs/pull/129) ([ekohl](https://github.com/ekohl))
- fixes [\#17378](https://projects.theforeman.org/issues/17378) - tomcat has dedicated certificate [\#128](https://github.com/theforeman/puppet-certs/pull/128) ([timogoebel](https://github.com/timogoebel))
- fixes [\#17572](https://projects.theforeman.org/issues/17572) - module works with master compile [\#127](https://github.com/theforeman/puppet-certs/pull/127) ([timogoebel](https://github.com/timogoebel))
- Update modulesync config [\#125](https://github.com/theforeman/puppet-certs/pull/125) ([ekohl](https://github.com/ekohl))
- Only reference ::certs::params values in foreman\_proxy\_content [\#124](https://github.com/theforeman/puppet-certs/pull/124) ([stbenjam](https://github.com/stbenjam))
- fixes [\#17714](https://projects.theforeman.org/issues/17714) - use pki dir for puppet client certs [\#117](https://github.com/theforeman/puppet-certs/pull/117) ([stbenjam](https://github.com/stbenjam))

## [1.0.1](https://github.com/theforeman/puppet-certs/tree/1.0.1) (2017-01-24)

[Full Changelog](https://github.com/theforeman/puppet-certs/compare/1.0.0...1.0.1)

**Merged pull requests:**

- refs [\#17366](https://projects.theforeman.org/issues/17366) - remove capsule.pp [\#123](https://github.com/theforeman/puppet-certs/pull/123) ([stbenjam](https://github.com/stbenjam))
- Remove EL6 support [\#122](https://github.com/theforeman/puppet-certs/pull/122) ([ekohl](https://github.com/ekohl))
- fixes [\#17863](https://projects.theforeman.org/issues/17863) - use puppet user not uid [\#121](https://github.com/theforeman/puppet-certs/pull/121) ([stbenjam](https://github.com/stbenjam))
- refs [\#15931](https://projects.theforeman.org/issues/15931) - allow passing the cname parameter when generating certs [\#120](https://github.com/theforeman/puppet-certs/pull/120) ([evgeni](https://github.com/evgeni))
- Change existing Kafo type definitions to Puppet 4 types [\#114](https://github.com/theforeman/puppet-certs/pull/114) ([stbenjam](https://github.com/stbenjam))

## [1.0.0](https://github.com/theforeman/puppet-certs/tree/1.0.0) (2016-12-29)

[Full Changelog](https://github.com/theforeman/puppet-certs/compare/0.7.5...1.0.0)

**Merged pull requests:**

- Changed tar option to determine the file is compressed or not [\#119](https://github.com/theforeman/puppet-certs/pull/119) ([netman2k](https://github.com/netman2k))
- Fixes [\#17721](https://projects.theforeman.org/issues/17721) - check for fqdn before adding custom fact [\#116](https://github.com/theforeman/puppet-certs/pull/116) ([jlsherrill](https://github.com/jlsherrill))
- fixes [\#17658](https://projects.theforeman.org/issues/17658) - support restarting goferd on OS's with systemd, too [\#115](https://github.com/theforeman/puppet-certs/pull/115) ([stbenjam](https://github.com/stbenjam))

## [0.7.5](https://github.com/theforeman/puppet-certs/tree/0.7.5) (2016-12-14)

[Full Changelog](https://github.com/theforeman/puppet-certs/compare/0.7.4...0.7.5)

## [0.7.4](https://github.com/theforeman/puppet-certs/tree/0.7.4) (2016-12-14)

[Full Changelog](https://github.com/theforeman/puppet-certs/compare/0.7.1...0.7.4)

**Merged pull requests:**

- Require puppet server installed before setting file user to puppet [\#113](https://github.com/theforeman/puppet-certs/pull/113) ([ehelms](https://github.com/ehelms))
- module sync update [\#112](https://github.com/theforeman/puppet-certs/pull/112) ([jlsherrill](https://github.com/jlsherrill))
- refs [\#17366](https://projects.theforeman.org/issues/17366) - change references from capsule to foreman\_proxy\_content [\#111](https://github.com/theforeman/puppet-certs/pull/111) ([stbenjam](https://github.com/stbenjam))
- Modulesync, bump major for 1.8.7/el6 drop [\#110](https://github.com/theforeman/puppet-certs/pull/110) ([stbenjam](https://github.com/stbenjam))
- Modulesync [\#109](https://github.com/theforeman/puppet-certs/pull/109) ([stbenjam](https://github.com/stbenjam))
- Modulesync [\#108](https://github.com/theforeman/puppet-certs/pull/108) ([stbenjam](https://github.com/stbenjam))
- fixes [\#16945](https://projects.theforeman.org/issues/16945) - use node\_fqdn for consumer cert RPM generation [\#107](https://github.com/theforeman/puppet-certs/pull/107) ([stbenjam](https://github.com/stbenjam))
- Modulesync: rspec-puppet-facts updates [\#106](https://github.com/theforeman/puppet-certs/pull/106) ([stbenjam](https://github.com/stbenjam))
- refs [\#10283](https://projects.theforeman.org/issues/10283) - mark parameters advanced [\#101](https://github.com/theforeman/puppet-certs/pull/101) ([stbenjam](https://github.com/stbenjam))
- Refs [\#16134](https://projects.theforeman.org/issues/16134) - deploy hostname override fact [\#100](https://github.com/theforeman/puppet-certs/pull/100) ([jlsherrill](https://github.com/jlsherrill))
- refs [\#11737](https://projects.theforeman.org/issues/11737) - support cnames and add localhost cname to qpid certs [\#65](https://github.com/theforeman/puppet-certs/pull/65) ([stbenjam](https://github.com/stbenjam))

## [0.7.1](https://github.com/theforeman/puppet-certs/tree/0.7.1) (2016-09-14)

[Full Changelog](https://github.com/theforeman/puppet-certs/compare/0.7.0...0.7.1)

**Merged pull requests:**

- Bump foreman dependency [\#105](https://github.com/theforeman/puppet-certs/pull/105) ([beav](https://github.com/beav))

## [0.7.0](https://github.com/theforeman/puppet-certs/tree/0.7.0) (2016-09-12)

[Full Changelog](https://github.com/theforeman/puppet-certs/compare/0.6.0...0.7.0)

**Merged pull requests:**

- Fixes [\#16388](https://projects.theforeman.org/issues/16388) - rpm -e katello-ca-consumer rpm should revert rhsm.conf [\#104](https://github.com/theforeman/puppet-certs/pull/104) ([sean797](https://github.com/sean797))
- Modulesync update [\#103](https://github.com/theforeman/puppet-certs/pull/103) ([ehelms](https://github.com/ehelms))
- Remove unused password\_file\_dir parameter [\#102](https://github.com/theforeman/puppet-certs/pull/102) ([ekohl](https://github.com/ekohl))
- Use /etc/puppet for client SSL certificates [\#99](https://github.com/theforeman/puppet-certs/pull/99) ([stbenjam](https://github.com/stbenjam))
- Move tomcat name logic to puppet-certs [\#98](https://github.com/theforeman/puppet-certs/pull/98) ([stbenjam](https://github.com/stbenjam))
- Update rhsm config template for puppet 4 [\#97](https://github.com/theforeman/puppet-certs/pull/97) ([beav](https://github.com/beav))
- fixes [\#15882](https://projects.theforeman.org/issues/15882) - support AIO paths for puppet [\#95](https://github.com/theforeman/puppet-certs/pull/95) ([stbenjam](https://github.com/stbenjam))
- Fixes [\#15700](https://projects.theforeman.org/issues/15700) - make sure change of certs propagates changes in nssdb [\#94](https://github.com/theforeman/puppet-certs/pull/94) ([iNecas](https://github.com/iNecas))
- Modulesync: pin json\_pure [\#93](https://github.com/theforeman/puppet-certs/pull/93) ([stbenjam](https://github.com/stbenjam))
- Refs [\#15538](https://projects.theforeman.org/issues/15538): Check for nssdb cert as the beginning of a line [\#92](https://github.com/theforeman/puppet-certs/pull/92) ([ehelms](https://github.com/ehelms))
- Fixes [\#15538](https://projects.theforeman.org/issues/15538) - make sure the rpms from ssl-build are used [\#91](https://github.com/theforeman/puppet-certs/pull/91) ([iNecas](https://github.com/iNecas))
- Pin extlib since they dropped 1.8.7 support [\#90](https://github.com/theforeman/puppet-certs/pull/90) ([stbenjam](https://github.com/stbenjam))
- refs [\#15217](https://projects.theforeman.org/issues/15217) - puppet 4 support [\#89](https://github.com/theforeman/puppet-certs/pull/89) ([stbenjam](https://github.com/stbenjam))

## [0.6.0](https://github.com/theforeman/puppet-certs/tree/0.6.0) (2016-05-27)

[Full Changelog](https://github.com/theforeman/puppet-certs/compare/0.5.0...0.6.0)

**Merged pull requests:**

- fixes [\#15063](https://projects.theforeman.org/issues/15063) - remove client cert configuration [\#88](https://github.com/theforeman/puppet-certs/pull/88) ([stbenjam](https://github.com/stbenjam))
- Refs [\#12266](https://projects.theforeman.org/issues/12266) - fixing case where no certs exist [\#86](https://github.com/theforeman/puppet-certs/pull/86) ([jlsherrill](https://github.com/jlsherrill))
- Refs [\#14858](https://projects.theforeman.org/issues/14858) - removes gutterball [\#85](https://github.com/theforeman/puppet-certs/pull/85) ([cfouant](https://github.com/cfouant))
- Refs [\#12266](https://projects.theforeman.org/issues/12266) - Fixes no implicit conversion of Hash into String [\#84](https://github.com/theforeman/puppet-certs/pull/84) ([jlsherrill](https://github.com/jlsherrill))
- Fixes [\#12266](https://projects.theforeman.org/issues/12266): Handle last RPM sort for more than 10 bootstrap RPMs [\#83](https://github.com/theforeman/puppet-certs/pull/83) ([ehelms](https://github.com/ehelms))
- Add paths for puppet-lint docs check [\#82](https://github.com/theforeman/puppet-certs/pull/82) ([stbenjam](https://github.com/stbenjam))
- Fixes [\#14223](https://projects.theforeman.org/issues/14223) - Handles atomic machine detection properly [\#81](https://github.com/theforeman/puppet-certs/pull/81) ([parthaa](https://github.com/parthaa))

## [0.5.0](https://github.com/theforeman/puppet-certs/tree/0.5.0) (2016-03-16)

[Full Changelog](https://github.com/theforeman/puppet-certs/compare/0.4.1...0.5.0)

**Merged pull requests:**

- Modulesync [\#80](https://github.com/theforeman/puppet-certs/pull/80) ([stbenjam](https://github.com/stbenjam))
- Fixes [\#14188](https://projects.theforeman.org/issues/14188) - change pulp\_parent to qpid\_client class [\#78](https://github.com/theforeman/puppet-certs/pull/78) ([johnpmitsch](https://github.com/johnpmitsch))

## [0.4.1](https://github.com/theforeman/puppet-certs/tree/0.4.1) (2016-03-01)

[Full Changelog](https://github.com/theforeman/puppet-certs/compare/0.4.0...0.4.1)

**Merged pull requests:**

- Fixes [\#13925](https://projects.theforeman.org/issues/13925): Use concat to build reconfigure script [\#77](https://github.com/theforeman/puppet-certs/pull/77) ([ehelms](https://github.com/ehelms))
- fix bootstrap rpm in katello\_devel install [\#76](https://github.com/theforeman/puppet-certs/pull/76) ([jlsherrill](https://github.com/jlsherrill))

## [0.4.0](https://github.com/theforeman/puppet-certs/tree/0.4.0) (2016-02-24)

[Full Changelog](https://github.com/theforeman/puppet-certs/compare/0.2.0...0.4.0)

**Merged pull requests:**

- Fixes [\#13658](https://projects.theforeman.org/issues/13658) - pulp\_client\_key and pulp\_client\_cert not being set cor… [\#75](https://github.com/theforeman/puppet-certs/pull/75) ([johnpmitsch](https://github.com/johnpmitsch))
- Fixes [\#13635](https://projects.theforeman.org/issues/13635) - set pulp client cert settings [\#73](https://github.com/theforeman/puppet-certs/pull/73) ([johnpmitsch](https://github.com/johnpmitsch))
- Fixes [\#13634](https://projects.theforeman.org/issues/13634) - Adding Katello cert to ca-trust [\#72](https://github.com/theforeman/puppet-certs/pull/72) ([parthaa](https://github.com/parthaa))
- Fixes [\#13489](https://projects.theforeman.org/issues/13489) - fixes group on pulp\_client cert [\#71](https://github.com/theforeman/puppet-certs/pull/71) ([cfouant](https://github.com/cfouant))
- Fixes [\#13188](https://projects.theforeman.org/issues/13188) - Creates certificates for capsule authentication [\#70](https://github.com/theforeman/puppet-certs/pull/70) ([cfouant](https://github.com/cfouant))
- Fixes [\#10052](https://projects.theforeman.org/issues/10052) - Code to setup rhsm.conf for atomic hosts [\#67](https://github.com/theforeman/puppet-certs/pull/67) ([parthaa](https://github.com/parthaa))

## [0.2.0](https://github.com/theforeman/puppet-certs/tree/0.2.0) (2015-10-15)

[Full Changelog](https://github.com/theforeman/puppet-certs/compare/0.1.0...0.2.0)

**Merged pull requests:**

- Use cache\_data and random\_password from extlib [\#68](https://github.com/theforeman/puppet-certs/pull/68) ([ehelms](https://github.com/ehelms))
- Pulp consumer\_ca\_cert is now ca\_cert [\#66](https://github.com/theforeman/puppet-certs/pull/66) ([ehelms](https://github.com/ehelms))
- Add forge and travis badges to README [\#64](https://github.com/theforeman/puppet-certs/pull/64) ([stbenjam](https://github.com/stbenjam))
- Fixes [\#11755](https://projects.theforeman.org/issues/11755): Validate absolute path for custom certificates [\#58](https://github.com/theforeman/puppet-certs/pull/58) ([ehelms](https://github.com/ehelms))

## [0.1.0](https://github.com/theforeman/puppet-certs/tree/0.1.0) (2015-07-20)

[Full Changelog](https://github.com/theforeman/puppet-certs/compare/7f082050ca4711b7f46fd053801c0a2475ceedf4...0.1.0)

**Merged pull requests:**

- Prepare puppet-certs for release [\#63](https://github.com/theforeman/puppet-certs/pull/63) ([stbenjam](https://github.com/stbenjam))
- Fixes [\#10670](https://projects.theforeman.org/issues/10670) - deploy the katello-default-ca as part of the bootstrap RPM [\#62](https://github.com/theforeman/puppet-certs/pull/62) ([iNecas](https://github.com/iNecas))
- Fixes [\#10097](https://projects.theforeman.org/issues/10097) - Fixed references to city [\#61](https://github.com/theforeman/puppet-certs/pull/61) ([adamruzicka](https://github.com/adamruzicka))
- Updates from modulesync. [\#60](https://github.com/theforeman/puppet-certs/pull/60) ([ehelms](https://github.com/ehelms))
- fixes [\#10350](https://projects.theforeman.org/issues/10350) - switch to qdrouterd user for certs + keys [\#59](https://github.com/theforeman/puppet-certs/pull/59) ([mccun934](https://github.com/mccun934))
- Fixes [\#9888](https://projects.theforeman.org/issues/9888) - use random\_password over generate\_password [\#57](https://github.com/theforeman/puppet-certs/pull/57) ([dustints](https://github.com/dustints))
- Fixes [\#9875](https://projects.theforeman.org/issues/9875): Better docker service restart [\#56](https://github.com/theforeman/puppet-certs/pull/56) ([elyezer](https://github.com/elyezer))
- Pin rspec on ruby 1.8.7 [\#55](https://github.com/theforeman/puppet-certs/pull/55) ([stbenjam](https://github.com/stbenjam))
- Fixes [\#9699](https://projects.theforeman.org/issues/9699): Check for nssdb creation before running certutil. [\#54](https://github.com/theforeman/puppet-certs/pull/54) ([ehelms](https://github.com/ehelms))
- fixes [\#8636](https://projects.theforeman.org/issues/8636) - Katello CA cert now trusted system wide [\#53](https://github.com/theforeman/puppet-certs/pull/53) ([jlsherrill](https://github.com/jlsherrill))
- refs [\#9392](https://projects.theforeman.org/issues/9392) - pass options to foreman-rake config command correctly  [\#52](https://github.com/theforeman/puppet-certs/pull/52) ([stbenjam](https://github.com/stbenjam))
- refs [\#8175](https://projects.theforeman.org/issues/8175) - certificates for dispatch router [\#51](https://github.com/theforeman/puppet-certs/pull/51) ([stbenjam](https://github.com/stbenjam))
- Fixes [\#9392](https://projects.theforeman.org/issues/9392) - Substitute foreman-config \(deprecated\) for foreman-rake config [\#50](https://github.com/theforeman/puppet-certs/pull/50) ([dLobatog](https://github.com/dLobatog))
- Fixes [\#9204](https://projects.theforeman.org/issues/9204): Resolve conflict with similar cert names. [\#48](https://github.com/theforeman/puppet-certs/pull/48) ([ehelms](https://github.com/ehelms))
- Refs [\#8756](https://projects.theforeman.org/issues/8756): Ensure server ca file exists before deploying. [\#47](https://github.com/theforeman/puppet-certs/pull/47) ([ehelms](https://github.com/ehelms))
- Refs [\#7745](https://projects.theforeman.org/issues/7745): Deploy client cert bundle specifically for use by the Capsul... [\#45](https://github.com/theforeman/puppet-certs/pull/45) ([ehelms](https://github.com/ehelms))
- Refs [\#8756](https://projects.theforeman.org/issues/8756): Deploy the server\_ca to the Capsule directories for RHSM. [\#44](https://github.com/theforeman/puppet-certs/pull/44) ([ehelms](https://github.com/ehelms))
- Refs [\#8756](https://projects.theforeman.org/issues/8756): Allow configuring the RHSM port. [\#43](https://github.com/theforeman/puppet-certs/pull/43) ([ehelms](https://github.com/ehelms))
- Fixes [\#8850](https://projects.theforeman.org/issues/8850) - import gutterball cert after katello nssdb exists [\#42](https://github.com/theforeman/puppet-certs/pull/42) ([dustints](https://github.com/dustints))
- Refs [\#8372](https://projects.theforeman.org/issues/8372) - generate client certificates to be used by the smart proxy [\#41](https://github.com/theforeman/puppet-certs/pull/41) ([iNecas](https://github.com/iNecas))
- Ref \#8548 - creates and installs certs for gutterball [\#40](https://github.com/theforeman/puppet-certs/pull/40) ([dustints](https://github.com/dustints))
- Refs [\#8270](https://projects.theforeman.org/issues/8270): Let defaults be defined by params. [\#39](https://github.com/theforeman/puppet-certs/pull/39) ([ehelms](https://github.com/ehelms))
- fixes [\#8261](https://projects.theforeman.org/issues/8261) - use Default Organization for certificate org [\#38](https://github.com/theforeman/puppet-certs/pull/38) ([stbenjam](https://github.com/stbenjam))
- fixes [\#7633](https://projects.theforeman.org/issues/7633) - depend on katello-common \>= 0.0.1 [\#37](https://github.com/theforeman/puppet-certs/pull/37) ([stbenjam](https://github.com/stbenjam))
- refs [\#7558](https://projects.theforeman.org/issues/7558) - make CA readable by foreman and deploy CA crt to pub  [\#36](https://github.com/theforeman/puppet-certs/pull/36) ([stbenjam](https://github.com/stbenjam))
- Readme [\#35](https://github.com/theforeman/puppet-certs/pull/35) ([iNecas](https://github.com/iNecas))
- Add qpidd group and candlepin event topic as params [\#34](https://github.com/theforeman/puppet-certs/pull/34) ([dustints](https://github.com/dustints))
- Refs [\#7104](https://projects.theforeman.org/issues/7104) - ensure the qpidd is really running before configuring it [\#33](https://github.com/theforeman/puppet-certs/pull/33) ([iNecas](https://github.com/iNecas))
- Fixes [\#7239](https://projects.theforeman.org/issues/7239) - make sure the qpid client cert is deployed before the pulp migrations [\#32](https://github.com/theforeman/puppet-certs/pull/32) ([iNecas](https://github.com/iNecas))
- Fixes [\#7210](https://projects.theforeman.org/issues/7210) - make sure the Package\['pulp-server'\] is defined [\#31](https://github.com/theforeman/puppet-certs/pull/31) ([iNecas](https://github.com/iNecas))
- Refs [\#6736](https://projects.theforeman.org/issues/6736): Updates to standard layout and basic test. [\#30](https://github.com/theforeman/puppet-certs/pull/30) ([ehelms](https://github.com/ehelms))
- Refs [\#7147](https://projects.theforeman.org/issues/7147) - lock puppet-lint to \<= 1.0.0 [\#29](https://github.com/theforeman/puppet-certs/pull/29) ([iNecas](https://github.com/iNecas))
- fixes [\#7029](https://projects.theforeman.org/issues/7029) - fixing bootstrap of older rhsm clients [\#27](https://github.com/theforeman/puppet-certs/pull/27) ([jlsherrill](https://github.com/jlsherrill))
- fixes [\#7007](https://projects.theforeman.org/issues/7007) - require pulp-server to be installed before cert work [\#26](https://github.com/theforeman/puppet-certs/pull/26) ([jlsherrill](https://github.com/jlsherrill))
- Refs [\#6875](https://projects.theforeman.org/issues/6875) - separate the default CA and server CA [\#25](https://github.com/theforeman/puppet-certs/pull/25) ([iNecas](https://github.com/iNecas))
- Refs [\#6126](https://projects.theforeman.org/issues/6126): Fully specify deployment URL for RHSM. [\#24](https://github.com/theforeman/puppet-certs/pull/24) ([ehelms](https://github.com/ehelms))
- Refs [\#6418](https://projects.theforeman.org/issues/6418) - Fix keytool use for Java 6 compatibility. [\#22](https://github.com/theforeman/puppet-certs/pull/22) ([awood](https://github.com/awood))
- Set up certificates for Candlepin/Qpid integration. [\#21](https://github.com/theforeman/puppet-certs/pull/21) ([awood](https://github.com/awood))
- Fixes [\#6359](https://projects.theforeman.org/issues/6359) - consumer rpm err set full\_refresh [\#20](https://github.com/theforeman/puppet-certs/pull/20) ([dustints](https://github.com/dustints))
- Fixes [\#4650](https://projects.theforeman.org/issues/4650) - consumer cert alias for katello [\#19](https://github.com/theforeman/puppet-certs/pull/19) ([dustints](https://github.com/dustints))
- Fixes [\#5599](https://projects.theforeman.org/issues/5599): Set cert expirations to 20 years by default. [\#18](https://github.com/theforeman/puppet-certs/pull/18) ([ehelms](https://github.com/ehelms))
- Fixes [\#6140](https://projects.theforeman.org/issues/6140) - support RHEL 7 [\#16](https://github.com/theforeman/puppet-certs/pull/16) ([jmontleon](https://github.com/jmontleon))
- Fixes [\#5823](https://projects.theforeman.org/issues/5823) - full\_refresh\_on\_yum=1 to rhsm.conf [\#15](https://github.com/theforeman/puppet-certs/pull/15) ([dustints](https://github.com/dustints))
- Refs [\#5815](https://projects.theforeman.org/issues/5815) - generate certs for node qpid [\#14](https://github.com/theforeman/puppet-certs/pull/14) ([iNecas](https://github.com/iNecas))
- fixes [\#5486](https://projects.theforeman.org/issues/5486)  prefix and candlepin url incorrect for rhsm template on dev... [\#13](https://github.com/theforeman/puppet-certs/pull/13) ([dustints](https://github.com/dustints))
- Refs [\#5423](https://projects.theforeman.org/issues/5423) - fix certs generation for capsule usage [\#12](https://github.com/theforeman/puppet-certs/pull/12) ([iNecas](https://github.com/iNecas))
- Fixing [\#5299](https://projects.theforeman.org/issues/5299): variables not used properly. [\#11](https://github.com/theforeman/puppet-certs/pull/11) ([omaciel](https://github.com/omaciel))
- Parameterize node certs and removes reliance on directories not yet crea... [\#10](https://github.com/theforeman/puppet-certs/pull/10) ([ehelms](https://github.com/ehelms))
- Addresses changes made to katello-certs-tools regarding location of [\#9](https://github.com/theforeman/puppet-certs/pull/9) ([ehelms](https://github.com/ehelms))
- Capsule related certs settings [\#8](https://github.com/theforeman/puppet-certs/pull/8) ([iNecas](https://github.com/iNecas))
- fixing perms on apache key cert [\#7](https://github.com/theforeman/puppet-certs/pull/7) ([jlsherrill](https://github.com/jlsherrill))
- Provides clean up and ordering change of parameters to reduce dependency [\#6](https://github.com/theforeman/puppet-certs/pull/6) ([ehelms](https://github.com/ehelms))
- adjusting the cert module to work with the new apache module [\#5](https://github.com/theforeman/puppet-certs/pull/5) ([jlsherrill](https://github.com/jlsherrill))
- Certs module cleanup [\#3](https://github.com/theforeman/puppet-certs/pull/3) ([iNecas](https://github.com/iNecas))
- Parameterizing the module and removing coupling to the Katello module. [\#2](https://github.com/theforeman/puppet-certs/pull/2) ([ehelms](https://github.com/ehelms))
