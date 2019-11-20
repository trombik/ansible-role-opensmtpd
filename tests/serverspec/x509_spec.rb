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

stderr_msg = "depth=0 C = TH, ST = Bangkok, O = Internet Widgits Pty Ltd, CN = a.mx.trombik.org
verify error:num=18:self signed certificate
verify return:1
depth=0 C = TH, ST = Bangkok, O = Internet Widgits Pty Ltd, CN = a.mx.trombik.org
verify error:num=10:certificate has expired
notAfter=Dec  1 03:57:09 2018 GMT
verify return:1
depth=0 C = TH, ST = Bangkok, O = Internet Widgits Pty Ltd, CN = a.mx.trombik.org
notAfter=Dec  1 03:57:09 2018 GMT
verify return:1
DONE
"

# XXX sleep before disconnecting. otherwise, the SMTP banner cannot be
# captured in the stdout
describe command "(sleep 3; echo helo localhost)| openssl s_client -connect 127.0.0.1:587" do
  its(:stderr) { should eq stderr_msg }
  # its(:stdout) { should match(/^#{Regexp.escape("subject=/C=TH/ST=Bangkok/O=Internet Widgits Pty Ltd/CN=a.mx.trombik.org")}$/) }
  its(:stdout) { should match(/^#{Regexp.escape("subject=C = TH, ST = Bangkok, O = Internet Widgits Pty Ltd, CN = a.mx.trombik.org")}$/) }
  its(:stdout) { should match(/^#{Regexp.escape("220 a.mx.trombik.org ESMTP OpenSMTPD")}$/) }
  its(:exit_status) { should eq 0 }
end
