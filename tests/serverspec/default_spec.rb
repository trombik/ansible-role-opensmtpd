require "spec_helper"
require "serverspec"

service = "smtpd"
config_dir = "/etc/mail"
ports = [25]
default_user = "root"
default_group = "root"
user = "_smtpd"
group = "_smtpd"
virtual_user = {
  name: "vmail",
  group: "vmail",
  home: "/var/vmail"
}
extra_group = ["nobody"]
packages = []
passwd_postfix = ":::::"

case os[:family]
when "ubuntu"
  config_dir = "/etc"
  user = "opensmtpd"
  group = "opensmtpd"
  extra_group = ["games"]
  service = "opensmtpd"
  packages = ["opensmtpd", "opensmtpd-extras"]
  passwd_postfix = ":12345:12345:::"
when "freebsd"
  config_dir = "/usr/local/etc/mail"
  default_group = "wheel"
  packages = ["opensmtpd", "opensmtpd-extras-table-passwd"]
when "openbsd"
  default_group = "wheel"
  packages = ["opensmtpd-extras"]
when "redhat"
  config_dir = "/etc/opensmtpd"
  user = "smtpd"
  group = "smtpd"
  service = "opensmtpd"
  passwd_postfix = ":12345:12345:::"
  packages = ["opensmtpd"]
  extra_group = ["games"]
else
  raise "Unknown os[:family]: `#{os[:family]}`"
end

config = "#{config_dir}/smtpd.conf"
tables = [
  { path: "#{config_dir}/secrets",
    name: "secrets",
    type: "file",
    mode: 640,
    owner: "root",
    group: group,
    matches: [/^#{Regexp.escape("john@example.org $2b$08$")}.*$/] },
  { path: "#{config_dir}/smtpd_passwd",
    name: "passwd",
    type: "passwd",
    mode: 640,
    owner: "root",
    group: group,
    matches: [/^#{Regexp.escape("john@example.org:$2b$08$")}.*#{passwd_postfix}$/] },
  { path: "#{config_dir}/aliases",
    name: "aliases",
    type: "file",
    mode: 644,
    owner: default_user,
    group: default_group,
    matches: [
      /^MAILER-DAEMON: postmaster$/,
      /^foo: error:500 no such user$/,
      /^#{Regexp.escape("bar: | cat - >/dev/null")}$/
    ] },
  { path: "#{config_dir}/domains",
    name: "domains",
    type: "file",
    mode: 644,
    owner: default_user,
    group: default_group,
    matches: [/^example\.org$/, /^example\.net$/] },
  { path: "#{config_dir}/mynetworks",
    name: "mynetworks",
    type: "db",
    mode: 644,
    owner: default_user,
    group: default_group,
    matches: [/^#{Regexp.escape("192.168.21.0/24")}$/] },
  { path: "#{config_dir}/virtuals",
    name: "virtuals",
    type: "db",
    mode: 444,
    owner: default_user,
    group: virtual_user[:group],
    matches: [
      /^#{Regexp.escape("abuse@example.org john@example.org")}$/,
      /^#{Regexp.escape("postmaster@example.org john@example.org")}$/,
      /^#{Regexp.escape("john@example.org #{virtual_user[:name]}")}$/,
      /^#{Regexp.escape("abuse@example.net john@example.net")}$/,
      /^#{Regexp.escape("postmaster@example.net john@example.net")}$/,
      /^#{Regexp.escape("john@example.net #{virtual_user[:name]}")}$/
    ] }
]

packages.each do |p|
  describe package p do
    it do
      if p == "opensmtpd-extras" && os[:family] == "ubuntu" && os[:release].to_f == 14.04
        pending "the package is not available"
      end
      should be_installed
    end
  end
end

case os[:family]
when "freebsd"
  describe file("/etc/rc.conf.d/smtpd") do
    it { should exist }
    it { should be_file }
    it { should be_owned_by default_user }
    it { should be_grouped_into default_group }
    it { should be_mode 644 }
    its(:content) { should match(/^smtpd_config="#{Regexp.escape(config)}"$/) }
    its(:content) { should match(/^smtpd_flags="-v"$/) }
  end

  describe file("/etc/rc.conf") do
    it { should exist }
    it { should be_file }
    it { should be_owned_by default_user }
    it { should be_grouped_into default_group }
    it { should be_mode 644 }
    %w[sendmail_submit sendmail_outbound sendmail_msp_queue].each do |s|
      its(:content) { should match(/^#{s}_enable='NO'$/) }
    end
  end
end

describe file(config_dir) do
  it { should exist }
  it { should be_directory }
  it { should be_mode 755 }
  it { should be_owned_by default_user }
  it { should be_grouped_into default_group }
end

describe group(group) do
  it { should exist }
end

describe user(user) do
  it { should exist }
  it { should belong_to_primary_group group }
  extra_group.each do |g|
    it { should belong_to_group g }
  end
end

describe group(virtual_user[:group]) do
  it { should exist }
end

describe user(virtual_user[:name]) do
  it { should exist }
  it { should belong_to_group virtual_user[:group] }
  it { should belong_to_primary_group virtual_user[:group] }
  it { should have_home_directory virtual_user[:home] }
  it { should have_login_shell "/sbin/nologin" }
end
describe file(config_dir) do
  it { should exist }
  it { should be_directory }
  it { should be_mode 755 }
  it { should be_owned_by default_user }
  it { should be_grouped_into default_group }
end

describe file(virtual_user[:home]) do
  it { should exist }
  it { should be_directory }
  it { should be_owned_by virtual_user[:name] }
  it { should be_grouped_into virtual_user[:group] }
  it { should be_mode 755 }
end

tables.each do |t|
  describe file(t[:path]) do
    it { should exist }
    it { should be_owned_by t[:owner] }
    it { should be_grouped_into t[:group] }
    it { should be_mode t[:mode] }
    t[:matches].each do |m|
      its(:content) { should match m }
    end
  end
end

tables.each do |t|
  next unless t[:type] == "db"
  describe file("#{t[:path]}.db") do
    it { should exist }
    it { should be_file }
    it { should be_owned_by t[:owner] }
    it { should be_grouped_into t[:group] }
    it { should be_mode t[:mode] }
  end
end

describe file(config) do
  it { should exist }
  it { should be_file }
  it { should be_mode 644 }
  it { should be_owned_by default_user }
  it { should be_grouped_into default_group }
  tables.each do |t|
    path = t[:type] == "db" ? "#{t[:path]}.db" : t[:path]
    its(:content) do
      if t[:name] == "passwd" && (os[:family] == "ubuntu" || os[:family] == "redhat")
        pending "#{os[:family]} does not have matched version of opensmtpd-extra"
      end
      should match(/^table #{t[:name]} #{t[:type]}:#{path}$/)
    end
  end
  int_lo = case os[:family]
           when "ubuntu", "redhat"
             "lo"
           else
             "lo0"
           end
  its(:content) { should match(/^listen on #{int_lo} port 25$/) }
  case os[:family]
  when "freebsd", "openbsd"
    # false positives
    # rubocop:disable Style/FormatStringToken
    its(:content) { should match(/^#{Regexp.escape('action "local_mail" maildir "/var/vmail/%{dest.domain}/%{dest.user}/Maildir"')}$/) }
    # rubocop:enable Style/FormatStringToken
    its(:content) { should match(/^#{Regexp.escape('action "outbound" relay')}$/) }
  else
    # rubocop:disable Style/FormatStringToken
    its(:content) { should match(/^#{Regexp.escape("accept from any for domain <domains> virtual <virtuals> \\")}\n\s+#{Regexp.escape("deliver to maildir \"#{virtual_user[:home]}/%{dest.domain}/%{dest.user}/Maildir\"")}$/) }
    # rubocop:enable Style/FormatStringToken
  end
end

case os[:family]
when "openbsd"
  describe command("rcctl get smtpd flags") do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should eq "-v\n" }
    its(:stderr) { should eq "" }
  end
end

describe service(service) do
  it { should be_running }
  it { should be_enabled }
end

ports.each do |p|
  describe port(p) do
    it { should be_listening }
  end
end
