require 'jsonapi/deserializable/resource'

module JSONAPI
  module Deserializable
    # https://jsonapi.org/format/#document-top-level
    class Payload
      module DSL
        existing_nodes = {}

        DEFAULT_META_BLOCK = proc { |m| m }
        DEFAULT_ERROR_BLOCK = proc { |e| e }
        DEFAULT_LINKS_BLOCK = proc { |l| l }
        DEFAULT_DATA_BLOCK = proc { |d| JSONAPI::Deserializable::Resource.new(d) }

        def data(&block)
          self.data_block = block || DEFAULT_DATA_BLOCK
        end

        # https://jsonapi.org/format/#error-objects
        def errors(&block)
          self.error_block = block || DEFAULT_ERROR_BLOCK
        end

        # https://jsonapi.org/format/#document-meta
        def meta(&block)
          self.meta_block = block || DEFAULT_META_BLOCK
        end

        # https://jsonapi.org/format/#document-links
        def links(&block)
          self.links_block = block || DEFAULT_LINKS_BLOCK
        end

        # def included
        # end
      end
    end
  end
end
