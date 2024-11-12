module AresMUSH
  module CoD

    def self.spend_xp enactor, sheet, amount, msg = nil
      create_modification(enactor, sheet, "Field:curr_xp:-#{amount.round(1)}", msg)
      run_modifications(sheet)
    end

    def self.award_xp enactor, sheet, amount, msg = nil
      create_modification(enactor, sheet, "Field:curr_xp:+#{amount.round(1)}", msg)
      create_modification(enactor, sheet, "Field:xp:+#{amount.round(1)}", msg)
      run_modifications(sheet)
    end

    def self.xp_cost sheet, stat_name
      stat, type_name = get_stat_with_category(sheet, stat_name)
      primary, secondary = parse_stat(stat_name)
      type_name = get_stat_category(sheet, stat_name)&.downcase&.to_sym

      type_name = :specialty if type_name == :skill && secondary
      c_stat = get_config_stat(sheet.template, primary, type_name)
      return t('cod.invalid_stat', stat: stat_name) if !c_stat || !type_name

      if [:attribute, :merit, :skill, :specialty].include? type_name
        err, can_purchase = can_purchase(sheet, c_stat, stat, type_name, stat_name)
        return err if err
        Global.read_config('cod', 'xp_costs', type_name.to_s)
      else
        config = get_template_config(sheet.template)
        err, can_purchase = self.public_send("#{to_key(config[:sphere])}_can_purchase_stat", sheet, c_stat, type_name, stat_name)
        return err if err
        self.public_send("#{to_key(config[:sphere])}_xp_cost", sheet, c_stat, type_name, stat_name, can_purchase)
      end
    end

    def self.can_purchase sheet, c_stat, stat, type_name, stat_name
      ok = nil
      rating = stat.respond_to?(:name) ? get_rating(sheet, "#{stat.name}#{type_name == :merit ? ".#{stat.spec}" : ''}") : -1
      ranges = Global.read_config('cod', 'stat_ranges').with_indifferent_access

      case type_name
      when :attribute, :skill
        ok = rating < ranges[type_name][:max]
        err = t('cod.cannot_raise_x_any_higher', stat: c_stat[:name]) if !ok
      when :merit
        return t('cod.merit_is_cg_only', name: c_stat['name']) if c_stat['cg_only']
        met = parse_expression(c_stat['reqs'], sheet)
        if met
          ok = !rating || rating < c_stat[:cost] if c_stat[:cost].is_a? Integer
          ok = (c_stat[:cost].index(rating) || 0) < (c_stat[:cost].size - 1) if c_stat[:cost].is_a? Array
          err = t('cod.cannot_raise_x_any_higher', stat: "#{c_stat[:name]}#{}") if !ok
        else
          err = t('cod.requirements_not_met_or_special_requirements_please_submit_xp_request')
          ok = false
        end
      when :specialty
        err = t('cod.specialty_already_exists', name: stat.name) if stat.name.match?(/\./)
        ok = !rating && !err
      end
      return err, ok
    end

  end
end
