module LeapCli; module Util

  class ConsoleTable
    def table
      @rows = []
      @cell_options = []

      @row_options = []
      @column_widths = []
      @column_options = []

      @current_row = 0
      @current_column = 0
      yield
    end

    def row(options=nil)
      @current_column = 0
      @rows[@current_row] = []
      @cell_options[@current_row] = []
      @row_options[@current_row] ||= options
      yield
      @current_row += 1
    end

    def column(str, options={})
      str ||= ""
      @rows[@current_row][@current_column] = str
      @cell_options[@current_row][@current_column] = options
      @column_widths[@current_column] = [str.length, options[:min_width]||0, @column_widths[@current_column]||0].max
      @column_options[@current_column] ||= options
      @current_column += 1
    end

    def draw_table
      @rows.each_with_index do |row, i|
        color = (@row_options[i]||{})[:color]
        row.each_with_index do |column, j|
          align = (@column_options[j]||{})[:align] || "left"
          width = @column_widths[j]
          cell_color = @cell_options[i][j] && @cell_options[i][j][:color]
          cell_color ||= color
          if cell_color
            str = LeapCli.logger.colorize(column, cell_color)
            extra_width = str.length - column.length
          else
            str = column
            extra_width = 0
          end
          if align == "right"
            printf "  %#{width+extra_width}s" % str
          else
            printf "  %-#{width+extra_width}s" % str
          end
        end
        puts
      end
      puts
    end
  end

end; end