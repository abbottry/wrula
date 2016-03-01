require 'uri'
require 'cgi'

class Site < ActiveRecord::Base
  belongs_to :user

  has_many :site_events, dependent: :destroy

  before_create :set_account_id

  def set_account_id
    self.account_id = loop do
      random_token = SecureRandom.urlsafe_base64(nil, false)
      break random_token unless self.class.exists?(account_id: random_token)
    end
  end

  def generate_event_payload(provided_url)
    url = URI(provided_url)
    {
        "url": url.to_s,
        "host": url.host,
        "path": url.path,
        "query": url.query
    }
  end

  def get_daily_visits(start_date, end_date)
    query = "SELECT *
    FROM (
      SELECT day::date
      FROM generate_series(timestamp '#{start_date.to_s(:db)}', timestamp '#{end_date.to_s(:db)}', interval '1 day') as day
    ) d
    LEFT JOIN (
      SELECT CAST(site_events.created_at as DATE) as day, count(id)
      FROM site_events
      WHERE site_id = #{self.id}
      GROUP BY day
    ) t USING (day)
    ORDER BY day"

    ActiveRecord::Base.connection.execute(query)
  end

  def get_daily_visits_by(start_date, end_date, key="path")
    query = "SELECT *
    FROM (
      SELECT day::date
      FROM generate_series(timestamp '#{start_date.to_s(:db)}', timestamp '#{end_date.to_s(:db)}', interval '1 day') as day
    ) d
    LEFT JOIN (
      SELECT CAST(site_events.created_at as DATE) as day, payload -> '#{key}' as path, count('#{key}')
      FROM site_events
      WHERE site_id = #{self.id}
      GROUP BY day, #{key}
    ) t USING (day)
    ORDER BY day"

    ActiveRecord::Base.connection.execute(query)
  end

  def get_unique_by(start_date, end_date, column)
    SiteEvent.where(site: self).where(created_at: start_date.to_date..end_date.to_date+1.day).group("payload -> '#{column}'").count()
  end
end
