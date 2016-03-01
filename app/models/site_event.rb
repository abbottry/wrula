class SiteEvent < ActiveRecord::Base
  belongs_to :user
  belongs_to :site

  enum event: [:page_view]

  before_create :parse_useragent
  before_create :determine_status

  def parse_useragent
      user_agent = UserAgent.parse(self.payload.fetch("useragent", ""))
      self.payload["browser"] = user_agent.browser
      self.payload["browser_version"] = user_agent.version
      self.payload["platform"] = user_agent.platform
  end

  def determine_status
      self.payload["is_returning"] = SiteEvent.where(site: self.site).where("payload ->> 'ip' = '#{self.payload.fetch("ip")}'").count() > 1
  end
end
