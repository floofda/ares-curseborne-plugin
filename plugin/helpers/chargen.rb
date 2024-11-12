module AresMUSH
  module CoD

    def self.build_web_chargen_info(char)
      info = BuildWebChargenInfo.new
      info.build(char)
    end

    def self.save_chargen(char, data)
      sheet = data[:custom][:cg_sheet]
      c_abilities = get_template_config(char.sheet.template)[:abilities]
      c_abilities = c_abilities ? c_abilities.map { |c| c['key'].to_sym } : []
      (c_abilities + [:attributes, :skills, :specialties, :merits, :fields]).each do |f|
        next if !sheet[f]
        sheet[f] = sheet[f].map do |k, v|
          v[:rating] = v[:rating].to_i if v[:rating]
          v[:has_spec] = v[:has_spec] == 'true' if v[:has_spec]
          v[:cost] = v[:cost].is_a?(Array) ? v[:cost].map(&:to_i) : v[:cost].to_i if v[:cost]
          v
        end
      end
      char.sheet.update(cg_sheet: sheet)
    end

    def self.app_review(char)
      sheet_errors = check_sheet(char)
      template_errors = check_template(char)
      {
        ok: sheet_errors.empty? && template_errors.empty?,
        sheet_errors: cg_error_msg(sheet_errors, 'cod.checking_sheet'),
        template_errors: cg_error_msg(template_errors, 'cod.checking_template_info')
      }
    end

    def self.cg_error_msg(errors, translation)
      out = Chargen.format_review_status(t(translation), !errors.empty? ? '' : t('chargen.ok'))
      if !errors.empty?
        out += '%r' + errors.map { |m| "%t%xh%xr#{m}%xn" }.join('%r')
      end
      out
    end

    def self.check_sheet(char)
      errors = []
      cg_sheet = char.sheet.cg_sheet
      errors << check_fields(cg_sheet)
      errors << check_points(cg_sheet, 'attr', 'attributes')
      errors << check_points(cg_sheet, 'skill', 'skills')
      errors << check_specialties(cg_sheet)
      errors << check_merits(cg_sheet, char.sheet.template)
      errors.flatten.compact
    end

    def self.check_template(char)
      errors = []
      cg_sheet = char.sheet.cg_sheet
      errors << check_classifications(cg_sheet, char.sheet.template)
      method = "app_review_#{to_key(char.sheet.template)}".to_sym
      errors << self.public_send(method, cg_sheet) if self.respond_to?(method)
      errors.flatten.compact
    end

    def self.check_fields(cg_sheet)
      errors = []
      errors << t('cod.missing_field', field: 'Concept') if cg_sheet['concept'].empty?
      if cg_sheet['anchors'].nil? || cg_sheet['anchors'][0].nil? || cg_sheet['anchors'][1].nil?
        errors << t('cod.missing_field', field: 'Anchor')
      end
      errors
    end

    def self.check_points(cg_sheet, type, label)
      config = Global.read_config('cod', 'chargen')
      errors = []
      cg_sheet[label].each { |a|
        if a['rating'] > config["max_#{type}"]
          errors << t("cod.#{type}_above_max", name: a['name'], max: config["max_#{type}"])
        end
        if a['rating'] < config["min_#{type}"]
          errors << t("cod.#{type}_below_min", name: a['name'], min: config["min_#{type}"])
        end
      }
      points = config["#{type}_category_points"].values
      diff = Set.new(points.map{ |a| a + (type == 'attr' ? 3 : 0) }) -
        Set.new(['mental', 'physical', 'social'].map{ |c|
          cg_sheet[label].reduce(0) { |a, b|
            a = a + b['rating'] if b['category'] == c
            a
          }
        })
      diff.empty? ? errors : errors << t("cod.#{type}_distribution_invalid", points: points.join(', '))
    end

    def self.check_specialties(cg_sheet)
      errors = []
      cg_sheet['specialties'].each { |s|
        return errors << t('cod.missing_specialties') if s['specialty'] == "" || s['skill'] == ""
      }
      errors
    end

    def self.check_merits(cg_sheet, template)
      errors = []
      return errors << t('cod.missing_merits') if cg_sheet['merits'].nil?
      spent = 0
      merits = CoD.merits(template)
      cg_sheet['merits'].each { |m|
        merit = merits.find { |c_merit| c_merit['name'] == m['name'] }
        return errors << t('cod.invalid_merit', name: m['name']) if merit.nil?

        costs = merit['cost'].is_a?(Array) ? merit['cost'] : [merit['cost']]
        return errors << t('cod.invalid_merit_cost', nme: m['name']) if !costs.include?(m['rating'])

        spent += m['rating']
        errors << t('cod.merit_needs_more_info', name: m['name']) if CoD.to_b(m['has_spec']) && m['spec'].empty?
      }
      expected = get_template_config(template)['merits']
      errors << t('cod.merit_points_incorrect', spent: spent, expected: expected) if spent != expected
      errors
    end

    def self.check_classifications(cg_sheet, template)
      errors = []
      config = get_template_config(template)
      return errors if !config.has_key?('classifications')
      config['classifications']&.each { |k, v|
        entry = cg_sheet.dig('classifications', k)
        errors << t('cod.missing_classification', type: v) if entry.nil?

        if entry && !config[v.downcase].map { |c| c['name'] }.include?(entry)
          errors << t('cod.invalid_classification', type: v, name: entry)
        end
      }
      errors
    end

    def self.check_template_fields(cg_sheet, config, errors)
      config['fields']&.each { |f|
        field = get_cg_field(cg_sheet, f['name'])
        if field.nil?
          errors << t('cod.missing_field', field: f['name'])
          next
        end

        if !f['values'].map { |v| v['name'] }.include?(field['name'])
          errors << t('cod.invalid_field', name: field['name'])
        end
      }
    end

    def self.get_cg_field(cg_sheet, field)
      cg_sheet['fields']&.select { |f| f['field'] == field }&.first
    end

    def self.cg_mods(sheet, stat)
      return if stat.nil?
      c_stat = get_config_stat(sheet.template, stat)
      if c_stat['modifiers']&.any?
        modifiers = c_stat['modifiers']&.each { |m|
          create_modification(Game.master.system_character, sheet, m.downcase, 'CharGen')
        }
      end
    end

    def self.cg_to_sheet(char)
      sheet = char.sheet
      cg_sheet = sheet.cg_sheet
      sheet.delete_dependents
      sheet.readable_stats.each { |s| sheet.public_send("#{s}=", 0) }
      sheet.update(
        size: 5,
        speed: 5,
        template: cg_sheet['template'],
        concept: cg_sheet['concept'],
        template_config: create_template_config(char)
      )

      sheet = Sheet[sheet.id]
      cg_sheet['attributes'].each { |a| set_attribute(sheet, a, true) }
      cg_sheet['skills'].each { |s| set_skill(sheet, s, true) }
      sheet.template_config['abilities']&.each { |type|
        cg_abilities = cg_sheet[type['key']] || []
        cg_abilities.each { |a| set_ability(sheet, a, type) }
      }

      cg_sheet['merits'].each { |m|
        merit = "#{m['name']}#{m['has_spec'] ? ".#{m['spec']}" : ''}"
        set_stat(sheet, 'Merit', merit, m['rating'], true)
      }
      cg_sheet['specialties'].each { |s| set_specialty(sheet, s['skill'], s['specialty']) }

      config = get_template_config(sheet.template)
      sheet = Sheet[sheet.id]
      set_species_stats(sheet)
      [config, sheet.template_config['classifications'], sheet.template_config['fields']].flatten.compact.each { |c|
        c['modifiers']&.each { |m| create_modification(Game.master.system_character, sheet, m, 'CharGen') }
      }
      build_derived_stats(sheet)
      run_modifications(Sheet[sheet.id])
      build_derived_stats(sheet)
      set_resource_stats(sheet)

      if config['secondary_desc'] && sheet.template_config['secondary_desc']
        profile = char.profile
        profile[config['secondary_desc']] = sheet.template_config['secondary_desc']
        char.set_profile(profile, char)
      end
    end

    def self.create_template_config(char)
      cg_sheet = char.sheet.cg_sheet
      config = get_template_config(cg_sheet['template'])

      template_config = {
        power: config['power'] ? config.dig('power', 'name') : nil,
        resource: config['resource'],
        morality: config['morality'],
        secondary_desc: cg_sheet['secondary_desc'],
        abilities: config['abilities'],
        anchors: config['anchors'].map.with_index { |a, i| ({ name: a['name'], value: cg_sheet['anchors'][i]}) }
      }


      if config['classifications']
        classifications = ['primary', 'secondary', 'tertiary']
        template_config['classifications'] = config['classifications'].values.map.with_index { |c, i|
            value = cg_sheet['classifications'][classifications[i]]
            item = config[c.downcase].select { |m| m['name'] == value }.first
            ({ name: c, value: value, modifiers: item&.dig('modifiers') || [] })
          }
      end

      if config['fields']
        template_config['fields'] = config['fields'].map.with_index { |f, i|
          value = cg_sheet['fields'].map{ |f| f['name'] }[i]
          v = f['values'].select { |v| v['name'] == value }.first
          ({ name: f['name'], value: value, modifiers: v&.dig('modifiers') || [] })
        }
      end
      template_config
    end

  end
end
