require 'test_helper'

require 'active_record_doctor/tasks/missing_unique_indexes'

class ActiveRecordDoctor::Tasks::MissingUniqueIndexesTest < ActiveSupport::TestCase
  def test_missing_unique_index
    Temping.create(:users, temporary: false) do
      with_columns do |t|
        t.string :email
        t.index :email
      end

      validates :email, uniqueness: true
    end

    assert_result([
      ['users', [['email']]]
    ])
  end

  def test_present_unique_index
    Temping.create(:users, temporary: false) do
      with_columns do |t|
        t.string :email
        t.index :email, unique: true
      end

      validates :email, uniqueness: true
    end

    assert_result([])
  end

  def test_missing_unique_index_with_scope
    Temping.create(:users, temporary: false) do
      with_columns do |t|
        t.string :email
        t.integer :company_id
        t.integer :department_id
        t.index [:company_id, :department_id, :email]
      end

      validates :email, uniqueness: { scope: [:company_id, :department_id] }
    end

    assert_result([
      ['users', [['company_id', 'department_id', 'email']]]
    ])
  end

  def test_present_unique_index_with_scope
    Temping.create(:users, temporary: false) do
      with_columns do |t|
        t.string :email
        t.integer :company_id
        t.integer :department_id
        t.index [:company_id, :department_id, :email], unique: true
      end

      validates :email, uniqueness: { scope: [:company_id, :department_id] }
    end

    assert_result([])
  end

  def test_conditions_is_skipped
    assert_skipped(conditions: -> { where.not(email: nil) })
  end

  def test_case_insensitive_is_skipped
    assert_skipped(case_sensitive: false)
  end

  def test_if_is_skipped
    assert_skipped(if: ->(model) { true })
  end

  def test_unless_is_skipped
    assert_skipped(unless: ->(model) { true })
  end

  private

  def assert_skipped(options)
    Temping.create(:users, temporary: false) do
      with_columns do |t|
        t.string :email
      end

      validates :email, uniqueness: options
    end

    assert_result([])
  end
end
