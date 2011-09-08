class PivotalShell::Cache
  class User
    ATTRIBUTES=%w(name id initials email)
    
    ATTRIBUTES.each do |attribute|
      attr_reader attribute
    end
    
    def initialize(source={})
      if source.is_a? PivotalTracker::Membership
        raise 'TODO'
      elsif source.is_a? Hash
        create_from_hash(source)
      end
    end

    def to_s
      name
    end
    
    def self.find(id)
      str_id = id.to_s.downcase
      hash = PivotalShell::Configuration.cache.db.execute("SELECT * FROM users WHERE id=? OR lower(initials)=? OR lower(name)=? OR lower(email)=?", id, str_id, str_id, str_id).first
      hash && new(hash)
    end

  protected
    def create_from_hash(hash)
      PivotalShell::Cache::User::ATTRIBUTES.each do |attribute|
        self.instance_variable_set("@#{attribute}", hash[attribute])
      end
    end
  end
end
