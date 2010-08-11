require 'ttv/prawn/form'
require 'ttv/prawn/annotations'
require 'ttv/prawn/form_xobject'

Prawn::Document.extensions << TTV::Prawn::Annotation
Prawn::Document.extensions << TTV::Prawn::FormXObject
Prawn::Document.extensions << TTV::Prawn::Form
