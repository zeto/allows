require 'exceptions'
require 'debugger'

module Allows

  def self.included(base)
    base.extend(ClassMethods)

    base.send :before_filter, :set_permissions
    base.send :before_filter, :check_permissions
    
    class << base
      attr_accessor :permissions
      #cattr_accessor :permission_checker
      attr_accessor :permission_checker
    end
    #class << self
    #  attr_accessor :permission_checker
    #end

    # set default permission_checker
    base.permission_checker = :current_user
  end

  public  

  def check_permissions
    im_allowed = false

    klass = self.class
    if klass.permission_checker && respond_to?(klass.permission_checker)
      if klass.permissions
        permissions_for_action = klass.permissions[action_name.to_sym]
        if permissions_for_action
          permissions_for_action.each do |permission|
            if assert_permission(permission)
              im_allowed = true
            end
          end
        else
          # Can execute the action. No "allow" rule affects this action.
          im_allowed = false
        end
      else
        # Can execute any action. Controller does not declare any "allow" rule
        im_allowed = true
      end
    else
      raise NoPermissionChecker # Permission checker isnt defined, so no permissions can be validated
    end
    raise Unauthorized unless im_allowed
  end

  protected

  def set_permissions
    self.class.set_permissions # Call class method instead
  end

  private

  def assert_permission(permission)
    targetted_permission = /(?<method>.+)_of_(?<target>.+)/.match(permission.to_s)

    # Permission is something like: allow reader_of_post (<permission>_of_<target>)
    if targetted_permission && targetted_permission.captures.size == 2
      raise NoInstanceVariable unless instance_variable_get("@#{targetted_permission[:target]}")
      (self.send self.class.permission_checker).send "#{targetted_permission[:method]}?", instance_variable_get("@#{targetted_permission[:target]}")
    else
      (self.send self.class.permission_checker).send "#{permission.to_s}?"
    end
  end

  module ClassMethods
    def allow(*options, &block)
      @allows ||= Array.new
      @allows << options
    end

    def set_permissions
      # Permissions are calculated only once per class for performance considerations
      # This behaviour is overridden in development so permissions are always calculated
      if (!@permissions && @allows) || (defined?(RAILS_ENV) && RAILS_ENV == 'development')
        @permissions = Hash.new
        
        if @allows 
          @allows.each do |p|
            allowed = Hash.new
            hash = p.select{|o| o.is_a?(Hash)}
            
            allowed[:permissions] = p - hash

            actions = hash.first
            if hash.first
              allowed[:except] = actions[:except] 
              allowed[:only] = actions[:only]
            end

            if allowed[:only]                               # Only for the specified actions
              allowed_actions = Array(allowed[:only])
            elsif allowed[:except]                          # All available actions EXCEPT the ones specified
              allowed_actions = controller_actions - Array(allowed[:except])
            else                                            # All available actions
              allowed_actions = controller_actions
            end

            allowed_actions.each do |action|
              @permissions[action.to_sym] = (Array(@permissions[action.to_sym]) + allowed[:permissions]).uniq
            end
          end
        end
      end
    end

    def clear_permissions
      @permissions = nil
    end

    private

    def controller_actions
      (self.new.action_methods - ActionController::Base.new.action_methods).map {|am| am.to_sym} - [:check_permissions]
    end
  end
end