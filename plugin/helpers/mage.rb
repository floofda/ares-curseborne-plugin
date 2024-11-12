module AresMUSH
  module CoD

    def self.app_review_mage(cg_sheet)
      config = get_template_config('mage').with_indifferent_access
      errors = []
      check_template_fields(cg_sheet, config, errors)
      check_mage_arcana(cg_sheet, config, errors)
      check_mage_praxes(cg_sheet, config, errors)
      check_mage_rotes(cg_sheet, config, errors)
      errors
    end

    def self.app_review_sleepwalker(cg_sheet)
      []
    end

    def self.app_review_proximus(cg_sheet)
      config = get_template_config('proximus').with_indifferent_access
      errors = []
      check_template_fields(cg_sheet, config, errors)
      check_proximus_blessings(cg_sheet, config, errors)
      errors
    end

    def self.check_mage_praxes(cg_sheet, config, errors)
      count = (cg_sheet['merits'] || []).select { |m| m['name'] == 'Gnosis Increase' }.size + 1
      amount = (cg_sheet['praxes'] || []).select { |p| p['name'] != '' }.size
      errors << t('cod.must_have_x_praxes_y_found', count: count, amount: amount) if count != amount
    end

    def self.check_mage_arcana(cg_sheet, config, errors)
      path = config[:path].select { |p| p['name'] == cg_sheet['classifications']['primary'] }.first
      arcana_config = config[:arcana]
      rote_count = 0
      cg_sheet['arcana'].each { |a|
        if path['ruling_arcana'].include? a['name']
          errors << t('cod.must_have_at_least_one_dot_in_ruling_arcana', arcana: a['name']) if a['rating'] < 1
        elsif path['inferior_arcana'].include? a['name']
          errors << t('cod.cannot_start_play_with_any_dots_in_inferior_arcana', arcana: a['name']) if a['rating'] > 0
        end
        if a['rating'] > arcana_config['max']
          errors << t('cod.cannot_have_more_than_x_dots_in_an_arcana', count: arcana_config[:max])
        end
        rote_count += a['rating']
      }
      if arcana_config[:total] != rote_count
        errors << t('cod.must_have_x_points_in_arcana_y_found', count: arcana_config[:total], amount: rote_count)
      end
    end

    def self.check_mage_rotes(cg_sheet, config, errors)
      count = cg_sheet['rotes']&.size || 0
      errors << t('cod.must_have_x_rotes', count: config[:rotes]) if count != config[:rotes]
    end

    def self.check_proximus_blessings(cg_sheet, config, errors)
      count = config[:blessings]
      amount = cg_sheet['blessings']&.size || 0
      errors << t('cod.must_have_x_blessings', count: count) if amount != count
    end

    def self.proximi_can_purchase_stat sheet, c_stat, type_name
      return t('cod.already_added', name: c_stat[:name]) if get_stat(sheet, c_stat[:name])

      t_config = get_template_config('proximus')
      dot_max = t_config['max_blessing_dots']
      dots = sheet.abilities.reduce(0) { |d, n| d += n.rating }
      stat_rating = c_stat[:reqs].split(':')&.last&.to_i || 1000
      return t('cod.cannot_exceed_x_dots_in_blessings', dots: dot_max) if (dots + stat_rating) > dot_max

      s_config = sheet.template_config.with_indifferent_access
      arcana = t_config[:path].select { |a| a['name'] == s_config[:classifications].first['value'] }&.first&.dig('ruling_arcana')
      arcana << s_config[:fields]&.first['value']

      c_blessings = abilities(sheet.template, 'rotes').select { |b| b['reqs'].match?(/^Ability:(#{arcana.join('|')}):[123]/) }
      selection = c_blessings.select { |b| b['name'] == c_stat[:name] }&.first
      return t('cod.invalid_stat', stat: c_stat[:name]) if !selection
      return nil, stat_rating
    end

    def self.mage_can_purchase_stat sheet, c_stat, type_name, stat_name
      return proximi_can_purchase_stat(sheet, c_stat, type_name) if sheet.template == 'Proximus'

      c_mage = Global.read_config('cod', 'mage')
      xp_max_arcana = c_mage['xp_max_arcana']
      primary, secondary = parse_stat(stat_name)
      gnosis = get_rating(sheet, 'Gnosis')
      stat = get_stat(sheet, c_stat['name']) || get_stat(sheet, primary)

      if get_field(stat, :name) == 'Gnosis'
        return nil, true if gnosis < c_mage.dig('power', 'max')
      elsif get_field(stat, :type) == 'Arcanum'
        return t('cod.arcana_cannot_go_above_max', max: xp_max_arcana) if stat.rating >= xp_max_arcana

        arcana = sheet.abilities.find(type: 'Arcanum')
        highest_max = [3, 3, 4, 4, 5][gnosis - 1]
        other_max = [2, 3, 3, 4, 4][gnosis - 1]
        curr_max = arcana.reduce { |c, n| c = n if c.nil? || c.rating <= n.rating }

        if (stat.rating + 1) > highest_max
          return t('cod.highest_arcanum_max_x', arcanum: stat.name)
        elsif curr_max.rating == highest_max && (stat.rating + 1) > other_max
          return t('cod.higest_arcanum_max_x', arcanum: curr_max.name)
        elsif (stat.rating + 1) > other_max
          return t('cod.highest_other_arcana_max_x', arcanum: stat.name)
        end
        return nil, true
      elsif (stat&.type == 'Rote' && secondary) || (stat&.type == 'Praxis' && !secondary)
        return t('cod.already_added', name: stat.name)
      end

      return nil, true if parse_expression(c_stat[:reqs], sheet)
      t('cod.requirements_not_met_for_x', name: c_stat[:name])
    end

    def self.get_mage_path sheet
      Global.read_config('cod', 'mage', 'path').select { |p| p['name'] == get_stat(sheet, 'path')['value'] }&.first
    end

    def self.is_common_arcana? sheet, arcanum
      !(is_ruling_arcana?(sheet, arcanum) || is_inferior_arcana?(sheet, arcanum))
    end

    def self.is_ruling_arcana? sheet, arcanum
      path = get_mage_path sheet
      return false if !path
      path['ruling_arcana'].include? arcanum
    end

    def self.is_inferior_arcana? sheet, arcanum
      path = get_mage_path sheet
      return false if !path
      path['inferior_arcana'].include? arcanum
    end

    def self.mage_xp_cost sheet, c_stat, type_name, stat_name, rating
      return Global.read_config('cod', 'proximi', 'xp_costs')[:blessings] if sheet.template == 'Proximus'

      xp_costs = Global.read_config('cod', 'mage', 'xp_costs')
      primary, secondary = parse_stat(stat_name)
      stat = get_stat(sheet, c_stat['name']) || get_stat(sheet, primary)
      if get_field(stat, :name) == 'Gnosis'
        return xp_costs['gnosis']
      elsif get_field(stat, :type) == 'Arcanum'
        arcana = sheet.abilities.find(type: 'Arcanum')
        rating = get_field(stat, :rating)
        return xp_costs['over_arcana'] if is_inferior_arcana?(sheet, stat.name) && stat.rating >= 2
        return xp_costs['over_arcana'] if is_common_arcana?(sheet, stat.name) && stat.rating >= 4
        return xp_costs['arcana']
      else
        return xp_costs['rote']
      end
    end

  end
end
