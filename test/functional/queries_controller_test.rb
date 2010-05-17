require File.dirname(__FILE__) + '/../test_helper'

class MylynConnector::QueriesControllerTest < MylynConnector::ControllerTest
  fixtures :queries

  def setup
    super
    @controller = MylynConnector::QueriesController.new
  end

  def test_all_unauthenticated
    get :all
    assert_response :success
    assert_template 'all.xml.builder'

    xmldoc = XML::Document.string @response.body
    schema = read_schema 'queries'
    valid = xmldoc.validate_schema schema
    assert valid , 'Ergebnis passt nicht zum Schema ' + 'queries'

    qs =  {:tag => 'queries', :children => {:count => 5}, :attributes => {:api => /^2.7.0/}}
    q = {:tag => 'query', :attributes => {:id => 6}, :parent => qs}
    assert_tag qs
    assert_tag q

    assert_tag :tag => 'name', :content => 'Open issues grouped by tracker', :parent => q

  end

    def test_all_authenticated
    @request.session[:user_id] = 2

      get :all
    assert_response :success
    assert_template 'all.xml.builder'

    xmldoc = XML::Document.string @response.body
    schema = read_schema 'queries'
    valid = xmldoc.validate_schema schema
    assert valid , 'Ergebnis passt nicht zum Schema ' + 'queries'

    qs =  {:tag => 'queries', :children => {:count => 7}, :attributes => {:api => /^2.7.0/}}
    assert_tag qs

    assert_tag :tag => 'query', :attributes => {:id => 1}, :parent => qs
    assert_tag :tag => 'query', :attributes => {:id => 4}, :parent => qs
    assert_tag :tag => 'query', :attributes => {:id => 5}, :parent => qs
    assert_tag :tag => 'query', :attributes => {:id => 6}, :parent => qs
    assert_tag :tag => 'query', :attributes => {:id => 7}, :parent => qs
    assert_tag :tag => 'query', :attributes => {:id => 8}, :parent => qs
    assert_tag :tag => 'query', :attributes => {:id => 9}, :parent => qs

  end

  def test_all_empty_is_valid
    Query.delete_all
 
    get :all

    xmldoc = XML::Document.string @response.body
    schema = read_schema 'queries'
    valid = xmldoc.validate_schema schema
    assert valid , 'Ergebnis passt nicht zum Schema ' + 'queries'

    assert_tag :tag => 'queries', :children => {:count => 0}, :attributes => {:api => /^2.7.0/}
  end
end
