module AresMUSH
  module CoD

    def self.init_health_track(sheet)
      sheet.update(health_track: Array.new(get_field(sheet, :health), 0))
      # ['bashing', 'lethal', 'agg'].each { |h| sheet.update("#{h}_wounds" => 0) }
      ['bashing', 'lethal', 'agg'].each { |h| set_field(sheet, "#{h}_wounds", 0, true) }
    end

    def self.derive_track(sheet)
      wounds = Array.new(get_field(sheet, :agg_wounds), 3) +
        Array.new(get_field(sheet, :lethal_wounds), 2) +
        Array.new(get_field(sheet, :bashing_wounds), 1)
      diff = get_field(sheet, :health) - wounds.size
      wounds + (diff > 0 ? Array.new(diff, 0) : [])
    end

    def self.set_health(sheet, values)
      types = ['bashing', 'lethal', 'agg']
      init_health_track(sheet)
      values.tally.each { |type, amount|
        # sheet.update("#{types[type - 1]}_wounds" => amount) if type.between?(1, 3)
        set_field(sheet, "#{types[type - 1]}_wounds", amount, true) if type.between?(1, 3)
      }
    end

    def self.harm(sheet, type, wounds)
      track = derive_track(sheet)
      size = track.size
      types = { agg: 3, lethal: 2, bashing: 1 }
      track += Array.new(wounds, types[type])
      track.sort!.reverse!
      overflow = track.slice!(size, track.size) || []
      overflow.slice!(overflow.index(0), size) if overflow.index(0)
      return set_health(sheet, track) if overflow.sum == 0

      upgrade_damage = lambda { |track, overflow|
        return track if overflow.empty? || overflow.first >= 3
        overflow.map! { |r| r + 1 }
        track.map! { |box| box < (overflow.first || 0) ? overflow.shift : box }
        upgrade_damage.call(track, overflow)
      }

      upgrade_damage.call(track, overflow)
      set_health(sheet, track)
    end

    def self.get_health(sheet)
      {
        bashing: get_field(sheet, :agg_wounds),
        lethal: get_field(sheet, :lethal_wounds),
        agg: get_field(sheet, :bashing_wounds)
      }
    end

    def self.heal(sheet, type, amount, downgrade = false)
      track = derive_track(sheet)
      health = [get_field(sheet, :bashing_wounds), get_field(sheet, :lethal_wounds), get_field(sheet, :agg_wounds)]
      type = type.nil? ? health.index { |h| h != 0 } : type
      return if type.nil?

      if downgrade
        max = get_field(sheet, :health)
        amount.times.each {
          next if health[type] <= 0
          health[type] -= 1
          health[type - 1] += 1 if type != 0 && health[type - 1] < max
        }
      else
        index = [:bashing, :lethal, :agg].index(type)
        health[index] -= amount
        health[index] = 0 if health[index] < 0
      end

      set_health(sheet, [3, 2, 1].map { |i| Array.new(health[i - 1] > 0 ? health[i - 1] : 0, i) }.flatten)
    end

    def self.adjust_health(sheet, type = nil, amount = 0, downgrade = false)
      level = (type == 'aggravated' ? 'agg' : type)&.to_sym
      health = amount <= 0 ?
        harm(sheet, level || :bashing, -amount) :
        heal(sheet, level, amount, downgrade || type.nil?)
    end

  end
end
