---
title: Steam GetAuthTicketForWebApi in Unreal Engine
description: How to call Steam's GetAuthTicketForWebApi in Unreal Engine and expose it to Blueprints
layout: post
category: Unreal Engine
tags:
  - Unreal Engine
  - C++
  - Blueprint
  - Steam
keywords:
  - Unreal Engine
  - Steam
  - Steamworks
  - Web API
  - Authentication
---

When working with Steam in Unreal Engine you may want to authenticate a player to a backend server. The [Steamworks documentation on authentication](https://partner.steamgames.com/doc/features/auth) recommends using the Web API for this purpose, where a client generates an auth ticket ([ISteamUser::GetAuthTicketForWebApi](https://partner.steamgames.com/doc/api/ISteamUser#GetAuthTicketForWebApi)) which is then sent to the backend server for validation ([ISteamUserAuth/AuthenticateUserTicket](https://partner.steamgames.com/doc/webapi/ISteamUserAuth#AuthenticateUserTicket)).

We want to call `GetAuthTicketForWebApi` from Unreal Engine and expose it to Blueprints. To do this we need to call `GetLinkedAccountAuthToken` from the Steam subsystem identity interface. I implement this in my game's custom [Game Instance](https://dev.epicgames.com/documentation/en-us/unreal-engine/gameplay-framework-in-unreal-engine) class. Below is an example of how to do this.

To generate a Web API Auth Ticket in Unreal Engine the following should be done:

1. Update your project's `Build.cs` file to include the `Steamworks`, `OnlineSubsystem`, and `OnlineSubsystemSteam` modules.

```cpp
PublicDependencyModuleNames.AddRange(new string[] { ..., "Steamworks", "OnlineSubsystem", "OnlineSubsystemSteam" });
```
{: file='Build.cs'}

2. Call `GetLinkedAccountAuthToken` from the Steam subsystem identity interface (here I have implemented this in my custom Game Instance class with method/delegate that's accessible from Blueprints):

```cpp
DECLARE_DYNAMIC_DELEGATE_TwoParams(FGetSteamAuthTicketForWebApiResponse, bool, bWasSuccessful, const FString&, AuthToken);

UCLASS()
class MY_GAME_API UMyGameInstance : public UGameInstance
{
  UFUNCTION(BlueprintCallable)
  static void GetSteamAuthTicketForWebApi(const FGetSteamAuthTicketForWebApiResponse& Delegate);
};
```
{: file='MyGameInstance.h'}

```cpp
#include "OnlineSubsystemNames.h"
#include "OnlineSubsystemSteam.h"
#include "Interfaces/OnlineIdentityInterface.h"

void UMyGameInstance::GetSteamAuthTicketForWebApi(const FGetSteamAuthTicketForWebApiResponse& Delegate)
{
  FOnlineSubsystemSteam* SteamSubsystem = static_cast<FOnlineSubsystemSteam*>(IOnlineSubsystem::Get(STEAM_SUBSYSTEM));
  if (SteamSubsystem != nullptr)
  {
    SteamSubsystem->GetIdentityInterface()->GetLinkedAccountAuthToken(0, TEXT("WebAPI:MyGame"), IOnlineIdentity::FOnGetLinkedAccountAuthTokenCompleteDelegate::CreateLambda([Delegate](int32 LocalUserNum, bool bWasSuccessful, const FExternalAuthToken& AuthToken)
    {
      Delegate.ExecuteIfBound(bWasSuccessful, AuthToken.TokenString);
    }));
  }
}
```
{: file='MyGameInstance.cpp'}

> Note: in the above snippet there is a hardcoded text value "WebAPI:MyGame", which is composed of two parts separated by a colon.
>
> The first part of this string must be `WebAPI` to indicate to `GetLinkedAccountAuthToken` that we want a Web API token from Steam.
>
> The second part is an identity string, this can be whatever you want but the same string must be used when calling `AuthenticateUserTicket` on your backend server.
{: .prompt-info }

The resulting token can then be sent to your backend server for validation. The backend server should call `AuthenticateUserTicket` to validate the token and ensure the player is who they say they are. Successful validation will return the player's Steam ID.
