# -*- encoding: utf-8 -*-
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

      has_many :referees, class_name: name, foreign_key: configuration[:reference_key]

      class_eval <<-EOV
        include ActsAsBinaryTree::InstanceMethods

        after_create :set_place_in_tree
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
      
      nodes += ([node.left] + node.left.nodes) if node.left && configuration[:side] != :right
      nodes += ([node.right] + node.right.nodes) if node.right && configuration[:side] != :left

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
      configuration = {}
      configuration.update(options) if options.is_a?(Hash)

      direction = get_direction(node, configuration[:mode].to_sym)
      # puts direction

      add_node_into(node, direction: direction)
    end

    def get_direction(node, direction)
      directions = [:left, :right]
      return direction if directions.include?(direction.to_sym)

      begin
        last_side = node.reference.referees.last(2)[0].side.to_sym
        directions.delete last_side
        return directions[0]
      rescue
        return :left
      end
    end

    def add_node_into(node, options={})
      direction = options[:direction].to_s

      eval <<-EOV
        if self.#{direction}.nil?
          self.update_attribute(:#{direction}, node)
          node.update_attribute(:parent_id, self.id)
          node.update_attribute(:side, direction)
        else
          self.#{direction}.add_node(node, mode: direction.to_sym)
        end
      EOV
    end

    private
    def set_place_in_tree
      return if reference_id.nil? && parent_id.nil?
      node, mode = self, (self.side || reference.distribution_setup).to_sym
      reference.add_node(node, mode: mode) unless parent
    end

  end
end