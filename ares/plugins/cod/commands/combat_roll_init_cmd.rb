module AresMUSH
  module CoD
    class CombatRollInitCmd
      include CommandHandler

      attr_accessor :target, :bonus, :msg

      def parse_args
        args = cmd.parse_args(/(?<arg1>[^\/]+)?(\/(?<arg2>[+-]?[\d]+))?/)
        if CoD.is_numeric? args.arg1
          self.target = enactor_name
          self.bonus = integer_arg(args.arg1)
        else
          self.target = args.arg1
          self.bonus = integer_arg(args.arg2)
        end
      end

      def handle
        target = Character.named(self.target || enactor_name)

        if target&.name != enactor_name && !CoD.is_st?(enactor)
          return CoD.system_emit t('cod.permission_denied'), client
        end

        if !target
          return client.emit_failure t('cod.invalid_character', char: self.target)
        elsif !target.is_approved?
          return CoD.system_emit t('cod.character_must_be_approved', name: target.name), client
        end

        combat = Combat.find(scene_id: enactor_room.scene.id).first if enactor_room.scene
        return CoD.system_emit(t('cod.combat_not_found'), client) if !combat

        modifier = self.bonus || 0
        mod_str = "#{modifier >= 0 ? '+' : '-'}#{modifier.abs}"
        if combat.init_list.member?(target.name) && combat.init_list[target.name] != 0
          CoD.set_init combat, target, [combat.init_list[target.name] + modifier, 1].max
          CoD.system_emit t('cod.initiative_modified', target: target.name, value: mod_str), client, enactor_room, :info
        else
          init = CoD.get_rating(target.sheet, 'initiative') + CoD.roll(1, 11)[:dice].first + modifier
          CoD.set_init(Combat[combat.id], target, init)
          bonus = modifier != 0 ? " (#{mod_str})" : ''
          CoD.system_emit t('cod.initiative_roll', target: target.name, value: init, bonus: bonus), client, enactor_room, :info
        end

        CoD.combat_notify combat
      end
    end
  end
end
