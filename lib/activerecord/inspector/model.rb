require "set"

module ActiveRecord
  module Inspector
    class Model
      class AttributeSet < Set
        def to_s
          map do |sets|
            sets.map(&:to_s).join(', ')
          end.join('|')
        end
      end

      attr_reader :active_record_class

      def initialize(active_record_class)
        @active_record_class = active_record_class
      end

      def name
        @active_record_class.name
      end

      def table_name
        @active_record_class.table_name
      end

      def foreign_keys_covered_by_index
        foreign_keys.select {|key| first_columns_of_indexes.include?(key) }
      end

      def foreign_keys_not_covered_by_index
        foreign_keys.select {|key| !first_columns_of_indexes.include?(key) }
      end

      def unique_attributes_not_covered_by_index
        unique_attribute_sets - column_symbols_sets_of_unique_indexes
      end

      def unique_attributes_not_validated
        column_symbols_sets_of_unique_indexes - unique_attribute_sets
      end

      private
        # When +validates :provider_unique_id, :uniqueness => {:scope => [:type, :user_id]}+
        # this method returns +[[:provider_unique_id, :type, :user_id]]+
        def unique_attribute_sets
          @active_record_class._validators.each_with_object(AttributeSet.new) do |(attr, validators), set|

            uniqueness_validators = validators.select do |validator|
              validator.is_a? ActiveRecord::Validations::UniquenessValidator
            end

            next if uniqueness_validators.empty?

            uniqueness_validators.each do |validator|
              set << (validator.options[:scope] ? [attr] + Array(validator.options[:scope]) :  [attr]).to_set
            end
          end
        end

        def column_symbols_sets_of_unique_indexes
          AttributeSet.new(unique_indexes.map {|index| index.columns.map(&:to_sym).to_set })
        end

        def column_names
          @active_record_class.columns.map(&:name)
        rescue ActiveRecord::StatementInvalid => e
          p e.message
          []
        end

        def foreign_keys
          column_names.select {|column_name| column_name =~ /_id\Z/ }
        end

        def indexes
          @indexes ||= begin
            @active_record_class.connection.indexes(@active_record_class.table_name)
          rescue ActiveRecord::StatementInvalid => e
            p e.message
            []
          end
        end

        def unique_indexes
          @unique_indexes ||= begin
            @active_record_class.connection.indexes(@active_record_class.table_name).select(&:unique)
          rescue ActiveRecord::StatementInvalid => e
            p e.message
            []
          end
        end

        def first_columns_of_indexes
          indexes.map {|index| index.columns.first }.uniq
        end
    end
  end
end
