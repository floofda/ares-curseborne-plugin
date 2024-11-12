module AresMUSH
  module CoD

    def self.is_npc? obj
      return true if obj.class.name == 'AresMUSH::Npc'
      return true if obj.is_a?(Hash) && obj[:is_npc]
      false
    end

    def self.get_npc_from_sheet sheet
      Npc[sheet[:npc_id]]
    end

    def self.set_npc_stat sheet, stat, value, set = false
      npc = get_npc_from_sheet(sheet)
      n_sheet = npc.sheet
      n_sheet[to_key(stat)] = set ? value : n_sheet[to_key(stat)] + value
      npc.update(sheet: n_sheet)
      npc.sheet
    end

    def self.get_npc_stat sheet, stat
      stat = :resource if stat == sheet[:resource_name]
      stat = :morality if stat == sheet[:morality_name]
      rating = get_npc_rating sheet, stat
      key = sheet.select { |k, v| to_key(k).casecmp?(to_key(stat)) || to_key(k).start_with?(to_key(stat))}.first&.first
      { name: key.split('_').map(&:capitalize).join(' '), value: rating, rating: rating } if key
    end

    def self.get_npc_rating sheet, stat
      stat = :resource if stat == sheet[:resource_name]
      stat = :morality if stat == sheet[:morality_name]
      key = sheet.select { |k, v| to_key(k).casecmp? to_key(stat) }.first&.first
      sheet[key] if key
    end

    def self.update_npc combat, npc, updates
      npc.update(name: get_unique_npc_name(combat, updates[:name]), sheet: create_npc_sheet(updates[:sheet]))
    end

    def self.get_unique_npc_name combat, name
      return name if !combat.init_list[name]
      parts = name.split(/\s+/)
      n = is_numeric?(parts[-1]) ? "#{parts[0..-2].join(' ')} #{parts[-1].to_i + 1}" : "#{name} 1"
      return n if !combat.init_list[n]
      get_unique_npc_name(combat, n)
    end

    def self.create_npc enactor, combat, config
      sheet = create_npc_sheet config[:sheet] || {}
      npc = Npc.create(
        creator_id: enactor.id, combat_id: combat.id, uuid: generate_uuid,
        name: config[:name].strip, icon: config[:icon], sheet: sheet
      )
      s_sheet = npc.sheet
      sheet[:npc_id] = npc.id
      uniq_name = get_unique_npc_name(combat, config[:name].strip)
      npc.update(sheet: sheet, name: uniq_name)
    end

    def self.create_npc_sheet sheet
      parsed_sheet = {}
      sheet.each { |k, v| is_numeric?(v) ? parsed_sheet[k] = v.to_i : parsed_sheet[k] = v }
      n_sheet = {
        health: 7, agg_wounds: 0, lethal_wounds: 0, bashing_wounds: 0, init: 9, attack: 6, defense: 4,
        curr_wp: parsed_sheet['willpower'] || 4, curr_resource: parsed_sheet['resource'] || 10
      }
      n_sheet.merge(parsed_sheet)
    end

  end
end
