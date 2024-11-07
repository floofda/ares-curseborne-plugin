module AresMUSH
  module CoD
    class CharCreatedEventHandler
      def on_event(event)
        char = Character[event.char_id]
        char.update(sheet: Sheet.create)
        char.sheet.update(template: 'Mortal', cg_sheet: { template: 'Mortal' }, character: char)
        groups = char.groups
        groups[:template] = 'Mortal'
        char.update(groups: groups)
        role = Role.find_one_by_name('mortal')
        char.roles.add role
      end
    end
  end
end
