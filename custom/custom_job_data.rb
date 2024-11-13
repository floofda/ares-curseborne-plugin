module AresMUSH
  module Jobs
    def self.custom_job_menu_fields(job, viewer)
      sheet = viewer.sheet.template_config
      sheet[:id] = viewer.id
      sheet[:name] = viewer.name
      [:template, :health, :agg_wounds, :lethal_wounds, :bashing_wounds].each do |f|
        sheet[f] = viewer.sheet.public_send(f)
      end

      {
        is_st: CoD.is_st?(viewer),
        char: sheet,
        config: Global.read_config('cod', 'client'),
        settings: viewer.cod_settings
      }
    end
  end
end
