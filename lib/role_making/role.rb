require 'role_making/resourcing'
module RoleMaking
  module Role

    def add_role(role_name)
      role = self.roles.where(name: role_name).first
      unless role
        role = self.class.role_cname.constantize.where(name: role_name.to_s).first_or_initialize
        self.roles << role
      end
      role
    end
    alias_method :grant, :add_role

    def has_role?(role_name)
     # role_array = if new_record?
     #                self.roles.detect { |r| r.name.to_s == role_name.to_s }
     #              else
     #                #self.respond_to?(:cache_roles) ? self.cache_roles.detect{|it| it.name == role_name.to_s} : self.roles.exists?( name: role_name)
     #                self.roles.detect {||}
     #              end
      !!self.roles.detect { |r| r.name.to_s == role_name.to_s }
      #!!role_array
    end

    def has_all_roles?(*args)
      args.all? do |item|
        self.has_role?(item)
      end
    end

    def has_any_role?(*args)
      args.any? { |r| self.has_role?(r) }
    end


    def remove_role(roles_name)
      self.roles.delete(self.class.role_cname.constantize.where(name: roles_name))
    end

    alias_method :revoke, :remove_role

    def roles_name
      #self.roles.select(:name).map { |r| r.name }
      self.roles.map { |r| r.display_name }
    end

  end
end
