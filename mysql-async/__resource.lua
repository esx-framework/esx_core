resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

version '3.2.0'

server_script 'mysql-async.js'
client_script 'mysql-async-client.js'

files {
  'ui/index.html',
  'ui/app.js',
  'ui/app.css',
  'ui/fonts/fira-sans-v9-latin-700.woff',
  'ui/fonts/fira-sans-v9-latin-700.woff2',
  'ui/fonts/fira-sans-v9-latin-italic.woff',
  'ui/fonts/fira-sans-v9-latin-italic.woff2',
  'ui/fonts/fira-sans-v9-latin-regular.woff',
  'ui/fonts/fira-sans-v9-latin-regular.woff2',
  'ui/fonts/MaterialIcons-Regular.eot',
  'ui/fonts/MaterialIcons-Regular.ttf',
  'ui/fonts/MaterialIcons-Regular.woff',
  'ui/fonts/MaterialIcons-Regular.woff2',
}

ui_page 'ui/index.html'
