require 'uri'

class Site < ActiveRecord::Base
  belongs_to :user

  has_many :site_events, dependent: :destroy

  validates :name, presence: true

  before_save :set_account_id

  def set_account_id
    # we could do this on create, but often times things
    # happen during the save, so rather than creating a
    # method to compensate for it, we'll call the method
    # on any save, and just noop if it's already set
    return if self.account_id

    # loop until the token (account_id) generated is unique
    self.account_id = loop do
      random_token = SecureRandom.urlsafe_base64(nil, false)
      break random_token unless Site.exists?(account_id: random_token)
    end
  end

  def get_unique_count_by(start_date, end_date, column)
    # return the number of unique values stored for the provided column
    self.get_unique_by(start_date, end_date, column).count()
  end

  def get_unique_by(start_date, end_date, column)
    # returns
    self.site_events.where(created_at: start_date.to_date..end_date.to_date).group("payload -> '#{column}'")
  end

  def get_daily_visits(start_date, end_date)
    # returns an active record result set representing each day between
    # the provided start and end date for each page, and how many times
    # that page has been viewed

    # TODO: potentially move this to a stored procedure, the reason we're
    # using raw sql here is so that we can join it against a psuedo table
    # that ensures a value is returned for every page, for every day that
    # lies between the provided start and end date
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

  class << self

    def parse_full_url(provided_url)
      # URI does a nice job of parsing the data out, this is just a more
      # hydrated version of its result, for thr purpose of storing it
      url = URI(provided_url)
      {
          "url": url.to_s,
          "host": url.host,
          "path": url.path,
          "query": url.query
      }
    end

  end
end
