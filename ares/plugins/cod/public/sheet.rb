module AresMUSH
  class Sheet < Ohm::Model
    include ObjectModel

    attribute :name
    attribute :template
    attribute :concept
    attribute :power, type: DataType::Integer, default: 0
    attribute :xp, type: DataType::Float, default: 0.0
    attribute :size, type: DataType::Integer, default: 5
    attribute :speed, type: DataType::Integer, default: 5
    attribute :initiative, type: DataType::Integer, default: 0
    attribute :willpower, type: DataType::Integer, default: 0
    attribute :defense, type: DataType::Integer, default: 0
    attribute :morality, type: DataType::Integer, default: 0
    attribute :resource, type: DataType::Integer, default: 0
    attribute :health, type: DataType::Integer, default: 0
    attribute :agg_wounds, type: DataType::Integer, default: 0
    attribute :lethal_wounds, type: DataType::Integer, default: 0
    attribute :bashing_wounds, type: DataType::Integer, default: 0
    attribute :template_config, type: DataType::Hash, default: {}
    attribute :cg_sheet, type: DataType::Hash, default: {}
    attribute :freeform, type: DataType::Array, default: []

    attribute :curr_xp, type: DataType::Float, default: 0.0
    attribute :curr_wp, type: DataType::Integer, default: 0
    attribute :curr_resource, type: DataType::Integer, default: 0
    attribute :curr_morality, type: DataType::Integer, default: 0
    attribute :health_track, type: DataType::Array, default: []
    attribute :bonus_health

    reference :character, "AresMUSH::Character"
    collection :cod_attributes, "AresMUSH::Attribute"
    collection :skills, "AresMUSH::Skill"
    collection :abilities, "AresMUSH::Ability"
    collection :merits, "AresMUSH::Merit"
    collection :conditions, "AresMUSH::Condition"
    collection :tilts, "AresMUSH::Tilt"
    collection :modifications, "AresMUSH::Modification"

    index :name
    index :template

    before_delete :delete_dependents

    def delete_dependents
      [ self.cod_attributes, self.skills, self.abilities, self.merits, self.conditions, self.tilts, self.modifications ].each do |list|
        list.each do |d|
          d.delete
        end
      end
    end

    def abilities_by_type type = nil
      type ? self.abilities.select { |a| type == a.type } : self.abilities
    end

    def readable_stats
      [
        'name', 'template', 'concept', 'xp', 'size', 'power', 'resource',
        'speed', 'initiative', 'willpower', 'defense', 'health', 'morality',
        'curr_wp', 'curr_xp', 'curr_resource', 'curr_morality', 'agg_wounds',
        'lethal_wounds', 'bashing_wounds'
      ]
    end

    def to_h
      {
        id: id,
        template: template,
        concept: concept,
        power: power,
        xp: xp.round(1),
        curr_xp: curr_xp.round(1),
        size: size,
        speed: speed,
        initiative: initiative,
        willpower: willpower,
        curr_wp: curr_wp,
        defense: defense,
        morality: morality,
        resource: resource,
        curr_resource: curr_resource,
        health: health,
        agg_wounds: agg_wounds,
        lethal_wounds: lethal_wounds,
        bashing_wounds: bashing_wounds,
        template_config: template_config,
        character: {
          id: character.id,
          name: character.name
        },
        attributes: self.cod_attributes.map(&:to_h),
        skills: self.skills.map(&:to_h),
        abilities: self.abilities.map(&:to_h),
        merits: self.merits.map(&:to_h),
        conditions: self.conditions.map(&:to_h),
        tilts: self.tilts.map(&:to_h)
      }
    end
  end
end
