class SessionCleaner
  def self.remove_stale_sessions
    secs = 86400 # 1 days
    old = "DATE_ADD(updated_at, INTERVAL #{secs} SECOND) < NOW()" 
    MysqlSession.delete_all(old)
  end
end
