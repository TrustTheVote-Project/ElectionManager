require 'ttv/prawn/form'
require 'ttv/prawn/annotations'
require 'ttv/prawn/form_xobject'
require 'ttv/prawn/snapshot'
require 'ttv/prawn/internals'

Prawn::Document.extensions << TTV::Prawn::Annotation
Prawn::Document.extensions << TTV::Prawn::FormXObject
Prawn::Document.extensions << TTV::Prawn::Form

