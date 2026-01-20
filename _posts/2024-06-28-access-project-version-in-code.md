---
title: Access project version in Unreal Engine
description: How to access the project's version in Unreal Engine and expose it to Blueprints
layout: post
category: Unreal Engine
tags:
  - Unreal Engine
  - C++
  - Blueprint
keywords:
  - Unreal Engine
---

If you want to access your project version in C++ or Blueprints you can implement the following simple blueprint function library method, this can be included in an existing blueprint function library that you might have for your project, otherwise a new one can be created.

```cpp
class MYGAME_API UMyFunctionLibrary : public UBlueprintFunctionLibrary
{
  UFUNCTION(BlueprintPure)
  static FString GetProjectVersion();
}
```
{: file='MyFunctionLibrary.h'}

```cpp
FString UMyFunctionLibrary::GetProjectVersion()
{
  FString ProjectVersion;

  GConfig->GetString(
    TEXT("/Script/EngineSettings.GeneralProjectSettings"),
    TEXT("ProjectVersion"),
    ProjectVersion,
    GGameIni
  );

  return ProjectVersion;
}
```
{: file='MyFunctionLibrary.cpp'}

Now the following blueprint function can be called from any blueprint in your project to get the project version, and formatted as a string like so:

![Get Project Version](/assets/img/posts/2024-06-28-access-project-version-in-code/get-project-version.png)
