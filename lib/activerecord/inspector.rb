require "active_record"
require "activerecord/inspector/model"
require "activerecord/inspector/model_inspector"
require "activerecord/inspector/version"

module ActiveRecord
  module Inspector
    class << self
      def eager_load_models!(load_paths)
        eager_load_paths = Array(load_paths) # [File.join(Rails.root, 'app', 'models')]
        eager_load_paths.each do |load_path|
          matcher = /\A#{Regexp.escape(load_path.to_s)}\/(.*)\.rb\Z/
          Dir.glob("#{load_path}/**/*.rb").sort.each do |file|
            require_dependency file.sub(matcher, '\1')
          end
        end
      end

      def models_with_mismatched_index_and_validation
        models.select do |model|
          !model.unique_attributes_not_covered_by_index.empty? || !model.unique_attributes_not_validated.empty?
        end
      end

      def format
        inspector = ActiveRecord::Inspector::ModelInspector.new(models_with_mismatched_index_and_validation)
        inspector.format(ActiveRecord::Inspector::Formatter.new)
      end

      # def indexes_over_validations_models
      #   models.select do |model|
      #     !model.unique_attributes_not_validated.empty?
      #   end
      # end

      # def dangerous_uniqueness_attributes_list
      #   models.select do |model|
      #     !model.unique_attributes_not_covered_by_index.empty? || !model.unique_attributes_not_validated.empty?
      #   end.map do |model|
      #     {
      #       model_name: model.name,
      #       table_name: model.table_name,
      #       dangerous: model.unique_attributes_not_covered_by_index,
      #       unique_attribute_sets: model.unique_attribute_sets, 
      #       unique_indexes: model.send(:unique_indexes)
      #     }
      #   end
      # end

      # def dangerous_foreign_key_list
      #   models.select do |model|
      #     !model.foreign_keys_not_covered_by_index.empty?
      #   end.map do |model|
      #     [model.name, model.foreign_keys_not_covered_by_index]
      #   end
      # end

      def models
        ActiveRecord::Base.descendants.reject(&:abstract_class?).map {|c| Model.new(c) }
      end
    end
  end
end
