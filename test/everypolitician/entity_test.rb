require 'test_helper'

class EverypoliticianTest < Minitest::Test

  def test_entity_has_a_name
    entity = Everypolitician::Entity.new({name: 'name'})
    assert_equal 'name', entity.name
  end

end
