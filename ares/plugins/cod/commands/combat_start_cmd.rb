module AresMUSH
  module CoD
    class CombatStartCmd
      include CommandHandler

      def handle
        if !enactor.is_approved? && !CoD.is_st?(enactor)
          return CoD.system_emit t('cod.character_must_be_approved', name: enactor.name), client
        end

        combat = Combat.find(scene_id: enactor_room.scene.id).first if enactor_room.scene
        return CoD.system_emit(t('cod.combat_tracker_already_exists_for_scene'), client) if combat

        scene = enactor_room.scene
        return CoD.system_emit(t('cod.combat_tracker_requires_an_active_scene'), client) if !scene

        combat = Combat.create(scene_id: scene.id, owner_id: enactor.id)
        CoD.combat_notify combat
        CoD.system_emit t('cod.combat_tracker_started'), client, enactor_room, :info
      end
    end
  end
end
