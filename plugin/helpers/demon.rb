module AresMUSH
  module CoD

    def self.app_review_demon(cg_sheet)
      config = get_template_config('demon').with_indifferent_access
      errors = []
      check_template_fields(cg_sheet, config, errors)
      check_demon_embeds_and_exploits(cg_sheet, config, errors)
      check_demon_form_abilities(cg_sheet, config, errors)
      errors
    end

    def self.app_review_stigmata(cg_sheet)
      config = get_template_config('stigmata').with_indifferent_access
      errors = []
      check_template_fields(cg_sheet, config, errors)
      errors
    end

    def self.check_demon_embeds_and_exploits(cg_sheet, config, errors)
      embeds = cg_sheet.dig('embeds')
      return t('cod.must_have_at_least_one_embed') if embeds.nil?
      embed_names = embeds.map { |e| e['name'] }
      exploits = cg_sheet.dig('exploits') || []
      exploits.each { |e|
        if !embed_names.include? e['spec']
          errors << t('cod.no_correlating_embed_found', name: e['name'])
        end
      }
      errors << t('cod.must_have_at_least_one_embed') if embeds.size <= 0
    end

    def self.check_demon_form_abilities(cg_sheet, config, errors)
      abilities = cg_sheet['form_abilities'] || []
      config['form_abilities'].each { |k, v|
        count = cg_sheet&.dig('form_abilities')&.select { |f|
          next if !f['category']
          k.start_with? f['category'][0..5]&.downcase
        }.size
        errors << t('cod.must_have_x_of_y_z_found', size: v, name: k, curr: count) if count != v
      }
    end

  end
end
