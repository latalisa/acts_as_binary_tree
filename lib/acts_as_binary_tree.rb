require 'acts_as_binary_tree/version'

module ActsAsBinaryTree
  
  if defined? Rails::Railtie
    require 'acts_as_binary_tree/railtie'
  elsif defined? Rails::Initializer
    raise 'act_as_binary_tree is not compatible with Rails 2.3 or older'
  end
    
  def self.included(base)
    base.extend(ClassMethods)
  end

  # Specify this +acts_as+ extension if you want to model a binary tree structure by 
  # providing a parent association and a children association.
  module ClassMethods
    def acts_as_binary_tree(options = {})
      configuration = { left_key: 'left_id', right_key: 'right_id', parent_key: 'parent_id' }
      configuration.update(options) if options.is_a?(Hash)

      belongs_to :left, class_name: name, foreign_key: configuration[:left_key]
      belongs_to :right, class_name: name, foreign_key: configuration[:right_key]
      belongs_to :parent, class_name: name, foreign_key: configuration[:parent_key]

      class_eval <<-EOV
        include ActsAsBinaryTree::InstanceMethods
      EOV
    end
  end

  module InstanceMethods
    # Returns a list of ancestors, starting from parent until root
    def ancestors(options={})
      configuration = {}
      configuration.update(options) if options.is_a? Hash

      node, nodes = self, []
      
      nodes.concat([node.left].concat(node.left.get_nodes)) if node.left && configuration[:side] != :right
      nodes.concat([node.right].concat(node.right.get_nodes)) if node.right && configuration[:side] != :left

      nodes
    end

    # Returns root
    def root
      node = self
      node = node.parent while node.parent
      node
    end

    # Returns all left childrens
    def get_left
      get_nodes(side: :left)
    end

    # Returns all right childrens
    def get_right
      get_nodes(side: :right)
    end

    def get_nodes(options={})
      
    end

    # FIXME: Under development
    def get_direct_nodes
      node, nodes = self, []
      nodes << node.left
      nodes << node.right
    end

    def add_node(node, options={})
      configuration = { mode: :balanced }
      configuration.update(options) if options.is_a?(Hash)

      # TODO: Implement balanced mode
      # Workarround while we don't have balanced mode yet.
      configuration[:mode] = :left if configuration[:mode].nil? || configuration[:mode] == :balanced
      add_node_into(node, direction: configuration[:mode])
    end

    def add_node_into(node, options={})
      direction = options[:direction].to_s
      eval <<-EOV
        if self.#{direction}.nil?
          self.#{direction} = node
          node.parent_id = self.id

          node.save
          self.save
        else
          self.#{direction}.add_node(node, direction)
        end
      EOV
    end

  end
end