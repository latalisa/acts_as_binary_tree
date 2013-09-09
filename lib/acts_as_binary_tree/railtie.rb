# -*- encoding: utf-8 -*-
module ActsAsBinaryTree

  class Railtie < Rails::Railtie
    initializer 'acts_as_binary_tree.insert_into_active_record' do
      ActiveSupport.on_load :active_record do
        ActiveRecord::Base.send(:include, ActsAsBinaryTree)
      end
    end
  end

end