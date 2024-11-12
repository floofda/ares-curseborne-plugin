module AresMUSH
  module CoD
    class CombatCursorCmd
      include CommandHandler

      def handle
        combat = Combat.find(scene_id: enactor_room.scene.id).first if enactor_room.scene
        return CoD.system_emit(t('cod.no_combat_tracker_found_for_scene'), client) if !combat

        if !enactor.is_approved? && !CoD.is_st?(enactor)
          return CoD.system_emit t('cod.character_must_be_approved', name: enactor.name), client
        end

        msg = cmd.switch == 'next' ?
          t('cod.combat_next_char', name: CoD.next_combatant(combat)) :
          t('cod.combat_prev_char', name: CoD.prev_combatant(combat))

        CoD.system_emit msg, client, enactor_room, :info
      end
    end
  end
end
