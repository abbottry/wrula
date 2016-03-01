
class SiteEventsController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:index, :create]

  respond_to :js

  def index
  end

  def create
    site = Site.find_by(account_id: params[:account_id])

    payload = site.generate_event_payload(params[:url])
    payload[:useragent] = request.env['HTTP_USER_AGENT']
    payload[:ip] = params[:ip]

    SiteEvent.create(
      site: site,
      event: SiteEvent.events[:page_view],
      payload: payload
    )

    render nothing: true, status: 200
  end
end
