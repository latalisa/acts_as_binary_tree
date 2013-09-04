module ActiveRecord
  module Acts
    module BinaryTree
      def self.included(base)
        base.extend(ClassMethods)
      end

      # Specify this +acts_as+ extension if you want to model a binary tree structure by 
      # providing a parent association and a children association.
      module ClassMethods
        def act_as_binary_tree(options = {})
          configuration = { left_key: 'left_id', right_key: 'right_id', parent_key: 'parent_id' }
          configuration.update(options) if options.is_a?(Hash)

          belongs_to :left, class_name: name, foreign_key: configuration[:left_key]
          belongs_to :right, class_name: name, foreign_key: configuration[:right_key]
          belongs_to :parent, class_name: name, foreign_key: configuration[:parent_key]
        end
      end

      module InstanceMethods
        # Returns a list of ancestors, starting from parent until root
        def ancestors
          node, nodes = self, []
          nodes << node = node.parent while node.parent
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
          get_childrens(:left)
        end

        # Returns all right childrens
        def get_right
          get_childrens(:right)
        end

        # Returns all childrens or children for a specific side (leg)
        def get_childrens(options={})
          configuration = {}
          configuration.update(options) if options.is_a?(Hash)

          node, left, right = self, [], []
          left << node = node.left while node.left unless options[:side] == 'right'
          right << node = node.right while node.right unless options[:side] == 'left'

          {left: left, right: right}
        end

        def add_node(node, options={})
          configuration = { mode: :balanced }
          configuration.update(options) if options.is_a?(Hash)

          # TODO: 


          
        end

        def add_node_into(node, options={})
          eval <<-EOV
            if self.#{var}.nil?
              self.#{var} = new_user
              new_user.parent_id = self.id
              new_user.save
            else
              self.#{var}.add_to_tree(new_user, direction)
            end
          EOV
        end

      end
    end
  end
end