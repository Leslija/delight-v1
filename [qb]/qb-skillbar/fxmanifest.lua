fx_version 'cerulean'
game 'gta5'

description 'QB-Skillbar'
version '1.0.0'

ui_page "html/index.html"

client_scripts {
    '@mka-lasers/client/client.lua',
    'client/main.lua',
}

files {
    'html/index.html',
    'html/script.js',
    'html/style.css',
    'html/VerdanaBold.ttf'
}

exports {
    'GetSkillbarObject'
}

dependencies {
    'qb-core'
}

lua54 'yes'