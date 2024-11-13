module AresMUSH
  module Chargen
    def self.custom_approval(char)
      starting_xp = Global.read_config('cod', 'starting_xp')
      if starting_xp && char.sheet.xp == 0
        CoD.award_xp(Game.master.system_character, char.sheet, starting_xp, msg = nil)
      end

      power = CoD.get_template_config(char.sheet.template)&.dig(:power, :name)
      return if !power

      char.sheet.merits.each { |m| m.delete if m.name == "#{power} Increase" }
    end
  end
end
