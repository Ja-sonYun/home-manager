vim9script

def g:LspConfig_terraform(): dict<any>
  return {
    name: 'terraform-ls',
    filetype: ['hcl', 'tf', 'tfvars', 'terraform'],
    path: exepath('terraform-ls'),
    args: ['serve'],
    rootSearch: ['terraform.rc', '.terraformrc', 'main.tf', 'versions.tf'],
  }
enddef
