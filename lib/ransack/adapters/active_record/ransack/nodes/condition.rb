module Ransack
  module Nodes
    class Condition

      def arel_predicate
        arel_predicate_for(attributes_array)
      end

      private

        def attributes_array
          attributes.map do |a|
            a.attr.send(
              arel_predicate_for_attribute(a), formatted_values_for_attribute(a)
            )
          end
        end

        def arel_predicate_for(predicates)
          if predicates.size > 1
            combinator_for(predicates)
          else
            format_predicate(predicates.first)
          end
        end

        def combinator_for(predicates)
          if combinator === Constants::AND
            Arel::Nodes::Grouping.new(Arel::Nodes::And.new(predicates))
          elsif combinator === Constants::OR
            predicates.inject(&:or)
          end
        end

        def format_predicate(predicate)
          predicate.tap do
            if casted_array_with_in_predicate?(predicate)
              predicate.right[0] = predicate.right[0].val.map { |v| format(v) }
            end
          end
        end

        def casted_array_with_in_predicate?(predicate)
          return unless defined?(Arel::Nodes::Casted)
          predicate.class == Arel::Nodes::In &&
          predicate.right[0].respond_to?(:val) &&
          predicate.right[0].val.is_a?(Array)
        end

        # Necessary for Arel >= 6.0 (Rails >= 4.2)
        def format(value)
          if value.is_a?(String)
            Arel::Nodes.build_quoted(value)
          else
            value
          end
        end

    end
  end
end
