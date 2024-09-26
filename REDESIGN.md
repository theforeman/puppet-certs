# Redesign of Certificate Handling

This document is not intended to be merged to the repository in the end.
This document aims to be an outline of the design strategy envisioned for this repository, and the roadmap of changes needed to help get it there.
This document is intended to help with discussions and information sharing to make the large set of smaller PRs coming in easier to understand with respect to the overall strategy.
This document will get updated with PRs as they aim at each Roadmap item as well as any Redmine issues that get created to track the progress.

## Design Targets

There are three major areas that are targeted for redesign within this module.

 * Split certificate generation from certificate deployment and management
 * Deploy and Manage certificates within service modules
 * Generate one certificate for a hostname

### Split certificate generation from certificate deployment and management

#### Problem Statement

In theory, this module aims to both generate certificates and to deploy them to their final, managed locations per the needs of each service. This is laid out in the (README)[https://github.com/theforeman/puppet-certs#phases] but not strictly true as there is tighter cohesion than expected. There is unnecessary work that happens within the code to achieve a split generate and deploy model that involves certificates living in three different locations and RPMs being built and installed.

Let's recap the current locations that certificates live on disk and the "stages" each pertains to:

| Location on disk                             | stage    | purpose                                                   |
|----------------------------------------------|----------|-----------------------------------------------------------|
| /root/ssl-build/${hostname}/*.{crt,key}      | generate | Certificates and private keys created by katello-ssl-tool |
| /root/ssl-build/${hostname/*.noarch.rpm      | generate | RPMs containing a certificate and private key pair        |
| /etc/pki/katello-certs-tools/{certs,private} | deploy   | Installed locations of key pair from RPMs                 |
| /etc/pki/katello,/etc/foreman,/etc/candlepin | deploy   | Final, managed key pair destination for services to use   |

On a Foreman server, thus the workflow goes something like:

 1) katello-ssl-tool creates /root/ssl-build directory
 2) katello-ssl-tool creates CA certificate and key along with openssl config
 3) katello-ssl-tool creates certificates based upon hostname input
 4) katello-ssl-tool creates an RPM that wraps the generated certificate and private key
 5) the RPM is installed
 6) the RPM creates certificate and private key at `/etc/pki/katello-certs-tools/{certs,private}`
 7) the certificate and private key are copied from `/etc/pki/katello-certs-tools` to `/etc/pki/katello` (or other locations)
 8) Puppet in some cases manages the files setting user, group, mode
 9) service modules are configured to find their certificates in `/etc/pki/katello` (or other locations) by puppet-katello or directly in something like the foreman-installer answers file

On a Content proxy, the workflow is:

 1) generate a tarball on the server for the smart-proxy hostname
 2) copy tarball to smart-proxy
 3) tarball is expanded putting RPMs inside into `/root/ssl-build/${hostname}`
 4) the RPM is installed
 5) the RPM creates certificate and private key at `/etc/pki/katello-certs-tools/{certs,private}`
 6) the certificate and private key are copied from `/etc/pki/katello-certs-tools` to `/etc/pki/katello` (or other locations)
 7) Puppet in some cases manages the files setting user, group, mode
 8) service modules are configured to find their certificates in `/etc/pki/katello` (or other locations) by puppet-katello or directly in something like the foreman-installer answers file

There are a few issues with this:

 1) The intermediate location (/etc/pki/katello-certs-tools) is unnecessary
 2) The use of RPMs restricts the deployments for which this can be used
 3) Deploy is linked to both installation of the RPMs and certificates landing in their final destination

#### Design

The new design aims to draw a clear line between the generation of certificates by katello-ssl-tool and the deployment of the generated certificates to their final managed location. Each service imposes some set of needs on the certificates it uses in order for the service to operate. This can be the user and group that has access, the location on disk or even the format of the certificate.

By differentiating between generation of certificates and deployment/management of the certificates the tooling is able to create a well defined interface for providing certificates. That is, katello-ssl-tool generated certificates can be treated like Puppet generated certificates in that they can be generated in one spot and then handed to the interfaces to ensure they wind up in the right locations for each service with the right permissions. This levels the field of possible certificate inputs and will ultimately make user supplied certificates easier. Additionally, this will also allow moving of the deployment and management step into the individual service modules (e.g. puppet-candlepin) that are better equipped to manage the files on disk given those modules are often also managing the user, group and directories that need access.

#### Roadmap

This section aims to outline the set of steps, at level of individual pull request changes, needed to achieve the design.

  * Add acceptance tests for tar_create and tar_extract
    * [x] [Pull Request](https://github.com/theforeman/puppet-certs/pull/351)
  * Add acceptance tests for any missing service classes
    * [x] [foreman](https://github.com/theforeman/puppet-certs/pull/355)
    * [x] [qpid_router](https://github.com/theforeman/puppet-certs/pull/356)
    * [x] [pulp_client](https://github.com/theforeman/puppet-certs/pull/357)
    * [x] [puppet](https://github.com/theforeman/puppet-certs/pull/358)
  * Add certificates from /root/ssl-build/${hostname} into tarball creation
    * Needed for being able to deploy certificates from the build directory on a content proxy as the current design only copies over RPMs and then installs those RPMs resulting in the `/etc/pki/katello-certs-tools` location being available
    * [x] [Pull Request](https://github.com/theforeman/puppet-certs/pull/352)
  * Investigate configuring where certificates are generated for a given service by katello-ssl-tool
  * Add new type for managing a certificate
    * This type and provider would handle copying the provided certificate to a destination, validating it and setting properties on the file
    * Name ideas:
      * managed_certificate
      * certificate
      * certificate_file
      * public_certificate
      * service_certificate
  * Add a new provider for managing a private key
    * This type and provider would handle copying the provided certificate to a destination, validating it and setting properties on the file
    * Name ideas:
      * managed_private_key
      * private_key
      * private_key_file
      * service_private_key
  * Add a new defines `key_pair` that provides a single interface to wrap private and public key management
    * This will eventually replace `keypair` and provides a way to migrate service by service in smaller chunks
  * Switch classes one by one to deploy certificates from the build directory (e.g. /root/ssl-build) rather than from the RPM location
    * Set `deploy => false` on `cert` provider to avoid RPM install
  * Remove RPM deployment and generation
    * Add a change that stops generating RPMs when `deploy => false` is set on the `cert` provider
    * Clean out RPM handling code from `cert` provider

### Deploy and Manage certificates within service modules

#### Problem Statement

Services almost always need to set some level of ownership on certificates in order to consume them at runtime. This can be as simple as user and group. The certificates used by a service are also often co-located within a directory owned by that service. This creates dependency cycles and burdens when trying to manage the certificates from within puppet-certs. For example, puppet-candlepin needs to install Candlepinand ensure the tomcat user and group exists, as well as the `/etc/candlepin/certs` directory in order for puppet-certs to set the owner and group on the certificates. And, puppet-candlepin needs puppet-certs to have created and deployed the certificates with those correct ownerships before the service can be started.

While not directly a problem, creating certificate stores in the right format and managing can be a complex detail that a user should not need to deal with. The use of keystores and truststores can be thought of as internal to how something like Candlepin works and a user should only have to worry about supplying certificates.

#### Design

The new design moves the management/deployment of certificates and certificate stores into the service modules themselves which has better dependency control over the attributes that need to be set on the certificates as well as the final location of the certificates. The interface to the modules would then be the needed set of generated certificates. In this way, certificates can be supplied directly by a user from their own tooling, or puppet-certs can generate certificates from katello-ssl-tool as input or Puppet generated certificates can be generated and supplied.

#### Roadmap

 * Complete "Split certificate generation from certificate deployment and management"
 * Add types and providers for all certificate stores in use
   * [x] keystore
   * [x] truststore
   * [x] nssdb
 * For each service module:
   * Add parameters for the required certificates, private keys and CA certificates
   * Add management of the input certificates via the new types in puppet-certs
   * Set deploy false in puppet-certs to prevent duplicate management

### Generate one certificate for a hostname

#### Problem Statement

For a given hostname, puppet-certs generates multiple certificates with different names that are the same content. This is overhead given that what matters is that there are copies when the certificates are deployed not when they are generated (due to needing to manage the certificate differently per service). Depending on the configuration, this can be 5-10 copies of the same effective certificate being generated over and over. This is both unneeded overhead and unobvious to a user debugging issues.

#### Design

The new design would move to a model of generating a single certificate and private key per hostname that could then be shared as input to the service modules for management to the final deployed location of the certificates. This would also align better with more modern tools such as Let's Encrypt, smallstep, Vault and FreeIPA.

#### Roadmap

 * Complete "Split certificate generation from certificate deployment and management"
 * Add a Puppet class for generating a certificate for the primary input FQDN
 * Add a Puppet class for generating a certificate for localhost
 * Update classes in puppet-certs to include the new class based on the FQDN requirement
