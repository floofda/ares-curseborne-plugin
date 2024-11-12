module AresMUSH
  class Character
    attribute :s_settings
    reference :sheet, "AresMUSH::Sheet"

    def cod_settings= settings
      self.s_settings = JSON(settings || '{}')
    end

    def cod_settings
      JSON.parse(self.s_settings || '{}', symbolize_names: true).with_indifferent_access
    end

  end
end
