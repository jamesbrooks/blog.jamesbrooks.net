---
title: PIE instance ID in Unreal Engine
description: How to access the PIE instance ID in Unreal Engine and expose it to Blueprints
layout: post
category: Unreal Engine
tags:
  - Unreal Engine
  - C++
  - Blueprint
  - PIEInstance
keywords:
  - Unreal Engine
---

When Playing in Editor (PIE), in particular with multiple local clients, it can be useful to know which instance of the game you are currently running. This can be useful for debugging, logging, or other purposes (for example I have used this id to communicate to a backend server to authenticate the local clients and have consistent player data served to them).

I expose the PIE instance ID to Blueprints in my game using a blueprint function library. This can be included in an existing blueprint function library that you might have for your project, otherwise a new one can be created.

```cpp
class MYGAME_API UMyFunctionLibrary : public UBlueprintFunctionLibrary
{
  UFUNCTION(BlueprintPure, Category = "Debug", meta = (WorldContext = "WorldContextObject"))
  static int32 PIEInstance(const UObject* WorldContextObject);
}
```
{: file='MyFunctionLibrary.h'}

```cpp
int32 UMyFunctionLibrary::PIEInstance(const UObject* WorldContextObject)
{
  const UWorld* World = GEngine->GetWorldFromContextObject(WorldContextObject, EGetWorldErrorMode::LogAndReturnNull);

  // If we are in the editor, return the PIE instance ID, otherwise return -1 (not in PIE and we won't be using this value anyway)
  if (World->IsEditorWorld())
  {
    // Get world context
    FWorldContext* WorldContext = GEngine->GetWorldContextFromWorld(World);
    if (WorldContext)
    {
      return WorldContext->PIEInstance;
    }
  }

  return -1;
}

```
{: file='MyFunctionLibrary.cpp'}

Now the following blueprint function can be called from any blueprint in your project to get the PIE instance ID of the current client:

![Get Project Version](/assets/img/posts/2024-07-24-pieinstance-in-unreal/pieinstance.webp)
