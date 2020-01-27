require 'jsonapi/deserializable/payload/dsl'

module JSONAPI
  module Deserializable
    class Payload
      extend DSL

      attr_accessor :meta, :errors, :links, :data, :hash

      class << self
        attr_accessor :meta_block, :error_block, :links_block, :data_block
      end

      def self.inherited(klass)
        super
        klass.meta_block = meta_block
        klass.error_block = error_block
        klass.links_block = links_block
        klass.data_block = data_block
      end

      def self.call(payload)
        new(payload)
      end

      def initialize(payload)
        @payload = payload || {}
        @meta_object = @payload['meta']
        @error_objects = @payload['errors']
        @links_object = @payload['links']
        @primary_data = @payload['data']
        @included_data = @payload['included']
        deserialize!
        denormalize!

        freeze
      end

      def deserialize!
        @reverse_mapping = {}
        hashes = [deserialize_meta, deserialize_errors, deserialize_links, deserialize_data]
        # validation step?
        @hash = hashes.reduce({}, :merge)
      end

      def deserialize_meta
        block = self.class.meta_block
        return {} unless block

        @meta = { meta: block.call(@meta_object) }
      end

      def deserialize_errors
        block = self.class.error_block
        return {} unless block

        @errors = { errors: @error_objects.map(&block) }
      end

      def deserialize_links
        block = self.class.links_block
        return {} unless block

        @links = { links: block.call(@links_object) }
      end

      # recursive deserialization of included relationships (dep tree)
      def deserialize_included
        block = self.class.included_block
        return {} unless block

        @included = { included: }
      end

      def deserialize_data
        block = self.class.data_block
        return {} unless block

        @data = {  data: @primary_data.kind_of?(Array) ? @primary_data.map{ |r| block.call(r, @included) } : block.call(@primary_data, @included) }
        # @data = { data: block.call(@primary_data, @included) }
      end
    end
  end
end
