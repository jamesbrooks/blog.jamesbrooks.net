---
title: Technitium DNS Server with Tailscale
description: How to use Technitium DNS Server with Tailscale to provide split-horizon DNS resolution for your network in order to provide correct DNS resolution for devices on your home network as well as devices connecting in via Tailscale.
layout: post
category: Networking
tags:
  - Networking
  - DNS
  - Technitium DNS Server
  - Tailscale
  - Split Horizon
keywords:
  - Networking
  - DNS
  - Technitium DNS Server
  - Tailscale
  - Split Horizon
  - Homelab
---

I have been using [Tailscale](https://tailscale.com/) for a while now to provide secure access to my home network from anywhere, I run it constantly on my work laptop which I use both at home and in the office as well as on many devices within my home network. Within my home network as well I have been running Pi-hole to provide network-wide ad-blocking, and for the interest of this article, DNS resolution.

One of the things I haven't quite been able to (happily) solve has been the ability to provide DNS resolution that is both correct for devices on my home network as well as devices connecting in via Tailscale. Pi-hole allowed me to add some simple DNS entries to resolve internal hosts, but for devices connecting in via Tailscale those entries would not be appropriate (e.g. the difference between 10.1.1.20 and the Tailscale IP that device might have of 100.70.60.50).

I recently discovered [Technitium DNS Server](https://technitium.com/dns/) as a bit of a step-up replacement for Pi-hole in terms of ad-blocking, but additionally with a much more powerful DNS server. One of the features that caught my eye was the ability to provide split-horizon DNS resolution, which is exactly what I needed to solve my problem.

Split-horizon DNS resolution enables me to provide different DNS resolutions based on the source IP of the request. This means that I can provide different DNS resolutions for devices on my home network and devices connecting in via Tailscale. Perfect!

I won't go into the details of setting up Technitium DNS Server (but after the server is installed the Split Horizon app will also need to be installed), but I will provide a brief overview of the split-horizon configuration that I used to solve my problem.

There are two primary methods that can be used to solve this problem, first is on a per-record basis, and second is a global ip mapping mechanism. I'll detail both below. For my use case I've gone with the first method as I don't have a large amount of receords that need this treatment, and having the details of the mapping directly on the record itself feels like less of a foot-gun.

### Per-record basis

Instead of creating a regular DNS record, e.g. an A record, instead create an APP record. Specify 'Split Horizon' as the app, 'SplitHorizon.SimpleAddress' as the class path (though the CNAME-equivalent class path could also be used if that is more appropriate). The 'Data' field is where the split-horizon magic happens, this is a JSON object that specifies the IP address to return based on the source IP of the request.

```javascript
{
  // for requests from a source in the Tailscale CIDR, resolve to the Tailscale IP
  "100.64.0.0/10": [
    "100.89.243.99"
  ],

  // otherwise resolve to the internal IP for requests from any other source
  "0.0.0.0/0": [
    "10.1.1.3"
  ]
}
```

And voila! Now devices on my home network will resolve to the internal IP of the host, and devices connecting in via Tailscale will resolve to the Tailscale IP of the host. Perfect! Optionally this approach can be cleaned up by setting some global configuration on the Split Horizon app to add friendly network names for the CIDRs, e.g.

```javascript
{
  "networks": {
    "tailscale": ["100.64.0.0/10"],
    "default": ["0.0.0.0/0"]
  }
}
```

Which would allow the per-record configuration to be simplified to:

```javascript
{
  "tailscale": [
    "100.89.243.99"
  ],
  "default": [
    "10.1.1.3"
  ]
}
```

### Global IP mapping

The second method is to use a global IP mapping mechanism. Instead of setting up mappings on a per-record basis just declare the records like usual using the internal IP addresses, and then we'll set up a mechanism to map internal IPs to their respective Tailscale IPs if the request is coming from a Tailscale IP. This configuration only needs to occur on the Split Horizon app.

The equivalent configuration to the above would be:

```javascript
{
  "enableAddressTranslation": true,
  "networkGroupMap": {
    "100.64.0.0/10": "tailscale"
  },
  "groups": [
    {
      // for requests that come in from a Tailscake IP:
      // translate the would-be resolved internal IP to a Tailscale IP instead
      "name": "tailscale",
      "enabled": true,
      "translateReverseLookups": false,
      "externalToInternalTranslation": {
        "10.1.1.3": "100.89.243.99"
        // add more mappings here as needed
      }
    }
  ]
}
```

Now everytime the DNS server would respond to a query with `10.1.1.3`, if the request came from a Tailscale IP it will instead respond with `100.89.243.99`. This approach is more scalable if you have a large number of records that need this treatment.

Hopefully this helps someone else out as the split-horizon documentation for Technitium DNS Server is a little sparse at the time of writing. I'm very happy with the solution and it has been working perfectly for me.
