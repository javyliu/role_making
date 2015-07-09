module RoleMaking
  module Generators
    class RoleMakingGenerator < Rails::Generators::NamedBase

      source_root File.expand_path('../templates', __FILE__)
      argument :role_cname, :type => :string, :default => "Role"

      namespace :role_making

      desc "Generates a model with the given NAME and a migration file."

      def inject_user_class
        model_path = File.join("app", "models", "#{name.underscore}.rb")

        insert_into_file(model_path,after: "ActiveRecord::Base\n") do
          "  role_making role_cname: '#{role_cname.classify}'\n"
        end

      end

      def copy_resource_file
        copy_file "resource.rb",File.join("app","models","resource.rb")
      end

      def create_role_model
        Rails::Generators.invoke "active_record:model",["RoleResource","--no-migration","--no-fixture"], behavior: behavior
        Rails::Generators.invoke "active_record:model",[role_cname,"--no-migration","--no-fixture"], behavior: behavior
        inject_role_class if behavior == :invoke
        inject_role_resource_class if behavior == :invoke
        create_migration
      end

      #add ability files
      def create_ability_model
        Rails::Generators.invoke "cancan:ability",["-s"],behavior: behavior
        model_path = File.join("app", "models", "ability.rb")
        insert_into_file(model_path, after: "    #   end\n") do
          <<-EOF
    #{role_cname.classify}.all_without_reserved.each do |role|
      next unless user.has_role?(role.name)
      role.role_resources.each do |res|
        resource = Resource.find_by_name(res.resource_name)
        if block = resource.behavior
          can resource.verb,resource.object do |obj|
            block.call(user,obj)
          end
        elsif resource.hash
          eval_con = resource.hash.delete(:con).try(:inject,{}) do |r,(k,v)|
            r[k] = eval(v)
            r
          end
          can resource[:verb],resource[:object],resource[:hash].merge(eval_con)
        else
          can resource[:verb],resource[:object]
        end
      end
    end \n
          EOF


        end if behavior == :invoke

      end


      def show_readme
        if behavior == :invoke
          readme "../USAGE"
        end
      end

      private
      def inject_role_class
        model_path = File.join("app", "models", "#{role_cname.underscore}.rb")

        join_table = "#{name.tableize}_#{role_cname.tableize}"
        insert_into_file(model_path,after: "ActiveRecord::Base\n") do
          <<-EOF
            RESERVED = [:admin,:guest]
            has_and_belongs_to_many :#{name}, join_table: :#{join_table}
            has_many :role_resources, dependent: :destroy

            def self.all_with_reserved
              self.all.where("name not in ?",RESERVED)
            end
          EOF
        end

      end


      def inject_role_resource_class
        model_path = File.join("app", "models", "role_resource.rb")

        insert_into_file(model_path,after: "ActiveRecord::Base\n") do
          <<-EOF
            validates_uniqueness_of :resource_name, scope: :#{role_cname.underscore}_id

            belongs_to :#{role_cname.underscore}
          EOF
        end
      end


      def create_migration
        role_table = role_cname.tableize
        join_table = "#{name.tableize}_#{role_table}"
        user_reference = name.underscore
        role_reference = role_cname.underscore
        role_file = "db/migrate/201506250001_role_making_create_#{role_table}.rb"
        role_resource_file = "db/migrate/201506250002_role_making_create_role_resources.rb"

        create_file role_file do
          <<-EOF
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
        create_file role_resource_file do
          <<-EOF
          class RoleMakingCreateRoleResources < ActiveRecord::Migration
            def change
              create_table(:role_resources) do |t|
                t.references :#{role_reference}
                t.string :resource_name

                t.timestamps
              end

              add_index(:role_resources, :#{role_reference}_id)
            end
          end
          EOF
      end
      end



    end
  end
end
