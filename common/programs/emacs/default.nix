{ inputs, self, ... }:
{
	home-manager.users.me = { ... }: {
		imports = [
			inputs.nix-doom-emacs.hmModule
		];
		programs.doom-emacs = {
			enable = true;
			doomPrivateDir = "${self}/common/programs/emacs";
		};
	};
}
