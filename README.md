# TraitMacros
Addon for enabling talent conditionals for WoW

The WoW Dragonflight prepatch quitely disabled the talent conditional while adding a staggering number of new talents. For those of us who depend on talent conditionals for macros it has been a tough adjustment. This addon tries to provide the old behavior.


## How it works
The talent condition hasn't been removed (so there is hope that it will come back) but it does seem to always return false. Additionally, you can still add a 'no' prefix to get it to return true. The format the addon uses is [talent:NodeId] / [talent:NodeId/EntryId] / [talent:NodeId/EntryId/Rank] / [talent:NodeId/Rank]. NodeId and EntryId come from the talent tree and can be found in game using the addon [idTip](https://github.com/ItsJustMeChris/idTip-Community-Fork). Rank is 1 if not supplied. If only 2 values are supplied and the second value is a single digit, it is assumed to be a rank rather than an entry. The entry is only required for choice nodes if you care which choice is taken. Because the addon uses talent/notalent to enable options, to check for a talent being missing, use [talent:!NodeId].

When you edit a macro or change your talents, the addon goes through all your talents and looks for talent conditionals and changes them to `notalent` if the test passes and `talent` otherwise. This can add length to macros (specifically 2 characters for each true value) and if the result is too long, the macro will not be updated.


### Examples
(separated over multiple lines for clarity)
```
/use [mod:alt]War Stomp;                  
[talent:82120,form:2]Primal Wrath;        # Primal Wrath if talented and in cat form
[talent:82242/103321]Ursol's Vortex;      # Ursol's Vortex if talented
[talent:82242]Mass Entanglement;          # Mass entanglement (since this shares a note with UV, the EntryId is left out
[talent:82237/103316]Incapacitating Roar; # Incapacitating Roar if talented
[form:2]Rip;                              
[form:4]Flap;
Mark of the Wild
```

```
/use [talent:82214/2,@player]Regrowth;  # Regrowth on the player if at least two ranks of Nurturing Instinct are talented
[notalent:!82207]Moonfire;              # Moonfire if Improved Sunfire is not talented
[talent:82208]Sunfire;                  # Sunfire if talented
Wrath
```

# Warnings
* Back up your macros before playing with this addon, if something goes wrong wow may wipe out your macros. Look for `macros-cache.txt` in your account and character folders and make a copy.
* Existing macros using the old trait macros will all be changed to always succeed.
* I've only tested so far using one character and one spec so there are bound to be bugs
