---
title: Fixing 'movement not allowed' for respawned pawns
layout: post
category: Unreal Engine 4
tags:
  - Unreal Engine 4
  - UE4
  - C++
  - UPathFollowingComponent
keywords:
  - Unreal Engine 4
  - UE4
  - UPathFollowingComponent
  - AI
  - Movement
  - movement not allowed
  - SimpleMoveToLocation
  - UPathFollowingComponent
  - UNavMovementComponent
---

Have you ran into the issue "SimpleMove failed for X: movement not allowed" when trying to call
Simple Move to Location after respawning a multiplayer pawn?

After a player's pawn has been killed and respawned (a new pawn spawned and possessed by the PlayerController) we were unable to call [UAIBlueprintHelperLibrary::SimpleMoveToLocation](https://docs.unrealengine.com/en-US/API/Runtime/AIModule/Blueprint/UAIBlueprintHelperLibrary/SimpleMoveToLocation/index.html) with out error "movement not allowed" presenting itself. This situation would be present if you were starting with Unreal's Top Down example project and modified it to support pawn respawning.

The issue is that `Simple Move To Location` creates and attaches a [UPathFollowingComponent](https://docs.unrealengine.com/en-US/API/Runtime/AIModule/Navigation/UPathFollowingComponent/index.html) to the Controller if one isn't present. Part of the initialize of this component caches the Movement Component ([UNavMovementComponent](https://docs.unrealengine.com/en-US/API/Runtime/Engine/GameFramework/UNavMovementComponent/index.html)) of the currently possessed Pawn.

When a new pawn is possessed by the Controller a delegate is broadcasted to update the Movement Component on the Path Following Component in [OnPossess](https://docs.unrealengine.com/en-US/API/Runtime/Engine/GameFramework/APlayerController/OnPossess/index.html), which is ONLY ran on Authority (i.e. on the server). Ideally this delegate would also had been invoked on non-Authority as well.

As a fix we can manually instruct the attached Path Following Component to update its cached Movement Component on the non-authority Player Controller at an appropriate time, e.g. OnRep_Pawn

```cpp
/**
 * UPathFollowingComponent registers only to server-only delegates for detect pawn changes.
 * Invoke the same functionality on the client-side.
*/
if (Role < ROLE_Authority)
{
  UPathFollowingComponent* PathFollowingComp = FindComponentByClass<UPathFollowingComponent>();
  if (PathFollowingComp)
  {
    PathFollowingComp->UpdateCachedComponents();
  }
}
```

After this change has been made `SimpleMoveToLocation` will function as expected!
