require "spec_helper"
require "serverspec"

service = "smtpd"
config_dir = "/etc/mail"
config  = "#{config_dir}/smtpd.conf"
aliases = "/etc/mail/aliases"
ports   = [25]
default_user = "root"
default_group = "wheel"
virtual_user = {
  name: "vmail",
  group: "vmail",
  home: "/var/vmail"
}

tables = [
  { path: "/etc/mail/domains",
    name: "domains",
    type: "file",
    mode: 644,
    owner: default_user,
    group: default_group,
    matches: [/^example\.org$/, /^example\.net$/] },
  { path: "/etc/mail/virtuals",
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
  its(:content) { should match(/^table aliases file:#{Regexp.escape(aliases)}$/) }
  tables.each do |t|
    path = t[:type] == "db" ? "#{t[:path]}.db" : t[:path]
    its(:content) { should match(/^table #{t[:name]} #{t[:type]}:#{path}$/) }
  end
  its(:content) { should match(/^listen on lo0 port 25$/) }
  # rubocop:disable Style/FormatStringToken
  its(:content) { should match(/^#{Regexp.escape("accept from any for domain <domains> virtual <virtuals> \\")}\n\s+#{Regexp.escape("deliver to maildir \"#{virtual_user[:home]}/%{dest.domain}/%{dest.user}/Maildir\"")}$/) }
  # rubocop:enable Style/FormatStringToken
end

describe command("rcctl get smtpd flags") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should eq "-v\n" }
  its(:stderr) { should eq "" }
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
