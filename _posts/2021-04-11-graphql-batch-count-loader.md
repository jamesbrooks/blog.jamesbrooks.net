---
title: Count loader for graphql-batch
description: Efficiently counting records and load associations using GraphQL Ruby
layout: post
category: Ruby on Rails
tags:
  - Ruby
  - Rails
  - GraphQL
keywords:
  - Rails
  - Ruby
  - GraphQL
  - Batch
  - N+1
  - Count
  - Associations
  - has_many
  - Preload
  - Join
  - CountLoader
  - Record Loader
  - graphql-ruby
  - graphql-batch
---

When implemented a GraphQL API using [GraphQL Ruby](https://graphql-ruby.org/) it is beneficial to ensure that executed queries don't trigger any N+1 query problems.

One (of many) solutions to this is [graphql-batch](https://github.com/Shopify/graphql-batch) which provides a means of delcaring loaders to perform batched execution, avoding N+1 query problems.

A record and assocation loader is provided by default and these perform their jobs admirably, though alone they do not cover the gamut of N+1 issues that can be encountered.

In this post we'll address the issue of counting generically using `CountLoader`, and more explicitly associations using [`AssociationCountLoader`](#counting-activerecord-associations).

The following example type if fetched multiple times in a query (e.g. as a collection) would cause multiple queries in counting:

```ruby
class Types::UserType < Types::BaseObject
  field :name, String, null: false
  field :post_count, Integer, "blog posts authored by this user", null: false

  def post_count
    object.posts.count
  end
end
```

We can resolve this issue by implementing a `CountLoader` and updating the typing accordingly.

```ruby
class CountLoader < GraphQL::Batch::Loader
  def initialize(model, field)
    super()
    @model = model
    @field = field
  end

  def perform(ids)
    counts = @model.where(@field => ids).group(@field).count

    counts.each { |id, count| fulfill(id, count) }
    ids.each { |id| fulfill(id, 0) unless fulfilled?(id) }
  end
end
```

```ruby
class Types::UserType < Types::BaseObject
  field :name, String, null: false
  field :post_count, Integer, "blog posts authored by this user", null: false

  def post_count
    CountLoader.for(Post, :user_id).load(object.id)
  end
end
```

Using the `CountLoader` above the multiple queries as a result of counting have been resolved. As can be seen the structure of `CountLoader` is very similar to the provided `RecordLoader`.

### Counting ActiveRecord associations

Reddit user [u/Owumaro](https://www.reddit.com/user/Owumaro) suggested using an ActiveRecord association name rather than having to specify the join model and foriegn key back.

The provided `AssociationCountLoader` reflects on the provided relationship to alleviate the need for specifying these extra implementation details (it should be less britle).

```ruby
class AssociationCountLoader < GraphQL::Batch::Loader
  def initialize(model, association_name)
    super()
    @model = model
    @association_name = association_name
  end

  def perform(records)
    reflection = @model.reflect_on_association(@association_name)
    reflection.check_preloadable!

    klass = reflection.klass
    field = reflection.join_primary_key
    counts = klass.where(field => records).group(field).count

    records.each do |record|
      record_key = record[reflection.active_record_primary_key]
      fulfill(record, counts[record_key] || 0)
    end
  end
end
```

Using `AssociationCountLoader` `post_count` in `Types::UserType` changes to:

```ruby
def post_count
  AssociationCountLoader.for(User, :posts).load(object)
end
```

---

**2021-04-14 Update:** Implementations of the loaders shown here are being maintained at [https://github.com/jamesbrooks/graphql-batch-loaders](https://github.com/jamesbrooks/graphql-batch-loaders)
