require "spec_helper"
require "serverspec"

service = "smtpd"
config_dir = "/etc/mail"
ports = [25]
default_user = "root"
default_group = "root"
user = "_smtpd"
group = "_smtpd"
packages = []

case os[:family]
when "ubuntu"
  config_dir = "/etc"
  user = "opensmtpd"
  group = "opensmtpd"
  service = "opensmtpd"
  packages = ["opensmtpd"]
when "freebsd"
  config_dir = "/usr/local/etc/mail"
  default_group = "wheel"
  packages = ["opensmtpd"]
when "openbsd"
  default_group = "wheel"
  packages = []
end

config = "#{config_dir}/smtpd.conf"
tables = [
  { path: "#{config_dir}/domains",
    name: "domains",
    type: "file",
    mode: 644,
    owner: default_user,
    group: default_group,
    matches: [/^example\.org$/] }
]

packages.each do |p|
  describe package p do
    it { should be_installed }
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
    its(:content) { should match(/^smtpd_flags=""$/) }
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
end

describe file(config_dir) do
  it { should exist }
  it { should be_directory }
  it { should be_mode 755 }
  it { should be_owned_by default_user }
  it { should be_grouped_into default_group }
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
    its(:content) { should match(/^table #{t[:name]} #{t[:type]}:#{path}$/) }
  end
  int_lo = case os[:family]
           when "ubuntu"
             "lo"
           else
             "lo0"
           end
  its(:content) { should match(/^listen on #{int_lo} port 25$/) }
  its(:content) { should match(/^#{Regexp.escape('action "local_mail" mbox')}$/) }
  its(:content) { should match(/^#{Regexp.escape('match from any for domain <domains> action "local_mail"')}$/) }
end

case os[:family]
when "openbsd"
  describe command("rcctl get smtpd flags") do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should eq "\n" }
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
