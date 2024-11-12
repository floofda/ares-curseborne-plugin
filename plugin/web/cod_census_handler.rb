module AresMUSH
  module CoD
    class CodCensusHandler
      def handle(request)
        chars = Chargen.approved_chars.sort_by { |c| c.name }
        census = []

        chars.each do |c|
          classifications = c.sheet.template_config['classifications']
          char_data = {}
          char_data['name'] = c.name
          char_data['char'] = {
               name: c.name,
               icon:  Website.icon_for_char(c)  }
          char_data['template'] = c.sheet.template
          char_data['primary'] = classifications&.dig(0)
          char_data['secondary'] = classifications&.dig(1)
          char_data['tertiary'] = classifications&.dig(2)
          char_data['age'] = c.age
          census << char_data
        end
        census.sort! { |a, b| a['char'][:name] <=> b['char'][:name] }
        tally = census.map { |c| c['template'] }.tally
        {
          titles: Hash[tally.keys.map { |t| [t, CoD.get_template_config(t)['classifications'] || [nil, nil, nil]] }],
          totals: tally,
          chars: census
        }
      end
    end
  end
end
