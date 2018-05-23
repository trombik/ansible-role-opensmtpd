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
