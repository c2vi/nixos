{ ... }:
{
	home-manager.users.me.programs.git = {
		enable = true;
		userName  = "Sebastian Moser";
		userEmail = "me@c2vi.dev";
	
		extraConfig.core.editor = "nvim";
		extraConfig.core.excludesfile = "~/.config/git/gitignore";
	};
}
