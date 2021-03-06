require 'role_making/railtie' if defined?(Rails)
require 'role_making/role'
require "role_making/version"

module RoleMaking
  class Error < StandardError; end

  attr_accessor :role_cname, :role_join_table_name, :role_table_name

  def role_making(options = {})
    include Role
    #extend Dynamic if RoleMaking.dynamic_shortcuts

    options.reverse_merge!({:role_cname => 'Role'})
    self.role_cname = options[:role_cname]
    self.role_table_name = self.role_cname.tableize.gsub(/\//, "_")

    default_join_table = [self.to_s.tableize.gsub(/\//, "_"),self.role_table_name].sort.join("_")
    options.reverse_merge!({:role_join_table_name => default_join_table})
    self.role_join_table_name = options[:role_join_table_name]

    rolify_options = { :class_name => options[:role_cname].camelize }
    rolify_options.merge!({ :join_table => self.role_join_table_name })
    rolify_options.merge!(options.reject{ |k,v| ![ :before_add, :after_add, :before_remove, :after_remove ].include? k.to_sym })

    has_and_belongs_to_many :roles, rolify_options

    #load_dynamic_methods if RoleMaking.dynamic_shortcuts
  end

end
