class ActivityController < ApplicationController

  # GET /activity
  # params:
  #   after optional. ID of activity item after which activityitems are returned
  #   before optional, if after is not specified. ID of activity item before which activityitems are returned
  #   limit optional.
  # returns JSON array of ActivityItems as JSON, in ascending order according to id
  def index
    respond_to do |format|
      format.json do
        where = if params[:after].present?
          ["id > ?", params[:after]]
        elsif params[:before].present?
          ["id < ?", params[:before]]
        else
          ""
        end
        
        @activity_items = ActivityItem.where(where)
          .limit(params[:limit])
          .order('created_at desc')
        
        if @activity_items.present?
          render :json => @activity_items.reverse.map(&:as_json)
        else 
          render :nothing => true
        end
      end
    end
  end
end
