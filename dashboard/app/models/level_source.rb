# == Schema Information
#
# Table name: level_sources
#
#  id         :integer          not null, primary key
#  level_id   :integer
#  md5        :string(32)       not null
#  data       :string(20000)    not null
#  created_at :datetime
#  updated_at :datetime
#  hidden     :boolean          default(FALSE)
#
# Indexes
#
#  index_level_sources_on_level_id_and_md5  (level_id,md5)
#

require 'digest/md5'

# A specific solution attempt for a specific level
class LevelSource < ActiveRecord::Base
  belongs_to :level
  has_one :level_source_image

  has_many :activities

  validates_length_of :data, maximum: 20000
  validates :data, no_utf8mb4: true

  # This string used to sometimes appear in program XML.
  # We now strip it out, but it remains in some old LevelSource.data.
  # A level_source is considered to be standardized if it does not have this.
  XMLNS_STRING = ' xmlns="http://www.w3.org/1999/xhtml"'

  def self.cache_key(level_id, md5)
    "#{level_id}-#{md5}"
  end

  def self.find_identical_or_create(level, data)
    md5 = Digest::MD5.hexdigest(data)

    Rails.cache.fetch(cache_key(level.id, md5)) do
      LevelSource.where(level: level, md5: md5).first_or_create do |ls|
        ls.data = data
      end
    end
  end

  def standardized?
    !data.include? XMLNS_STRING
  end

  # Get the id of the LevelSource with the standardized version of self.data.
  def get_standardized_id
    return id if standardized?
    data = self.data.gsub(XMLNS_STRING, '')
    level_source = LevelSource.where(
      level_id: level_id,
      data: data,
      md5: Digest::MD5.hexdigest(data)
    ).first_or_create

    level_source.id
  end
end
