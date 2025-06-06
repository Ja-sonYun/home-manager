M = {}

M.root_markers = {
	".git",
	"*.sln",
	"build/env.sh",
	"pyproject.toml",
	"env",
	"Pipenv",
	"setup.cfg",
	"setup.py",
	".venv",
	"package.json",
	"package-lock.json",
	"node_modules",
	"yarn.lock",
	"yarn-error.log",
	"composer.json",
	"composer.lock",
	"vendor",
	"Gemfile",
	"Gemfile.lock",
	"Podfile",
	"Podfile.lock",
	"Pods",
	"Cartfile",
	"Cartfile.resolved",
	"Carthage",
	"Carthage.resolved",
	"Makefile",
	"makefile",
	".terraform",
	"flake.nix",
	"flake.lock",
	"default.nix",
	"shell.nix",
	"Cargo.toml",
	"go.mod",
	"compile_flags.txt",
	"compile_commands.json",
	"CMakeLists.txt",
	"build.ninja",
	"build.ninja.in",
	"meson.build",
	"meson_options.txt",
	"go.sum",
	".luarc.json",
	".luarc.jsonc",
	".luacheckrc",
	".stylua.toml",
	"stylua.toml",
	"selene.toml",
	"selene.yml",
	"Cargo.lock",
	"rust-toolchain",
	"src",
	"flake.nix",
	"default.nix",
	"shell.nix",
	"package.json",
	"tsconfig.json",
	"yarn.lock",
	"pnpm-lock.yaml",
	"package-lock.json",
	".git",
	".gitignore",
	".gitmodules",
}

M.non_code = {
	"*.so",
	"*.o",
	"*.obj",
	"*.dylib",
	"*.bin",
	"*.dll",
	"*.exe",
	"*/.git/**",
	"*/.svn/**",
	"*/.venv/**",
	"*/__pycache__/*",
	"*/build/**",
	"*.jpg",
	"*.png",
	"*.jpeg",
	"*.bmp",
	"*.gif",
	"*.tiff",
	"*.svg",
	"*.ico",
	"*.pyc",
	"*.pkl",
	"*.DS_Store",
	"*.aux",
	"*.bbl",
	"*.blg",
	"*.brf",
	"*.fls",
	"*.fdb_latexmk",
	"*.synctex.gz",
	"*.xdv",
}

M.lsp_servers = {
	"typescript",
	"cxx",
	"go",
	"lua",
	"nix",
	"python",
	"ruby",
	"rust",
	"sh",
	"swift",
	"terraform",
	"harper",
}

return M
