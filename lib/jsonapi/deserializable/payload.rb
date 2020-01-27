# require 'jsonapi/deserializable/payload/dsl'
require '/Users/appfolio/src/jsonapi-deserializable/lib/jsonapi/deserializable/payload/dsl.rb'
require '/Users/appfolio/src/jsonapi-deserializable/lib/jsonapi/deserializable/util/payload_tree.rb'

module JSONAPI
  module Deserializable
    class Payload
      extend DSL

      attr_accessor :meta, :errors, :links, :data, :included, :hash

      class << self
        attr_accessor :meta_block, :error_block, :links_block, :data_block, :included_block
      end

      def self.inherited(klass)
        super
        klass.meta_block = meta_block
        klass.error_block = error_block
        klass.links_block = links_block
        klass.data_block = data_block
        klass.included_block = included_block
      end

      def self.call(payload)
        new(payload).to_h
      end

      def initialize(payload)
        @payload = payload || {}
        @meta_object = @payload['meta'] || {}
        @error_objects = @payload['errors'] || []
        @links_object = @payload['links'] || {}
        @primary_data = @payload['data'] || {}
        @included_data = @payload['included'] || {}
        deserialize!
        # denormalize!

        freeze
      end

      def to_hash
        @hash
      end
      alias to_h to_hash

      private

      def deserialize!
        @reverse_mapping = {}
        hashes = [deserialize_meta, deserialize_errors, deserialize_links, deserialize_data]
        puts 'hashes'
        puts hashes
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
      # def deserialize_included
      #   block = self.class.included_block
      #   return {} unless block

      #   @included = { included: }
      # end

      def deserialize_data
        data_block = self.class.data_block
        included_block = self.class.included_block
        return {} unless data_block

        primary_data = data_block.call(@primary_data)
        included_data = included_block.call(@included_data)


        graph = PayloadDenormalizer.new(primary_data, included_data)

        @data = { data: graph.data_nodes }

        # @data = {  data: @primary_data.kind_of?(Array) ? @primary_data.map{ |r| block.call(r, @included) } : block.call(@primary_data, @included) }
        # @data = { data: block.call(@primary_data, @included) }
      end
    end
  end
end
