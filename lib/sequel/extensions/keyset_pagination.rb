# frozen_string_literal: true

require "sequel"

module Sequel
  module KeysetPagination
    module Utils
      def self.qualify_order(expression)
        case expression
        when Sequel::SQL::OrderedExpression
          expression
        else
          Sequel::SQL::OrderedExpression.new(expression, false)
        end
      end

      def self.cursor_conditions(columns, cursor2, reverse: false)
        zipped = columns.zip(cursor2)
        desc = reverse ? :> : :<
        asc = reverse ? :< : :>

        # Reduce the dimensions
        segments = zipped.each_with_index.reverse_each.reduce([]) do |acc, ((column, cursor), idx)|
          # We always start of with the leaf
          segment = [Sequel[column.expression].send(column.descending ? desc : asc, cursor)]

          # Scope the leaf to its higher level dimensions
          zipped.slice(0, idx).each do |(col, cur)|
            segment << Sequel[col.expression].send(:=~, cur)
          end

          acc << Sequel.&(*segment)
        end
        Sequel.|(*segments)
      end
    end

    def seek(before: nil, after: nil)
      raise ArgumentError, "`before` or `after` is required" unless before || after

      if opts[:order].nil?
        raise StandardError, "cannot call #seek on a dataset with no order"
      end

      cursor_size = opts[:order].count

      if before
        before = [before] unless before.is_a? Array
        raise StandardError, "The `before` cursor has the wrong number of values. Expected #{cursor_size}, received #{before.count}." unless before.count == cursor_size
      end

      if after
        after = [after] unless after.is_a? Array
        raise StandardError, "The `after` cursor has the wrong number of values. Expected #{cursor_size}, received #{after.count}." unless after.count == cursor_size
      end

      columns = opts[:order].map { |o| Utils.qualify_order(o) }
      conditions = []

      if after
        conditions << Utils.cursor_conditions(columns, after)
      end

      if before
        conditions << Utils.cursor_conditions(columns, before, reverse: true)
      end

      where(Sequel.&(*conditions))
    end
  end

  Dataset.register_extension(:keyset_pagination, KeysetPagination)
end
