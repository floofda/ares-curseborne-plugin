module AresMUSH
  class Tilt < Ohm::Model
    include ObjectModel

    attribute :name
    attribute :type
    reference :sheet, "AresMUSH::Sheet"

    index :name
    index :type

    def to_h
      {
        name: name,
        type: type
      }
    end
  end
end