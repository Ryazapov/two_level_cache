require "two_level_cache/version"
require "active_support/cache"

module TwoLevelCache
  class Store < ActiveSupport::Cache::Store
    def initialize(options = {})
      super(options)
      @memory_store = ActiveSupport::Cache::MemoryStore.new(options)
      @file_store = ActiveSupport::Cache::FileStore.new(options[:cache_path], options)
    end

    %i[clear cleanup].each do |method_name|
      define_method(method_name) do |*args|
        memory_store.send(method_name, *args)
        file_store.send(method_name, *args)
      end
    end

    %i[read_entry delete_entry modify_value].each do |method_name|
      define_method(method_name) do |*args|
        memory_store.send(method_name, *args) || file_store.send(method_name, *args)
      end
    end

    private

    attr_reader :memory_store, :file_store

    def write_entry(*args)
      memory_store.send(:write_entry, *args)
    end
  end
end
