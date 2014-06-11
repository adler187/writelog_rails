require 'test_helper'

class QsosControllerTest < ActionController::TestCase
  setup do
    @qso = qsos(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:qsos)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create qso" do
    assert_difference('Qso.count') do
      post :create, qso: { band: @qso.band, dupe: @qso.dupe, idkey: @qso.idkey, mode: @qso.mode, serial: @qso.serial, station: @qso.station, time64h: @qso.time64h, time64l: @qso.time64l, updatedby: @qso.updatedby, version: @qso.version }
    end

    assert_redirected_to qso_path(assigns(:qso))
  end

  test "should show qso" do
    get :show, id: @qso
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @qso
    assert_response :success
  end

  test "should update qso" do
    put :update, id: @qso, qso: { band: @qso.band, dupe: @qso.dupe, idkey: @qso.idkey, mode: @qso.mode, serial: @qso.serial, station: @qso.station, time64h: @qso.time64h, time64l: @qso.time64l, updatedby: @qso.updatedby, version: @qso.version }
    assert_redirected_to qso_path(assigns(:qso))
  end

  test "should destroy qso" do
    assert_difference('Qso.count', -1) do
      delete :destroy, id: @qso
    end

    assert_redirected_to qsos_path
  end
end
