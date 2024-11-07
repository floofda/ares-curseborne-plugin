module AresMUSH
  module CoD

    def self.app_review_changeling(cg_sheet)
      config = get_template_config('changeling').with_indifferent_access
      errors = []
      check_template_fields(cg_sheet, config, errors)
      check_changeling_chargen_fields(cg_sheet, config, errors)
      check_changeling_contracts(cg_sheet, config, errors)
      errors
    end

    def self.app_review_fae_touched(cg_sheet)
      config = get_template_config('fae-touched').with_indifferent_access
      errors = []
      check_template_fields(cg_sheet, config, errors)
      check_fae_touched_contracts(cg_sheet, config, errors)
      errors
    end

    def self.check_changeling_chargen_fields(cg_sheet, config, errors)
      attribute = 'Favored Attribute'
      seeming = cg_sheet.dig('classifications', 'primary')
      favored = config['seeming']&.select { |s| s['name'] == seeming }&.first

      favored_match = attributes_by_type(favored&.dig('attribute'))
        .map{ |f| f['name'] }
        .include?(get_cg_field(cg_sheet, attribute)&.dig('name'))
      if favored && !favored_match
        errors << t('cod.favored_attribute_must_be', category: favored['attribute'])
      end
      errors.flatten!
    end

    def self.check_changeling_contracts(cg_sheet, config, errors)
      seeming = get_cg_field(cg_sheet, 'Favored Regalia')
      court = config['court']&.select { |s| s['name'] == cg_sheet.dig('classifications', 'tertiary') }&.first
      favored = config['seeming']&.select { |s| s['name'] == cg_sheet.dig('classifications', 'primary') }&.first
      regalia = [seeming&.dig('name'), favored&.dig('regalia'), court&.dig('name')]
      common = cg_sheet.dig('contracts')&.select { |c| c['type'] == 'Common' || c['group'] == 'Goblin'}
      royal = cg_sheet.dig('contracts')&.select { |c| c['type'] == 'Royal' }
      common_count = config['contracts']['common']
      royal_count = config['contracts']['royal']

      if common.size != common_count || royal.size != royal.count
        errors << t('cod.changeling_contract_count_royal', common: common_count, royal: royal_count)
      end

      royal.each { |r|
        if !regalia&.include?(r['category'])
          errors << t('cod.contract_not_in_favored', contract: r['name'])
        end
      }
    end

    def self.check_fae_touched_contracts(cg_sheet, config, errors)
      favored = get_cg_field(cg_sheet, 'Favored Regalia')
      common = cg_sheet.dig('contracts')&.select { |c| c['type'] == 'Common' }
      common_count = config['contracts']['common']

      if common.size != common_count
        errors << t('cod.changeling_contract_count', common: common_count)
      end

      common.each { |c|
        if !favored&.dig('name').casecmp?(c['category'])
          errors << t('cod.contract_not_in_favored', contract: c['name'])
        end
      }
    end

    def self.changeling_can_purchase_stat sheet, c_stat, type_name, stat_name
      return t('cod.cannot_purchase_c_stat_please_submit_xp_request') if type_name == 'contract blessing'
      return t('cod.already_added', name: c_stat[:name]) if get_c_stat(sheet, c_stat[:name])
      return nil, true if c_stat[:group] != 'Court'

      court = c_stat[:category]
      mantle = get_rating(sheet, "Mantle.#{court}") || 0
      goodwill = get_rating(sheet, "Court Goodwill.#{court}") || 0
      contract_count = sheet.abilities.find(type: 'Contract').map(&:to_h)
        .select { |c| c[:data]['group'] == 'Court' && c[:data]['category'] == court && c[:data]['type'] == c_stat[:type] }.size

      if contract_count > 0
        common_check =(goodwill < 2 && mantle < 1) && c_stat[:type] == 'Common'
        royal_check = (goodwill < 5 && mantle < 3) && c_stat[:type] == 'Royal'
        return t('cod.mantle_or_court_goodwill_not_high_enough', court: court) if common_check || royal_check
      else
        return t('cod.court_goodwill_not_high_enough', court: court) if c_stat[:type] == 'Royal' && goodwill < 4
      end

      return nil, true
    end

    def self.changeling_xp_cost sheet, c_stat, can_purchase
      config = get_template_config('changeling')
      xp_costs = config[:xp_costs]
      return xp_costs[:contract_blessing] if type_name == 'contract blessing'

      favored_seeming_regalia = config[:seeming].select { |s| s[:name] == get_rating(sheet, :seeming) }&.first&.dig('regalia')
      favored_regalia = get_rating(sheet, 'Favored Regalia')
      type = c_stat[:type] == 'Royal' ? 'royal' : 'common'

      if c_stat[:group] == 'Regalia'
        return [favored_seeming_regalia, favored_regalia].include?(c_stat[:category]) ?
          xp_costs["favored_regalia_contract_#{type}"] :
          xp_costs["regalia_contract_#{type}"]
      elsif c_stat[:group] == 'Court'
        return xp_costs["court_contract_#{type}"]
      else
        return xp_costs[:goblin_contract]
      end
    end

  end
end
