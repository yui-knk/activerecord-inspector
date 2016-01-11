require 'test_helper'

class ActiveRecord::InspectorTest < Minitest::Test
  def test_models_with_mismatched_index_and_validation
    actual = ActiveRecord::Inspector.models_with_mismatched_index_and_validation.map(&:active_record_class).sort_by(&:name)
    assert_equal [Blog, Comment, Post, User], actual
  end

  def test_format
    actual = ActiveRecord::Inspector.format
    assert_equal <<-EXPECTED.strip, actual
Model_Name Table_Name Not_Covered_By_Index  Not_Covered_By_Validation
      User users      email                 
      Blog blogs                            title
      Post posts      title, category | tag title
   Comment comments   category              tag | body, category
    EXPECTED
  end
end
