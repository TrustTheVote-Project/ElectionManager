require 'ttv/prawn/form'
require 'ttv/prawn/annotations'

Prawn::Document.extensions << TTV::Prawn::Annotation
Prawn::Document.extensions << TTV::Prawn::Form
