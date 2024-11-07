module AresMUSH
  class Attribute < Ohm::Model
    include ObjectModel

    attribute :name
    attribute :category
    attribute :type
    attribute :rating, type: DataType::Integer, default: 1
    attribute :bonus, type: DataType::Integer, default: 0
    attribute :flat, type: DataType::Integer, default: 0
    reference :sheet, "AresMUSH::Sheet"

    index :name
    index :category
    index :type

    def total
      flat > 0 ? flat : rating + bonus
    end

    def to_h
      {
        name: name,
        category: category,
        type: type,
        rating: rating,
        flat: flat,
        bonus: bonus,
        total: total
      }
    end
  end
end