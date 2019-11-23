# ansible-role-opensmtpd

Configure `smtpd(8)`, aka [OpenSMTPD](https://www.opensmtpd.org/).

# Requirements

When `opensmtpd_include_x509_certificate` is `yes`, `trombik.x509-certificate`
must have been available, usually via `requirements.yml`.

If `opensmtpd-extras` is installed, `opensmtpd` API version must match
`opensmtpd-extras`'s one.

# Role Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `opensmtpd_user` | user name of `smtpd(8)` | `{{ __opensmtpd_user }}` |
| `opensmtpd_group` | group name of `smtpd(8)` | `{{ __opensmtpd_group }}` |
| `opensmtpd_service` | service name of `smtpd(8)` | `{{ __opensmtpd_service }}` |
| `opensmtpd_conf_dir` | path to configuration directory | `{{ __opensmtpd_conf_dir }}` |
| `opensmtpd_conf_file` | path to `smtpd.conf(5)` | `{{ opensmtpd_conf_dir }}/smtpd.conf` |
| `opensmtpd_flags` | optional flags for `smtpd(8)` | `""` |
| `opensmtpd_package_name` | package name of OpenSMTPD | `{{ __opensmtpd_package_name }}` |
| `opensmtpd_extra_packages` | list of extra packages to install | `[]` |
| `opensmtpd_config` | content of `smtpd.conf(5)` | `""` |
| `opensmtpd_makemap_bin` | path to `makemap(8)` | `{{ __opensmtpd_makemap_bin }}` |
| `opensmtpd_virtual_user` | Virtual user for delivering mails to virtual users. See below. | `{}` |
| `opensmtpd_extra_groups` | Additional list of groups to add `smtpd(8)` user to | `[]` |
| `opensmtpd_tables` | list of tables. See below.  | `[]` |
| `opensmtpd_include_x509_certificate` | Include [`trombik.x509-certificate`](https://github.com/trombik/ansible-role-x509-certificate) role during the play | `no` |

## `opensmtpd_virtual_user`

This dict variable defines a virtual user to create. Its keys are explained
below. When non-empty dict, the user and its home directory are created.

| Key | Description | Mandatory? |
|-----|-------------|------------|
| `comment` | The comment field in `passwd(5)` | no |
| `group` | The primary group name of the user | yes |
| `groups` | Additional groups of the user | no |
| `home` | Home directory of the user | yes |
| `name` | Name of the user | yes |
| `uid` | UID of the user | no |
| `mode` | The mode of `home` directory. If omitted, the mode is set by system default | no |

## `opensmtpd_tables`

This list variable defines list of dict of `table(5)`.

| Key | Description | Mandatory? |
|-----|-------------|------------|
| `name` | The name of the table used in `smtpd.conf(5)` | yes |
| `path` | The path to the file | yes |
| `type` | One of supported back-end type, default installation only accepts `file` or `db`. Install [OpenSMTPD-extra](https://github.com/OpenSMTPD/OpenSMTPD-extras) for other types | yes |
| `owner` | Owner of the file | no |
| `group` | Group of the file | no |
| `dbtype` | One of supported formats of the database, the default is `hash`. Ignored unless `type` is `db` | no |
| `format` | The format of the resulting map file, see `-t type` in `makemap(8)` for possible values. Ignored unless `type` is `db` | no |
| `mode` | String of file mode of the file. Note that you should almost always quote it. | no |
| `values` | List of content of the file. See `table(5)`. | yes |
| `no_log` | When `yes`, enable `no_log` in the template task. Setting this to `no` causes everything in the variable logged, including credentials. The default is `yes` | no |

## `opensmtpd_include_x509_certificate`

This `include_role`
[`trombik.x509-certificate`](https://github.com/trombik/ansible-role-x509-certificate)
role during the play. See an example in
[`tests/serverspec/x509.yml`](tests/serverspec/x509.yml).

## Debian

| Variable | Default |
|----------|---------|
| `__opensmtpd_user` | `opensmtpd` |
| `__opensmtpd_group` | `opensmtpd` |
| `__opensmtpd_service` | `opensmtpd` |
| `__opensmtpd_conf_dir` | `/etc` |
| `__opensmtpd_package_name` | `opensmtpd` |
| `__opensmtpd_makemap_bin` | `/usr/sbin/makemap` |

## FreeBSD

| Variable | Default |
|----------|---------|
| `__opensmtpd_user` | `_smtpd` |
| `__opensmtpd_group` | `_smtpd` |
| `__opensmtpd_service` | `smtpd` |
| `__opensmtpd_conf_dir` | `/usr/local/etc/mail` |
| `__opensmtpd_package_name` | `mail/opensmtpd` |
| `__opensmtpd_makemap_bin` | `/usr/local/libexec/opensmtpd/makemap` |

## OpenBSD

| Variable | Default |
|----------|---------|
| `__opensmtpd_user` | `_smtpd` |
| `__opensmtpd_group` | `_smtpd` |
| `__opensmtpd_service` | `smtpd` |
| `__opensmtpd_conf_dir` | `/etc/mail` |
| `__opensmtpd_package_name` | `""` |
| `__opensmtpd_makemap_bin` | `/usr/sbin/makemap` |

## RedHat

| Variable | Default |
|----------|---------|
| `__opensmtpd_user` | `smtpd` |
| `__opensmtpd_group` | `smtpd` |
| `__opensmtpd_service` | `opensmtpd` |
| `__opensmtpd_conf_dir` | `/etc/opensmtpd` |
| `__opensmtpd_package_name` | `opensmtpd` |
| `__opensmtpd_makemap_bin` | `/sbin/makemap` |

# Dependencies

None

# Example Playbook

```yaml
---

- hosts: localhost
  roles:
    - name: trombik.redhat_repo
      when: ansible_os_family == 'RedHat'
    - role: trombik.freebsd_pkg_repo
      when:
        - ansible_os_family == 'FreeBSD'
    - role: ansible-role-opensmtpd
  vars:
    os_default_group:
      FreeBSD: wheel
      OpenBSD: wheel
      Debian: root
      RedHat: root
    freebsd_pkg_repo:
      FreeBSD:
        enabled: "false"
        state: present
      FreeBSD_latest:
        enabled: "true"
        state: present
        url: pkg+https://pkg.FreeBSD.org/${ABI}/latest
        mirror_type: srv
        signature_type: fingerprints
        fingerprints: /usr/share/keys/pkg
        priority: 100
    redhat_repo:
      epel:
        mirrorlist: "http://mirrors.fedoraproject.org/mirrorlist?repo=epel-{{ ansible_distribution_major_version }}&arch={{ ansible_architecture }}"
        gpgcheck: yes
        enabled: yes

    test_user: john@example.org
    # smtpctl encrypt PassWord
    test_password: "$2b$08$LT/AdE2YSHb19d3hB27.4uXd1/Cj0qQIWc4FdfLlcuqnCUGbRu2Mq"
    # XXX table_passwd in Ubuntu package throws error when UID or GID field is
    # empty
    os_passwd_postfix:
      FreeBSD: ":::::"
      OpenBSD: ":::::"
      Debian: ":12345:12345:::"
      RedHat: ":12345:12345:::"
    passwd_postfix: "{{ os_passwd_postfix[ansible_os_family] }}"

    os_opensmtpd_extra_packages:
      FreeBSD:
        - opensmtpd-extras-table-passwd
      OpenBSD:
        - opensmtpd-extras
      Debian: []
      RedHat: []
    opensmtpd_extra_packages: "{{ os_opensmtpd_extra_packages[ansible_os_family] }}"

    os_opensmtpd_extra_groups:
      FreeBSD:
        - nobody
      OpenBSD:
        - nobody
      Debian:
        - games
      RedHat:
        - games
    opensmtpd_extra_groups: "{{ os_opensmtpd_extra_groups[ansible_os_family] }}"
    opensmtpd_virtual_user:
      name: vmail
      group: vmail
      home: /var/vmail
      comment: Virtual Mail User
      mode: "0755"
    opensmtpd_tables:
      - name: aliases
        path: "{{ opensmtpd_conf_dir }}/aliases"
        type: file
        format: aliases
        mode: "644"
        no_log: no
        values:
          - "MAILER-DAEMON: postmaster"
          - "postmaster: root"
          - "daemon: root"
          - "ftp-bugs: root"
          - "operator: root"
          - "www:    root"
          - "foo: error:500 no such user"
          - "bar: | cat - >/dev/null"
      - name: secrets
        path: "{{ opensmtpd_conf_dir }}/secrets"
        type: file
        owner: root
        group: "{{ opensmtpd_group }}"
        mode: "0640"
        no_log: no
        values:
          - "{{ test_user }} {{ test_password }}"
      - name: passwd
        # XXX Ubuntu package does not allow non-defalt path to smtpd.conf(5)
        # as such, all files are under opensmtpd_conf_dir. use smtpd_passwd,
        # instead of consistent file name, `passwd`.
        path: "{{ opensmtpd_conf_dir }}/smtpd_passwd"
        type: passwd
        owner: root
        group: "{{ opensmtpd_group }}"
        mode: "0640"
        no_log: no
        values:
          - "{{ test_user }}:{{ test_password }}{{ passwd_postfix }}"
      - name: domains
        path: "{{ opensmtpd_conf_dir }}/domains"
        type: file
        owner: root
        group: "{{ os_default_group[ansible_os_family] }}"
        mode: "0644"
        no_log: no
        values:
          - example.org
          - example.net
      - name: virtuals
        path: "{{ opensmtpd_conf_dir }}/virtuals"
        type: db
        dbtype: hash
        format: aliases
        owner: root
        group: vmail
        mode: "0444"
        no_log: no
        values:
          - abuse@example.org john@example.org
          - postmaster@example.org john@example.org
          - john@example.org {{ opensmtpd_virtual_user.name }}
          - abuse@example.net john@example.net
          - postmaster@example.net john@example.net
          - john@example.net {{ opensmtpd_virtual_user.name }}
      - name: mynetworks
        path: "{{ opensmtpd_conf_dir }}/mynetworks"
        type: db
        format: set
        no_log: no
        values:
          - 192.168.21.0/24

    opensmtpd_flags: -v
    os_listen_on_interface:
      FreeBSD: lo0
      OpenBSD: lo0
      Debian: lo
      RedHat: lo
    opensmtpd_config: |
      {% for list in opensmtpd_tables %}
      {% if list.type == 'passwd' and (ansible_os_family == 'Debian' or ansible_os_family == 'RedHat') %}
      # XXX at the moment (2018/05/20), the version of opensmtpd-extras is
      # behind opensmtpd, causing "table-api: bad API version".
      # https://packages.ubuntu.com/bionic/opensmtpd-extras
      #
      # skip passwd table until synced version is released
      #
      # also, opensmtpd-extras for ubuntu 14.04 was removed
      {% else %}
      table {{ list.name }} {{ list.type }}:{{ list.path }}{% if list['type'] == 'db' %}.db{% endif %}
      {% endif %}

      {% endfor %}
      listen on {{ os_listen_on_interface[ansible_os_family] }} port 25

      {% if ansible_os_family == 'OpenBSD' or ansible_os_family == 'FreeBSD' %}
      # new format
      action "local_mail" maildir "{{ opensmtpd_virtual_user['home'] }}/%{dest.domain}/%{dest.user}/Maildir"
      action "outbound" relay
      match from any for domain <domains> action "local_mail"
      match from src <mynetworks> action "outbound"
      {% else %}
      # old format
      accept from any for domain <domains> virtual <virtuals> \
        deliver to maildir "{{ opensmtpd_virtual_user['home'] }}/%{dest.domain}/%{dest.user}/Maildir"
      accept from any for domain <domains> \
        deliver to mbox
      {% endif %}
```

# License

```
Copyright (c) 2017 Tomoyuki Sakurai <y@trombik.org>

Permission to use, copy, modify, and distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
```

# Author Information

Tomoyuki Sakurai <y@trombik.org>

This README was created by [qansible](https://github.com/trombik/qansible)
