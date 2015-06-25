module RoleMaking
  module Resourcing
    extend ActiveSupport::Concern

    included do
      @groups = []
      @current_group = nil
      @resources = []
    end

    module ClassMethods
      def group(name,&block)
        @groups << name
        @groups.uniq!
        @current_group = name
        block.call
      end

      def resource(verb_or_verbs,object,&block)
        raise "Need define group first" if @current_group.nil?
        group = @current_group
        behavior = block
        Array.wrap(verb_or_verbs).each do |verb|
          add_resource(group,verb,object,behavior)
        end
      end

      def add_resource(group,verb,object,behavior)
        name = "#{verb}_#{object.to_s.underscore}"
        resource = {
          name: name,
          group: group,
          verb: verb,
          object: object,
          behavior: behavior
        }
        @resources << resource
      end

      def each_group(&block)
        @groups.each do |group|
          block.call(group)
        end
      end

      def each_resources_by(group,&block)
        @resources.find_all{|r| r[:group] == group}.each(&block)
      end

      def find_by_name(name)
        resource = @resources.detect { |e| e[:name] == name.to_s }
        raise "not found resources by name: #{name}" unless resource
        resource

      end
    end


  end


end
