module RoleMaking
  module Resourcing
    extend ActiveSupport::Concern

    included do
      @groups = []
      @current_group = nil
      @resources = []
      Res = Struct.new(:name,:group,:verb,:hashs,:object,:behavior)
      #need set locale yml file
      class Res
        def human_name(scope=nil)
          action,res = self.name.split("@")
          I18n.t(["actions.#{action}","#{scope.nil? ? 'activerecord.models' : scope}.#{res}"]).join rescue self.name
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
          add_resource(group,verb,object,hashs,behavior)
        end
      end

      def add_resource(group,verb,object,hashs,behavior)
        name = "#{verb}@#{hashs.try(:delete,:res_name) || object.to_s.underscore}"
        resource = Res.new(name,group,verb,hashs,object,behavior)
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
