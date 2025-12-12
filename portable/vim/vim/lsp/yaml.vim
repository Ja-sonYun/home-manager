vim9script

def g:LspConfig_yaml(): dict<any>
  return {
    name: 'yaml-language-server',
    filetype: ['yaml', 'yml'],
    path: exepath('yaml-language-server'),
    args: ['--stdio'],
    workspaceConfig: {
      yaml: {
        schemas: {
          'https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json': ['**/*docker-compose*.yaml'],
          'https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.34.1-standalone-strict/all.json': ['**/k8s/**/*.yaml', '**/kubernetes/**/*.yaml'],
          'https://json.schemastore.org/kustomization.json': ['**/kustomization.{yml,yaml}'],
          'https://json.schemastore.org/helmfile.json': ['**/helmfile.{yml,yaml}'],
          'https://json.schemastore.org/chart.json': ['**/Chart.{yml,yaml}', '**/values*.{yml,yaml}'],
          'https://json.schemastore.org/github-workflow.json': ['.github/workflows/*.{yml,yaml}'],
          'https://json.schemastore.org/github-action.json': ['action.{yml,yaml}'],
          'https://json.schemastore.org/ansible-playbook.json': ['**/playbook*.{yml,yaml}', '**/ansible/**/*.yaml'],
          'https://json.schemastore.org/cloudformation.json': ['**/cf-*.{yml,yaml}', '**/cfn*.{yml,yaml}'],
          'https://github.com/rendercv/rendercv/raw/main/schema.json': ['**/*_cv.yaml', '**/*rendercv*.yaml'],
        },
      },
    },
  }
enddef
