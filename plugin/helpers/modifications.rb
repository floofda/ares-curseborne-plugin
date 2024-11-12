module AresMUSH
  module CoD

    def self.create_modification(enactor, sheet, modifier, msg = nil)
      category, stat, value = modifier.split(':')
      action = !is_numeric?(value) || !value.start_with?(/[+-]/) ? 'set' : 'modify'

      primary, secondary = stat.split('.')
      if category == 'Skill' && !secondary.nil?
        category = 'Specialty'
      end

      Modification.create(
        category: category,
        stat: stat,
        action: action,
        value: value,
        msg: msg,
        enactor: enactor,
        sheet: sheet
      )
    end

    def self.run_modifications(sheet, include = nil, replay = true)
      if include.is_a? Array
        sheet.modifications.each { |m| run_modification(m, replay) if include.include?(m.stat.downcase) }
      else
        sheet.modifications.each { |m| run_modification(m) if !m.applied }
        if sheet.modifications.find(applied: false).size > 0
          run_modifications(sheet, nil, false)
        end
      end
      true
    end

    def self.run_modification(mod, replay = false)
      if is_numeric? mod.value
        val = ['xp', 'curr_xp'].include?(mod.stat.downcase) ? mod.value.to_f.round(1) : mod.value.to_i
      else
        val = mod.value
      end

      old = mod.value
      res = set_stat(Sheet[mod.sheet.id], mod.category, mod.stat, val, mod.action == 'set')
      return if replay
      mod.update(applied: true, previous: old)
    end

  end
end
