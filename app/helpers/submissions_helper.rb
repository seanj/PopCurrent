module SubmissionsHelper
  def has_blipped
    has_blipped = false
    if session[:user]
      if @submission.sub_blips.find_by_user_id(session[:user].id) 
        has_blipped = true
      end
    end
    return has_blipped
  end
end

