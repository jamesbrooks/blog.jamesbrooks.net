---
title: Default transformations for ActiveStorage attachments
description: Declare default transformations for ActiveStorage attachments
layout: post
category: Ruby on Rails
tags:
  - Rails
  - Ruby
  - ActiveStorage
keywords:
  - Rails
  - Ruby
  - ActiveStorage
  - Variants
  - Image Cropping
  - Default Transformations
og_image: https://blog.jamesbrooks.net/assets/img/posts/2020-06-11-default-transformations-for-active-storage-attachments/thumb.png
---

Recently I needed to crop images across a variety of models and attachments on a recent Rails project using [ActiveStorage](https://edgeguides.rubyonrails.org/active_storage_overview.html).

The initial native solution was to implement methods in each of these models, check to see if there are any stored crop settings, and perform cropping and any extra passed in image transformations to `variant`. This quickly bloated out off control.

To combat this the following monkey-patch was implemented to apply default transformations to `variant` calls across the project. Right now it only handles the needed image cropping but would be easily extendable to a variety of other situations (e.g. checking for and calling a `default_name_transformations` method on the record and merging that into the provided variant transformations).

The monkey-patch to support image cropping looks like this:

```ruby
module ActiveStorage
  class Attached
    CROP_SETTINGS_SUFFIX = "_crop_settings".freeze

    def variant(transformations)
      attachment.public_send(:variant, default_transformations.merge(transformations))
    end

  private
    def default_transformations
      {
        crop: crop_transformation
      }.compact
    end

    def crop_transformation
      attachment_crop_settings_attribute = "#{name}#{CROP_SETTINGS_SUFFIX}"
      return unless record.respond_to?(attachment_crop_settings_attribute)

      if (crop_settings = record.send(attachment_crop_settings_attribute)).present?
        w, h, x, y = crop_settings.values_at("w", "h", "x", "y")
        "#{w}x#{h}+#{x}+#{y}"
      end
    end
  end
end
```
{: file='lib/ext/active_storage/attached.rb'}

```ruby
module TestApp
  class Application < Rails::Application
    # ...

    config.to_prepare do
      require 'ext/active_storage/attached'
    end
  end
end
```
{: file='config/application.rb'}
