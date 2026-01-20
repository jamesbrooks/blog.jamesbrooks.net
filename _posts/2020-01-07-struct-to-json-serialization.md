---
title: Struct to JSON serialization
description: How to serialize a Unreal Engine USTRUCT to JSON or deserializing JSON back to a USTRUCT
layout: post
category: Unreal Engine
tags:
  - Unreal Engine
  - C++
  - JSON
keywords:
  - Unreal Engine
  - JSON
  - Serialize Struct
---

Serializing a Unreal Engine USTRUCT to JSON or deserializing JSON back to a USTRUCT is very painless thanks to the build-in [FJsonObjectConverter](https://docs.unrealengine.com/en-US/API/Runtime/JsonUtilities/FJsonObjectConverter/index.html) class. The process is performed recursively without any extra effort as well as having the ability to include/exclude specific properties from the serialization. Below we'll describe the requirements for using `FJsonObjectConverter` as well as a practical example.

### Requirements

To use `FJsonObjectConverter` you will need to ensure that both `Json` and `JsonUtilities` are included within `PublicDependencyModuleNames` in your projects `Build.cs`, e.g.:

```cpp
PublicDependencyModuleNames.AddRange(new string[] { "Core", "CoreUObject", "Engine", "InputCore", "HeadMountedDisplay", "NavigationSystem", "AIModule", "Json", "JsonUtilities" });
```

You'll also need to include the `JsonObjectConverter.h` header in source files where you make calls to `FJsonObjectConverter`, e.g.

```cpp
#include "Runtime/JsonUtilities/Public/JsonObjectConverter.h"
```

### Example

The examples below will use this following struct as a guide:

```cpp
USTRUCT()
struct FPlayer
{
  GENERATED_BODY()

  UPROPERTY()
  FString Name;

  UPROPERTY()
  int32 Level;

  UPROPERTY()
  TArray<FString> Friends;

  UPROPERTY(Transient)
  FString PropertyToIgnore;
};
```

### Serialization

To serialize a struct to a JSON payload use [FJsonObjectConverter::UStructToJsonObjectString](https://docs.unrealengine.com/en-US/API/Runtime/JsonUtilities/FJsonObjectConverter/UStructToJsonObjectString/1/index.html). This method will operate recursively, so if you have anything liked nested structs, arrays inside of arrays inside of other structs it will operate as expected. Note that the `PropertyToIgnore` property above is marked as `Transient`, this will prevent the property from being serialized. For example:

```cpp
FPlayer Player;
Player.Name = "Frank";
Player.Level = 3;
Player.Friends.Add("Jeff");
Player.PropertyToIgnore = "Gotta Go Fast";

FString JSONPayload;
FJsonObjectConverter::UStructToJsonObjectString(Player, JSONPayload, 0, 0);
```

Will result in the following JSON payload being written to the `JSONPayload` FString:

```json
{
  "name": "Frank",
  "level": 3,
  "friends": ["Jeff"]
}
```

### Deserialization

To deserialize a JSON payload back to a struct use [FJsonObjectConverter::JsonObjectStringToUStruct](https://docs.unrealengine.com/en-US/API/Runtime/JsonUtilities/FJsonObjectConverter/JsonObjectStringToUStruct/index.html). After this above serialization example this method works exactly how you would expect it to. For example:

```cpp
FString JSONPayload = "...";  // The actual payload
FPlayer Player;

FJsonObjectConverter::JsonObjectStringToUStruct(JSONPayload, &Player, 0, 0);

// Player.Name == "Frank"
// Player.Level == 3
// etc..
```

### Final Notes

You will have noticed above that we are passing two 0's as the final arguments to both methods above. These 0's are the `CheckFlags` and `SkipFlags` respectively. These can be used to provide more fine-graned control over what properties are either included (whitelisted) or skipped (blacklisted).

Above we used `Transient` to skip a property above without having to pass this value into `SkipFlags`. This is because `FJsonObjectConverter` uses `Transient` by default when no `SkipFlags` are specified (a very sane default).
