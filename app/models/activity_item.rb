# ActivityItems are created after certain actions are taken on the site, such 
# as a new location was added or a comment was made. ActivityItems appear in
# the activity ticker. 
# The ActivityObserver handles the creation of ActivityItems.

class ActivityItem < ActiveRecord::Base
  include ApplicationHelper
  include ActionView::Helpers::TextHelper
  
  # subject is either a FeaturePoint, Comment, or Vote
  belongs_to :subject, :polymorphic => true, :inverse_of => :activity_items
  # subject_parent is a FeaturePoint, only if the subject is Vote of Comment
  belongs_to :subject_parent, :polymorphic => true
  belongs_to :profile
  
  validates :subject, :presence => true
  
  # JSON representation of ActivityItems provides information necessary to display in ticker
  def as_json
    attrs = { 
      :id           => id,
      :feature_id   => feature.id,
      :avatar_url   => avatar_url(profile.try(:user)), 
      :feature_url  => Rails.application.routes.url_helpers.feature_point_path(feature),
      :user_name    => read_attribute(:user_name) || User.model_name.human.capitalize,
      :message      => message, 
      :subject_type => subject_type.underscore
    }
  end
  
  private
  
  # For ticker JSON, clause describing user who created the feature this ActivityItem is about
  def describe_by_user
    return unless subject_parent.present?
    " " + I18n.t("activity.point.by_name", :name => subject_parent.display_submitter)
  end
  
  # For ticker JSON, clause describing region of activity's feature
  def describe_in_region
    return unless feature.region.present?
    " " + I18n.t("activity.point.in_region", :region => feature.region.name) 
  end
  
  # The feature this ActivityItem is about. 
  # If the subject is a FeaturePoint, subject is returned.
  # Else, the subject_parent is returned.
  def feature
    subject_parent || subject
  end
  
  # For ticker JSON, the body of the ActivityItem in ticker
  def message
    case subject_type
    when "FeaturePoint"
      [I18n.t("activity.point.action"), describe_in_region, "."]
    when "Comment"
      [I18n.t("activity.comment.action"), describe_by_user, ": &ldquo;", truncate(subject.comment, :length => 25), "&rdquo;"]
    when "Vote"
      [I18n.t("activity.vote.action"), describe_by_user, describe_in_region, "."]
    end.compact.join("")
  end
end
