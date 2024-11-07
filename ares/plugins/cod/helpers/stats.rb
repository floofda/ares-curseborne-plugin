module AresMUSH
  module CoD

    def self.set_attribute(sheet, attr, set = false)
      attr = attr.with_indifferent_access
      s_attr = sheet.cod_attributes.find(name: attr[:name]).first
      if !s_attr
        s_attr = Attribute.create(name: attr[:name], category: attr[:category], type: attr[:type], sheet: sheet)
      end
      s_attr.update(
        rating: set ? attr[:rating] : s_attr.rating + attr[:rating],
        bonus: attr[:bonus] || s_attr.bonus,
        flat: attr[:flat] || s_attr.flat
      )
    end

    def self.set_skill(sheet, skill, set = false)
      skill = skill.with_indifferent_access
      s_skill = sheet.skills.find(name: skill[:name]).first
      if !s_skill
        s_skill = Skill.create(name: skill[:name], category: skill[:category], sheet: sheet)
      end
      s_skill.update(rating: set ? skill[:rating] : s_skill.rating + skill[:rating])
    end

    def self.set_merit(sheet, merit, set = false)
      merit = merit.with_indifferent_access
      return if merit[:has_spec] && merit[:spec].nil?
      s_merit = get_sheet_merit(sheet, "#{merit[:name]}.#{merit[:spec]}")

      if s_merit && (merit[:rating] == 0 || s_merit.rating + merit[:rating] <= 0)
          s_merit.delete
          return
      end

      s_merit = nil if merit[:multi]
      if !s_merit
        s_merit = Merit.create(name: merit[:name], sheet: sheet, has_spec: merit[:has_spec])
      end
      new_rating = set ? merit[:rating] : s_merit.rating + merit[:rating]
      s_merit.update(rating: new_rating, category: merit[:category], spec: merit[:spec])

      merit[:modifiers]&.each { |m|
        create_modification(Game.master.system_character, sheet, m, 'Merit Modifier')
      }
    end

    def self.get_sheet_ability(sheet, name, type)
      primary, secondary = parse_stat name
      if type.is_a? String
        type = get_template_config(sheet.template)[:abilities].select { |t| t['name'] == type }.first
      end
      s_list = sheet.abilities_by_type(type&.dig('name')).select { |a| a.name.downcase.start_with? primary.downcase }
      type&.dig('spec_required') ? s_list.select { |a| a.spec.downcase == secondary&.downcase }.first : s_list.first
    end

    def self.set_ability(sheet, ability, type)
      ability = ability.with_indifferent_access

      if type['spec_required']
        return if ability[:spec]&.empty?
        s_ability = get_sheet_ability(sheet, "#{ability[:name]}.#{ability[:spec]}", type['name'])
      else
        s_ability = get_sheet_ability(sheet, ability[:name], type['name'])
      end

      if !type['has_rating']
        if s_ability && ability[:rating] == 0
          s_ability.delete
          return
        end
        ability.delete(:rating)
      end

      s_ability = nil if type['multi']
      if !s_ability
        s_ability = Ability.create(sheet: sheet, name: ability[:name], type: type['name'])
      end
      s_ability.update(data: ability)

      ability[:modifiers]&.each { |a|
        create_modification(Game.master.system_character, sheet, m, "#{type['name']} Modifier")
      }
    end

    def self.has_field_stat(sheet, stat)
      return true if sheet.respond_to? stat.downcase
      config = sheet.template_config
      ['anchors', 'classifications', 'fields'].each { |s|
        return true if config[s].select { |f| f['name'].downcase&.start_with?(stat.downcase) }.first
      }
      sheet.freeform&.values&.each { |values|
        return true if values.select { |f| f['name'].downcase.start_with?(stat.downcase) }.first
      }
      false
    end

    def self.set_field(sheet, stat, value, set = true)
      return set_npc_stat(sheet, stat, value, set) if is_npc? sheet
      sheet = Sheet[sheet.id]
      config = sheet.template_config
      ['power', 'resource', 'morality'].each { |f|
        stat = f if config[f]&.downcase&.start_with?(stat.downcase)
      }
      stat = stat&.downcase
      if sheet.readable_stats.include? stat
        new_value = set ? value : value + get_field(sheet, stat)
        sheet.update(stat => new_value)
      else
        config = sheet.template_config
        ['anchors', 'classifications', 'fields'].each do |s|
          config[s]&.each_with_index { |f, i|
            if f['name'].downcase.start_with?(stat)
              config[s][i]['value'] = value.is_a?(String) ? value.strip : value
            end
          }
        end
        sheet.update(template_config: config)
      end
    end

    def self.get_skill_specialty(skill, specialty)
      skill.specialties.select { |s| s.downcase.start_with? specialty.downcase }.first
    end

    def self.set_specialty(sheet, s_name, specialty, value = nil, set = true)
      sheet = Sheet[sheet.id]
      skill = sheet.skills.find(name: s_name).first
      specialties = skill.specialties
      skill.update(specialties: value == 0 ? specialties - [specialty.strip] : specialties | [specialty.strip])
    end

    def self.build_derived_stats(sheet, replay = false)
      sheet = Sheet[sheet.id]
      run_modifications(sheet, ['size'], replay)
      set_derived_stats(sheet)
      run_modifications(sheet, ['initiative', 'speed'], replay)
    end

    def self.set_resource_stats(sheet)
      config = get_template_config(sheet.template)
      set_field(sheet, 'curr_morality', get_rating(sheet, 'morality'))
      set_field(sheet, 'curr_wp', get_rating(sheet, 'willpower'))
      set_field(sheet, 'curr_resource', get_rating(sheet, 'resource')) if (config['power'])
    end

    def self.set_species_stats(sheet)
      base = Global.read_config('cod', 'species', 'human')
      config = get_template_config(sheet.template)
      min = config.dig('power', 'min')
      sheet.update(size: base['size'], speed: base['speed'], power: min || 0)
      set_field(sheet, 'morality', config['start_morality'] || get_rating(sheet, 'wits') + get_rating(sheet, 'composure'))
      set_field(sheet, 'willpower', get_rating(sheet, 'composure') + get_rating(sheet, 'resolve'))
    end

    def self.set_derived_stats(sheet)
      base = Global.read_config('cod', 'species', 'human')
      sheet = Sheet[sheet.id]
      config = get_template_config(sheet.template)
      set_field(sheet, 'health', get_rating(sheet, 'size') + get_rating(sheet, 'stamina'))
      set_field(sheet, 'speed', base['speed'] + get_rating(sheet, 'strength') + get_rating(sheet, 'dexterity'))
      set_field(sheet, 'initiative', get_rating(sheet, 'composure') + get_rating(sheet, 'dexterity'))
      set_field(sheet, 'defense',
        [get_rating(sheet, 'wits'), get_rating(sheet, 'dexterity')].min + get_rating(sheet, 'athletics')
      )
      set_field(sheet, 'resource', config['resource_pool'][get_rating(sheet, 'power')]) if (config['power'])
    end

    def self.set_stat(sheet, category, stat, value, set = false)
      return set_npc_stat(sheet, stat, value) if is_npc? sheet
      primary, secondary = parse_stat(stat)
      category = category.downcase

      case category
      when 'attribute'
        attribute = get_stat_from_config(attributes, primary)
        attribute['rating'] = value
        set_attribute(sheet, attribute, set)
      when 'skill'
        skill = get_stat_from_config(skills, primary)
        skill['rating'] = value
        set_skill(sheet, skill, set)
      when 'field'
        set_field(sheet, primary, value, set)
      when 'merit'
        merit = get_stat_from_config(merits(sheet.template), primary)
        if merit
          merit['spec'] = secondary if secondary && merit['has_spec']
          merit['rating'] = value
          set_merit(sheet, merit, set)
        end
      when 'specialty'
        set_specialty(sheet, primary, secondary, value, set)
      else
        match = /(?<type>[\w ]+)(?=ability$)/.match(category)
        return if !match && category != 'ability'

        if match
          type = get_ability_type(sheet.template, match[:type])
          ability = abilities(sheet.template, type['config']).select { |a| a['name'].start_with?(primary) }.first
        else
          ability, type = get_ability_with_type(sheet.template, primary)
        end
        if ability
          ability['spec'] = secondary if secondary && type['spec_required']
          ability['rating'] = value if type['has_rating'] || value == 0
          set_ability(sheet, ability, type)
        end
      end
    end

    def self.get_sheet_skill(sheet, stat, roll = nil)
      primary, secondary = parse_stat(stat)
      primary = primary.downcase
      skill = sheet.skills.find(name: get_from_list(skill_names, primary)).first
      if skill
        spec = get_skill_specialty(skill, secondary) if !secondary.nil?
        if spec
          skill.name = "#{skill.name}.#{spec}"
        end
      end
      skill
    end

    def self.get_sheet_merit(sheet, stat)
      name, spec = parse_stat(stat)
      c_merit = get_stat_from_config(merits(sheet.template), name)
      if c_merit
        if c_merit['has_spec']
          merit = sheet.merits.find(name: c_merit['name']).select { |m| spec && m.spec&.casecmp?(spec) }.first
        else
          merit = sheet.merits.find(name: c_merit['name']).first
        end
      end
      merit
    end

    def self.get_stat_with_category(sheet, stat, category = nil, type = nil)
      return nil if stat.nil?
      return [get_npc_stat(sheet, stat)] if is_npc? sheet

      primary, secondary = parse_stat(stat)
      primary = primary&.downcase
      category = category&.downcase

      if category.nil? || category == 'attribute'
        attr = sheet.cod_attributes.find(name: get_from_list(attr_names, primary)).first
        return attr, :attribute if attr
      end

      if category.nil? || category == 'skill'
        skill = get_sheet_skill(sheet, stat)
        return skill, :skill if skill
      end

      if category.nil? || category == 'field'
        field = get_from_list(sheet.readable_stats, primary)
        return { name: field.capitalize, value: sheet.public_send(field) }, :field if field
        field = get_field_stat(sheet, primary, secondary)
        return field, :field if field
      end

      if category.nil? || category == 'merit'
        merit = get_sheet_merit(sheet, stat)
        return merit, :merit if merit
      end

      if category.nil? || (category || '').end_with?('ability')
        type = /(?<type>\w+)(?=ability)/.match category if !type
        ability = get_sheet_ability(sheet, stat, type)
        type = ability&.type if !type
        return ability, type.to_sym if ability
      end
    end

    def self.get_stat(sheet, stat, category = nil, type = nil)
      get_stat_with_category(sheet, stat, category, type)&.first
    end

    def self.get_stat_category(sheet, stat)
      return nil if stat.nil?
      primary, secondary = parse_stat(stat)
      primary = primary.downcase
      return 'Attribute' if get_from_list(attr_names, primary)
      return 'Skill' if get_from_list(skill_names, primary)
      return 'Field' if get_from_list(sheet.readable_stats, primary)
      return 'Field' if get_field_stat(sheet, primary, secondary)
      return 'Merit' if get_from_list(merit_names(sheet.template), primary)
      return 'Ability' if get_from_list(abilities(sheet.template)&.map { |a| a['name']}, primary)
    end

    def self.get_field_stat(sheet, primary, secondary = nil)
      primary = primary.downcase
      config = sheet.template_config
      ['power', 'resource', 'morality'].each { |f|
        return { name: config[f], value: sheet.public_send(f) } if config[f]&.downcase&.start_with?(primary)
      }
      ['anchors', 'classifications', 'fields'].each { |s|
        field = config[s]&.select { |f|
          f['name']&.downcase&.start_with?(primary)
        }&.first
        return field if !field.nil?
      }
      nil
    end

    def self.get_field(stat, field)
      field = field.is_a?(Symbol) ? field : field.to_sym
      return stat.with_indifferent_access[field] if stat.is_a? Hash
      return stat.public_send(field) if stat.respond_to? field
    end

    def self.get_rating(sheet, stat_name, base = nil)
      return get_npc_rating(sheet, stat_name) if is_npc? sheet
      sheet = Sheet[sheet.id]
      stat = get_stat(sheet, stat_name.to_s)
      rating = nil
      rating = stat.rating if stat.respond_to?(:rating)
      rating = stat.total if !rating && stat.respond_to?(:total)
      rating = get_field(stat, :value) if !rating
      rating
    end

    def self.get_stat_from_config(list, stat, field = 'name')
      list.select { |i| i[field].downcase.start_with?(stat.downcase) }.first
    end

    def self.parse_stat(str)
      primary, secondary = str.split(/\./)
      return primary, secondary
    end

  end
end
