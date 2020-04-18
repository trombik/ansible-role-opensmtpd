require "default_spec"

ssl_dir = case os[:family]
          when "freebsd"
            "/usr/local/etc/mail/ssl"
          when "openbsd"
            "/etc/mail/ssl"
          else
            raise format("unsupported platform %<family>s", family: os[:family])
          end

describe file "#{ssl_dir}/a.mx.trombik.org.key" do
  it { should exist }
  it { should be_file }
end

describe file "#{ssl_dir}/a.mx.trombik.org.crt" do
  it { should exist }
  it { should be_file }
end

describe port(587) do
  it { should be_listening }
end

stdout_match = "subject=C = TH, ST = Bangkok, O = Internet Widgits Pty Ltd, CN = a.mx.trombik.org"
case Specinfra.backend.run_command("openssl version").stdout
when /LibreSSL/
  stdout_match = "subject=/C=TH/ST=Bangkok/O=Internet Widgits Pty Ltd/CN=a.mx.trombik.org"
end

# XXX sleep before disconnecting. otherwise, the SMTP banner cannot be
# captured in the stdout
describe command "(sleep 3; echo helo localhost)| openssl s_client -connect 127.0.0.1:587" do
  # XXX here stderr is not tested because the stderr outputs vary depeding on
  # openssl version.
  its(:stdout) { should match(/^#{Regexp.escape(stdout_match)}$/) }
  its(:stdout) { should match(/^#{Regexp.escape("220 a.mx.trombik.org ESMTP OpenSMTPD")}$/) }
  its(:exit_status) { should eq 0 }
end
