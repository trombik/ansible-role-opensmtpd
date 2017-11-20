require "spec_helper"
require "serverspec"

service = "smtpd"
config_dir = "/etc/mail"
config  = "#{config_dir}/smtpd.conf"
aliases = "/etc/mail/aliases"
ports   = [25]
default_user = "root"
default_group = "wheel"

describe file(config_dir) do
  it { should exist }
  it { should be_directory }
  it { should be_mode 755 }
  it { should be_owned_by default_user }
  it { should be_grouped_into default_group }
end

describe file(config) do
  it { should exist }
  it { should be_file }
  it { should be_mode 644 }
  it { should be_owned_by default_user }
  it { should be_grouped_into default_group }
  its(:content) { should match(/^table aliases file:#{Regexp.escape(aliases)}$/) }
  its(:content) { should match(/^listen on lo0$/) }
  its(:content) { should match(/^accept for local alias <aliases> deliver to mbox$/) }
  its(:content) { should match(/^accept from local for any relay$/) }
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
