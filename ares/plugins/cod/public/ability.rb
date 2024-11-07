module AresMUSH
  class Ability < Ohm::Model
    include ObjectModel

    attribute :name
    attribute :type
    attribute :data, type: DataType::Hash, default: {}
    reference :sheet, "AresMUSH::Sheet"

    index :name
    index :type

    def spec
      data['spec']
    end

    def spec= val
      data = {} if !data
      data['spec'] = val
    end

    def rating
      data['rating']
    end

    def rating= val
      data = {} if !data
      data['rating'] = val
    end

    def to_h
      {
        name: name,
        type: type,
        data: data
      }
    end
  end
end
