$:.unshift File.dirname(__FILE__)

module AresMUSH
     module CoD

    def self.plugin_dir
      File.dirname(__FILE__)
    end

    def self.shortcuts
      Global.read_config('cod', 'shortcuts')
    end

    def self.achievements
      Global.read_config('cod', 'shortcuts')
    end

    def self.get_cmd_handler(client, cmd, enactor)
      case cmd.root
      when 'stat'
        case cmd.switch
        when 'buy'
          return StatBuyCmd
        when 'cost'
          return StatCostCmd
        when 'info'
          return StatInfoCmd
        when 'check'
          return StatCheckCmd
        end
        return StatCmd
      when 'combat'
        case cmd.switch
        when 'init'
          return CombatRollInitCmd
        when 'start'
          return CombatStartCmd
        when 'end'
          return CombatEndCmd
        when 'join'
          return CombatJoinCmd
        when 'leave'
          return CombatLeaveCmd
        when 'next', 'prev'
          return CombatCursorCmd
        else
          return CombatCmd
        end
      when 'sheet'
        return SheetCmd
      when 'spend', 'regain', 'lose'
        return ResourceCmd
      when 'reset'
        return ResetCmd
      when 'roll'
        return RollCmd
      when 'harm'
        return HarmCmd
      when 'heal'
        return HealCmd
      when 'xp'
        return XpCmd
      end
    end

    def self.get_event_handler(event_name)
      case event_name
      when 'CronEvent'
        return CronEventHandler
      when 'CharCreatedEvent'
        return CharCreatedEventHandler
      end
    end

    def self.get_web_request_handler(request)
      case request.cmd
      when 'setupTemplate'
        return SetupTemplateHandler
      when 'awardBeats'
        return AwardBeatsJobHandler
      when 'addJobRoll'
        return AddJobRollHandler
      when 'addSceneRoll'
        return AddSceneRollHandler
      when 'adjustHealth'
        return AdjustHealthHandler
      when 'adjustResource'
        return AdjustResourceHandler
      when 'codCensus'
        return CodCensusHandler
      when 'codSettings'
        return CodSettingsHandler
      when 'codUpdateSettings'
        return CodUpdateSettingsHandler
      when 'sceneCombatInfo'
        return SceneCombatInfoHandler
      when 'combatStart'
        return CombatStartHandler
      when 'combatEnd'
        return CombatEndHandler
      when 'joinCombat'
        return JoinCombatHandler
      when 'leaveCombat'
        return LeaveCombatHandler
      when 'combatRollInit'
        return CombatRollInitHandler
      when 'combatPrevChar'
        return CombatPrevCharHandler
      when 'combatNextChar'
        return CombatNextCharHandler
      when 'addNpc'
        return AddNpcHandler
      when 'updateNpc'
        return UpdateNpcHandler
      when 'removeNpc'
        return RemoveNpcHandler
      when 'npcTemplates'
        return NpcTemplatesHandler
      else
        nil
      end
    end

  end
end
