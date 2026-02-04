---
title: Reviving 32-bit Adobe AIR Apps for Modern macOS
description: How to repackage old 32-bit Adobe AIR applications to run on macOS Catalina and later using the HARMAN AIR SDK.
layout: post
category: macOS
tags:
  - macOS
  - Adobe AIR
  - HARMAN
  - Legacy Software
keywords:
  - Adobe AIR
  - 32-bit
  - 64-bit
  - macOS Catalina
  - macOS Sequoia
  - HARMAN AIR SDK
  - Legacy App
---

I had an old educational app that I wanted to run on a newer Intel Mac running Sequoia. The app was built back in 2014 and macOS straight up refused to run it - 32-bit apps haven't been supported since Catalina (10.15). A quick check with `file` on the executable confirmed it was indeed 32-bit Intel only.

Looking inside the .app bundle I noticed it was an [Adobe AIR](https://airsdk.harman.com/) application - there was an `Adobe AIR.framework` in the Frameworks folder and a `.swf` file as the main content. This was actually good news. SWF files are platform-independent bytecode, which means the actual app content should still work fine - it was just the bundled runtime that was outdated.

Adobe handed off AIR development to [HARMAN](https://airsdk.harman.com/) back in 2019, and they've kept it alive with 64-bit support. I wondered what would happen if I just swapped out to a newer Adobe AIR SDK - surely it's not that easy, right?

### What You Need

1. The original .app bundle
2. [HARMAN AIR SDK](https://airsdk.harman.com/download) - requires a free account. I used version 33.1.1 which was designed specifically for migrating legacy AIR apps to 64-bit.

### The Process

First, verify you're dealing with an AIR app:

```bash
# Check the architecture
file "/path/to/YourApp.app/Contents/MacOS/YourApp"
# Should show: Mach-O executable i386

# Look for AIR framework
ls "/path/to/YourApp.app/Contents/Frameworks/"
# Should contain Adobe AIR.framework
```

Copy the Resources folder from the original app to a working directory. Inside you'll find `META-INF/AIR/application.xml` - this is the app descriptor. Create a copy at the root of your working directory and update the namespace from the old AIR version to the new one:

```xml
<!-- Change this -->
<application xmlns="http://ns.adobe.com/air/application/15.0">

<!-- To this -->
<application xmlns="http://ns.adobe.com/air/application/33.1">
```

Download and extract the HARMAN AIR SDK. Then create a self-signed certificate (required for packaging):

```bash
/path/to/AIRSDK/bin/adt -certificate -cn "SelfSigned" 2048-RSA selfsigned.p12 password123
```

Finally, repackage the app with the new runtime:

```bash
/path/to/AIRSDK/bin/adt -package \
    -storetype pkcs12 \
    -keystore selfsigned.p12 \
    -storepass password123 \
    -tsa none \
    -target bundle \
    "YourApp.app" \
    application.xml \
    your_main_file.swf \
    icons_folder \
    other_resource_folders
```

The `-tsa none` flag skips timestamp server verification which can sometimes fail.

### The Result

Turns out it really was that easy. The repackaged app came out as a universal binary with both x86_64 and arm64 architectures - so it runs natively on both Intel and Apple Silicon Macs. First launch requires right-clicking and selecting "Open" to bypass Gatekeeper since it's self-signed, but after that it runs normally.

The app went from completely non-functional on my Intel Sequoia Mac to working perfectly. If you've got old AIR apps lying around that you'd like to keep using, this approach should work for most of them.
