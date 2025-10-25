vim9script

import autoload 'utils/gpt.vim' as gpt

def GenerateReplacer(prompt: string, system_prompt: string): func<void>
  def InnerFunc(start: number, end: number): void
    echom 'Calling GPT to process text...'
    const text = join(getline(start, end), "\n")
    const full_prompt = prompt .. '\n' .. text

    gpt.CallAsync(
      'gpt-5-nano',
      full_prompt,
      (result) => {
        const lines = split(result, "\n")
        setline(start, lines)
        if len(lines) < end - start + 1
          deletebufline('%', start + len(lines), end)
        endif
        echohl MoreMsg
        echom 'Text replacement completed.'
        echohl None
      },
      {
        system_prompt: system_prompt,
        extra_params: {
          reasoning_effort: 'medium',
        },
      }
    )
  enddef

  return InnerFunc
enddef

const GrammarFix = GenerateReplacer(
  'Fix the grammar of the following text without changing meaning:',
  'You are a precise grammar correction model. Output only corrected text.'
)
const AddComment = GenerateReplacer(
  'Add insightful comments to the following code to improve its readability:',
  'You are an expert programmer who writes clear and concise comments. Output only the code with added comments. Do not change the original code functionality.'
)

command! -range Fix call GrammarFix(<line1>, <line2>)
command! -range Com call AddComment(<line1>, <line2>)

defcompile
