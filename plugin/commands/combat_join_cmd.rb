module AresMUSH
  module CoD
    class CombatJoinCmd
      include CommandHandler

      def handle
        if !enactor.is_approved? && !CoD.is_st?(enactor)
          return CoD.system_emit t('cod.character_must_be_approved', name: enactor.name), client
        end

        combat = Combat.find(scene_id: enactor_room.scene.id).first if enactor_room.scene
        return CoD.system_emit(t('cod.no_combat_tracker_found_for_scene'), client) if !combat
        return CoD.system_emit(t('cod.already_in_combat'), client) if CoD.is_combatant? combat, enactor

        CoD.add_combatant combat, enactor
        CoD.system_emit t('cod.x_has_joined_combat', name: enactor_name), client, enactor_room, :info
      end
    end
  end
end
