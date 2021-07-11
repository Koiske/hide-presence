# name: disable-hide-presence
# version: 1.0.2
# authors: buildthomas

enabled_site_setting :disable_hide_presence_enabled

register_asset "stylesheets/disable-hide-presence.scss"

after_initialize do
  
  # Intercept requests to update preferences
  module UserUpdaterInterceptor
    def update(attributes = {})
      if SiteSetting.disable_hide_presence_enabled
        # Delete entry and pass on if plugin enabled
        attributes.delete(:hide_profile_and_presence)
      end
      super(attributes)
    end
  end
  UserUpdater.send(:prepend, UserUpdaterInterceptor)

  # Intercept requests to open profiles
  module GuardianInterceptor
    def can_see_profile?(user)
      if SiteSetting.disable_hide_presence_enabled
        # Overwrite implementation of can_see_profile? to not use presence setting
        return !user.blank?
      end
      # Use default if plugin disabled
      super(user)
    end
  end
  Guardian.send(:prepend, GuardianInterceptor)

end
