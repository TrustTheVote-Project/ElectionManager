# Need to put this outside directories that are auto reloaded in dev mode.
require "#{Rails.root}/config/ttv/ballot_rule/base"

TTV::BallotRule::Default
TTV::BallotRule::VA
