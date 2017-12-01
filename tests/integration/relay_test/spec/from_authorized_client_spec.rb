require_relative "spec_helper"
require "net/smtp"

def smtp_object
  o = Net::SMTP.new(
    server(:server1).server.address, 587
  )
  ctx = OpenSSL::SSL::SSLContext.new
  ctx.verify_mode = OpenSSL::SSL::VERIFY_NONE
  o.enable_tls(ctx)
  o
end

describe server(:server1) do
  let(:smtp) { smtp_object }
  after(:each) { smtp.finish if smtp.started? }

  it "accepts TLS connection" do
    expect { smtp.start }.not_to raise_exception
  end
end

context "when the SMTP client is authenticated" do
  describe server(:server1) do
    let(:smtp) { smtp_object }
    let(:user) { "john@example.org" }
    let(:password) { "PassWord" }
    before(:each) do
      smtp.start("localhost", user, password, :plain)
    end
    after(:each) { smtp.finish if smtp.started? }

    it "accepts message to third-party domain" do
      expect { smtp.mailfrom(user) }.not_to raise_exception
      expect { smtp.rcptto("foo@example.com") }.not_to raise_exception
    end

    ["example.org", "example.net"].each do |domain|
      it "accepts message to our domains" do
        expect { smtp.mailfrom(user) }.not_to raise_exception
        expect { smtp.rcptto("abuse@#{domain}") }.not_to raise_exception
      end
    end
  end
end
