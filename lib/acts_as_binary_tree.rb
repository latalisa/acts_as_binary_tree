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
      configuration = { 
        left_key: 'left_id', 
        right_key: 'right_id', 
        parent_key: 'parent_id',
        reference_key: 'reference_id'
      }
      configuration.update(options) if options.is_a?(Hash)

      belongs_to :left, class_name: name, foreign_key: configuration[:left_key]
      belongs_to :right, class_name: name, foreign_key: configuration[:right_key]
      belongs_to :parent, class_name: name, foreign_key: configuration[:parent_key]
      belongs_to :reference, class_name: name, foreign_key: configuration[:reference_key]

      class_eval <<-EOV
        include ActsAsBinaryTree::InstanceMethods

        after_save :set_place_in_tree
      EOV
    end
  end

  module InstanceMethods
    # Returns a list of ancestors, starting from parent until root
    def ancestors(options={})
      node, nodes = self, []
      nodes << node = node.parent while node.parent
      nodes
    end

    # Returns a list of nodes, starting node as root until last node
    def nodes(options={})
      configuration = {}
      configuration.update(options) if options.is_a? Hash

      node, nodes = self, []
      
      nodes.concat([node.left].concat(node.left.nodes)) if node.left && configuration[:side] != :right
      nodes.concat([node.right].concat(node.right.nodes)) if node.right && configuration[:side] != :left

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
      nodes(side: :left)
    end

    # Returns all right childrens
    def get_right
      nodes(side: :right)
    end

    def add_node(node, options={})
      configuration = { mode: :balanced }
      configuration.update(options) if options.is_a?(Hash)

      # TODO: Implement balanced mode
      # START Workaround while we don't have balanced mode yet.
      configuration[:mode] = :right if configuration[:mode].nil? || configuration[:mode] == :balanced
      # END Workaround
      add_node_into(node, direction: configuration[:mode])
    end

    def add_node_into(node, options={})
      direction = options[:direction].to_s
      eval <<-EOV
        if self.#{direction}.nil?
          self.#{direction} = node
          node.parent_id = self.id

          self.save
          node.save
        else
          self.#{direction}.add_node(node, direction)
        end
      EOV
    end

    private
    def set_place_in_tree
      reference.add_node(self) unless parent
    end

  end
end