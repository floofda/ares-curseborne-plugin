module AresMUSH
  class Modification < Ohm::Model
    include ObjectModel

    attribute :category
    attribute :stat
    attribute :action
    attribute :msg
    attribute :value
    attribute :previous
    attribute :applied, type: DataType::Boolean, default: false
    reference :sheet, "AresMUSH::Sheet"
    reference :enactor, "AresMUSH::Character"

    index :category
    index :stat
    index :applied

    def to_h
      {
        category: category,
        stat: stat,
        action: action,
        value: value,
        previous: previous,
        msg: msg,
        applied: applied,
        created_at: created_at,
        enactor: {
          id: enactor.id,
          name: enactor.name
        }
      }
    end
  end
end
