module AresMUSH
  class Merit < Ohm::Model
    include ObjectModel

    attribute :name
    attribute :category
    attribute :rating, type: DataType::Integer, default: 0
    attribute :spec
    attribute :has_spec, type: DataType::Boolean, default: false
    reference :sheet, "AresMUSH::Sheet"

    index :name
    index :category
    index :spec

    def to_h
      {
        name: name,
        category: category,
        rating: rating,
        has_spec: has_spec,
        spec: spec
      }
    end
  end
end
