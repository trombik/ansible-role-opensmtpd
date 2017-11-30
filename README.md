# ansible-role-opensmtpd

Configure `smtpd(8)`, aka [OpenSMTPD](https://www.opensmtpd.org/).

# Requirements

None

# Role Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `opensmtpd_user` | user name of `smtpd(8)` | `{{ __opensmtpd_user }}` |
| `opensmtpd_group` | group name of `smtpd(8)` | `{{ __opensmtpd_group }}` |
| `opensmtpd_service` | service name of `smtpd(8)` | `{{ __opensmtpd_service }}` |
| `opensmtpd_conf_dir` | path to configuration directory | `{{ __opensmtpd_conf_dir }}` |
| `opensmtpd_conf_file` | path to `smtpd.conf(5)` | `{{ __opensmtpd_conf_dir }}/smtpd.conf` |
| `opensmtpd_aliases_file` | path to `aliases(5)` | `{{ __opensmtpd_conf_dir }}/aliases` |
| `opensmtpd_flags` | optional flags for `smtpd(8)` | `""` |
| `opensmtpd_package_name` | package name of OpenSMTPD | `{{ __opensmtpd_package_name }}` |
| `opensmtpd_extra_packages` | list of extra packages to install | `[]` |
| `opensmtpd_config` | content of `smtpd.conf(5)` | `""` |
| `opensmtpd_virtual_user` | Virtual user for delivering mails to virtual users. See below. | `None` |
| `opensmtpd_tables` | list of tables. See below.  | `[]` |

## `opensmtpd_virtual_user`

This dict variable defines a virtual user to create. Its keys are explained
below. When defined, the user and its home directory are created.

| Key | Description | Mandatory? |
|-----|-------------|------------|
| `comment` | The comment field in `passwd(5)` | no |
| `group` | The primary group name of the user | yes |
| `groups` | Additional groups of the user | no |
| `home` | Home directory of the user | yes |
| `name` | Name of the user | yes |
| `uid` | UID of the user | no |

## `opensmtpd_tables`

This list variable defines list of dict of `table(5)`.

| Key | Description | Mandatory? |
|-----|-------------|------------|
| `name` | The name of the table used in `smtpd.conf(5)` | yes |
| `path` | The path to the file | yes |
| `type` | Either one of `file` or `db` | yes |
| `owner` | Owner of the file | no |
| `group` | Group of the file | no |
| `dbtype` | One of supported formats of the database, the default is `hash`. Ignored unless `type` is `db` | no |
| `format` | The format of the resulting map file, see `-t type` in `makemap(8)` for possible values. Ignored unless `type` is `db` | no |
| `mode` | String of file mode of the file. Note that you should almost always quote it. | no |
| `values` | List of content of the file. See `table(5)`. | yes |

## OpenBSD

| Variable | Default |
|----------|---------|
| `__opensmtpd_user` | `_smtpd` |
| `__opensmtpd_group` | `_smtpd` |
| `__opensmtpd_service` | `smtpd` |
| `__opensmtpd_conf_dir` | `/etc/mail` |
| `__opensmtpd_package_name` | `""` |

# Dependencies

None

# Example Playbook

```yaml
- hosts: localhost
  roles:
    - ansible-role-opensmtpd
  vars:
    opensmtpd_virtual_user:
      name: vmail
      group: vmail
      home: /var/vmail
      comment: Virtual Mail User
    opensmtpd_tables:
      - name: domains
        path: /etc/mail/domains
        type: file
        owner: root
        group: wheel
        mode: "0644"
        values:
          - example.org
          - example.net
      - name: virtuals
        path: /etc/mail/virtuals
        type: db
        dbtype: hash
        format: aliases
        owner: root
        group: vmail
        mode: "0444"
        values:
          - abuse@example.org john@example.org
          - postmaster@example.org john@example.org
          - john@example.org {{ opensmtpd_virtual_user.name }}
          - abuse@example.net john@example.net
          - postmaster@example.net john@example.net
          - john@example.net {{ opensmtpd_virtual_user.name }}

    opensmtpd_flags: -v
    opensmtpd_config: |
      table aliases file:{{ opensmtpd_aliases_file }}
      {% for list in opensmtpd_tables %}
      table {{ list.name }} {{ list.type }}:{{ list.path }}{% if list['type'] == 'db' %}.db{% endif %}

      {% endfor %}
      listen on lo0 port 25
      accept from any for domain <domains> virtual <virtuals> \
        deliver to maildir "{{ opensmtpd_virtual_user.home }}/%{dest.domain}/%{dest.user}/Maildir"
```

# License

```
Copyright (c) 2017 Tomoyuki Sakurai <tomoyukis@reallyenglish.com>

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

Tomoyuki Sakurai <tomoyukis@reallyenglish.com>

This README was created by [qansible](https://github.com/trombik/qansible)
