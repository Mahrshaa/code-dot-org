class ChangePhaseToInt < ActiveRecord::Migration
  PHASES = {
      1 => 'Phase 1',
      2 => 'Phase 2',
      3 => 'Phase 2 Online',
      4 => 'Phase 3A',
      5 => 'Phase 3B',
      6 => 'Phase 3C',
      7 => 'Phase 3D',
      8 => 'Phase 4'
  }
  def up
    ActiveRecord::Base.transaction do
      Workshop.find_each do |workshop|
        phase = workshop.phase
        if PHASES.invert[phase]
          workshop.phase = PHASES.invert[phase]
        else
          raise "error"
        end
        workshop.save!
      end
      change_column :workshops, :phase, :text
    end
  end
  def down
    Workshop.find_each do |workshop|
      phase = workshop.phase
      workshop.phase = PHASES[phase]
      workshop.save!
    end
    change_column :workshops, :phase, :text
  end
end
