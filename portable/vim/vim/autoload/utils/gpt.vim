vim9script

import autoload 'utils/curl.vim' as curl

g:default_openai_endpoint = 'https://api.openai.com/v1'
g:default_openai_api_key = getenv('OPENAI_API_KEY')

def BuildChatCompletionURL(): string
  const endpoint = get(g:, 'default_openai_endpoint', '')
  return endpoint .. '/chat/completions'
enddef

def BuildHeaders(stream: bool = false): dict<string>
  var headers: dict<string> = {
    'Content-Type': 'application/json',
  }
  if stream
    headers['Accept'] = 'text/event-stream'
  endif

  var api_key = get(g:, 'default_openai_api_key', '')
  if api_key == ''
    throw 'OpenAI API key is not set. Please set the OPENAI_API_KEY environment variable or g:default_openai_api_key.'
  endif
  headers['Authorization'] = 'Bearer ' .. api_key
  return headers
enddef

def BuildMessages(prompt: string, system_prompt: string = ''): list<dict<string>>
  var messages: list<dict<string>> = []
  if system_prompt != ''
    add(messages, {'role': 'system', 'content': system_prompt})
  endif
  add(messages, {'role': 'user', 'content': prompt})
  return messages
enddef

def BuildPayload(
  messages: list<dict<string>>,
  model: string,
  stream: bool,
  extra_params: dict<any> = {}
): dict<any>
  var payload: dict<any> = {
    'model': model,
    'messages': messages,
    'stream': stream,
  }
  for [k, v] in items(extra_params)
    payload[k] = v
  endfor
  return payload
enddef

def CreateCall(
  model: string,
  prompt: string,
  opts: dict<any> = {}
): curl.Request
  const headers = BuildHeaders()
  const messages = BuildMessages(prompt, get(opts, 'system_prompt', ''))
  const extra_params = get(opts, 'extra_params', {})
  const payload = BuildPayload(messages, model, false, extra_params)
  const endpoint = BuildChatCompletionURL()

  const req = curl.Request.new(
    endpoint,
    {
      method: 'POST',
      headers: headers,
      data: json_encode(payload),
    }
  )
  return req
enddef

def ParseCallResponse(res: curl.Response): string
  if res.status != 200
    throw 'OpenAI API request failed with status ' .. string(res.status)
  endif
  const body = res.Body()
  const data = body['choices'][0]['message']['content']
  return data
enddef

# Call(
#   'gpt-5',
#   'Hello, how are you?',
#   {
#     system_prompt: 'You are a friendly chatbot.',
#   }
# )
export def Call(
  model: string,
  prompt: string,
  opts: dict<any> = {}
): string
  const req = CreateCall(model, prompt, opts)
  const res = req.Join()
  return ParseCallResponse(res)
enddef

export def CallAsync(
  model: string,
  prompt: string,
  cb: any,
  opts: dict<any> = {}
): void
  const req = CreateCall(model, prompt, opts)
  req.Start()
  req.WaitAsync(100, (res) => {
    const data = ParseCallResponse(res)
    call(cb, [data])
  })
enddef


def CreateCallTool(
  model: string,
  name: string,
  prompt: string,
  parameters: dict<any>,
  opts: dict<any> = {}
): curl.Request
  const headers = BuildHeaders()
  const messages = BuildMessages(prompt, get(opts, 'system_prompt', ''))
  var base_extra = get(opts, 'extra_params', {})
  const tool_info = {
    'tools': [
      {
        'type': 'function',
        'function': {
          'name': name,
          'parameters': parameters,
        }
      }
    ],
    'tool_choice': {'type': 'function', 'function': {'name': name}},
  }
  const extra_params = extend(copy(base_extra), tool_info)
  const payload = BuildPayload(messages, model, false, extra_params)
  const endpoint = BuildChatCompletionURL()
  const req = curl.Request.new(
    endpoint,
    {
      method: 'POST',
      headers: headers,
      data: json_encode(payload),
    }
  )
  return req
enddef

def ParseCallToolResponse(res: curl.Response): dict<any>
  if res.status != 200
    throw 'OpenAI API request failed with status ' .. string(res.status)
  endif
  const body = res.Body()
  const data = body['choices'][0]['message']['tool_calls'][0]['function']['arguments']
  return json_decode(data)
enddef

# const res = CallTool(
#   'gpt-5',
#   'get_weather',
#   'What is the current weather in New York?',
#   {
#     'type': 'object',
#     'properties': {
#       'location': {'type': 'string', 'description': 'city name'},
#       'unit': {'type': 'string', 'enum': ['celsius', 'fahrenheit']},
#     },
#     'required': ['location'],
#   },
#   {
#     system_prompt: 'You can use get_weather tool to fetch current weather information.',
#   }
# )
# echo res["location"]
export def CallTool(
  model: string,
  name: string,
  prompt: string,
  parameters: dict<any>,
  opts: dict<any> = {}
): dict<any>
  const req = CreateCallTool(model, name, prompt, parameters, opts)
  const res = req.Join()
  return ParseCallToolResponse(res)
enddef

export def CallToolAsync(
  model: string,
  name: string,
  prompt: string,
  parameters: dict<any>,
  cb: any,
  opts: dict<any> = {}
): void
  const req = CreateCallTool(model, name, prompt, parameters, opts)
  req.Start()
  req.WaitAsync(100, (res) => {
    const data = ParseCallToolResponse(res)
    call(cb, [data])
  })
enddef
