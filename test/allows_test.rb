# -*- encoding : utf-8 -*-

require 'minitest/autorun'
require 'turn'
require 'allows'
require 'rubygems'
require 'action_pack'
require 'action_controller'

class AllowsTest < MiniTest::Unit::TestCase
  def test_simple_permissions  
    TestController.set_permissions
    
    assert TestController.permissions.count == 5

    assert TestController.permissions[:index].include? :admin
    refute TestController.permissions[:show].include? :gpd
    assert TestController.permissions[:index].include? :dds
  end

  def test_complex_permissions
    TestController.set_permissions

    assert TestController.permissions.count == 5

    assert TestController.permissions[:index].include? :a
    assert TestController.permissions[:create].include? :b
    assert TestController.permissions[:update].include? :c
    
    assert TestController.permissions[:create].include? :d
    refute TestController.permissions[:index].include? :d
    refute TestController.permissions[:new].include? :d
    refute TestController.permissions[:show].include? :d

    assert TestController.permissions[:create].include? :e
    refute TestController.permissions[:index].include? :f
  end

  def test_must_not_include_nonexistant_action
    TestController.set_permissions

    refute TestController.permissions[:showw]
    refute TestController.permissions[:accao_que_nao_existe]
  end

  def test_all_actions
    TestController.set_permissions

    assert TestController.permissions.count == 5

    assert TestController.permissions.keys.include? :index
    assert TestController.permissions.keys.include? :show
    assert TestController.permissions.keys.include? :update
    assert TestController.permissions.keys.include? :new
    assert TestController.permissions.keys.include? :create
  end

  def test_generate_unauthorized
    TestControllerNone.set_permissions

    assert_raises Unauthorized do
     TestControllerNone.new.check_permissions
    end
  end

  def test_allow_that_depends_on_instance_variable
    TestControllerComplex.set_permissions
    
    assert TestControllerComplex.permissions.count == 1

    tcc = TestControllerComplex.new
    tcc.instance_variable_set(:@requirement,RequirementStub.new)
    tcc.instance_variable_set(:@post,3)

    tcc.check_permissions
  end

end

class TestController < ActionController::Base
  include Allows

  allow :admin
  allow :gpd, :only => :index
  allow :dds, :except => :show

  allow :a, :b, :c
  allow :d, :only => :create
  allow :e, :f, :except => [:index, :update, :show]

  def index; end
  def show; end
  def update; end
  def new; end
  def create; end

  protected

  def action_name; :show; end
  def current_user; PermissionCheckerDeluxe.new; end
  
end

class PermissionCheckerDeluxe
  def admin?; true; end
  def gpd?; true; end
  def dds?; false; end
  def a?; false; end
  def b?; true; end
  def c?; false; end
  def d?; true; end
  def e?; false; end
  def f?; true; end
end

class TestControllerComplex < ActionController::Base
  include Allows

  allow :reader_of_requirement, :editor_of_post

  def show; end

  protected

  def action_name; :show; end
  def current_user; PermissionCheckerForRequirement.new; end
end

class PermissionCheckerForRequirement
  def reader?(requirement); requirement.message == 'testing'; end
  def editor?(post); post == 3; end
end

class RequirementStub
  def message; 'testing'; end
end

class TestControllerNone < ActionController::Base
  include Allows

  allow :admin

  def show; end

  protected

  def action_name; :show; end
  def current_user; PermissionCheckerNone.new; end
  
end

class PermissionCheckerNone
  def admin?; false; end
end
