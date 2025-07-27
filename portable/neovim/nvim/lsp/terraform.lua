return {
	cmd = { "terraform-ls", "serve" },
	root_markers = {
		"terraform.rc",
		".terraformrc",
		"main.tf",
		"versions.tf",
	},
	filetypes = { "hcl", "tf", "tfvars", "terraform" },
}
