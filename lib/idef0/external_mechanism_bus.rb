require_relative 'point'
require_relative 'labels'

module IDEF0
  class ExternalMechanismBus
    attr_reader :name, :lines

    def initialize(lines)
      @lines = lines.map { |line| line }
      @name = @lines.first.name
    end

    def trunk_x
      @lines.map(&:x1).min
    end

    def baseline
      @lines.map(&:y1).max
    end

    def bus_y
      [@lines.map(&:y2).max + 20, baseline - 20].min
    end

    def label
      CentredLabel.new(@name, Point.new(trunk_x, baseline - 5))
    end

    def to_svg
      segments = [svg_line(trunk_x, baseline - 20, trunk_x, bus_y)]
      @lines.map(&:x1).uniq.each do |x|
        segments << svg_line(trunk_x, bus_y, x, bus_y)
      end
      @lines.each do |line|
        segments << svg_line(line.x1, bus_y, line.x1, line.y2)
        segments << svg_up_arrow(line.x1, line.y2)
      end
      segments.join("\n")
    end

    def label_to_svg
      "#{label.to_svg_background}\n#{label.to_svg}"
    end

    private

    def svg_line(x1, y1, x2, y2)
      "<line x1='#{x1}' y1='#{y1}' x2='#{x2}' y2='#{y2}' stroke='black' />"
    end

    def svg_up_arrow(x, y)
      "<polygon fill='black' stroke='black' points='#{x},#{y} #{x-3},#{y+6} #{x+3},#{y+6} #{x},#{y}' />"
    end
  end
end
