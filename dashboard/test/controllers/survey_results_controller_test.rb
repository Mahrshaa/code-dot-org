require 'test_helper'

class SurveyResultsControllerTest < ActionController::TestCase
  setup do
    @teacher = create(:teacher)
  end

  test 'post diversity survey results' do
    sign_in @teacher

    assert_creates(SurveyResult) do
      post :create,
        params: {
          survey: {kind: 'Diversity2016', survey2016_ethnicity_asian: 22, survey2016_foodstamps: 3}
        },
        format: :json
    end

    survey_result = SurveyResult.where(user: @teacher).first
    assert survey_result
    assert_equal 'Diversity2016', survey_result.kind
    assert_equal 22, survey_result["properties"]["survey2016_ethnicity_asian"].to_i
    assert_equal 3, survey_result["properties"]["survey2016_foodstamps"].to_i
  end

  test 'post net promoter score survey results' do
    sign_in @teacher

    nps_value = 10
    nps_comment = "Rock on"
    assert_creates(SurveyResult) do
      post :create,
        params: {
          survey: {kind: 'NetPromoterScore2015', nps_value: nps_value, nps_comment: nps_comment}
        },
        format: :json
    end

    survey_result = SurveyResult.where(user: @teacher).first
    assert survey_result
    assert_equal 'NetPromoterScore2015', survey_result.kind
    assert_equal nps_value, survey_result.properties['nps_value'].to_i
    assert_equal nps_comment, survey_result.properties['nps_comment']
  end

  test 'blocks non-whitelisted parameters' do
    sign_in @teacher

    assert_creates(SurveyResult) do
      post :create,
        params: {
          survey: {kind: 'Diversity2016', nonwhitelisted: 'untrusted data'}
        },
        format: :json
    end

    survey_result = SurveyResult.where(user: @teacher).first
    assert survey_result
    assert_equal 'Diversity2016', survey_result.kind
    assert survey_result['properties']['nonwhitelisted'].nil?
  end

  test 'fixes non-utf-8 characters' do
    sign_in @teacher
    assert_creates(SurveyResult) do
      post :create,
        params: {
          survey: {
            kind: 'NetPromoterScore2017',
            nps_value: 1,
            nps_comment: "testing #{panda_panda}"
          }
        },
        format: :json
    end
    survey_result = SurveyResult.find_by_user_id(@teacher.id)
    assert survey_result
    assert_equal 'NetPromoterScore2017', survey_result.kind
    assert_equal '1', survey_result.nps_value
    # The panda is a four byte sequence, so there are four replacement
    # characters.
    assert_equal "testing Panda\u{fffd}\u{fffd}\u{fffd}\u{fffd}", survey_result.nps_comment
  end
end
