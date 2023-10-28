{ ... }:
{
	home-manager.users.me.programms.git = {
		enable = true;
		userName  = "Sebastian Moser";
		userEmail = "sewi.moser@gmail.com";
	
		extraConfig.core.editor = "nvim";
		extraConfig.core.excludesfile = "gitignore";
	};
}
