class NerEvaluationController < ApplicationController
  before_action :require_login

  def index
    @results = RuleEvaluatorService.evaluate_all
  end
end
