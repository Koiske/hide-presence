# Plugin: `disable-hide-presence`

Disables the setting that lets users hide their profile and presence entirely.

This is undesirable for moderation reasons and it also doesn't fit our community or any other Roblox privacy features we have, since all users on forum are 13+.

---

## Features

- This plugin disables the "Hide my public profile and presence features" setting at User > Preferences > Interface.

  - This prevents users from hiding their profile from other forum users and community leaders, which would be undesirable because it complicates forum moderation and inspection of suspicious users by non-staff.

  - Before and after the plugin is enabled:
    - **Preference settings:**

      The setting will be hidden entirely after enabling the plugin.

      <img src=docs/before-settings.png width=45%> <img src=docs/after-settings.png width=47%>

    - **Profile:**

      Previously hidden profiles will be forced as public, and users can no longer hide their profile and presence from others.

      <img src=docs/before-profile.png width=40%> <img src=docs/after-profile.png width=52%>

---

## Impact

### Community

Users cannot hide their profile and presence anymore from any other forum user. Leaders and other non-staff that need to inspect user profiles for whatever reason are now able to do so.

Not being able to hide profiles does not impede privacy of the user, as all of the user's posts are still visible and findable through forum search anyway.

The only legitimate use case for hiding profiles is when you don't want the "Joined", "Last Post" or "Seen" labels to show, but this is not a large enough use case to allow users to hide their profile, considering the reasons above.

### Internal

No effect, staff users could already see all profiles regardless of user settings.

### Resources

Since this plugin simply overrides the value of the setting and does not allow users to change it, there is only a highly negligible performance impact whenever visiting a user's profile, but this will not impact forum performance.

### Maintenance

No manual maintenance needed.

---

## Technical Scope

The plugin hooks into the method that is called whenever a user updates their preferences, and the guardian that is used to check whether someone can see a user's profile.

For the first method, it will delete the `hide_profile_and_presence` key from the input if it exists, before passing it on to the actual update method. For the second method, it will override the entire implementation of the method to make sure that all users are able to see all profiles.

The prepend mechanism that is used to intervene in these methods is a standard one, and so is unlikely to break throughout Discourse updates, with the exception of the case where the names or parameter lists of `UserUpdater.update` or `Guardian.can_see_profile?` change. Even if that happens, the forum will continue to function properly, only the plugin functionality will be broken.

The fact that the implementation of `Guardian.can_see_profile?` is overridden when the plugin is enabled is risky, as when the stock Discourse implementation of this method or the underlying class changes in any way, then this may not be reflected by the implementation that this plugin overrides it with. However, it is deemed unlikely that this method or the class will change so rigorously in the near-term future.

#### Copyright 2020 Roblox Corporation
