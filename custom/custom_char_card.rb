module AresMUSH
  module Scenes

    def self.custom_char_card_fields(char, viewer)
      sheet = char.sheet.template_config
      sheet[:id] = char.id
      sheet[:name] = char.name
      [:template, :health, :agg_wounds, :lethal_wounds, :bashing_wounds].each do |f|
        sheet[f] = char.sheet.public_send(f)
      end

      {
        is_st: CoD.is_st?(char),
        sheet: sheet
      }
    end
  end
end
