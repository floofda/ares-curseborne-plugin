module AresMUSH
  class Skill < Ohm::Model
    include ObjectModel

    attribute :name
    attribute :category
    attribute :rating, type: DataType::Integer, default: 0
    attribute :bonus, type: DataType::Integer, default: 0
    attribute :specialties, type: DataType::Array, default: []
    reference :sheet, "AresMUSH::Sheet"

    index :name
    index :category

    def total
      self.rating + self.bonus
    end

    def to_h
      {
        name: name,
        category: category,
        specialties: specialties,
        rating: rating,
        bonus: bonus
      }
    end
  end
end
