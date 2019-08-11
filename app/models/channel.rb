class Channel < ApplicationRecord
  # == Constants ============================================================
  
  # == Attributes ===========================================================
  
  # == Extensions ===========================================================
  
  # == Relationships ========================================================
  
  # == Validations ==========================================================
  validates :name, uniqueness: true
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
