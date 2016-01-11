module ActiveRecord
  module Inspector
    class ModelInspector
      def initialize(models)
        @models = models
      end

      def format(formatter)
        formatter.header @models
        formatter.section @models
        formatter.result
      end
    end

    class Formatter
      def initialize
        @buffer = []
      end

      def result
        @buffer.join("\n")
      end

      def section(models)
        @buffer << draw_section(models)
      end

      def header(models)
        @buffer << draw_header(models)
      end

      def draw_section(models)
        header_lengths = ['Model_Name', 'Table_Name', 'Not_Covered_By_Index'].map(&:length)
        name_width, table_name_width, validation_width = widths(models).zip(header_lengths).map(&:max)

        models.map do |model|
          "#{model.name.rjust(name_width)} #{model.table_name.ljust(table_name_width)} #{model.unique_attributes_not_covered_by_index.to_s.ljust(validation_width)} #{model.unique_attributes_not_validated.to_s}"
        end
      end

      def draw_header(models)
        name_width, table_name_width, validation_width = widths(models)

        "#{"Model_Name".rjust(name_width)} #{"Table_Name".ljust(table_name_width)} #{"Not_Covered_By_Index".ljust(validation_width)} Not_Covered_By_Validation"
      end

      def widths(models)
        [models.map { |model| model.name.length }.max || 0,
         models.map { |model| model.table_name.length }.max || 0,
         models.map { |model| model.unique_attributes_not_covered_by_index.to_s.length }.max || 0]
      end

      def no_models(routes, filter)
        @buffer <<
        if routes.none?
          <<-MESSAGE.strip_heredoc
          You don't have any routes defined!

          Please add some routes in config/routes.rb.
          MESSAGE
        elsif missing_controller?(filter)
          "The controller #{filter} does not exist!"
        else
          "No routes were found for this controller"
        end
        @buffer << "For more information about routes, see the Rails guide: http://guides.rubyonrails.org/routing.html."
      end
    end
  end
end
