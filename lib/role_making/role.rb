module RoleMaking
  module Role

    def add_role(role_name)
      self.roles(role_name: role_name.to_s).first_or_create
    end
    alias_method :grant, :add_role

    def has_role?(role_name)
      role_array = if new_record?
                     self.roles.detect { |r| r.name.to_s == role_name.to_s }
                   else
                     self.roles.exist?( name: role_name)
                   end
      !!role_array
    end

    def has_all_roles?(*args)
      args.all? do |item|
        self.has_role?(item)
      end
    end

    def has_any_role?(*args)
      args.any? { |r| self.has_role?(r) }
    end


    def remove_role(role_name)
      self.roles.delete(name: roles_name)
    end

    alias_method :revoke, :remove_role

    def roles_name
      self.roles.select(:name).map { |r| r.name }
    end

  end
end
