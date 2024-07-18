---
title: Instant velocity character movement
description: How to make a Pawn (using CharacterMovementComponent) move instantly at maximum speed
layout: post
category: Unreal Engine
tags:
  - Unreal Engine
  - C++
keywords:
  - Unreal Engine
  - Character Movement
  - Velocity
  - Acceleration
og_image: https://blog.jamesbrooks.net/assets/img/posts/2019-10-17-instant-velocity-character-movement/thumb.png
---

Unreal Engine's [CharacterMovementComponent](https://docs.unrealengine.com/en-US/Gameplay/Networking/CharacterMovementComponent/index.html) is a fantastic component for easily granting a Pawn network-replicated and client-predictive movement with a lot of functionality out of the box that often just works. Though sometimes the way it performs movement is not what we want.

The `CharacterMovementComponent` primarily performs movement by acceleration and velocity and for a few different style of games (such as a MOBA, RTS or ARPG) movement-by-acceleration is often not desired as usually we would expect a pawn to have it's velocity set to it's maximum speed when moving, and then stop immediately once it's reached it's target.

Depending on the game you're building it might be reasonable to build or use a different movement component in lieu of `CharacterMovementComponent`, but at the same time you'd be giving up a lot of really nice out-of-the-box features `CharacterMovementComponent` provides such as client-prediction.

It's possible to minimise the effects of the acceleration-based movement by having `MaxAcceleration` and `BrakingFriction` set to extreme values to try and trick `CharacterMovementComponent` into accelerating/decellerating (almost) immediately, though this can lead to some strange edge cases when velocity doesn't fully change in a single frame.

What if we just subclass `CharacterMovementComponent` and stop using acceleration to determine velocity? Turns out it's really trivial to do and we only need to override one aptly-named method: [CalcVelocity](https://docs.unrealengine.com/en-US/API/Runtime/Engine/GameFramework/UCharacterMovementComponent/CalcVelocity/index.html). We can override `CalcVelocity` to perform instant changes to velocity rather than incremental.

```cpp
void UMyCharacterMovementComponent::CalcVelocity(float DeltaTime, float Friction, bool bFluid, float BrakingDeceleration)
{
  // There may/may-not be some times you want to call super.
  // have a look through CalcVelocity to find out. We'll call super here just in case.
  Super::CalcVelocity(DeltaTime, Friction, bFluid, BrakingDeceleration);

  if (Acceleration.IsZero())
  {
    // Stop movement
    Velocity = FVector::ZeroVector;
  }
  else
  {
    // Set velocity to max speed in the direction of acceleration (ignoring magnitude)
    Velocity = GetMaxSpeed() * Acceleration.GetSafeNormal();
  }
}
```

Voilà! we now have character movement where movement starts immediately at maximum speed and stops immediately when no acceleration input is present, exactly what we wanted for our game!

If you're unsure about how to go about subclassing `CharacterMovementComponent`, [have a read of this](https://wiki.unrealengine.com/Custom_Character_Movement_Component).
