---
title: Enhanced broadcasting with Action Cable
layout: post
category: Ruby on Rails
tags:
  - Ruby
  - Rails
keywords:
  - Rails
  - Ruby
  - ActionCable
  - Web Sockets
  - Optimization
  - Redis
  - broadcast_to
  - block
---

When using [Action Cable](https://guides.rubyonrails.org/action_cable_overview.html) sometimes it is useful to broadcast to a channel only if there are active subscriptions. This can be useful to avoid unnecessary processing and network traffic, as well as reduce the load on the server in cases where generating the broadcast payload is expensive (e.g. a large chunk of HTML).

Recently I ran into a situation in a project where the result of an action should push real-time changes to users where the HTML payload needed to be different on a per-user basis. It was important to only broadcast to users who were currently subscribed to the channel to avoid generating unnecessary HTML payloads as the number of users that can be viewing the page can potentially be quite large.

To solve this I added a monkey-patch to `ActionCable::Channel::Broadcasting` overwriting [`broadcast_to`](https://edgeapi.rubyonrails.org/classes/ActionCable/Channel/Broadcasting/ClassMethods.html#method-i-broadcasting_for) to facilitate both only broadcasting to channels with active subscriptions, as well as only generating payloads if they are actually needed for broadcast. This monkey-patch shown below allows both calling `broadcast_to` as originally defined (accepting a `model` and `message`) as arguments, but also allowing a block to be passed to lazy generate the message payload instead.

```ruby
module ActionCable::Channel::Broadcasting
  module ClassMethods
    def broadcast_to(model, message = nil, &block)
      raise ArgumentError, "Missing message/block" unless message || block

      # Skip broadcast if no subscriptions
      return unless active_subscriptions_for?(model)

      # Yield message content from block if message was not provided
      message ||= yield(block)

      ActionCable.server.broadcast(broadcasting_for(model), message)
    end

    def active_subscriptions_for?(model)
      channel = [
        ActionCable.server.config.cable[:channel_prefix],
        broadcasting_for(model)
      ].compact.join(":")

      Redis.new.pubsub("numsub", channel).last.positive?
    end
  end
end
```
{: file='lib/actioncable/channel/broadcasting.rb'}


### Example Usage

Given an application with multiple chat rooms with users associated with each room through a participant join model. An action could allow a message to be edited, and on successful edit the message should be broadcasted to all users in the chat room.

In this case the message payload is different for each user as it contains different functionality depending on if the user is the author or an admin, so it is important to only generate the payload for users that are actively subscribed to the channel. In this example the `ChatRoomMessageComponent` is a [View Component](https://viewcomponent.org/) that renders the message HTML.

```ruby
# given a chat_room record with a number of associated participants in the room receiving a change to a `message` record
chat_room.participants.find_each do |participant|
  ChatRoomChannel.broadcast_to(participant) do
    {
      action: 'update_message',
      content: ApplicationController.renderer.render(
        ChatRoomMessageComponent.new(message:, participant:)
        layout: false
      )
    }
  end
end
```

In the above example the block argument passed to `broadcast_to` is only evaluated if there are active subscriptions for the channel, saving the application from generating the message HTML payload for users that are not actively subscribed to the channel.
