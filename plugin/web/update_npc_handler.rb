module AresMUSH
  module CoD
    class UpdateNpcHandler
      def handle(request)
        combat = Combat[request.args['combat_id']]
        scene = Scene[combat.scene_id]
        npc = Npc[request.args['npc']['id']]
        enactor = request.enactor

        error = Website.check_login(request)
        return error if error

        return { error: t('webportal.not_found') } if !scene
        return { error: t('scenes.access_not_allowed') } if !Scenes.can_read_scene? enactor, scene
        return { error: t('scenes.scene_already_completed') } if scene.completed
        return { error: t('cod.combat_not_found') } if !combat
        if !!Character.named(request.args['npc']['name'].strip)
          return { error: t('cod.npc_cannot_be_named_after_existing_character') }
        end
        return { error: t('cod.npc_not_found', name: request.args['npc']['name']) } if !npc

        CoD.remove_combatant combat, npc
        npc = CoD.update_npc combat, npc, request.args['npc']
        CoD.add_combatant combat, npc
        CoD.set_init(combat, npc, CoD.get_rating(npc.sheet, :init))
        CoD.combat_notify combat
        {}
      end
    end
  end
end
