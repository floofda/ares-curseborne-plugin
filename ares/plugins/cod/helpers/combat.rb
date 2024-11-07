module AresMUSH
  module CoD

    def self.build_web_combat_data combat
      combat = Combat[combat.id]
      data = combat.to_h
      data[:combatants] = data[:ordered_init_list].map { |n|
        c = Character.named(n) || Npc.named(n)
        return nil if !c
        is_npc = is_npc? c
        {
          name: n,
          is_npc: is_npc,
          icon: is_npc ? "npcs/#{(c.icon.nil? || c.icon.empty?) ? 'default.png' : c.icon}" : Website.icon_for_char(c),
          creator_id: is_npc ? c.creator_id : nil,
          id: c.id,
          sheet: (is_npc ? c.sheet.except(:is_npc, :npc_id) : {}).merge({
            defense: get_rating(c.sheet, :defense),
            health: get_rating(c.sheet, :health),
            agg_wounds: get_rating(c.sheet, :agg_wounds),
            lethal_wounds: get_rating(c.sheet, :lethal_wounds),
            bashing_wounds: get_rating(c.sheet, :bashing_wounds),
            init: combat.init_list[n],
            willpower: get_rating(c.sheet, :willpower),
            curr_wp: get_rating(c.sheet, :curr_wp),
            morality_name: is_npc ? c.sheet[:morality_name] : c.sheet.template_config['morality'],
            morality: get_rating(c.sheet, :morality),
            curr_morality: get_rating(c.sheet, :curr_morality),
            resource_name: is_npc ? c.sheet[:resource_name] : c.sheet.template_config['resource'],
            resource: is_npc ? c.sheet[:resource] : get_rating(c.sheet, :resource),
            curr_resource: get_rating(c.sheet, :curr_resource)
          })
        }
      }
      data
    end

    def self.combat_notify combat = nil, action = :update
      return if !combat
      data = build_web_combat_data(combat).to_json if action == :update
      data = 'null' if action == :delete

      Global.client_monitor.notify_web_clients(:combat_update, data, true) do |c|
        c && (combat.scene.participant_names.include?(c.name) || Scenes.is_watching?(combat.scene, c))
      end
    end

    def self.is_combatant? combat, char
      combat.init_list.member? char.name
    end

    def self.add_combatant combat, char
      return nil if is_combatant? combat, char
      list = combat.init_list
      list[char.name] = 0
      combat.update(init_list: list)
    end

    def self.remove_combatant combat, char
      return nil if !is_combatant? combat, char
      list = combat.init_list
      list.delete(char.name)
      combat.update(init_list: list)
    end

    def self.set_init combat, char, init
      return nil if !is_combatant? combat, char
      list = combat.init_list
      list[char.name] = init
      combat.update(init_list: list, cursor: combat.ordered_init_list.index(char.name) || 0)
    end

    def self.next_combatant combat
      len = combat.ordered_init_list.size
      new_cursor = combat.cursor < (len - 1) ? combat.cursor + 1 : 0
      combat.update(cursor: new_cursor)
      combat.curr_char
    end

    def self.prev_combatant combat
      len = combat.ordered_init_list.size
      new_cursor = combat.cursor <= 0 ? len - 1 : combat.cursor - 1
      combat.update(cursor: new_cursor)
      combat.curr_char
    end

    def self.get_combatants combat
      combat.ordered_init_list.map { |c| Character.named(c) || Npc.named(c) }
    end
  end
end
