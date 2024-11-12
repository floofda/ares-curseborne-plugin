module AresMUSH
  module CoD
    class AddNpcHandler
      def handle(request)
        combat = Combat[request.args[:combat_id]]
        scene = Scene[combat.scene_id]
        npc = request.args[:npc]
        enactor = request.enactor

        error = Website.check_login(request)
        return error if error

        return { error: t('webportal.not_found') } if !scene
        return { error: t('scenes.access_not_allowed') } if !Scenes.can_read_scene? enactor, scene
        return { error: t('scenes.scene_already_completed') } if scene.completed
        return { error: t('cod.combat_not_found') } if !combat
        return { error: t('cod.npc_cannot_be_named_after_existing_character') } if !!Character.named(npc[:name].strip)

        target = CoD.create_npc enactor, combat, npc
        CoD.add_combatant combat, target
        init = CoD.get_rating(target.sheet, 'init') + CoD.roll(1, 11)[:dice].first
        CoD.set_init(combat, target, init)
        CoD.system_emit t('cod.x_has_been_added_to_combat', name: target.name, enactor: enactor.name), nil, scene.room, :info
        return CoD.build_web_combat_data(combat)
      end
    end
  end
end
