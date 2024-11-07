module AresMUSH
  class Combat < Ohm::Model
    include ObjectModel

    attribute :scene_id, type: DataType::Integer, default: 0
    attribute :conditions, type: DataType::Array, default: []
    attribute :tilts, type: DataType::Array, default: []
    attribute :cursor, type: DataType::Integer, default: 0
    attribute :init_list, type: DataType::Hash, default: {}
    attribute :owner_id, type: DataType::Integer, default: 0

    reference :scene, "AresMUSH::Scene"
    index :owner_id

    before_delete :delete_dependents

    def delete_dependents
      Npc.find(combat_id: self.id).each { |npc| npc.delete }
    end

    def ordered_init_list
      init_list.select { |k, v| v && v > 0 }.sort_by { |k, v| v }.reverse.map { |k, v| k }
    end

    def next_char
      ordered_init_list[cursor >= (ordered_init_list.size - 1) ? 0 : cursor + 1]
    end

    def prev_char
      ordered_init_list[cursor <= 0 ? -1 : cursor - 1]
    end

    def curr_char
      ordered_init_list[cursor]
    end

    def to_h
      {
        id: id,
        owner_id: owner_id,
        scene_id: scene.id,
        init_list: init_list.keys,
        ordered_init_list: ordered_init_list,
        curr: curr_char,
        next: next_char,
        prev: prev_char
      }
    end
  end
end
