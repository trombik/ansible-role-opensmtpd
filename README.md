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
    opensmtpd_flags: -v
    opensmtpd_config: |
      table aliases file:{{ opensmtpd_aliases_file }}
      listen on lo0
      accept for local alias <aliases> deliver to mbox
      accept from local for any relay
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
