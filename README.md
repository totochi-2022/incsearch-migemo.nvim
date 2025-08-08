# incsearch-migemo.nvim

A simple incremental migemo search plugin for Neovim.

## Features

- **Incremental search**: Real-time search as you type
- **Migemo support**: Japanese text search with romanized input
- **Simple API**: Three main functions for different search modes
- **Lightweight**: Pure Lua implementation, no external dependencies
- **Toggle-friendly**: Easy integration with configuration toggles

## Requirements

- Neovim 0.5+
- One of the following:
  - `cmigemo` command (recommended)
  - Vim with builtin migemo support

## Installation

### lazy.nvim
```lua
{
  "motoki317/incsearch-migemo.nvim",
  tag = "v1.0.0",
}
```

### packer.nvim
```lua
use {
  "motoki317/incsearch-migemo.nvim",
  tag = "v1.0.0",
}
```

## Usage

### Basic Setup
```lua
local migemo = require('incsearch-migemo')

-- Setup with default configuration
migemo.setup()

-- Check if migemo is available
if migemo.has_migemo() then
  -- Setup keymaps
  vim.keymap.set('n', 'm/', migemo.forward, { desc = 'Migemo forward search' })
  vim.keymap.set('n', 'm?', migemo.backward, { desc = 'Migemo backward search' })
  vim.keymap.set('n', 'mg/', migemo.stay, { desc = 'Migemo stay search' })
end
```

### Custom Configuration
```lua
require('incsearch-migemo').setup({
  migemo_command = "cmigemo",  -- migemo command path
  migemo_dict = "/usr/share/cmigemo/utf-8/migemo-dict",  -- dictionary path
  highlight = true,  -- enable search highlighting
})
```

## API

### Functions

- `forward()` - Forward migemo search
- `backward()` - Backward migemo search
- `stay()` - Stay migemo search (cursor position maintained)
- `has_migemo()` - Check if migemo is available
- `setup(opts)` - Setup with configuration

### Search Modes

- **Forward/Backward**: Search and jump to matches
- **Stay**: Search and highlight matches but keep cursor position (useful when migemo is slow)

## How It Works

1. Type characters one by one
2. Migemo converts romanized input to Japanese regex pattern
3. Search results are highlighted in real-time
4. Press `Enter` to confirm, `Escape` to cancel

Example: Typing `kanji` will match `漢字`, `かんじ`, `カンジ`, etc.

## Toggle Integration

Perfect for configuration toggles:

```lua
-- In your toggle configuration
m = {
  name = 'migemo',
  get_state = function()
    return vim.g.migemo_enabled and 'on' or 'off'
  end,
  set_state = function(state)
    local migemo = require('incsearch-migemo')
    if state == 'on' and migemo.has_migemo() then
      vim.keymap.set('n', 'm/', migemo.forward)
      vim.keymap.set('n', 'm?', migemo.backward)
      vim.g.migemo_enabled = true
    else
      pcall(vim.keymap.del, 'n', 'm/')
      pcall(vim.keymap.del, 'n', 'm?')
      vim.g.migemo_enabled = false
    end
  end
}
```

## License

Apache License 2.0