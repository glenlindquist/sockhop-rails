class Channel < ApplicationRecord
  # == Constants ============================================================
  
  # == Attributes ===========================================================
  
  # == Extensions ===========================================================
  has_secure_password
  
  # == Relationships ========================================================
  belongs_to :user

  # == Validations ==========================================================
  validates :name, presence: true, uniqueness: true

  # == Scopes ===============================================================
  
  # == Callbacks ============================================================
  after_create :init_redis
  after_destroy :clear_redis

  # == Class Methods ========================================================
  
  # == Instance Methods =====================================================
  
  # == Private Instance Methods =============================================
  private
    def init_redis
      #TODO
    end

    def clear_redis
      #TODO
    end
end
