require 'test_helper'

class EverypoliticianTest < Minitest::Test

  def test_entity_has_a_name
    entity = Everypolitician::Entity.new({name: 'name'})
    assert_equal 'name', entity.name
  end

  def test_entity_uses_name_when_interpolated
    entity = Everypolitician::Entity.new({name: 'name'})
    assert_equal 'Fetching data for name', "Fetching data for #{entity}"
  end

end
