
class SiteEventsController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:index, :create]

  respond_to :js

  def index
    # supplies the javascript that is ultimately rendered on a client site
  end

  def create
    # every time the index action is called, the script rendered there will
    # gather information from the client site, and send it as a POST request
    # to this action to then be stored

    # the account_id is how we determine what site were receiving events for
    site = Site.find_by(account_id: params[:account_id])

    payload = Site.parse_full_url(params[:url])
    payload[:ip] = params[:ip]

    payload[:useragent] = request.env['HTTP_USER_AGENT']

    SiteEvent.create(
      site: site,
      event: SiteEvent.events[:page_view],
      payload: payload
    )

    render nothing: true, status: 200
  end
end
