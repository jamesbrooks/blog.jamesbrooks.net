---
title: Websockets and dedicated servers
layout: post
category: Unreal Engine 4
tags:
  - Unreal Engine 4
  - UE4
  - C++
  - Websockets
keywords:
  - Unreal Engine 4
  - UE4
  - Websockets
  - Dedicated Server
  - Linux
  - Android
  - Oculus Quest
  - Error
  - Crash
  - nullptr
---

Quick post!

I was having trouble using [Websockets](https://docs.unrealengine.com/4.27/en-US/API/Runtime/WebSockets/) in Unreal Engine 4 when building the project as a linux dedicated server. `FWebSocketsModule::Get().CreateWebSocket` was erroring with a fatal error (invalid attempt to read memory) as `FWebSocketsModule` was `nullptr` on those builds. This was working happily in-editor.

The problem was that the module was not loaded for linux dedicated server build which can be fixed with the following before calling `FWebSocketsModule::Get()`:

```cpp
  if (!FModuleManager::Get().IsModuleLoaded("WebSockets"))
  {
    FModuleManager::Get().LoadModule("WebSockets");
  }

  // Call `CreateWebSocket` as usual
  Socket = FWebSocketsModule::Get().CreateWebSocket(ServerURL, ServerProtocol);
```

After `FModuleManager::Get().LoadModule("WebSockets")` had been called the issue was resolved and the dedicated server build was able to connect to a websocket server how I expected it to.
