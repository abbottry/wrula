class SitesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_site, only: [:show, :edit, :update, :destroy]

  # after_action  :verify_authorized

  # GET /sites
  def index
    @sites = current_user.sites.all
  end

  # GET /sites/1
  def show
    @start_date = if params[:start_date]
      Date.parse(params[:start_date])
    else
      30.days.ago.to_date
    end

    @end_date = if params[:end_date]
      DateTime.parse(params[:end_date])
    else
      DateTime.now
    end.end_of_day

    @popular_pages = SiteEvent.select("payload -> 'path' as path, count('path')").where(site: @site).where(created_at: @start_date..@end_date).group('path').order("count DESC")
    # @page_visit_data = @site.get_daily_visits_by(@start_date, @end_date, "path")
    @page_visit_data = @site.get_daily_visits(@start_date, @end_date)
    @browser_breakdown = SiteEvent.select("payload -> 'browser' as browser, count('browser')").where(site: @site).where(created_at: @start_date..@end_date).group('browser').order("count DESC")
  end

  # GET /sites/new
  def new
    @site = current_user.sites.new
  end

  # GET /sites/1/edit
  def edit
  end

  # POST /sites
  def create
    @site = current_user.sites.new(site_params)

    if @site.save
      redirect_to @site, notice: 'Site was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /sites/1
  def update
    if @site.update(site_params)
      redirect_to @site, notice: 'Site was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /sites/1
  def destroy
    @site.destroy
    redirect_to sites_url, notice: 'Site was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_site
      @site = current_user.sites.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def site_params
      params.require(:site).permit(:user_id, :name, :url, :account_id)
    end
end
