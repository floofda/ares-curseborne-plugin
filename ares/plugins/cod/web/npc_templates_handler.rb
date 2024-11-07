module AresMUSH
  module CoD
    class NpcTemplatesHandler
      def handle(request)
        Global.read_config('cod', 'npcs').map { |npc|
          new_sheet = CoD.create_npc_sheet(npc['sheet'])
            .except(:agg_wounds, :lethal_wounds, :bashing_wounds, :curr_wp, :curr_resource)
          npc['sheet'] = new_sheet
          npc
        }
      end
    end
  end
end
