# Glitch's Chronicles of Darkness code for AresMUSH

**************************************
**NO SUPPORT PROVIDED GOOD LUCK :)**
**************************************

Over at City of Glass, we’ve had the great pleasure of getting to use a custom Ares plugin for Chronicles of Darkness made by the community’s one and only Glitch. He’s had to since leave the hobby, but the plugin has remained stable enough for three non-coders to continue using it and staffing with it without too much difficulty, minus a few hiccups. He also let us know that we should do whatever we thought was best with the code, and we figure the best thing is to open it to the wild.

The code includes support for Mortal/Mortal+, Changeling, Mage, and Demon, along with the M++ templates Atariya, Dreamer, Infected, Lost Boy, and Psychic Vampire. (We only use Atariya and Psychic Vampire on CoG, so those are the only two I can fully attest to.)

**This should be considered abandonware: nothing in it is going to change or be updated, and the documentation included is all you get. It was designed under Ares 1.x and will require code changes for 2.x games.**

## Install

1. `plugin/install <github url>`
2. Update the custom code hooks using the examples in the `custom/` folder.
3. Upload (via FTP or GitHub) the contents of the `public/` folder into the `ares-webportal/public` folder.
4. Restart the game.
5. Make the following changes to `chargen.yml`:

```
  app_notes_prompt: If you want to make any special notes about your application,
    you can enter them below. For Merit notes, custom Anchors, ability details, or
    other required template items (e.g., Touchstones, Frailties, etc.), please set
    these in the Ledger section of your character page, either in the appropriate
    sphere-specific tab, or in the Notes tab.
  stages:
    start:
      title: Chargen Commands
      text: Our chargen is exclusive on the web portal. Please select `Create a Character`
        from the `Getting Started` menu to begin!
    app:
      title: App Review
      text: The `Review` button is your friend during chargen. It will alert you to
        things you may have forgotten to set.  %xrred%xn issues will almost certainly
        prevent your character from being approved (like forgetting to set your template).
        %xyYellow%xn issues are warnings; they might actually be OK if it fits the
        character concept.
    demographics:
      help: demographics
    background:
      help: backgrounds
    desc:
      help: descriptions
    hooks:
      help: hooks
    handles:
      help: handles
    profile:
      help: profile
    lastwill:
      help: idle_out
    review:
      title: App Submission
      text: You've completed chargen! Review your app one more time, and use `Submit`
        to submit your character when ready. The admins will make sure it's a good
        fit for the game's theme, that the skills are reasonable given the background,
        and that you haven't missed anything important in chargen. See `help apps`
        for additional help on the app review process.
  welcome_message: |-
    Please welcome %{name}, our newest %{template}!

    Profile: %{profile_link}

    RP Hooks:

    %{rp_hooks}
```


## Uninstall

You will need to remove all the database fields and objects from the database, then remove the plugin itself. See [removing plugins](https://aresmush.com/tutorials/code/contribs.html#uninstalling-plugins) for help.
