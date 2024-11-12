module AresMUSH
  module CoD
    class CodSettingsHandler

      def handle(request)
        presets = Global.read_config('cod', 'char_settings').with_indifferent_access
        enactor = request.enactor

        error = Website.check_login(request)
        return error if error

        c_settings = enactor.cod_settings
        c_settings = c_settings.map { |cat, setting|
          [cat, presets[cat].merge(c_settings[cat])]
        }.to_h
        enactor.update(cod_settings: presets.except(:options).merge(c_settings))
        {
          char: enactor.id,
          settings: enactor.cod_settings,
          presets: presets
        }
      end

    end
  end
end
