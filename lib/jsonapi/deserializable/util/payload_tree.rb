# require 'jsonapi/deserializable/resource'
require '/Users/appfolio/src/jsonapi-deserializable/lib/jsonapi/deserializable/resource.rb'

class PayloadDenormalizer
  attr_accessor :data_nodes
  def initialize(data, included_data, existing_nodes = {})
    @existing_nodes = existing_nodes
    build_nodes(data, included_data)
    build_edges
  end

  def build_nodes(data, included_data)
    @data_nodes = data.map do |datum|
      resource = JSONAPI::Deserializable::Resource.new(datum)
      resource_node = ResourceNode.new(resource, datum[:relationships])
      @existing_nodes["#{datum[:type]}#{datum[:id]}"] = resource_node
    end

    @included_nodes = included_data.map do |datum|
      resource = JSONAPI::Deserializable::Resource.new(datum)
      resource_node = ResourceNode.new(resource, datum[:relationships])
      @existing_nodes["#{datum[:type]}#{datum[:id]}"] = resource_node
    end
  end

  def build_edges
    (@data_nodes + @included_nodes).each do |node|
      node.relationships&.keys&.each do |key|
        data = node.relationships[key][:data].kind_of?(Array) ?
          node.relationships[key][:data] : [node.relationships[key][:data]]
        data.each do |datum|
          child = find_node(datum[:id], datum[:type])
          if child.blank?
            raise "Node #{datum[:type]} #{datum[:id]} is not in the payload"
          end
          node.append_child(key, child)
        end
      end
    end
  end

  def find_node(id, type)
    @existing_nodes["#{type.to_s}#{id.to_s}"]
  end
end

class ResourceNode
  attr_accessor :resource, :relationships, :children
  def initialize(resource, relationships)
    puts 'res'
    puts resource
    puts 'rel'
    puts relationships
    @resource = resource
    @relationships = relationships
    @children = {}
  end

  def append_child(children_key, children_node)
    if @children[children_key].present?
      @children[children_key].append(children_node)
    else
      @children[children_key] = [children_node]
    end
  end
end
