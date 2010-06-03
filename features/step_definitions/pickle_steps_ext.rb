# -*- coding: utf-8 -*-

Given(/^no (.+) exists$/) do |model_class|
  klass = model_class.singularize.camelize.constantize
  klass.delete_all
  assert_equal 0, klass.count
end
