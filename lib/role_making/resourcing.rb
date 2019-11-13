module RoleMaking
  module Resourcing
    extend ActiveSupport::Concern

    included do
      @groups = []
      @current_group = nil
      @resources = []
      Res = Struct.new(:name,:group,:verb,:hashs,:object,:behavior,:action_scope,:res_scope)
      #need set locale yml file
      class Res
        def human_name
          action,res = self.name.split("@")
          ac = I18n.t(action,scope: (self.action_scope || 'actions'),throw: true) rescue action
          _res = I18n.t(res,scope: (self.res_scope || 'activerecord.models'),throw: true) rescue res
          "#{ac}#{_res}"
        end
      end
    end

    module ClassMethods
      attr_reader :resources,:groups
      def group(name,&block)
        @groups << name
        @groups.uniq!
        @current_group = name
        block.call
      end



      def resource(verb_or_verbs,object,hashs=nil,&block)
        raise "Need define group first" if @current_group.nil?
        group = @current_group
        behavior = block
        Array.wrap(verb_or_verbs).each do |verb|
          add_resource(group,verb,object,hashs.try(:dup),behavior)
        end
      end

      def add_resource(group,verb,object,hashs,behavior)
        name = "#{verb}@#{hashs.try(:delete,:res_name) || object.to_s.underscore}"
        action_scope =  hashs.try(:delete,:action_scope)
        res_scope = hashs.try(:delete,:res_scope)
        hashs = nil if hashs.blank?
        resource = Res.new(name,group,verb,hashs,object,behavior,action_scope,res_scope)
        @resources << resource
      end

      def each_group(&block)
        @groups.each do |group|
          block.call(group)
        end
      end

      def each_resource(&block)
        @resources.group_by(&:group).each(&block)
      end

      def each_resources_by(group,&block)
        @resources.find_all{|r| r.group == group}.each(&block)
      end

      def find_by_name(name)
        resource = @resources.detect { |e| e.name == name.to_s }
        raise "not found resources by name: #{name}" unless resource
        resource

      end
    end


  end
end
