require 'require_all'
require 'rails'
# require 'devise'
require 'devise-links'

require 'cancan'
require 'cancan-rest-links'
require 'cancan-permits'

require 'cream/namespaces' 

require 'sugar-high/alias'
require 'sugar-high/kind_of'
require 'sugar-high/array'

require 'cream/role'    

require_all File.dirname(__FILE__) + '/cream/controller'
require_all File.dirname(__FILE__) + '/cream/helper'
require_all File.dirname(__FILE__) + '/cream/view'
require_all File.dirname(__FILE__) + '/cream/rails'

require 'cream/roles_config'


