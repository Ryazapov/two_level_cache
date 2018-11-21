# TwoLevelCache

[![Build Status](https://travis-ci.org/Ryazapov/two_level_cache.svg?branch=master)](https://travis-ci.org/Ryazapov/two_level_cache)

A cache store implementation which has two levels in first level it stores everything into memory in the same process and in second level it stores everything on the filesystem.

This first level has a bounded size specified by the :size options to the initializer (default is 32Mb). When the first level exceeds the allotted size, a cleanup will occur which move to the second level store down to three quarters of the maximum size by moving the least recently used entries.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'two_level_cache'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install two_level_cache

## Usage

Initialize Two Level Cache Store. You can pass all parameters available for [MemoryStore](https://api.rubyonrails.org/classes/ActiveSupport/Cache/MemoryStore.html) and [FileStore](https://api.rubyonrails.org/classes/ActiveSupport/Cache/FileStore.html)

```ruby
store = TwoLevelCache::Store.new(cache_path: "tmp/cache")
```

Writes item to the store

```ruby
store.write("city", "Moscow") # => true
```

Reads item from the store

```ruby
store.write("city") # => "Moscow"
```

Deletes item from the store

```ruby
store.delete("city") # => true
```

Deletes all items from the cache.

```ruby
store.clear
```

Preemptively iterates through all stored keys and removes the ones which have expired.

```ruby
store.cleanup
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Ryazapov/two_level_cache.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
