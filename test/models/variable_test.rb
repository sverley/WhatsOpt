require 'test_helper'

class VariableTest < ActiveSupport::TestCase
  
  test "should have shape and type default attributes resp 1 and Float" do
    var = Variable.new(name: 'test', io_mode: Variable::IN)
    assert_equal Variable::DEFAULT_SHAPE, var.shape
    assert_equal Variable::DEFAULT_TYPE, var.type
    assert var.active
  end

  test "should be invalid if bad-formed shape" do
    var = Variable.new(name: 'test', io_mode: Variable::IN, shape:'shape')
    refute var.valid?
  end
  
  test "should be valid if well-formed shape and have the right dim" do
    var = Variable.new(name: 'test', io_mode: Variable::IN, shape:'3')
    assert !var.valid?
    var = Variable.new(name: 'test', io_mode: Variable::IN, shape:'1')
    assert var.valid?
    assert var.active
    assert_equal 1, var.dim
    var = Variable.new(name: 'test', io_mode: Variable::IN, shape:'(12,)')
    assert var.valid? 
    assert_equal 12, var.dim
    var = Variable.new(name: 'test', io_mode: Variable::IN, shape:'(5, 6)')
    assert var.valid?
    assert_equal 5*6, var.dim
    var = Variable.new(name: 'test', io_mode: Variable::IN, shape:'(5, 6, 7)')
    assert var.valid?
    assert_equal 5*6*7, var.dim
  end

  def test_should_have_a_valid_py_default_value_taking_into_account_type_and_shape
    var = variables(:var_scalar_float)
    assert_equal '1.0', var.default_py_value 
    var = variables(:var_scalar_int)
    assert_equal '1', var.default_py_value 
    var = variables(:var_array_float)
    assert_equal 'np.ones((3,))', var.default_py_value  
    var = variables(:var_nparray_float)
    assert_equal 'np.ones((3, 5))', var.default_py_value 
    var = variables(:var_string)
    assert_equal 'test_init_string', var.parameter.init
  end
  
  def test_as_json
    var = variables(:varx1_out)
    adapter = ActiveModelSerializers::SerializableResource.new(var)
    assert_equal [:active, :desc, :io_mode, :name, :parameter, :shape, :type, :units], adapter.as_json.keys.sort
    assert_equal({:init=>"3.14", :lower=>"1", :upper=>"10"}, adapter.as_json[:parameter])
  end
  
  test "may have several outgoings when output" do
    var = variables(:varz_design_out)
    assert_equal 2, var.outgoing_connections.count
  end
  
  test "should have one incoming when input" do
    var = variables(:varyg_aero_in)
    assert var.incoming_connection
  end
  
end
