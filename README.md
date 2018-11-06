# Sequel::KeysetPagination

[![Build Status](https://travis-ci.org/sarahhenkens/sequel-keyset_pagination.svg?branch=master)](https://travis-ci.org/sarahhenkens/sequel-keyset_pagination)

Adds support to Sequel Dataset with both an `before` and `after` cursor. Allowing you to slice your dataset in both directions.

Provides cursor support for Relay like pagination: https://facebook.github.io/relay/graphql/connections.htm

## To install
```ruby
# Activate the extension:
Sequel::Database.extension :keyset_pagination
# or
DB.extension :keyset_pagination
```

### Simple pagination example
```ruby
# Activate the extension:
Sequel::Database.extension :keyset_pagination
# or
DB.extension :keyset_pagination

# Get your first collection of records
DB[:records].order(:id).limit(10)

# Pass the last record's ID as the seek cursor to get the next page
DB[:records].order(:id).limit(5).seek(after: 1125)
```

### Multiple column ordering (example tv episodes)
```ruby
# To get all episodes after episode 5 of season 1:
DB[:episodes].order(:season_nr, :ep_nr).limit(5).seek(after: [1, 5])
```
In the above example, both `1x06` up to `1x20` and all future episodes after `s02` will be includes in the dataset.

### Slicing in both directions
```ruby
# You can pass both an `after` and `before` cursor to seek
DB[:posts].order(:created_at).seek(before: '2018-10-02T15:00:00Z', after: '2016-10-02T15:00:00Z')
```
This will slice your dataset between those two cursors. An unlimited amount of sort columns are supported.
