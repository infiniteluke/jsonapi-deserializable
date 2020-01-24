class PayloadDenormalizer
  attr_accessor :root
  def initialize(root_data, included, existing_nodes = {})
    @existing_nodes = existing_nodes
    @root = ResourceNode.new(root_data[:id], root_data[:attributes], root_data[:type])
    @existing_nodes["#{root_data[:type]}#{root_data[:id]}"] = @root
    @included = included

    denormalize(@root, root_data[:relationships])
  end

  def denormalize(node, relationships)
    relationships.keys.each do |key|
      relationships[key][:data].each do |datum|
        child = find_node(datum[:id], datum[:type])
        if child.blank?
          included_data = find_included_data(datum[:id], datum[:type])
          child = ResourceNode.new(included_data[:id], included_data[:attributes], included_data[:type])
          @existing_nodes["#{included_data[:type]}#{included_data[:id]}"] = child
          call(child, included_data[:relationships]) if included_data[:relationships].present?
        end
        node.append_child(key, child)
      end
    end
  end

  def find_node(id, type)
    @existing_nodes["#{type}#{id}"]
  end

  def find_included_data(id, type)
    @included.find { |datum| datum[:id] == id && datum[:type] == type}
  end
end

class ResourceNode
  attr_accessor :id, :attributes, :type, :children
  def initialize(id, attributes = {}, type = '')
    @id = id
    @attributes = attributes
    @type = type
    @children = {}
  end

  def append_child(children_key, children_node)
    if @children[children_key].present?
      @children[children_key].append(children_node)
    else
      @children[children_key] = [children_node]
    end
  end

  def find(id, type)
    if @id == id && @type == type
      self
    else
      @children.values.flatten.map { |child| child.find(id, type) }.compact&.first
    end
  end
end