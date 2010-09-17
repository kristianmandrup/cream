require 'active_support/inflector'
require 'require_all'
require 'cream/namespaces'    

require 'sugar-high/alias'
require 'sugar-high/kind_of'
require 'sugar-high/array'

require_all File.dirname(__FILE__) + '/cream/controller'
require_all File.dirname(__FILE__) + '/cream/helper'
require_all File.dirname(__FILE__) + '/cream/view'

