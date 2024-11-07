module AresMUSH
  class Condition < Ohm::Model
    include ObjectModel

    attribute :name
    attribute :type
    attribute :persistent, type: DataType::Boolean, default: false
    reference :sheet, "AresMUSH::Sheet"

    index :name
    index :type

    def to_h
      {
        name: name,
        type: type,
        persistent: persistent
      }
    end
  end
end
