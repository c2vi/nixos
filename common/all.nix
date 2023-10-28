{}:

# config that i use on all my hosts

{
	# Set your time zone.
	time.timeZone = "Europe/Vienna";

	users.mutableUsers = false;
	
	nixpkgs.config.allowUnfree = true;
}
