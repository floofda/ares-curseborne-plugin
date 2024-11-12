module AresMUSH
  module CoD
    class CombatTemplate < ErbTemplateRenderer

      attr_accessor :char, :client, :section, :combat

      def initialize(combat, char, client, section = nil)
        @combat = combat
        @char = char
        @client = client
        @section = section
        super File.dirname(__FILE__) + '/combat.erb'
      end

      def wounds char
        wounds = CoD.wound_boxes char.sheet
      end

      def highlight name
        name == @combat&.curr_char ? "%xc%xh*%xn%xh #{name}%xn" : name
      end

      def is_combatant? char
        !CoD.is_combatant?(@combat, char)
      end

      def combatants
        @combat.nil? || is_combatant?(@char) ? [@char] : CoD.get_combatants(@combat)
      end

      def base char
        sheet = char.sheet
        power = []
        fields = [
          { name: 'Defense', value: CoD.get_rating(sheet, :defense) },
          { name: 'Initiative', value: CoD.get_rating(sheet, :initiative) },
          { name: 'Speed', value: CoD.get_rating(sheet, :speed) },
          { name: 'Willpower', value: "#{CoD.get_rating(sheet, :curr_wp)}/#{CoD.get_rating(sheet, :willpower)}" }
        ]

        if (CoD.is_npc?(sheet) ? sheet[:resource_name] : sheet.template_config['power'])
          power << {
            name: CoD.is_npc?(sheet) ? sheet[:resource_name] : sheet.template_config['resource'],
            value: "#{CoD.get_rating(sheet, :curr_resource)}/#{CoD.get_rating(sheet, :resource)}"
          }
        end
        fields = (fields + power).compact
        fields.each_with_index.map { |f, i|
          linebreak = (i % 3) == 2 ? '%r' : ''
          "#{linebreak} #{left(f[:name], 10)}#{right(f[:value], 14)} "
        }
      end

      def section_line(left, right = nil)
        @client.screen_reader ? left : CoD.header_line(left, right)
      end

      def footer_line(left = nil)
        @client.screen_reader ? left : CoD.footer_line(left)
      end

    end
  end
end
