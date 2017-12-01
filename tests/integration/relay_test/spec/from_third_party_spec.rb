require_relative "spec_helper"
require "net/smtp"

context "when the SMTP client is third-party" do
  describe server(:server1) do
    let(:smtp) do
      Net::SMTP.start(
        server(:server1).server.address, 25
      )
    end
    before(:each) { smtp.mailfrom "foo@example.com" }
    after(:each) { smtp.finish }

    let(:mandatory_local_parts) { %w[abuse postmaster] }

    ["example.org", "example.net"].each do |domain|
      it "accepts a message to mandatory addresses in #{domain}" do
        mandatory_local_parts.each do |local|
          expect { smtp.rcptto "#{local}@#{domain}" }.not_to raise_exception
        end
      end

      it "does not accept non-existing user in #{domain}" do
        expect { smtp.rcptto "no-such-user@#{domain}" }.to raise_exception(Net::SMTPFatalError)
      end

      it "does not accept existing user in #{domain}" do
        expect { smtp.rcptto "john@#{domain}" }.not_to raise_exception
      end
    end

    it "is not an open-relay" do
      expect { smtp.rcptto "bar@example.com" }.to raise_exception(Net::SMTPFatalError)
    end
  end
end
