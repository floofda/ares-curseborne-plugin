module AresMUSH
  module CoD
    class RemoveNpcHandler
      def handle(request)
        combat = Combat[request.args[:combat_id]]
        scene = Scene[combat.scene_id]
        npc = Npc.named(request.args[:npc])
        enactor = request.enactor

        error = Website.check_login(request)
        return error if error

        return { error: t('webportal.not_found') } if !scene
        return { error: t('scenes.access_not_allowed') } if !Scenes.can_read_scene? enactor, scene
        return { error: t('scenes.scene_already_completed') } if scene.completed
        return { error: t('cod.combat_not_found') } if !combat
        return { error: t('cod.npc_not_found', name: request.args[:npc]) } if !npc

        CoD.remove_combatant combat, npc
        CoD.system_emit t('cod.x_has_been_removed_from_combat', name: npc.name, enactor: enactor.name), nil, scene.room, :info
        npc.delete
        return CoD.build_web_combat_data(combat)
      end
    end
  end
end
