module AresMUSH
  module CoD
    class CombatEndCmd
      include CommandHandler

      def handle
        if !enactor.is_approved? && !CoD.is_st?(enactor)
          return CoD.system_emit t('cod.character_must_be_approved', name: enactor.name), client
        end

        combat = Combat.find(scene_id: enactor_room.scene.id).first if enactor_room.scene
        return CoD.system_emit(t('cod.no_combat_tracker_found_for_scene'), client) if !combat

        CoD.combat_notify combat, :delete
        combat.delete
        CoD.system_emit t('cod.combat_tracker_ended'), client, enactor_room, :info
      end
    end
  end
end
