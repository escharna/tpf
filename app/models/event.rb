class Event < ActiveRecord::Base
  extend SimpleCalendar

	belongs_to :event_type
	has_many :sub_events, dependent: :destroy

  has_calendar :attribute => :date

  validates :date, :name, presence: true

  scope :incomplete, ->{where(completed_at: nil)}
  scope :complete, ->{where.not(completed_at: nil)}
  scope :with_sub_events, ->{joins(:sub_events).uniq}

  def incomplete_tasks?
    sub_events.incomplete.present?
  end

  def completes
    self.update(completed_at: Time.now)
    self.save
  end

  def self.openings_with_role(role)
    return [] if role.to_s == 'admin'
    Event.with_sub_events.incomplete.inject([]) do |accum, event|
      event.sub_events.each{|sub| accum << event and break if !sub.is_full?(role.to_s)}
      accum
    end
  end

  private

  before_save :set_day

  def set_day
  	self.day = self.date.strftime("%A")
  end

end
