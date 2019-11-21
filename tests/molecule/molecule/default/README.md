## scenario `default`

### Description

The scenario creates two instances, `client1` and `server1`.

The client has `smtpd(8)` listening on 127.0.0.1 port 10025. The `smtpd(8)`
relays all messages from local machine to `server1`.

The server has `smtpd(8)` listening on an interface for private network port
25, and accepts messages for domain `example.org` and `example.net`.

The scenario has a side-effect play that sends three messages to recipients in
the domains.

The test will see if the messages are delivered to the recipients.
