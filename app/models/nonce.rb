class Nonce < ActiveRecord::Base
  belongs_to :user
  
  validates :uuid, presence: true, uniqueness: true
  validates :session_id, presence: true, uniqueness: true

  attr_accessible :session_id

  before_validation :init

  def expired?
    self.created_at.to_i < Time.now.to_i - 600
  end

  private

  def init
    if self.uuid.nil?
      Nonce.where(session_id:self.session_id).destroy_all
      self.uuid = SecureRandom.hex(8)
    end
  end
end