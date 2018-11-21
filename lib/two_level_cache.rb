require "two_level_cache/version"
require "active_support/cache"

module TwoLevelCache
  class Store < ActiveSupport::Cache::MemoryStore
    def initialize(options = {})
      super(options)

      cache_path = options.delete(:cache_path)
      @file_store = ActiveSupport::Cache::FileStore.new(cache_path, options)
    end

    %i[clear cleanup].each do |method_name|
      define_method(method_name) do |*args|
        super(*args)
        file_store.public_send(method_name, *args)
      end
    end

    def prune(target_size, max_time = nil)
      return if pruning?

      @pruning = true
      begin
        move_entries(target_size, max_time)
      ensure
        @pruning = false
      end
    end

    private

    attr_reader :file_store

    def read_entry(key, options)
      entry = super

      if entry.nil?
        entry = file_store.send(:read_entry, file_store_normalize_key(key, options), options)
        write_entry(key, entry, {}) if entry
      end

      entry
    end

    def write_entry(key, entry, options)
      file_store.delete(key, options)

      super
    end

    def delete_entry(key, options)
      super || file_store.delete(key, options)
    end

    def modify_value(name, amount, options)
      super || file_store.send(:modify_value, name, amount, options)
    end

    def move_entries(target_size, max_time)
      start_time = Time.now
      cleanup
      instrument(:prune, target_size, from: @cache_size) do
        keys = synchronize { sorted_key_access }
        keys.each do |key|
          move_entry(key, options)
          break if @cache_size <= target_size || (max_time && Time.now - start_time > max_time)
        end
      end
    end

    def sorted_key_access
      @key_access.keys.sort { |a, b| @key_access[a].to_f <=> @key_access[b].to_f }
    end

    def move_entry(key, options)
      entry = read_entry(key, options)

      return unless delete_entry(key, options)

      options = merged_options(options)
      file_store.send(:write_entry, file_store_normalize_key(key, options), entry, options)
    end

    def file_store_normalize_key(key, options)
      file_store.send(:normalize_key, key, options)
    end
  end
end
