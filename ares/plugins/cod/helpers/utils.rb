require 'securerandom'

module AresMUSH
  module CoD

    def self.attributes
      Global.read_config('cod', 'attributes')
    end

    def self.attributes_by_type(type)
      attributes.filter { |a| a['type'] == type }
    end

    def self.attributes_by_category(category)
      attributes.filter { |a| a['category'] == category }
    end

    def self.skills
      Global.read_config('cod', 'skills')
    end

    def self.skills_by_category(category)
      skills.filter { |s| s['category'] == category }
    end

    def self.merits(template = nil)
      merits = Global.read_config('cod', 'merits')
      is_m_plus = false
      if template
        is_m_plus = !!Global.read_config('cod', 'chargen', 'm_plus')&.include?(template)
        sphere = get_template_config(template.downcase)&.dig('sphere') || ''
        merits += (Global.read_config('cod', "#{sphere.downcase}_merits") || [])
      end
      merits.select { |m|
        (m['include'].size == 0 || m['include'].include?(template&.downcase) || (m['include'].include?('mortal') && is_m_plus)) &&
        !m['exclude']&.include?(template&.downcase)
      }.sort { |a, b| a['name'] <=> b['name'] }
    end

    def self.abilities(template = nil, type_config_key = nil)
      return [] if template.nil?
      a_config = get_template_config(template)
      return [] if !a_config['abilities']
      out = type_config_key.nil? ?
        a_config['abilities'].map { |a| Global.read_config('cod', a['config']) }.flatten :
        Global.read_config('cod', type_config_key)

      (out || []).sort { |a, b| a['name'] <=> b['name'] }
    end

    def self.get_ability_type(template, type_name = nil)
      return nil if !type_name
      get_template_config(template.downcase)[:abilities]
        .select { |t| t['name'].downcase == type_name.downcase }.first&.with_indifferent_access
    end

    def self.get_ability_with_type(template, ability)
      return nil if template.nil?
      a_config = get_template_config(template)[:abilities]
      return nil if !a_config
      a_config.each { |type|
        t_ability = abilities(template, type['config']).select { |a| a['name'] == ability }&.first&.with_indifferent_access
        return t_ability, type if t_ability
      }
    end

    def self.get_template_config(template)
      Global.read_config('cod', to_key(template)).with_indifferent_access
    end

    def self.get_template_stats(config)
      stats = []
      fields = config['classifications'].values
      stats << fields.map { |f| config[f.downcase] }
    end

    def self.get_config_stat(template, stat, type_name = nil)
      type = get_ability_type(template, type_name) if type_name
      c_abilities = abilities(template, type&.dig('config')) || []
      return [attributes, skills, merits(template), c_abilities].flatten.select { |s|
        s['name']&.downcase&.start_with? (stat.is_a?(String) ? stat : stat&.name)&.downcase
      }.first&.dup&.with_indifferent_access
    end

    def self.get_basic_stat sheet, type_name, stat_name
      if type_name == 'merit'
        list = merits(sheet.template)
      else
        list = ['skill', 'specialty'].include?(type_name) ? skills : attributes
      end
      list.select { |s| s['name']&.downcase&.start_with? stat_name&.downcase }&.first&.dup&.with_indifferent_access
    end

    def self.attributes_blurb
      Global.read_config('cod', 'chargen', 'attributes_blurb')
    end

    def self.skills_blurb
      Global.read_config('cod', 'chargen', 'skills_blurb')
    end

    def self.merits_blurb
      Global.read_config('cod', 'chargen', 'merits_blurb')
    end

    def self.sheet_columns
      Global.read_config('cod', 'sheet_columns')
    end

    def self.attr_names
      CoD.attributes.map { |a| a['name'] }
    end

    def self.skill_names
        CoD.skills.map { |s| s['name'] }
    end

    def self.merit_names template
        CoD.merits(template).map { |m| m['name'] }
    end

    def self.get_from_list list, q
      list&.select { |a| a&.downcase&.start_with?(q&.downcase) }&.first
    end

    def self.can_view_sheets? actor
      Global.read_config('cod', 'show_sheet') || (actor && actor.has_permission?('view_sheets'))
    end

    def self.is_st? actor
      actor && (actor.is_admin? || actor.has_role?('storyteller'))
    end

    def self.is_numeric? str
      "#{str}".match?(/^[+-]?(\d*[.])?\d+$/)
    end

    def self.to_b bool
      bool.to_s.downcase.strip == 'true' ? true : false
    end

    def self.to_key(key)
      (key || '').to_s.gsub(/[- ]/, '_')&.downcase
    end

    def self.generate_uuid
      SecureRandom.uuid
    end

  end
end
