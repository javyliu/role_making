module RoleMaking
  module Generators
    class RoleMakingGenerator < Rails::Generators::NamedBase

      source_root File.expand_path('../templates', __FILE__)
      argument :role_cname, :type => :string, :default => "Role"

      namespace :role_making

      desc "Generates a model with the given NAME and a migration file."

      def inject_user_class
        model_path = File.join("app", "models", "#{name}.rb")

        inject_into_class(model_path,name.classify.constantize) do
          "  role_making role_cname: '#{role_cname.classify}'\n"
        end

      end

      def copy_resource_file
        copy_file "resource.rb",File.join("app","models","resource.rb")
      end

      def create_role_model
        invoke "active_record:model",[role_cname], migration: false
      end

      def create_migration
        role_table = role_cname.tableize
        join_table = "#{name.tableize}_#{role_table}"
        user_reference = name.underscore
        role_reference = role_cname.underscore
        file = "db/migrate/#{Time.now.to_s(:number)}_role_making_create_#{role_table}.rb"

        create_file file do
<<EOF
class RoleMakingCreate#{role_table.camelize} < ActiveRecord::Migration
  def change
    create_table(:#{role_table}) do |t|
      t.string :name
      t.string :display_name

      t.timestamps
    end

    create_table(:#{join_table}, :id => false) do |t|
      t.references :#{user_reference}
      t.references :#{role_reference}
    end

    add_index(:#{role_table}, :name)
    add_index(:#{join_table}, [ :#{user_reference}_id, :#{role_reference}_id ])
  end
end
EOF

        end
      end

      def show_readme
        readme "../USAGE"
      end


    end
  end
end
