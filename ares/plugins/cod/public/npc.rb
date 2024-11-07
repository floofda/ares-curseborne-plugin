module AresMUSH
  class Npc < Ohm::Model
    include ObjectModel

    attribute :name
    attribute :icon
    attribute :s_sheet
    attribute :combat_id
    attribute :uuid
    attribute :creator_id

    index :uuid
    index :name
    index :combat_id

    def self.named name
      self.find(name: name).first
    end

    def sheet= sheet
      sheet[:is_npc] = true
      sheet[:npc_id] = id
      self.s_sheet = JSON(sheet)
    end

    def is_approved?
      true
    end

    def profile_icon
      icon
    end

    def sheet
      JSON.parse(self.s_sheet || '{}', symbolize_names: true).with_indifferent_access
    end

    def to_h
      {
        name: name,
        id: id,
        combat_id: combat_id,
        profile_icon: icon,
        sheet: sheet
      }
    end

  end
end
