module AresMUSH
  module CoD
    class CodUpdateSettingsHandler

      def handle(request)
        presets = Global.read_config('cod', 'char_settings').with_indifferent_access
        enactor = request.enactor

        error = Website.check_login(request)
        return error if error

        new_settings = request.args.map { |key, subset|
          [key, subset.map { |k, v|
            if CoD.is_numeric? v
              [k, v.to_i]
            elsif ['true', 'false'].include? v
              [k, CoD.to_b(v)]
            else
              [k, v]
            end
          }.to_h]
        }.to_h

        enactor.update(cod_settings: enactor.cod_settings.merge(new_settings))
        enactor.cod_settings
      end

    end
  end
end
