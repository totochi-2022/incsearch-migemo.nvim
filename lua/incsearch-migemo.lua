-- incsearch-migemo.nvim
-- シンプルなインクリメンタルmigemo検索プラグイン for Neovim

local M = {}

-- デフォルト設定
local default_config = {
    migemo_command = "cmigemo",
    migemo_dict = "/usr/share/cmigemo/utf-8/migemo-dict",
    highlight = true,
}

M.config = default_config

-- migemoが利用可能かチェック
function M.has_migemo()
    -- Vimビルトインのmigemoが使える場合
    if vim.fn.has("migemo") == 1 then
        return true
    end
    
    -- cmigemoコマンドが使える場合
    if vim.fn.executable(M.config.migemo_command) == 1 then
        return true
    end
    
    return false
end

-- migemoで文字列を変換（Vim正規表現として）
local function migemo_convert(query)
    if query == "" then
        return ""
    end
    
    -- Vimビルトインのmigemoが使える場合
    if vim.fn.has("migemo") == 1 then
        return vim.fn.migemo(query)
    end
    
    -- cmigemoを使う場合
    if vim.fn.executable(M.config.migemo_command) == 0 then
        return query
    end
    
    -- cmigemoの-vオプションでVim用の正規表現を生成
    local cmd = string.format("%s -v -w '%s' -d '%s'", 
        M.config.migemo_command,
        query:gsub("'", "'\\''"),
        M.config.migemo_dict
    )
    
    local result = vim.fn.system(cmd)
    
    if vim.v.shell_error ~= 0 then
        return query
    end
    
    return vim.fn.trim(result)
end

-- インクリメンタル検索の実装
local function incremental_search(direction, stay_mode)
    local prompt = direction == "/" and "/" or "?"
    local current_input = ""
    local original_pos = vim.fn.getpos(".")
    
    -- 検索ハイライトを有効化
    if M.config.highlight then
        vim.o.hlsearch = true
    end
    
    -- コマンドラインを使った入力ループ
    vim.cmd("echo ''")
    vim.cmd("redraw")
    
    while true do
        -- プロンプトと現在の入力を表示
        vim.cmd(string.format("echo '%s%s'", prompt, vim.fn.escape(current_input, "'")))
        
        -- 1文字入力を待つ
        local char = vim.fn.getchar()
        
        -- Escapeキー
        if char == 27 then
            -- 元の位置に戻る
            vim.fn.setpos(".", original_pos)
            vim.cmd("echo ''")
            return
        -- Enterキー
        elseif char == 13 then
            -- 検索確定
            vim.cmd("echo ''")
            if stay_mode then
                -- stayモードの場合は元の位置に戻る
                vim.fn.setpos(".", original_pos)
            end
            return
        -- Backspace
        elseif char == 8 or char == 127 then
            if #current_input > 0 then
                current_input = string.sub(current_input, 1, -2)
            end
        -- 通常の文字
        else
            local char_str = vim.fn.nr2char(char)
            current_input = current_input .. char_str
        end
        
        -- 入力があれば検索
        if current_input ~= "" then
            -- migemoで変換
            local pattern = migemo_convert(current_input)
            
            -- 検索レジスタに設定
            vim.fn.setreg("/", pattern)
            
            -- 元の位置から検索
            vim.fn.setpos(".", original_pos)
            
            -- 検索実行（エラーを無視）
            local flags = direction == "/" and "c" or "bc"
            pcall(vim.fn.search, pattern, flags)
        else
            -- 入力が空なら元の位置に戻る
            vim.fn.setpos(".", original_pos)
        end
        
        -- 画面を更新
        vim.cmd("redraw")
    end
end

-- 前方migemo検索
function M.forward()
    incremental_search("/", false)
end

-- 後方migemo検索
function M.backward()
    incremental_search("?", false)
end

-- ステイmigemo検索（カーソル位置維持）
function M.stay()
    incremental_search("/", true)
end

-- セットアップ
function M.setup(opts)
    if opts then
        M.config = vim.tbl_deep_extend("force", M.config, opts)
    end
    
    -- migemoの利用可能性をチェック
    if not M.has_migemo() then
        vim.notify("incsearch-migemo.nvim: migemo not available", vim.log.levels.WARN)
        return false
    end
    
    return true
end

return M