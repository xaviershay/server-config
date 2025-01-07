This file documents various non-automated bits of config.

## AmpliFi DNS

Setting nameservers in the app worked for my desktop but no other clients. Never
figured out exactly why. Needed to enable "Bypass DNS Cache" via the web
interface.

Fixed leases can be setup in the mobile app. See `blocky` config for which
servers require this (because it is resolving names to specific IPs).

## Domains

To change primary nameservers, login to each registrar website. While there is
an ICANN lookup available to find it, often I bought through a reseller - it's
easier just to search email for renewal notices. (I've also now collected them
all in a spreadsheet.)