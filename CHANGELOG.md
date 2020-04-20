## Release 1.7.3

* 8f46758 bugfix: silence conditional_bare_variables warning

## Release 1.7.2

* 78a771b bugfix: QA
* 7e3b21d bugfix: update box versions, fix specs in x509
* 09d1861 bugfix: do not use sudo if docker
* d12910a bugfix: re-enable qansible

## Release 1.7.1

Fix wrong `role_name`

## Release 1.7.0

* 8c60ad6 bugfix: s/Ubuntu:/Debian:/ and enable logging on tables
* 666343d bugfix: update meta
* 3d43978 bugfix: remove `if ... else ...`
* 6a04a20 bugfix: refactor tests
* ee58c37 bugfix: s/in_mbox/in_maildir/ in test name
* 6e727d9 bugfix: remove unused prepare.yml
* 9b7ea4b doc: add README to `docker` role
* 9ebe4e6 bugfix: s/centos8/centos7/
* da42587 bugfix: remove another `if ... else ...` from the example
* a12de3f bugfix: fix wrong default in opensmtpd_conf_file
* 22c1362 doc: update README
* 4171f9b bugfix: add prepare.yml to travisci_ubuntu1804
* 7390e75 bugfix: install docker_package_ss on other Linux distro
* 94354aa bugfix: remove unused Dockerfile.j2
* f5e0ee6 bugfix: add molecule tests for CentOS
* 547fddd bugfix, feature: allow to change mode of home directory
* 17d80f5 bugfix: QA
* 86d4f2d bugfix: reenable qansible
* c468aad bugfix: update travis.yml
* 2ad13f4 bugfix: refactor path to home directory
* b86928e bugfix: list services after play, not before
* d1f19d9 bugfix: add tests in travis CI

## Release 1.6.1

* 6bc5dad bugfix: QA
* 9c34dba bugfix: test the virtual domain
* 4f57872 bugfix: create mailer.conf(5) on FreeBSD
* 1e4f52b bugfix: add yamllint
* 7e06a19 bugfix: QA
* f8495ed bugfix: ignore false positives
* 7bb4846 bugfix: QA
* 391dd38 bugfix: document WIP status
* 585a450 bugfix: test if a message is delivered to the recipient
* d1507da bugfix:: introduce molecule tests
* 746b096 bugfix: QA
* ae1336a bugfix: update gitignore
* 6505628 bugfix: update boxes, smtpd.conf, and tests
* f9e830f bugfix: add ansible.cfg
* b69199a QA

## Release 1.6.0

* 7d9b44d [bugfix] workaround an issue in galaxy
* 8622db5 [bugfix] bump OpenBSD version in the integration tests
* 374619a [bugfix] ensure the daemon is notified after `Start opensmtpd` task
* 4452848 [feature] support FreeBSD 10.4, and OpenBSD 6.3

## Release 1.5.0

* 0a32670 [feature] support ubuntu 14.04 and 18.04 (#42)
* e28fcd2 [documentation] warn API version mismatch
* 40dd728 [bugfix] QA
* a27a8a2 [bugfix] Update README
* 3d2ab0b [bugfix] remove opensmtpd-extras on ubuntu 14.04
* 583a252 [bugfix] do not install opensmtpd-extra on ubuntu 18.04 for now
* 5ceb1a6 [bugfix] make the YAML more portable
* 105b1dd [bugfix] stop smtpd(8) on ubuntu when, and only if, the package has been installed
* 1d4fea4 [bugfix] Update README (#40)
* ee77e47 [bugfix] QA (#39)

## Release 1.4.1

* e0d24dd [bugfix] opensmtpd_virtual_user defaults to an empty dict, instead of `None` (#36)

## Release 1.4.0

* e577eb1 [feature] Support x509-certificate (#32)

## Release 1.3.2

* cbca001 [bugfix] remove include: (#30)

## Release 1.3.1

* e2ba83e [bugfix] QA (#28)

## Release 1.3.0

* c858284 [bugfix] Notify the daemon when file databases have been updated (#26)
* 7d3b558 [feature] Support table types other than file and db (#25)
* 81b281d [bugfix] support Ubuntu (#22)

## Release 1.2.0

* 4045034 [feature] support `opensmtpd_extra_groups` (#20)

## Release 1.1.0

* b8cd4b7 [feature] support FreeBSD (#17)
* 8c902ee [bugfix] remove `opensmtpd_aliases_file`, which is just another table (#16)

## Release 1.0.1

* fix `meta/main.yml` that caused a failure when galaxy import the role

## Release 1.0.0

* Initial release
